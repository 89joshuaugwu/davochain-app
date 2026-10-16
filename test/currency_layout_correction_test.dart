import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/features/dashboard/presentation/dashboard_screen.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_widgets.dart';
import 'package:davochain/features/wallets/presentation/wallet_picker_sheet.dart';
import 'package:davochain/features/wallets/wallet_repository.dart';
import 'package:davochain/shared/widgets/davo_naira_amount.dart';

void main() {
  setUp(() => WalletAccountState.instance.startSimulation(empty: false));
  tearDown(WalletAccountState.instance.reset);
  testWidgets(
    'crypto selector keeps compact quantity rows without cash equivalents',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: BuyCryptoAssetSheet())),
      );
      await tester.pumpAndSettle();
      expect(find.byType(DavoNairaAmount), findsNothing);
      expect(find.textContaining(r'$'), findsNothing);
      expect(find.text('0.0086 BTC'), findsOneWidget);
      expect(
        tester.getSize(find.byKey(const ValueKey('crypto-option-BTC'))).height,
        lessThanOrEqualTo(76),
      );
    },
  );
  testWidgets(
    'wallet selector cash amount has brand while crypto keeps quantity only',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: WalletPickerSheet())),
      );
      await tester.pumpAndSettle();
      expect(find.byType(DavoNairaAmount), findsOneWidget);
      expect(find.textContaining(r'$'), findsNothing);
      expect(find.text('0.0086 BTC'), findsOneWidget);
    },
  );
  testWidgets('portfolio search pins while assets continue scrolling', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(411, 914);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: PortfolioScreen()));
    await tester.pumpAndSettle();
    expect(find.byType(DavoNairaAmount), findsNothing);
    final search = find.byKey(const ValueKey('portfolio-asset-search'));
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -1000));
    await tester.pumpAndSettle();
    final first = tester.getTopLeft(search).dy;
    expect(first, closeTo(8, .5));
    expect(search.hitTestable(), findsOneWidget);
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -180));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(search).dy, closeTo(first, .5));
    expect(tester.takeException(), isNull);
  });
}
