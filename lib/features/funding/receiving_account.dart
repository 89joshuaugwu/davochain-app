enum ReceivingAccountStatus { creating, ready, failed, unavailable }

class ReceivingBankDetails {
  const ReceivingBankDetails({
    required this.accountName,
    required this.bankName,
    required this.accountNumber,
    required this.isPreview,
  });
  final String accountName, bankName, accountNumber;
  final bool isPreview;
  Map<String, Object?> toJson() => {
    'name': accountName,
    'bank': bankName,
    'number': accountNumber,
    'preview': isPreview,
  };
}

class ReceivingAccount {
  const ReceivingAccount({
    required this.accountId,
    required this.status,
    this.details,
  });
  const ReceivingAccount.ready({
    required this.accountId,
    required ReceivingBankDetails this.details,
  }) : status = ReceivingAccountStatus.ready;
  final String accountId;
  final ReceivingAccountStatus status;
  final ReceivingBankDetails? details;
  Map<String, Object?> toJson() => {
    'version': 1,
    'account': accountId,
    'status': status.name,
    'details': details?.toJson(),
  };
  factory ReceivingAccount.fromJson(Map<String, Object?> json) {
    if (json['version'] != 1 || json['account'] is! String) {
      throw const FormatException('Invalid receiving account');
    }
    final raw = json['details'] as Map?;
    final status = ReceivingAccountStatus.values.byName(
      json['status'] as String,
    );
    final details = raw == null
        ? null
        : ReceivingBankDetails(
            accountName: raw['name'] as String,
            bankName: raw['bank'] as String,
            accountNumber: raw['number'] as String,
            isPreview: raw['preview'] as bool,
          );
    if (status == ReceivingAccountStatus.ready &&
        (details == null ||
            details.accountNumber.isEmpty ||
            details.bankName.isEmpty ||
            details.accountName.isEmpty)) {
      throw const FormatException('Missing receiving details');
    }
    return ReceivingAccount(
      accountId: json['account'] as String,
      status: status,
      details: status == ReceivingAccountStatus.ready ? details : null,
    );
  }
}
