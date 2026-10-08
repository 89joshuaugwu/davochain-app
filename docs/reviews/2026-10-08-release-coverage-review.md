# Release coverage review - 8 October 2026

Read-only source/APK audit before the new build. No device walkthrough, launch, release build, or runtime coverage is claimed. Current source was being updated in parallel; findings describe the inspected snapshot.

## Existing artifacts and asset coverage

- `build/app/outputs/flutter-apk/app-debug.apk`: 172,898,715 bytes; filesystem modified 7 October 2026 22:13:23.
- `build/app/outputs/flutter-apk/app-release.apk`: 65,357,471 bytes; filesystem modified 7 October 2026 22:18:40. Both predate today's edits; matching assets do not prove matching Dart behavior.
- The old APK checkpoint used version `0.10.0+11`, nine asset directories and Sora weights 400/500/600/700. Enumerating immediate files in those declared directories plus the declared font yields 724 assets. Both APK ZIPs contain exactly those 724 under `assets/flutter_assets/`, with no omissions, extra asset paths, or differing source asset bytes (SHA-256 comparison).
- Source scan resolved 206 unique literal/constant-root asset references; none were missing on disk or in either APK. Constant roots such as `$_f`, `$_exactAssets`, and `$_iconRoot` were substituted per file. The two remaining computed tier paths in `profile_settings_flow.dart` resolve to `tier_1_exact.png`, `tier_2_exact.png`, `tier_3_exact.png` for existing UI tiers 1-3; all exist and are packaged. This is a bounded source scan, not proof for arbitrary runtime path inputs.
- Both `FontManifest.json` files declare MaterialIcons, Sora and CupertinoIcons. Sora font bytes match the current declared font (111,400 bytes). MaterialIcons is 1,645,184 bytes in debug versus 3,352 in release, consistent with icon tree shaking. Asset/font parity therefore looks sound for the previous build.

## Release-specific behavior

- `rg` found no `kReleaseMode`, `kDebugMode`, `kProfileMode`, `bool.fromEnvironment`, or `dart.vm.product` branches in `lib/`/`android/`; no custom dynamic `IconData(...)` construction in `lib/`. Existing constant `Icons.*` references should be discoverable by the new build's icon tree shaker; the old release icon subset cannot validate newly added icons until rebuilt.
- Only two application assertions were found: positive success-mark size (`davo_success_mark.dart:12`) and an icon/asset constructor precondition (`dashboard_screen.dart:911` at inspection). These check developer parameters; financial/authentication decisions do not rely on assertions. Assertions disappearing in release does not enable a hidden real transaction path.
- Runtime dependencies in `pubspec.yaml` remain Flutter, `cupertino_icons`, and `flutter_svg`; no production API/auth/payment integration is configured by these changes. Local demo interactions and static transaction records remain demo behavior in release.
- `android/app/build.gradle.kts` still uses `com.example.davochain` and the debug signing configuration for release. Existing APK is a device-preview artifact, not a store-signing milestone. Do not print key material.

## Outstanding sample-data inconsistencies

- History buy (`transaction_history_screen.dart:14,106`) reports 0.0300 BTC and builds a NGN 720,000 order. `buy_crypto_models.dart:5,70-71` gives exactly 0.03 BTC but $492.11 USD; other crypto detail screens display a fixed $500.00 for 0.03 BTC (`crypto_full_flow.dart:2585` at inspection). Values come from different mock assumptions.
- History deposit advertises +0.0300 BTC (`transaction_history_screen.dart:22`), while its `DepositStatusScreen` displays 0.0317934 BTC (`crypto_full_flow.dart:3760` at inspection).
- Conversion details pair 0.03 BTC with 500 USDT but display 1 USDT approximately 0.0000345 BTC (`crypto_full_flow.dart:2703,2789`). That rate gives 0.01725 BTC for 500 USDT, not 0.03 BTC.
- Sell uses a fixed NGN 731,540.00 output and $500.00 presentation independent of input amount. External/other crypto receipts also use fixed USD presentation. Buy details use `DateTime.now()` (`buy_crypto_screens.dart:503`), while history labels and crypto details use separate static dates. These remain sample records; aligning rows does not reconcile financial truth.
- Existing copyable sample IDs like `0x3a4f...9c7d` are deliberately abbreviated sample strings. Copy now preserves the supplied full raw string/address/hash; no nonexistent ID suffix was invented.

## What the stale release does not cover

The existing APK predates today's shared `ReceiptDetailRow`, `DavoSuccessMark`, and `DavoResultScreen` source additions and their integration. Current source has consistently aligned receipt columns, complete wrapping/copy for long values, gift-result content scrolling with pinned actions, and revised finite success/result screens across auth, crypto/trade, gift and profile verification. Current dashboard and splash source also has today's adjustments. The old release cannot be used to accept these fixes even though every asset already exists in its archive.

Rebuild the current release, then validate the revised flows on the target device, particularly narrow/enlarged-text receipt rows, copied hash/address completeness, result actions, reduced-motion outcomes, dashboard assets, splash handoff and new copy icon rendering. Focused widget verification is recorded by the implementation work; this audit adds packaging/source evidence only.


## New artifact verification by the integration pass

The new 0.11.0+12 release (65,456,355 bytes) and debug (163,720,572 bytes) APKs were built after integration. Both contain all 724 declared source assets/font files, with zero missing ZIP entries and zero SHA-256 byte mismatches. Release MaterialIcons is 4,116 bytes after newly used icons were retained. Android package metadata verifies versionCode12/versionName0.11.0: physical phone is release (no DEBUGGABLE flag), emulator is debug. The bounded phone walkthrough verifies fixed-header asset scrolling, explicit fingerprint setup, splash-to-returning preview, simulated fingerprint unlock and logout-to-Login. Full source checks: 81 passing tests, analyzer clean. See DEVELOPMENT_CONTEXT.md for logs and screenshot evidence. Historical sample-data inconsistencies above remain preview data limitations; this build does not provide backend settlement/authentication.
