import 'package:flutter/services.dart';

/// Keeps the national number separate from the displayed +234 prefix.
class NigerianPhoneFormatter extends TextInputFormatter {
  const NigerianPhoneFormatter();
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    var removed = 0;
    if (newValue.text.trimLeft().startsWith('+234')) {
      removed = 3;
    } else if (digits.startsWith('00234')) {
      removed = 5;
    } else if (digits.length > 10 && digits.startsWith('234')) {
      removed = 3;
    }
    var number = digits.substring(removed.clamp(0, digits.length));
    if (number.length == 11 && number.startsWith('0')) {
      number = number.substring(1);
      removed++;
    }
    if (number.length > 10) return oldValue;
    int offset(int original) {
      final before =
          newValue.text.substring(0, original.clamp(0, newValue.text.length));
      return (before.replaceAll(RegExp(r'\D'), '').length - removed)
          .clamp(0, number.length);
    }

    return TextEditingValue(
        text: number,
        selection: TextSelection(
            baseOffset: offset(newValue.selection.baseOffset),
            extentOffset: offset(newValue.selection.extentOffset)));
  }
}
