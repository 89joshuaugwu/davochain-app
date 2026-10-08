# Dark-mode implementation review — 8 October 2026

The user approved analysis, plan and implementation automatically. The historical readiness audit informed the migration; [design](../superpowers/specs/2026-10-08-dark-mode-design.md) and [plan](../superpowers/plans/2026-10-08-dark-mode.md) record the decisions. No automatic commits were made.

## Result

Appearance now owns a local Light/Dark/System draft. Next persists and applies it; Back cancels an unsaved draft. Pending saves block both Back controls. A failed write keeps the previous preference and offers retry. Controller writes serialize so slow earlier saves cannot overwrite later choices. Preference restores before ordinary Flutter content; System uses platform brightness.

`DavoColors` is a context-resolved ThemeExtension. Material themes and custom screens use semantic text, canvas, surface, input, border, link and status roles. Nested previews and receipts have independent themes; no global mutable dark palette or blanket image inversion is used. Sora sizes and the accepted blue splash are preserved. Colorful brands, flags, crypto and bank artwork remain original. Monochrome glyphs receive intentional tint. Camera overlays retain black background/white framing. Exported paper remains white with dark ink; the app chrome and sharing controls follow appearance.

Migrated shared/auth/onboarding, Dashboard/portfolio, crypto/buy/sell/swap, gift cards/history, Profile/Settings/Basic and Advanced verification and ancillary views. Appearance uses an actual themed miniature wallet rather than a static light raster preview. System bars follow the actual content theme, with white-icon exceptions on blue brand/auth surfaces.

## Verification

- Full suite: **172 passed**, one optional motion capture test skipped. `../../../tmp/dark-delivery-tests.txt`.
- Analyzer: **No issues found**. `../../../tmp/dark-package-analysis.txt`.
- Final dashboard refinements: four targeted dark financial tests passed, including doubled-text forms/dashboard and camera overlay contrast. `../../../tmp/dark-dashboard-final-tests.txt`.
- Tests cover restore/default/invalid preference, failed and overlapping writes, draft cancellation, blocked Back during save, live System brightness resolution, context-isolated paper, dark shared UI, result reduced motion, and representative financial/gift/history/profile/verification layouts at 2× text.
- Dark text/hint/link/status token pairs on surface and field pass 4.5:1. Blue CTA/white retains 5.38:1. Light text-status roles now pass 4.5:1 (green 5.02, warning 5.24, danger 6.57). These pair checks do not certify every alpha-composited asset or disabled state.
- Independent read-only review identified write races, save navigation, global bars, scanner contrast and light-status contrast. All were corrected and re-reviewed with no remaining blocking finding.
- Installed preview runtime: Light → Dark selection updates Profile and Dashboard; cold restart restores Dark despite OS Light. Screenshots: `../../../tmp/emulator-review/dark-profile.png`, `dark-dashboard.png`, `dark-login.png`, `dark-cold-onboarding.png`. Final packaging/install evidence is appended after verification.

## Evidence limits

Final release **0.13.0+18** built successfully (70,548,692 bytes, reported 67.3 MB) and installed on `emulator-5554`. Android reports code 18/name 0.13.0 without DEBUGGABLE. All **728 declared assets/font files** are present and byte-identical to source. APK SHA-256: `7E9513B8632C104EC012BD0FAC34E048AC10BB7DF27B8F4B90CAE98A80FCA3F3`. Build log: `../../../tmp/dark-final-release-build.txt`. Installed final walkthrough confirmed System follows live OS changes, including an already-open wallet sheet; settled Profile status icons are white on dark. OS Night mode was restored to its initial No setting, and app preference left at System. Evidence: `system-dark-profile-settled.png`, `system-light-wallet-final.png`, `system-dark-wallet-final.png` under `../../../tmp/emulator-review/`. Bounded PID-filtered runtime log check found no fatal/unhandled, missing-asset/plugin or RenderFlex-overflow matches.

The full 172-test suite preceded the final Dashboard color refinements; all four dark financial tests and the analyzer were rerun after those refinements. Final subsequent source-only edits remove trailing whitespace and update documentation.

This remains a frontend preview with mock financial/authentication/KYC state. No backend or native biometric verification is implied. Widget and bounded Android runtime evidence are not an exhaustive all-screen accessibility/performance audit. iOS execution, physical dark-mode walkthrough, TalkBack/VoiceOver and physical frame-time evidence remain unverified. White receipt/QR/logo tiles are intentional exceptions, not dark surface defects. Any native share/picker may follow the OS theme independently.

Preferences use the recommended async API for non-critical device settings: [Shared Preferences plugin](https://pub.dev/packages/shared_preferences). Custom colors follow Flutter's [ThemeExtension](https://api.flutter.dev/flutter/material/ThemeExtension-class.html).

## Physical delivery follow-up

Release 0.13.0+18 installed successfully on Redmi 14C (`CI49FIXKM7BUOVA6`) on 8 October 2026. Package confirms code 18/name 0.13.0, without DEBUGGABLE. All 728 declared assets/fonts were rechecked before installation. Launched and captured dark onboarding successfully; bounded process logs showed no fatal/unhandled, missing-asset/plugin or RenderFlex-overflow matches. Screenshot: `../../../tmp/emulator-review/dark-phone-installed.png`. This is a bounded installation/launch check; comprehensive physical dark-mode/accessibility/performance validation remains unverified.

The reported lime outline is present around the emulator's Android Flutter content view, absent in the phone capture, and absent from app debug-border source. Android's default keyboard focus highlight explains this known behavior: [Flutter Android focus-highlight issue](https://github.com/flutter/flutter/issues/146695), [external-keyboard reproduction](https://github.com/flutter/flutter/issues/162743). No application layout or renderer changes were made while diagnosing it.
