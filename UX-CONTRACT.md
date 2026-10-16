# UX Contract

## Product context
Existing Flutter app; this contract records the shared owners touched by the October 2026 refinement.

## Business-context sources
User instructions and the existing exact wallet/receipt lifecycle. See docs/riverpod-49-implementation.md and docs/notification-experience-49.md. Local operation acceptance is not evidence of an incoming deposit.

## Visual contract
DESIGN.md preserves the established identity; runtime theme files own token values.

## Canonical UI Map
| Capability | Owner | Source of truth | Verification |
| --- | --- | --- | --- |
| Refresh | DavoRefreshRegion / DavoFloatingRefresh | Read-only resource delegate | refresh_binding_test |
| Transaction facts | LocalTransactionRepository / ReceiptRecord | Account checkpoint | existing repository and receipt tests |
| Receipt exports | ReceiptPresentation / ReceiptPaper / ReceiptPdf | Masked immutable presentation | receipt_system_test, receipt_export_test |
| Deposit alert | FundingActivity / DepositActivityBanner | Accepted funding outcome | deposit_presentation_refinement_test |
| Verification acknowledgement | DavoVerificationMark | Caller-established success | verification_acknowledgement_test |
| Primary action | DavoPrimaryButton | Caller navigation | existing onboarding tests |

## Flow ledger
Deposit initiation remains stored for reconciliation but is absent from history and notifications. Completed/failed outcomes retain their identity and appear once. Swipe or close dismisses the outcome banner only; history remains intact. Dismissal is session/account scoped because the funding banner feed itself is session scoped.

## Navigation and responsive behavior
Preserve existing destinations. Long receipt values wrap; at narrow widths/large text, rows stack. Signup and result bodies scroll while the primary action remains reachable.

## Overlays and feedback
Use existing Davo toast and export/share sheet. No additional confirmation for dismissing an informational banner.

## Async and resilience
No change to balances, reservation, checkpointing, retry or operation IDs. Suppressed notification events remain consumed across restore. Old saved deposit-initiation notices are removed with their unread count. Lifecycle pauses acknowledgement motion; disposal stops it.

## Permission and clipboard
Existing receipt masking remains the default for image and PDF exports. Export captures the selected immutable presentation.

## Verification
Run focused notification, funding, refresh, receipt and acknowledgement tests, full analyzer and regression suite. Capture and inspect welcome/share screens at phone width, plus large-text behavior.
