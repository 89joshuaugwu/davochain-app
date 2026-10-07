import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/auth_widgets.dart';

const _iconRoot = 'assets/icons/auth';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool get _canLogin => _email.text.trim().isNotEmpty && _password.text.isNotEmpty;

  void _refresh(String _) => setState(() {});

  @override
  Widget build(BuildContext context) {
    return DavoAuthScaffold(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Entrance(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back!',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.ink,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Log in here.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.body,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Entrance(
                      delay: const Duration(milliseconds: 60),
                      child: DavoTextField(
                        label: 'Email Address',
                        controller: _email,
                        hint: 'example@gmail.com',
                        iconAsset: '$_iconRoot/mail.png',
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.email],
                        onChanged: _refresh,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Entrance(
                      delay: const Duration(milliseconds: 100),
                      child: DavoTextField(
                        label: 'Password',
                        controller: _password,
                        hint: 'Create your password',
                        iconAsset: '$_iconRoot/lock.png',
                        obscureText: true,
                        showVisibilityToggle: true,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        borderRadius: 12,
                        onChanged: _refresh,
                        onSubmitted: (_) { if (_canLogin) _login(); },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.forgotPassword),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Forgot Password',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Entrance(
                      delay: const Duration(milliseconds: 150),
                      child: DavoPrimaryButton(
                        label: 'Login',
                        enabled: _canLogin,
                        onPressed: _canLogin ? _login : null,
                      ),
                    ),
                    const Spacer(),
                    Center(
                      child: LinkText(
                        prefix: 'Don’t have an account?',
                        action: 'Create Account',
                        onTap: () => Navigator.of(context).pushNamed(AppRoutes.signup),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _login() {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.dashboard, (route) => false);
  }
}

enum _ForgotStage { email, code, newPassword, success }

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  _ForgotStage _stage = _ForgotStage.email;
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _otp = List.generate(4, (_) => TextEditingController());
  final _otpFocus = List.generate(4, (_) => FocusNode());
  bool _otpError = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    for (final c in _otp) {
      c.dispose();
    }
    for (final f in _otpFocus) {
      f.dispose();
    }
    super.dispose();
  }

  void _back() {
    if (_stage == _ForgotStage.email) {
      Navigator.maybePop(context);
      return;
    }
    setState(() {
      _otpError = false;
      _stage = switch (_stage) {
        _ForgotStage.code => _ForgotStage.email,
        _ForgotStage.newPassword => _ForgotStage.code,
        _ForgotStage.success => _ForgotStage.newPassword,
        _ => _ForgotStage.email,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return DavoAuthScaffold(
      onBack: _back,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 360),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final slide = Tween<Offset>(
            begin: const Offset(.035, 0),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: switch (_stage) {
          _ForgotStage.email => _EmailStage(
              key: const ValueKey('forgot-email'),
              email: _email,
              onContinue: _openCode,
              onLogin: () => Navigator.pop(context),
            ),
          _ForgotStage.code => _CodeStage(
              key: const ValueKey('forgot-code'),
              controllers: _otp,
              focusNodes: _otpFocus,
              error: _otpError,
              onVerify: _verifyCode,
              onResend: _resendCode,
              onChanged: () => setState(() => _otpError = false),
            ),
          _ForgotStage.newPassword => _ResetPasswordStage(
              key: const ValueKey('forgot-new-password'),
              password: _password,
              confirm: _confirm,
              onUpdated: () => setState(() => _stage = _ForgotStage.success),
            ),
          _ForgotStage.success => _PasswordUpdatedStage(
              key: const ValueKey('forgot-success'),
              onLogin: () => Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.login,
                (route) => route.settings.name == AppRoutes.onboarding || route.isFirst,
              ),
            ),
        },
      ),
    );
  }

  void _openCode() {
    if (_email.text.trim().isEmpty) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _stage = _ForgotStage.code);
  }

  void _verifyCode() {
    final code = _otp.map((c) => c.text).join();
    if (code.length != 4 || code == '0000') {
      setState(() => _otpError = true);
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _stage = _ForgotStage.newPassword);
  }

  void _resendCode() {
    for (final c in _otp) {
      c.clear();
    }
    setState(() => _otpError = false);
    _otpFocus.first.requestFocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('A new reset code has been requested.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class _EmailStage extends StatefulWidget {
  const _EmailStage({
    super.key,
    required this.email,
    required this.onContinue,
    required this.onLogin,
  });

  final TextEditingController email;
  final VoidCallback onContinue;
  final VoidCallback onLogin;

  @override
  State<_EmailStage> createState() => _EmailStageState();
}

class _EmailStageState extends State<_EmailStage> {
  bool get enabled => widget.email.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('email-content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Forgot Password',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text('Enter your account email', style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 24),
        DavoTextField(
          label: 'Email Address',
          controller: widget.email,
          hint: '@gmail.com',
          iconAsset: '$_iconRoot/mail.png',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.email],
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) { if (enabled) widget.onContinue(); },
        ),
        const SizedBox(height: 64),
        DavoPrimaryButton(
          label: 'Continue',
          enabled: enabled,
          onPressed: enabled ? widget.onContinue : null,
        ),
        const Spacer(),
        Center(
          child: LinkText(
            prefix: 'Remembered your password?',
            action: 'Login',
            onTap: widget.onLogin,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _CodeStage extends StatelessWidget {
  const _CodeStage({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.error,
    required this.onVerify,
    required this.onResend,
    required this.onChanged,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final bool error;
  final VoidCallback onVerify;
  final VoidCallback onResend;
  final VoidCallback onChanged;

  bool get complete => controllers.every((c) => c.text.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('code-content'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Forgot Password',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Enter the 4-digit code sent to your email',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 18),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(4, (index) {
              return Padding(
                padding: EdgeInsets.only(right: index == 3 ? 0 : 16),
                child: _OtpBox(
                  controller: controllers[index],
                  focusNode: focusNodes[index],
                  error: error,
                  autofocus: index == 0,
                  onChanged: (value) {
                    onChanged();
                    if (value.isNotEmpty && index < 3) {
                      focusNodes[index + 1].requestFocus();
                    } else if (value.isEmpty && index > 0) {
                      focusNodes[index - 1].requestFocus();
                    }
                  },
                ),
              );
            }),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          child: error
              ? const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Center(
                    child: Text(
                      'Incorrect code. Try again',
                      style: TextStyle(fontSize: 12, color: AppColors.danger),
                    ),
                  ),
                )
              : const SizedBox(height: 2),
        ),
        const SizedBox(height: 18),
        DavoPrimaryButton(label: 'Verify', enabled: complete, onPressed: complete ? onVerify : null),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('Didn’t get a code?', style: Theme.of(context).textTheme.bodyMedium),
            TextButton(
              onPressed: onResend,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Resend Code'),
            ),
          ],
        ),
        const Spacer(),
      ],
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.error,
    required this.autofocus,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool error;
  final bool autofocus;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46,
      height: 46,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14, color: AppColors.bodyMuted),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: error ? AppColors.danger : AppColors.primary),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: error ? AppColors.danger : AppColors.primary, width: 1.4),
          ),
        ),
      ),
    );
  }
}

class _ResetPasswordStage extends StatefulWidget {
  const _ResetPasswordStage({
    super.key,
    required this.password,
    required this.confirm,
    required this.onUpdated,
  });

  final TextEditingController password;
  final TextEditingController confirm;
  final VoidCallback onUpdated;

  @override
  State<_ResetPasswordStage> createState() => _ResetPasswordStageState();
}

class _ResetPasswordStageState extends State<_ResetPasswordStage> {
  bool get lengthOk => widget.password.text.length >= 8;
  bool get numberOrSymbol => RegExp(r'[0-9!@#$%^&*(),.?":{}|<>_+\-=\[\]\\;/]').hasMatch(widget.password.text);
  bool get capital => RegExp(r'[A-Z]').hasMatch(widget.password.text);
  bool get strong => lengthOk && numberOrSymbol && capital;
  bool get match => widget.confirm.text.isNotEmpty && widget.confirm.text == widget.password.text;
  bool get enabled => strong && match;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('new-password-content'),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Set New Password',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose something you haven’t used before',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          DavoTextField(
            label: 'Password',
            controller: widget.password,
            hint: 'At least 8 characters',
            obscureText: true,
            showVisibilityToggle: true,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 20),
          _CriteriaBlock(lengthOk: lengthOk, numberOrSymbol: numberOrSymbol, capital: capital),
          const SizedBox(height: 24),
          DavoTextField(
            label: 'Confirm Password',
            controller: widget.confirm,
            hint: 'At least 8 characters',
            obscureText: true,
            showVisibilityToggle: true,
            errorText: widget.confirm.text.isNotEmpty && !match ? 'Password did not match' : null,
            successText: match ? 'Password match' : null,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 102),
          DavoPrimaryButton(
            label: 'Update Password',
            enabled: enabled,
            onPressed: enabled ? widget.onUpdated : null,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _CriteriaBlock extends StatelessWidget {
  const _CriteriaBlock({required this.lengthOk, required this.numberOrSymbol, required this.capital});

  final bool lengthOk;
  final bool numberOrSymbol;
  final bool capital;

  @override
  Widget build(BuildContext context) {
    final score = [lengthOk, numberOrSymbol, capital].where((value) => value).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: SizedBox(
            height: 8,
            child: Stack(
              children: [
                const Positioned.fill(child: ColoredBox(color: AppColors.mutedSoft)),
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 280),
                  widthFactor: score / 3,
                  alignment: Alignment.centerLeft,
                  child: const ColoredBox(color: AppColors.success),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _ResetCriterion(label: 'At least 8 characters long', met: lengthOk),
        const SizedBox(height: 8),
        _ResetCriterion(label: 'One number or symbol', met: numberOrSymbol),
        const SizedBox(height: 8),
        _ResetCriterion(label: 'One capital letter', met: capital),
      ],
    );
  }
}

class _ResetCriterion extends StatelessWidget {
  const _ResetCriterion({required this.label, required this.met});

  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final color = met ? AppColors.success : AppColors.bodyMuted;
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: met ? AppColors.success : AppColors.border,
          ),
        ),
        const SizedBox(width: 9),
        Text(label, style: TextStyle(fontSize: 14, color: color)),
      ],
    );
  }
}

class _PasswordUpdatedStage extends StatelessWidget {
  const _PasswordUpdatedStage({super.key, required this.onLogin});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('success-content'),
      children: [
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: .75, end: 1),
          duration: const Duration(milliseconds: 520),
          curve: Curves.elasticOut,
          builder: (context, value, child) => Transform.scale(scale: value, child: child),
          child: Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: AppColors.primaryDisabled,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Image.asset('$_iconRoot/tick_circle.png', width: 48, height: 48),
          ),
        ),
        const SizedBox(height: 62),
        Text(
          'Password updated',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Your password has been reset. You can now sign in with your new password.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.bodyMuted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: AppColors.warningSurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.warningBorder),
            boxShadow: const [
              BoxShadow(color: Color(0x0A000000), blurRadius: 30, offset: Offset(0, 8)),
            ],
          ),
          child: const Text(
            "For security, you've been signed out of all other devices.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.35, color: AppColors.warning),
          ),
        ),
        const SizedBox(height: 102),
        DavoPrimaryButton(label: 'Login Now', onPressed: onLogin),
        const Spacer(),
      ],
    );
  }
}
