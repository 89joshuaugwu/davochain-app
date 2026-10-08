import 'package:flutter/material.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/shared/motion/davo_motion_spec.dart';
import 'package:davochain/shared/motion/davo_outcome_artwork.dart';
import 'package:davochain/shared/widgets/davo_auth_journey.dart';
import 'package:davochain/shared/motion/davo_working_indicator.dart';

void main() =>
    runApp(MaterialApp(theme: AppTheme.light, home: const MotionGallery()));

/// Development entry point: flutter run -t tool/motion_gallery.dart.
/// Never linked from production Settings.
class MotionGallery extends StatefulWidget {
  const MotionGallery({super.key});
  @override
  State<MotionGallery> createState() => _GalleryState();
}

class _GalleryState extends State<MotionGallery>
    with SingleTickerProviderStateMixin {
  late final AnimationController timeline;
  String scene = 'C';
  bool reduced = false, blue = false;
  int get duration => scene == 'S'
      ? 900
      : scene == 'P'
          ? 1000
          : scene == 'F'
              ? 960
              : scene == 'compact C'
                  ? 680
                  : scene == 'W'
                      ? 1200
                      : scene == 'K' || scene == 'H'
                          ? 280
                          : 1120;
  @override
  void initState() {
    super.initState();
    timeline = AnimationController(
        vsync: this, duration: Duration(milliseconds: duration));
  }

  @override
  void dispose() {
    timeline.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Motion gallery')),
      body: SafeArea(
          child: Column(children: [
        Wrap(spacing: 8, children: [
          for (final value in ['C', 'compact C', 'S', 'P', 'F', 'W', 'K', 'H'])
            ChoiceChip(
                label: Text(value),
                selected: value == scene,
                onSelected: (_) => setState(() {
                      scene = value;
                      timeline.stop();
                      timeline.value = 0;
                      timeline.duration = Duration(milliseconds: duration);
                    }))
        ]),
        SwitchListTile(
            title: const Text('Reduced motion'),
            value: reduced,
            onChanged: (value) => setState(() => reduced = value)),
        SwitchListTile(
            title: const Text('Blue auth background'),
            value: blue,
            onChanged: (value) => setState(() => blue = value)),
        Expanded(
            child: AnimatedBuilder(
                animation: timeline,
                builder: (context, child) => MotionReferenceScene(
                    scene: scene,
                    progress: reduced ? 1 : timeline.value,
                    blue: blue,
                    reduced: reduced))),
        AnimatedBuilder(
            animation: timeline,
            builder: (context, child) => Slider(
                value: timeline.value,
                onChanged: (value) {
                  timeline.stop();
                  timeline.value = value;
                })),
        TextButton(
            onPressed: () => timeline.forward(from: 0),
            child: const Text('Play once')),
      ])));
}

class MotionReferenceScene extends StatelessWidget {
  const MotionReferenceScene(
      {super.key,
      required this.scene,
      required this.progress,
      this.blue = false,
      this.reduced = false});
  final String scene;
  final double progress;
  final bool blue, reduced;
  @override
  Widget build(BuildContext context) {
    final auth = scene == 'P' || scene == 'F';
    final submitted = scene == 'S';
    final frame = DavoOutcomeFrame(
        submitted ? DavoOutcomeKind.submitted : DavoOutcomeKind.completed,
        progress);
    if (auth) {
      return DavoAuthScene(
          fingerprint: scene == 'F',
          progress: progress,
          onBlue: blue,
          reduced: reduced);
    }
    if (scene == 'W') {
      return Center(
          child: SizedBox.square(
              dimension: 150,
              child: DavoWorkingArtwork(
                  kind: DavoWorkingKind.operation, progress: progress)));
    }
    if (scene == 'K') {
      final ms = progress * 280;
      final leaving = ms < 100;
      final value = leaving
          ? 1 - DavoMotionSpec.phase(ms, 0, 100)
          : DavoMotionSpec.phase(ms, 100, 280, DavoMotionSpec.settle);
      return Center(
          child: Opacity(
              opacity: value,
              child: Transform.translate(
                  offset:
                      Offset(0, leaving ? -4 * (1 - value) : 8 * (1 - value)),
                  child: Text(leaving ? 'Step 1' : 'Step 2'))));
    }
    if (scene == 'H') {
      return Stack(children: [
        Positioned.fill(
            child: ColoredBox(
                color: Colors.black.withValues(
                    alpha:
                        .32 * DavoMotionSpec.phase(progress * 280, 0, 160)))),
        Align(
            alignment: Alignment.bottomCenter,
            child: FractionalTranslation(
                translation:
                    Offset(0, 1 - DavoMotionSpec.settle.transform(progress)),
                child: Container(
                    height: 220,
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(20))),
                    child: const Center(child: Text('Share')))))
      ]);
    }
    return ColoredBox(
        color: Colors.white,
        child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          DavoOutcomeArtwork(
              kind: submitted
                  ? DavoOutcomeKind.submitted
                  : DavoOutcomeKind.completed,
              progress: progress,
              size: 148),
          const SizedBox(height: 24),
          Opacity(
              opacity: frame.heading,
              child: Transform.translate(
                  offset: Offset(0, 8 * (1 - frame.heading)),
                  child: Text(submitted ? 'Submitted' : 'Completed',
                      style: const TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.none,
                          color: AppColors.ink)))),
        ])));
  }
}
