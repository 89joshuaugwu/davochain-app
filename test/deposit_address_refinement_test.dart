import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/dashboard/presentation/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
      'deposit identifies coin and network and copies full hidden address',
      (tester) async {
    const address = '0x4C55D181b91A6d5fE8B54B925C61D9dC06cE28B4';
    String? copied;
    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        copied = (call.arguments as Map)['text'] as String;
      }
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: const CryptoDepositScreen(asset: CryptoAsset.tether)));
    await tester.pumpAndSettle();
    expect(find.text('Tether (USDT)'), findsOneWidget);
    expect(find.text('Network: Ethereum (ERC20)'), findsOneWidget);
    expect(find.text(address), findsNothing);
    expect(
        tester.widget<Text>(find.byKey(const ValueKey('deposit-address'))).data,
        '0x4C55...E28B4');
    await tester.tap(find.text('Copy Address'));
    await tester.pump();
    expect(copied, address);
    await Scrollable.ensureVisible(tester.element(find.text('Show all')),
        alignment: .5);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show all'));
    await tester.pump();
    expect(find.text(address), findsOneWidget);
    await Scrollable.ensureVisible(tester.element(find.text('Hide')),
        alignment: .5);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hide'));
    await tester.pump();
    expect(find.text(address), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('deposit address expansion stays usable at enlarged text',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!),
        home: const CryptoDepositScreen(asset: CryptoAsset.ethereum)));
    await tester.pumpAndSettle();
    await Scrollable.ensureVisible(tester.element(find.text('Show all')),
        alignment: .5);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Show all'));
    await tester.pump();
    expect(find.text('Hide'), findsOneWidget);
    expect(find.text('Copy Address'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
