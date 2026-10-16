# Account notification experience, build 49

The inbox uses Davochain blue, white/light-gray surfaces and existing branded receipt assets. Compact rows group notifications by local calendar day; category filters, unread dots, the settings gear and contextual detail actions support scanning. Detail pages show the actual status, amount and safe transaction facts, or the verification next step. Both themes use existing DavoColors. Text scales, long facts wrap, and actions remain inside the safe, scrollable page.

## Integration

- Mount `ref.watch(notificationEventBridgeProvider)` once from `AccountBootstrap`.
- After final registration fields and ledger session are assigned, call `NotificationEventCoordinator.instance.activate(accountId, generation)`, then `.welcome(accountId, generation, firstName: profile.firstName)`. Welcome is explicit; opening an old account cannot generate one.
- Save `.exportState()` as an optional account checkpoint `notifications` field. Restore with `.restoreState(accountId, generation, data)` after the account session is restored and before mounting the bridge. Absent old checkpoint field starts empty. Reject mismatched/malformed checkpoints before restoring account state; a temporary coordinator/inbox can prevalidate.
- Observe `NotificationInbox.instance` for read/unread and new-event persistence. Notification delivery never changes funds. Existing deterministic event IDs plus saved seen IDs preserve read decisions during receipt replay.
- Legacy receipt history is baselined only when activating a different account without a notification checkpoint. Same-account restored checkpoints replay unseen committed statuses, including a completion committed after the last inbox save.

The coordinator rejects stale account/generation callbacks. The bridge listens to committed repository receipt records, checks `needsSave`, and checks the existing transaction/security channel and individual category preferences. Disabled events are consumed without later backfilling. No email, SMS, remote push, rewards, prices or credits are invented.

`basicSubmitted` emits **Basic profile completed**, with submitted status and the existing advanced-verification action. `advancedSubmitted` emits **Advanced verification submitted**. Existing `basicVerified` aliases submission and is intentionally not observed as approval. Future authoritative review adapters may call `verification(... status: NotificationVerificationStatus.verified)`; the local bridge never does so.

## Verification

Run centrally with the serialized SDK slot:

```
flutter test test/notification_events_test.dart test/notification_bridge_test.dart test/notification_experience_test.dart
flutter analyze
flutter test
```

Tests cover event types, operation/status deduplication, account/generation isolation, category preferences, restored read/unread state, missed-completion replay, atomic invalid-checkpoint rejection, honest verification status, gear navigation and large-text light/dark welcome navigation. Existing fixture-based tests should explicitly seed `previewNotifications`; the application singleton and account reset are empty until real account events arrive. Standalone `NotificationInbox()` retains its legacy default fixture constructor for compatibility.

## Integration completed in build 50

AccountBootstrap mounts the Riverpod event bridge. Registration emits a welcome after final profile assignment. LocalAccountPersistence saves the optional notification envelope and read/seen state with the account, prevalidates it before replacing an account, restores it with the new session generation, and observes inbox changes. Earlier checkpoints remain readable. The old fixed notification filter helper was removed. Fixture-based tests now seed their records explicitly; production accounts receive only their own events.

The requested parallel implementers completed their source changes. A fresh review agent could not run because its service usage allowance was exhausted; the primary agent reviewed integration, account isolation, restart deduplication, disabled-event persistence and CTA routing directly. No review success is claimed from the failed agent.

Combined build-50 verification: 700 tests passed, 16 existing platform skips; source analyzer reported no issues. Focused UI regressions passed for gear navigation, read state, large-text light/dark welcome CTA and transaction-history navigation.
