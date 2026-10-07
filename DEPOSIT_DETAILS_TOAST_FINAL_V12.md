# Davochain v12 — Deposit Details + Copy Toast Final Verification

This checkpoint closes only the remaining Deposit-final-verification items after the BTC/NGD screen patch. Figma was inspected read-only; no Figma content was edited.

## Figma references

- BTC Deposit: `7319:55142`
- NGD Deposit: `7319:55184`
- Copy toast: `7319:55296`
- Deposit Details — Successful: `7319:55771`
- Deposit Details — Pending: `7319:56399`

## Copy toast — CLOSED

The standalone Figma toast is exactly:

- 265 × 98
- radius 8
- `#1C1C1C`
- 16 px internal padding
- Sora Regular 16, 22 px line height
- text: `Copied Successfully. Please check when pasting to avoid malicious tampering`

Figma stores the toast as a separate frame beside the BTC Deposit screen (same section y-coordinate), not as an overlay inside the Deposit frame, so Figma does **not** encode a definitive overlay coordinate. The Flutter implementation therefore preserves the exact component and uses a deterministic app placement: horizontally centered, 24 px above the device bottom safe area. This placement is implementation behavior, not a fabricated Figma coordinate.

The previous generic SnackBar styling/centering was replaced by an exact 265 × 98 overlay component. Text is left-aligned as in Figma.

## Deposit Details — Successful — CLOSED

Matched to `7319:55771`:

- white root background
- back control: x=6, y=75, 32 × 32
- `Deposit Details`: x=116, y=77.5, 156 × 27, Sora Regular 20
- Quantity: x=103, y=150, 186 × 22
- amount: x=134.5, y=182, 123 × 22, Sora SemiBold 16
- exact 16 × 16 green success icon at x=103, y=207.5
- `Deposit Successful`: x=123, y=206, Sora Regular 14, `#1BA44D`
- source Figma message retained at x=27, y=252, 338 × 26
- detail card: x=17, y=305, 358 × 260, radius 8, `#F5F6F9`
- Network/Time/Deposit Address/Transaction Hash/Blockchain Explorer rows aligned to their Figma coordinates
- exact 16 × 16 copy glyph placement for address/hash
- exact 24 × 24 link-control placement

## Deposit Details — Pending — CLOSED

Matched to `7319:56399` while sharing the same detail-card geometry as Successful:

- exact amber pending icon at x=156.5, y=207.5
- `Pending`: x=176.5, y=206, Sora Regular 14, `#CC8408`
- the rest of the card remains identical to the successful frame

### Figma copy inconsistency intentionally preserved

The Pending Figma frame still contains the same message as Successful:

`Crypto has arrived in your davopay account. View your wallet account balance for more details`

This checkpoint does not silently rewrite that source copy. It remains identical to Figma until product/design explicitly approves different pending wording.

## Exact local runtime assets added

- `deposit_details_back_exact.png`
- `deposit_success_status_exact.png`
- `deposit_pending_status_exact.png`
- `deposit_details_copy_exact.png`
- `deposit_details_link_exact.png`

These were derived from the exact Figma vectors / supplied consolidated Figma assets rather than Material icons.

## Validation

- targeted Dart source delimiters/ordinary strings: balanced
- literal asset references in affected Dashboard/Crypto files: zero missing
- new PNG assets: valid
- no Figma edits were performed
- Flutter SDK is not available in this runtime, so `flutter analyze` / device rendering were not claimed
