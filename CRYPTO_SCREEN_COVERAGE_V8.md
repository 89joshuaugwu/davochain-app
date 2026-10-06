# Davochain Crypto Screen Coverage — v8

Authoritative Figma section: `7319:55770` in **Davopay and Davochain**.

The section contains **61 top-level Figma frames/states**. v8 maps them into reusable Flutter flows rather than duplicating near-identical PIN/progress/success/detail pages.

## Implemented flow families

- **Fiat withdrawal**: wallet selection, amount/payment method, add payment method, add bank, bank selection, saved bank, confirmation, PIN inactive/active behavior, submitted toast.
- **Crypto withdrawal — Davochain user**: withdraw mode, username/amount inactive+active state, review, PIN, processing, success, transaction details, transfer receipt.
- **Crypto withdrawal — external wallet**: address entry, QR/paste screen, network selection, prohibited-entity warning, filled/confirmed states, cancel reminder, PIN, processing, success, transaction details, blockchain-oriented receipt.
- **Deposit status**: pending and successful detail states with network, timestamp, address, transaction hash, and copy actions.
- **Swap / Convert**: inactive/active input state, review conversion, processing, success, details, conversion receipt.
- **Sell**: cryptocurrency selector, sell-into wallet selector, inactive/active amount state, confirmation, processing, success, sell transaction details.
- **Buy**: preserved v7 selector → funding wallet → inactive/active amount → review → PIN → progress → success → details implementation.

## Shared-state mapping

Figma repeats multiple security and result frames. v8 uses stateful shared components for those exact patterns:

- `CryptoPinScreen` covers the repeated inactive/active PIN frames.
- `TransactionProgressScreen` covers internal transfer, external transfer, sell, and conversion progress states.
- `TransactionSuccessScreen` covers transfer, sell, and conversion success states.
- `TransactionDetailsScreen` covers internal/external transfer details and receipts, sell details, conversion details and receipts.
- `TradeAmountScreen` owns the inactive/active Sell and Convert states.

## Exact asset policy

Unique Figma assets used by the new flows are packaged under `assets/images/figma/crypto_full/`. Existing exact Buy/Dashboard Figma assets are reused where the design uses the same visual. No web-hosted Figma URL is required at runtime.

## Validation boundary

This workspace does not include Flutter/Dart SDK binaries, so `flutter analyze`, `flutter test`, and a real device build must still be run in a Flutter environment. Static source/asset/ZIP integrity checks are performed before packaging.
