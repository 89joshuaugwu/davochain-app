import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/formatters/grouped_amount_formatter.dart';
import '../../../shared/widgets/davo_toast.dart';
import '../../../shared/widgets/davo_receipt_export_frame.dart';
import '../../../shared/widgets/receipt_detail_row.dart';
import 'buy_crypto_models.dart';
import 'buy_crypto_widgets.dart';

/// Purchase content stays distinct from crypto transfer and sale receipts.
class BuyReceiptScreen extends StatelessWidget {
  const BuyReceiptScreen(
      {super.key,
      required this.order,
      required this.date,
      required this.transactionId});

  final BuyCryptoOrder order;
  final DateTime date;
  final String transactionId;

  @override
  Widget build(BuildContext context) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final time =
        '${months[date.month - 1]} ${date.day}, ${date.year}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    final rows = <Widget>[
      ReceiptDetailRow(
          label: 'Paid from',
          value: '${order.wallet.name} (${order.wallet.symbol})'),
      ReceiptDetailRow(
          label: 'Amount paid',
          value:
              '${formatGroupedAmount(order.ngnAmount.toStringAsFixed(2))} ${order.wallet.symbol}'),
      ReceiptDetailRow(
          label: 'Asset',
          value: '${order.asset.name} (${order.asset.symbol})',
          leading: BuyAssetIcon(asset: order.asset, size: 24)),
      ReceiptDetailRow(label: 'Date', value: time),
      const ReceiptDetailRow(
          label: 'Network Fee', value: 'Free', valueColor: AppColors.primary),
      ReceiptDetailRow(
          label: 'Transaction ID',
          value: transactionId,
          copyable: true,
          onCopy: () => showDavoToast(context, 'Transaction ID copied')),
    ];
    return DavoReceiptExportFrame(
        receiptType: 'Purchase',
        receipt: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Image.asset('assets/images/brand/davochain_logo.png',
                width: 32, height: 32),
            const SizedBox(width: 8),
            const Flexible(
                child: Text('Davochain',
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.w700))),
          ]),
          const SizedBox(height: 8),
          const Text('Purchase Receipt',
              style: TextStyle(fontSize: 14, color: AppColors.bodyMuted)),
          const SizedBox(height: 24),
          Container(
              key: const ValueKey('buy-receipt-card'),
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(children: [
                Row(children: [
                  BuyAssetIcon(asset: order.asset, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(
                            '${formatGroupedAmount(order.cryptoAmount.toStringAsFixed(4))} ${order.asset.symbol}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                        Text(
                            '≈ \$${formatGroupedAmount(order.usdAmount.toStringAsFixed(2))} USD',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.bodyMuted)),
                      ])),
                  const SizedBox(width: 8),
                  Flexible(
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                              color: const Color(0xFFE5F9ED),
                              borderRadius: BorderRadius.circular(30)),
                          child: const Text('Completed',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1BA44D))))),
                ]),
                const Divider(height: 32, color: Color(0xFFF0F1F4)),
                for (final row in rows) ...[
                  row,
                  const Divider(height: 24, color: Color(0xFFF0F1F4)),
                ],
                const SizedBox(height: 8),
                const Text('Thank you for using Davochain',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                const Text('Build. Trade. Belong.',
                    style: TextStyle(fontSize: 12, color: AppColors.bodyMuted)),
              ])),
        ]));
  }
}
