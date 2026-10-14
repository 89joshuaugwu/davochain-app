# State management for Davochain

Assessment: 14 October 2026. Recommendation, not an implemented migration.

## Recommended direction

Use **Riverpod for shared application state and asynchronous services**, alongside **Flutter `setState` for short-lived screen interactions**. This combination can be introduced before backend connection. Keep the exact-money types, repository contracts, account ownership checks and transaction rules independent of the state framework.

This recommendation comes from Davochain's current code and planned integration needs, not a claim that popularity proves suitability. Riverpod supports provider dependencies, caching, disposal and testing overrides. Its own guidance recommends keeping ephemeral widget state local rather than putting everything in providers. Sources: [Riverpod providers](https://riverpod.dev/docs/concepts2/providers), [Riverpod DO/DON'T](https://riverpod.dev/docs/root/do_dont).

## Current implementation

- `setState` owns form selection, visibility, expanded details and screen interaction.
- `ChangeNotifier`/`ValueNotifier` with listening widgets owns shared wallets, inbox, appearance and local profile/auth preferences.
- Dedicated amount controllers own parsing, account generation and eligibility; repository interfaces establish backend boundaries.
- Many shared models use static singleton access. Tests and account resets must explicitly restore them. `AppProviders` currently enforces environment/authority; despite its name, it is not Riverpod.

These Flutter primitives are valid state-management tools. Flutter distinguishes local/ephemeral state from application state, and its architecture guidance allows `ChangeNotifier`/`Listenable` for view models. The absence of a backend does not require either approach. Sources: [Flutter state management](https://docs.flutter.dev/data-and-backend/state-mgmt/intro), [Flutter architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations).

## Comparison for this project

| Option | Benefit | Cost or concern |
| --- | --- | --- |
| Keep current approach | Existing behavior and regression coverage; minimal churn | Explicit singleton reset/disposal and async loading/error handling remain distributed |
| Riverpod plus local `setState` | Scoped dependencies, replaceable repositories, async states and derived reads; test containers avoid global service replacement | Requires a staged migration and deliberate account/cache invalidation; does not automatically prevent races or authorize money movement |
| Bloc/Cubit plus local widget state | Explicit events/state transitions can suit complex workflows | Another architecture and dependency set; no demonstrated requirement for its ceremony in every Davochain screen |
| Multiple shared-state frameworks together | Can bridge a temporary migration | Long-term duplicate ownership increases synchronization and debugging work; avoid separate authoritative copies of the same wallet/session |

Riverpod is my preferred next shared-state layer here. A migration should replace ownership gradually, not wrap every singleton indefinitely and call it complete. There is no need to combine Riverpod, Bloc and GetX for the same state.

## Proposed migration sequence

1. Add one app-level `ProviderScope` and repository/service providers. Begin without code generation unless it solves a concrete need. Continue using current repository contracts and injectable local adapters.
2. Establish the account/session boundary first. Invalidate account-owned state on sign-out/account change; reject late results. Keep secrets in the approved secure-storage/service boundary, not provider state snapshots or logs.
3. Migrate the notification inbox as a bounded pilot: records, unread aggregate, read mutation, refresh, loading/error state and stale-response handling. Verify badge/detail synchronization and isolated test overrides.
4. Migrate wallet snapshot and derived portfolio/allocation reads. Preserve exact amounts, snapshot versions and coherent balances; avoid rebuilding the whole app for one field change.
5. Move transaction submission/read reconciliation and gift catalogue/quotes to feature controllers. Keep idempotency and accepted-operation tracking explicit. Automatically retry safe reads where appropriate; do not blindly retry financial writes.
6. Migrate profile/appearance/preferences where useful. Keep field controllers, focus, draft photos, selected tabs and small animation state local to screens unless there is a cross-screen ownership reason.
7. Remove superseded singleton ownership only after consumers move. Run existing regression coverage plus isolated provider tests, account-switch/race tests, loading/error/refresh tests and representative device checks.

## Acceptance criteria

- Each wallet, session, inbox and operation has one authoritative state owner.
- Account A results cannot populate account B state or receipts.
- Providers can be overridden in tests without mutating a process-wide service instance.
- Backend adapters can be swapped in without changing UI financial calculations or weakening production guards.
- Explicit loading, stale-data, empty, error and retry states are represented where applicable.
- All current money, receipt, PIN/fingerprint, refresh and responsive-layout regressions continue to pass.

No Riverpod dependency or source migration has been introduced by this analysis. The current visual/security batch should be accepted independently before starting the architecture change.
