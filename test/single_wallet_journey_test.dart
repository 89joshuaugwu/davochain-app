import 'package:davochain/features/crypto/presentation/crypto_transaction_kind.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/core/preview/local_preview_profile.dart';
import 'package:davochain/features/funding/receiving_account_gateway.dart';
import 'package:davochain/features/funding/funding_outcomes.dart';
import 'package:davochain/features/wallets/wallet_repository.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_models.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_receipt_records.dart';
import 'package:davochain/features/crypto/presentation/crypto_receipt_records.dart';
import 'package:davochain/shared/receipts/receipt_activity.dart';
import 'package:davochain/shared/receipts/receipt_record.dart';

void main() {
  testWidgets(
    'new receiving wallet funds Buy, Swap, Sell and a bank withdrawal once',
    (tester) async {
      final wallet = WalletAccountState.instance;
      ReceiptActivity.reset();
      FundingActivity.reset();
      LocalPreviewProfile.instance.register(
        name: 'Wallet Tester',
        email: 'single-wallet@example.com',
        phone: '+2348000000000',
      );
      final receiving = await const LocalReceivingAccountGateway().provision(
        accountId: wallet.snapshot.accountId,
        idempotencyKey: 'signup',
        accountName: 'Wallet Tester',
      );
      expect(receiving.details!.isPreview, isTrue);
      expect(wallet.ngnAvailableMinorUnits, 0);
      FundingActivity.submitPreview(
        FundingRecord(
          id: 'journey-in',
          direction: FundingDirection.deposit,
          status: FundingStatus.pending,
          amount: '10000',
          currency: 'NGN',
          destination: receiving.details!.accountNumber,
          occurredAt: DateTime(2026),
          preview: true,
        ),
      );
      await tester.pump(const Duration(seconds: 21));
      expect(wallet.ngnAvailableMinorUnits, 1000000);
      final buy = buildBuyReceiptRecord(
        const BuyCryptoOrder(
          asset: BuyCryptoAsset.bitcoin,
          wallet: BuyFundingWallet.ngd,
          ngnAmount: '1000',
        ),
        id: 'journey-buy',
      );
      ReceiptActivity.submitPreview(buy);
      await tester.pump(const Duration(seconds: 21));
      expect(wallet.ngnAvailableMinorUnits, 900000);
      final swap = buildCryptoReceiptRecord(
        kind: TxKind.conversion,
        target: 'USDT',
        amount: wallet.snapshot.available('BTC').decimal,
        asset: BuyCryptoAsset.bitcoin,
        id: 'journey-swap',
      );
      ReceiptActivity.submitPreview(swap);
      await tester.pump(const Duration(seconds: 21));
      expect(wallet.snapshot.available('BTC').atomicUnits, BigInt.zero);
      expect(
        wallet.snapshot.available('USDT').atomicUnits,
        greaterThan(BigInt.zero),
      );
      final sell = buildCryptoReceiptRecord(
        kind: TxKind.sell,
        target: 'NGN',
        amount: wallet.snapshot.available('USDT').decimal,
        asset: BuyCryptoAsset.tether,
        id: 'journey-sell',
      );
      ReceiptActivity.submitPreview(sell);
      await tester.pump(const Duration(seconds: 21));
      final proceeds = wallet.ngnAvailableMinorUnits;
      expect(proceeds, greaterThan(900000));
      ReceiptActivity.accept(ReceiptActivity.resolve(sell));
      expect(wallet.ngnAvailableMinorUnits, proceeds);
      FundingActivity.submitPreview(
        FundingRecord(
          id: 'journey-out',
          direction: FundingDirection.withdrawal,
          status: FundingStatus.pending,
          amount: '100',
          fee: '100',
          currency: 'NGN',
          destination: 'Linked bank',
          bank: 'Test bank',
          accountNumber: '1234567890',
          accountName: 'Wallet Tester',
          occurredAt: DateTime(2026),
          preview: true,
        ),
      );
      expect(wallet.ngnAvailableMinorUnits, proceeds - 20000);
      await tester.pump(const Duration(seconds: 21));
      expect(wallet.ngnAvailableMinorUnits, proceeds - 20000);
      expect(
        FundingActivity.records.value.first.status,
        FundingStatus.completed,
      );
      expect(wallet.snapshot.assets.contains('NGD'), isFalse);
      expect(
        ReceiptActivity.records.value.every(
          (record) => record.status == ReceiptStatus.completed,
        ),
        isTrue,
      );
      ReceiptActivity.reset();
      FundingActivity.reset();
      wallet.reset();
      await tester.pump();
    },
  );
}
