import 'package:davochain/features/buy_crypto/presentation/buy_crypto_widgets.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_models.dart';
import 'package:davochain/features/crypto/presentation/crypto_receipt_records.dart';
import 'package:davochain/features/crypto/presentation/crypto_transaction_kind.dart';
import 'package:davochain/features/wallets/wallet_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'funded source picker omits zero holdings and excludes destination',
    (tester) async {
      final wallet = WalletAccountState.instance..startSimulation(empty: false);
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BuyCryptoAssetSheet(
              fundedOnly: true,
              excluded: BuyCryptoAsset.tether,
            ),
          ),
        ),
      );
      expect(find.text('Bitcoin'), findsOneWidget);
      expect(find.text('Tether'), findsNothing);
      expect(find.text('XRP'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      wallet.reset();
    },
  );
  test(
    'sell proceeds enter the same wallet available for buying and withdrawing',
    () async {
      final wallet = WalletAccountState.instance..startSimulation(empty: false);
      final before = wallet.ngnAvailableMinorUnits;
      final record = buildCryptoReceiptRecord(
        kind: TxKind.sell,
        target: 'NGN',
        amount: '0.001',
        asset: BuyCryptoAsset.bitcoin,
      );
      final effect = record.walletEffect!;
      expect(effect.credits.keys, ['NGN']);
      wallet.applyEffect('sell', effect, completed: true, failed: false);
      expect(wallet.ngnAvailableMinorUnits, greaterThan(before));
      expect(BuyFundingWallet.ngd.exactBalance.toFixed(2), isNotEmpty);
      await Future<void>.delayed(Duration.zero);
      wallet.reset();
    },
  );
}
