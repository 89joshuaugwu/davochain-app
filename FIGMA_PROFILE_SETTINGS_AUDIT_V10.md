# Figma Profile / Settings Audit v10

## Source
- File: `z5bMfbhPLQQyZUK8lHU5jo`
- Section: `7319:60302`
- Target stack: Flutter / Dart
- Primary design family: Sora typography, `#135CF7` Davo blue, white surfaces, `#F8F9FB` grouped settings cards.

## Design-system decisions
- Kept the existing cumulative Davochain Sora typography and app color tokens.
- Preserved 390px Figma mobile composition through responsive Flutter padding instead of hard-coding a phone canvas.
- Reused the already-exported Figma profile raster from v9; no remote image dependency was introduced.
- Common Figma icon geometry is represented with native Flutter vector icons at the same 16/24/32px visual sizes, inside the Figma `#EAEef6` icon containers.
- No screenshot is used as a screen background. All layouts remain native, selectable, scrollable, and interactive.

## Interaction audit
- All buttons and chevrons with a meaningful destination are wired.
- Duplicate Figma frames were implemented as state variants rather than copied screens.
- Inputs are editable; PIN and verification fields accept numeric input.
- Upload and social actions open native modal surfaces.
- Notification filters, transaction-limit tabs, switches, referral/reward navigation, support-chat branches, and KYC flow are interactive.

## Existing cumulative work preserved
- Authentication/onboarding
- Dashboard
- Buy/Sell crypto and portfolio/deposit/withdrawal flows
- Gift Card buy/sell module from v9
