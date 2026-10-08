import '../../core/theme/app_theme.dart';
import 'package:flutter/material.dart';

import 'davo_success_mark.dart';
import '../motion/davo_outcome_sequence.dart';
import '../motion/davo_motion_spec.dart';

/// Result presentation with immediately available actions and scrollable copy.
/// Callers own outcome wording, navigation and action behavior.
class DavoResultScreen extends StatelessWidget {
  const DavoResultScreen({
    super.key,
    required this.title,
    required this.message,
    required this.actions,
    this.details,
    this.mark,
    this.kind = DavoOutcomeKind.completed,
    this.tempo = DavoOutcomeTempo.regular,
    this.eventKey,
    this.appBar,
  });

  final String title;
  final String message;
  final Widget actions;
  final Widget? details;
  final Widget? mark;
  final DavoOutcomeKind kind;
  final DavoOutcomeTempo tempo;
  final Object? eventKey;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) => DavoOutcomeSequence(
      kind: kind,
      tempo: tempo,
      eventKey: eventKey,
      sceneBuilder: (context, timeline) {
        Widget reveal(Widget child, bool details, double travel) =>
            AnimatedBuilder(
                animation: timeline,
                child: child,
                builder: (context, child) {
                  final frame = DavoOutcomeFrame(kind, timeline.value);
                  final value = details ? frame.details : frame.heading;
                  return Opacity(
                      opacity: value,
                      child: Transform.translate(
                          offset: Offset(0, travel * (1 - value)),
                          child: child));
                });
        return Scaffold(
          backgroundColor: DavoColors.of(context).surface,
          appBar: appBar,
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: (constraints.maxHeight - 60)
                              .clamp(0, double.infinity),
                        ),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 440),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                mark ??
                                    AnimatedBuilder(
                                        animation: timeline,
                                        builder: (context, child) =>
                                            DavoSuccessMark(
                                                kind: kind,
                                                progress: timeline.value)),
                                const SizedBox(height: 24),
                                reveal(
                                    Text(
                                      title,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'Sora',
                                        fontSize: 24,
                                        height: 1.3,
                                        fontWeight: FontWeight.w600,
                                        color: DavoColors.of(context).ink,
                                      ),
                                    ),
                                    false,
                                    8),
                                if (message.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  reveal(
                                      Text(
                                        message,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Sora',
                                          fontSize: 14,
                                          height: 1.6,
                                          color: DavoColors.of(context).bodyMuted,
                                        ),
                                      ),
                                      false,
                                      8),
                                ],
                                if (details != null) ...[
                                  const SizedBox(height: 24),
                                  reveal(details!, true, 6),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: SizedBox(width: double.infinity, child: actions),
                  ),
                ),
              ],
            ),
          ),
        );
      });
}
