import 'account_welcome_screen.dart';
import '../../../core/navigation/app_page_route.dart';
import '../../../shared/widgets/davo_result_screen.dart';
import 'dart:async';
import '../../../shared/motion/davo_motion_spec.dart';
import '../../../shared/motion/davo_motion_policy.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/auth_widgets.dart';

enum VerificationKind { email, sms }

class VerificationScreen extends StatefulWidget {
  const VerificationScreen(
      {super.key, required this.kind, this.now = DateTime.now});

  final VerificationKind kind;
  final DateTime Function() now;

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  final _controllers = List.generate(4, (_) => TextEditingController());
  final _focusNodes = List.generate(4, (_) => FocusNode());
  Timer? _timer;
  int _seconds = 30;
  DateTime? _resendAt;
  bool _error = false;
  bool _verified = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _shakeController.dispose();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _resendAt = widget.now().add(const Duration(seconds: 30));
    setState(() => _seconds = 30);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final remaining = _resendAt!.difference(widget.now()).inMilliseconds;
      final seconds = (remaining / 1000).ceil().clamp(0, 30);
      if (seconds == 0) timer.cancel();
      if (seconds != _seconds) setState(() => _seconds = seconds);
    });
  }

  String get _code => _controllers.map((e) => e.text).join();
  bool get _complete => _code.length == 4;

  void _onChanged(int index, String value) {
    if (_error) setState(() => _error = false);
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  Future<void> _submit() async {
    if (!_complete) return;
    FocusManager.instance.primaryFocus?.unfocus();

    // Prototype behavior: 0000 demonstrates the Figma error state; any other
    // complete code demonstrates successful verification until API wiring.
    if (_code == '0000') {
      HapticFeedback.mediumImpact();
      setState(() => _error = true);
      if (!DavoMotionPolicy.reduce(context)) {
        await _shakeController.forward(from: 0);
      }
      return;
    }

    HapticFeedback.lightImpact();
    _timer?.cancel();
    setState(() => _verified = true);
  }

  void _continueFromSuccess() {
    final route = widget.kind == VerificationKind.email
        ? AppRoutes.smsVerification
        : AppRoutes.transactionPin;
    Navigator.of(context).pushNamed(route);
  }

  void _resend() {
    if (_seconds > 0) return;
    for (final controller in _controllers) {
      controller.clear();
    }
    setState(() {
      _error = false;
      _verified = false;
    });
    _focusNodes.first.requestFocus();
    _startTimer();
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    if (_verified) {
      return VerificationSuccessScreen(
        kind: widget.kind,
        onContinue: _continueFromSuccess,
      );
    }

    final isEmail = widget.kind == VerificationKind.email;
    return DavoAuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Entrance(
            child: DavoScreenIntro(
              title: isEmail ? 'Check your inbox' : 'Check your SMS',
              subtitle: isEmail
                  ? 'We sent a 4-digit code to vin****nt@gmail.com, Paste it below'
                  : 'We sent a 4-digit code to 90******004, please paste it below',
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: AnimatedBuilder(
              animation: _shakeController,
              builder: (context, child) {
                final progress = _shakeController.value;
                final offset = DavoMotionPolicy.reduce(context)
                    ? 0.0
                    : DavoMotionSpec.rejectionOffset(progress);
                return Transform.translate(
                    offset: Offset(offset, 0), child: child);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _OtpBoxes(
                    controllers: _controllers,
                    focusNodes: _focusNodes,
                    error: _error,
                    onChanged: _onChanged,
                    onSubmit: _submit,
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    child: _error
                        ? Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Incorrect code. Try again',
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 14,
                                height: 1.35,
                                color: DavoColors.of(context).danger,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          DavoPrimaryButton(
            label: 'Submit',
            enabled: _complete,
            onPressed: _complete ? _submit : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Didn’t get a code?',
                style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    color: DavoColors.of(context).body),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: _seconds == 0 ? _resend : null,
                child: Text(
                  'Resend Code',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    color: _seconds == 0
                        ? AppColors.primary
                        : DavoColors.of(context).bodyMuted,
                  ),
                ),
              ),
              const Spacer(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: _seconds > 0
                    ? Text(
                        '0:${_seconds.toString().padLeft(2, '0')}',
                        key: ValueKey(_seconds),
                        style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 14,
                            color: DavoColors.of(context).body),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OtpBoxes extends StatelessWidget {
  const _OtpBoxes({
    required this.controllers,
    required this.focusNodes,
    required this.error,
    required this.onChanged,
    required this.onSubmit,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool error;
  final void Function(int, String) onChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        return Padding(
          padding: EdgeInsets.only(right: index == 3 ? 0 : 16),
          child: SizedBox(
            width: 46,
            height: 46,
            child: TextField(
              controller: controllers[index],
              focusNode: focusNodes[index],
              autofocus: index == 0,
              keyboardType: TextInputType.number,
              textInputAction:
                  index == 3 ? TextInputAction.done : TextInputAction.next,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 14,
                  color: DavoColors.of(context).bodyMuted),
              maxLength: 1,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                counterText: '',
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                      color: error
                          ? DavoColors.of(context).danger
                          : DavoColors.of(context).border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                      color: error
                          ? DavoColors.of(context).danger
                          : AppColors.primary),
                ),
              ),
              onChanged: (value) => onChanged(index, value),
              onSubmitted: (_) {
                if (index == 3) onSubmit();
              },
            ),
          ),
        );
      }),
    );
  }
}

class VerificationSuccessScreen extends StatelessWidget {
  const VerificationSuccessScreen(
      {super.key, required this.kind, required this.onContinue});
  final VerificationKind kind;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) => DavoResultScreen(
        title: kind == VerificationKind.email
            ? 'Email verified!'
            : 'Phone number verified!',
        message: kind == VerificationKind.email
            ? 'Your email address has been verified. Continue to proceed.'
            : 'Your phone number has been verified. Continue to proceed.',
        appBar: AppBar(backgroundColor: DavoColors.of(context).surface),
        actions: DavoPrimaryButton(label: 'Continue', onPressed: onContinue),
      );
}

class TransactionPinScreen extends StatefulWidget {
  const TransactionPinScreen({super.key});

  @override
  State<TransactionPinScreen> createState() => _TransactionPinScreenState();
}

class _TransactionPinScreenState extends State<TransactionPinScreen>
    with SingleTickerProviderStateMixin {
  final _controllers = List.generate(4, (_) => TextEditingController());
  final _focusNodes = List.generate(4, (_) => FocusNode());
  late final AnimationController _shakeController;
  String? _createdPin;
  bool _confirming = false;
  bool _finishing = false;
  bool _error = false;

  String get _pin => _controllers.map((e) => e.text).join();
  bool get _complete => _pin.length == 4;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 220));
  }

  @override
  void dispose() {
    _shakeController.dispose();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _changed(int index, String value) {
    if (_error) setState(() => _error = false);
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  void _clear() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
  }

  Future<void> _continue() async {
    if (!_complete || _finishing) return;
    if (!_confirming) {
      _createdPin = _pin;
      setState(() => _confirming = true);
      _clear();
      HapticFeedback.selectionClick();
      return;
    }

    if (_pin != _createdPin) {
      HapticFeedback.mediumImpact();
      setState(() => _error = true);
      if (!DavoMotionPolicy.reduce(context)) {
        await _shakeController.forward(from: 0);
      }
      return;
    }

    HapticFeedback.lightImpact();
    if (!mounted) return;
    _finishing = true;
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pushReplacement(AppPageRoute<void>(
      authHandoff: true,
      builder: (welcomeContext) => AccountWelcomeScreen(onExplore: () {
        Navigator.of(welcomeContext).pushNamedAndRemoveUntil(
            AppRoutes.dashboard, (route) => false,
            arguments: const AuthHandoff());
      }),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return DavoAuthScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Entrance(
            child: DavoScreenIntro(
              title: 'Great job! Now, secure your account.',
              subtitle: _confirming
                  ? 'Confirm your 4-digit PIN to authorize transactions.'
                  : 'Set up your 4-digit PIN to authorize transactions.',
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                Text(
                  _confirming
                      ? 'Confirm Your Secure PIN'
                      : 'Create Your Secure PIN',
                  style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 14,
                      height: 1.35,
                      color: DavoColors.of(context).body),
                ),
                const SizedBox(height: 9),
                AnimatedBuilder(
                  animation: _shakeController,
                  builder: (context, child) {
                    final p = _shakeController.value;
                    final x = DavoMotionPolicy.reduce(context)
                        ? 0.0
                        : DavoMotionSpec.rejectionOffset(p);
                    return Transform.translate(
                        offset: Offset(x, 0), child: child);
                  },
                  child: _OtpBoxes(
                    controllers: _controllers,
                    focusNodes: _focusNodes,
                    error: _error,
                    onChanged: _changed,
                    onSubmit: _continue,
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 180),
                  child: _error
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'PINs do not match. Try again',
                            style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 14,
                                color: DavoColors.of(context).danger),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          const Spacer(),
          DavoPrimaryButton(
            label: 'Continue',
            enabled: _complete,
            onPressed: _complete ? _continue : null,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
