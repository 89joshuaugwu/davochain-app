# Refresh, receipts, notifications and backend handoff

## Delivered changes

- Face opening is a rounder forehead/cheek/jaw outline matching the revised drawing. Active perimeter ticks use green (0xFF15976F); original on-device detection, pose holds and first-frontal capture gating remain intact.
- Settings Appearance icon fills its right half; Linked Accounts uses thin outlined stacked cards. Gift referral uses a complete white vector celebration icon and opens the existing ReferralDashboardScreen. Conflicting banner reward amounts were replaced by neutral referral wording; backend owns actual campaign rules.
- Receipt details reveal through a 280ms height/slide/fade transition. Reduced motion renders directly. Sharing-page side margins are 8px, receipt-paper inset 16px; export actions use 12px side margins. Export data masking and capture freeze remain unchanged.
- All explicit application HapticFeedback calls were removed. The primary-button channel test confirms no vibration is emitted.
- Branded pull-to-refresh runs at least two full 900ms rotations, waits longer when its read is unfinished and skips the visual minimum for reduced motion. Its UI-owned minimum timer is cancelled on disposal. The original logo assembles, its center breathes and a leading dot follows the outer arc. The shared operation/loading arc now also has a leading dot.
- Pull-to-refresh covers Home, History, Portfolio, the wallet-balance selector, notification centre/details, gift-card home/brand catalogues, financial outcome pages and transaction details. DavoRefreshScope provides one read-only integration callback keyed by resource and accepted transaction ID. Pulling never submits a financial operation or changes pending into completed on its own.
- Empty notification artwork performs two quiet floating/rocking gestures separated by a pause, then settles. Motion pauses in the background and is skipped for reduced motion. Notification details now show category context, time/read metadata, a message card and a relevant working action to history/password/support.
- Backend handoff: docs/backend-engineer-handoff.md maps implemented source and contracts to proposed endpoints, typed DTOs, state transitions, uploads, provider events, policy questions, priorities and acceptance checks. Current static/local authority and gift delivery DTO propagation gap are recorded honestly for integration. Customer-facing copy remains normal product wording.

## Verification

Full suite: 401 passed, 10 optional captures skipped (tmp/build36-tests.txt). Analyzer: no issues (tmp/build36-final-analyze.txt). Tests include read-only target dispatch, stable transaction identity through fetched confirmation, preservation of expanded receipt details, financial-only result refresh, two-turn minimum, failure/retry, navigation, image validation, reduced motion and silent button activation. Revised face capture is tmp/face-oval-overlay-review.png. All 16 explicit source references in the backend handoff exist; Markdown fences are balanced.

Native release evidence is appended after final installation. Human head-pose/liveness and iOS behavior cannot be fully verified by Android emulator UI checks; actual device capture gating remains covered by its existing tests.

## Build36 native checks

Version36 installed and launched on emulator-5554. Actual captures qa36-settings-linked-cards.png and qa36-settings-appearance.png confirm stacked-card and half-shaded blue icons. qa36-notification-detail.png confirms the redesigned message page, and its View transaction history button opened History. APK audit: 790 declared assets/fonts match, three ABIs, 126256558 bytes, SHA256575bdb1b8e9eeac516ed265a3b25d7ffdf2d6083316d4ca528956f65fa8705dc.

## Additional authorized performance page

After emulator installation the user explicitly requested building the portfolio performance destination. The former inactive chart button now opens PortfolioPerformanceScreen. Integer-kobo current/history models, five real range filters, point inspection and accessible slider, visibility privacy, external controller/loader binding, initial/range/refresh loads and stale-response guards are implemented. Actual portfolio value change is separate from period-specific server-supplied adjusted performance; no historical gains are invented. Default data contains the same current portfolio valuation only. Historical data contract added to backend-engineer-handoff.md. Ten focused performance tests passed; analyzer clean (build37 logs). Final native/chart artifact evidence follows installation.
