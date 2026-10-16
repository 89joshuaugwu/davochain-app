# Selected Davochain Naira currency mark

Selected by the product owner on 16 October 2026. The D-shaped bowl relates to the existing Davochain identity; two horizontal strokes establish its currency use. No detached dot is placed beside amounts because it could be read as a decimal point.

- `currency-mark.svg`: scalable monochrome master using currentColor.
- `currency-mark-preview.png`: light/dark and size proof, with illustrative balances.
- `currency-mark-blue.png`: transparent blue raster export.
- `davochain-currency-proposal.ttf`: original review font with private-use U+E900, retained as design provenance. Production copy is registered as DavochainCurrency in pubspec.
- `generate.py`: reproducible source (Python with Pillow/fontTools), using the bundled Sora/Noto fonts for the proof.

Use the mark before branded Davochain Naira amounts, aligned to the numeral baseline. It inherits text color and accessibility scaling. Use full grouped amounts and two decimal places. The unit represents exactly NGN 1.

Implementation: `DavoNairaAmount` supplies exact minor-unit display, negative sign, masking and semantic text. `DavoCurrencyMark` displays the standalone unit. The first integration is the existing Davochain Naira Buy funding row; the separate wallet-consolidation plan governs rollout across the other money flows.

For plain-text clipboard, notification bodies, bank contracts and external apps, use an explicit readable denomination instead of a private-use glyph. This asset does not assign a public Unicode character or change the underlying currency code.

Verification: exact grouped/negative/masked amounts and screen-reader labels passed with the buy/quote/trade-layout regressions (16 tests). Vector/font proof inspected at large and everyday sizes on light/dark surfaces. No debit/credit routing changed in the symbol integration.
