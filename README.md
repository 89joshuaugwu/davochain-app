# Davochain Flutter App

Current milestone: **v4 Dashboard + Deposit Flow**.

## Included

- Davochain branded native + Flutter splash matching the cobalt Figma treatment
- Animated onboarding carousel/state flow
- Multi-country account setup (Nigeria, Ghana, Kenya, South Africa, UK, US)
- Create account, password strength, login and forgot-password flows
- Email/SMS OTP verification with shake + haptic error feedback
- Transaction PIN creation/confirmation
- Davochain dashboard matching the connected Figma dashboard section
- Portfolio view and allocation states
- Deposit wallet selector + add-currency bottom sheet
- Crypto deposit screen with QR/address/copy/guidelines/share UI
- Davochain NGD bank-deposit screen with copy/share states
- Figma-style copied-success toast
- Shared navigation and motion transitions

## Run locally

```bash
flutter pub get
flutter run
```

If your local project already has `android/` and `ios/`, keep those folders and merge this source into the project. Run `setup_windows.bat` after merging when native splash assets change.

## Native splash

The native splash configuration is in `pubspec.yaml`. To regenerate it manually:

```bash
dart run flutter_native_splash:create
```

## API status

This milestone is frontend/prototype wiring. Authentication, live balances, crypto settlement, bank account generation, real OTP validation and real transaction APIs still need the Davochain backend endpoints.
