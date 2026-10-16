import 'receiving_account.dart';

abstract interface class ReceivingAccountGateway {
  Future<ReceivingAccount> provision({
    required String accountId,
    required String idempotencyKey,
    required String accountName,
  });
}

/// Explicit non-routing fixtures until a backend provisions actual bank accounts.
class LocalReceivingAccountGateway implements ReceivingAccountGateway {
  const LocalReceivingAccountGateway();
  @override
  Future<ReceivingAccount> provision({
    required String accountId,
    required String idempotencyKey,
    required String accountName,
  }) async {
    return ReceivingAccount.ready(
      accountId: accountId,
      details: ReceivingBankDetails(
        accountName: accountName.trim().isEmpty
            ? 'Davochain customer'
            : accountName.trim(),
        bankName: 'Davochain preview bank',
        accountNumber: 'TEST-${Uri.encodeComponent(accountId)}',
        isPreview: true,
      ),
    );
  }
}
