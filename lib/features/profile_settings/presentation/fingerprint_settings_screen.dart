part of 'profile_settings_flow.dart';

class FingerprintSettingsScreen extends StatefulWidget {
  const FingerprintSettingsScreen({super.key});
  @override
  State<FingerprintSettingsScreen> createState() =>
      _FingerprintSettingsScreenState();
}

class _FingerprintSettingsScreenState extends State<FingerprintSettingsScreen> {
  bool _working = false;
  final int _generation = PreviewAuthState.generation;

  Future<void> _change(bool payments, bool enabled) async {
    if (_working || _generation != PreviewAuthState.generation) return;
    final preference = payments
        ? PreviewAuthState.paymentBiometricsEnabled
        : PreviewAuthState.biometricsEnabled;
    if (!enabled) {
      setState(() => preference.value = false);
      return;
    }
    setState(() => _working = true);
    var accepted = false;
    try {
      accepted = await BiometricGateway.instance.authenticate(
          reason: payments
              ? 'Enable fingerprint confirmation for Davochain transactions'
              : 'Enable fingerprint unlock for Davochain');
    } catch (_) {
      accepted = false;
    }
    if (!mounted) return;
    setState(() => _working = false);
    if (_generation != PreviewAuthState.generation ||
        !(ModalRoute.of(context)?.isCurrent ?? true)) {
      return;
    }
    if (accepted) {
      setState(() => preference.value = true);
    } else {
      showDavoToast(
          context, 'Fingerprint not confirmed. Your setting has not changed.');
    }
  }

  @override
  void dispose() {
    if (_working) unawaited(BiometricGateway.instance.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _Shell(
      title: 'Fingerprint',
      scroll: true,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 24),
        const Center(
            child: Icon(Icons.fingerprint_rounded,
                size: 72, color: AppColors.primary)),
        const SizedBox(height: 24),
        Text('Choose where to use fingerprint', style: _t20(context)),
        const SizedBox(height: 12),
        Text(
            'Use the fingerprint enrolled on your device. Use your password to sign in, or your payment PIN to confirm transactions.',
            style: _t14(context)),
        const SizedBox(height: 24),
        ValueListenableBuilder<bool>(
            valueListenable: PreviewAuthState.biometricsEnabled,
            builder: (context, value, _) => SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('App unlock'),
                subtitle: const Text('Unlock Davochain with fingerprint.'),
                value: value,
                onChanged: _working ? null : (v) => _change(false, v))),
        const Divider(),
        ValueListenableBuilder<bool>(
            valueListenable: PreviewAuthState.paymentBiometricsEnabled,
            builder: (context, value, _) => SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Payment confirmation'),
                subtitle: const Text(
                    'Use fingerprint in place of your transaction PIN. Off until you enable it.'),
                value: value,
                onChanged: _working ? null : (v) => _change(true, v))),
        if (_working)
          const Padding(
              padding: EdgeInsets.only(top: 16),
              child: LinearProgressIndicator()),
        const SizedBox(height: 24),
      ]));
}
