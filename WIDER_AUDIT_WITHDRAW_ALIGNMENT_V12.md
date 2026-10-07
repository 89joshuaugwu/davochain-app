# Davochain v12 — Naira + Crypto Withdraw Alignment

Checkpoint scope: **only** Naira Withdraw full-screen alignment and final internal/external Crypto Withdraw full-screen polish. The previously closed modal/sheet checkpoint was not reopened.

Figma file: `z5bMfbhPLQQyZUK8lHU5jo` (`Davopay and Davochain`).

## 1. Naira Withdraw — closed

Primary states checked: `7319:56715` (base), `7319:58276` (amount + selected payment method), plus payment-sheet overlays already closed separately.

Exact geometry now represented in Flutter:

- dashboard header: x=16/y=60, 358×40 in the 390×844 design; avatar 40×40; Earn $5 pill 89×32; notification pill 32×32.
- balance card: x=16/y=116, 358×136, radius 16; exact wave art, eye indicator and text baselines.
- Amount field: x=16/y=276, 358×73, radius 4, `#FBFBFD` with `#EEF0F5` stroke. Label/value baselines match y=286/314.
- daily limit: y=361.
- Payment Method field: x=16/y=400, 358×73; label baseline y=410, value y≈438/439, exact 24×24 Figma chevron at x=338/y=424.5.
- Continue: x=16/y=746, 358×48. Figma shows the blue visual in the base state, so the app preserves that visual while blocking submission until the form is ready.

The previous general Column/Spacer layout was replaced with fixed Figma-coordinate positioning inside the existing SafeArea scaffold so the layout no longer drifts with intrinsic widget heights.

## 2. Internal Crypto Withdraw — closed

States checked: `7319:57559` (inactive) and `7319:57897` (active).

- header/balance/card positions retained because they already matched the exact coordinate system.
- Transfer To input: label y=221, input y=244, 358×48.
- Enter Amount: label y=316, input y=339, 358×48.
- exact `#EBEDF3` input strokes restored for the two white internal inputs.
- amount-row right padding corrected so the trailing USD value aligns to the Figma row width.
- inactive Continue keeps Figma `#D0DEFD`; active Continue keeps Davochain blue.
- active fiat-equivalent display now updates from the entered BTC amount while preserving the Figma sample equivalence (0.02 BTC → 500.00 USD).

## 3. External Crypto Withdraw — closed

States checked: `7319:57609` (inactive) and `7319:57688` (active), 390×945 design.

Verified exact vertical system:

- balance y=104; Address label/input y=221/244; Network y=316/339; Amount y=411/434; Available y=486; Withdrawal Notice y=532.
- bottom Receiving/Confirm dock remains y=805 with the Confirm button x=203/y=827.5, 171×48.
- Address input trailing controls preserve the exact address-book / separator / QR ordering and near-pixel positions.
- selected Bitcoin network now displays `BTC`, matching the active Figma state instead of the longer sheet label `Bitcoin (BTC)`.
- disabled Confirm background corrected to Figma `#EBEDF3` with disabled text `#9D9EA2`; active state remains `#135CF7` with light text.
- external input backgrounds remain Figma `#F5F6F9` and intentionally have no stroke.

## Exact local derivatives added

- `assets/figma_exact/naira_payment_chevron_exact.png` — rasterized from supplied exact `dashboard_crypto_icons__nav-arrow-up.svg`.
- `assets/figma_exact/naira_earn_gift_exact.png` — rasterized from supplied exact `dashboard_crypto_icons__ph_gift-light.svg`.
- `assets/figma_exact/chevron_down.png` — missing runtime alias restored from supplied exact `dashboard_crypto_icons__vuesax_linear_arrow-down.svg`; this fixes an existing unresolved asset reference without rebuilding that trade screen.

## Validation

- targeted Dart delimiter/string scan: PASS.
- all 47 unique `assets/figma_exact` references in `crypto_full_flow.dart`: resolved; 0 missing.
- no generic Material `Icons.*` references in the scoped Naira/internal/external withdraw implementations.
- Flutter SDK is not installed in this runtime, so `flutter analyze` / device rendering were not claimed.

## Do not redo

These two wider-audit items are now closed. Reopen only if the user supplies a newer Figma revision or a reproducible runtime screenshot mismatch.
