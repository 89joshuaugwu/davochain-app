import 'package:davochain/shared/motion/davo_motion_spec.dart';
import 'package:davochain/shared/motion/davo_outcome_sequence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('outcome timing and distinct final symbols match the contract', () {
    expect(
        DavoMotionSpec.outcomeDuration(
                DavoOutcomeKind.completed, DavoOutcomeTempo.regular)
            .inMilliseconds,
        1120);
    expect(
        DavoMotionSpec.outcomeDuration(
                DavoOutcomeKind.completed, DavoOutcomeTempo.compact)
            .inMilliseconds,
        680);
    expect(
        DavoMotionSpec.outcomeDuration(
                DavoOutcomeKind.submitted, DavoOutcomeTempo.regular)
            .inMilliseconds,
        900);
    final done = DavoOutcomeFrame(DavoOutcomeKind.completed, 1);
    final pending = DavoOutcomeFrame(DavoOutcomeKind.submitted, 1);
    expect(done.discRadius, 57);
    expect(done.insetRadius, 24);
    expect(done.check, 1);
    expect(done.clock, 0);
    expect(pending.check, 0);
    expect(pending.clock, 1);
  });
  testWidgets('finite sequence settles, does not replay and accepts new event',
      (tester) async {
    double progress = -1;
    Widget host(Object event, {bool reduced = false}) => MaterialApp(
        home: MediaQuery(
            data: MediaQueryData(disableAnimations: reduced),
            child: DavoOutcomeSequence(
                eventKey: event,
                kind: DavoOutcomeKind.completed,
                builder: (_, value) {
                  progress = value;
                  return const SizedBox();
                })));
    await tester.pumpWidget(host('a'));
    await tester.pumpAndSettle();
    expect(progress, 1);
    expect(tester.binding.transientCallbackCount, 0);
    await tester.pumpWidget(host('a'));
    expect(progress, 1);
    await tester.pumpWidget(host('b'));
    expect(progress, 0);
    await tester.pumpWidget(host('b', reduced: true));
    expect(progress, 1);
    expect(tester.binding.transientCallbackCount, 0);
  });
}
