# Davochain phone notifications: analysis and proposed design

Status: proposed for the next implementation, not implemented in build 52. Research checked 16 October 2026. Scope: Android notification shade, lock screen, optional heads-up banners and their connection to the existing inbox. Preserve Davochain's visual identity. PIN reset recommendation is separate and is not authorization to change recovery yet.

## Existing state and gaps

- `notification_events.dart` creates stable, account-scoped welcome, receipt-status and verification inbox items. `notification_providers.dart`, mounted in `AccountBootstrap`, observes committed repository receipts and verification transitions with session-generation guards. Receipt events bypass records with uncertain checkpoint saves.
- `notification_inbox.dart` persists records/read state through `LocalAccountPersistence`. Build 51 removes pending-deposit presentation and migrates saved initiation alerts away.
- There is no system notification plugin or POST_NOTIFICATIONS declaration in the current app manifest. Existing Push toggles are preferences, not evidence that Android permission exists or delivery works.
- Topic preferences are eleven mutable booleans; channel preferences are three lists for transaction/security/marketing. The event bridge currently gates creation of inbox records using the push preference. This must be separated: OS permission or phone delivery opt-out must not remove the in-app audit record. Preferences also need explicit account-scoped persistence rather than relying on static lists.
- The notification category model has All/Transactions/Security/Rewards. Verification uses Security. Support, service messages and announcements must not be misleadingly forced into Rewards: introduce an Updates category only when its first real source is enabled, retaining existing category IDs and migrating by stable name.
- Existing financial command, profile, auth, bank and support APIs supply local outcomes. They cannot detect a real login on another device, actual remote deposits, support replies or KYC approval without a backend.

## UX: permission without interruption

1. Initialize channels and read OS status silently; do not ask at splash, email OTP, PIN entry, camera permission or unlock.
2. After signup and Explore reaches a stable first dashboard, show one compact invitation: **Stay informed** / **Get deposit, transaction and security updates on your phone.** Actions **Enable notifications** and **Not now**. Returning accounts see it at their next stable dashboard, once per installation; dismissal is remembered. This uses existing surfaces, not another onboarding page.
3. Enable opens the real Android permission dialog on Android 13+ when eligible. On older Android versions, check system notification enablement instead of promising a runtime prompt. Do not interpret a dismissed OS dialog as granted.
4. Denied/restricted/channel-blocked state remains visible in Settings: **Phone notifications are off** with **Open phone settings**. Do not repeatedly call the prompt on every launch. Refresh status when returning from system settings. Never require notifications to trade or use the account.
5. Keep the existing preferences screen and channel screen, but show their effective state. A master switch must not appear successfully enabled while OS permission is denied. Rename the current Push label to **Phone notifications** with helper text; backend push transport can be added later without changing this vocabulary.
6. Add **Send test notification** in Notification Settings, explicitly user-triggered. It sends **Davochain notifications are ready** with **Tap to return to notification settings.** It has no money, no receipt, and creates no account activity. A diagnostic-only delayed variant supports background/closed-app QA, without fake financial credits.

Android 13+ permission is a real OS choice; the app cannot force a dialog after a permanent refusal. Source: [runtime permission](https://developer.android.com/develop/ui/compose/notifications/notification-permission).

## Appearance and interaction

Use standard native notification templates. Android and the phone manufacturer own layout, font, corner radius, system light/dark styling and heads-up eligibility. Davochain owns the monochrome small-logo drawable, blue accent, concise title/body, timestamp, grouping and action labels. No blue full-card background, copied in-app card, large promotional artwork or custom font inside the shade.

Collapsed: Davochain icon/name, event title, one clear body line and event time. Expanded: BigText for longer transactional/security copy; MessagingStyle only for actual future support messages with sender/thread identity. No receipt screenshots in financial alerts. Use BigPicture only for a real, opted-in future campaign, never a fabricated balance or prize.

All financial notifications are normally dismissible, auto-cancel when opened, and never ongoing/sticky. A swipe removes the phone alert only; it does not delete history or the inbox item and does not mark the item read. A successful tap marks the matching inbox item read, cancels that native item, then opens its target after any required unlock. Opening the item from the inbox also cancels its native counterpart. Keep grouping quiet: one group per account plus category, summary only when needed, no extra summary sound. Duplicate statuses update the same event; repeated listeners/restarts never produce additional alerts.

Privacy default: generic title/body on the lock screen and notification shade unless the user enables **Show transaction details in phone notifications**. Example private default: **Deposit received** / **Your wallet has been credited. Open Davochain for details.** Opt-in unlocked detail: **NGN100,000.00 was added to your Naira wallet.** Use exact receipt display amounts; never recalculate. Configure private visibility and a generic public version. Never include PINs, OTPs, passwords, full bank numbers, wallet addresses, identity documents or security answers in notification text, payload or logs. User/device visibility settings ultimately control lock-screen presentation. Source: [notification privacy](https://developer.android.com/develop/ui/compose/notifications/create-notification).

## Channels and interruption policy

| Stable channel | Purpose | Initial importance | Behavior |
| --- | --- | --- | --- |
| `davo_transactions_v1` | Deposit/withdrawal/trade outcomes | Default | Shade, normal device sound; no promised heads-up |
| `davo_security_v1` | Confirmed sensitive account changes | High | Heads-up eligible, normal vibration; no full-screen intent or DND bypass |
| `davo_account_v1` | Verification/account updates | Default | Shade; quiet foreground behavior |
| `davo_support_v1` | Future actual replies | Default | Thread grouping; no automatic generated replies |
| `davo_updates_v1` | Opted-in product/reward updates | Low | Silent; campaigns opt-in by default |
| `davo_diagnostics_v1` | User-triggered notification test | Default | Separate from account activity; delayed QA test can be cancelled |

Normal foreground transactions still create one shade entry silently, while the existing result/banner handles immediate feedback. Security changes may alert once; avoid a second toast, banner and sound for the same event. Do not suppress the persistent inbox item merely because its page is open. Suppress phone delivery when a matching receipt/thread is visibly open and unlocked, recording that decision so it does not replay later. Diagnostics always appear when explicitly tested. User OS overrides are final. Android channel importance/sound cannot be programmatically changed after creation; do not evade user settings by continually creating new channel IDs. Source: [channels](https://developer.android.com/develop/ui/compose/notifications/channels).

## Event inventory and wiring map

`I` = in-app inbox; `P` = phone notification subject to permission/preferences. Every trigger means an accepted outcome, not a button tap or screen build.

| Source / event | Delivery now | Sample title and intent | Target / hook |
| --- | --- | --- | --- |
| Account created | I; optional quiet P once, no historic replay | Welcome to Davochain | `LocalPreviewProfile.register` / coordinator.welcome; basic profile |
| Deposit address shown/copied, amount initiated | Neither | No event: no evidence of received funds | Preserve pending repository state only |
| Naira/crypto deposit completed | I + P | Deposit received | Committed receipt event; exact receipt ID |
| Deposit failed | I + P only for an accepted deposit operation | Deposit unsuccessful | Same receipt; review, no automatic retry |
| Buy, sell, swap completed | I + P | Bitcoin purchase complete / Sale complete / Swap complete | Existing receipt bridge and immutable fields |
| Buy/sell/swap pending | I if useful; no P for immediate local initiation | Transaction processing | Receipt; no success check or money claim |
| Accepted withdrawal pending | I; P only if later substantive status update | Withdrawal processing | Receipt; initiation screen already acknowledges request |
| Withdrawal completed / failed | I + P | Withdrawal complete / Withdrawal unsuccessful | Exact receipt; failure/retry details |
| Gift-card submission | I, no immediate P | Gift card submitted | Gift receipt; submitted does not mean paid |
| Gift-card completed / rejected | I + P when repository outcome changes | Gift card trade complete / Trade needs attention | Gift trade/receipt; never infer provider approval from a timer |
| Basic profile submitted | I, no immediate P | Basic profile completed | Verification bridge; not identity approval |
| Advanced submitted | I; no duplicate immediate P | Verification submitted | Verification overview; truthful ready-for-review copy |
| Verified / needs attention | Adapter + deterministic QA fixtures now; real remote source later | Verification update | Per-attempt event ID; correct Basic/Advanced route; never invent approval |
| Password successfully changed | I + P | Password changed | Accepted `SettingsGateway.changePassword`; Security settings |
| PIN successfully changed | I + P | Transaction PIN changed | Accepted `setTransactionPin` mutation via account-bound service; never include digits |
| Biometrics/security questions changed | I + P | Account security updated | Committed setting/service transition; describe app unlock vs payment separately |
| Payment PIN lockout | I + P once per lock episode | Transaction PIN temporarily locked | Fifth failure accepted by auth state; no alert per bad digit or login keystroke |
| Routine unlock/login on this phone | No alert per unlock | Avoid flooding | Existing auth journey only; new-device/remote sign-in requires backend evidence |
| Bank account linked | I + optional P | Bank account linked | After gateway success; masked last four only; Linked Accounts |
| Support request sent / user chat message | In-context confirmation; no P | User already sees their own action | Existing ticket/chat gateway; no fake incoming reply |
| Actual support reply | Future source + QA fixture | New reply from Davochain Support | Conversation ID, MessagingStyle; suppress when same chat open |
| Reward redemption accepted | I + optional quiet P only if accepted account mutation exists | Reward redemption complete | Redemption reference/receipt; no fabricated cash/points |
| Promotion/product news/education | Future opted-in content + diagnostic fixtures | Short specific content | Safe in-app destination; never arbitrary payload URL |
| Price alert/portfolio changes | Deferred | No false market alerts from dated offline quotes | Requires genuine quotes plus user-defined threshold/dedupe policy |
| Profile edits/theme toggles/copy/share/refresh/validation errors | No P | Keep local feedback | No inbox noise for routine UI actions |
| Deletion request | I while active; cancel account phone alerts on sign-out/deletion | Account request received if accepted | Never announce completed deletion before actual completion |

All current local financial receipts remain local accepted records, not a claim of bank/network confirmation. The notification layer observes them; it never settles a pending transaction, changes a balance or authorizes a payment.

## Architecture and durability

Recommend `flutter_local_notifications`, currently stable 22.3.2, behind an injectable gateway. Reverify/pin its supported version and Gradle requirements when implementation begins; no package added by this planning task. Use immediate local delivery first. Optional diagnostic scheduling uses inexact delivery; no exact-alarm, background service, battery exemption or full-screen permission is warranted. Source: [plugin](https://pub.dev/packages/flutter_local_notifications).

Refactor event creation into `NotificationDomainEvent` and two projections: durable inbox and device delivery. Fields: version, stable event ID, account ID, source ID, source revision/status, event kind, occurredAt, safe structured facts and typed target. Account generation is a runtime guard, not stored authority. Preserve existing account/status event IDs. Security/verification require per-operation/per-attempt IDs so a second genuine reset/submission is not suppressed forever.

Add a persisted delivery outbox with allocated native integer IDs (do not use Dart hashCode), state `queued/posting/posted/suppressed/failed`, attempts, dismissal/read acknowledgement, policy snapshot and processed revision. Save the accepted event and a `posting` attempt before OS delivery. Gate on active account + generation at every await, then post with a stable ID. Recover an interrupted attempt by reconciling currently active native IDs: an active matching ID is acknowledged without a new alert; if the ID is missing, mark the ambiguous attempt suppressed rather than reposting, because the user may already have swiped it away. Prefer avoiding replay over guaranteed delivery in this ambiguous case. `onlyAlertOnce` helps updates to an existing visible notification; it does not guarantee exactly-once delivery after dismissal. An OS post error known to occur before dispatch can be retried explicitly; unknown outcomes follow the ambiguous-attempt policy. Never re-post terminal/suppressed/dismissed IDs from generic receipt scans. Read status is not delivery status. Failure to display does not roll back funds or block app startup.

Store preferences per account, device permission status per installation, with backward-compatible migration. Graceful upgrade seeds existing inbox/receipts as historical, not a burst of old phone alerts. Permission newly granted does not flush old denied alerts: new events only, plus an explicit test. Persist queued delivery decisions, not secrets or arbitrary route URLs.

Tap payload contains version + account ID + event ID only, with typed target resolved from the local store. Handle foreground, background and cold-start launch details. Wait for persistence restore and the existing security-question/unlock gate. Resolve the target once per tap. If logged out, account differs, target no longer exists, or payload malformed, open a safe inbox/login state; do not switch accounts silently or expose another account's receipt. On logout/account switch cancel active and pending account notifications, invalidate queued callbacks, and clear deferred navigation. Notification removal does not mutate financial records. Future backend push adapter feeds this same event pipeline to avoid local-plus-remote duplicates.

## Testing without a backend

Real local accepted flows can produce actual Android shade notifications today. The existing Dart 20-second reconciliation timer is not a reliable background worker and does not run after process death. Do not schedule a financial success notification merely because a pending operation was initiated. In a killed-process test, pending operations remain pending until normal restore/reconciliation commits a real local outcome. A separately labelled diagnostic scheduled alert can test system delivery while backgrounded/closed without touching money. Actual remote deposits, remote KYC/support/login updates and reliable delivery of newly arriving server events while terminated are a later push/backend phase.

Test actual shade appearance and taps on emulator and the connected phone, including manufacturer styles. Automated fakes verify policy, but plugin no-op behavior in widget tests is not proof of Android delivery. Cover granted/denied/dismissed/revoked permission, per-channel blocking, foreground/locked/background/cold-start, sound/DND, light/dark and large text, swiping, double tap, account switching, restart after post/before checkpoint, post then crash then swipe then restart without repost, no historical burst and no false success after failed saves.

## PIN reset UX recommendation

Prefer **Set new PIN -> Confirm new PIN -> PIN changed** after the current recovery-code step. Four masked digit cells and the signup keypad pattern reduce keyboard clutter and align an already learned flow. Separate screens reduce simultaneous fields and make confirmation independent. One-page entry is faster for comparison, but less consistent with signup and exposes two fields to keyboard/focus mistakes.

First page: **Set your new PIN**, brief instruction, masked four-digit entry, Next only when four digits exist. Second: **Confirm your new PIN**, **Enter it again to confirm**, Confirm PIN action. A mismatch clears only confirmation and announces **PINs do not match. Try again.** Back allows editing the first PIN and clears stale confirmation. Reuse signup components, deletion behavior, contrast and reduced motion. Do not automatically save on the fourth digit. Commit once only on explicit confirmation, then emit one security event with no PIN value. Keep the first PIN only in route memory and clear both values on cancel, account change, dispose or lock; never persist it. A reveal control, if retained, is explicitly temporary and resets on backgrounding.

Keep recovery verification before entry. Current local code accepts a four-digit verification-code length and uses session-only PIN state: changing layout must not be described as stronger server-side recovery. Real OTP validation/rate limits/recovery tokens remain a backend requirement. No PIN reset implementation is included in this plan's notification tasks.

Review clarification: Android only-alert-once applies to updates of an already showing notification, so this design intentionally suppresses missing ambiguous posts after restart rather than promising exactly-once delivery. [Notification.Builder.setOnlyAlertOnce](https://developer.android.com/reference/android/app/Notification.Builder#setOnlyAlertOnce(boolean)).
