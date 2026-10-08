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
  bool _enabled = false;
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: const Text('Biometrics')),
        body: SafeArea(
            child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: ConstrainedBox(
                          constraints: BoxConstraints(
                              minHeight: constraints.maxHeight - 48),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_enabled)
                                  const DavoSuccessMark(
                                      semanticLabel: 'Fingerprint enabled')
                                else
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
                                Text(
                                    _enabled
                                        ? 'Fingerprint enabled'
                                        : 'Enable fingerprint',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.ink)),
                                const SizedBox(height: 16),
                                const Text(
                                    'Use your fingerprint to unlock your Davochain account quickly and securely.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 14,
                                        height: 1.6,
                                        color: AppColors.bodyMuted)),
                                const SizedBox(height: 40),
                                DavoPrimaryButton(
                                    label: _enabled
                                        ? 'Done'
                                        : 'Enable fingerprint',
                                    onPressed: () {
                                      if (_enabled) {
                                        Navigator.pop(context);
                                        return;
                                      }
                                      PreviewAuthState.biometricsEnabled.value =
                                          true;
                                      setState(() => _enabled = true);
                                    }),
                                if (!_enabled)
                                  TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Not now')),
                              ])),
                    ))),
      );
}
