# Davochain Flutter App

Current milestone: **v12 frontend handoff and native mobile preview preparation**. See [DEVELOPMENT_CONTEXT.md](DEVELOPMENT_CONTEXT.md) for architecture direction, mock/backend boundaries, and remaining review work.

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

This working project contains the native Android and iOS runner folders retained when importing the latest frontend handoff. The native splash includes custom Android animated-dot resources. Preserve those resources when changing splash artwork; the generator does not reproduce the custom animation.

## Native splash

The generator configuration is retained for reference. Running `dart run flutter_native_splash:create` can overwrite the custom Android 12 animated-dot styles. Reapply the custom drawable, animator and versioned styles before building if regeneration is needed.

Launcher icons are configured with the supplied Davochain artwork. To regenerate them after changing that artwork:

```bash
dart run flutter_launcher_icons
```

## Backend status

This milestone is frontend/prototype wiring. Authentication, live balances, wallet-address generation, crypto settlement, bank-account generation, real OTP validation, payment execution, and transaction APIs still require the Davochain backend.

The Buy Crypto flow intentionally uses local/mock quote and balance data. See `BUY_CRYPTO_IMPLEMENTATION.md`.

## Font integration note

The UI specifies the **Sora** family to match Figma. The variable Sora font is bundled under `assets/fonts/sora/` with its OFL license and registered at weights 400, 500, 600 and 700 in `pubspec.yaml`. It is packaged in both debug and release builds.


## Cumulative v8 crypto-board pass

The authoritative Figma crypto section (`7319:55770`) contains 61 top-level states. v8 adds the missing Withdraw, Sell, Swap/Convert, deposit-status, network/scanner/safety, PIN, progress, success, detail, and receipt states while preserving the v7 Buy and splash fidelity work. See `CRYPTO_SCREEN_COVERAGE_V8.md` and `FIGMA_ASSET_AUDIT_V8.md`.
