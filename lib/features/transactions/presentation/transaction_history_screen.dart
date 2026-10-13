import '../../../shared/receipts/receipt_identity.dart';
import '../../../shared/widgets/davo_refresh_region.dart';
import '../../../shared/receipts/receipt_activity.dart';
import '../../../shared/receipts/receipt_record.dart';
import '../../../shared/receipts/transaction_record_details_screen.dart';
import '../../buy_crypto/presentation/buy_receipt_records.dart';
import '../../crypto/presentation/crypto_receipt_records.dart';
import '../../funding/funding_outcomes.dart';
import 'package:flutter/material.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/theme/davo_colors.dart';
import '../../buy_crypto/presentation/buy_crypto_models.dart';
import '../../buy_crypto/presentation/buy_crypto_screens.dart';
import '../../crypto/presentation/crypto_full_flow.dart';

/// Local preview history until transaction endpoints are connected.
class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({super.key});

  static const _samples = <_SampleTransaction>[
    _SampleTransaction('Bought Bitcoin', '7 Oct 2026 • 10:30', '+0.0300 BTC',
        Icons.add, _SampleKind.buy),
    _SampleTransaction('Sold Bitcoin', '6 Oct 2026 • 14:20', '−0.0300 BTC',
        Icons.remove, _SampleKind.sell),
    _SampleTransaction('Converted Bitcoin', '5 Oct 2026 • 09:15',
        '0.0300 BTC → USDT', Icons.swap_horiz, _SampleKind.convert),
    _SampleTransaction('Withdrew Bitcoin', '4 Oct 2026 • 16:45', '−0.0300 BTC',
        Icons.arrow_outward, _SampleKind.withdraw),
    _SampleTransaction('Deposited Bitcoin', '3 Oct 2026 • 11:10', '+0.0300 BTC',
        Icons.south_west, _SampleKind.deposit),
  ];

  @override
  Widget build(BuildContext context) => DavoRefreshRegion(
        target: DavoRefreshTarget.transactionHistory,
        builder: _buildHistory,
      );

  Widget _buildHistory(BuildContext context) => ValueListenableBuilder<
          List<FundingRecord>>(
      valueListenable: FundingActivity.records,
      builder: (context, records, _) => ValueListenableBuilder<
              List<ReceiptRecord>>(
          valueListenable: ReceiptActivity.records,
          builder: (context, receipts, _) => Scaffold(
                appBar: AppBar(
                  title: const Text('History'),
                  centerTitle: true,
                  backgroundColor: DavoColors.of(context).surface,
                  foregroundColor: DavoColors.of(context).ink,
                  surfaceTintColor: Colors.transparent,
                ),
                body: SafeArea(
                  top: false,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      Text('Recent activity',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: DavoColors.of(context).ink)),
                      const SizedBox(height: 12),
                      for (final receipt in receipts.where((receipt) => !records
                          .any((funding) => funding.id == receipt.id))) ...[
                        _ActivityRow(
                          title: ReceiptIdentity(receipt).headline,
                          amount: receipt.amount,
                          date: formatReceiptDate(receipt.occurredAt),
                          icon: ReceiptIdentity(receipt).action.icon,
                          status: receipt.status,
                          onTap: () => Navigator.of(context).push(
                              AppPageRoute<void>(
                                  builder: (_) =>
                                      TransactionRecordDetailsScreen(
                                          record: receipt))),
                        ),
                        Divider(
                            height: 1, color: DavoColors.of(context).divider),
                      ],
                      for (final record in records) ...[
                        _ActivityRow(
                          title: record.title,
                          amount: record.amountLabel,
                          date: formatReceiptDate(record.occurredAt),
                          icon: record.deposit
                              ? Icons.south_west
                              : Icons.north_east,
                          status: switch (record.status) {
                            FundingStatus.pending => ReceiptStatus.pending,
                            FundingStatus.completed => ReceiptStatus.completed,
                            FundingStatus.failed => ReceiptStatus.failed,
                          },
                          onTap: () => Navigator.of(context).push(
                              AppPageRoute<void>(
                                  builder: (_) =>
                                      FundingDetailsScreen(record: record))),
                        ),
                        Divider(
                            height: 1, color: DavoColors.of(context).divider),
                      ],
                      if (records.isNotEmpty) const SizedBox(height: 24),
                      for (final sample in _samples) ...[
                        _TransactionRow(sample: sample),
                        if (sample != _samples.last)
                          Divider(
                              height: 1, color: DavoColors.of(context).divider),
                      ],
                    ],
                  ),
                ),
              )));
}

enum _SampleKind { buy, sell, convert, withdraw, deposit }

class _SampleTransaction {
  const _SampleTransaction(
      this.title, this.date, this.amount, this.icon, this.kind);

  final String title;
  final String date;
  final String amount;
  final IconData icon;
  final _SampleKind kind;

  Widget details() {
    final date = switch (kind) {
      _SampleKind.buy => DateTime(2026, 10, 7, 10, 30),
      _SampleKind.sell => DateTime(2026, 10, 6, 14, 20),
      _SampleKind.convert => DateTime(2026, 10, 5, 9, 15),
      _SampleKind.withdraw => DateTime(2026, 10, 4, 16, 45),
      _SampleKind.deposit => DateTime(2026, 10, 3, 11, 10)
    };
    final id = receiptDemoId(date);
    switch (kind) {
      case _SampleKind.buy:
        const order = BuyCryptoOrder(
            asset: BuyCryptoAsset.bitcoin,
            wallet: BuyFundingWallet.ngn,
            ngnAmount: 720000);
        return BuyTransactionDetailsScreen(
            order: order,
            record: buildBuyReceiptRecord(order, occurredAt: date, id: id));
      case _SampleKind.sell:
      case _SampleKind.convert:
      case _SampleKind.withdraw:
        final txKind = kind == _SampleKind.sell
            ? TxKind.sell
            : kind == _SampleKind.convert
                ? TxKind.conversion
                : TxKind.external;
        final target = kind == _SampleKind.sell
            ? 'Nigerian Naira'
            : kind == _SampleKind.convert
                ? 'USDT'
                : 'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh';
        return TransactionDetailsScreen(
            kind: txKind,
            target: target,
            amount: .03,
            record: buildCryptoReceiptRecord(
                kind: txKind,
                target: target,
                amount: .03,
                occurredAt: date,
                id: id,
                network: txKind == TxKind.external ? 'Bitcoin' : null,
                fee: 0));
      case _SampleKind.deposit:
        return DepositStatusScreen(
            success: true,
            record: ReceiptRecord(
                id: id,
                reference: id,
                type: 'Deposit',
                status: ReceiptStatus.completed,
                occurredAt: date,
                amount: '0.03 BTC',
                preview: true,
                fields: const [
                  ReceiptField(label: 'Network', value: 'Bitcoin')
                ],
                events: [
                  ReceiptEvent(
                      label: 'Deposit confirmed',
                      description: 'Deposit confirmed.',
                      occurredAt: date,
                      state: ReceiptEventState.complete)
                ]));
    }
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({required this.sample});
  final _SampleTransaction sample;
  @override
  Widget build(BuildContext context) => _ActivityRow(
      title: sample.title,
      amount: sample.amount,
      date: sample.date,
      icon: sample.icon,
      status: ReceiptStatus.completed,
      onTap: () => Navigator.of(context)
          .push<void>(AppPageRoute<void>(builder: (_) => sample.details())));
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow(
      {required this.title,
      required this.amount,
      required this.date,
      required this.icon,
      required this.status,
      required this.onTap});
  final String title, amount, date;
  final IconData icon;
  final ReceiptStatus status;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final colors = DavoColors.of(context);
    final statusColor = switch (status) {
      ReceiptStatus.pending => colors.warning,
      ReceiptStatus.completed => colors.success,
      ReceiptStatus.failed => colors.danger,
    };
    return InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(children: [
              Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                      color: colors.primarySoft, shape: BoxShape.circle),
                  child: Icon(icon, color: colors.link, size: 22)),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(title,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.ink)),
                    const SizedBox(height: 5),
                    Text(amount,
                        style: TextStyle(fontSize: 13, color: colors.body)),
                    const SizedBox(height: 5),
                    Text(date,
                        style:
                            TextStyle(fontSize: 11, color: colors.bodyMuted)),
                  ])),
              const SizedBox(width: 8),
              Column(children: [
                Text(status.label,
                    style: TextStyle(fontSize: 11, color: statusColor)),
                const SizedBox(height: 8),
                Icon(Icons.chevron_right, color: colors.bodyMuted, size: 20),
              ]),
            ])));
  }
}
