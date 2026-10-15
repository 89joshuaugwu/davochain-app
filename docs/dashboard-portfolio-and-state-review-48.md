# Dashboard, Portfolio and state review

## Purpose and review

Dashboard Assets is a compact view of the signed-in account's holdings: quantity, current value, and a fast path to Portfolio. It is not a market watchlist. Zero holdings are valid. Buying an asset or receiving a deposit should change it without refreshing a different screen. Preserve the existing compact viewport, but consider sorting positive holdings first and making full-list discoverability explicit.

Portfolio answers what the person owns, what it is worth and how it is distributed. Its total should sum crypto holdings using the same quotes, exclude cash wallets and pending destination credits, and keep Buy/Sell/Swap as equally available actions. A blue Buy button suggested an active tab even though these are actions, so all three now have neutral styling. Allocation now counts positive holdings in the simulator and has an honest empty state.

The current portfolio rows have chevrons without an associated drill-down action; wire them to actual asset details in the next product pass or remove that affordance. Holding value and allocation are useful now. Personal profit, cost basis and performance require historical prices plus cash-flow accounting. Depositing money is not investment profit. The simulator removes fixture percentage labels from holdings rather than calling them returns. The local account view omits the Live Sync badge because its rates are a dated snapshot.

Search works for partial names and symbols, keeps a stable results area and handles no results. A zero holding does not mean the asset is unsupported; its balance now shows zero. In simulation mode all ten assets have researched quotes and can be selected. Outside simulation, quote availability remains a separate guard. Future polish: persistent search field above independently scrollable results, a clear-query action, and sort held assets first. Preserve the current layout until product decisions call for those changes.

## Local simulation delivered

New registration starts every NGN/NGD/crypto wallet at zero. The existing Login demonstration identity remains funded. Development receiving pages expose Add funds with Confirm deposit; normal product wording is deliberate, as the user requested. The Naira deposit dialog lets the tester choose NGN or NGD. Copy/share/QR do not fabricate deposits. A pending source debit reserves available funds; destination credit arrives only on completion. Failure refunds the reservation; duplicate completion does not double-credit; account changes invalidate old effects. Actual remote-provider receipts cannot write the simulation ledger. Gift purchases also require available NGN funds.

This is a session-local demonstration, not bank settlement or authenticated account persistence. Relaunch/login retains the existing local identity behavior; durable per-account storage is part of the Riverpod/repository follow-up. No Riverpod dependency or migration introduced in this batch.

## Conversion research

CoinGecko /simple/price queried by canonical coin IDs with NGN, USD and last_updated_at. Source data is saved in research/coingecko-2026-10-15.json. Observation: 15 October 2026, 15:07:48 UTC / 16:07:48 WAT. One dated snapshot drives crypto/NGN conversions and wallet valuation, with exact decimal amounts and rounding down acquired units. USD/NGN derives from the paired USD Coin quotes, avoiding a hard-coded dollar value of exactly1.

| Asset | NGN per coin at observation |
|---|---:|
| BTC |109,147,955.00|
| ETH |3,217,319.00|
| SOL |140,538.00|
| USDT |1,328.84|
| USDC |1,329.51|
| XRP |1,772.39|
| ADA |304.68|
| DOGE |106.91|
| LTC |79,746.00|
| BNB |971,979.00|

These are indicative market observations, not an executable buy/sell spread, guaranteed stablecoin parity, or live pricing. The offline bundle intentionally makes boss demonstrations reproducible. Production needs a provider quote ID, source, expiry, fee/spread and server validation. Never refresh a quote silently between review and payment confirmation. Fee schedules must come from the business/provider; this change does not invent new fees.

Source: https://docs.coingecko.com/demo/reference/simple-price (supports timestamps/freshness checks and canonical IDs).

## State-management comparison

| Option | Fit for Davochain | Trade-off |
|---|---|---|
| Riverpod | Recommended: account-scoped dependencies, async repository reads, derived wallet/portfolio state and isolated tests | Requires disciplined provider ownership; it does not implement a financial ledger or database for us |
| BLoC / Cubit | Strong alternative for explicit workflow state machines; Cubit exposes methods, Bloc accepts events | More ceremony for combining many wallet, quote and settings dependencies; choose it if the team prefers event-driven conventions |
| Provider / ChangeNotifier | Closest to current code, easy incremental sharing | Manual async/error/session cleanup and mutable shared state remain our responsibility |
| MobX | Observable state and derived values with concise reactive updates | More implicit dependency tracking and optional code generation; no clear migration advantage here |
| GetX | Broad reactive state/navigation/dependency toolkit | Would overlap the existing navigation and service conventions; not recommended as a second framework alongside Riverpod |

Recommendation is an engineering judgment for this repository, not a claim that one library is universally best. Use Riverpod for shared account/async state, retain local setState/controllers for transient form inputs, and use an explicit transaction state machine within a notifier where appropriate. Avoid mixing Riverpod and BLoC for the same wallet.

Primary sources checked 15 October 2026:
- https://riverpod.dev/docs/concepts2/providers
- https://riverpod.dev/docs/concepts2/retry
- https://riverpod.dev/docs/concepts2/offline (persistence is experimental; a database still owns durable records)
- https://bloclibrary.dev/bloc-concepts/
- https://bloclibrary.dev/architecture/
- https://pub.dev/packages/provider
- https://pub.dev/packages/mobx
- https://pub.dev/packages/get
- https://docs.flutter.dev/data-and-backend/state-mgmt/options

Implementation plan: superpowers/plans/2026-10-15-riverpod-account-state.md.

## User clarification

The user confirmed there is no backend and explicitly wants fully working local presentation flows without customer-facing preview or simulation labels. Add funds records a local deposit; it does not call a bank. Keep technical limitations in engineering documentation, not the account screens.
