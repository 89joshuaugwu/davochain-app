import '../../security_questions/presentation/security_questions_login_gate.dart';
import '../../security_questions/security_questions_service.dart';
import '../../../shared/widgets/transaction_pin_entry.dart';
import '../../profile_settings/presentation/verification/verification_state.dart';
import '../../../shared/widgets/davo_auth_journey.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/navigation/app_page_route.dart';
import '../../../core/preview/preview_auth_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/auth_widgets.dart';
import '../../../shared/widgets/davochain_logo_lockup.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import 'login_flow.dart';

class ReturningUnlockScreen extends StatefulWidget {
  const ReturningUnlockScreen({super.key});
  @override
  State<ReturningUnlockScreen> createState() => _ReturningUnlockScreenState();
}

class _ReturningUnlockScreenState extends State<ReturningUnlockScreen> {
  final _password = TextEditingController();
  AuthJourneyMethod? _method;
  bool _pinOpening = false;
  bool get _opening => _method != null || _pinOpening;
  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  void _unlock([AuthJourneyMethod method = AuthJourneyMethod.password]) {
    if (_opening) return;
    setState(() => _method = method);
    FocusManager.instance.primaryFocus?.unfocus();
    HapticFeedback.lightImpact();
  }

  bool _checkingQuestions = false;
  Future<void> _finishUnlock() async {
    if (_checkingQuestions) return;
    _checkingQuestions = true;
    PreviewAuthState.unlocked.value = false;
    final accepted = await checkSecurityQuestions(context);
    if (!mounted) return;
    _checkingQuestions = false;
    if (!accepted) {
      setState(() => _method = null);
      return;
    }
    PreviewAuthState.unlocked.value = true;
    Navigator.of(context).pushAndRemoveUntil(
        AppPageRoute<void>(
            authHandoff: true,
            builder: (_) => const DavochainDashboardScreen()),
        (_) => false);
  }

  Future<void> _pinUnlock() async {
    if (_opening || _checkingQuestions) return;
    setState(() => _pinOpening = true);
    final accepted = await Navigator.of(context).push<bool>(AppPageRoute<bool>(
      builder: (pinContext) => TransactionPinEntryScreen(
        title: 'Unlock with PIN',
        message: 'Preview only. Enter four digits to try the login flow.',
        onConfirm: () => Navigator.of(pinContext).pop(true),
      ),
    ));
    if (!mounted) return;
    setState(() => _pinOpening = false);
    if (accepted == true) _unlock();
  }

  void _cancel() {
    if (Navigator.of(context).canPop()) {
      Navigator.pop(context);
    } else {
      _otherAccount();
    }
  }

  void _otherAccount() {
    SecurityQuestionsService.instance.clear();
    PreviewAuthState.accountEmail = null;
    PreviewAuthState.unlocked.value = false;
    VerificationSession.instance.reset();
    Navigator.of(context).pushAndRemoveUntil(
        AppPageRoute<void>(builder: (_) => const LoginScreen()), (_) => false);
  }

  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness: Brightness.dark,
            systemNavigationBarColor: AppColors.primary,
            systemNavigationBarIconBrightness: Brightness.light),
        child: DavoAuthJourney(
            onBlue: true,
            method: _method,
            onComplete: _finishUnlock,
            child: Scaffold(
              backgroundColor: AppColors.primary,
              body: SafeArea(
                  child: LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                            child: ConstrainedBox(
                                constraints: BoxConstraints(
                                    minHeight: (constraints.maxHeight - 36)
                                        .clamp(0, double.infinity)),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Align(
                                          alignment: Alignment.centerLeft,
                                          child: IconButton(
                                              tooltip: 'Back to Settings',
                                              onPressed: _cancel,
                                              color: Colors.white,
                                              icon: const Icon(
                                                  Icons.arrow_back_rounded))),
                                      const Entrance(
                                          child: Center(
                                              child: FittedBox(
                                                  child: DavochainLogoLockup(
                                                      logoColor: Colors.white,
                                                      logoWidth: 36,
                                                      fontSize: 26)))),
                                      const SizedBox(height: 28),
                                      Entrance(
                                          delay:
                                              const Duration(milliseconds: 80),
                                          child: Container(
                                              padding: const EdgeInsets.all(24),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          28)),
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    ValueListenableBuilder<
                                                            bool>(
                                                        valueListenable:
                                                            PreviewAuthState
                                                                .biometricsEnabled,
                                                        builder:
                                                            (context, enabled,
                                                                    _) =>
                                                                Column(
                                                                    children: [
                                                                      Semantics(
                                                                        button:
                                                                            enabled,
                                                                        onTap: enabled
                                                                            ? () =>
                                                                                _unlock(AuthJourneyMethod.fingerprint)
                                                                            : null,
                                                                        label: enabled
                                                                            ? 'Use fingerprint'
                                                                            : 'Fingerprint disabled',
                                                                        child: ExcludeSemantics(
                                                                            child: Material(
                                                                                color: const Color(0xFFE8EFFF),
                                                                                shape: const CircleBorder(),
                                                                                child: InkWell(customBorder: const CircleBorder(), onTap: enabled ? () => _unlock(AuthJourneyMethod.fingerprint) : null, child: const Padding(padding: EdgeInsets.all(24), child: Icon(Icons.fingerprint_rounded, size: 64, color: AppColors.primary))))),
                                                                      ),
                                                                      const SizedBox(
                                                                          height:
                                                                              12),
                                                                      if (enabled)
                                                                        TextButton(
                                                                            onPressed: () => _unlock(AuthJourneyMethod
                                                                                .fingerprint),
                                                                            child: const Text(
                                                                                'Use fingerprint'))
                                                                      else
                                                                        Text(
                                                                            'Enable fingerprint in Settings',
                                                                            textAlign: TextAlign
                                                                                .center,
                                                                            style: TextStyle(
                                                                                fontSize: 12,
                                                                                height: 1.5,
                                                                                color: DavoColors.of(context).bodyMuted)),
                                                                    ])),
                                                    const SizedBox(height: 24),
                                                    Text(
                                                        'Welcome back, Vincent',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 23,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            color:
                                                                DavoColors.of(
                                                                        context)
                                                                    .ink)),
                                                    const SizedBox(height: 12),
                                                    const Text(
                                                        'Enter your password to unlock your account.',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            height: 1.5,
                                                            color: AppColors
                                                                .bodyMuted)),
                                                    const SizedBox(height: 24),
                                                    DavoTextField(
                                                        label: 'Password',
                                                        controller: _password,
                                                        hint: 'Enter password',
                                                        obscureText: true,
                                                        showVisibilityToggle:
                                                            true,
                                                        textInputAction:
                                                            TextInputAction
                                                                .done,
                                                        onChanged: (_) =>
                                                            setState(() {}),
                                                        onSubmitted: (_) {
                                                          if (_password.text
                                                              .isNotEmpty) {
                                                            _unlock();
                                                          }
                                                        }),
                                                    TextButton(
                                                      onPressed: _opening
                                                          ? null
                                                          : _pinUnlock,
                                                      child:
                                                          const Text('Use PIN'),
                                                    ),
                                                    const SizedBox(height: 12),
                                                    DavoPrimaryButton(
                                                        label: 'Unlock',
                                                        enabled: !_opening &&
                                                            _password.text
                                                                .isNotEmpty,
                                                        onPressed: _password
                                                                .text.isNotEmpty
                                                            ? _unlock
                                                            : null),
                                                  ]))),
                                      const SizedBox(height: 12),
                                      TextButton(
                                          onPressed: _otherAccount,
                                          child: const Text(
                                              'Use another account',
                                              style: TextStyle(
                                                  color: Colors.white))),
                                    ])),
                          ))),
            )),
      );
}
