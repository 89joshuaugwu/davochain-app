import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../../core/theme/app_theme.dart';
import '../presentation/verification/verification_components.dart';
import 'face_guidance.dart';
import 'face_oval_overlay.dart';
import 'face_capture_reveal.dart';
import 'face_frame_freshness.dart';
import 'nv21_frame.dart';
import 'verification_attachment.dart';
import 'verification_media_gateway.dart'
    show cacheVerificationAttachment, releaseCapturedSource;

class GuidedFaceCaptureScreen extends StatefulWidget {
  const GuidedFaceCaptureScreen({super.key});
  @override
  State<GuidedFaceCaptureScreen> createState() => _GuidedFaceState();
}

class _GuidedFaceState extends State<GuidedFaceCaptureScreen>
    with WidgetsBindingObserver {
  final guide = FaceGuidance();
  final detector = FaceDetector(
      options: FaceDetectorOptions(
          performanceMode: FaceDetectorMode.fast, enableTracking: true));
  final speech = FlutterTts();
  CameraController? camera;
  Timer? clock;
  VerificationAttachment? front;
  String? error;
  String detectionFeedback = 'Looking for your face. Use good lighting.';
  int detectorFailures = 0;
  bool starting = false,
      analyzing = false,
      takingPhoto = false,
      delivered = false,
      voice = true;
  int generation = 0;
  final monotonic = Stopwatch()..start();
  Duration analyzedAt = Duration.zero, tickAt = Duration.zero;
  FaceGuidanceStage? spoken;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    guide.addListener(_changed);
    unawaited(_initialize());
  }

  void _changed() {
    if (!mounted) return;
    if (spoken != guide.stage &&
        camera?.value.isInitialized == true &&
        error == null) {
      spoken = guide.stage;
      unawaited(_speak());
    }
    setState(() {});
    if (guide.stage == FaceGuidanceStage.capturing && !takingPhoto) {
      unawaited(_captureFront());
    }
    if (guide.stage == FaceGuidanceStage.done && front != null && !delivered) {
      clock?.cancel();
      unawaited(speech.stop());
    }
  }

  Future<void> _speak() async {
    try {
      await speech.stop();
      if (!mounted || !voice) return;
      await speech.setLanguage('en-US');
      await speech.setSpeechRate(.45);
      if (mounted && voice) await speech.speak(guide.instruction);
    } catch (_) {
      /* On-screen guidance remains available without a speech engine. */
    }
  }

  Future<void> _initialize() async {
    if (starting) return;
    starting = true;
    final ticket = ++generation;
    clock?.cancel();
    front?.release();
    front = null;
    spoken = null;
    analyzedAt = Duration.zero;
    detectorFailures = 0;
    detectionFeedback = 'Looking for your face. Use good lighting.';
    guide.reset();
    if (mounted) setState(() => error = null);
    CameraController? controller;
    try {
      await camera?.dispose();
      camera = null;
      final cameras = await availableCameras();
      final fronts = cameras
          .where((item) => item.lensDirection == CameraLensDirection.front);
      if (fronts.isEmpty) {
        throw const FormatException(
            'A front camera is not available on this device.');
      }
      controller = CameraController(fronts.first, ResolutionPreset.medium,
          enableAudio: false,
          imageFormatGroup: Platform.isAndroid
              ? ImageFormatGroup.nv21
              : ImageFormatGroup.bgra8888);
      await controller.initialize();
      await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
      if (!mounted || ticket != generation) {
        await controller.dispose();
        return;
      }
      camera = controller;
      await controller.startImageStream(_analyze);
      tickAt = monotonic.elapsed;
      clock = Timer.periodic(const Duration(milliseconds: 200), (_) => _tick());
      spoken = guide.stage;
      await _speak();
    } catch (failure) {
      if (mounted && ticket == generation) {
        setState(() => error = failure is CameraException &&
                failure.code.contains('Denied')
            ? 'Camera access is needed to take your selfie. Enable camera access in your device settings, then retry.'
            : failure is FormatException
                ? failure.message
                : 'The camera could not start. Close other camera apps and try again.');
      }
      if (controller != camera) {
        try {
          await controller?.dispose();
        } catch (_) {}
      }
    } finally {
      starting = false;
      if (mounted) setState(() {});
    }
  }

  void _tick() {
    if (!mounted || takingPhoto || error != null) return;
    final now = monotonic.elapsed;
    final delta = now - tickAt;
    tickAt = now;
    switch (faceFrameFreshness(now - analyzedAt)) {
      case FaceFrameFreshness.expired:
        detectionFeedback = 'Waiting for a clear camera frame. Hold still.';
        guide.updatePose(inFrame: false, yaw: 0, pitch: 0);
        return;
      case FaceFrameFreshness.waiting:
        setState(() => detectionFeedback =
            'Processing your face. Keep holding this position.');
        return;
      case FaceFrameFreshness.fresh:
        guide.tick(Duration(milliseconds: delta.inMilliseconds.clamp(0, 300)));
    }
  }

  Future<void> _analyze(CameraImage frame) async {
    final controller = camera;
    if (analyzing ||
        takingPhoto ||
        error != null ||
        !mounted ||
        controller == null ||
        (monotonic.elapsed - analyzedAt).inMilliseconds < 120) {
      return;
    }
    analyzing = true;
    final ticket = generation;
    try {
      final rotation = InputImageRotationValue.fromRawValue(
          controller.description.sensorOrientation);
      if (rotation == null) {
        throw const FormatException('Unsupported camera rotation.');
      }
      final bytes =
          Platform.isAndroid ? _nv21(frame) : frame.planes.first.bytes;
      final input = InputImage.fromBytes(
          bytes: bytes,
          metadata: InputImageMetadata(
              size: Size(frame.width.toDouble(), frame.height.toDouble()),
              rotation: rotation,
              format: Platform.isAndroid
                  ? InputImageFormat.nv21
                  : InputImageFormat.bgra8888,
              bytesPerRow: Platform.isAndroid
                  ? frame.width
                  : frame.planes.first.bytesPerRow));
      final faces = await detector.processImage(input);
      if (!mounted || ticket != generation) return;
      detectorFailures = 0;
      analyzedAt = monotonic.elapsed;
      if (faces.length != 1) {
        detectionFeedback = faces.isEmpty
            ? 'No face detected. Face the camera in good lighting.'
            : 'More than one face detected. Keep only your face in view.';
        guide.updatePose(inFrame: false, yaw: 0, pitch: 0);
        return;
      }
      final face = faces.single;
      final sideways = rotation == InputImageRotation.rotation90deg ||
          rotation == InputImageRotation.rotation270deg;
      final width = (sideways ? frame.height : frame.width).toDouble(),
          height = (sideways ? frame.width : frame.height).toDouble();
      final box = face.boundingBox;
      final inFrame = box.width > width * .18 &&
          box.width < width * .8 &&
          box.center.dx > width * .25 &&
          box.center.dx < width * .75 &&
          box.center.dy > height * .2 &&
          box.center.dy < height * .8;
      detectionFeedback = !inFrame
          ? box.width <= width * .18
              ? 'Move closer until your face fills the oval.'
              : box.width >= width * .8
                  ? 'Move back slightly to fit your whole face inside the oval.'
                  : 'Center your face inside the oval.'
          : face.headEulerAngleY == null || face.headEulerAngleX == null
              ? 'Face detected. Hold still so your head position can be read.'
              : guide.stage == FaceGuidanceStage.front &&
                      ((face.headEulerAngleY!).abs() > 15 ||
                          (face.headEulerAngleX!).abs() > 15)
                  ? 'Face detected. Look straight at the camera and level your head.'
                  : 'Face detected. Follow the head movement instruction.';
      guide.updatePose(
          inFrame: inFrame,
          yaw: frontCameraUserYaw(face.headEulerAngleY ?? 90),
          pitch: face.headEulerAngleX ?? 90);
    } catch (failure) {
      if (mounted && ticket == generation) {
        detectorFailures++;
        debugPrint('Live face detection failed: ${failure.runtimeType}; '
            'code=${failure is PlatformException ? failure.code : "frame"}; '
            'format=${frame.format.group}, planes=${frame.planes.length}, '
            'size=${frame.width}x${frame.height}');
        detectionFeedback = 'The camera frame could not be read. Retrying.';
        if (detectorFailures >= 3) {
          error = 'Live face detection could not read the camera frames. '
              'Retry the camera to restart detection.';
          clock?.cancel();
        }
        guide.updatePose(inFrame: false, yaw: 0, pitch: 0);
      }
    } finally {
      analyzing = false;
    }
  }

  Uint8List _nv21(CameraImage image) {
    if (image.planes.length == 1) {
      return packedNv21Bytes(
          image.planes.first.bytes, image.width, image.height);
    }
    if (image.planes.length != 3) {
      throw const FormatException('Unsupported camera plane layout.');
    }
    final result = Uint8List(image.width * image.height * 3 ~/ 2);
    var index = 0;
    final y = image.planes[0], u = image.planes[1], v = image.planes[2];
    for (var row = 0; row < image.height; row++) {
      for (var col = 0; col < image.width; col++) {
        result[index++] =
            y.bytes[row * y.bytesPerRow + col * (y.bytesPerPixel ?? 1)];
      }
    }
    for (var row = 0; row < image.height ~/ 2; row++) {
      for (var col = 0; col < image.width ~/ 2; col++) {
        result[index++] =
            v.bytes[row * v.bytesPerRow + col * (v.bytesPerPixel ?? 1)];
        result[index++] =
            u.bytes[row * u.bytesPerRow + col * (u.bytesPerPixel ?? 1)];
      }
    }
    return result;
  }

  Future<void> _captureFront() async {
    takingPhoto = true;
    clock?.cancel();
    final controller = camera, ticket = generation;
    VerificationAttachment? attachment;
    try {
      if (controller == null) return;
      await controller.stopImageStream();
      final photo = await controller.takePicture();
      try {
        final faces =
            await detector.processImage(InputImage.fromFilePath(photo.path));
        if (faces.length != 1 ||
            (faces.single.headEulerAngleY ?? 90).abs() > 15 ||
            (faces.single.headEulerAngleX ?? 90).abs() > 15) {
          throw const FormatException(
              'Keep your face forward until the photo is captured.');
        }
        attachment =
            await cacheVerificationAttachment(photo.path, name: 'selfie.jpg');
      } finally {
        await releaseCapturedSource(photo.path);
      }
      if (!mounted || ticket != generation) {
        attachment.release();
        return;
      }
      front?.release();
      front = attachment;
      HapticFeedback.lightImpact();
      await controller.startImageStream(_analyze);
      guide.frontCaptured();
      tickAt = monotonic.elapsed;
      analyzedAt = Duration.zero;
      clock = Timer.periodic(const Duration(milliseconds: 200), (_) => _tick());
    } catch (_) {
      attachment?.release();
      front = null;
      if (mounted && ticket == generation) {
        setState(
            () => error = 'Your photo could not be captured. Please retry.');
      }
    } finally {
      takingPhoto = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && camera == null && !starting) {
      unawaited(_initialize());
    } else if (state != AppLifecycleState.resumed &&
        camera?.value.isInitialized == true) {
      generation++;
      clock?.cancel();
      unawaited(speech.stop());
      final previous = camera;
      camera = null;
      unawaited(previous?.dispose());
      front?.release();
      front = null;
      guide.reset();
    }
  }

  @override
  void dispose() {
    generation++;
    WidgetsBinding.instance.removeObserver(this);
    clock?.cancel();
    guide.removeListener(_changed);
    guide.dispose();
    if (!delivered) front?.release();
    unawaited(camera?.dispose());
    unawaited(speech.stop());
    unawaited(Future<void>.delayed(const Duration(milliseconds: 300), () async {
      try {
        await detector.close();
      } catch (_) {}
    }));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    return Scaffold(
        backgroundColor: DavoColors.of(context).surface,
        appBar: AppBar(
            title: const Text('Face Verification', style: verificationHeading),
            centerTitle: true,
            actions: [
              IconButton(
                  tooltip:
                      voice ? 'Mute voice guidance' : 'Enable voice guidance',
                  icon: Icon(voice
                      ? Icons.volume_up_rounded
                      : Icons.volume_off_rounded),
                  onPressed: () {
                    setState(() => voice = !voice);
                    if (voice) {
                      unawaited(_speak());
                    } else {
                      unawaited(speech.stop());
                    }
                  })
            ]),
        body: SafeArea(
            top: false,
            child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text('Live face detection',
                              style: verificationHeading),
                          const SizedBox(height: 8),
                          const Text(
                              'Your first front-facing photo will be captured automatically. Then follow the head movement prompts.',
                              style: verificationBody),
                          const SizedBox(height: 24),
                          if (error != null) ...[
                            VerificationNotice(error!),
                            const SizedBox(height: 16),
                            VerificationButton('Retry camera',
                                onPressed: starting ? null : _initialize)
                          ] else if (guide.stage == FaceGuidanceStage.done &&
                              front != null)
                            ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                    height: (constraints.maxHeight * .52)
                                        .clamp(260, 380),
                                    child: FaceCaptureReveal(
                                        image: FileImage(File(front!.path)),
                                        onDone: () {
                                          if (guide.stage !=
                                                  FaceGuidanceStage.done ||
                                              front == null ||
                                              delivered) {
                                            return;
                                          }
                                          delivered = true;
                                          Navigator.pop(context, front);
                                        })))
                          else if (camera?.value.isInitialized != true)
                            const SizedBox(
                                height: 300,
                                child:
                                    Center(child: CircularProgressIndicator()))
                          else
                            ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                    height: (constraints.maxHeight * .52)
                                        .clamp(260, 380),
                                    child:
                                        Stack(fit: StackFit.expand, children: [
                                      FittedBox(
                                          fit: BoxFit.cover,
                                          child: SizedBox(
                                              width: camera!
                                                  .value.previewSize!.height,
                                              height: camera!
                                                  .value.previewSize!.width,
                                              child: CameraPreview(camera!))),
                                      FaceOvalOverlay(
                                          ready: guide.ready,
                                          progress: guide.stage ==
                                                  FaceGuidanceStage.capturing
                                              ? 1
                                              : guide.progress),
                                    ]))),
                          const SizedBox(height: 24),
                          Semantics(
                              liveRegion: true,
                              child: AnimatedSwitcher(
                                  duration: reduced
                                      ? Duration.zero
                                      : const Duration(milliseconds: 200),
                                  child: Text(guide.instruction,
                                      key: ValueKey(guide.stage),
                                      textAlign: TextAlign.center,
                                      style: verificationHeading))),
                          const SizedBox(height: 12),
                          Text(
                              guide.ready
                                  ? 'Face aligned. Hold this position.'
                                  : detectionFeedback,
                              textAlign: TextAlign.center,
                              style: verificationCaption.copyWith(
                                  color: DavoColors.of(context).bodyMuted)),
                          const SizedBox(height: 24),
                          VerificationButton('Cancel',
                              secondary: true,
                              onPressed: () => Navigator.maybePop(context)),
                        ])))));
  }
}
