import '../../profile_settings/presentation/verification/verification_state.dart';
import 'dart:async';
import '../../../core/device/biometric_gateway.dart';
import '../../../shared/motion/davo_outcome_content.dart';
import 'package:flutter/material.dart';
import '../../../core/preview/preview_auth_state.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/auth_widgets.dart';
import '../../../shared/widgets/davo_success_mark.dart';

class FingerprintSetupScreen extends StatefulWidget {
  const FingerprintSetupScreen({super.key});
  @override
  State<FingerprintSetupScreen> createState() => _FingerprintSetupScreenState();
}

class _FingerprintSetupScreenState extends State<FingerprintSetupScreen> {
  bool _enabled = false, _busy = false;
  String? _error;
  @override
  void dispose() {
    unawaited(BiometricGateway.instance.cancel());
    super.dispose();
  }

  Future<void> _enable() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final generation = VerificationSession.instance.generation;
    try {
      final accepted = await BiometricGateway.instance.authenticate(
          reason: 'Confirm biometrics to enable Davochain device unlock');
      if (!mounted || generation != VerificationSession.instance.generation) {
        return;
      }
      if (accepted) {
        PreviewAuthState.biometricsEnabled.value = true;
        setState(() => _enabled = true);
      } else {
        setState(() => _error =
            'Fingerprint was not confirmed. Enroll a fingerprint in device settings or use your password.');
      }
    } catch (_) {
      if (mounted) {
        setState(() =>
            _error = 'Biometric unlock is unavailable. Use your password.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: DavoColors.of(context).surface,
        appBar: AppBar(title: const Text('Biometrics')),
        body: SafeArea(
            child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                          constraints: BoxConstraints(
                              minHeight: constraints.maxHeight - 48),
                          child: Column(
                              mainAxisAlignment: _enabled
                                  ? MainAxisAlignment.center
                                  : MainAxisAlignment.start,
                              children: [
                                if (_enabled)
                                  DavoOutcomeContent(
                                      tempo: DavoOutcomeTempo.compact,
                                      semanticLabel: 'Fingerprint enabled',
                                      heading: Column(children: [
                                        Text('Fingerprint enabled',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.w600,
                                                color: DavoColors.of(context)
                                                    .ink)),
                                        const SizedBox(height: 16),
                                        Text(
                                            'Use your fingerprint to unlock your Davochain account quickly and securely.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontSize: 14,
                                                height: 1.6,
                                                color: DavoColors.of(context)
                                                    .bodyMuted))
                                      ]))
                                else ...[
                                  Container(
                                      width: 140,
                                      height: 140,
                                      decoration: const BoxDecoration(
                                          color: Color(0xFFE8EFFF),
                                          shape: BoxShape.circle),
                                      child: const Icon(
                                          Icons.fingerprint_rounded,
                                          size: 82,
                                          color: AppColors.primary)),
                                  const SizedBox(height: 32),
                                  Text('Enable fingerprint',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600,
                                          color: DavoColors.of(context).ink)),
                                  const SizedBox(height: 16),
                                  Text(
                                      'Use your fingerprint to unlock your Davochain account quickly and securely.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontSize: 14,
                                          height: 1.6,
                                          color: DavoColors.of(context)
                                              .bodyMuted)),
                                ],
                                if (_error != null)
                                  Text(_error!,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color:
                                              DavoColors.of(context).danger)),
                                const SizedBox(height: 40),
                                DavoPrimaryButton(
                                    label: _enabled
                                        ? 'Done'
                                        : 'Enable fingerprint',
                                    enabled: !_busy,
                                    onPressed: _enabled
                                        ? () => Navigator.pop(context)
                                        : _enable),
                                if (!_enabled)
                                  TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Not now')),
                              ])),
                    ))),
      );
}
