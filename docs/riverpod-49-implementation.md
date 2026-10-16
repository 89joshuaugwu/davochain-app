# Riverpod account-state implementation, build 49

User authorized the migration on 16 October 2026 and confirmed there is no backend. Customer screens retain normal product wording.

## Ownership and data flow

- Root DavoAccountScope owns a Riverpod container; accountSessionProvider tracks account ID and generation. Wallet adapters publish exact immutable WalletSnapshot values. Derived portfolio state excludes cash and zero allocations.
- Modern NotifierProvider subscriptions adapt existing native/device/profile/KYC/settings services. Dashboard/Portfolio and financial/provider consumers update from shared streams. The device appearance provider lives outside account reset. Local form, focus, scroll, animation and visibility state remains in widgets.
- LocalTransactionRepository owns receipt identity, pending timers, exact reservation/settlement and SQLite checkpoints. ReceiptActivity is retained as a compatibility facade, not a second ledger. TransactionController exposes submitting/pending/completed/failed/unknown command state and never submits in provider build. A timeout/failed save does not trigger a new payment submission. Financial changes are staged, saved atomically, then published. A failed save stops settlement and shows an account-update-pending outcome; reconciliation saves the same operation identity.
- Quotes come through QuoteSource -> QuoteRepository -> Riverpod -> wallet valuation. Riverpod does not fetch or invent exchange prices. The default source is the dated saved CoinGecko snapshot; an injected stream can publish newer observations. No fake ticks or silently advertised live API.
- Review steps freeze buy amounts, unit price and USD rate. Sell/swap review retains displayed source/destination rates. Reviews also carry account ID and generation, so switching accounts blocks old confirmations. A changed/expired quote blocks confirmation; accepted receipt effects retain exact units across later price updates.

## Storage and account sessions

SQLite stores one account checkpoint containing wallet available/reserved units, settled/rejected identities, receipts and display profile. Account and operation rows are committed in one transaction. Atomic quantities are decimal integer strings with explicit asset precision. Account IDs are unique across registrations; operation identity is unique per account. Writes reject older checkpoint revisions. Quote identity, observation time and expiry are stored alongside their prices.

Startup restores the active account and pending local operations reconcile once using their original submission time. Existing email login can select saved local account data. Login restoration is guarded against cancelled routes, overlapping requests and account switches. Sign-out flushes/deactivates the account and invalidates wallet, receipt and verification state; appearance remains device-wide. Passwords, raw transaction PINs, biometric credentials and verification-media files are not stored in this database. Payment PIN remains session-owned and can be reset through the existing flow after restart.

This remains local presentation behavior, not backend authentication or bank/chain/exchange settlement. Existing static domain/read APIs and native service implementations remain compatibility adapters; a future backend adapter replaces repository implementations without changing provider consumers.

## Versions and research

Pinned flutter_riverpod 3.4.3 and sqflite 2.4.4+2, tested with sqflite_common_ffi 2.4.4. Their published requirements raise the project floor to Dart 3.12 / Flutter 3.44; installed SDK is Flutter 3.47.1 / Dart 3.13.1. Dart formatting follows the new language version for touched files.

Primary sources checked 16 October 2026:
- https://riverpod.dev/docs/concepts2/providers
- https://riverpod.dev/docs/concepts2/retry
- https://riverpod.dev/docs/how_to/testing
- https://pub.dev/packages/flutter_riverpod/versions/3.4.3
- https://pub.dev/packages/sqflite

## Verification

Provider/account/quote/command tests, actual financial-flow regressions, SQLite reservation restoration, duplicate settlement, overdue reconciliation, stored account restoration, sign-out and appearance isolation are covered. Full-suite, review and native release evidence is appended after final checks.

Final automated verification: 673 passed, 16 existing platform skips, zero failed; source analyzer has no issues. Additional targeted account/auth/funding suite: 38 passed. Reviewer findings were covered by account-switch, quote bootstrap, stale-review, failed-save, pending-result, stored-rate and delayed-login regression tests.

## Implementation decisions

- build-48 deferral is superseded by today's explicit user authorization; implement as build 49.
- preserve legacy public facades for existing native flows/tests during migration, but route state observation/commands through Riverpod and repository adapters. No all-at-once navigation rewrite. Cost if wrong: remaining compatibility calls must be listed honestly.
- no automatic external price API calls or made-up ticks. Add injectable streaming quote source and coherent quote updates; retain the dated offline snapshot until a configured source is supplied. Cost: prices are not live network data in this release.
- use stable flutter_riverpod 3.4.3 and sqflite 2.4.4+2, verified on pub.dev; raise SDK floor to Dart 3.12 / Flutter 3.44 as these dependencies require. Installed SDK is Flutter 3.47.1 / Dart 3.13.1.
- common service adapters retain typed existing public APIs while Riverpod owns their subscriptions. This preserves camera/biometric/OTP lifecycle; not replacing native service ownership with UI providers.
- keep local-only account identity/receipt facades for compatibility, not a claim of backend authentication. Do not persist PINs/passwords or verification media. Account restore opens the existing unlock route; payment PIN remains session-owned and can be reset through existing flow.
- durable financial commands stage the existing exact ledger rather than replace its arithmetic; legacy synchronous APIs remain compatibility facades and dispatch durably when storage is attached. Cost if wrong: legacy consumers require continuing regression coverage.

No deferred minor review findings. Native release results follow below.

Build 50 includes the subsequently requested notification event/UI and trade-card refinements. The combined suite passed 700 tests, with 16 existing platform skips; source analyzer reported no issues. The initial build-49 release was built and installed successfully before this added scope.

## Final release evidence, 16 October 2026

Version 0.19.1+50, package com.example.davochain. Release APK built successfully and installed using adb install -r, preserving emulator data. APK SHA-256: DDDEC57BBDC0187C5BA423F433EC93F35B90E0A16A0C86F3126120CD806889C6. Certificate SHA-256: d0de9b8311199a2eb6a238d106b45eaa9d30fe4ef0ef7b9b5808edc3988e2411. Development signing is unchanged.

Native checks on emulator-5554: created Release Fifty account; dashboard and crypto assets zero; one welcome notification; read state updates; Get started opens Basic Verification; gear opens Notification Settings. Added NGN100000, force-stopped while pending, reopened through returning unlock: same account restored, NGN100000 credited once, pending and completed notices present, welcome remains read. Deposit notice opens the matching receipt. Buy/Sell/Swap card alignment and percentage widths inspected and captured. Cash deposit leaves crypto-only Portfolio zero. Automated suites cover completed buy/sell/swap/gift/withdrawal effects, quote invalidation, insufficient balances, save failures and stale callbacks; those complete financial flows were not all repeated manually on this release.

Phone CI49FIXKM7BUOVA6 was not listed by ADB at final check; phone installation remains outstanding until connected. Only emulator installation is claimed. No app data was cleared. Emulator initially had system launcher/UiAutomation timeouts; cold boot with existing data resolved them.

Evidence: workspace review/evidence/riverpod-migration-49, including full-suite/analyzer/build logs and emulator screenshots/XML. APK copied to both worktree and main project build/app/outputs/flutter-apk/app-release.apk with matching hash.
