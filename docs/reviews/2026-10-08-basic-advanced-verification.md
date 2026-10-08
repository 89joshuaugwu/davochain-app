# Basic and Advanced verification redesign

The active Davochain verification journey replaces the former Davopay Tier 1/2/3 arrangement with two clear paths.

## Basic verification

Personal details → contact/address details → choose NIN **or** BVN → enter an 11-digit number → submission summary.

- Reuses the existing personal and contact forms, including the custom date and searchable state pickers.
- Middle name is optional. Name, birthday, phone, address and state remain required in the active journey.
- Draft fields survive navigation within the app session. Logout and switching accounts clear the session.
- Both identity methods restrict input to eleven digits. Only the final four digits are retained after submission.
- No facial verification or second identity-number requirement.

## Advanced verification

Facial verification first → identity documents → proof of address → review → submission summary.

- Basic submission is required before Advanced can start. Submission does not imply approval.
- National ID and driving licence require front and back. International passport requires its biodata page.
- Address documents retain Utility bill, Bank statement and Tenancy agreement choices.
- Changing a document choice clears the corresponding attachment progress.
- Previous-step navigation keeps completed information. Return later exits to the overview; reopening resumes progress.
- Blue confirmation animation follows submission. Pending review remains explicit.
- Short transitions respect reduced-motion settings; long content scrolls on narrow screens and at larger accessibility text scales.

## Active entry points and compatibility

Dashboard setup, Profile → Verification, and Increase Transfer Limits now open the same Basic/Advanced overview. No live entry point starts the previous tier chain. Legacy classes remain for compatibility and can be removed in a separate cleanup after route migration is accepted.

## Integration boundary

This is the app's presentation flow. Progress is held in memory, not persisted across process restarts. The existing camera and document fixtures are still local presentation actions. Native capture/file selection, secure upload, identity-number validation, server submission acknowledgments, and authoritative approval status must be connected before live verification. No permission or transaction limit is granted by this state model. Dashboard asset expansion uses the existing local setup indicator only.

Tests cover Basic input and route selection, optional middle name, draft restoration, direct Advanced gating, step order, passport page requirements, document changes, proof-of-address gating, back/resume, pending outcomes and reduced motion.

## Validation

- Full Flutter regression suite: 138 tests passed.
- Final numbered-list alignment and helper-contrast refinement: all 3 focused Basic flow tests passed; Flutter analyze reports no issues.
- Android release APK 0.12.0+16 built successfully; final Gradle assembleRelease took 131.3 seconds.
- Emulator installation identifies versionName 0.12.0 / versionCode 16. Dashboard-to-overview navigation and Basic personal-details navigation inspected through the Android UI tree. Overview screenshot: `../../../tmp/emulator-review/kyc-overview-0.12.0.png` (before the final fixed number-column refinement).
- Release asset audit: 727 declared files, zero missing and zero source/package mismatches.
- Physical phone remained disconnected; no new phone installation or device-specific rendering claim.

### Physical phone installation, 2026-10-08

The Redmi 14C reconnected. A fresh `flutter build apk --release` succeeded (14.6 seconds), and `adb install -r` installed 0.12.0+16 successfully. Release manifest includes arm64-v8a, armeabi-v7a and x86_64; installed package has no DEBUGGABLE flag. The 727 declared asset/font files all match source bytes with none missing. Built and installed APK SHA-256 are identical: `2d4a4a3b68338424377059b55c87aae04ce8a2be062c24220d2f422bf22bd7cb`. Cold launch returned Status ok; the process remained running and MainActivity was focused. The inspected startup log showed no fatal exception, missing-asset or missing-plugin matches. This establishes build/package/installation integrity, not exhaustive functional validation of every screen or completion of the documented backend integration gaps.
