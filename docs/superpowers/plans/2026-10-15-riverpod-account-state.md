> Execution update, 16 October 2026: implemented in commits 9b3d143 and 9b7f482, released locally as 0.19.1+50 after additional notification/trade-card scope. Canonical completion, compatibility decisions and exact validation coverage: [implementation record](../../riverpod-49-implementation.md). 700 tests passed, 16 existing skips; source analyzer clean; release built and installed/tested on emulator. Phone absent, so phone installation remains pending. Original step checkboxes below describe the planning sequence; the execution record documents the approved compatibility and offline-price deviations.

# Riverpod Account State Implementation Plan

> **For agentic workers:** Use superpowers:executing-plans to implement this plan task by task. This document is a future migration plan, not authorization to begin the migration in build 48.

**Goal:** Replace shared mutable account singletons with account-scoped Riverpod state while preserving the tested wallet and receipt behavior.

**Architecture:** Repositories own exact amounts, transaction settlement and storage. Riverpod exposes repository streams and derived view state to widgets; explicit command controllers submit transactions. Session replacement disposes the previous account scope and prevents late responses from updating another account.

**Tech Stack:** Flutter/Dart, current stable compatible flutter_riverpod 3.x (verify and pin at implementation), existing exact-decimal money types, flutter_test and provider overrides. Begin with manual providers; code generation is optional later.

**Spec:** ../../wallet-simulation-48-spec.md and ../../dashboard-portfolio-and-state-review-48.md

## Global Constraints

- No Riverpod dependency or migration in build 48.
- Newly registered local accounts start with zero balances in every asset.
- Exact amounts use atomic integer units and explicit asset precision; display text never becomes a ledger instruction.
- Only successful transactions credit destinations; pending outgoing requests reserve funds once and failures release them once.
- Production wallet state comes from an authoritative backend. Local simulation cannot manufacture production balances.
- Transient form input, focus, balance visibility and animation controllers remain local widget state.
- No automatic retry of financial writes in provider build methods.
- Keep existing navigation, legal references, styling and native integrations during migration.

## Review Focus

1. Duplicate completion or repeated taps must not settle a transaction twice (task 3).
2. Account switch while a response is in flight must discard the old account response (task 1).
3. Timeout after submission is an unknown outcome, not permission to submit a second payment (task 3).
4. Process death with a reserved transaction must reconcile it without minting or losing funds (task 6).
5. Expired or changed prices must require a new reviewed quote before submitting (task 2).

## File ownership

- `lib/core/session/account_session.dart`: authenticated account identity and generation.
- `lib/core/providers/account_scope.dart`: ProviderScope boundary and account overrides.
- `lib/features/wallets/wallet_repository.dart`: existing interface and exact snapshot types; extract singleton adapter into `local_wallet_repository.dart`.
- `lib/features/wallets/wallet_providers.dart`: watch snapshot and derive values; no settlement arithmetic.
- `lib/features/wallets/quote_repository.dart`: timestamped, expiring quotes.
- `lib/shared/receipts/transaction_repository.dart`: durable submission identity, reservation and reconciliation contract.
- `lib/shared/receipts/transaction_controller.dart`: explicit submit/status/retry-read commands.
- `lib/features/dashboard/presentation/portfolio_view_state.dart`: derived crypto totals/allocation, no independent balance copy.
- Existing auth, dashboard, trade, gift-card, profile and verification screens: consumers migrated in bounded groups.

### Task 1: Establish an account-scoped repository boundary

**Files:** Create account_session.dart, account_scope.dart, local_wallet_repository.dart and wallet_providers.dart above; modify `lib/app.dart`; test `test/providers/account_scope_test.dart`.
**Interfaces:** `AccountSession(String accountId, int generation)`; `walletRepositoryProvider: Provider<WalletRepository>`; `walletSnapshotProvider: StreamProvider<WalletSnapshot>`. Keep `WalletRepository.watchSnapshot()` and `refresh()`.

- [ ] Write `oldAccountResponseCannotPublishAfterSwitch`: use two fake streams, switch A to B, emit A late and assert consumers still show B. Also assert a registered B starts with twelve zero balances and disposing its scope cancels subscriptions.
- [ ] Run `flutter test test/providers/account_scope_test.dart`; confirm failure before the new boundary exists.
- [ ] Pin the verified compatible Riverpod version; adapt existing simulation without rewriting arithmetic. Inject one repository per account through ProviderScope overrides. Keep a temporary singleton bridge for unmigrated screens.
- [ ] Run the same test and `flutter analyze lib`; require passing tests and no source issues. Commit this account boundary independently.

### Task 2: Own quotes and computed wallet state

**Files:** Create quote_repository.dart, portfolio_view_state.dart; extend wallet_providers.dart; test `test/providers/wallet_derivations_test.dart`.
**Interfaces:** `QuoteSnapshot(id, asOf, expiresAt, pricesMinorUnits, usdNgnMinorUnits)`; `quoteProvider: FutureProvider<QuoteSnapshot>`; computed `portfolioViewProvider` and per-asset view providers read the same wallet snapshot.

- [ ] Write tests asserting NGN cash is excluded from crypto allocation, zero holdings produce no percentage division, and a changed or expired quote invalidates review confirmation instead of silently changing the amount.
- [ ] Run `flutter test test/providers/wallet_derivations_test.dart`; confirm failure.
- [ ] Derive totals/allocation from exact snapshot units. Bundle the dated snapshot only in the development quote adapter; production quote adapters must supply identity, timestamps, expiry and fees/spread. Keep market movement separate from personal P&L.
- [ ] Run derivation and existing quote-consistency tests; require passing results. Commit quote ownership and derived views.

### Task 3: Introduce explicit transaction commands

**Files:** Create transaction_repository.dart and transaction_controller.dart; adapt `lib/shared/receipts/receipt_activity.dart`; test `test/providers/transaction_controller_test.dart`.
**Interfaces:** `submit(TransactionIntent intent, String idempotencyKey) -> Future<TransactionRecord>` and `lookup(String idempotencyKey) -> Future<TransactionRecord>` on TransactionRepository; `TransactionController.submit(intent)` is a user command, never a provider build side effect. States: draft, submitting, pending, completed, failed, unknown.

- [ ] Write tests for two taps with one intent, repeated completion, insufficient balance, failed debit refund, and timeout after server acceptance. Assert exactly one reserve and one credit; unknown outcome triggers lookup with the same key and never a fresh submit.
- [ ] Run `flutter test test/providers/transaction_controller_test.dart`; confirm failure.
- [ ] Move existing tested WalletEffect settlement behind the local repository adapter. Make the repository own atomic idempotency and transaction identity; controller renders state and requests reconciliation. Disable automatic write retry and double-submit while submitting/pending/unknown.
- [ ] Run controller tests and `test/wallet_simulation_48_test.dart`; require passing results. Commit the transaction command boundary.

### Task 4: Migrate Dashboard and Portfolio together

**Files:** Modify `lib/features/dashboard/presentation/dashboard_screen.dart`, components/dashboard_panels.dart, components/portfolio_panels.dart and portfolio_performance_screen.dart; test `test/providers/dashboard_portfolio_test.dart`.
**Interfaces:** Widgets consume walletSnapshotProvider and portfolioViewProvider from tasks 1?2; selectors watch only values required by each widget.

- [ ] Write a widget test funding NGN, buying BTC and checking Dashboard and Portfolio agree without route reload; switching account resets both. Assert neutral Buy/Sell/Swap actions and a truthful zero state. Performance must not show fabricated personal returns when there is no cost basis/history.
- [ ] Run `flutter test test/providers/dashboard_portfolio_test.dart`; confirm failure against singleton-only screens.
- [ ] Replace manual listeners with Consumer widgets/ref.watch. Remove screen-owned copies of balances; retain local visibility and scroll state. Preserve the present layout and navigation.
- [ ] Run dashboard/portfolio tests plus existing responsive tests, then capture zero and funded screens in light/dark modes. Commit the two screens as one coherent migration.

### Task 5: Migrate transaction entry flows

**Files:** Modify buy_crypto_models.dart, buy_receipt_records.dart, crypto_receipt_records.dart, gift_card_receipt_records.dart, funding_outcomes.dart and simulation_deposit_button.dart; test `test/providers/trade_flow_test.dart`.
**Interfaces:** Flows consume immutable quotes from task 2 and call task 3's controller with an exact TransactionIntent; receipts observe the repository's record stream.

- [ ] Write flow tests for deposit ? buy ? swap ? sell ? withdrawal, gift purchase/sale, and account change while PIN confirmation is open. Assert fees, source-wallet selection, displayed quotes and exact settled units agree and stale confirmations are rejected.
- [ ] Run `flutter test test/providers/trade_flow_test.dart`; confirm failure.
- [ ] Replace static repository access in each builder/flow with injected dependencies; retain the development-only Add funds / Confirm deposit control with normal product wording. Eliminate UI-owned completion timers after the repository owns lifecycle scheduling.
- [ ] Run flow tests and the existing receipt/funding/gift suites; require passing results. Commit the migrated transaction flows.

### Task 6: Add durable local simulation storage and restart reconciliation

**Files:** Create `lib/features/wallets/local_ledger_store.dart`, `local_ledger_migrations.dart`; modify local_wallet_repository.dart and transaction_repository.dart; test `test/providers/local_ledger_restart_test.dart`.
**Interfaces:** Transactional store reads/writes account-scoped snapshots and records together, with a unique `(accountId, idempotencyKey)` constraint. Persist atomic units as decimal integer strings plus precision, not floating point.

- [ ] Write tests for process termination before/after reservation and completion, duplicate persisted callbacks, corrupted data and account isolation. Reopening the store must preserve exact funds and reconcile pending records once.
- [ ] Run `flutter test test/providers/local_ledger_restart_test.dart`; confirm failure.
- [ ] Select a supported transactional database adapter after checking current platform support; make schema migrations and atomic commits explicit. Do not use preferences as a financial ledger. Riverpod's experimental offline persistence is not a substitute for transaction storage. Production reconciliation reads authoritative backend state.
- [ ] Run restart/migration tests and exact-money tests; require passing results. Commit storage only after crash/reopen cases pass.

### Task 7: Migrate remaining shared account services

**Files:** Modify `lib/core/preview/local_preview_profile.dart`, profile_settings/presentation/verification/verification_state.dart, core/theme/appearance_controller.dart and their consumers; create feature-specific providers alongside each service; test `test/providers/account_services_test.dart`.
**Interfaces:** Auth/session, KYC, linked accounts and preferences receive account/session dependencies through providers. Device-wide appearance remains outside the account scope.

- [ ] Write tests proving sign-out clears account/KYC/transaction state, late verification callbacks cannot restore the old account, and device appearance persists independently.
- [ ] Run `flutter test test/providers/account_services_test.dart`; confirm failure.
- [ ] Migrate one shared service at a time. Keep TextEditingController, OTP focus and animation state local. Remove the singleton bridge only after `rg 'WalletAccountState.instance|ReceiptActivity\.' lib` shows no unintended consumers.
- [ ] Run auth, verification, settings and provider suites; require passing results. Commit each migrated feature independently.

### Task 8: Release verification

**Files:** Update research/review and native evidence under `review/evidence/riverpod-migration/`; update pubspec version after the migration is implemented.

- [ ] Run the full Flutter test suite and source analyzer; resolve genuine regressions before packaging.
- [ ] Build the development release APK; install with `adb install -r` to preserve device data. Verify package version and signature.
- [ ] On emulator: create account, confirm all balances zero, add funds, complete buy/swap/sell/withdrawal, switch accounts and restart. Compare Dashboard, Portfolio and History after each settlement. Capture failures/offline/unknown outcomes as well as success.
- [ ] Install the same verified APK on the phone when connected; report separately if unavailable. Commit evidence and a migration completion note; do not claim production settlement from local simulation.

## Primary references

- https://riverpod.dev/docs/concepts2/providers
- https://riverpod.dev/docs/concepts2/retry
- https://riverpod.dev/docs/how_to/testing
- https://riverpod.dev/docs/how_to/select
- https://riverpod.dev/docs/concepts2/offline
- https://bloclibrary.dev/architecture/
