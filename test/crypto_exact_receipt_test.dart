import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/features/crypto/presentation/crypto_receipt_records.dart';
import 'package:davochain/features/crypto/presentation/crypto_transaction_kind.dart';

void main() {
  test('one satoshi and large string quantities survive receipt arithmetic',
      () {
    final tiny = buildCryptoReceiptRecord(
        kind: TxKind.sell, target: 'NGN', amount: '0.00000001');
    expect(tiny.amount, '₦0.24');
    final large = buildCryptoReceiptRecord(
        kind: TxKind.internal,
        target: '@recipient',
        amount: '9007199254740993.00000001');
    expect(large.amount, '9007199254740993.00000001 BTC');
  });
}
