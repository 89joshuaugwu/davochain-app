import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/motion/davo_motion_policy.dart';
import '../../../shared/widgets/davo_result_screen.dart';
import '../security_questions_service.dart';

const securityQuestionPresets = <String>[
  'Who was your favorite teacher?',
  'What was the first concert you attended?',
  'What was your childhood nickname?',
  'Which place is especially memorable to you?',
  'What was the first book you loved?',
  'What did you want to become as a child?',
];
String _normalized(String value) =>
    value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
String _error(Object error) => error is FormatException
    ? error.message
    : 'Something went wrong. Please try again.';

class SecurityQuestionsSettingsScreen extends StatelessWidget {
  const SecurityQuestionsSettingsScreen({super.key, this.service});
  final SecurityQuestionsService? service;
  @override
  Widget build(BuildContext context) =>
      _QuestionsFlow(service: service ?? SecurityQuestionsService.instance);
}

enum _Page { manage, question, review, code, result }

class _QuestionsFlow extends StatefulWidget {
  const _QuestionsFlow({required this.service, this.recovery = false});
  final SecurityQuestionsService service;
  final bool recovery;
  @override
  State<_QuestionsFlow> createState() => _QuestionsFlowState();
}

class _QuestionsFlowState extends State<_QuestionsFlow> {
  late _Page _page = widget.recovery ? _Page.code : _Page.manage;
  final _questions = List<String>.filled(3, '');
  final _answers = List.generate(3, (_) => TextEditingController());
  final _custom = TextEditingController();
  final _code = TextEditingController();
  int _step = 0;
  bool _customSelected = false, _visible = false, _busy = false;
  String? _problem, _grant;
  ResetChallenge? _reset;
  SecurityQuestionsService get service => widget.service;

  @override
  void dispose() {
    if (_grant != null || _reset != null) service.invalidateReset();
    for (final answer in _answers) {
      answer.dispose();
    }
    _custom.dispose();
    _code.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _problem = null;
    });
    try {
      await action();
    } catch (error) {
      if (mounted) setState(() => _problem = _error(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _setup() {
    setState(() {
      _page = _Page.question;
      _step = 0;
      _problem = null;
    });
    _loadQuestion();
  }

  void _loadQuestion() {
    _customSelected = _questions[_step].isNotEmpty &&
        !securityQuestionPresets.contains(_questions[_step]);
    _custom.text = _customSelected ? _questions[_step] : '';
    _visible = false;
  }

  bool get _complete {
    final question = _questions[_step];
    final answerLength = _normalized(_answers[_step].text).runes.length;
    return question.trim().isNotEmpty &&
        answerLength >= 3 &&
        answerLength <= 120 &&
        ![
          for (var i = 0; i < 3; i++)
            if (i != _step) _normalized(_questions[i])
        ].contains(_normalized(question));
  }

  Future<void> _choose() async {
    final chosen = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) => FractionallySizedBox(
            heightFactor: .85,
            child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Choose a question',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600))),
                  for (final question in securityQuestionPresets)
                    Builder(builder: (context) {
                      final taken = [
                        for (var i = 0; i < 3; i++)
                          if (i != _step) _normalized(_questions[i])
                      ].contains(_normalized(question));
                      return ListTile(
                          title: Text(question,
                              style: const TextStyle(fontSize: 14)),
                          subtitle: taken
                              ? const Text('Already selected',
                                  style: TextStyle(fontSize: 12))
                              : null,
                          enabled: !taken,
                          trailing:
                              taken ? const Icon(Icons.check, size: 20) : null,
                          onTap: taken
                              ? null
                              : () => Navigator.pop(context, question));
                    }),
                  ListTile(
                      title: const Text('Write my own question'),
                      leading: const Icon(Icons.edit_outlined),
                      onTap: () => Navigator.pop(context, 'custom')),
                ])));
    if (!mounted || chosen == null) return;
    setState(() {
      _customSelected = chosen == 'custom';
      _questions[_step] = _customSelected ? _custom.text : chosen;
      _problem = null;
    });
  }

  void _next() {
    if (!_complete || _busy) return;
    FocusScope.of(context).unfocus();
    setState(() {
      if (_step == 2) {
        _page = _Page.review;
      } else {
        _step++;
        _loadQuestion();
      }
      _problem = null;
    });
  }

  Future<void> _request() => _run(() async {
        FocusScope.of(context).unfocus();
        final challenge = await service.requestReset();
        if (!mounted) {
          service.invalidateReset();
          return;
        }
        setState(() {
          _reset = challenge;
          _page = _Page.code;
          _code.clear();
        });
      });

  Future<void> _confirm() => _run(() async {
        FocusScope.of(context).unfocus();
        final grant = await service.confirmReset(_reset!.id, _code.text);
        if (!mounted) {
          service.invalidateReset();
          return;
        }
        _grant = grant;
        _setup();
      });

  Future<void> _save() => _run(() async {
        FocusScope.of(context).unfocus();
        final values = [
          for (var i = 0; i < 3; i++)
            QuestionAnswer(_questions[i], _answers[i].text)
        ];
        if (_grant == null) {
          await service.saveInitial(values);
        } else {
          await service.replaceQuestions(_grant!, values);
        }
        if (!mounted) return;
        setState(() {
          _grant = null;
          _reset = null;
          _page = _Page.result;
        });
        for (final answer in _answers) {
          answer.clear();
        }
      });

  void _back() {
    if (_busy) return;
    FocusScope.of(context).unfocus();
    if (_page == _Page.question && _step > 0) {
      setState(() {
        _step--;
        _loadQuestion();
        _problem = null;
      });
    } else if (_page == _Page.review) {
      setState(() {
        _page = _Page.question;
        _step = 2;
        _loadQuestion();
      });
    } else if (_page != _Page.manage && !widget.recovery) {
      service.invalidateReset();
      setState(() {
        _grant = null;
        _reset = null;
        _page = _Page.manage;
        _problem = null;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_page == _Page.result) {
      return DavoResultScreen(
          title: 'Security questions saved',
          message: widget.recovery
              ? 'Your questions have been replaced. Answer one selected question to finish signing in.'
              : 'Your three questions are ready for your next sign-in in this session preview.',
          actions: _action(widget.recovery ? 'Return to verification' : 'Done',
              () => Navigator.pop(context, true)));
    }
    return PopScope(
        canPop: !_busy &&
            (_page == _Page.manage || widget.recovery && _page == _Page.code),
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop && !_busy) _back();
        },
        child: _Frame(
            title: 'Security questions',
            onBack: _busy ? null : _back,
            child: AnimatedSwitcher(
                duration: DavoMotionPolicy.reduce(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 180),
                child: Column(
                    key: ValueKey('${_page.name}-$_step'),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ..._content(context),
                      if (_problem != null) _Problem(_problem!),
                      if (_busy)
                        const Padding(
                            padding: EdgeInsets.only(top: 16),
                            child: Text('Please wait…',
                                textAlign: TextAlign.center))
                    ]))));
  }

  List<Widget> _content(BuildContext context) {
    switch (_page) {
      case _Page.manage:
        return [
          _heading(service.enabled
              ? 'Your extra sign-in check'
              : 'A few answers only you know'),
          _body(
              'Choose three different questions and memorable, private answers. Avoid passwords and PINs.'),
          _notice(context),
          const SizedBox(height: 28),
          if (service.enabled) ...[
            for (var i = 0; i < service.questions.length; i++)
              _questionRow(context, i, service.questions[i]),
            const SizedBox(height: 24),
            _body(
                'To replace all three questions, first verify an email code in the session preview.'),
          ],
          _action(service.enabled ? 'Change questions' : 'Set up questions',
              service.enabled ? _request : _setup,
              enabled: !_busy),
        ];
      case _Page.question:
        return [
          Text('Question ${_step + 1} of 3',
              style: TextStyle(
                  fontSize: 12, color: DavoColors.of(context).bodyMuted)),
          const SizedBox(height: 12),
          LinearProgressIndicator(
              value: (_step + 1) / 3,
              minHeight: 4,
              borderRadius: BorderRadius.circular(2)),
          const SizedBox(height: 28),
          _heading('Choose a question you will remember'),
          _body(
              'Your answer stays hidden. Use something private that you can recall later.'),
          const SizedBox(height: 12),
          OutlinedButton(
              onPressed: _busy ? null : _choose,
              style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.all(16),
                  alignment: Alignment.centerLeft),
              child: Row(children: [
                Expanded(
                    child: Text(
                        _questions[_step].isEmpty || _customSelected
                            ? 'Choose a question'
                            : _questions[_step],
                        style: const TextStyle(fontSize: 14))),
                const Icon(Icons.expand_more)
              ])),
          if (_customSelected) ...[
            const SizedBox(height: 16),
            TextField(
                controller: _custom,
                enabled: !_busy,
                maxLines: 2,
                maxLength: 160,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                    labelText: 'Your own question',
                    hintText: 'Write a memorable, private question'),
                onChanged: (value) =>
                    setState(() => _questions[_step] = value)),
            if (_questions[_step].trim().isNotEmpty &&
                [
                  for (var i = 0; i < 3; i++)
                    if (i != _step) _normalized(_questions[i])
                ].contains(_normalized(_questions[_step])))
              const _Problem(
                  'This question is already selected. Choose a different question.'),
          ],
          const SizedBox(height: 24),
          TextField(
              key: const Key('security-answer'),
              controller: _answers[_step],
              enabled: !_busy,
              obscureText: !_visible,
              maxLength: 120,
              autocorrect: false,
              enableSuggestions: false,
              style: const TextStyle(fontSize: 14),
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                  labelText: 'Your answer',
                  helperText: '3–120 characters',
                  helperMaxLines: 4,
                  suffixIcon: IconButton(
                      tooltip: _visible ? 'Hide answer' : 'Show answer',
                      onPressed: _busy
                          ? null
                          : () => setState(() => _visible = !_visible),
                      icon: Icon(_visible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined))),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _next()),
          const SizedBox(height: 28),
          _action(_step == 2 ? 'Review questions' : 'Next question', _next,
              enabled: _complete && !_busy),
        ];
      case _Page.review:
        return [
          _heading('Review your three questions'),
          _body(
              'Check that each question is different and easy for you to remember. Your answers are hidden.'),
          for (var i = 0; i < 3; i++) _questionRow(context, i, _questions[i]),
          const SizedBox(height: 28),
          _action('Save questions', _save, enabled: !_busy),
          TextButton(
              onPressed: _busy ? null : _back,
              child: const Text('Edit questions'))
        ];
      case _Page.code:
        return [
          _heading('Verify before replacing questions'),
          _body(
              'Email verification is a session preview. No email is sent. Request a preview code and enter it below.'),
          if (_reset == null)
            _action('Request preview code', _request, enabled: !_busy)
          else ...[
            Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: DavoColors.of(context).primarySoft,
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Preview code · no email sent',
                          style: TextStyle(
                              fontSize: 12,
                              color: DavoColors.of(context).link)),
                      const SizedBox(height: 8),
                      SelectableText(_reset!.previewCode,
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: DavoColors.of(context).link)),
                      const SizedBox(height: 8),
                      _body(
                          'Valid for 5 minutes after requesting. Your current questions remain active until replacements are saved.'),
                    ])),
            const SizedBox(height: 24),
            TextField(
                key: const Key('security-reset-code'),
                controller: _code,
                enabled: !_busy,
                keyboardType: TextInputType.number,
                autocorrect: false,
                enableSuggestions: false,
                decoration:
                    const InputDecoration(labelText: 'Email preview code'),
                onChanged: (_) => setState(() {})),
            const SizedBox(height: 24),
            _action('Verify code', _confirm,
                enabled: !_busy && _code.text.trim().isNotEmpty),
            TextButton(
                onPressed: _busy ? null : _request,
                child: const Text('Request a new preview code')),
          ]
        ];
      case _Page.result:
        return [];
    }
  }
}

class SecurityQuestionsChallengeScreen extends StatefulWidget {
  const SecurityQuestionsChallengeScreen(
      {super.key, this.service, required this.onVerified, this.onCancel});
  final SecurityQuestionsService? service;
  final VoidCallback onVerified;
  final VoidCallback? onCancel;
  @override
  State<SecurityQuestionsChallengeScreen> createState() => _ChallengeState();
}

class _ChallengeState extends State<SecurityQuestionsChallengeScreen> {
  final _answer = TextEditingController();
  SecurityQuestionsService get service =>
      widget.service ?? SecurityQuestionsService.instance;
  late SecurityQuestionChallenge _challenge = service.beginChallenge();
  bool _busy = false, _verified = false, _canceled = false;
  String? _problem;
  @override
  void dispose() {
    service.cancelChallenge(_challenge.id);
    _answer.dispose();
    super.dispose();
  }

  void _cancel() {
    if (_busy || _verified || _canceled) return;
    FocusScope.of(context).unfocus();
    _canceled = true;
    if (widget.onCancel != null) {
      widget.onCancel!();
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _verify() async {
    if (_busy || _verified || _canceled || _answer.text.trim().isEmpty) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _problem = null;
    });
    try {
      final correct =
          await service.verifyChallenge(_challenge.id, _answer.text);
      if (!mounted || _canceled) return;
      if (correct) {
        _verified = true;
        widget.onVerified();
      } else {
        setState(() => _problem = service.cooldownUntil != null
            ? 'Too many attempts. Wait 30 seconds before trying again.'
            : 'Answer did not match. Please try again.');
      }
    } catch (error) {
      if (mounted && !_canceled) setState(() => _problem = _error(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _recover() async {
    if (_busy || _verified || _canceled) return;
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    final changed = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
            builder: (_) => _QuestionsFlow(service: service, recovery: true)));
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = false;
      _problem = changed == true
          ? 'Questions replaced. Answer the selected question to continue.'
          : null;
    });
    if (changed == true) {
      _challenge = service.beginChallenge();
      _answer.clear();
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _cancel();
      },
      child: _Frame(
          title: 'Verify your identity',
          onBack: _busy ? null : _cancel,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _heading('Answer your security question'),
            _body(
                'Answer one randomly selected question to finish signing in. Answers ignore capitalization and extra spaces.'),
            _notice(context),
            const SizedBox(height: 24),
            Text(_challenge.question,
                style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                    color: DavoColors.of(context).ink)),
            const SizedBox(height: 12),
            TextField(
                key: const Key('challenge-answer-0'),
                controller: _answer,
                enabled: !_busy && !_verified,
                obscureText: true,
                autocorrect: false,
                enableSuggestions: false,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(labelText: 'Your answer'),
                onChanged: (_) => setState(() {})),
            const SizedBox(height: 24),
            if (_problem != null) _Problem(_problem!),
            _action(_busy ? 'Verifying…' : 'Verify answer', _verify,
                enabled: !_busy &&
                    !_verified &&
                    service.enabled &&
                    _answer.text.trim().isNotEmpty),
            TextButton(
                onPressed: _busy || _verified ? null : _recover,
                child: const Text('Forgot your answer?')),
          ])));
}

class _Frame extends StatelessWidget {
  const _Frame(
      {required this.title, required this.onBack, required this.child});
  final String title;
  final VoidCallback? onBack;
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: DavoColors.of(context).surface,
      appBar: AppBar(
          title: Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          leading: IconButton(
              tooltip: 'Back',
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back)),
          centerTitle: true),
      body: SafeArea(
          child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Center(
                  child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: child)))));
}

Widget _heading(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(text,
        style: const TextStyle(
            fontSize: 24, height: 1.3, fontWeight: FontWeight.w600)));
Widget _body(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Text(text, style: const TextStyle(fontSize: 14, height: 1.6)));
Widget _notice(BuildContext context) => Text(
    'Session preview · an additional knowledge check, not two-factor authentication. Questions and answers are cleared when this app session ends.',
    style: TextStyle(
        fontSize: 12, height: 1.6, color: DavoColors.of(context).bodyMuted));
Widget _action(String label, VoidCallback callback, {bool enabled = true}) =>
    FilledButton(
        onPressed: enabled ? callback : null,
        style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
        child: Text(label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)));
Widget _questionRow(BuildContext context, int index, String question) =>
    Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${index + 1}.',
              style: TextStyle(
                  color: DavoColors.of(context).bodyMuted, fontSize: 14)),
          const SizedBox(width: 12),
          Expanded(
              child: Text(question,
                  style: const TextStyle(
                      fontSize: 14, height: 1.5, fontWeight: FontWeight.w500)))
        ]));

class _Problem extends StatelessWidget {
  const _Problem(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Semantics(
      liveRegion: true,
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(text,
              style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: DavoColors.of(context).danger))));
}
