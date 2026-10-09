# Security questions — 9 October 2026

Current behavior (release 24): enrollment/reset still uses exactly three questions; login asks one randomly selected question with a stable choice during retries. See [the follow-up review](2026-10-09-single-question-login-and-nigeria-signup.md). The initial implementation and release-23 evidence below are historical.

## Implemented flow

Settings → Security → Security questions opens a guided setup. Users select three distinct preset or custom questions, enter hidden answers, and review only the questions before saving. Previously selected presets are disabled. Back navigation retains the draft; incomplete or duplicate sets cannot activate.

Configured accounts enter a three-answer challenge after the existing returning password/fingerprint flow or the new PIN preview route. Ordinary password login also uses the gate. Home and the unlocked state are reached only after all three answers match. Canceling returns to primary unlock. Duplicate PIN pushes and repeated verification callbacks are guarded.

Change questions requests an email-code preview, validates that code, and replaces all three questions atomically. Existing answers remain active until replacement succeeds. Recovery returns to a cleared challenge for the new answers rather than unlocking directly. Canceling invalidates the code/grant and keeps the old set.

The UI follows the existing blue/Sora design, light/dark themes, finite step transitions, reduced motion and accepted result animation. Forms scroll with the keyboard and large text. Seven screenshots cover setup, disabled question choices, review, result, email-code preview, dark challenge and 320px/2× text with keyboard. A clipped helper was corrected in one confirmation pass.

## Verification boundary

This is an additional knowledge check, not true MFA. NIST withdrew security questions as an authentication factor because answers can be private without being secret: https://www.nist.gov/system/files/documents/2020/07/02/SP800-63-3-Implementation-Resources_07012020.pdf.

The service is explicitly session-only preview. No email is sent; the code is displayed as a fixture. Existing PIN and biometric acceptance remain frontend demonstrations. Questions and salted answer digests are held in RAM, without disk persistence or logging. Answer matching ignores capitalization and extra spaces while retaining punctuation. Ordinary logout retains the current preview account's configuration; switching accounts or deleting the account clears it.

Five wrong answer attempts impose a 30-second cooldown. Codes and reset grants expire after five minutes; codes have an attempt limit and resend cooldown, and grants are generation-bound and single-use. Invalid replacement inputs leave the previous set untouched.

Production requires account-scoped authenticated endpoints, actual primary authentication, email delivery, server-side slow salted hashes and rate limits. Passkeys or TOTP should provide real production MFA. The UI should be connected to authoritative server outcomes before being used for real access control.

## Checks

Eight service tests cover validation, matching, lockout, code expiry, resend limits and reset grants. UI tests cover selection, hidden review, custom duplicates, retained drafts, Unicode answer limits, full reset/recovery and cancellation. Integration tests use actual fingerprint/password controls and the PIN route to verify the login gate, cancellation and duplicate-route prevention. An independent source review identified and verified fixes for recovery back navigation and PIN reentrancy.

The Settings security group now grows with its contents rather than overflowing after the new row. A focused 32-test batch including existing profile/auth regressions and the capture passed. Final release evidence is appended after the combined receipt and gift-progress refinements finish.

## Combined release verification

Release: `0.13.0+23`, installed on `emulator-5554` (API 36). Flutter analyzer reports no issues. Full suite: 314 passed, six optional capture tests skipped. Receipt visual confirmation passed separately. The final receipt identity/external-withdrawal regression batch passed all 30 checks after the last mapping change.

Release APK: 79,635,999 bytes, ARM32/ARM64/x86_64, no debuggable flag. All 753 declared asset, font and license files match their source bytes; no files missing. The installed base APK SHA-256 matches the build: `eb77b50cf299656c4459181e497874430ef89d3a319b5de44c10900eb27cf84f`.

On the installed emulator, enrolled two preset questions and one custom question, confirmed disabled duplicate selection and hidden review answers, saved through the accepted result, then followed returning PIN login into the three-question challenge. All three matching answers opened Home. The same release opened a BTC/USDT swap receipt with the expected identity and populated ID. A native Download saved a selectable PDF with both asset badges, the same transaction facts, and no Preview wording. Crash and Flutter error/overflow scans were empty.

Evidence: `tmp/combined-final-analyze.txt`, `tmp/combined-final-tests.txt`, `tmp/receipt-external-final-tests.txt`, `tmp/receipt-visual-confirmation.txt`, `tmp/combined-release-build.txt`, `tmp/receipt-release-apk-audit.json`, `tmp/emulator-questions-review.png`, `tmp/emulator-questions-challenge.png`, `tmp/emulator-receipt-swap.png`, `tmp/receipt-fidelity-review/emulator-release23-swap.pdf`, and emulator logcat files. These paths are relative to the project workspace, one level above the Flutter app.

Physical installation: Redmi 14C (`CI49FIXKM7BUOVA6`) accepted `adb install -r` successfully. Android reports versionCode23/versionName0.13.0. Pulled base APK matches the verified release hash. App launch command succeeded. This verifies installation; the full feature walkthrough above was performed on the emulator.
