import 'package:flutter/services.dart';

/// Groups the integer portion only; decimal digits and trailing zeros survive.
String formatGroupedAmount(String text) {
  final raw = text.replaceAll(',', '');
  if (raw.isEmpty) return '';
  final parts = raw.split('.');
  final integer = parts.first.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );
  return parts.length > 1 ? '$integer.${parts[1]}' : integer;
}

double parseAmount(String text) =>
    double.tryParse(text.replaceAll(',', '')) ?? 0;

class GroupedAmountInputFormatter extends TextInputFormatter {
  const GroupedAmountInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (!newValue.composing.isCollapsed) return newValue;
    var raw = newValue.text.replaceAll(',', '');
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(raw)) return oldValue;
    var caret = newValue.selection.extentOffset.clamp(0, newValue.text.length);
    var rawCaret = newValue.text.substring(0, caret).replaceAll(',', '').length;
    // Backspacing over a grouping separator deletes the adjacent digit rather
    // than repeatedly restoring the same comma and trapping the caret.
    if (oldValue.selection.isCollapsed &&
        newValue.selection.isCollapsed &&
        oldValue.text.length == newValue.text.length + 1 &&
        oldValue.selection.extentOffset == caret + 1 &&
        caret < oldValue.text.length &&
        oldValue.text[caret] == ',' &&
        rawCaret > 0) {
      raw = raw.substring(0, rawCaret - 1) + raw.substring(rawCaret);
      rawCaret--;
    }
    final grouped = formatGroupedAmount(raw);
    var position = 0;
    var digits = 0;
    while (position < grouped.length && digits < rawCaret) {
      if (grouped[position] != ',') digits++;
      position++;
    }
    return TextEditingValue(
      text: grouped,
      selection: TextSelection.collapsed(offset: position),
    );
  }
}
