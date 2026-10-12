import 'package:davochain/shared/formatters/nigerian_phone_formatter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const formatter = NigerianPhoneFormatter();
  TextEditingValue edit(String value) => formatter.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(
          text: value,
          selection: TextSelection.collapsed(offset: value.length)));
  test('national prefix is removed before the ten-digit limit', () {
    expect(edit('08161780381').text, '8161780381');
    expect(edit('08161780381').selection.extentOffset, 10);
    expect(edit('8161780381').text, '8161780381');
    expect(edit('+234 0816 178 0381').text, '8161780381');
    expect(edit('002348161780381').text, '8161780381');
  });
  test('typing the leading zero cannot consume the last digit', () {
    var current = TextEditingValue.empty;
    for (final digit in '08161780381'.split('')) {
      final text = current.text + digit;
      current = formatter.formatEditUpdate(
          current,
          TextEditingValue(
              text: text,
              selection: TextSelection.collapsed(offset: text.length)));
    }
    expect(current.text, '8161780381');
  });
  test('leading zero stays until the complete eleven-digit number is entered', () {
    expect(edit('0').text, '0');
    expect(edit('0816').text, '0816');
    expect(edit('0816178038').text, '0816178038');
    expect(edit('08161780381').text, '8161780381');
  });
  test('an extra digit is rejected without truncating a pasted address', () {
    final old = edit('8161780381');
    expect(
        formatter.formatEditUpdate(
            old,
            const TextEditingValue(
                text: '81617803812',
                selection: TextSelection.collapsed(offset: 11))),
        old);
  });
}
