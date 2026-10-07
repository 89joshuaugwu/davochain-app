import 'package:flutter/material.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/auth_widgets.dart';

class CreatePasswordScreen extends StatefulWidget {
  const CreatePasswordScreen({super.key});

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  bool get _lengthOk => _password.text.length >= 8;
  bool get _numberOrSymbol => RegExp(r'[0-9!@#$%^&*(),.?":{}|<>_+\-=\[\]\\;/]').hasMatch(_password.text);
  bool get _capital => RegExp(r'[A-Z]').hasMatch(_password.text);
  bool get _strong => _lengthOk && _numberOrSymbol && _capital;
  bool get _match => _confirm.text.isNotEmpty && _confirm.text == _password.text;
  bool get _canContinue => _strong && _match;

  int get _score {
    var score = 0;
    if (_lengthOk) score++;
    if (_numberOrSymbol) score++;
    if (_capital) score++;
    return score;
  }

  String get _strengthLabel {
    if (_password.text.isEmpty) return '';
    if (_score <= 1) return 'Low Strength';
    if (_score == 2) return 'Medium Strength';
    return 'Strong Password';
  }

  Color get _strengthColor {
    if (_score <= 1) return AppColors.danger;
    if (_score == 2) return const Color(0xFFF3A712);
    return AppColors.success;
  }

  void _refresh(String _) => setState(() {});

  @override
  Widget build(BuildContext context) {
    return DavoAuthScaffold(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(

            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Entrance(
                      child: DavoScreenIntro(
                        title: 'Create Password',
                        subtitle: 'Set a strong password to keep your Davochain account secure.',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Entrance(
                      delay: const Duration(milliseconds: 50),
                      child: DavoTextField(
                        label: 'Password',
                        controller: _password,
                        hint: 'At least 8 characters',
                        obscureText: true,
                        showVisibilityToggle: true,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newPassword],
                        onChanged: _refresh,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Entrance(
                      delay: const Duration(milliseconds: 90),
                      child: _PasswordStrength(
                        score: _score,
                        label: _strengthLabel,
                        color: _strengthColor,
                        lengthOk: _lengthOk,
                        numberOrSymbol: _numberOrSymbol,
                        capital: _capital,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Entrance(
                      delay: const Duration(milliseconds: 130),
                      child: DavoTextField(
                        label: 'Confirm Password',
                        controller: _confirm,
                        hint: 'At least 8 characters',
                        obscureText: true,
                        showVisibilityToggle: true,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.newPassword],
                        errorText: _confirm.text.isNotEmpty && !_match ? 'Password did not match' : null,
                        successText: _match ? 'Password match' : null,
                        onChanged: _refresh,
                        onSubmitted: (_) { if (_canContinue) _continue(); },
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(height: 32),
                    DavoPrimaryButton(
                      label: 'Continue',
                      enabled: _canContinue,
                      onPressed: _canContinue ? _continue : null,
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

  void _continue() {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.emailVerification,
      (route) => route.settings.name == AppRoutes.onboarding || route.isFirst,
    );
  }
}

class _PasswordStrength extends StatelessWidget {
  const _PasswordStrength({
    required this.score,
    required this.label,
    required this.color,
    required this.lengthOk,
    required this.numberOrSymbol,
    required this.capital,
  });

  final int score;
  final String label;
  final Color color;
  final bool lengthOk;
  final bool numberOrSymbol;
  final bool capital;

  @override
  Widget build(BuildContext context) {
    final progress = score / 3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: SizedBox(
            height: 8,
            child: Stack(
              children: [
                const Positioned.fill(
                  child: ColoredBox(color: AppColors.mutedSoft),
                ),
                AnimatedFractionallySizedBox(
                  duration: const Duration(milliseconds: 320),
                  curve: Curves.easeOutCubic,
                  widthFactor: progress,
                  alignment: Alignment.centerLeft,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          child: label.isEmpty
              ? const SizedBox(height: 8)
              : Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 14, height: 1.35, color: color),
                  ),
                ),
        ),
        const SizedBox(height: 8),
        _Criterion(label: 'At least 8 characters long', met: lengthOk),
        const SizedBox(height: 8),
        _Criterion(label: 'One number or symbol', met: numberOrSymbol),
        const SizedBox(height: 8),
        _Criterion(label: 'One capital letter', met: capital),
      ],
    );
  }
}

class _Criterion extends StatelessWidget {
  const _Criterion({required this.label, required this.met});

  final String label;
  final bool met;

  @override
  Widget build(BuildContext context) {
    final color = met ? AppColors.success : AppColors.bodyMuted;
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 220),
      style: TextStyle(
        fontFamily: 'Sora',
        fontSize: 14,
        height: 1.35,
        color: color,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: met ? AppColors.success : AppColors.border),
          ),
          const SizedBox(width: 9),
          Text(label),
        ],
      ),
    );
  }
}
