import '../motion/davo_motion_policy.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'auth_widgets.dart';
import 'dart:async';
import '../../core/device/biometric_gateway.dart';
import '../../core/preview/preview_auth_state.dart';
import '../../core/navigation/app_page_route.dart';
import '../../features/profile_settings/presentation/profile_settings_flow.dart';

class TransactionPinEntryScreen extends StatefulWidget {
  const TransactionPinEntryScreen(
      {super.key,
      required this.onConfirm,
      this.paymentConfirmation = true,
      this.title = 'Confirm Your Pin',
      this.message =
          'Please enter your 4-digit security PIN to confirm this transaction.'});
  final VoidCallback onConfirm;
  final bool paymentConfirmation;
  final String title, message;

  @override
  State<TransactionPinEntryScreen> createState() =>
      _TransactionPinEntryScreenState();
}

class _TransactionPinEntryScreenState extends State<TransactionPinEntryScreen> {
  String pin = '';
  String? error;
  bool _authenticating = false, _confirmed = false;
  late final int _generation;
  bool get _locked =>
      widget.paymentConfirmation && PreviewAuthState.paymentsLocked();
  bool get _current =>
      mounted &&
      _generation == PreviewAuthState.generation &&
      (ModalRoute.of(context)?.isCurrent ?? true);

  @override
  void initState() {
    super.initState();
    _generation = PreviewAuthState.generation;
  }

  @override
  void dispose() {
    if (_authenticating) unawaited(BiometricGateway.instance.cancel());
    super.dispose();
  }

  void _finish() {
    if (!_current || _confirmed || _locked) return;
    _confirmed = true;
    pin = '';
    widget
        .onConfirm(); // Local preview only; backend must still authorize payment.
  }

  Future<void> _fingerprint() async {
    if (_authenticating ||
        _confirmed ||
        _locked ||
        !_current ||
        !PreviewAuthState.paymentBiometricsEnabled.value) {
      return;
    }
    setState(() => _authenticating = true);
    var accepted = false;
    try {
      accepted = await BiometricGateway.instance.authenticate(
          reason: 'Confirm this Davochain transaction with your fingerprint');
    } catch (_) {
      accepted = false;
    }
    if (!mounted) return;
    setState(() => _authenticating = false);
    if (!_current) return;
    if (accepted && PreviewAuthState.paymentBiometricsEnabled.value) {
      _finish();
    } else {
      setState(
          () => error = 'Fingerprint not confirmed. Enter your PIN instead.');
    }
  }

  Future<void> _confirmPin() async {
    if (pin.length != 4 ||
        _authenticating ||
        _confirmed ||
        !_current ||
        _locked) {
      return;
    }
    if (PreviewAuthState.verifyTransactionPin(pin,
        payment: widget.paymentConfirmation)) {
      _finish();
      return;
    }
    setState(() {
      pin = '';
      error = _locked
          ? 'Payments are paused for 1 hour. You can still use your account.'
          : 'Incorrect PIN. Please try again.';
    });
    if (widget.paymentConfirmation &&
        PreviewAuthState.paymentPinFailures == 4) {
      final reset = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('One attempt remaining'),
                content: const Text(
                    'One more incorrect PIN pauses payments for 1 hour. Reset your PIN or try once more.'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Reset PIN')),
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Last try')),
                ],
              ));
      if (!_current) return;
      if (reset == true) _resetPin();
    }
  }

  void _resetPin() {
    Navigator.of(context)
        .push(AppPageRoute<void>(builder: (_) => const ResetPinStartScreen()));
  }

  void key(String value) {
    if (_locked || _authenticating || _confirmed || !_current) return;
    setState(() {
      if (value == 'back') {
        if (pin.isNotEmpty) pin = pin.substring(0, pin.length - 1);
      } else if (pin.length < 4) {
        pin += value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final reduced = DavoMotionPolicy.reduce(context);
    return DavoAuthScaffold(
      child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 96,
                      height: 96,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: DavoColors.of(context).surface,
                          boxShadow: const [
                            BoxShadow(
                                color: Color(0x16000000),
                                blurRadius: 12,
                                offset: Offset(0, 3))
                          ]),
                      child: Image.asset(
                          'assets/figma_exact/buy_pin_shield.png',
                          width: 32,
                          height: 40),
                    ),
                    const SizedBox(height: 26),
                    Text(widget.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 24,
                            height: 1.35,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(widget.message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 14,
                                height: 1.4,
                                color: DavoColors.of(context).body))),
                    const SizedBox(height: 32),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          final filled = index < pin.length;
                          return Semantics(
                              label:
                                  'PIN digit ${index + 1}, ${filled ? "entered" : "empty"}',
                              child: AnimatedContainer(
                                duration: reduced
                                    ? Duration.zero
                                    : const Duration(milliseconds: 160),
                                width: 56,
                                height: 68,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: DavoColors.of(context).mutedSoft,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: filled
                                            ? AppColors.primary
                                            : DavoColors.of(context).divider)),
                                child: filled
                                    ? Icon(Icons.circle,
                                        size: 14,
                                        color: DavoColors.of(context).ink)
                                    : null,
                              ));
                        })),
                    const SizedBox(height: 16),
                    if (error != null || _locked)
                      Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Semantics(
                              liveRegion: true,
                              child: Text(
                                  _locked
                                      ? 'Payments are paused for 1 hour. You can still use your account.'
                                      : error!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: DavoColors.of(context).danger)))),
                    SizedBox(
                        height: 52,
                        child: Center(
                            child: pin.length == 4 && !_locked
                                ? DavoPrimaryButton(
                                    label: 'Confirm',
                                    onPressed:
                                        _authenticating ? null : _confirmPin)
                                : Text('Enter Secure PIN',
                                    style: TextStyle(
                                        fontSize: 14,
                                        height: 1.4,
                                        color: DavoColors.of(context).body)))),
                    const SizedBox(height: 16),
                    ...List.generate(
                        4,
                        (row) => Row(
                                children: List.generate(3, (col) {
                              const values = [
                                '1',
                                '2',
                                '3',
                                '4',
                                '5',
                                '6',
                                '7',
                                '8',
                                '9',
                                '',
                                '0',
                                'back'
                              ];
                              const letters = [
                                '',
                                'ABC',
                                'DEF',
                                'GHI',
                                'JKL',
                                'MNO',
                                'PQRS',
                                'TUV',
                                'WXYZ',
                                '',
                                '',
                                ''
                              ];
                              final i = row * 3 + col;
                              if (values[i].isEmpty) {
                                return const Expanded(
                                    child: SizedBox(height: 56));
                              }
                              return Expanded(
                                  child: SizedBox(
                                      height: 56 +
                                          (MediaQuery.textScalerOf(context)
                                                      .scale(25) -
                                                  25)
                                              .clamp(0, double.infinity),
                                      child: Semantics(
                                        button: true,
                                        onTap: () => key(values[i]),
                                        label: values[i] == 'back'
                                            ? 'Delete PIN digit'
                                            : values[i],
                                        excludeSemantics: true,
                                        child: InkWell(
                                          onTap: () => key(values[i]),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Center(
                                              child: values[i] == 'back'
                                                  ? const Icon(
                                                      Icons.backspace_outlined,
                                                      size: 24)
                                                  : Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                          Text(values[i],
                                                              style: TextStyle(
                                                                  fontSize: 25,
                                                                  height: 1.1,
                                                                  color: DavoColors.of(
                                                                          context)
                                                                      .ink)),
                                                          if (letters[i]
                                                              .isNotEmpty)
                                                            Text(letters[i],
                                                                style: const TextStyle(
                                                                    fontSize:
                                                                        10,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w700,
                                                                    letterSpacing:
                                                                        1.5)),
                                                        ])),
                                        ),
                                      )));
                            }))),
                    const SizedBox(height: 40),
                    if (widget.paymentConfirmation &&
                        PreviewAuthState.paymentBiometricsEnabled.value &&
                        !_locked)
                      TextButton.icon(
                          onPressed: _authenticating ? null : _fingerprint,
                          icon: const Icon(Icons.fingerprint_rounded),
                          label: Text(_authenticating
                              ? 'Confirming fingerprint...'
                              : 'Use fingerprint')),
                    if (widget.paymentConfirmation)
                      TextButton(
                          onPressed: _authenticating ? null : _resetPin,
                          child: const Text('Reset PIN')),
                    Text('Enter your transaction PIN to continue.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 12,
                            height: 1.4,
                            color: DavoColors.of(context).body)),
                    const SizedBox(height: 12),
                  ]),
                ),
              )),
    );
  }
}
