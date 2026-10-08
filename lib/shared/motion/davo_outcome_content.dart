import 'package:flutter/material.dart';
import '../widgets/davo_success_mark.dart';
import 'davo_outcome_sequence.dart';
import 'davo_motion_spec.dart';

/// Coordinated art and copy for result bodies inside existing feature shells.
class DavoOutcomeContent extends StatelessWidget {
  const DavoOutcomeContent(
      {super.key,
      required this.heading,
      this.details,
      this.kind = DavoOutcomeKind.completed,
      this.tempo = DavoOutcomeTempo.regular,
      this.semanticLabel = 'Success',
      this.size = 148,
      this.play = true});
  final Widget heading;
  final Widget? details;
  final DavoOutcomeKind kind;
  final DavoOutcomeTempo tempo;
  final String semanticLabel;
  final double size;
  final bool play;
  @override
  Widget build(BuildContext context) => DavoOutcomeSequence(
      kind: kind,
      tempo: tempo,
      play: play,
      sceneBuilder: (context, timeline) {
        Widget reveal(Widget child, bool detail) => AnimatedBuilder(
            animation: timeline,
            child: child,
            builder: (context, child) {
              final frame = DavoOutcomeFrame(kind, play ? timeline.value : 1);
              final value = detail ? frame.details : frame.heading;
              return Opacity(
                  opacity: value,
                  child: Transform.translate(
                      offset: Offset(0, (detail ? 6 : 8) * (1 - value)),
                      child: child));
            });
        return Column(children: [
          AnimatedBuilder(
              animation: timeline,
              builder: (context, child) => DavoSuccessMark(
                  kind: kind,
                  size: size,
                  progress: play ? timeline.value : 1,
                  semanticLabel: semanticLabel)),
          const SizedBox(height: 24),
          reveal(heading, false),
          if (details != null) ...[
            const SizedBox(height: 24),
            reveal(details!, true)
          ],
        ]);
      });
}
