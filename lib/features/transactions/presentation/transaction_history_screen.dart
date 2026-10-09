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
  Widget build(BuildContext context) => ValueListenableBuilder<
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
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: [
                      Text('Recent activity',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: DavoColors.of(context).ink)),
                      const SizedBox(height: 12),
                      for (final receipt in receipts) ...[
                        ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.receipt_long,
                                color: DavoColors.of(context).link),
                            title: Text(receipt.type,
                                style: const TextStyle(fontSize: 14)),
                            subtitle: Text(
                                '${receipt.status.label}${receipt.preview ? ', Preview' : ''}',
                                style: const TextStyle(fontSize: 12)),
                            trailing: Text(receipt.amount,
                                style: const TextStyle(fontSize: 12)),
                            onTap: () => Navigator.of(context).push(
                                AppPageRoute<void>(
                                    builder: (_) =>
                                        TransactionRecordDetailsScreen(
                                            record: receipt)))),
                        Divider(
                            height: 1, color: DavoColors.of(context).divider),
                      ],
                      for (final record in records) ...[
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                              record.deposit
                                  ? Icons.south_west
                                  : Icons.arrow_outward,
                              color: DavoColors.of(context).link),
                          title: Text(record.title,
                              style: const TextStyle(fontSize: 14)),
                          subtitle: Text(
                              record.preview
                                  ? '${record.statusLabel}, Preview'
                                  : record.statusLabel,
                              style: const TextStyle(fontSize: 12)),
                          trailing: Text(record.amountLabel,
                              style: const TextStyle(fontSize: 12)),
                          onTap: () => Navigator.of(context).push(
                              AppPageRoute<void>(
                                  builder: (_) =>
                                      FundingDetailsScreen(record: record))),
                        ),
                        Divider(
                            height: 1, color: DavoColors.of(context).divider),
                      ],
                      if (records.isNotEmpty) const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: DavoColors.of(context).primarySoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline,
                                size: 20, color: DavoColors.of(context).link),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Sample transactions',
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: DavoColors.of(context).link)),
                                  const SizedBox(height: 4),
                                  Text(
                                      'Preview data only. No funds have been moved.',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: DavoColors.of(context).body)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
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
    final id = 'PREVIEW-HISTORY-${kind.name.toUpperCase()}';
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
                : 'bc1qpreviewaddress';
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
                      description: 'Sample funds credited.',
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
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.of(context)
            .push<void>(AppPageRoute<void>(builder: (_) => sample.details())),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                    color: DavoColors.of(context).primarySoft,
                    shape: BoxShape.circle),
                child: Icon(sample.icon,
                    color: DavoColors.of(context).link, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sample.title,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: DavoColors.of(context).ink)),
                    const SizedBox(height: 5),
                    Text(sample.amount,
                        style: TextStyle(
                            fontSize: 13, color: DavoColors.of(context).body)),
                    const SizedBox(height: 5),
                    Text(sample.date,
                        style: TextStyle(
                            fontSize: 11,
                            color: DavoColors.of(context).bodyMuted)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  Text('Completed',
                      style: TextStyle(
                          fontSize: 11, color: DavoColors.of(context).success)),
                  const SizedBox(height: 8),
                  Icon(Icons.chevron_right,
                      color: DavoColors.of(context).bodyMuted, size: 20),
                ],
              ),
            ],
          ),
        ),
      );
}
