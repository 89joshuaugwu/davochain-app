# Davochain Figma Asset Audit — V6 Cumulative

This pass continues the V5 Flutter implementation and audits the currently built product surface against the current Davochain Figma source.

## Screen coverage

- Splash and onboarding
- Country selection, sign up, login, password recovery
- Verification / OTP / transaction-PIN states
- Dashboard
- Portfolio and wallet-selection sheets
- Crypto deposit and share/copy states
- Davochain NGD bank-deposit flow
- Buy Crypto selectors, amount, review, PIN, processing, success, and transaction details

## Asset corrections retained in V6

- Splash uses the recovered Figma cobalt background composition with lower crypto artwork rather than a simplified replacement.
- Dashboard uses local profile, balance-wave, promo, quick-action, notification/earn, navigation, and token artwork.
- Corrupt/duplicate profile and promo exports from the interrupted transfer were replaced with valid packaged images.
- BTC, ETH, SOL, USDT, and USDC token artwork is packaged locally and wired into the relevant screens.
- BTC deposit retains the source QR artwork; ETH, SOL, USDT, and USDC have packaged local QR images tied to their prototype wallet strings.
- The former pseudo-QR painter/placeholder path is removed.
- The former hand-drawn Nigeria flag substitute is removed from both Buy Crypto funding-wallet presentations and replaced by the packaged flag asset.
- Dormant token/balance/promo painter approximations were removed so they cannot silently reappear as fallbacks.
- The verification smoke test now imports the current package name (`davochain`) rather than the obsolete package identifier.

## Validation boundary

Static verification in this handoff checks asset resolution, image decodability, branding/package-name regressions, stale painter references, basic source delimiter balance, and ZIP integrity. The Flutter/Dart SDK is not installed in this execution environment, so `flutter test`, `flutter analyze`, and a device build cannot be executed here; those commands must be run in a Flutter-enabled development environment before release.

## Typography boundary

Screens reference Sora to match Figma. Font binaries are not bundled in this source handoff; the host application should supply the approved Sora configuration before final pixel-level typography QA.
