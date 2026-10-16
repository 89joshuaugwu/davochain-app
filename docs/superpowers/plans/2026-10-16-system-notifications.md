# Android System Notifications Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Use subagent-driven-development only when separately authorized. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Deliver real Android notification-shade alerts from accepted Davochain events, with contextual permission, private content, correct taps and a backend-independent test path.

**Architecture:** Extend the existing account-scoped event coordinator into durable inbox and phone-delivery projections. An injected Android gateway renders native notifications; a persisted outbox owns deduplication and stable IDs. Typed tap intents pass through restore/unlock before existing routes. No notification code mutates financial state.

**Tech Stack:** Flutter/Dart, Riverpod, current SQLite account store; proposed flutter_local_notifications stable 22.3.2 (reverify and pin at execution); Android native channels. No Firebase/backend addition in this phase.

**Spec:** [Analysis and proposed design](../specs/2026-10-16-system-notifications-design.md).

## Global Constraints

- This is a proposed next implementation. Build 52 contains only the unlock-theme fix, not system notifications or PIN reset changes.
- Preserve blue/white identity inside the app; Android owns native notification geometry and fonts.
- No pending-deposit history/inbox/phone alert; preserve the underlying pending operation.
- Permission, OS channel state and delivery preferences never delete accepted inbox/financial records.
- Never place PINs, OTPs, credentials, identity media, full bank numbers or wallet addresses in text/payload/logs.
- No financial success from a scheduled timer in the notification layer. No inferred remote login, KYC approval, reward or support reply.
- No arbitrary payload routes/URLs, no silent account switching, no unlock bypass, no exact alarms/full-screen intents/DND bypass.
- Upgrade retains accounts, existing inbox read state, receipts and balances. Do not clear app data to make tests pass.
- Android delivery only in this phase; non-Android gateway is safe unsupported/no-op, not a claim of iOS support.

## Review Focus

1. Process dies between OS post and delivery checkpoint: reconcile active IDs; suppress a missing ambiguous attempt instead of replaying a possibly dismissed alert. Never change funds.
2. Account switches during asynchronous permission/show/tap: old account content must never appear in the new session.
3. Existing install grants permission after months of activity: no burst of historical or denied-period events.
4. System settings revoke permission/block one channel: UI must show effective state; inbox remains usable.
5. Pending financial operation outlives process: no guessed completed alert before repository commits an outcome.

## Ownership and file map

New files under `lib/features/notifications/`: `notification_domain_event.dart` (typed facts/targets), `notification_preferences.dart` (account preference model), `notification_delivery_store.dart` (outbox/IDs), `device_notification_gateway.dart` (platform boundary), `android_notification_gateway.dart` (plugin adapter), `notification_delivery_policy.dart` (pure eligibility/style mapping), `notification_delivery_controller.dart` (serialized delivery), `notification_permission_controller.dart` (installation permission), `notification_tap_router.dart` (safe navigation), `notification_enable_sheet.dart` (invitation), `notification_test_action.dart` (diagnostic only).

Extend existing `notification_events.dart`, `notification_inbox.dart`, `notification_providers.dart`, `features/wallets/local_account_persistence.dart`, `local_ledger_store.dart` and `local_ledger_migrations.dart`. Reuse existing account scope, app navigation, unlock gate and notification destinations. Modify profile Notification Settings/Preferences to bind the new model instead of mutable static arrays. Add Android drawable `ic_davo_notification.xml`, manifest permission and required Gradle plugin setup. Keep financial screen edits limited to accepted domain-event hooks where a service lacks an event API.

### Task 1: Separate event capture, inbox preferences and phone delivery

**Files:** Create domain event/preferences/delivery store files above; modify existing coordinator/bridge/inbox and wallet persistence/migrations. Tests: `test/notification_domain_event_test.dart`, `test/notification_delivery_store_test.dart`, `test/notification_events_test.dart`, `test/notification_bridge_test.dart`, `test/providers/local_account_persistence_test.dart` (use actual existing persistence test location if different).

**Interfaces:**
- `NotificationDomainEvent { String id, accountId, sourceId; NotificationEventKind kind; DateTime occurredAt; NotificationTarget target; Map<String,String> safeFacts; }` with versioned codec and immutable facts.
- `NotificationPreferences { topicEnabled(kind), phoneEnabled(channel), showPhoneDetails }`; default marketing phone delivery off.
- `NotificationDeliveryStore.enqueue(event, disposition)`, `allocateNativeId(accountId,eventId)`, `markPosting`, `markPosted`, `markSuppressed`, `pending(accountId)`, `cancelAccount(accountId)`; allocate integer IDs transactionally and preserve across restart.
- Coordinator consumes a committed typed event once; exposes durable eligible events independently of inbox read state. Baseline old receipts/inbox as historical on migration; preserve existing stable keys and use operation/attempt IDs for repeat security/verification events.

- [ ] Write failing tests: OS/push disabled still keeps the inbox; suppressed pending deposit remains consumed; preferences survive restart per account; historical inbox does not enqueue phone posts; two PIN resets have distinct IDs; exact receipt text never recalculates.
- [ ] Run those tests and record the expected failures.
- [ ] Implement backward-compatible migration, account-scoped preferences and outbox checkpoints. Add `NotificationInbox.dismiss(id)` only if needed for inbox controls; dismissal must be separate from event-consumed/phone delivery state.
- [ ] Run targeted new tests plus existing notification/persistence suites. Include malformed migration rollback, missing optional fields and isolated accounts. Expected: pass, unchanged financial records.
- [ ] Review and commit `refactor: separate inbox events from phone delivery`.

### Task 2: Native gateway, channels and pure presentation policy

**Files:** Create gateway/adapter/policy files, Android drawable, modify `pubspec.yaml`, lockfile, manifest and Gradle file as required. Tests: `test/device_notification_policy_test.dart`, `test/android_notification_gateway_test.dart` using an injected platform fake.

**Interfaces:**
- `DeviceNotificationGateway.initialize(onTap)`, `readPermission()`, `requestPermission()`, `openSettings({channelId})`, `show(DeviceNotificationRequest)`, `cancel(int id)`, `cancelAccount(String accountId)`, `readLaunchIntent()`.
- `DeviceNotificationRequest` carries allocated native ID, stable tag/group, channel ID, private/public copy, event time, typed safe payload, silent/onlyAlertOnce and autoCancel.
- `NotificationDeliveryPolicy.evaluate(event, preferences, permission, appVisibility, openTarget)` returns `post(request)`, `suppress(reason)` or `unavailable(reason)` with no side effects.

- [ ] Write failing tests for each channel/style in the spec, private default/opt-in amounts, foreground silence, same-visible-target suppression, pending deposit exclusion, generic lock-screen copy and no forbidden fields.
- [ ] Run and observe failures; verify plugin version/SDK/Gradle requirements against official package sources before adding the pinned dependency. Current Android compile/target 36 is already present.
- [ ] Implement monochrome small icon, native BigText, channel defaults and only permissions required by used features. Do not copy the plugin example's entire manifest. No scheduled financial notifications.
- [ ] Run fake-platform tests, release-build resource checks and an explicit device smoke check for the real shade entry (widget plugin no-ops are insufficient evidence). Verify notification icon survives resource shrinking.
- [ ] Review and commit `feat: add native Android notification delivery gateway`.

### Task 3: Permission invitation and effective Settings state

**Files:** Create permission controller/enable sheet/test action; modify `AccountBootstrap` initialization (no permission side effect in build), dashboard settled entry, profile notification Settings/Preferences. Persist invitation metadata per installation and preferences per account. Tests: `test/notification_permission_flow_test.dart`, `test/notification_settings_state_test.dart`.

**Interfaces:**
- `NotificationPermissionState { unsupported, notRequested, granted, denied, restricted }` plus per-channel blocking; refresh from OS on app resume.
- `NotificationPermissionController.enableFromUserAction()`; one concurrent request; state reflects actual result, not switch intent.
- `NotificationTestAction.sendNow()` posts a diagnostic event excluded from inbox/history/ledger. Optional development-only inexact delayed test is cancellable and clearly labelled.

- [ ] Write failing widget tests: signup invitation after stable dashboard/Explore, never during OTP/unlock; Not now remembered; Enable invokes exactly one real gateway request; denied/swiped-away remains off; Settings opens OS settings and rechecks on return; pre-13 has no fake prompt.
- [ ] Run tests to RED.
- [ ] Implement invitation and Settings bindings using existing shared UI. Keep in-app notifications independent, clarify Email/SMS are future preferences without pretending those transports send messages. Do not change email/SMS integration as part of this task.
- [ ] Run tests to GREEN; device-test allow, deny and dismiss on Android 13+, plus revoked permission/channel block. Keep app usable with all delivery denied. Explicit test notification routes back to Settings and changes no balance/history.
- [ ] Review and commit `feat: request phone notification permission in context`.

### Task 4: Durable delivery and secure taps in every lifecycle

**Files:** Create delivery controller/tap router, extend notification providers/persistence and auth handoff integration; reuse `notificationDestination`. Tests: `test/notification_delivery_controller_test.dart`, `test/notification_tap_router_test.dart`.

**Interfaces:**
- `NotificationDeliveryController.drain(AccountSession session)` serializes queued events, checkpoints a posting attempt before dispatch, checkpoints outcome and reconciles native IDs; account guards before/after each awaited boundary.
- `NotificationTapRouter.accept(NotificationTapIntent)`, `resumeAfterUnlock(AccountSession)`, `clearForAccountChange()`; only event/account/version in raw payload, target reloaded from store.
- Tap acknowledgement marks one item read and cancels its native item only after account/target validation; normal unlock remains authoritative.

- [ ] Write failing tests for all five Review Focus scenarios; active/background/cold-start taps; malformed payload; deleted receipt; locked account; account mismatch; double taps; cancel on logout; post failure does not affect financial commit.
- [ ] Run tests to RED with fake store/gateway/clock and controllable futures.
- [ ] Implement durable queue processing; on an interrupted posting attempt reconcile active IDs, acknowledge a matching visible notification and suppress missing ambiguous IDs rather than reposting a possibly dismissed alert. Use onlyAlertOnce only for updates to an existing visible item. Keep no replay of dismissed/suppressed history, and safe deferred target routing through restore/unlock. Avoid event regeneration from display widgets.
- [ ] Run to GREEN, including killed-after-show-before-checkpoint recovery and post -> crash -> swipe away -> restart (no repost). Document the intentional possible missed alert in an ambiguous crash window; do not claim exactly-once OS delivery. Once granted after denial, only future events and explicit diagnostic tests post. No financial timer fires in the notification subsystem.
- [ ] Review and commit `feat: persist notification delivery and guard deep links`.

### Task 5: Connect genuine local event sources and preserve quiet interactions

**Files:** Extend coordinator/bridge; introduce focused service event adapters where needed for password/PIN/biometric/security questions/bank changes. Existing source files: `core/preview/preview_auth_state.dart`, `core/preview/settings_preview_session.dart`, `features/security_questions/security_questions_service.dart`, profile `settings_personal_action_flows.dart`, `profile_pin_screens.dart`, `fingerprint_settings_screen.dart`, `settings_action_flows.dart`. Do not make unrelated UI redesigns. Tests: `test/notification_event_coverage_test.dart`, existing settings/auth/payment/receipt tests.

**Interfaces:** Accepted domain mutation emits an event with account ID, runtime generation, operation ID and safe facts. No secrets in event arguments. Financial events remain repository-derived; UI screens do not post directly. Future support/KYC/login/reward adapters use the same contract, with deterministic fixtures only in tests/development diagnostics.

- [ ] Parameterize tests from every row in the spec's event inventory: expected inbox/phone/silent/suppressed result and exact typed destination.
- [ ] Run to RED. Include failed gateway mutations, cancelled routes, repeated listeners and a second actual security change in the same session.
- [ ] Wire available accepted local outcomes, with explicit suppression for routine unlock, deposit initiation, own support messages, copy/share/refresh and validation errors. Keep real remote sources deferred; no fabricated approvals/replies.
- [ ] Run to GREEN, then existing receipt/funds/auth/settings suites. Assert no changed ledger total or settled status from delivery and one alert per actual operation/status.
- [ ] Review and commit `feat: connect accepted account events to phone alerts`.

### Task 6: Device acceptance, screenshots and release evidence

**Files:** QA evidence under workspace `review/evidence/system-notifications`; maintain `docs/system-notifications-implementation.md`. Optional instrumented tests under `integration_test/notification_delivery_test.dart` if reliable on current Flutter/device harness.

- [ ] Run focused unit/widget suites, full regression suite and `flutter analyze`; build optimized APK with existing release helper and increment version only at implementation release time.
- [ ] Test Android below 13 if available and API 33+ emulator; connected phone manufacturer UI; system/app light and dark; large text. Record unavailable targets rather than claiming coverage.
- [ ] Fresh permission state: allow/deny/swipe away; never clear financial app data to reset permission. Use documented adb permission flags on emulator only and restore test settings afterwards.
- [ ] Exercise real completed deposit/trade, accepted withdrawal failure, security change, test notification; inspect collapsed/expanded/locked shade. Verify swipe removal, sound/DND behavior, grouped burst without duplicate summary sounds.
- [ ] Exercise tap while foreground/background/locked/cold-start, account switch/logout, stale payload and missing record. Verify correct receipt after unlock, no cross-account disclosure, no repeated navigation.
- [ ] Force process death with an accepted pending transaction: verify no false completed phone alert. Use a separate delayed diagnostic to test scheduled native background delivery; confirm it has no ledger/inbox side effect. Record the no-backend limits honestly.
- [ ] Independent review, fix important findings, package/hash/signature evidence and installation preserving account data. Update implementation doc with exact results and remaining device gaps.
- [ ] Commit `test: verify Android notifications across permissions and lifecycle`.

## Explicit next-step boundaries

The next implementation should follow these tasks after this proposed design is accepted. Do not silently add backend messaging, market alerts or remote-login detection. PIN reset stepper is recommended in the companion analysis, but requires its own small implementation task/test cycle after the user chooses it; do not mix recovery behavior changes into phone-delivery work.

## Primary sources checked

- [Android permission and denial behavior](https://developer.android.com/develop/ui/compose/notifications/notification-permission)
- [Android channels and user control](https://developer.android.com/develop/ui/compose/notifications/channels)
- [Native presentation and lock-screen privacy](https://developer.android.com/develop/ui/compose/notifications/create-notification)
- [flutter_local_notifications setup and tap handling](https://pub.dev/packages/flutter_local_notifications)
