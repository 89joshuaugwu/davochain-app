import 'package:davochain/features/notifications/notification_events.dart';
import 'package:davochain/features/notifications/notification_inbox.dart';
import 'package:davochain/shared/receipts/receipt_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late NotificationInbox inbox;
  late NotificationEventCoordinator events;
  final now = DateTime(2026, 10, 16, 12);
  ReceiptRecord receipt(
    String id, {
    String type = 'Deposit',
    ReceiptStatus status = ReceiptStatus.completed,
  }) => ReceiptRecord(
    id: id,
    reference: 'REF-$id',
    type: type,
    status: status,
    occurredAt: now,
    amount: '10 USDT',
    fields: const [
      ReceiptField(label: 'Asset', value: 'USDT'),
      ReceiptField(label: 'Bank account', value: '1234567890', sensitive: true),
    ],
  );
  setUp(() {
    inbox = NotificationInbox(records: const []);
    events = NotificationEventCoordinator(inbox: inbox, clock: () => now);
    events.activate('account-a', 1);
  });
  tearDown(() => inbox.dispose());

  test(
    'new account welcome has a useful verification action, once per account',
    () {
      expect(events.welcome('account-a', 1, firstName: 'Ada'), isTrue);
      expect(events.welcome('account-a', 1, firstName: 'Ada'), isFalse);
      expect(inbox.snapshot.single.title, 'Welcome to Davochain, Ada');
      expect(
        inbox.snapshot.single.action,
        NotificationAction.basicVerification,
      );
      expect(inbox.snapshot.single.kind, NotificationKind.welcome);
      expect(inbox.snapshot.single.createdAt, now);
      expect(inbox.snapshot.single.body, isNot(contains('credited')));
    },
  );

  for (final type in [
    'Deposit',
    'Withdrawal',
    'Purchase',
    'Crypto sale',
    'Swap',
    'Gift card purchase',
    'Gift card sale',
  ]) {
    test('$type uses committed amount, reference and receipt identity', () {
      final record = receipt(type, type: type);
      expect(events.receipt('account-a', 1, record), isTrue);
      final notification = inbox.snapshot.single;
      expect(notification.receiptId, record.id);
      expect(notification.amount, record.amount);
      expect(notification.facts['Reference'], record.reference);
      expect(notification.facts.containsKey('Bank account'), isFalse);
      expect(notification.action, NotificationAction.receipt);
      expect(notification.category, 1);
      expect(events.receipt('account-a', 1, record), isFalse);
    });
  }

  test(
    'pending, completion and failure each deduplicate by operation and status',
    () {
      for (final status in ReceiptStatus.values) {
        events.receipt('account-a', 1, receipt('one', status: status));
        events.receipt('account-a', 1, receipt('one', status: status));
      }
      expect(inbox.snapshot.length, 3);
      expect(inbox.snapshot.map((n) => n.status).toSet(), {
        'Pending',
        'Completed',
        'Failed',
      });
      expect(
        inbox.snapshot.where((n) => n.status == 'Pending').single.title,
        'Deposit in progress',
      );
    },
  );

  test(
    'preferences suppress events without replaying them when re-enabled',
    () {
      expect(
        events.receipt('account-a', 1, receipt('off'), enabled: false),
        isFalse,
      );
      expect(events.receipt('account-a', 1, receipt('off')), isFalse);
      expect(inbox.snapshot, isEmpty);
    },
  );

  test(
    'account and generation switches reject old callbacks and clear old account',
    () {
      events.welcome('account-a', 1, firstName: 'Ada');
      events.activate('account-b', 2);
      expect(inbox.snapshot, isEmpty);
      expect(events.receipt('account-a', 1, receipt('stale')), isFalse);
      events.activate('account-b', 3);
      expect(
        events.receipt('account-b', 2, receipt('old-generation')),
        isFalse,
      );
      expect(events.receipt('account-b', 3, receipt('new')), isTrue);
    },
  );

  test(
    'legacy baseline does not invent credits when opening an existing account',
    () {
      events.activate('legacy', 2, baseline: [receipt('old')]);
      expect(events.receipt('legacy', 2, receipt('old')), isFalse);
      expect(inbox.snapshot, isEmpty);
      expect(events.receipt('legacy', 2, receipt('new')), isTrue);
    },
  );

  test('read state and event IDs survive restore and receipt replay', () {
    final record = receipt('saved');
    events.receipt('account-a', 1, record);
    inbox.markRead(inbox.snapshot.single.id);
    final checkpoint = events.exportState();
    events.activate('other', 2);
    events.restoreState('account-a', 3, checkpoint);
    events.activate('account-a', 3, baseline: [record]);
    expect(events.receipt('account-a', 3, record), isFalse);
    expect(inbox.snapshot.length, 1);
    expect(inbox.snapshot.single.isRead, isTrue);
    expect(inbox.unreadCount, 0);
    inbox.markUnread(inbox.snapshot.single.id);
    final unread = events.exportState();
    events.restoreState('account-a', 4, unread);
    expect(inbox.unreadCount, 1);
  });

  test(
    'restored checkpoint replays a committed status missing at checkpoint time',
    () {
      final pending = receipt('recover', status: ReceiptStatus.pending);
      events.receipt('account-a', 1, pending);
      final saved = events.exportState();
      events.restoreState('account-a', 2, saved);
      final completed = receipt('recover');
      events.activate('account-a', 2, baseline: [completed]);
      expect(events.receipt('account-a', 2, completed), isTrue);
      expect(events.receipt('account-a', 2, completed), isFalse);
      expect(inbox.snapshot.length, 2);
    },
  );

  test('bad checkpoints do not partially mutate the active inbox', () {
    events.welcome('account-a', 1, firstName: 'Ada');
    final before = events.exportState();
    expect(
      () => events.restoreState('account-a', 2, {
        ...before,
        'seen': [42],
      }),
      throwsA(anything),
    );
    expect(events.exportState(), before);
    expect(() => events.restoreState('other', 2, before), throwsArgumentError);
    expect(events.exportState(), before);
    final invalid = {
      ...before,
      'inbox': {'version': 1, 'records': [], 'unreadCount': 'invalid'},
    };
    expect(
      () => events.restoreState('account-a', 2, invalid),
      throwsA(anything),
    );
    expect(events.exportState(), before);
  });

  test(
    'submission does not claim verification; real approval can invite advanced',
    () {
      events.verification(
        'account-a',
        1,
        advanced: false,
        status: NotificationVerificationStatus.submitted,
      );
      final submitted = inbox.snapshot.single;
      expect(submitted.title, 'Basic profile completed');
      expect(submitted.status, 'Submitted');
      expect(submitted.body, isNot(contains('confirmed')));
      expect(submitted.action, NotificationAction.advancedVerification);
      events.verification(
        'account-a',
        1,
        advanced: false,
        status: NotificationVerificationStatus.verified,
      );
      expect(inbox.snapshot.first.title, 'Basic verification complete');
      expect(
        inbox.snapshot.first.action,
        NotificationAction.advancedVerification,
      );
      expect(inbox.snapshot.length, 2);
    },
  );

  test('advanced submission and attention updates show truthful status', () {
    events.verification(
      'account-a',
      1,
      advanced: true,
      status: NotificationVerificationStatus.submitted,
    );
    expect(inbox.snapshot.single.title, 'Advanced verification submitted');
    expect(inbox.snapshot.single.status, 'Submitted');
    events.verification(
      'account-a',
      1,
      advanced: true,
      status: NotificationVerificationStatus.needsAttention,
    );
    expect(inbox.snapshot.first.status, 'Action needed');
    expect(inbox.snapshot.first.action, NotificationAction.basicVerification);
  });
}
