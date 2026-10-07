# Davochain v12 — BTC / NGD Deposit Final Patch

Scope of this checkpoint: only the BTC Deposit screen and NGD Deposit screen. Deposit Details, Copy-toast overlay placement, success/pending detail-state alignment, and Transaction PIN reconciliation remain separate follow-up items.

## BTC Deposit — closed

Figma reference: `7319:55142` (Deposit BTC Crypto Screen).

Verified and implemented:

- Back control: frame at x=6, y=75, 32×32, using a local raster generated from the exact `nav-arrow-left` Figma SVG. The visible arrow is inset to the same 8×16 geometry inside the 32×32 frame.
- `Deposit` header: Sora SemiBold 16, exact Figma title placement x=144, y=80, 66×22.
- QR region: outer 257×283 at x=66.5, y=131; image 247×273 inset 5px; 1px `#F5F6F9` stroke; centered white 48×48 Bitcoin badge at local x=105/y=118 with a 40×40 coin image.
- Deposit Address card: 358×91 at x=16/y=438, radius 8, `#F5F6F9`; inner content x=32/y=448 width 326; address row starts y=475 and uses 284px text space plus the exact 24×24 `ph:copy-thin` asset at x=334.
- Metadata rows remain at y=553/578/603/628 with 13px row heights.
- Guideline line remains at y=663.
- Bottom actions are now part of the scroll content rather than a viewport-pinned footer, so the collapsed Figma state lands exactly at y=843: two 171×48 buttons separated by 16px.
- `Share or save`: regular Sora 14, `#424242` on `#EEF0F5`.
- `Copy Address`: SemiBold Sora 14, `#EEF0F5` on Davochain blue.

## NGD Deposit — closed

Figma reference: `7319:55184` (Deposit Davochain NGD Screen).

Verified and implemented:

- Back control: x=6/y=75, 32×32 using the same exact deposit back asset.
- `Deposit` header: Sora SemiBold 16, exact Figma placement x=162/y=80, 66×22.
- Main horizontal content width adjusted to 359px (x=16 to x=375) to match this frame.
- Yellow information card: x=16/y=142, 359×121, radius 6, `#FEF7EA`; exact 17×17 info icon and the Figma heading/body baselines are preserved.
- Bank card: x=16/y=287, 359×223, radius 4, `#F5F6F9`.
- Account Name / Bank Name / Account Number rows remain 56px high with 8px row gaps and exact Sora label/value line heights.
- Copy visuals are now the exact 16×16 `copy` Figma asset, flush-right at x=343 rather than centered inside a generic 48px IconButton.
- Explanatory paragraph: x=43/y=534, 305×75.
- `Disclaimer`: y=631, 19px line; body starts y=666 and remains 70px high.
- `Share Details` is now inside the scroll content at exact y=802, 359×48, regular Sora 14 with the Figma foreground/background treatment.

## Exact local assets created from supplied Figma SVGs

- `assets/figma_exact/deposit_back_exact.png`
- `assets/figma_exact/deposit_btc_copy_exact.png`
- `assets/figma_exact/deposit_ngd_copy_exact.png`

These are rasterized local runtime derivatives of already-supplied exact Figma vectors; no generic Material substitutes were introduced.
