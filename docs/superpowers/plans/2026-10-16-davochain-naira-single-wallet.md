# Davochain Naira Single-Wallet Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox syntax for tracking. Work directly on main as the user requested; protect unrelated edits and push only verified commits.

**Goal:** Present one Davochain Naira wallet for receiving, buying, selling and bank withdrawal, with the approved custom mark and consistent naira/USD valuations.

**Architecture:** Retain NGN as the canonical underlying fiat money asset, introduce a named Davochain Naira wallet projection, and retire the separate NGD spendable balance through a versioned account migration. Receiving-account provisioning and withdrawal destinations are separate account-scoped models. Reuse exact money, account guards, receipt persistence and notification delivery.

**Tech Stack:** Flutter/Dart, Riverpod, existing exact money/ledger and SQLite checkpoint store; native notification runtime; custom SVG/font currency mark.

**Spec:** docs/superpowers/specs/2026-10-16-davochain-naira-single-wallet-design.md

**Status:** User approved execution of this whole plan on 16 October 2026 and requested direct work/push on main. Symbol implementation is already complete. Task1 foundation: 19 focused tests passed and static analysis clean; remaining tasks in progress.

## Global constraints

- 1 Davochain Naira represents exactly NGN 1, with two decimal places.
- Davochain Naira is the customer-facing wallet name; NGN remains the banking/FX denomination.
- One spendable fiat wallet; never double-count or silently reset existing funds.
- No real bank provisioning or remote transfer success is invented without a backend.
- Preserve operation IDs, pending reservations, receipt facts, notification read/delivery state and account isolation.
- Symbol is a custom mark/font glyph; external plain text needs a meaningful fallback.
- Price equivalents come from the same dated quote; USD estimates are not spendable balances.
- Dashboard cash balance stays distinct from crypto portfolio valuation.

## Review focus

1. An old account containing both NGN and NGD plus a pending withdrawal must preserve funds/reservations and settle or release once after migration and restart.
2. Duplicate or late incoming transfer callbacks must credit once; callbacks for a switched account must not show details, credit funds or notify another account.
3. Quote refresh during amount entry/review must update or expire both valuations coherently and never change a confirmed debit silently.
4. A saved bank edited/removed while withdrawal review is open must be revalidated, with fee/total and available balance unchanged until acceptance.
5. Symbol font loss, text export, large text, hidden balance and screen readers must not produce unreadable private glyphs, clipped values or hidden-value disclosure.

---

### Task 1: Introduce the named wallet contract and migration

**Files:** create `lib/features/wallets/davochain_naira_wallet.dart`, `lib/features/wallets/davochain_naira_migration.dart`; modify `wallet_repository.dart`, `local_account_persistence.dart`, `local_wallet_repository.dart`, checkpoint serialization in `shared/receipts/transaction_repository.dart`; test `test/providers/davochain_naira_migration_test.dart`.

**Interfaces:** `DavochainNairaWallet` exposes wallet identity, NGN currency ID, available/reserved minor units and display name from WalletSnapshot. `migrateDavochainNairaCheckpoint(Map<String,Object?>)` returns a validated versioned checkpoint without mutating its input; explicitly handle unsupported/provenance-ambiguous input.

- [ ] Write failing fixtures for NGN-only, NGD-only, both independent, ambiguous mirrored, zero, reserved, pending buy/withdrawal, failed release, duplicate migration and two accounts.
- [ ] Run the focused test to RED and establish the exact reconciliation policy from stored operation provenance; resolve ambiguous input before shipping.
- [ ] Implement one canonical wallet accessor and atomic idempotent account migration, including pending effects and schema compatibility. Preserve total funds, operation identities and history.
- [ ] Run focused money/ledger/restart tests to GREEN; assert no new receipts, notifications or synthetic performance gains. Commit the independently validated migration.

### Task 2: Model receiving details per account

**Files:** create `lib/features/funding/receiving_account.dart`, `receiving_account_gateway.dart`, `receiving_account_controller.dart`; modify `components/deposit_screens.dart`, `shared/widgets/bank_details_share_button.dart`, startup/account services; test `test/receiving_account_test.dart`.

**Interfaces:** account-scoped `ReceivingAccount` with creating/ready/failed/unavailable status and provider-issued details only when ready; injectable `ReceivingAccountGateway.provision(accountId, idempotencyKey)`; controller validates account/generation around awaited responses.

- [ ] Write RED tests for delayed provisioning, retry, duplicate signup request, account switch, copy/share while pending, third-party accepted deposit, duplicate credit and failed transfer.
- [ ] Implement deterministic clearly preview-only local fixtures, persistent per-account status, and a later production-adapter boundary. Replace the global BankDepositDetails.preview dependency in customer flows.
- [ ] Correct the non-withdrawable/same-name-only product copy. Ready receiving account maps accepted transfers to the single wallet; display/copy/share never manufactures credit.
- [ ] Run to GREEN with funding/receipt/notification bridge tests. Verify details are never reused across customers. Commit.

### Task 3: Make Buy use Davochain Naira by default

**Files:** modify `buy_crypto_models.dart`, `buy_crypto_flow.dart`, `buy_crypto_screens.dart`, `buy_crypto_widgets.dart`, `buy_amount_controller.dart`, related buy receipt builder and portfolio buy entry points; test `test/buy_davochain_naira_test.dart`.

**Interfaces:** new orders always use the named canonical fiat wallet; legacy funding enum values deserialize through compatibility mapping. A visible source selector is unnecessary when there is one source.

- [ ] Write RED tests entering from Home, Trade, portfolio and asset overview: no NGN/NGD choice, correct default and exact balance, empty Add money state, insufficient funds, stale quote and account switch.
- [ ] Remove the extra funding sheet from new Buy journeys, use the wallet projection in validation and review, and retain legacy order restoration safely.
- [ ] Confirm one debit from Davochain Naira and one credit to selected crypto; failed/cancelled submission preserves or releases funds once.
- [ ] Run buy, amount-precision, receipt and notification tests to GREEN. Commit.

### Task 4: Align Sell, Swap and gift cards

**Files:** modify `crypto_trade_screens.dart`, `crypto_receipt_records.dart`, `crypto_trade_amounts.dart`, `gift_card_receipt_records.dart`, `gift_buy_screens.dart`; test `test/single_fiat_trade_routing_test.dart`.

**Interfaces:** fiat proceeds/spends target the canonical wallet accessor; Swap source projection uses available funded crypto holdings; destination catalog excludes source and unsupported/unquoted destinations.

- [ ] Write RED tests for sell proceeds then re-buy/withdraw, gift-card purchase/sale/refund, funded swap selection, zero-source state, same-asset swap, fees, quote expiry and pending restoration.
- [ ] Replace separate fiat targets with the one wallet and label; keep crypto-to-crypto exchange on actual holdings with exact quantities and fee validation.
- [ ] Run trade/gift/ledger outcome suites to GREEN; verify receipt-driven notifications use the same wallet name without duplicates. Commit.

### Task 5: Route bank withdrawals from the same wallet

**Files:** modify `crypto_full_flow.dart`, `crypto_naira_screens.dart`, `funding_outcomes.dart`, linked-bank settings adapters and relevant receipt presentation; test `test/davochain_naira_withdrawal_test.dart`.

**Interfaces:** withdrawal request identifies canonical source wallet and existing saved-bank destination ID, amount/fee/total in minor units, account generation and operation ID.

- [ ] Write RED tests for branded source instead of flag/NGN option, matching displayed available balance, fee-inclusive limit, linked-bank selection/add/remove, double-submit, pending success/failure/restart and account switch.
- [ ] Reuse linked-bank settings as destinations, validate them again before acceptance, debit/reserve the same displayed wallet, and preserve pending versus completed status.
- [ ] Run withdrawal, saved-bank, funding/receipt and security-gate tests to GREEN. Commit.

### Task 6: Apply mark, naming and both valuations consistently

**Files:** approved `shared/widgets/davo_naira_amount.dart` and currency assets; create `features/wallets/wallet_valuation.dart`; modify dashboard/deposit/withdraw/trade/gift/transaction-history and receipt/share views; test `test/davochain_naira_presentation_test.dart`.

**Interfaces:** valuation projection returns naira minor units, optional USD minor units, quote ID/as-of and availability; amount widget renders the approved glyph with semantic/plain-text fallbacks. Customer labels do not expose a second funding balance.

- [ ] Write RED tests for one cash wallet across surfaces; crypto quantity/naira/USD hierarchy; 1:1 cash parity; missing/stale quote; exact rounding; both hidden; large text, light/dark and receipt exports.
- [ ] Use one quote snapshot for both estimates. Replace static USD examples and direct customer-facing NGN-wallet strings. Keep underlying currency facts on external banking/FX records and old receipts accurate.
- [ ] Apply the selected currency mark to branded balances/spend/proceeds; preserve readable text when copied/shared outside the app. Crypto portfolio excludes cash unless explicitly labelled total-account value.
- [ ] Run presentation, accessibility, export and snapshot tests to GREEN. Capture phone/narrow/large-text and both themes in one batch, fix meaningful defects once, confirm. Commit.

### Task 7: End-to-end acceptance and main release

**Files:** update this plan and implementation evidence under `docs/`; release through the existing local helper with a new build number when money-flow implementation is ready.

- [ ] Exercise signup -> receiving details -> accepted local transfer -> Buy -> Swap -> Sell -> linked-bank withdrawal, including failure/cancel/restart states and real notification taps.
- [ ] Verify no second NGN/NGD balance or unintended entry point remains; exact funds conservation and no migration notification burst.
- [ ] Run focused suites, the full regression suite and static analysis. Get a fresh independent code review and fix important findings before release.
- [ ] Build and inspect the APK, test on available devices without clearing user accounts, record unavailable backend/device coverage, verify hash/signature, commit on main and push origin/main. No force push.

## Backend handoff

Define provider-backed receiving provisioning, actual accepted transfer events, idempotent credit, withdrawals/status reconciliation and saved-bank validation behind the local gateways. Confirm the provider supports the required third-party inbound transfers before production receiving copy is enabled. Server-side authority must enforce balances, fees, limits, ownership and identity requirements; frontend fixtures remain testing only.
