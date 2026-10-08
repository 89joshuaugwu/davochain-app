# Funding outcomes and first-account welcome

Implemented under the user's automatic approval on 2026-10-08. This follows the [outcome feedback audit](2026-10-08-outcome-feedback-audit.md).

## First account setup

Matching the first transaction PIN confirmation now opens a dedicated welcome finale. Mismatches remain on the PIN form. The scene says **Welcome to Davochain**, acknowledges **Transaction PIN created**, and offers **Explore Davochain**. This combines account-setup closure and PIN closure without two consecutive success screens. It does not claim that Basic or Advanced verification has been approved.

Explore is available immediately and only dispatches once. It clears the onboarding stack into Home with the existing 160 ms authentication handoff fade. Animation completion never navigates. The accepted startup splash is untouched.

### Welcome recipe O: 2400 ms

One Flutter animation controller coordinates the original brand assembly, established completed artwork, two expansion waves and copy. The existing settle curve is `Cubic(.22, 1, .36, 1)`.

| Time | Choreography |
| --- | --- |
| 0–720 ms | Original logo pieces gather. Map this interval to the completed artwork's first 240 ms; preserve the supplied logo asset and clipping regions. |
| 720–1700 ms | Resolve from the assembled mark through the established blue disc, white inset and check stroke. Map to artwork progress 240/1120 through 1 using settle. |
| 624–1944 ms | First 2 px expansion wave: radius 54→118 on a 240 px stage; opacity `sin(p×π)×.9` applied to the themed primary-soft color. |
| 912–2232 ms | Second wave with the same geometry and a 288 ms offset. Both disappear completely. |
| 1150–1750 ms | Welcome heading resolves from opacity 0→1 and vertical offset 12→0. |
| 1400–1950 ms | Supporting copy resolves with the same bounded travel. |
| 1650–2200 ms | PIN confirmation pill resolves. |
| 2200–2400 ms | Final composed state holds. No loop or automatic route change. |

The scene uses a 180 px completed artwork on a 240 px stage, scrollable content, a fixed reachable primary action, semantic theme colors and Sora. Reduced motion settles everything immediately. Lifecycle changes pause/resume the controller; theme changes while backgrounded do not restart it. No new runtime dependencies were added.

## Naira withdrawal

The existing review and PIN steps remain. After PIN confirmation, a progress route waits for operation acceptance, then presents a submitted result with the shared S recipe. Amount, pending status, bank, masked account, account name, fee and date are available in details. Accepted session activity appears in History. Android back and Back to wallet return to the wallet rather than reopening an accepted withdrawal form.

Invalid/zero/non-finite amounts and amounts beyond the displayed daily maximum disable Continue. The review flow guards repeat taps. Cancellation prevents a late future result from inserting activity or navigating. Failure stays explicit and allows a manual retry.

The existing app remains a financial preview. The default withdrawal fixture returns pending after 1500 ms and displays “Preview only. No funds have been moved.” It does not turn pending into paid. Provider reconciliation, authoritative balances/limits, credential verification and idempotent payout submission remain backend work. `operation` is a test seam, not a production bank adapter; a production adapter must supply accepted transaction metadata rather than reuse preview identity or fixed fee data.

## Deposits

`FundingRecord` represents pending, completed or failed deposits and withdrawals, including currency, destination, occurrence time, optional network/reference/hash, and bank metadata. `FundingActivity.accept(record)` upserts session activity by stable event ID and prevents a completed event regressing to pending. Logout resets session records and presentation bookkeeping.

Crypto receiving pages filter deposit feedback by asset symbol; the bank-transfer receiving page filters NGD. Home shows the latest deposit event in a nonmodal banner. A record can open its pending/received outcome and details, and History shows event activity above a separately identified fixture section. First outcome presentation plays once per event/status; revisits settle. The presentation decision is captured at the tap, so inherited/theme rebuilds do not interrupt it. Details update when the same event changes status.

Receiving instructions, address copy and QR sharing never create a credited deposit. The feed has no invented credit timer or “I paid” shortcut. Real wallet/bank events must call the accepted-event adapter before these new banners appear. Historic BTC fixture details remain the legacy settled sample. Existing bank-details Share Details still uses its previous acknowledgement; implementing bank-details sharing is separate from these outcome changes.

## Verification

- Behavior tests cover PIN mismatch/confirmation/Explore, delayed withdrawal acceptance, pending-versus-paid wording, masked details, failure/retry, cancellation, Android back, deposit upsert/non-regression, Home feedback, fixture labeling, theme rebuild/revisit, reduced motion and 200% text at 360×640.
- Optional rendered checkpoints: `flutter test test/funding_outcome_capture_test.dart --dart-define=CAPTURE_FUNDING=true`. Light/dark welcome frames and funding results are written to `../tmp/funding-welcome-review/` for visual inspection.
- `flutter analyze`: no issues found.
- Full suite: 184 tests passed; two opt-in capture tests skipped. The separate enabled funding/welcome capture run is used for visual review.
- Independent source review completed; the presentation-rebuild and fixture-label findings were fixed and regression-tested.
- `git diff --check`: clean. No phone installation is part of this request.
