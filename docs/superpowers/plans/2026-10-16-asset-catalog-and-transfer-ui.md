# Asset catalog and transfer UI implementation plan

> **For agentic workers:** Use superpowers:executing-plans inline. User explicitly requested analysis and to proceed on 16 October, with direct main/push authorization continuing. Preserve existing account data and unrelated worktrees.

**Goal:** Show every supported catalog asset, rank balances consistently, use the Davochain mark with naira/USD equivalents, and make wallet selection and internal crypto transfers usable.

**Architecture:** A pure shared asset projection orders the existing ten-asset catalog. Exact naira valuations determine the same order as USD under the shared positive FX quote, without rounding ties to USD cents. UI projections never create balances or enable unsupported network operations. Reuse the existing custom font, money ledger and transaction guards.

**Tech stack:** Flutter/Dart, Sora/Davo theme, existing SVG logos and exact-money wallet snapshots.

## Accepted behavior and rulings

All catalog assets remain visible at zero. Positive holdings sort first by descending shared-quote value, then a curated popular order USDT, BTC, ETH, USDC, SOL; remaining ties/zero assets sort by display name. Home takes the first five; Portfolio shows the full searchable list. Allocation remains based on funded holdings, and cash remains separate from crypto portfolio value.

The Davochain mark leads money values, followed by = standard naira value and approximate USD. Crypto quantities remain explicitly denominated in BTC/ETH/etc; equivalent value must not be mistaken for a separate cash holding. Hidden values conceal all three denominations and quantities. Missing quotes show unavailable rather than fabricated zero values.

The catalog already has ten assets with logos (Solana uses the existing drawn mark). Expose those before adding speculative assets without quotes or wallet contracts. Receiving/external-withdrawal support remains explicit: only issued/supported network routes can be selected. Internal transfers can use quoted holdings without inventing a blockchain address.

Replace redundant plus/add pickers with searchable complete wallet pickers. Davochain Naira stays the cash option. Redesign internal transfer inputs using the existing form vocabulary: readable labels, consistent minimum field heights, aligned quantity/actions, sensible keyboard focus and a clear recipient context. Preserve exact amounts, review/PIN gates and account-generation guards.

## Task 1: Shared ordering projection

Files: new lib/features/wallets/asset_catalog_projection.dart; test/asset_catalog_projection_test.dart.

- [x] Write RED tests for zero holdings, USD-equivalent value order, ties, popular/alpha fallback, search and five-item limit.
- [x] Implement pure projection over existing catalog and exact snapshot values; run GREEN.
- [x] Commit independently verified projection.

## Task 2: Portfolio, Home and value hierarchy

Files: dashboard_screen.dart, components/dashboard_panels.dart, components/portfolio_panels.dart; a reusable value widget under shared/widgets; relevant performance/asset value cards where applicable. Tests: asset_catalog_presentation_test.dart, existing dashboard/portfolio/accessibility suites.

- [ ] Write RED widget tests for all-zero searchable Portfolio, funded ordering, Home limit five and custom-mark/equivalent/hidden values.
- [ ] Replace funded-only/default toggle with always-visible catalog/search; keep allocation mathematically unchanged. Home uses shared ordering and five-item cap, and each asset opens its supported detail or honest availability page.
- [ ] Use custom-mark primary valuation with naira/USD secondary values and clear crypto quantity; run focused GREEN and commit.

## Task 3: Searchable receiving/withdrawal pickers

Files: new features/wallets/presentation/wallet_picker_sheet.dart; dashboard components/deposit_screens.dart and callers; crypto_full_flow.dart. Tests: wallet_picker_search_test.dart plus navigation/withdrawal suites.

- [ ] Write RED for search name/ticker, Davochain cash option, all catalog logos, zero/funded ordering, no redundant plus and unavailable network support.
- [ ] Reuse one picker component, remove obsolete add-only branches and keep supported routes explicit. Do not generate fake QR/address details for new rows.
- [ ] Verify cash withdrawal still reaches linked banks and crypto routes remain correct; run GREEN and commit.

## Task 4: Internal crypto transfer form

Files: crypto_full_flow.dart and existing inline/form widgets where required; test/internal_transfer_layout_test.dart and existing withdraw_refinement_test.dart.

- [ ] Write RED for minimum field height, aligned inputs/amount, keyboard/200-percent text, asset selection, Max exactness and stale-account invalidation.
- [ ] Improve recipient and amount layout using consistent native form controls, explicit crypto quantity/value, and stable bottom action. Preserve accepted operation/review behavior.
- [ ] Run GREEN, then one batched light/dark/phone/large-text capture round. Fix material defects in one pass and confirm.

## Task 5: Final verification and main release

- [ ] Get one fresh independent review of the complete change and resolve important findings.
- [ ] Run full regression and static analysis; build a new APK after build56 checkpoint.
- [ ] Inspect native results where the shared emulator is available, preserve data, document backend/device limits and push verified main commits.
