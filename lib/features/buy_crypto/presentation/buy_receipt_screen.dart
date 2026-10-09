import 'package:flutter/material.dart';
import '../../../shared/receipts/receipt_record.dart';
import '../../../shared/receipts/receipt_screen.dart';
import 'buy_crypto_models.dart';
import 'buy_receipt_records.dart';

class BuyReceiptScreen extends StatelessWidget {
  const BuyReceiptScreen(
      {super.key,
      required this.order,
      required this.date,
      required this.transactionId,
      this.record});
  final BuyCryptoOrder order;
  final DateTime date;
  final String transactionId;
  final ReceiptRecord? record;
  @override
  Widget build(BuildContext context) => KeyedSubtree(
      key: const ValueKey('buy-receipt-card'),
      child: ReceiptScreen(
          record: record ??
              buildBuyReceiptRecord(order,
                  occurredAt: date, id: transactionId)));
}
