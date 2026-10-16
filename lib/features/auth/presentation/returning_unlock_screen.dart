import '../../../core/providers/reactive_builder.dart';
import '../../../core/preview/local_preview_profile.dart';
import 'dart:async';
import '../../../core/device/biometric_gateway.dart';
import '../../../shared/widgets/davo_toast.dart';
import '../../security_questions/presentation/security_questions_login_gate.dart';
import '../../security_questions/security_questions_service.dart';
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
  bool _biometricOpening = false;
  bool get _opening => _method != null || _biometricOpening;
  @override
  void initState() {
    super.initState();
    LocalPreviewProfile.instance.addListener(_refreshProfile);
  }

  void _refreshProfile() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    LocalPreviewProfile.instance.removeListener(_refreshProfile);
    unawaited(BiometricGateway.instance.cancel());
    _password.dispose();
    super.dispose();
  }

  Future<void> _unlock(
      [AuthJourneyMethod method = AuthJourneyMethod.password]) async {
    if (_opening) return;
    if (method == AuthJourneyMethod.fingerprint) {
      final generation = VerificationSession.instance.generation;
      setState(() => _biometricOpening = true);
      bool accepted = false;
      try {
        accepted = await BiometricGateway.instance.authenticate(
            reason: 'Unlock Davochain with your enrolled biometrics');
      } catch (_) {
        accepted = false;
      }
      if (!mounted) return;
      setState(() => _biometricOpening = false);
      if (generation != VerificationSession.instance.generation) return;
      if (!accepted) {
        showDavoToast(context, 'Fingerprint not confirmed. Use your password.');
        return;
      }
    }
    setState(() => _method = method);
    FocusManager.instance.primaryFocus?.unfocus();
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
    PreviewAuthState.resetSession();
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
                                                  color: DavoColors.of(context).surface,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          28)),
                                              child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    DavoValueListenableBuilder<
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
                                                        'Welcome back, ${LocalPreviewProfile.instance.firstName}',
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
                                                    Text(
                                                        'Enter your password to unlock your account.',
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            height: 1.5,
                                                            color: DavoColors.of(context)
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
