import 'package:flutter/widgets.dart' show StringCharacters;

enum ReceiptStatus {
  pending('Pending'),
  completed('Completed'),
  failed('Failed');

  const ReceiptStatus(this.label);
  final String label;
}

enum ReceiptEventState { complete, current, upcoming }

enum ReceiptStyle {
  standard('Standard', 'Transaction receipt'),
  celebration('Celebration', 'Celebration receipt'),
  appreciation('Appreciation', 'Appreciation receipt'),
  birthday('Birthday', 'Birthday receipt');

  const ReceiptStyle(this.label, this.heading);
  final String label, heading;
}

class ReceiptField {
  const ReceiptField(
      {required this.label,
      required this.value,
      this.sensitive = false,
      this.copyable = false});
  final String label, value;
  final bool sensitive, copyable;
}

class ReceiptEvent {
  const ReceiptEvent(
      {required this.label,
      required this.description,
      this.occurredAt,
      required this.state});
  final String label, description;
  final DateTime? occurredAt;
  final ReceiptEventState state;
}

/// Accepted facts remain separate from receipt presentation choices.
class ReceiptRecord {
  ReceiptRecord(
      {required this.id,
      required this.reference,
      required this.type,
      required this.status,
      required this.occurredAt,
      required this.amount,
      this.preview = true,
      required List<ReceiptField> fields,
      List<ReceiptEvent> events = const []})
      : fields = List.unmodifiable(fields),
        events = List.unmodifiable(events);
  final String id, reference, type, amount;
  final ReceiptStatus status;
  final DateTime occurredAt;
  final bool preview;
  final List<ReceiptField> fields;
  final List<ReceiptEvent> events;
}

String formatReceiptDate(DateTime value) {
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
  String two(int n) => n.toString().padLeft(2, '0');
  return '${value.day} ${months[value.month - 1]} ${value.year} · ${two(value.hour)}:${two(value.minute)}${value.isUtc ? ' UTC' : ''}';
}

class ReceiptPresentation {
  ReceiptPresentation(
      {required this.record,
      this.style = ReceiptStyle.standard,
      String note = '',
      this.showSensitive = false})
      : note = note.characters.take(240).toString();
  final ReceiptRecord record;
  final ReceiptStyle style;
  final String note;
  final bool showSensitive;
  List<ReceiptField> get displayFields =>
      List.unmodifiable(record.fields.map((field) => ReceiptField(
          label: field.label,
          value: field.sensitive && !showSensitive ? '••••' : field.value,
          sensitive: field.sensitive,
          copyable: field.copyable && (!field.sensitive || showSensitive))));
  List<ReceiptField> get allDisplayFields => [
        ReceiptField(label: 'Transaction ID', value: record.id, copyable: true),
        ReceiptField(
            label: 'Reference', value: record.reference, copyable: true),
        ReceiptField(
            label: 'Date', value: formatReceiptDate(record.occurredAt)),
        ...displayFields,
      ];
}
