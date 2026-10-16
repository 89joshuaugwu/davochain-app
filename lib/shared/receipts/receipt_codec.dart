import '../../features/wallets/wallet_effect.dart';
import 'receipt_record.dart';

Map<String, Object?> encodeReceipt(ReceiptRecord r) => {
  'id': r.id,
  'reference': r.reference,
  'type': r.type,
  'status': r.status.name,
  'occurredAt': r.occurredAt.toIso8601String(),
  'amount': r.amount,
  'preview': r.preview,
  'effect': r.walletEffect?.toJson(),
  'fields': [
    for (final f in r.fields)
      {
        'label': f.label,
        'value': f.value,
        'sensitive': f.sensitive,
        'copyable': f.copyable,
      },
  ],
  'events': [
    for (final e in r.events)
      {
        'label': e.label,
        'description': e.description,
        'occurredAt': e.occurredAt?.toIso8601String(),
        'state': e.state.name,
      },
  ],
};
ReceiptRecord decodeReceipt(
  Map<String, Object?> data, {
  required int generation,
}) => ReceiptRecord(
  id: data['id'] as String,
  reference: data['reference'] as String,
  type: data['type'] as String,
  status: ReceiptStatus.values.byName(data['status'] as String),
  occurredAt: DateTime.parse(data['occurredAt'] as String),
  amount: data['amount'] as String,
  preview: data['preview'] as bool,
  walletEffect: data['effect'] == null
      ? null
      : WalletEffect.fromJson(
          Map<String, Object?>.from(data['effect'] as Map),
          generation: generation,
        ),
  fields: [
    for (final raw in data['fields'] as List)
      ReceiptField(
        label: raw['label'] as String,
        value: raw['value'] as String,
        sensitive: raw['sensitive'] as bool,
        copyable: raw['copyable'] as bool,
      ),
  ],
  events: [
    for (final raw in data['events'] as List)
      ReceiptEvent(
        label: raw['label'] as String,
        description: raw['description'] as String,
        occurredAt: raw['occurredAt'] == null
            ? null
            : DateTime.parse(raw['occurredAt'] as String),
        state: ReceiptEventState.values.byName(raw['state'] as String),
      ),
  ],
);
