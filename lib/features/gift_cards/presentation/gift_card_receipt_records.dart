import '../../../shared/formatters/grouped_amount_formatter.dart';
import '../../../shared/receipts/receipt_record.dart';

/// Captures the existing local outcome once; it does not submit a trade.
ReceiptRecord giftCardPreviewReceipt({
  required bool sell,
  required DateTime occurredAt,
  required String id,
  double? cardValue,
  int? naira,
  String? brand,
  String? category,
  String? subcategory,
  String? country,
  String? cardType,
  int? quantity,
}) {
  return ReceiptRecord(
    id: id,
    reference: id,
    type: sell ? 'Gift card sale' : 'Gift card purchase',
    status: sell ? ReceiptStatus.pending : ReceiptStatus.completed,
    occurredAt: occurredAt,
    amount: naira == null ? 'Amount unavailable' : '₦${formatGroupedAmount(naira.toString())}',
    fields: [
      if (cardValue != null) ReceiptField(label: 'Card Value', value: '\$${formatGroupedAmount(cardValue.toStringAsFixed(2))}'),
      if (brand != null) ReceiptField(label: 'Brand', value: brand),
      if (category != null) ReceiptField(label: 'Category', value: category),
      if (subcategory != null) ReceiptField(label: 'Subcategory', value: subcategory),
      if (country != null) ReceiptField(label: 'Country', value: country),
      if (cardType != null) ReceiptField(label: 'Card type', value: cardType),
      if (quantity != null) ReceiptField(label: 'Quantity', value: '$quantity'),
    ],
    events: [ReceiptEvent(
      label: sell ? 'Submitted' : 'Purchase preview',
      description: sell ? 'Local preview submitted; review is pending.' : 'Local purchase preview completed.',
      occurredAt: occurredAt,
      state: sell ? ReceiptEventState.current : ReceiptEventState.complete,
    )],
  );
}
