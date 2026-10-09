import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/features/security_questions/security_questions_service.dart';

const entries = [
  QuestionAnswer('First?', 'first answer'),
  QuestionAnswer('Second?', 'second answer'),
  QuestionAnswer('Third?', 'third answer')
];
void main() {
  test(
      'all three questions can be selected and only the selected answer matches',
      () async {
    final service = SecurityQuestionsService(random: Random(7));
    await service.saveInitial(entries);
    final selected = <String>{};
    for (var i = 0; i < 30; i++) {
      final challenge = service.beginChallenge();
      selected.add(challenge.question);
      final index =
          entries.indexWhere((entry) => entry.question == challenge.question);
      expect(
          await service.verifyChallenge(
              challenge.id, entries[(index + 1) % 3].answer),
          isFalse);
      expect(await service.verifyChallenge(challenge.id, entries[index].answer),
          isTrue);
      await expectLater(
          service.verifyChallenge(challenge.id, entries[index].answer),
          throwsFormatException);
    }
    expect(selected, entries.map((entry) => entry.question).toSet());
  });
  test(
      'new challenges cannot reset the shared cooldown and old challenges expire',
      () async {
    var now = DateTime(2026, 10, 9);
    final service = SecurityQuestionsService(now: () => now);
    await service.saveInitial(entries);
    final old = service.beginChallenge();
    for (var i = 0; i < 5; i++) {
      final challenge = service.beginChallenge();
      expect(await service.verifyChallenge(challenge.id, 'wrong'), isFalse);
    }
    final current = service.beginChallenge();
    await expectLater(
        service.verifyChallenge(
            current.id,
            entries
                .firstWhere((entry) => entry.question == current.question)
                .answer),
        throwsFormatException);
    now = now.add(const Duration(seconds: 30));
    expect(
        await service.verifyChallenge(
            current.id,
            entries
                .firstWhere((entry) => entry.question == current.question)
                .answer),
        isTrue);
    await expectLater(
        service.verifyChallenge(old.id, 'first answer'), throwsFormatException);
  });
}
