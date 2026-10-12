import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/motion/davo_motion_policy.dart';
import '../../buy_crypto/presentation/buy_crypto_models.dart';
import 'wallet_address_payload.dart';
import 'wallet_scanner_gateway.dart';

class ScanPasteAddressScreen extends StatefulWidget {
  const ScanPasteAddressScreen(
      {super.key,
      this.asset = BuyCryptoAsset.bitcoin,
      this.network,
      this.scanner});
  final BuyCryptoAsset asset;
  final String? network;
  final WalletScannerGateway? scanner;
  @override
  State<ScanPasteAddressScreen> createState() => _ScanPasteAddressState();
}

class _ScanPasteAddressState extends State<ScanPasteAddressScreen>
    with WidgetsBindingObserver {
  late final scanner = widget.scanner ?? DeviceWalletScannerGateway();
  bool manualOpen = false, starting = false, torchBusy = false;
  bool foreground = true;
  String? error;
  @override
  void initState() {
    super.initState();
    foreground = WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    WidgetsBinding.instance.addObserver(this);
    scanner.addListener(_changed);
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_start()));
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  Future<void> _start() async {
    if (!mounted || manualOpen || starting || !foreground) return;
    starting = true;
    try {
      await scanner.start();
      if (!mounted || manualOpen || !foreground) await _stop();
      if (mounted) setState(() => error = null);
    } catch (_) {
      if (mounted) {
        setState(() => error =
            'Camera unavailable. Allow camera access or enter the address manually.');
      }
    } finally {
      starting = false;
    }
  }

  Future<void> _stop() async {
    try {
      await scanner.stop();
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    foreground = state == AppLifecycleState.resumed;
    if (state == AppLifecycleState.resumed && !manualOpen) {
      unawaited(_start());
    } else if (state != AppLifecycleState.resumed) {
      unawaited(_stop());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    scanner.removeListener(_changed);
    unawaited(scanner.close());
    super.dispose();
  }

  void _detected(String payload) {
    if (!mounted || manualOpen || !foreground) return;
    try {
      final address = walletAddressFromPayload(payload,
          asset: widget.asset, network: widget.network);
      unawaited(_manual(initial: address));
    } on FormatException catch (failure) {
      setState(() => error = failure.message);
    }
  }

  Future<void> _torch() async {
    if (!scanner.torchAvailable || torchBusy) return;
    setState(() => torchBusy = true);
    try {
      await scanner.toggleTorch();
    } catch (_) {
      if (mounted) {
        setState(() => error = 'The flashlight is unavailable on this device.');
      }
    } finally {
      if (mounted) setState(() => torchBusy = false);
    }
  }

  Future<void> _manual({String initial = ''}) async {
    if (manualOpen || !mounted) return;
    setState(() => manualOpen = true);
    await _stop();
    if (!mounted) return;
    final reduced = DavoMotionPolicy.reduce(context);
    final result = await Navigator.of(context).push<String>(PageRouteBuilder<String>(
        transitionDuration: Duration(milliseconds: reduced ? 0 : 240),
        reverseTransitionDuration: Duration(milliseconds: reduced ? 0 : 200),
        pageBuilder: (context, animation, secondaryAnimation) =>
            ManualWalletAddressScreen(
                asset: widget.asset,
                network: widget.network,
                initialAddress: initial),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            reduced
                ? child
                : FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                        position: animation.drive(
                            Tween(begin: const Offset(0, .06), end: Offset.zero)
                                .chain(CurveTween(curve: Curves.easeOutCubic))),
                        child: child))));
    if (!mounted) return;
    if (result != null) {
      Navigator.pop(context, result);
    } else {
      setState(() {
        manualOpen = false;
        error = null;
      });
      await _start();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: DavoColors.of(context).canvas,
      appBar: AppBar(
          title: const Text('Scan or Paste Address',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          centerTitle: true,
          backgroundColor: DavoColors.of(context).canvas,
          scrolledUnderElevation: 0),
      body: SafeArea(
          top: false,
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(children: [
                      Expanded(
                          child: FilledButton(
                              onPressed: _start,
                              child: const Text('Scan QR Code'))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: FilledButton.tonal(
                              onPressed: () => _manual(),
                              child: const Text('Paste Address'))),
                    ]),
                    const SizedBox(height: 20),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                            height: (MediaQuery.sizeOf(context).width * 1.24)
                                .clamp(340.0, 485.0),
                            child: Stack(fit: StackFit.expand, children: [
                              const ColoredBox(color: Colors.black),
                              scanner.preview(onCode: _detected, retry: _start),
                              if (manualOpen)
                                const ColoredBox(color: Colors.black),
                              Align(
                                  alignment: const Alignment(0, -.5),
                                  child: IgnorePointer(
                                      child: FractionallySizedBox(
                                          widthFactor: .82,
                                          child: Image.asset(
                                              'assets/figma_exact/scanner_frame.png')))),
                              Positioned(
                                  left: 16,
                                  right: 16,
                                  bottom: 20,
                                  child: Column(children: [
                                    IconButton.filled(
                                        tooltip: scanner.torchAvailable
                                            ? (scanner.torchOn
                                                ? 'Turn torch off'
                                                : 'Turn torch on')
                                            : 'Torch unavailable',
                                        onPressed:
                                            scanner.torchAvailable && !torchBusy
                                                ? _torch
                                                : null,
                                        style: IconButton.styleFrom(
                                            backgroundColor: scanner.torchOn
                                                ? AppColors.primary
                                                : const Color(0xAA424242),
                                            disabledBackgroundColor:
                                                const Color(0xAA424242)),
                                        icon: Image.asset(
                                            'assets/figma_exact/flashlight.png',
                                            width: 24,
                                            height: 24)),
                                    const SizedBox(height: 12),
                                    const Text(
                                        'Align the QR code within the frame',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'Sora',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600)),
                                    TextButton(
                                        onPressed: () => _manual(),
                                        child: const Text(
                                            'Enter Address manually',
                                            style: TextStyle(
                                                color: Color(0xFF89ADF9),
                                                fontFamily: 'Sora',
                                                fontSize: 12))),
                                  ])),
                            ]))),
                    if (error != null)
                      Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(error!,
                              style: TextStyle(
                                  color: DavoColors.of(context).danger))),
                  ]))));
}

class ManualWalletAddressScreen extends StatefulWidget {
  const ManualWalletAddressScreen(
      {super.key, required this.asset, this.network, this.initialAddress = ''});
  final BuyCryptoAsset asset;
  final String? network;
  final String initialAddress;
  @override
  State<ManualWalletAddressScreen> createState() => _ManualWalletAddressState();
}

class _ManualWalletAddressState extends State<ManualWalletAddressScreen> {
  late final address = TextEditingController(text: widget.initialAddress);
  String? error;
  bool pasting = false;
  @override
  void dispose() {
    address.dispose();
    super.dispose();
  }

  String? get normalized {
    try {
      return walletAddressFromPayload(address.text,
          asset: widget.asset, network: widget.network);
    } on FormatException {
      return null;
    }
  }

  Future<void> _paste() async {
    if (pasting) return;
    setState(() => pasting = true);
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (!mounted) return;
      final text = data?.text?.trim() ?? '';
      address.text = text;
      address.selection = TextSelection.collapsed(offset: text.length);
      setState(() => error = text.isEmpty ? 'Your clipboard is empty.' : null);
    } catch (_) {
      if (mounted) {
        setState(() => error =
            'Clipboard access is unavailable. Enter the address manually.');
      }
    } finally {
      if (mounted) setState(() => pasting = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: DavoColors.of(context).surface,
      appBar: AppBar(
          title: const Text('Enter Wallet Address',
              style: TextStyle(fontSize: 16)),
          centerTitle: true,
          backgroundColor: DavoColors.of(context).surface,
          scrolledUnderElevation: 0),
      body: SafeArea(
          top: false,
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(widget.asset.name,
                        style: const TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Text(
                        widget.network ??
                            'Select the matching network in the withdrawal form.',
                        style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 14,
                            color: DavoColors.of(context).bodyMuted)),
                    const SizedBox(height: 24),
                    TextField(
                        controller: address,
                        minLines: 2,
                        maxLines: 4,
                        maxLength: 512,
                        autocorrect: false,
                        enableSuggestions: false,
                        keyboardType: TextInputType.visiblePassword,
                        onChanged: (_) => setState(() => error = null),
                        decoration: InputDecoration(
                            labelText: 'Wallet address',
                            hintText: 'Enter or paste the wallet address',
                            counterText: '',
                            errorText: error ??
                                (address.text.isNotEmpty && normalized == null
                                    ? 'Enter an address matching this asset and network.'
                                    : null),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8)))),
                    const SizedBox(height: 12),
                    Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                            onPressed: pasting ? null : _paste,
                            icon: const Icon(Icons.content_paste_rounded,
                                size: 18),
                            label: const Text('Paste from clipboard'))),
                    const SizedBox(height: 24),
                    FilledButton(
                        onPressed: normalized == null
                            ? null
                            : () => Navigator.pop(context, normalized),
                        child: const Text('Use Address')),
                  ]))));
}
