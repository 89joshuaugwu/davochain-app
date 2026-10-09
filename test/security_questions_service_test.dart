import 'package:davochain/features/security_questions/security_questions_service.dart';
import 'package:flutter_test/flutter_test.dart';

const original = [
  QuestionAnswer('Favorite teacher?', 'Mrs. Ada'),
  QuestionAnswer('First concert?', 'Blue Notes'),
  QuestionAnswer('Childhood nickname?', 'Little Fox'),
];
const replacement = [
  QuestionAnswer('First book?', 'Purple pages'),
  QuestionAnswer('Memorable place?', 'Old library'),
  QuestionAnswer('Childhood ambition?', 'Space pilot'),
];

void main() {
  late DateTime clock;
  late SecurityQuestionsService service;
  setUp(() {
    clock = DateTime.utc(2026, 10, 9);
    service = SecurityQuestionsService(now: () => clock);
  });
  tearDown(() => service.dispose());

  test('enrollment activates only a complete distinct validated set', () async {
    await expectLater(
        service.saveInitial(original.take(2).toList()), throwsFormatException);
    await expectLater(
        service.saveInitial([
          original[0],
          const QuestionAnswer(' favorite   TEACHER? ', 'valid'),
          original[2],
        ]),
        throwsFormatException);
    await expectLater(
        service.saveInitial([
          original[0],
          original[1],
          const QuestionAnswer('Third?', '  '),
        ]),
        throwsFormatException);
    expect(service.enabled, isFalse);
    expect(service.questions, isEmpty);
    await service.saveInitial(original);
    expect(service.enabled, isTrue);
    expect(service.questions,
        ['Favorite teacher?', 'First concert?', 'Childhood nickname?']);
    expect(() => service.questions.add('Tamper'), throwsUnsupportedError);
    await expectLater(service.saveInitial(replacement), throwsFormatException);
    expect(
        await service.verifyAnswers(['Mrs. Ada', 'Blue Notes', 'Little Fox']),
        isTrue);
  });

  test('answers match normalized spacing and case but retain punctuation',
      () async {
    await service.saveInitial(original);
    expect(
        await service
            .verifyAnswers([' MRS.   ada ', 'blue notes', 'little FOX']),
        isTrue);
    expect(await service.verifyAnswers(['Mrs Ada', 'Blue Notes', 'Little Fox']),
        isFalse);
    expect(await service.verifyAnswers(['Mrs. Ada', 'Blue Notes']), isFalse);
  });

  test('five failed checks lock even correct answers until cooldown ends',
      () async {
    await service.saveInitial(original);
    for (var i = 0; i < 5; i++) {
      expect(await service.verifyAnswers(['wrong', 'wrong', 'wrong']), isFalse);
    }
    expect(service.cooldownUntil, clock.add(const Duration(seconds: 30)));
    await expectLater(
        service.verifyAnswers(['Mrs. Ada', 'Blue Notes', 'Little Fox']),
        throwsFormatException);
    clock = clock.add(const Duration(seconds: 30));
    expect(
        await service.verifyAnswers(['Mrs. Ada', 'Blue Notes', 'Little Fox']),
        isTrue);
    expect(service.cooldownUntil, isNull);
  });

  test('reset cooldown blocks resends and a new request invalidates old code',
      () async {
    await service.saveInitial(original);
    final first = await service.requestReset();
    await expectLater(service.requestReset(), throwsFormatException);
    clock = clock.add(const Duration(seconds: 30));
    final second = await service.requestReset();
    await expectLater(service.confirmReset(first.id, first.previewCode),
        throwsFormatException);
    final grant = await service.confirmReset(second.id, second.previewCode);
    await service.replaceQuestions(grant, replacement);
    expect(
        await service
            .verifyAnswers(['Purple pages', 'Old library', 'Space pilot']),
        isTrue);
  });

  test('reset codes expire and are exhausted after five failed attempts',
      () async {
    await service.saveInitial(original);
    final challenge = await service.requestReset();
    for (var i = 0; i < 5; i++) {
      await expectLater(
          service.confirmReset(challenge.id, 'wrong'), throwsFormatException);
    }
    await expectLater(service.confirmReset(challenge.id, challenge.previewCode),
        throwsFormatException);
    clock = clock.add(const Duration(seconds: 30));
    final next = await service.requestReset();
    clock = next.expiresAt;
    await expectLater(
        service.confirmReset(next.id, next.previewCode), throwsFormatException);
    expect(
        await service.verifyAnswers(['Mrs. Ada', 'Blue Notes', 'Little Fox']),
        isTrue);
  });

  test('replacement validates before consuming a single-use grant', () async {
    await service.saveInitial(original);
    final challenge = await service.requestReset();
    final grant =
        await service.confirmReset(challenge.id, challenge.previewCode);
    await expectLater(service.confirmReset(challenge.id, challenge.previewCode),
        throwsFormatException);
    await expectLater(
        service.replaceQuestions(grant, replacement.take(2).toList()),
        throwsFormatException);
    expect(
        await service.verifyAnswers(['Mrs. Ada', 'Blue Notes', 'Little Fox']),
        isTrue);
    await service.replaceQuestions(grant, replacement);
    await expectLater(
        service.replaceQuestions(grant, original), throwsFormatException);
    expect(
        await service
            .verifyAnswers(['Purple pages', 'Old library', 'Space pilot']),
        isTrue);
  });

  test(
      'grant expiration, cancellation, and account clearing preserve boundaries',
      () async {
    await service.saveInitial(original);
    var challenge = await service.requestReset();
    var grant = await service.confirmReset(challenge.id, challenge.previewCode);
    clock = clock.add(const Duration(minutes: 5));
    await expectLater(
        service.replaceQuestions(grant, replacement), throwsFormatException);
    challenge = await service.requestReset();
    grant = await service.confirmReset(challenge.id, challenge.previewCode);
    service.invalidateReset();
    await expectLater(
        service.replaceQuestions(grant, replacement), throwsFormatException);
    expect(
        await service.verifyAnswers(['Mrs. Ada', 'Blue Notes', 'Little Fox']),
        isTrue);
    clock = clock.add(const Duration(seconds: 30));
    challenge = await service.requestReset();
    grant = await service.confirmReset(challenge.id, challenge.previewCode);
    service.clear();
    await service.saveInitial(original);
    await expectLater(
        service.replaceQuestions(grant, replacement), throwsFormatException);
  });

  test('answers outside meaningful length bounds cannot enroll', () async {
    for (final answer in ['ab', List.filled(121, 'x').join()]) {
      await expectLater(
          service.saveInitial([
            original[0],
            original[1],
            QuestionAnswer('Third?', answer),
          ]),
          throwsFormatException);
      expect(service.enabled, isFalse);
    }
  });
}
