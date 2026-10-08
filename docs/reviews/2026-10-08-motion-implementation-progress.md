# Motion implementation progress

The user authorized execution on 2026-10-08, including physical-device close-button fixes and refinement of the Verification overview. The earlier audit-only restriction is superseded. Work remains in the existing workspace; no automatic commits.

- Reproduced inherited yellow authentication decoration and clipped cryptocurrency close target in failing regression tests.
- Implemented C completed, S submitted, P password and F fingerprint storyboards using deterministic vector drawings, the approved logo, specified timings and coordinated heading/details reveals. Completed and pending outcomes have different artwork and wording; historical receipts do not replay an outcome.
- Preserve splash and existing small text sizes.
- Working indicators follow the actual operation future. Preview operations remain isolated fixtures; they are not backend confirmations. Pending review attention stops after two cycles. Popped routes and backgrounded authentication cannot deliver a late unlock/navigation.
- Added sequential forward/backward verification transitions, bounded dashboard entrances, immediate privacy masking, checkbox/press/copy/toast feedback, safe sheet headers and reduced-motion handling. Fixed inherited yellow authentication text decoration. Refined Verification overview without increasing small text sizes.
- Footer Trade opens the existing Buy/Sell/Swap trading screen. View Portfolio retains its portfolio destination.

## Verification and delivery

- Full Flutter suite: **152 passed**, one optional storyboard capture test skipped. Log: `../../../tmp/motion-full-tests-verified.txt`.
- Flutter analyzer: **No issues found**. Log: `../../../tmp/motion-analyze-clean.txt`. The final two analyzer-only brace additions do not change behavior.
- Deterministic capture: **53 PNG checkpoints** for C/S/P/F on white/blue, W, K and H. Opt-in capture passed; files: `../../../tmp/motion-storyboards/`, log: `../../../tmp/motion-final-storyboards.txt`. Development-only gallery: `../../tool/motion_gallery.dart` (no production menu entry).
- Focused independent read-only review found no remaining blocking defects in route cancellation and submitted-buy outcome mapping. Regression tests exercise real popped routes, pending receipts, reduced motion, large-text layouts and Trade navigation.
- Release **0.12.0+17** built successfully (69,830,677 bytes). All **728 declared assets/font files** present with zero missing entries and zero byte mismatches. Build log: `../../../tmp/motion-release-final-build.txt`.
- Installed with `adb install -r` on `emulator-5554`; package reports versionCode 17/versionName 0.12.0 and no DEBUGGABLE flag. Installed Trade walkthrough reaches Buy, Sell and Swap.

## Remaining integration and evidence

Physical delivery completed on 2026-10-08 after replacing an unstable USB cable: rebuilt release, installed on Redmi 14C (`CI49FIXKM7BUOVA6`), verified version 0.12.0/code 17 with no DEBUGGABLE flag, and launched successfully to onboarding. Pulled the installed `base.apk` back from the phone; its SHA-256 exactly matches the built APK: `059EE5BACB1D36CF0E533260A3927E4085CFA634821DE7DF57C5A0F358F6F065`. All 728 declared assets/fonts match source bytes; ARM64 and ARMv7 libraries included. Bounded launch log check found no fatal/unhandled, missing-asset/plugin or RenderFlex-overflow matches. Build log: `../../../tmp/motion-phone-release-build.txt`; installed UI evidence: `../../../tmp/emulator-review/motion-phone-installed-ui.xml`. Normal-speed physical motion review and profile/frame-time evidence remain pending. Installation/launch evidence is not exhaustive runtime or performance evidence.

Native biometric authentication, KYC camera/file providers and backend transaction/KYC review remain existing integration gaps. Provider-dependent attachment acceptance motion must be connected to real accepted provider results. The gallery and core sequences are implemented; this report does not claim that every legacy/inactive tier screen or every native micro-interaction has been migrated to the new system. The accepted splash is preserved.
