# Optimized Android APK for local testing

This build uses Flutter release compilation and the existing development signing identity. It can update current local installations when certificate fingerprints match. It does not configure a permanent application identity, production signing key or backend services.

From the project directory on Windows:

```powershell
powershell -ExecutionPolicy Bypass -File tool/build-local-release.ps1
```

Output: `build/app/outputs/flutter-apk/app-release.apk`. The helper temporarily sets `DAVOCHAIN_LOCAL_TEST_RELEASE=true`, passes `DAVOCHAIN_ENV=development`, and restores the prior environment value even on failure. The package remains `com.example.davochain` and uses the existing Android development keystore. No new signing key or password is created.

Without explicit local-test opt-in, release tasks retain the managed production identity/certificate checks. Local-test signing rejects app bundles and `DAVOCHAIN_ENV=production`. The normal production entrypoint also continues to reject local service providers. Do not upload this APK to a store or treat development account data as server data.

For eventual store publication, the owner must supply the final application ID and an existing or newly managed upload key, with secure backup and restricted credential storage. Play App Signing distinguishes the upload key from the app-signing key used for distributed installations; record the correct certificate fingerprints when configuring Firebase or other Android integrations. See [Android app signing](https://developer.android.com/studio/publish/app-signing) and [Flutter Android deployment](https://docs.flutter.dev/deployment/android).

## Phone layout coverage

`test/phone_size_matrix_test.dart` exercises dashboard, portfolio, transaction history, notifications, gift-card catalogue, settings, buy and sell at logical phone sizes 320x568, 360x640, 393x852 and 480x960. Each size runs at normal and 200% text, includes top/bottom safe-area insets, and checks both initial and scrolled content using the supplied Sora font. Normal-text checks use light appearance; enlarged-text checks use dark appearance. This is 64 automated combinations, not an exhaustive certification of every handset.

Existing keyboard/form checks additionally cover a 250-pixel keyboard inset on short screens, enlarged OTP text, trade forms, gift review, profile forms and accessible control targets. The app currently supports portrait orientation. Actual vendor keyboard, cutout, screen reader and frame-timing behavior still requires device acceptance.

Font-backed visual inspection found crowded portfolio headings, split monetary values and shortened dashboard labels at enlarged text. Headers separate their controls when needed, dashboard actions stack on constrained layouts, balance values fit on one line with their complete semantics, allocation rows place amounts on a separate line, and navigation labels stay intact. Catalogue brand tiles reflow at large text; its referral panel moves into scrolling content to preserve useful viewport space. Normal layouts retain the existing brand and actions. Two focused usability regressions reproduced the earlier heading/button issues before the fixes and passed afterward.

Gradle is limited to two workers with a 4 GB maximum JVM heap to avoid the observed memory pressure during native release builds on the 16 GB development computer. These are build-host resource limits, not measurements or limits on the mobile app's memory. Local-test APKs skip native R8/resource shrinking to retain useful plugin diagnostics and avoid the expensive first shrink pass; Flutter Dart code still uses optimized release compilation and the APK is not debuggable. Store release builds keep native shrinking enabled.

Optional visual evidence:

```powershell
flutter test test/phone_size_matrix_test.dart --dart-define=CAPTURE_PHONE_MATRIX=true
```

This produces 12 bounded dashboard/portfolio/catalogue captures for the smallest and largest phone sizes at both text scales in `../tmp/phone-size-review/`.

## Verified build 40

Version `0.16.1+40`: the full suite passed **560 tests**, with **11 optional captures skipped**. Final targeted layout/usability/asset-scroll verification passed **73 tests**, including all 64 phone-size combinations. The final analyzer reported no issues. Twelve font-backed captures were inspected.

The release build succeeded. APK manifest inspection confirms package `com.example.davochain`, version `0.16.1`, code `40`, and a non-debuggable application. `apksigner` verifies the signature and the certificate matches the previously installed debug APK, allowing an in-place update without clearing app data.

Artifact: `build/app/outputs/flutter-apk/app-release.apk`, **132,899,275 bytes**, SHA-256 `4FDBDAC9B866CF9A7415DF0F1ECC7D82382C6008CA2695304F7FAE421DFD6605`. This is an optimized development-signed release APK for local testing. Permanent production identity/signing, backend integration and device acceptance remain separate work.

Verification logs and captures are retained at project-level `review/evidence/local-release-40/`; installation status is recorded in `review/implementation-progress.md`.
