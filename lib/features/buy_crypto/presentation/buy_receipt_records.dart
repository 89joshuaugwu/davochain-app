import '../../../shared/receipts/receipt_record.dart';
import '../../../shared/formatters/grouped_amount_formatter.dart';
import 'buy_crypto_models.dart';

ReceiptRecord buildBuyReceiptRecord(BuyCryptoOrder order,
    {DateTime? occurredAt,
    String? id,
    String? reference,
    ReceiptStatus status = ReceiptStatus.completed,
    bool preview = true}) {
  final date = occurredAt ?? DateTime.now();
  final identity = id ?? receiptDemoId(date);
  return ReceiptRecord(
      id: identity,
      reference: reference ?? identity,
      type: 'Purchase',
      status: status,
      occurredAt: date,
      amount: '${order.formattedCryptoAmount} ${order.asset.symbol}',
      preview: preview,
      fields: [
        ReceiptField(
            label: 'Paid from',
            value: '${order.wallet.name} (${order.wallet.symbol})'),
        ReceiptField(
            label: 'Amount paid',
            value:
                '${formatGroupedAmount(order.ngnAmount.toStringAsFixed(2))} ${order.wallet.symbol}'),
        ReceiptField(
            label: 'Asset',
            value: '${order.asset.name} (${order.asset.symbol})'),
        const ReceiptField(label: 'Network Fee', value: 'Free'),
        ReceiptField(
            label: 'Exchange Rate', value: order.formattedExchangeRate),
      ],
      events: [
        ReceiptEvent(
            label: status.label,
            description: switch (status) {
              ReceiptStatus.completed => 'Purchase completed.',
              ReceiptStatus.pending => 'Purchase awaiting confirmation.',
              ReceiptStatus.failed => 'Purchase failed.',
            },
            occurredAt: date,
            state: status == ReceiptStatus.pending
                ? ReceiptEventState.current
                : ReceiptEventState.complete)
      ]);
}
