# Trade and portfolio refinement ? 0.18.0+42

15 October 2026. Scoped UI refinement; existing repositories, exact money, account generation checks and transaction authorization remain authoritative.

## Decisions and behavior

- Portfolio Buy, Sell and Swap open the respective amount screen directly, with Back returning to Portfolio. They are action shortcuts, rather than a selected mode on Portfolio. Home's existing guided pickers remain available. Trade's bottom navigation retains its mode-switching behavior.
- Buy and Sell use shared pay/receive cards with visible named currency selectors, coin artwork and chevrons. Buy can change its funding wallet and receive coin. Sell can change its source coin; proceeds remain NGN. Quotes, wallet eligibility and transaction review still use the existing exact calculations.
- The shared coin modal searches supported names and ticker symbols case-insensitively, handles whitespace, gives a no-match state and preserves cancellation. Keyboard insets and scrolling remain protected. Unsupported coins are not introduced into trading by visual changes.
- Returning sign-in offers password and enabled fingerprint only. Payment PIN creation, recovery, attempt limits and transaction confirmation remain transaction features. Fingerprint settings distinguish password sign-in fallback from payment PIN fallback; the illustration is centered.
- Portfolio and withdrawal cards put the mountain lower, restore the approximate USD equivalent and keep amounts hidden together with their equivalent. USD is an indicative calculation using this snapshot's USDC/NGN price, with exact integer arithmetic; no fabricated FX service. Portfolio offers Refresh instead of a misleading live-connection claim. Withdrawal adds visibility control and anchors Continue above the keyboard/system inset.
- Performance uses the branded value summary, clearer period controls and a compact first-valuation state. A chart is only drawn for two or more real supplied valuations. Cash-flow-adjusted investment performance remains separate from simple value change. History in capture fixtures is test data, not invented account history.
- Home features three repeating, swipeable banners: existing crypto/gift-card campaign, portfolio tracking and the supplied referral campaign. Six-second dwell, 450 ms transitions, manual page dots and swipe navigation. No visible play/pause control, per the supplied reference. Autoplay suspends for inactive app, hidden main tab, covering route, current drag and reduced-motion/accessibility navigation preferences. Original raster art and supplied coin images remain unchanged; other art uses existing vectors. No new image-generation asset or dependency is required.
- Extra banner controls require full-page scrolling on shorter phones. The assets region remains independently scrollable, showing three rows before setup and four after setup when brought into view. Large text uses flowing content and taller banners.

## Verification

Full suite: 600 passed, 11 optional captures skipped. Final focused run: 33 passed, including fresh light/dark captures, coin switching, chart history/hidden states and carousel lifecycle/tab/route guards. After removing playback controls, 17 focused carousel/navigation/dashboard checks passed, including an assertion that neither playback button exists. The 64-case phone matrix and all banner variants at 200% text passed. Analyzer: no issues. Independent read-only code review: no blocking findings. Artifact identity and installation results are recorded in the workspace implementation ledger. Physical-phone acceptance, real biometric prompts, backend quote freshness, authoritative auth and production signing remain separate integration/device work. No state-management migration is included.

## Local Android artifact

- Optimized local release: `0.18.0+42`, package `com.example.davochain`, non-debuggable, development signed.
- APK: `build/app/outputs/flutter-apk/app-release.apk`, 133,649,886 bytes.
- SHA-256: `5ACBD0420FD92D678163B008885FA450BB0EAA397830448C94E88B083DE8A864`.
- Corrected local PowerShell wrapper: Java/native stderr warnings are retained; the native process exit code determines success. Actual release rebuild succeeded; a simulated nonzero exit still throws. No signing gate was relaxed.
- Phone `CI49FIXKM7BUOVA6`: in-place installation returned Success, version 0.18.0/code 42 confirmed; app launch requested on 15 October 2026.
- Emulator `emulator-5554`: version 0.18.0/code 42 confirmed; app launch requested.
