import '../../shared/receipts/receipt_record.dart';
import 'notification_inbox.dart';

enum NotificationVerificationStatus { submitted, verified, needsAttention }

/// Indexes match the existing account notification preferences screen.
int notificationReceiptPreference(ReceiptRecord receipt) {
  final type = receipt.type.toLowerCase();
  if (type.contains('gift')) return 5;
  if (type.contains('deposit')) return 3;
  if (type.contains('withdraw') ||
      type.contains('transfer') ||
      type.contains('send')) {
    return 4;
  }
  if (type.contains('swap') || type.contains('conversion')) return 2;
  if (type.contains('sale') || type.contains('sell')) return 1;
  return 0;
}

/// Receives committed account facts. No timers, network calls or ledger writes.
class NotificationEventCoordinator {
  NotificationEventCoordinator({
    required this.inbox,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;
  static final instance = NotificationEventCoordinator(
    inbox: NotificationInbox.instance,
  );
  final NotificationInbox inbox;
  final DateTime Function() _clock;
  String? _accountId;
  int? _generation;
  final Set<String> _seen = {};
  String? get accountId => _accountId;

  void activate(
    String accountId,
    int generation, {
    Iterable<ReceiptRecord> baseline = const [],
  }) {
    _generation = generation;
    if (_accountId != accountId) {
      _seen.clear();
      _accountId = accountId;
      // Existing legacy receipts are history, not newly delivered credits.
      for (final receipt in baseline) {
        _seen.add('receipt:${receipt.id}:${receipt.status.name}');
      }
      inbox.reset(records: const []);
    }
  }

  bool _accept(String accountId, int generation, String key) =>
      _accountId == accountId && _generation == generation && _seen.add(key);

  bool welcome(String accountId, int generation, {required String firstName}) {
    const key = 'welcome';
    if (!_accept(accountId, generation, key)) return false;
    final name = firstName.trim();
    return _add(
      key,
      title: name.isEmpty
          ? 'Welcome to Davochain'
          : 'Welcome to Davochain, $name',
      body:
          'Your account is ready. Complete your basic profile to get started, then explore your wallets, crypto and gift cards.',
      kind: NotificationKind.welcome,
      action: NotificationAction.basicVerification,
      facts: const {
        'Next step': 'Complete your basic profile',
        'Account': 'Created',
      },
    );
  }

  bool receipt(
    String accountId,
    int generation,
    ReceiptRecord receipt, {
    bool enabled = true,
  }) {
    final key = 'receipt:${receipt.id}:${receipt.status.name}';
    if (!_accept(accountId, generation, key)) return false;
    // Starting a deposit is not evidence that money has arrived.
    if (!enabled ||
        (receipt.type.toLowerCase().contains('deposit') &&
            receipt.status == ReceiptStatus.pending)) {
      inbox.checkpointChanged();
      return false;
    }
    final type = receipt.type.toLowerCase();
    final preference = notificationReceiptPreference(receipt);
    final label = type == 'purchase'
        ? 'Crypto purchase'
        : type == 'sell'
        ? 'Crypto sale'
        : type == 'conversion'
        ? 'Crypto swap'
        : receipt.type;
    final kind = type.contains('gift')
        ? NotificationKind.giftCard
        : type.contains('deposit')
        ? NotificationKind.deposit
        : preference == 4
        ? NotificationKind.withdrawal
        : NotificationKind.crypto;
    final title = switch ((kind, receipt.status)) {
      (NotificationKind.deposit, ReceiptStatus.completed) => 'Deposit received',
      (NotificationKind.withdrawal, ReceiptStatus.completed) =>
        'Withdrawal completed',
      (_, ReceiptStatus.failed) => '$label unsuccessful',
      (_, ReceiptStatus.pending) => '$label in progress',
      _ => '$label completed',
    };
    final body = switch (receipt.status) {
      ReceiptStatus.pending =>
        'Your ${label.toLowerCase()} of ${receipt.amount} is being processed. Open the transaction for its current status.',
      ReceiptStatus.failed =>
        'Your ${label.toLowerCase()} of ${receipt.amount} could not be completed. Review the transaction details before trying again.',
      ReceiptStatus.completed =>
        kind == NotificationKind.deposit
            ? '${receipt.amount} has been credited to your wallet. View your transaction for the full details.'
            : 'Your ${label.toLowerCase()} of ${receipt.amount} is complete. Your transaction details are ready.',
    };
    return _add(
      key,
      title: title,
      body: body,
      category: 1,
      kind: kind,
      action: NotificationAction.receipt,
      receiptId: receipt.id,
      amount: receipt.amount,
      status: receipt.status.label,
      asset: receipt.assets.firstOrNull?.name,
      facts: {
        'Transaction': receipt.type,
        'Reference': receipt.reference,
        for (final field in receipt.fields.where((f) => !f.sensitive).take(3))
          field.label: field.value,
      },
    );
  }

  bool verification(
    String accountId,
    int generation, {
    required bool advanced,
    required NotificationVerificationStatus status,
    bool enabled = true,
  }) {
    final stage = advanced ? 'Advanced' : 'Basic';
    final key =
        'verification:${advanced ? 'advanced' : 'basic'}:${status.name}';
    if (!_accept(accountId, generation, key)) return false;
    if (!enabled) {
      inbox.checkpointChanged();
      return false;
    }
    final title = switch (status) {
      NotificationVerificationStatus.submitted =>
        advanced
            ? 'Advanced verification submitted'
            : 'Basic profile completed',
      NotificationVerificationStatus.verified => '$stage verification complete',
      NotificationVerificationStatus.needsAttention =>
        '$stage verification needs attention',
    };
    final body = switch (status) {
      NotificationVerificationStatus.submitted =>
        advanced
            ? 'Your details are ready for review. Track your progress in account verification.'
            : 'Your basic details have been submitted. Continue with Advanced verification to complete your identity and address information.',
      NotificationVerificationStatus.verified =>
        advanced
            ? 'Your Advanced verification has been confirmed. View your account verification for the details.'
            : 'Your Basic verification has been confirmed. Continue with Advanced verification to complete the next step.',
      NotificationVerificationStatus.needsAttention =>
        'Review your $stage verification details and follow the next steps in account verification.',
    };
    return _add(
      key,
      title: title,
      body: body,
      category: 2,
      kind: NotificationKind.verification,
      action:
          advanced || status == NotificationVerificationStatus.needsAttention
          ? NotificationAction.basicVerification
          : NotificationAction.advancedVerification,
      status: status == NotificationVerificationStatus.submitted
          ? 'Submitted'
          : status == NotificationVerificationStatus.verified
          ? 'Verified'
          : 'Action needed',
      facts: {
        'Verification level': stage,
        'Next step': advanced
            ? 'Review verification progress'
            : 'Continue with Advanced verification',
      },
    );
  }

  bool security(
    String accountId,
    int generation, {
    required String operationId,
    required String title,
    required String detail,
  }) {
    final key = 'security:$operationId';
    if (!_accept(accountId, generation, key)) return false;
    return _add(
      key,
      title: title,
      body: detail,
      category: 2,
      kind: NotificationKind.security,
      action: NotificationAction.security,
      facts: {'Update': detail},
    );
  }

  bool _add(
    String key, {
    required String title,
    required String body,
    int category = 0,
    required NotificationKind kind,
    required NotificationAction action,
    String? receiptId,
    String? amount,
    String? status,
    String? asset,
    Map<String, String> facts = const {},
  }) => inbox.insert(
    InboxNotification(
      id: '$_accountId:$key',
      title: title,
      body: body,
      time: '',
      day: '',
      category: category,
      createdAt: _clock(),
      kind: kind,
      action: action,
      receiptId: receiptId,
      amount: amount,
      status: status,
      asset: asset,
      facts: Map.unmodifiable(facts),
    ),
  );

  Map<String, Object?> exportState() => {
    'version': 1,
    'accountId': _accountId,
    'seen': _seen.toList(),
    'inbox': inbox.exportState(),
  };

  /// Caller supplies the active session generation; stored generations are never trusted.
  void restoreState(
    String accountId,
    int generation,
    Map<String, Object?> data,
  ) {
    if (data['accountId'] != accountId) {
      throw ArgumentError('Notification account mismatch');
    }
    if (data['version'] != 1) {
      throw ArgumentError('Unsupported notification checkpoint');
    }
    final restored = Map<String, Object?>.from(data['inbox'] as Map);
    final seen = (data['seen'] as List).cast<String>().toList();
    final candidate = NotificationInbox(records: const []);
    try {
      candidate.restoreState(restored);
      if (candidate.snapshot.any(
        (item) => !item.id.startsWith('$accountId:'),
      )) {
        throw ArgumentError('Notification record account mismatch');
      }
    } finally {
      candidate.dispose();
    }
    _accountId = accountId;
    _generation = generation;
    _seen
      ..clear()
      ..addAll(seen);
    inbox.restoreState(restored);
  }
}
