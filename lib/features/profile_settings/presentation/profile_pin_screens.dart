part of 'profile_settings_flow.dart';

class ResetPinStartScreen extends StatefulWidget {
  const ResetPinStartScreen({super.key});
  @override
  State<ResetPinStartScreen> createState() => _ResetPinStartScreenState();
}

class _ResetPinStartScreenState extends State<ResetPinStartScreen> {
  int method = 0;
  @override
  Widget build(BuildContext context) => _Shell(
      title: 'Reset Transaction PIN',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 26),
        Text(
            'To reset your transaction PIN, you’ll need to verify with a verification code sent to you.',
            style: _t14(context)),
        const SizedBox(height: 24),
        Text('Choose how you want to get code', style: _t14m(context)),
        const SizedBox(height: 12),
        _radioChoice(context, 'Send via SMS', method == 0,
            () => setState(() => method = 0)),
        const SizedBox(height: 12),
        _radioChoice(context, 'Send via Email', method == 1,
            () => setState(() => method = 1)),
        const Spacer(),
        _PrimaryButton('Next',
            onTap: () =>
                _push(context, VerifyPinCodeScreen(email: method == 1))),
        const SizedBox(height: 28)
      ]));
}

class VerifyPinCodeScreen extends StatefulWidget {
  const VerifyPinCodeScreen({super.key, required this.email, this.now});
  final bool email;
  final DateTime Function()? now;
  @override
  State<VerifyPinCodeScreen> createState() => _VerifyPinCodeScreenState();
}

class _VerifyPinCodeScreenState extends State<VerifyPinCodeScreen> {
  final c = TextEditingController();
  Timer? _resendTimer;
  late DateTime _resendAt;
  DateTime get _now => widget.now?.call() ?? DateTime.now();
  int get _remaining =>
      ((_resendAt.difference(_now).inMilliseconds / 1000).ceil()).clamp(0, 30);

  @override
  void initState() {
    super.initState();
    c.addListener(_refresh);
    _startCooldown();
  }

  void _startCooldown() {
    _resendTimer?.cancel();
    _resendAt = _now.add(const Duration(seconds: 30));
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {});
      if (_remaining == 0) timer.cancel();
    });
  }

  void _refresh() => setState(() {});

  void _resend() {
    if (_remaining > 0) return;
    setState(_startCooldown);
    _snack(context, 'Code resent');
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    c.removeListener(_refresh);
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = c.text.length == 4;
    final remaining = _remaining;
    return _Shell(
        title: 'Reset Transaction PIN',
        scroll: true,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 26),
          Text(
              'To reset your transaction PIN, you?ll need to verify with a verification code sent to your ${widget.email ? 'email' : 'phone number'}.',
              style: _t14(context)),
          const SizedBox(height: 24),
          _Input(
              label: 'Verification code',
              hint: 'Enter 4-digit code',
              controller: c,
              keyboard: TextInputType.number,
              labelSize: 16,
              hintSize: 14,
              hintFontFamily: 'Sora',
              maxLength: 4,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
          const SizedBox(height: 12),
          Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                Text('Didn?t get a code?', style: _t12(context)),
                TextButton(
                    onPressed: remaining == 0 ? _resend : null,
                    child: const Text('Resend Code')),
                if (remaining > 0)
                  Text('0:${remaining.toString().padLeft(2, '0')}',
                      style: _t12(context)),
              ]),
          const SizedBox(height: 36),
          _PrimaryButton('Next',
              enabled: enabled,
              disabledBackgroundColor: DavoColors.of(context).primaryDisabled,
              onTap: () {
            _resendTimer?.cancel();
            _push(context, const NewTransactionPinScreen());
          }),
          const SizedBox(height: 28),
        ]));
  }
}

class NewTransactionPinScreen extends StatefulWidget {
  const NewTransactionPinScreen({super.key});
  @override
  State<NewTransactionPinScreen> createState() =>
      _NewTransactionPinScreenState();
}

class _NewTransactionPinScreenState extends State<NewTransactionPinScreen> {
  final a = TextEditingController(), b = TextEditingController();
  bool showNew = false, showConfirm = false;
  bool get valid =>
      RegExp(r'^\d{4}$').hasMatch(a.text) &&
      RegExp(r'^\d{4}$').hasMatch(b.text) &&
      a.text == b.text;
  @override
  void initState() {
    super.initState();
    a.addListener(_refresh);
    b.addListener(_refresh);
  }

  void _refresh() => setState(() {});
  void _save() {
    if (!valid) return;
    FocusScope.of(context).unfocus();
    a.clear();
    b.clear();
    showNew = false;
    showConfirm = false;
    _push(context, const PinSuccessScreen());
  }

  @override
  void dispose() {
    a.removeListener(_refresh);
    b.removeListener(_refresh);
    a.clear();
    b.clear();
    a.dispose();
    b.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = DavoColors.of(context);
    final mismatch = b.text.length == 4 && a.text != b.text;
    return _Shell(
        title: 'Transaction PIN',
        scroll: true,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 20),
          Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                  color: colors.primarySoft,
                  borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.lock_outline_rounded,
                  color: AppColors.primary, size: 28)),
          const SizedBox(height: 20),
          Text('Set your new PIN', style: _t20(context)),
          const SizedBox(height: 8),
          Text(
              'Choose a 4-digit PIN to secure your transactions. Keep it private.',
              style: _t14(context).copyWith(color: colors.bodyMuted)),
          const SizedBox(height: 28),
          _TransactionPinField(
              label: 'New PIN',
              controller: a,
              visible: showNew,
              onToggle: () => setState(() => showNew = !showNew)),
          const SizedBox(height: 20),
          _TransactionPinField(
              label: 'Confirm New PIN',
              controller: b,
              visible: showConfirm,
              onToggle: () => setState(() => showConfirm = !showConfirm)),
          const SizedBox(height: 12),
          Semantics(
              liveRegion: true,
              child: Row(children: [
                Icon(
                    valid
                        ? Icons.check_circle_outline_rounded
                        : mismatch
                            ? Icons.error_outline_rounded
                            : Icons.info_outline_rounded,
                    size: 18,
                    color: valid
                        ? AppColors.primary
                        : mismatch
                            ? colors.danger
                            : colors.bodyMuted),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(
                        valid
                            ? 'PINs match'
                            : mismatch
                                ? 'PINs do not match. Check both entries.'
                                : 'Enter the same 4-digit PIN in both fields.',
                        style: _t12(context).copyWith(
                            color:
                                mismatch ? colors.danger : colors.bodyMuted))),
              ])),
          const SizedBox(height: 32),
          _PrimaryButton('Save', enabled: valid, onTap: _save),
          const SizedBox(height: 28),
        ]));
  }
}

class _TransactionPinField extends StatelessWidget {
  const _TransactionPinField(
      {required this.label,
      required this.controller,
      required this.visible,
      required this.onToggle});
  final String label;
  final TextEditingController controller;
  final bool visible;
  final VoidCallback onToggle;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: _t16(context)),
        const SizedBox(height: 8),
        TextField(
            key: ValueKey(label),
            controller: controller,
            keyboardAppearance: Theme.of(context).brightness,
            obscureText: !visible,
            keyboardType: TextInputType.number,
            enableSuggestions: false,
            autocorrect: false,
            enableIMEPersonalizedLearning: false,
            maxLength: 4,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 20,
                letterSpacing: 8,
                color: DavoColors.of(context).body),
            decoration: InputDecoration(
                hintText: '••••',
                counterText: '',
                filled: true,
                fillColor: DavoColors.of(context).fieldFill,
                suffixIcon: IconButton(
                    tooltip: '${visible ? 'Hide' : 'Show'} $label',
                    onPressed: onToggle,
                    icon: Icon(visible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)))),
      ]);
}

class PinSuccessScreen extends StatelessWidget {
  const PinSuccessScreen({super.key});
  @override
  Widget build(BuildContext context) => DavoResultScreen(
        tempo: DavoOutcomeTempo.compact,
        title: 'Success!',
        message: 'You’ve successfully reset your Transaction PIN',
        actions: _PrimaryButton('Okay',
            onTap: () => Navigator.of(context).popUntil((r) => r.isFirst)),
      );
}

// ---- Support ----
