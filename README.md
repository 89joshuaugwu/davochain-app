# Davochain Flutter App

Current milestone: **Figma fidelity cumulative audit — v6**.

## Included

- Davochain branded native + Flutter splash using the recovered cobalt Figma background artwork
- Three onboarding states with packaged illustration assets
- Multi-country account setup and authentication screens
- Email/SMS OTP verification, password recovery, and transaction-PIN flows
- Davochain dashboard with packaged Figma avatar, balance-wave, promo, action, notification, and navigation artwork
- Portfolio and wallet-selection states with packaged BTC, ETH, SOL, USDT, and USDC artwork
- Deposit wallet selector and add-currency bottom sheet
- Crypto deposit screen with local QR/address/copy/guidelines/share UI
- Davochain NGD bank-deposit screen with account copy/share states
- Buy Crypto frontend flow with cryptocurrency/funding-wallet selection, amount entry, review, PIN, processing, success, and transaction details
- Exact packaged Nigerian flag artwork in the Naira funding-wallet states
- Shared navigation, motion, success-toast, and modal behaviors

## Run locally

```bash
flutter pub get
flutter test
flutter analyze
flutter run
```

If your full repository already contains `android/` and `ios/`, keep those platform folders and merge this source into that project. When native splash assets change, regenerate the splash from the included `flutter_native_splash` configuration.

## Native splash

```bash
dart run flutter_native_splash:create
```

The source snapshot includes the native splash artwork/configuration, but not generated Android/iOS runner files.

## Backend status

This milestone is frontend/prototype wiring. Authentication, live balances, wallet-address generation, crypto settlement, bank-account generation, real OTP validation, payment execution, and transaction APIs still require the Davochain backend.

The Buy Crypto flow intentionally uses local/mock quote and balance data. See `BUY_CRYPTO_IMPLEMENTATION.md`.

## Font integration note

The UI specifies the **Sora** family to match Figma. Font binaries are not bundled in this handoff, so the host Flutter app should provide its licensed/approved Sora font setup (or an existing project font configuration) before pixel-level typography QA.
