# Reference fidelity corrections - 0.18.1+43

15 October 2026. Implements the user's marked screenshot corrections on top of 0.18.0+42. No repository/state-management migration or service endpoints added.

- Carousel restored to 106px compact / 121px standard, with indicators inside its existing bounds. Manual swiping and six-second automatic rotation remain; play/pause controls stay absent. Standard phones retain the stationary header and three complete initially visible assets. Short views and enlarged text remain scrollable.
- Portfolio banner uses a navy palette and the user's crisp wallet vector with a Bitcoin accent; referral uses a warm palette and the exact supplied native celebration emoji. Existing trading campaign art is unchanged. Original raster assets are not recompressed.
- Celebration emoji prefers platform color fonts rather than the app's monochrome emoji fallback. Headless Windows capture fixtures explicitly load the local color-emoji font for visual verification; that font is not copied into the app.
- Buy action now has white BTC/arrows, a solid orange inner disc and pale orange outer disc; Sell has its pale green disc and green arrows. Deposit uses a filled blue circle/white plus. Dashboard USD equivalent follows the existing snapshot calculation.
- Shared blue card has closer label/amount spacing, lower art and bottom breathing room without inflating its header with a touch target. Portfolio's compact badge represents the wallet snapshot; an injected refresh binding enables Sync/Updating/Updated with duplicate-request protection. No live-network status is invented.
- Withdrawal displays the supplied NGN5m daily-limit caption and validates a matching maximum per request at entry/review/confirmation. Backend integration must still enforce authoritative cumulative daily usage and return the applicable limit; this local check cannot certify account-wide daily enforcement.
- Signup email/SMS, password recovery and payment-PIN recovery use the same responsive resend row: prompt left, action/countdown on the right, stacked as needed for enlarged text. Countdown durations, expiry checks and resend guards remain unchanged. Damaged recovery apostrophes corrected.
- Bank modal selector and asset-change selector use down chevrons. Navigation rows keep side chevrons. Gift product selection rows no longer imply forward navigation. Bank intro text can grow rather than clipping at a fixed height.
- Gift-card Buy/Sell tabs now follow the shared blue segmented-control treatment, including 48px targets and enlarged-text growth. Gift-box action icons remain the supplied vectors; the celebration emoji belongs to the referral campaign.

Verification and installed artifact identity are recorded in review/implementation-progress.md after the final checks. Full backend acceptance and physical-phone testing remain separate work.

Verified before APK packaging: `flutter analyze --no-pub` reported no issues; the full suite passed 606 tests with 11 optional capture tests skipped. The explicit screenshot test then passed and generated 41 light/dark captures. Two independent scoped reviews found no remaining blockers in the carousel/emoji and OTP/balance/limit changes. `git diff --check` passed.

Follow-up screenshot correction: lowered only the Naira withdrawal mountain by 8 logical pixels using the shared card's optional art offset. Other balance cards retain their existing artwork position.
