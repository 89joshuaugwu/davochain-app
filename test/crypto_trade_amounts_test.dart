import 'package:davochain/features/crypto/crypto_trade_amounts.dart';
import 'package:davochain/core/money/exact_decimal.dart';
import 'package:davochain/core/money/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
      'percentage selection retains atomic precision without exceeding balance',
      () {
    final available = AssetAmount.parse('0.000000001', 'SOL', 9);
    expect(CryptoTradeAmounts.percentage(available, 100).toString(),
        '0.000000001');
    expect(CryptoTradeAmounts.percentage(available, 50).toString(), '0');
  });
  test('validation rejects overprecision and includes withdrawal fees', () {
    final available = AssetAmount.parse('0.0086', 'BTC', 8);
    expect(
        CryptoTradeAmounts.canSpend(available, ExactDecimal.parse('0.0086'),
            fee: ExactDecimal.parse('0.00002')),
        isFalse);
    expect(
        CryptoTradeAmounts.canSpend(available, ExactDecimal.parse('0.00858'),
            fee: ExactDecimal.parse('0.00002')),
        isTrue);
    expect(
        CryptoTradeAmounts.canSpend(
            available, ExactDecimal.parse('0.000000001')),
        isFalse);
  });
}
