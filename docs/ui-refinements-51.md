# Reference analysis and focused refinements, build 51

## What the references teach

The strongest receipt examples let a person answer three questions quickly: how much, what happened, and who or what the transaction involved. Secondary facts are grouped, identifiers have clear affordances, and detailed timelines can be disclosed instead of competing with the headline.

Davochain already has a consistent blue identity, restrained surfaces, useful notification categories and a more helpful welcome notification than the generic reference detail pages. Keep those. The references are not uniformly better: repeated promotions, dense rewards blocks and many badges make some screens harder to scan. They do not justify new rewards, banners or a new visual identity.

The supplied share screenshot shows the main weakness: duplicated identifiers and a long single-column form-like receipt. Preserve the transaction detail page the user likes. Give sharing its own clear title, compact label/value rows, a stronger amount/status hierarchy and a single identifier when ID and reference match. Preserve exact monetary values and masking; unknown fees must never become invented zero fees.

The verification check is already recognizable. Improve the lead-in: two visible ball-headed rotations, then the established check. This acknowledges a caller-established result; it does not perform verification or disable Continue. The signup finale needs an intentional composition rather than an isolated logo. Use the logo in a wallet silhouette with quiet crypto/gift-card accents, concise introductory copy and the existing Explore action.

## Changes

- Profile/Settings uses the existing read-only refresh region and supports pulling even when content fits.
- A pending deposit stays in the repository for reconciliation but does not enter public history, the funding banner or notification events. Other pending operations keep their existing behavior. Completion/failure can still be delivered once.
- Old persisted deposit-initiation notices are removed on restore with their unread contribution. Consumed event IDs remain persisted.
- Deposit outcome banners support swipe and an accessible close action. Dismissal does not delete a receipt, affect funds or remove history; it remains dismissed for that event in the session-scoped feed.
- Share receipts retain the established eight-pixel outer margin and export actions, use compact rows that stack at narrow/large text sizes, and omit the redundant Reference row only when it equals Transaction ID. Image/PDF still consume the same masked presentation.
- Email/phone verification uses a finite 2.6-second acknowledgement: two 800ms rotations then a 1000ms completion reveal. Reduced motion immediately shows the final check; lifecycle pauses motion and disposal stops it.
- Welcome keeps blue/white, Sora, the supplied logo and the existing navigation, with a wallet-shaped illustration and three feature labels. No invented account values.

## Validation

Evidence is kept in the workspace's review/evidence/ui-refinements-51 directory. Native screenshots and release metadata, when produced, are recorded there. No backend or live price behavior was added. Tests cover internal pending records, close/swipe/history retention, legacy inbox migration, refresh dispatch, masking/exports, immediate actions and reduced motion. The independent reviewer found no important issues.

Final source verification: `flutter test --no-pub --dart-define=CAPTURE_FUNDING=true --dart-define=CAPTURE_RECEIPT_FIDELITY=true --reporter expanded` passed 708 tests with 14 existing skips. `flutter analyze --no-pub` reported no issues. Both light/dark welcome and share screenshots were rendered and inspected; large-text/narrow tests passed. Initial regression runs exposed the superseded pending-deposit expectation and two shared-layout/component requirements; those were resolved before this final green run.

## Release and native evidence

Version 0.19.1+51, package com.example.davochain. The release helper completed successfully (Gradle 460.5 seconds). APK SHA-256: A03BF4548FCF9EAF61CF46619CD4BE4A549C22D8307B7AC0AEA28A7C63141681. Signing certificate SHA-256 remains d0de9b8311199a2eb6a238d106b45eaa9d30fe4ef0ef7b9b5808edc3988e2411.

Installed with adb install -r --no-streaming on emulator-5554 without clearing app data. Native package query confirmed code 51. The existing Release Fifty account restored and unlocked with its NGN100000 balance. The inbox retained the completed deposit and welcome notices, both read, and removed the old pending deposit notice. The completed notice opened its matching transaction and refined share page. Transaction ID appeared once, exact amount and date remained correct, and export actions remained accessible. Settings pull-to-refresh displayed the existing brand orbit and returned to the same Profile screen. Screenshots and UI XML are in the evidence directory. Phone CI49FIXKM7BUOVA6 was not connected; no phone installation is claimed.
