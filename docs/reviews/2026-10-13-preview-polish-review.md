# Preview polish review

The user supplied screenshots and drawings for consistent outline icons, main-page navigation, separated interactive notifications, local identity, image-only ID uploads, tapered face guidance, scanned previews and a 20-second transaction simulation. The implementation plan is `docs/superpowers/plans/2026-10-13-preview-polish.md`.

## Implemented

- Shared lazily mounted main shell preserves Home, Trade, Gift Cards and Settings state. Buy/Sell/Swap switch inside Trade; pushed detail routes cover the navigation. Accessible text scales increase navigation height; reduced motion disables the short selection fade.
- Settings outline SVGs use 1.5 stroke at 24 pixels. Dashboard asset viewport has a 10-pixel alpha fade at its scrolling edge.
- Notifications have category filtering, separators, detail pages and read indicators. Rewards deliberately has an empty state. Preference/channel switches retain their values within the local session.
- Registration supplies the local name/email/phone and clears the sample avatar. Explicit login loads the existing sample account. Successful Basic verification applies the identity draft. Native photo selection updates the shared avatar; only username is editable among personal fields. Verification badge colors represent unverified, Basic and Advanced states.
- ID selection uses a native image gallery and accepts validated JPG/PNG up to 5 MiB. Address evidence retains PDF support. Android Photo Picker is explicitly enabled because the installed plugin defaults to the older chooser before API 36. Front/back capture selection remains available.
- Uploaded thumbnails are larger, their filenames sit beneath them, Uploaded is green, Replace/Remove sit on the right, and the back-upload card is wider than the camera card. Large-text layouts stack the cards.
- Face guidance uses a tapered forehead/cheek/chin opening with external blur and 100 perimeter progress ticks. Real alignment/pose holds still gate capture. The first frontal photo is preserved through the right/left/nod sequence and revealed with an 850-ms scan before review. ID/address previews have a 1.6-second double scan. Reduced motion skips these decorative reveals.
- Explicit new local preview transactions enter Pending for 20 seconds, then update the same record to Completed. Result pages, details, open receipts and history resolve the shared identity. Reset cancels timers; historical/provider/failed records do not enter this simulation. History rows now share the same icon/amount/date/status layout. Naira withdrawal has a proper title/back control and a clear NGN balance label.

## Verification

- Full automated suite: 389 passed, 11 optional capture tests skipped (`tmp/build34-tests.txt`).
- Final analyzer: no issues (`tmp/build34-analyze.txt`). Image gateway/double-scan checks are included in the full suite.
- Navigation, identity, notifications, image validation, native picker source/cancellation, large text, reduced motion, detection holds, timer reset/reused IDs and live receipt updates are covered.
- Light/dark captures are in `tmp/preview-polish-review` and `tmp/updated-verification-review`; face frame capture is `tmp/face-oval-overlay-review.png`.
- Native build32 QA confirmed the selected BTC review rate and rounded quantity, normal transaction PIN wording, and a purchase result changing from Submitted to Successful while the same page remained open. Build31 QA confirmed all main roots retain navigation, inner pages hide it, modern Android Photo Picker updates the avatar, and notification filters/detail/read states work.
- New refresh checks cover partial assembly before release, cancellation, future-driven completion, duplicate-pull suppression, failure/retry, reduced motion and both theme renderings. The submitted status semantics now say Awaiting confirmation.

## Additional polish

- Customer-facing copy uses normal product wording; internal fixture and provider boundaries remain unchanged.
- BTC buy quantities consistently round to eight decimals without changing raw financial quantities; buy/sell exchange rates use the selected asset rather than a static USDT rate.
- Pull-to-refresh uses the original Davochain logo in three assembled pieces, a tapered blue orbital arc and 3.5% breathing motion. It floats in a 48px themed disc, does not move content down, pauses in the background and keeps a static assembled mark for reduced motion.

## Release artifact

Build `0.14.0+34`: `build/app/outputs/flutter-apk/app-release.apk`, 126,157,762 bytes. SHA-256 `33ea391199083e2e8199b73d15f19e76535663cb6776c7fcfb255b811b055c34`. AAPT confirms versionCode 34/versionName 0.14.0. All 790 declared assets/fonts match, with arm64-v8a, armeabi-v7a and x86_64 libraries. Installed and launched on emulator-5554. Native refresh screenshots are `tmp/qa34-refresh-pull.png` and `tmp/qa34-refresh-finished.png`; the indicator appears without a blank gap and clears after work. `tmp/qa34-logcat.txt` contains zero Flutter/layout/crash error lines. Final targeted checks: 7 passed (`tmp/build34-refresh-final.txt`), including the final orbital artwork rendering. Physical Redmi was disconnected at delivery.

## Boundaries

Identity, notification preferences and preview transactions are session-only. No funds move and local completion is not a provider result. Device permissions/camera/gallery are real. Physical human head poses and iOS cannot be fully verified on the Android emulator.
