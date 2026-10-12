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
      delivered = true;
      clock?.cancel();
      unawaited(speech.stop());
      Navigator.pop(context, front);
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
      clock = Timer.periodic(const Duration(milliseconds: 200), (_) {
        if (!mounted) return;
        final now = monotonic.elapsed;
        final delta = (now - tickAt);
        tickAt = now;
        if (!takingPhoto && (now - analyzedAt).inMilliseconds > 800) {
          guide.updatePose(inFrame: false, yaw: 0, pitch: 0);
        }
        guide.tick(Duration(milliseconds: delta.inMilliseconds.clamp(0, 300)));
      });
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

  Future<void> _analyze(CameraImage frame) async {
    final controller = camera;
    if (analyzing ||
        takingPhoto ||
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
      if (rotation == null) return;
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
      analyzedAt = monotonic.elapsed;
      if (faces.length != 1) {
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
      guide.updatePose(
          inFrame: inFrame,
          yaw: face.headEulerAngleY ?? 90,
          pitch: face.headEulerAngleX ?? 90);
    } catch (_) {
      if (mounted && ticket == generation) {
        guide.updatePose(inFrame: false, yaw: 0, pitch: 0);
      }
    } finally {
      analyzing = false;
    }
  }

  Uint8List _nv21(CameraImage image) {
    if (image.planes.length == 1) return image.planes.first.bytes;
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
      clock = Timer.periodic(const Duration(milliseconds: 200), (_) {
        final now = monotonic.elapsed;
        final delta = (now - tickAt);
        tickAt = now;
        if ((now - analyzedAt).inMilliseconds > 800) {
          guide.updatePose(inFrame: false, yaw: 0, pitch: 0);
        }
        guide.tick(Duration(milliseconds: delta.inMilliseconds.clamp(0, 300)));
      });
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
                          ] else if (camera?.value.isInitialized != true)
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
                                      CustomPaint(
                                          painter:
                                              _FaceFrame(ready: guide.ready)),
                                      Positioned(
                                          right: 16,
                                          bottom: 16,
                                          child: Container(
                                              width: 60,
                                              height: 60,
                                              padding: const EdgeInsets.all(6),
                                              decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle),
                                              child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    SizedBox.expand(
                                                        child:
                                                            CircularProgressIndicator(
                                                                value: guide
                                                                    .progress,
                                                                strokeWidth: 3,
                                                                color: AppColors
                                                                    .primary)),
                                                    if (guide.stage ==
                                                        FaceGuidanceStage
                                                            .capturing)
                                                      const Icon(
                                                          Icons.check_rounded,
                                                          color:
                                                              AppColors.primary,
                                                          size: 28)
                                                    else
                                                      FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          child: Text(
                                                              '${guide.seconds}',
                                                              style: const TextStyle(
                                                                  fontSize: 24,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                  color: AppColors
                                                                      .primary)))
                                                  ]))),
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
                                  ? 'Hold this position'
                                  : 'Keep one face centered and follow the instruction',
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

class _FaceFrame extends CustomPainter {
  const _FaceFrame({required this.ready});
  final bool ready;
  @override
  void paint(Canvas canvas, Size size) {
    final frame = RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: size.center(Offset.zero),
            width: size.width * .75,
            height: size.height * .82),
        const Radius.circular(16));
    canvas.drawPath(
        Path.combine(PathOperation.difference,
            Path()..addRect(Offset.zero & size), Path()..addRRect(frame)),
        Paint()..color = const Color(0x66000000));
    canvas.drawRRect(
        frame,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = ready ? AppColors.primary : Colors.white);
  }

  @override
  bool shouldRepaint(_FaceFrame oldDelegate) => ready != oldDelegate.ready;
}
