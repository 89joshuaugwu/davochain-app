import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

class QuestionAnswer {
  const QuestionAnswer(this.question, this.answer);

  final String question;
  final String answer;
}

class SecurityQuestionChallenge {
  const SecurityQuestionChallenge._(
      this.id, this.question, this._index, this._generation);
  final String id, question;
  final int _index, _generation;
}

class ResetChallenge {
  const ResetChallenge({
    required this.id,
    required this.previewCode,
    required this.expiresAt,
  });

  final String id;
  final String previewCode;
  final DateTime expiresAt;
}

/// Session-only preview. Production requires authenticated account-scoped server
/// checks, slow salted hashes, rate limits, and real email delivery.
class SecurityQuestionsService extends ChangeNotifier {
  SecurityQuestionsService({DateTime Function()? now, Random? random})
      : _now = now ?? DateTime.now,
        _random = random ?? Random.secure();

  static final instance = SecurityQuestionsService();
  static const defaultQuestions = [
    'Who was your favorite teacher?',
    'What was the first concert you attended?',
    'What was your childhood nickname?',
    'What place is especially memorable to you?',
    'What was the first book you loved?',
    'What did you want to be when you grew up?',
  ];

  final DateTime Function() _now;
  final Random _random;
  SecurityQuestionChallenge? _loginChallenge;
  List<_StoredAnswer> _answers = const [];
  int _generation = 0;
  int _failedAnswers = 0;
  DateTime? _answerLockUntil;
  DateTime? _resendUntil;
  _PendingReset? _reset;
  _ReplacementGrant? _grant;
  String? _error;

  bool get enabled => _answers.length == 3;
  List<String> get questions =>
      List<String>.unmodifiable(_answers.map((entry) => entry.question));
  String? get error => _error;
  DateTime? get cooldownUntil => _activeDeadline(_answerLockUntil);
  DateTime? get resetCooldownUntil => _activeDeadline(_resendUntil);

  Future<void> saveInitial(List<QuestionAnswer> entries) async {
    if (enabled) {
      _fail(
          'Security questions are already set. Verify a reset to change them.');
    }
    final validated = _validate(entries);
    _activate(validated);
  }

  Future<bool> verifyAnswers(List<String> answers) async {
    _checkAnswerAttempt();
    var matched = answers.length == 3;
    if (answers.length == 3) {
      // Check every answer so failures never disclose which answer differed.
      for (var index = 0; index < 3; index++) {
        final stored = _answers[index];
        final digest = _hash(stored.salt, _canonical(answers[index]));
        matched = _equalDigest(digest, stored.digest) && matched;
      }
    }
    return _finishAnswerAttempt(matched);
  }

  SecurityQuestionChallenge beginChallenge() {
    if (!enabled) _fail('Set your security questions before signing in.');
    final index = _random.nextInt(3);
    return _loginChallenge = SecurityQuestionChallenge._(
        _token(), _answers[index].question, index, _generation);
  }

  void cancelChallenge(String id) {
    if (_loginChallenge?.id == id) _loginChallenge = null;
  }

  Future<bool> verifyChallenge(String id, String answer) async {
    final challenge = _loginChallenge;
    if (challenge == null ||
        challenge.id != id ||
        challenge._generation != _generation ||
        !enabled) {
      _fail('This question has expired. Start signing in again.');
    }
    _checkAnswerAttempt();
    final stored = _answers[challenge._index];
    final matched =
        _equalDigest(_hash(stored.salt, _canonical(answer)), stored.digest);
    if (matched) _loginChallenge = null;
    return _finishAnswerAttempt(matched);
  }

  void _checkAnswerAttempt() {
    if (!enabled) {
      _fail('Set your security questions before verifying answers.');
    }
    if (cooldownUntil != null) {
      _fail('Too many attempts. Wait 30 seconds before trying again.');
    }
    if (_answerLockUntil != null) {
      _answerLockUntil = null;
      _failedAnswers = 0;
    }
  }

  bool _finishAnswerAttempt(bool matched) {
    if (matched) {
      _failedAnswers = 0;
      _error = null;
    } else {
      _failedAnswers++;
      _error = 'The answer did not match. Please try again.';
      if (_failedAnswers >= 5) {
        _answerLockUntil = _now().add(const Duration(seconds: 30));
        _error = 'Too many attempts. Wait 30 seconds before trying again.';
      }
    }
    notifyListeners();
    return matched;
  }

  Future<ResetChallenge> requestReset() async {
    if (!enabled) _fail('Set security questions before requesting a reset.');
    if (resetCooldownUntil != null) {
      _fail('Wait 30 seconds before requesting another preview code.');
    }
    final salt = _token();
    final code = _random.nextInt(1000000).toString().padLeft(6, '0');
    final challenge = ResetChallenge(
      id: _token(),
      previewCode: code,
      expiresAt: _now().add(const Duration(minutes: 5)),
    );
    _reset = _PendingReset(challenge.id, challenge.expiresAt, _generation, salt,
        _hash(salt, code));
    _grant = null;
    _resendUntil = _now().add(const Duration(seconds: 30));
    _error = null;
    notifyListeners();
    return challenge;
  }

  Future<String> confirmReset(String challengeId, String code) async {
    final reset = _reset;
    if (reset == null ||
        reset.id != challengeId ||
        reset.generation != _generation ||
        !_now().isBefore(reset.expiresAt)) {
      _fail(
          'This preview code has expired or is no longer valid. Request a new code.');
    }
    if (!_equalDigest(_hash(reset.salt, code.trim()), reset.digest)) {
      reset.failedAttempts++;
      if (reset.failedAttempts >= 5) _reset = null;
      _fail(reset.failedAttempts >= 5
          ? 'Too many code attempts. Request a new preview code.'
          : 'The preview code did not match. Try again.');
    }
    final token = _token();
    _grant = _ReplacementGrant(
        token, _now().add(const Duration(minutes: 5)), _generation);
    _reset = null;
    _error = null;
    notifyListeners();
    return token;
  }

  Future<void> replaceQuestions(
      String grant, List<QuestionAnswer> entries) async {
    final authorized = _grant;
    if (!enabled ||
        authorized == null ||
        authorized.token != grant ||
        authorized.generation != _generation ||
        !_now().isBefore(authorized.expiresAt)) {
      _fail('Verify a new preview code before changing security questions.');
    }
    // Validation and hashing finish before the one-use grant or old set changes.
    final validated = _validate(entries);
    _activate(validated);
  }

  void invalidateReset() {
    _reset = null;
    _grant = null;
    _error = null;
    // Private code/grant cancellation changes no visible enrollment.
    // Avoid notifying widgets during route disposal.
  }

  void clear() {
    _answers = const [];
    _generation++;
    _loginChallenge = null;
    _reset = null;
    _grant = null;
    _failedAnswers = 0;
    _answerLockUntil = null;
    _resendUntil = null;
    _error = null;
    notifyListeners();
  }

  List<_StoredAnswer> _validate(List<QuestionAnswer> entries) {
    if (entries.length != 3) _fail('Choose exactly three security questions.');
    final seen = <String>{};
    final validated = <_StoredAnswer>[];
    for (final entry in entries) {
      final question = _cleanSpaces(entry.question);
      if (question.isEmpty) _fail('Enter a meaningful security question.');
      if (!seen.add(_canonical(question))) {
        _fail('Choose three different security questions.');
      }
      final answer = _canonical(entry.answer);
      if (answer.runes.length < 3 || answer.runes.length > 120) {
        _fail('Use an answer between 3 and 120 characters.');
      }
      final salt = _token();
      validated.add(_StoredAnswer(question, salt, _hash(salt, answer)));
    }
    return List<_StoredAnswer>.unmodifiable(validated);
  }

  void _activate(List<_StoredAnswer> answers) {
    _answers = answers;
    _generation++;
    _loginChallenge = null;
    _reset = null;
    _grant = null;
    _failedAnswers = 0;
    _answerLockUntil = null;
    _resendUntil = null;
    _error = null;
    notifyListeners();
  }

  DateTime? _activeDeadline(DateTime? deadline) =>
      deadline != null && _now().isBefore(deadline) ? deadline : null;

  Never _fail(String message) {
    _error = message;
    notifyListeners();
    throw FormatException(message);
  }

  String _token() =>
      base64UrlEncode(List<int>.generate(32, (_) => _random.nextInt(256)));
  static String _cleanSpaces(String value) =>
      value.trim().replaceAll(RegExp(r'\s+'), ' ');
  static String _canonical(String value) => _cleanSpaces(value).toLowerCase();
  static List<int> _hash(String salt, String value) =>
      sha256.convert(utf8.encode('$salt:$value')).bytes;
  static bool _equalDigest(List<int> left, List<int> right) {
    var difference = left.length ^ right.length;
    for (var index = 0; index < left.length && index < right.length; index++) {
      difference |= left[index] ^ right[index];
    }
    return difference == 0;
  }
}

class _StoredAnswer {
  const _StoredAnswer(this.question, this.salt, this.digest);
  final String question;
  final String salt;
  final List<int> digest;
}

class _PendingReset {
  _PendingReset(
      this.id, this.expiresAt, this.generation, this.salt, this.digest);
  final String id;
  final DateTime expiresAt;
  final int generation;
  final String salt;
  final List<int> digest;
  int failedAttempts = 0;
}

class _ReplacementGrant {
  const _ReplacementGrant(this.token, this.expiresAt, this.generation);
  final String token;
  final DateTime expiresAt;
  final int generation;
}
