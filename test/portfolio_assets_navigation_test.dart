import 'package:davochain/features/dashboard/presentation/dashboard_screen.dart';
import 'package:davochain/features/wallets/wallet_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'full zero-balance catalog is searchable and asset taps open receiving details',
    (tester) async {
      final wallet = WalletAccountState.instance..startSimulation(empty: true);
      addTearDown(wallet.reset);
      await tester.pumpWidget(const MaterialApp(home: PortfolioScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Bitcoin'), findsOneWidget);
      expect(find.text('Cardano'), findsOneWidget);
      await Scrollable.ensureVisible(tester.element(find.text('Bitcoin')), alignment: .25);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bitcoin'));
      await tester.pumpAndSettle();
      expect(find.byType(CryptoDepositScreen), findsOneWidget);
      expect(
        tester
            .widget<CryptoDepositScreen>(find.byType(CryptoDepositScreen))
            .asset,
        CryptoAsset.bitcoin,
      );
      expect(find.text('Copy Address'), findsOneWidget);
    },
  );
}
