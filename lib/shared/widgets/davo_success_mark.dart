import 'package:flutter/material.dart';
import '../motion/davo_motion_spec.dart';
import '../motion/davo_outcome_sequence.dart';
import '../motion/davo_outcome_artwork.dart';
export '../motion/davo_motion_spec.dart' show DavoOutcomeKind, DavoOutcomeTempo;

/// Presents a caller-established outcome; never changes transaction status.
class DavoSuccessMark extends StatelessWidget {
  const DavoSuccessMark(
      {super.key,
      this.size = 148,
      this.semanticLabel = 'Success',
      this.kind = DavoOutcomeKind.completed,
      this.tempo = DavoOutcomeTempo.regular,
      this.eventKey,
      this.progress})
      : assert(size > 0);
  final double size;
  final String semanticLabel;
  final DavoOutcomeKind kind;
  final DavoOutcomeTempo tempo;
  final Object? eventKey;
  final double? progress;
  @override
  Widget build(BuildContext context) {
    Widget art(double value) =>
        DavoOutcomeArtwork(kind: kind, progress: value, size: size);
    return Semantics(
        label: semanticLabel,
        image: true,
        child: ExcludeSemantics(
            child: progress == null
                ? DavoOutcomeSequence(
                    kind: kind,
                    tempo: tempo,
                    eventKey: eventKey,
                    builder: (_, value) => art(value))
                : art(progress!)));
  }
}
