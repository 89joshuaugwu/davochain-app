# Gift Card Figma Asset Audit — v9

All Gift Card-specific runtime visuals are stored locally under:

`assets/images/figma/gift_cards/`

The app does not depend on expiring Figma URLs at runtime.

## Original Figma raster/image assets

- `amazon.png` — Amazon brand artwork.
- `apple.png` — iTunes/Apple brand artwork.
- `google_play.png` — Google Play brand artwork.
- `steam.png` — Steam brand artwork.
- `razer.png` — Razer Gold brand artwork.
- `walmart.png` — Walmart brand artwork.
- `ebay.png` — eBay Gift Card brand artwork.
- `amex.png` — American Express Gift Card artwork.
- `apple_card_photo.jpg` — exact uploaded physical-card photo used by the active Sell Card Figma state.

## Exact Figma UI/icon exports

- `search.png`
- `gallery.png`
- `check_mark.png`
- `user.png`
- `gift.png`
- `mail.png`
- `phone.png`
- `clock.png` — node `7319:59888`
- `wallet.png` — node `7319:60193`
- `trend.png` — node `7319:60209`
- `lightning.png` — node `7319:60118`

## Shared audited Davochain assets reused

The Gift Card flow reuses the already-packaged Figma-derived Davochain assets for back navigation, copy, PIN shield, PIN backspace, lock/security and other shared controls instead of introducing generic Material substitutes.

## Validation

- No `Icons.*` usage in `gift_card_flow.dart`.
- No `CustomPainter` / `CustomPaint` visual substitutes in the Gift Card module.
- All local raster assets passed decode verification during the v9 packaging pass.
