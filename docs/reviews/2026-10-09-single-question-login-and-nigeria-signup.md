# Single-question login and Nigeria signup

The user requested that login ask one randomly chosen question from the saved three and signup offer only Nigeria with a visible flag.

Enrollment and reset still require exactly three distinct preset/custom questions. Each login challenge selects one with the secure random generator, binds it to the current question set, and keeps the choice stable during retries. Only that question's answer is compared. Successful verification consumes the challenge. Cancellation, superseding challenges and replacing/clearing the account invalidate earlier challenges. Shared answer attempt limits survive beginning another challenge.

The login form now contains one hidden answer input and singular instructions/actions. Recovery replaces all three questions after the email-code preview, then starts a new single-question challenge. Primary PIN/password/fingerprint handoffs retain their existing gate.

Signup now offers Nigeria only. The correct green-white-green flag is drawn as a small vector widget in the picker, selected-country field and +234 phone prefix, avoiding regional emoji/font rendering differences. Existing Nigerian number validation and consent requirements remain.

This remains a session-only frontend authentication preview. Backend authentication and email delivery are still pending; this change does not create production MFA.

Focused tests passed all 23 checks, covering random selection across all three saved questions, wrong-question answer rejection, single-use IDs, cooldown continuity, one-field UI, stable retries, reset/recovery, existing login handoffs and Nigeria-only selection. Full suite, visual and release evidence follows below.

## Source and visual verification

Flutter analyzer: no issues. Full suite: 317 passed, six optional captures skipped. The optional screenshot test passed separately; reviewed the dark single-question challenge, Nigeria-only picker and selected-country flag. No additional visual correction was needed. Evidence: ../tmp/single-question-final-analyze.txt, ../tmp/single-question-final-tests.txt, ../tmp/single-question-capture.txt and ../tmp/questions-visual/.

## Release and installation

Release `0.13.0+24` built successfully and installed with `adb install -r` on Redmi 14C (`CI49FIXKM7BUOVA6`) and `emulator-5554`. Both devices report versionCode24; pulled base APK hashes match the verified build: `474400ad850f27920e38846838813e41630f893ebb7abc4c7b44bd095fd2a6f8`. App launch commands succeeded on both devices.

APK: 79,619,611 bytes; ARM32, ARM64 and x86_64. All 753 declared asset/font/license files match, with none missing. Installed emulator signup confirms the Nigeria-only row, accessible flag label and flag in the selected field. Native screenshots: ../tmp/emulator-release24-nigeria-picker.png and ../tmp/emulator-release24-nigeria-selected.png. Build/audit evidence: ../tmp/single-question-release-build.txt and ../tmp/receipt-release-apk-audit.json.
