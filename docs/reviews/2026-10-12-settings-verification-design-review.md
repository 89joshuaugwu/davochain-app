# Updated settings and verification design review

Source: supplied screenshots and Figma node `7829:84583` in file `z5bMfbhPLQQyZUK8lHU5jo`.

The initial Figma design-context request is blocked by connector reauthentication. Exact settings groups, asset mappings, geometry, and child-node contexts are therefore not yet verified. Layout implementation must wait for that source access; the screenshots establish the requested flow but are not a substitute for the required design context.

## Confirmed behavior change

The user's final instruction supersedes the earlier pending wording: Basic Verification must proceed from submitting an eleven-digit BVN or NIN, through active verification, to a verified result. No pending-review state remains in Basic Verification. One identity method is sufficient. Loading must not mark an account verified; only a successful operation may update state. Failure and cancellation must not unlock Advanced.

## Existing implementation gaps

- Basic result currently displays submitted/pending, with no operation-loading screen.
- Basic choice goes directly to number entry, missing the new requirements/Start screen.
- Overview uses large explanatory cards rather than the compact two-row reference.
- Advanced currently captures face before identity documents. The reference selects/uploads ID first, then introduces selfie/live capture/review/matching.
- Advanced currently combines ID and address into one submitted/pending result. The reference separates identity completion from address completion and has a distinct address details/review/loading/final result.
- Profile and contact forms already exist and retain their drafts; their headings, spacing, actions, and navigation require comparison with the live design.
- Existing upload/photo interactions are local fixtures. Reuse their established provider boundaries and supplied assets; do not substitute approximate artwork for design assets.

## Implementation sequence

1. Independently correct Basic's operation-driven loading → verified semantics and regression coverage.
2. Restore Figma access, fetch screenshot plus high-fidelity contexts for the linked section and all visible changed child screens.
3. Inventory settings changes and missing screens against those contexts; map and download exact assets, reusing matching bundled files.
4. Implement compact overview and Basic requirements/entry/result screens, then reorder Advanced to ID upload → selfie review/matching → ID-complete → address selection/upload/details → address verification → fully verified.
5. Verify navigation, saved drafts, disabled actions, reset/cancellation, safe areas, dark mode, reduced motion, and targeted visual captures; build and install only the complete reviewed release.

Do not change unrelated settings or infer unseen rearrangements while the source is inaccessible. Backend identity verification and native upload/liveness remain separate integrations from the local frontend fixture.

## Implementation progress

Basic's existing number-entry route now waits for an injectable verification operation. Its default local fixture returns a result after 1500 ms. While waiting it shows active BVN/NIN verification, does not unlock Advanced, and hides the submit action. A successful response commits the masked identifier, enables Advanced, and shows a completed/Verified result; Basic's overview status also reads Verified. Failure retains the input and allows retry. Disposed screens and reset sessions cannot commit late responses. This changes frontend presentation only; a production identity provider must replace the fixture.

Exact Figma layout implementation remains outstanding. Three design-context attempts and an account diagnostic still returned `UNAUTHORIZED`, `TRIGGER_REAUTHENTICATION`, `Reauthentication required` after the user reconnected. No new APK has been built or installed for this incomplete design update.

Verification: final targeted suite passed all 19 Basic/state/Advanced regression tests; analyzer reports no issues. New tests cover both identity methods, delayed success, failure/retry readiness, disposal, and reset during verification. Existing Advanced remains unchanged pending the new design implementation.
