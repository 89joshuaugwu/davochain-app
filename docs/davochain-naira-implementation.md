# Davochain Naira single wallet

Implemented 16 October 2026 for local development build 55.

## Product behavior

Davochain Naira is the one spendable cash wallet. One unit represents one Nigerian naira. NGN remains its internal banking and FX denomination; NGD is accepted only as a legacy alias. The approved custom mark is rendered through its bundled font, with explicit Davochain Naira text for accessibility and external sharing.

Home and withdrawal show this cash balance. Their naira equivalent begins with = to communicate exact 1:1 parity; USD uses the approximation mark. Crypto portfolio totals exclude it. Crypto holdings show their quantity, naira value and a secondary USD estimate. Estimates use the same wallet observation; mismatched or expired quotes suppress USD. Hiding a balance hides the equivalents too.

Buy opens the selected crypto with Davochain Naira already selected. Sell proceeds and gift-card proceeds enter the same wallet; gift purchases spend it. Swap sources are funded crypto holdings and destinations exclude the source. Flipping to an unfunded source is blocked. Bank withdrawal selects a saved linked account, checks amount plus fee, shows total debit in review, and validates the destination and account generation again after PIN.

## Migration and recovery

Known version-1 checkpoints store independent NGN and NGD balances. Migration adds the two available balances at parity, remaps pending effects/reservations, removes NGD from the exposed asset catalog and writes the validated checkpoint atomically before publication. Reserved debits are already excluded from available funds and are not added twice. Version-2 markers make reruns idempotent. Unknown or contradictory layouts fail validation instead of guessing.

Operation IDs, historical receipt text, notification read/delivery state and crypto valuation history are retained. No migration deposit or notification is manufactured. Existing pending operations settle or release once after restoration.

## Receiving and backend boundary

Receiving accounts have creating, ready, failed and unavailable states. Provisioning has an idempotency key, account/generation guards, a retry path and persistent account-scoped metadata. Copy/share is available only for ready details belonging to the current account. Sharing details never credits money.

The local gateway returns clearly labelled TEST references, not real bank account numbers. The development Add funds flow creates accepted local test transfers through the existing receipt/notification pipeline. Production disables these receiving fixtures. A backend must provision actual subaccounts, support third-party deposits, authenticate transfer callbacks, credit once, validate saved-bank ownership and reconcile withdrawals. No real bank transfer or provider provisioning was tested.

## Verification record

The focused migration checkpoint passed 19 tests with clean analysis before commit b42d69d. Receiving controller tests cover delayed responses, persistence before ready, duplicate activation, retry, restored-account mismatch and account switching. New Buy, funded Swap/Sell and presentation suites exercise the canonical wallet. Withdrawal regression coverage includes fee coverage and removal of a linked bank during PIN entry.

Independent read-only review found one P2 issue: matching expired quotes still displayed USD. The expiry regression failed before the correction and now passes; cash and portfolio paths also use the guard. No other important findings were reported; this is not backend or device certification.

Visual evidence: workspace `review/evidence/single-wallet-55/widgets/` contains light/dark Home, receiving, Buy, withdrawal, portfolio and 320-pixel/200-percent portfolio captures. Widget capture uses test font loading; native device evidence is authoritative for platform font rendering.

Final full regression: `flutter test --no-pub --reporter expanded` passed **751 tests**, with **17 optional capture tests skipped**. The new journey/presentation/discoverability focused run passed **15 tests**. User-requested `=` parity prefixes were added after the initial widget captures; final native captures document that update. APK and emulator results follow after execution.
