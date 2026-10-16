import 'package:davochain/features/wallets/simulation_deposit_button.dart';
import 'package:davochain/features/crypto/presentation/crypto_full_flow.dart';
import 'package:flutter/material.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_models.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_receipt_records.dart';
import 'package:davochain/features/crypto/presentation/crypto_receipt_records.dart';
import 'package:davochain/features/funding/funding_outcomes.dart';
import 'package:davochain/features/gift_cards/presentation/gift_card_receipt_records.dart';
import 'package:davochain/core/preview/local_preview_profile.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/features/wallets/wallet_repository.dart';
import 'package:davochain/features/wallets/wallet_effect.dart';
import 'package:davochain/shared/receipts/receipt_activity.dart';
import 'package:davochain/shared/receipts/receipt_record.dart';

void main() {
  final wallet = WalletAccountState.instance;
  setUp(() {
    ReceiptActivity.reset();
    wallet.startSimulation(empty: true);
  });
  tearDown(() {
    ReceiptActivity.reset();
    wallet.reset();
  });
  ReceiptRecord record(String id, WalletEffect effect, ReceiptStatus status) =>
      ReceiptRecord(
          id: id,
          reference: id,
          type: 'Test',
          status: status,
          occurredAt: DateTime(2026),
          amount: 'opaque display text',
          walletEffect: effect,
          fields: const []);
  test('new simulation account has zero funds in every wallet', () {
    expect(wallet.snapshot.assets.length, 11);
    for (final asset in wallet.snapshot.assets) {
      expect(wallet.snapshot.available(asset).atomicUnits, BigInt.zero);
    }
  });
  test('deposit credits only on completion and is idempotent', () {
    final effect = wallet.effect(credits: {'NGN': '100000'});
    ReceiptActivity.accept(record('deposit', effect, ReceiptStatus.pending));
    expect(wallet.ngnAvailableMinorUnits, 0);
    ReceiptActivity.accept(record('deposit', effect, ReceiptStatus.completed));
    ReceiptActivity.accept(record('deposit', effect, ReceiptStatus.completed));
    expect(wallet.ngnAvailableMinorUnits, 10000000);
  });
  test('pending debit reserves funds, failure refunds and rejects overdrafts',
      () {
    ReceiptActivity.accept(record('fund',
        wallet.effect(credits: {'NGN': '1000'}), ReceiptStatus.completed));
    final effect =
        wallet.effect(debits: {'NGN': '700'}, credits: {'BTC': '0.000001'});
    ReceiptActivity.accept(record('buy', effect, ReceiptStatus.pending));
    expect(wallet.ngnAvailableMinorUnits, 30000);
    ReceiptActivity.accept(record('overspend',
        wallet.effect(debits: {'NGN': '500'}), ReceiptStatus.pending));
    expect(ReceiptActivity.records.value.first.status, ReceiptStatus.failed);
    ReceiptActivity.accept(record('buy', effect, ReceiptStatus.failed));
    expect(wallet.ngnAvailableMinorUnits, 100000);
    expect(wallet.snapshot.available('BTC').atomicUnits, BigInt.zero);
  });
  test('swap settles both legs once and stale account effects cannot apply',
      () {
    ReceiptActivity.accept(record('fund',
        wallet.effect(credits: {'BTC': '0.01'}), ReceiptStatus.completed));
    final effect =
        wallet.effect(debits: {'BTC': '0.005'}, credits: {'ETH': '0.1'});
    ReceiptActivity.accept(record('swap', effect, ReceiptStatus.completed));
    ReceiptActivity.accept(record('swap', effect, ReceiptStatus.completed));
    expect(wallet.snapshot.available('BTC').decimal, '0.005');
    expect(wallet.snapshot.available('ETH').decimal, '0.1');
    wallet.startSimulation(empty: true);
    ReceiptActivity.accept(record('late', effect, ReceiptStatus.completed));
    expect(wallet.snapshot.portfolioMinorUnits, 0);
  });
  test(
      'registration starts empty and provider receipts cannot mint local funds',
      () {
    LocalPreviewProfile.instance.register(
        name: 'Boss Tester',
        email: 'boss@example.com',
        phone: '+2348012345678');
    expect(wallet.simulationEnabled, isTrue);
    expect(wallet.snapshot.portfolioMinorUnits, 0);
    final external = ReceiptRecord(
        id: 'remote',
        reference: 'remote',
        type: 'Deposit',
        status: ReceiptStatus.completed,
        occurredAt: DateTime(2026),
        amount: '100 NGN',
        preview: false,
        walletEffect: wallet.effect(credits: {'NGN': '100'}),
        fields: const []);
    ReceiptActivity.accept(external);
    expect(wallet.ngnAvailableMinorUnits, 0);
  });
  testWidgets(
      'deposit then buy, swap, sell and withdraw update the same wallet',
      (tester) async {
    FundingActivity.reset();
    addTearDown(FundingActivity.reset);
    FundingActivity.submitPreview(FundingRecord(
        id: 'cash-in',
        direction: FundingDirection.deposit,
        status: FundingStatus.pending,
        amount: '200000',
        currency: 'NGN',
        destination: 'NGN wallet',
        occurredAt: DateTime(2026),
        preview: true));
    expect(wallet.ngnAvailableMinorUnits, 0);
    await tester.pump(const Duration(seconds: 21));
    expect(wallet.ngnAvailableMinorUnits, 20000000);
    expect(FundingActivity.records.value.first.status, FundingStatus.completed);
    const order = BuyCryptoOrder(
        asset: BuyCryptoAsset.bitcoin,
        wallet: BuyFundingWallet.ngn,
        ngnAmount: 100000);
    ReceiptActivity.submitPreview(buildBuyReceiptRecord(order, id: 'buy'));
    expect(wallet.ngnAvailableMinorUnits, 10000000);
    expect(wallet.snapshot.available('BTC').atomicUnits, BigInt.zero);
    await tester.pump(const Duration(seconds: 21));
    expect(wallet.snapshot.available('BTC').decimal,
        order.exactCryptoAmount.toString());
    ReceiptActivity.submitPreview(buildCryptoReceiptRecord(
        kind: TxKind.conversion,
        target: 'Ethereum',
        amount: '0.0001',
        id: 'swap',
        asset: BuyCryptoAsset.bitcoin));
    await tester.pump(const Duration(seconds: 21));
    expect(
        wallet.snapshot.available('ETH').atomicUnits, greaterThan(BigInt.zero));
    ReceiptActivity.submitPreview(buildCryptoReceiptRecord(
        kind: TxKind.sell,
        target: 'NGN wallet',
        amount: '0.0001',
        id: 'sell',
        asset: BuyCryptoAsset.bitcoin));
    await tester.pump(const Duration(seconds: 21));
    final afterSale = wallet.ngnAvailableMinorUnits;
    expect(afterSale, greaterThan(10000000));
    FundingActivity.submitPreview(FundingRecord(
        id: 'cash-out',
        direction: FundingDirection.withdrawal,
        status: FundingStatus.pending,
        amount: '1000',
        fee: '100',
        currency: 'NGN',
        destination: 'Bank',
        occurredAt: DateTime(2026),
        preview: true));
    expect(wallet.ngnAvailableMinorUnits, afterSale - 110000);
    await tester.pump(const Duration(seconds: 21));
    expect(wallet.ngnAvailableMinorUnits, afterSale - 110000);
    expect(tester.takeException(), isNull);
  });
  testWidgets('gift trade effects debit and credit NGN without duplicates',
      (tester) async {
    ReceiptActivity.accept(record('fund',
        wallet.effect(credits: {'NGN': '10000'}), ReceiptStatus.completed));
    final purchase = giftCardPreviewReceipt(
        sell: false,
        occurredAt: DateTime(2026),
        id: 'gift-buy',
        naira: 5000,
        cardValue: 10);
    ReceiptActivity.submitPreview(purchase);
    expect(wallet.ngnAvailableMinorUnits, 500000);
    await tester.pump(const Duration(seconds: 21));
    ReceiptActivity.accept(ReceiptActivity.resolve(purchase));
    expect(wallet.ngnAvailableMinorUnits, 500000);
    final sale = giftCardPreviewReceipt(
        sell: true,
        occurredAt: DateTime(2026),
        id: 'gift-sell',
        naira: 3000,
        cardValue: 10);
    ReceiptActivity.submitPreview(sale);
    expect(wallet.ngnAvailableMinorUnits, 500000);
    await tester.pump(const Duration(seconds: 21));
    expect(wallet.ngnAvailableMinorUnits, 800000);
  });
  test('every quoted asset produces a receipt at wallet precision', () {
    for (final asset in BuyCryptoAsset.values) {
      final order = BuyCryptoOrder(
          asset: asset, wallet: BuyFundingWallet.ngn, ngnAmount: 10000);
      final receipt = buildBuyReceiptRecord(order);
      expect(receipt.walletEffect!.credits[asset.symbol]!.decimals,
          wallet.snapshot.available(asset.symbol).decimals);
    }
  });
  testWidgets('insufficient simulated withdrawal fails in both activity feeds',
      (tester) async {
    FundingActivity.reset();
    FundingActivity.submitPreview(FundingRecord(
        id: 'empty-withdraw',
        direction: FundingDirection.withdrawal,
        status: FundingStatus.pending,
        amount: '1000',
        currency: 'NGN',
        destination: 'Bank',
        occurredAt: DateTime(2026),
        preview: true));
    expect(ReceiptActivity.records.value.first.status, ReceiptStatus.failed);
    expect(FundingActivity.records.value.first.status, FundingStatus.failed);
    await tester.pump(const Duration(seconds: 21));
    expect(FundingActivity.records.value.first.status, FundingStatus.failed);
    expect(wallet.ngnAvailableMinorUnits, 0);
  });

  test('sell receipt amount matches the exact credited kobo', () {
    final receipt = buildCryptoReceiptRecord(
        kind: TxKind.sell, target: 'NGN', amount: '0.00000004');
    expect(receipt.amount, '\u20a64.36');
    expect(receipt.walletEffect!.credits['NGN']!.decimal, '4.36');
  });
  testWidgets('swap review shares the buy USD quote', (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home:
            const TradeReviewScreen(kind: TxKind.conversion, amount: '0.01')));
    expect(find.textContaining('820.64'), findsWidgets);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
      'deposit uses normal wording and completed funds update the wallet',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: SimulationDepositButton(currency: 'NGN'))));
    await tester.tap(find.text('Add funds'));
    await tester.pumpAndSettle();
    expect(find.textContaining('simulation'), findsNothing);
    expect(find.textContaining('preview'), findsNothing);
    await tester.tap(find.text('Confirm deposit'));
    await tester.pump(const Duration(seconds: 1));
    expect(wallet.ngnAvailableMinorUnits, 0);
    await tester.pump(const Duration(seconds: 21));
    expect(wallet.ngnAvailableMinorUnits, 10000000);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
