# Review implementation: frontend and integration boundaries

Version 0.15.0+38. Implements the frontend correction batch from the combined review plan. The original security review remains an immutable assessment of revision 32edac2; this document describes subsequent changes.

## Implemented

- Exact non-negative asset parsing into BigInt atomic units, strict precision validation, account/session generation tokens, versioned transaction-event store and production provider-composition guard.
- One observable wallet snapshot replaces contradictory funding balances and holding valuations. Portfolio total/allocation derive from holdings, including USDC; current performance valuation uses the same snapshot.
- Withdrawal selection carries BTC/ETH/SOL/USDT into mode and amount entry. Crypto available-funds checks use exact quantities; Naira eligibility uses exact minor units and rechecks before review. The open Naira screen observes balance updates.
- Naira entry flows with scroll/keyboard/text scaling; OTP scrolls, resend controls wrap, and masked destination comes from the current profile. Buy asset/funding sheets use content-sized rows and responsive value placement.
- Gift evidence uses validated actual image picking with cancel/remove/replace. Product country/type/category/rate and recipient/delivery travel through review/payment/receipt. Quote matching rejects edited input and expiry. Separate account-owned gift cache removes prior-process copies before another selection.
- Verification originals/PDF thumbnails/partial files reconcile before new capture. Cleanup is awaitable, retries deletion, checks canonical direct ownership, preserves active files and aggregates reset failure outcomes. Startup retention for previous-process files is zero; unretained in-process verification copies have a 24-hour sweep, gift evidence a separate one-hour policy.
- Camera initialization/frame/still work is tracked so teardown waits for pending native users rather than a fixed 300ms delay. Late asynchronous continuations check lifecycle/generation.
- Working animation invalidates tint/configuration changes, pauses on hidden tabs and obeys reduced motion. OTP disclosure also obeys reduced motion. Existing green face ticks, orbit dot and no-haptic behavior remain.
- Math font fallback registered; unregistered Poppins references replaced by Sora; input hint contrast strengthened. Reachable help controllers dispose. Notification categories expose selected semantics and 48px tap areas.
- Android release signing requires externally supplied identity/credentials and rejects a debug certificate. No signing key was generated or modified.

## Backend integration still required

`AuthRepository`, `WalletRepository`, `TransactionRepository` and `GiftCardRepository` are interfaces, not deployed services. Current normal development entrypoint retains local journeys so it can run; `DAVOCHAIN_ENV=production` rejects that composition. This is a developer build boundary, not a customer-facing banner.

Deliver authenticated account/challenge/quote/operation/upload adapters using the existing backend-engineer handoff. Local OTP/PIN/recovery and execution fixtures must be replaced before production. Server balances/fees/limits, KYC approval, durable idempotency, accepted operation reconciliation, reversal/refund propagation into receipts, push/read refresh publication, session secret storage and fulfillment are external acceptance gates. The new event store supports explicit versioned reversal/refund transitions; the legacy receipt observer has not been represented as a fully integrated server event adapter.

Exact `AssetAmount` models protect new parsing/eligibility boundaries. Some legacy quote/order/receipt presentation still uses double denomination values; serialize neither those values nor rounded display labels as authoritative money. Wire adapters must use agreed atomic-unit/minor-unit or decimal-string DTOs, server quotes and exact fee currency rules. Product must confirm NGD rules, network fees/minimums/limits, catalog availability/requirements and retention policy.

## Release configuration

Supply private Gradle properties `davochainApplicationId`, `davochainStoreFile`, `davochainStorePassword`, `davochainKeyAlias`, `davochainKeyPassword`, or corresponding `DAVOCHAIN_APPLICATION_ID`, `DAVOCHAIN_STORE_FILE`, `DAVOCHAIN_STORE_PASSWORD`, `DAVOCHAIN_KEY_ALIAS`, `DAVOCHAIN_KEY_PASSWORD`. Debug builds continue to use development identity. Production signing is a separate requirement from real provider integration.

## Verification and remaining work

Regression tests cover exact parsing, stale session/snapshot rejection, asset propagation, keyboard/text scaling, balance reduction while open, gift evidence/delivery/quote identity, file cleanup ownership/retry/process-start simulation, camera work draining, repaint/ticker lifecycle and selected notification accessibility.

Final command results and capture/artifact locations are recorded in the project review implementation ledger. Widget/native-bridge tests do not substitute for physical camera/biometric tests. Remaining validation includes live picker/camera/background/reopen, real iOS PDF parity, TalkBack traversal, profile-device performance, configured production certificate and authenticated staging integration. No FPS guarantee or full production-security claim is made.

Broader controller extraction, all financial-flow exact-money conversion, optional visual refinements and all backend adapter delivery remain subsequent plan work; this batch prioritizes verified user-visible and security-lifetime defects.
