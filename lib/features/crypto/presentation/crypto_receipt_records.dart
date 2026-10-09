import '../../../shared/formatters/crypto_quantity_formatter.dart';
import '../../../shared/receipts/receipt_record.dart';
import '../../../shared/formatters/grouped_amount_formatter.dart';
import '../../buy_crypto/presentation/buy_crypto_models.dart';
import 'crypto_transaction_kind.dart';
export '../../../shared/formatters/crypto_quantity_formatter.dart';

ReceiptRecord buildCryptoReceiptRecord(
    {required TxKind kind,
    required String target,
    required double amount,
    BuyCryptoAsset asset = BuyCryptoAsset.bitcoin,
    ReceiptStatus status = ReceiptStatus.completed,
    DateTime? occurredAt,
    String? id,
    String? reference,
    String? network,
    String? transactionHash,
    double? fee,
    bool preview = true}) {
  final date = occurredAt ?? DateTime.now();
  final type = switch (kind) {
    TxKind.sell => 'Sell',
    TxKind.conversion => 'Conversion',
    TxKind.external => 'External Transfer',
    TxKind.internal => 'Transfer'
  };
  final identity =
      id ?? 'PREVIEW-${kind.name.toUpperCase()}-${date.microsecondsSinceEpoch}';
  final quantity = '${formatCryptoQuantity(amount)} ${asset.symbol}';
  final ngn = amount * asset.ngnPerUnit;
  final destination = BuyCryptoAsset.values
      .where((a) => a.symbol == target || a.name == target)
      .firstOrNull;
  final received = kind == TxKind.sell
      ? '₦${formatGroupedAmount(ngn.toStringAsFixed(2))}'
      : kind == TxKind.conversion && destination != null
          ? '${formatCryptoQuantity(ngn / destination.ngnPerUnit)} ${destination.symbol}'
          : null;
  return ReceiptRecord(
      id: identity,
      reference: reference ?? identity,
      type: type,
      status: status,
      occurredAt: date,
      amount: received ?? quantity,
      preview: preview,
      fields: [
        ReceiptField(label: 'Asset', value: '${asset.name} (${asset.symbol})'),
        ReceiptField(
            label: kind == TxKind.sell || kind == TxKind.conversion
                ? 'From'
                : 'Amount',
            value: quantity),
        ReceiptField(
            label: kind == TxKind.conversion ? 'To' : 'Destination',
            value: target,
            sensitive: kind == TxKind.external || kind == TxKind.internal,
            copyable: true),
        if (received != null)
          ReceiptField(label: 'Total Received', value: received),
        if (network != null) ReceiptField(label: 'Network', value: network),
        ReceiptField(
            label: 'Network Fee',
            value: fee == null
                ? 'Not supplied'
                : fee == 0
                    ? 'Free'
                    : '${formatCryptoQuantity(fee)} ${asset.symbol}'),
        if (kind == TxKind.sell)
          ReceiptField(
              label: 'Exchange Rate',
              value:
                  '1 ${asset.symbol} ≈ ₦${formatGroupedAmount(asset.ngnPerUnit.toStringAsFixed(2))}'),
        if (kind == TxKind.conversion && destination != null)
          ReceiptField(
              label: 'Exchange Rate',
              value:
                  '1 ${asset.symbol} ≈ ${formatCryptoQuantity(asset.ngnPerUnit / destination.ngnPerUnit)} ${destination.symbol}'),
        if (transactionHash != null)
          ReceiptField(
              label: 'Transaction Hash',
              value: transactionHash,
              copyable: true),
      ],
      events: status == ReceiptStatus.pending
          ? [
              ReceiptEvent(
                  label: 'Submitted',
                  description: 'Transaction request submitted.',
                  occurredAt: date,
                  state: ReceiptEventState.complete),
              const ReceiptEvent(
                  label: 'Awaiting confirmation',
                  description: 'Status will update after confirmation.',
                  state: ReceiptEventState.current),
              const ReceiptEvent(
                  label: 'Completed',
                  description: 'Final confirmation is pending.',
                  state: ReceiptEventState.upcoming),
            ]
          : [
              ReceiptEvent(
                  label: status.label,
                  description: status == ReceiptStatus.completed
                      ? 'Transaction completed.'
                      : 'Transaction unsuccessful.',
                  occurredAt: date,
                  state: ReceiptEventState.complete)
            ]);
}
