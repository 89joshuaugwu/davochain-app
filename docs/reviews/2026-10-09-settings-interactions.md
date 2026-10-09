# Settings interactions: frontend completion

## Scope and arrangement

The remaining six audited interactions previously ended at selection, a toast, or a placeholder. Complete them using the current light/dark theme, Sora sizes, native route transitions, and shared outcome choreography. Compact completed outcomes suit bank linking and password changes; pending support and deletion requests use the submitted clock sequence. Outcome actions remain available without waiting for animation.

| Flow | Completed interaction | Backend boundary |
| --- | --- | --- |
| Bank linking | Search bank → 10-digit number → resolved preview name → review → link → updated account list. Linked accounts are available in the withdrawal payment selector. | No live account-name enquiry or bank linking. |
| Bank details | Native share composer uses the same immutable details as the deposit rows. Cancellation does not claim delivery. Sharing failure offers real clipboard copying. | Deposit details remain existing fixtures. |
| Password | Current/new/confirmation validation, signup strength rules and colors, locked busy fields, error retry, completed result. Secrets are cleared on acceptance and controllers disposed. | No credential validation, server password change, or persisted password. |
| Support | Subject, optional order ID, message, awaited submission, pending reference, saved request details and reference copying. | Requests are session fixtures; no email or ticket is sent to support. |
| Rewards | Amount validation → conversion review → accepted redemption → available/redeemed balances and activity. Integer kobo avoids rounding errors; 20 points = NGN 1. | Credit is a preview reward balance, not an authoritative wallet ledger. |
| Deletion | Optional reason, type DELETE, explicit acknowledgment, awaited pending result, one-time sign-out. Both settings and Account Information entries are connected. | No real account is deleted. Production must enforce account eligibility and submit a server request. |

## Implementation

- `SettingsPreviewSession` owns immutable account/request/redemption records for the active preview session. Logout and deletion sign-out reset it together with existing verification and funding state.
- `SettingsGateway` is the injectable service boundary; `PreviewSettingsGateway` provides finite awaited fixtures. Replace it with authenticated backend implementations and authoritative state refreshes.
- Forms reject duplicate submission and late acceptance after disposal, route changes or session reset. Account lookup revision tokens reject stale number responses. Failed operations retain a retry path.
- Redemption acceptance validates positive available points, exact conversion and unique references atomically. The form also checks the returned amount against the reviewed amount.
- Native sharing and clipboard copying use platform plugins. Share results do not establish recipient delivery.
- Existing placeholder classes were removed from the settings monolith and replaced with exported, separate action-flow files.
- Davo Points use a reusable blue coin carrying the existing Davochain mark in balance tiles, redemption review and activity. Ambassador reward totals use the same component. Actual currency/crypto icons retain their identities.

## Verification

Final `flutter analyze`: no issues. Final regression suite: **204 passed**, three opt-in capture tests skipped. The opt-in settings capture and focused interaction run also passed all 14 tests. Read-only review findings about the payment sheet's surface, the secondary deletion entry and clipboard errors were corrected before the final checks.

The new tests cover all six interaction paths, mocked native composer/copy behavior, stale bank lookups, failed-link retry, pending-route closure, duplicate account rejection, password input locking and session-reset cancellation, malformed redemption results, request revisit, withdrawal account selection, and deletion's cleared login navigation stack.

Opt-in `settings_actions_capture_test.dart` captures ten light/dark pages with real Sora and MaterialIcons at 390×844. Narrow bank pages were also exercised at 320 pixels with 2× text and keyboard insets. Captures live in `../tmp/settings-actions-review/`.

Physical native sharing, server authorization, provider errors and durable account state remain backend/device integration work. No version bump or APK installation is part of this change.
