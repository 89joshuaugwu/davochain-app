# Davochain v12 — Progress / Success / Detail / Receipt Final Pixel Pass

Status: **CLOSED for every Figma-backed transaction frame in this scope.**

This pass continues the cumulative v12 tree. It does not rebuild completed Buy/Sell/Convert review screens, modal sheets, deposit screens, Profile/Settings, or PIN work.

## Figma source frames audited

### Progress
- `7319:56855` — Internal crypto withdraw progress
- `7319:56869` — External crypto withdraw progress
- `7319:56883` — Conversion progress
- `7319:56895` — Sell progress
- `7319:56907` — Buy progress

### Success
- `7319:56919` — Internal transfer success
- `7319:56937` — External transfer success
- `7319:56955` — Conversion success
- `7319:56972` — Sell success
- `7319:56989` — Buy success

### Transaction details
- `7319:57006` — Internal transfer details
- `7319:57063` — External transfer details
- `7319:57134` — Conversion transaction details
- `7319:57219` — Sell transaction details

### Receipts
- `7319:57313` — Internal transfer receipt
- `7319:57381` — External transfer receipt
- `7319:57463` — Conversion receipt

## Progress/success geometry verified

- Back control is the Figma 24×24 asset at absolute `x=8, y=60`.
- Progress/success artwork is 150×150 at `x≈120, y=135`.
- Progress title baseline starts at `y=301`; optional destination line starts at `y=327`; helper copy follows at `y=331/354` as designed.
- Transfer success title is 20px Sora Bold at `y=301`; success body begins at `y=336`.
- Internal-transfer success uses the one-line body and buttons at `y=669` / `733`.
- External/conversion/sell/buy success use the two-line body and buttons at `y=688` / `752`.
- Exact mixed text styling was preserved: muted sentence text with dark/semibold transaction values according to each Figma frame.
- Buy progress/success retain the Figma wording, including the source design's `Sold  Successful` title on the Buy success frame.

## Transaction-detail corrections completed

All four Figma-backed detail variants now use the exact card heights/positions:
- Internal: card `358×287` at `x=16, y=279`; actions at `y=668/729`.
- External: card `359×375` at `x=16, y=271`; actions at `y=688/749`.
- Conversion: card `359×385` at `x=16, y=224`; actions at `y=651/712`.
- Sell: card `359×483` at `x=16, y=224`; Done at `y=762`; no invented Share Receipt button.

The final correction pass also fixed details the earlier generic row implementation missed:
- Exact Wrapped-BTC, classic BTC, USDT and Nigeria asset wrappers.
- Exact approximately-equal symbol geometry.
- Sell `Amount` row restored at the Figma position.
- Conversion/Sell `From` and `To` compound amount/currency blocks use exact positions.
- External full transaction hash restored instead of an abbreviated hash.
- External and conversion Blockchain Explorer rows restored.
- Exact 16×16 transaction copy asset replaces the previously scaled approximation.
- Exact 24×24 chain-link Figma asset replaces the unrelated paperclip icon.
- Network Fee `Free` remains Davochain blue exactly as Figma specifies.

## Receipt corrections completed

- Header title remains `Transaction Details` with Sora SemiBold 14 at the exact header baseline.
- Davochain receipt lockup now uses the exact supplied **26×26** Davochain Figma logo rather than resizing the 32px variant.
- Receipt card starts at `x=16, y=212` in all three receipt frames.
- Exact 32×32 pale-orange BTC wrapper restored in the receipt summary row.
- Internal receipt card: 358×379.
- External receipt card: 358×468 with transaction hash + Blockchain Explorer.
- Conversion receipt card: 358×502 with exact Wrapped-BTC/USDT blocks, exchange-rate symbol and Blockchain Explorer.
- `Thank you for using Davochain` plus `Build. Trade. Belong.` positions match each receipt frame.

## Exact local assets added/normalized in this pass

- `tx_btc_24_exact.png`
- `receipt_btc_32_exact.png`
- `tx_wrapped_btc_24_exact.png`
- `tx_usdt_24_exact.png`
- `tx_nigeria_24_exact.png`
- `tx_approx_12_exact.png`
- `tx_copy_16_exact.png`
- `tx_link_24_exact.png`
- `receipt_davochain_26_exact.png`

These are local runtime assets derived from the already-supplied exact Figma sources/geometry. No generic Material icons were introduced for the audited Figma transaction frames.

## Buy-specific detail/receipt design note

Figma contains explicit **Buy Progress** and **Buy Success** frames, and those are included in this pixel pass. The inspected transaction group does **not** contain a separate Buy-specific Transaction Details or Buy Receipt frame after `7319:56989`; the following detail frames correspond to internal transfer, external transfer, conversion, and sell. Therefore the existing functional `BuyTransactionDetailsScreen` was not falsely labeled as pixel-identical to a nonexistent Figma frame and was not rebuilt in this pass.

## Scope boundary

This checkpoint does **not** perform the next open task: transaction-flow CTA/back/cancel navigation cleanup. That remains separate so completed pixel work is not repeated.
