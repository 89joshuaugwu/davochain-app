import 'package:davochain/core/money/exact_decimal.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('addition and large fiat values preserve every digit', () {
    expect((ExactDecimal.parse('0.1') + ExactDecimal.parse('0.2')).toString(),
        '0.3');
    expect(
        (ExactDecimal.parse('9007199254740993.01') + ExactDecimal.parse('0.09'))
            .toFixed(2),
        '9007199254740993.10');
  });
  test('division has explicit rounding at financial precision', () {
    final one = ExactDecimal.parse('1'), three = ExactDecimal.parse('3');
    expect(
        one.divide(three, scale: 2, rounding: DecimalRounding.floor).toFixed(2),
        '0.33');
    expect(
        one.divide(three, scale: 2, rounding: DecimalRounding.ceil).toFixed(2),
        '0.34');
    expect(ExactDecimal.parse('1.005').toFixed(2), '1.01');
    expect(ExactDecimal.parse('-1.005').toFixed(2), '-1.01');
    expect(
        ExactDecimal.parse('-1.005')
            .toFixed(2, rounding: DecimalRounding.floor),
        '-1.01');
    expect(
        ExactDecimal.parse('-1.005').toFixed(2, rounding: DecimalRounding.ceil),
        '-1.00');
  });
  test('small crypto, multiplication and num compatibility normalize exactly',
      () {
    expect(ExactDecimal.from(0.00000001).toString(), '0.00000001');
    expect(
        (ExactDecimal.parse('0.00000001') * ExactDecimal.parse('24000000'))
            .toFixed(2),
        '0.24');
    expect(ExactDecimal.parse('0001.23000').toString(), '1.23');
    expect(ExactDecimal.parse('0').compareTo(ExactDecimal.parse('0.00000001')),
        lessThan(0));
  });
  test('invalid quantities and unsafe syntax never enter arithmetic', () {
    for (final value in ['NaN', 'Infinity', '1,23', '1e3', '--1', '.']) {
      expect(() => ExactDecimal.parse(value), throwsFormatException);
    }
    expect(() => ExactDecimal.from(double.infinity), throwsFormatException);
    expect(() => ExactDecimal.parse('1').divide(ExactDecimal.zero),
        throwsArgumentError);
  });
}
