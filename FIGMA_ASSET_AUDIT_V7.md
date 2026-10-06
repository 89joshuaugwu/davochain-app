# Davochain Figma Asset Audit — V7 Cumulative

This pass continues the V6 Flutter implementation and adds the Buy Crypto + splash fidelity/motion corrections requested from the current Davochain Figma source.

## Splash / launch

- Flutter splash now follows Figma node `7319:54308`: cobalt field, wide center oval, large Davochain logo + wordmark, and oversized outlined crypto artwork bleeding off the bottom edge.
- The previous fitted layout that visually shrank the lockup has been replaced with a fixed-proportion Flutter composition.
- Native Flutter animations add a restrained entrance/float and a smooth handoff to onboarding.
- Android 12 native splash branding strip is removed because Android scales that optional strip into a tiny bottom element; the OS splash uses the centered mark, then hands off to the full Flutter composition.
- Pre-Android-12/iOS native splash retains the packaged Davochain lockup.

## Buy Crypto

- Cryptocurrency and funding-wallet sheets use packaged Figma token/flag assets.
- Review confirmation now routes through the four-digit PIN authorization state.
- Exact packaged Figma assets are used for back, close, PIN shield, lock, keypad backspace, review direction, process artwork, and transaction copy action.
- The former processing custom painter and generic Material icon substitutes are removed from the Buy Crypto implementation.
- Processing receives only a subtle native pulse around the Figma visual.
- Transaction Details is realigned to the current Figma structure and action hierarchy.

## Validation boundary

Static verification in this handoff checks image presence/decodability, stale painter/icon regressions, source delimiter balance, references, and ZIP integrity. The Flutter/Dart SDK is not installed in this execution environment, so `dart format`, `flutter analyze`, `flutter test`, and a device build could not be executed here. Run those commands in a Flutter-enabled development environment before release.

## Typography boundary

Screens reference Sora to match Figma. Font binaries are not bundled in this source handoff; the host application should supply the approved Sora configuration before final pixel-level typography QA.
