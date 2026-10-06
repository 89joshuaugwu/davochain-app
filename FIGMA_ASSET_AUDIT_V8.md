# Davochain Figma Fidelity Audit — Cumulative v8

Authoritative design sources:
- Crypto section: Figma node `7319:55770`
- Splash: Figma node `7319:54308`

## v8 correction

A complete inventory of the crypto section found **61 top-level Figma frames/states**. v7 was not complete: Buy was implemented, while Dashboard Withdraw and Sell were still routed to `coming soon` placeholders and Swap was not a real flow.

v8 removes those crypto placeholders and implements the missing flow families:

- Naira withdrawal and payment-method/bank setup states
- Davochain-user crypto withdrawal
- external-wallet crypto withdrawal
- QR/paste-address flow
- network selection and sanctioned-entity warning
- cancel/reminder state
- shared transaction PIN states
- crypto withdrawal processing/success/details/receipt states
- deposit pending/success details
- Sell selector/wallet/amount/review/progress/success/details states
- Swap/Convert inactive/active/review/progress/success/details/receipt states
- existing Buy flow preserved from v7

Repeated Figma frames are implemented as stateful/reusable Flutter components rather than duplicated source files. This preserves every visual/state outcome while reducing inconsistent copies.

## Exact Figma assets added for missing flows

`assets/images/figma/crypto_full/`
- `user_circle.*`
- `qr_wallet.*`
- `chevron_right.*`
- `bank.*`
- `plus_circle.*`
- `scanner_frame.*`
- `flashlight.*`
- `network_warning.*`
- `swap.*`

The PNG versions are local renders of the exact Figma vectors; SVG source exports are retained alongside them for auditability. Existing exact Figma assets are reused for BTC/ETH/SOL/USDT, Nigerian flag, Davochain logo, back/close/copy icons, PIN artwork, keypad backspace, balance artwork, and transaction processing artwork.

## Mobile interaction polish

- Existing `AppPageRoute` fade/slide/scale transitions remain the navigation baseline.
- New sheets use native modal motion with darkened barriers.
- Haptics are used for selections and primary confirmations.
- PIN cells animate between inactive/active Figma states.
- Progress artwork uses the exact Figma visual with a restrained pulse animation.
- success content uses a short fade/scale entrance.
- scanner/paste and Buy/Sell/Convert mode changes use `AnimatedSwitcher`/animated state changes.
- all lists and flow layouts remain native Flutter widgets.

## Static verification performed

- 19 Dart source files checked with a string/comment-aware delimiter parser: PASS
- 64 static asset references checked: PASS
- 76 PNG assets decoded successfully: PASS
- 18 SVG assets parsed successfully: PASS
- no `Icons.*` usage in the new full crypto flow: PASS
- no `CustomPainter` usage in the new full crypto flow: PASS
- Dashboard Withdraw placeholder removed: PASS
- Dashboard Sell placeholder removed: PASS
- Portfolio Sell wired: PASS
- Portfolio Swap wired: PASS
- nested `crypto_full` asset directory declared in `pubspec.yaml`: PASS

## Validation boundary

Flutter and Dart SDK binaries are not installed in this execution environment. Therefore `flutter analyze`, `flutter test`, and a real Android/iOS build could not be executed here. Run those immediately after opening v8 in a Flutter environment.
