import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/crypto/presentation/wallet_address_scanner.dart';
import 'package:davochain/features/crypto/presentation/wallet_scanner_gateway.dart';

class _Scanner extends WalletScannerGateway {
  int stops = 0, starts = 0;
  bool light = false;
  ValueChanged<String>? detect;
  @override
  bool get torchAvailable => true;
  @override
  bool get torchOn => light;
  @override
  Widget preview(
      {required ValueChanged<String> onCode, required VoidCallback retry}) {
    detect = onCode;
    return const ColoredBox(color: Colors.black);
  }

  @override
  Future<void> start() async {
    starts++;
  }

  @override
  Future<void> stop() async {
    stops++;
  }

  @override
  Future<void> toggleTorch() async {
    light = !light;
    notifyListeners();
  }

  @override
  Future<void> close() async {
    dispose();
  }
}

void main() {
  const address = '1BoatSLRHtKNngkdXEeobR76b53LETtpyT';
  testWidgets('paste opens a separate form; invalid text cannot be submitted',
      (tester) async {
    final scanner = _Scanner();
    String? result;
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: Builder(
            builder: (context) => TextButton(
                onPressed: () async {
                  result = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ScanPasteAddressScreen(
                              scanner: scanner, network: 'Bitcoin (BTC)')));
                },
                child: const Text('Open scanner')))));
    await tester.tap(find.text('Open scanner'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Turn torch on'));
    await tester.pump();
    expect(scanner.light, isTrue);
    await tester.tap(find.text('Paste Address'));
    await tester.pumpAndSettle();
    expect(find.text('Enter Wallet Address'), findsOneWidget);
    expect(scanner.stops, greaterThan(0));
    await tester.enterText(find.byType(TextField), 'invalid address');
    await tester.pump();
    expect(
        tester
            .widget<FilledButton>(
                find.widgetWithText(FilledButton, 'Use Address'))
            .onPressed,
        isNull);
    await tester.enterText(find.byType(TextField), address);
    await tester.pump();
    await tester.tap(find.text('Use Address'));
    await tester.pumpAndSettle();
    expect(result, address);
    expect(tester.takeException(), isNull);
  });
  testWidgets('valid QR opens review once; cancel resumes scanning',
      (tester) async {
    final scanner = _Scanner();
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: ScanPasteAddressScreen(
            scanner: scanner, network: 'Bitcoin (BTC)')));
    await tester.pumpAndSettle();
    scanner.detect!('bitcoin:$address?amount=1');
    scanner.detect!('bitcoin:$address?amount=1');
    await tester.pumpAndSettle();
    expect(find.byType(ManualWalletAddressScreen), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
        address);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(scanner.starts, greaterThan(1));
    expect(find.text('Scan or Paste Address'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
