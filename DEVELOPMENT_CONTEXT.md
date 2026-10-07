# Davochain development context

Reviewed on 7 October 2026. This document records project direction and handoff context; it is not a build or runtime verification report.

## Working project and references

`davochain-app/` is the runnable Flutter project. Its frontend source comes from the latest v12 handoff originally extracted as `updated-version/`, with the existing native platform scaffolding retained. Make future app changes in `davochain-app/`.

The product name is **Davochain**. Older Davopay names or logos in design material are historical mistakes. Use the supplied Davochain branding and the configured launcher artwork at `assets/images/brand/app_icon.png`.

- `../figmadesignsurl.txt`: screen and section design references.
- `../errorsfound/`: screenshots of reported issues from before the latest handoff; reproduce them before assuming they still exist.
- `../DavoChain_All_Supplied_Assets/`: supplied artwork to consult when an asset is missing.
- `../flutter-docs-from-boss/`: both the HTML project-structure guide and its three-page PDF were reviewed.
- `../lastmessagefromgptweb.txt`: previous assistant handoff; its screen-coverage claims require runtime confirmation.
- `../research.txt`: ideas for future Flutter libraries, motion, storage, networking, testing, and security. Treat these as research leads, not approved dependencies or verified guarantees.
- `V12_WORK_LOG.md` and linked audit documents: previous checkpoint decisions and remaining work.

No applicable `AGENTS.md` was found during the workspace/ancestor review. Workspace `.codex/hooks.json` configures Impeccable edit and stop checks; `.impeccable/config.local.json` records accepted hook consent.

## Architecture direction

The boss's guide permits feature-first organization. Keep `lib/features/<feature>/` alongside shared infrastructure in `lib/core/` and reusable widgets in `lib/shared/`. `main.dart` bootstraps the app; `app.dart` configures the root widget and routes.

The current implementation is predominantly presentation code using local widget state. Several flow files are large and contain mock data and calculations alongside layout. This is a frontend prototype, rather than a completed clean-architecture implementation.

As features mature, split large flow files into screens and widgets, move flow state into controllers, and introduce repository interfaces with mock implementations. Add data/domain boundaries incrementally before connecting endpoints. Domain logic should remain pure Dart; data implementations depend on domain contracts; presentation consumes state rather than accessing external services directly. Choose state-management and networking packages when the actual requirements justify them.

## Preview milestone and backend boundary

First complete and verify Figma screens, states, modals, welcome flows, branding, and navigation; then polish the native mobile experience for the boss's preview. Use deterministic mock data until endpoints arrive.

Working frontend behavior includes navigation, local form input/validation, selection controls, and demonstrable local state changes. UI success states do not establish real account creation, authentication, OTP/PIN verification, KYC, biometric authentication, balances, wallet or bank-account generation, settlement, payments, or transaction execution. Mark demonstrations appropriately when presenting the app.

After backend integration, verify authentication, authorization, permissions, server-side transaction rules, and secure token handling. Client-only validation or obfuscation cannot establish transaction security or protect embedded backend secrets.

## Remaining review and polish

The v12 handoff marks asset consolidation, profile screen-state coverage, modal checks, deposit/withdraw fidelity passes, four-digit transaction PIN reconciliation, and progress/success/detail/receipt fidelity closed. Preserve those decisions unless a reproducible mismatch or updated Figma design requires reopening them.

The handoff still lists transaction CTA/back/cancel cleanup and cumulative QA/build/package checks as open. Confirm every implemented screen and state is reachable on the emulator/device; source presence does not establish complete navigation coverage.

Review the reported boxed input appearance, clipped or obscured icons, missing artwork, top/bottom overscroll effects, deposit button/toast placement, profile spacing, privacy overflow, and appearance illustration against the latest running app and Figma.

The wider polish pass should cover transitions and reduced motion; gestures, press feedback and haptics; keyboard dismissal and insets; safe areas, Android back handling and scrolling; consistent loading/empty/success/error states; responsive layouts, accessibility and text scaling; and Android animation performance. Verify with focused tests and device walkthroughs as each area changes.

The source references **Sora**, but no Sora font binaries or font declaration are currently bundled. Add approved font files and configure their weights before judging final typography against Figma; also reconcile any intentionally different font families in the supplied designs.

## Validation record

Record actual analyzer, test, build, and device outcomes separately with dates and commands. Historical static audits from the web handoff did not demonstrate a successful Flutter analysis or device build.

## Local fixes verified on 7 October 2026

The latest extracted source is the main `davochain-app` workspace. Compile blockers and analyzer findings were resolved. Boxed embedded inputs, covered swap arrows, short-screen deposit actions, privacy text overflow, appearance artwork, and visible Davopay names were corrected.

Android now uses platform scroll physics without the stretch indicator; dashboard content has appropriate bottom padding. Repaired full-height SVG navigation icons preserve the supplied shapes. Trade opens Portfolio; History opens a sample transaction list with detail routes; setup and rewards actions open their existing destinations. This is a targeted navigation pass; the wider CTA/back/cancel audit remains open.

Use `assets/images/brand/davochain_logo.png` for brand marks and `assets/images/brand/naira_coin.png` for NGN wallet/token artwork. The coin and updated onboarding/Appearance illustrations were generated with transparent backgrounds; older embedded marks were replaced. Unused historical supplied assets remain for reference. Original edited illustrations are preserved outside the app in `../tmp/branding-originals/`.

Validation: `flutter analyze --no-pub` reported no issues; `flutter test --no-pub` passed all 22 tests, including Android scroll boundaries, dashboard destinations, History back navigation, embedded input borders, pinned deposit actions, reduced motion, and responsive profile regressions. Debug APK build succeeded. The Android emulator walkthrough confirmed updated onboarding branding, complete bottom navigation icons, Trade and History destinations, Android back return, and dashboard scrolling with the navigation bar pinned. Final regenerated Naira artwork is flat cobalt/sky blue to match the current brand. Full screen-by-screen Figma and interaction verification remains open.

The rebuilt flat Naira token was also visually confirmed in the Android Select Wallet sheet. No Flutter/AndroidRuntime error entries were returned in the app PID-filtered check. One further asset-quality issue observed during this walkthrough: the supplied Solana raster has an opaque dark backdrop; review its approved artwork in the next asset cleanup pass.

## Dashboard asset scrolling update

On the emulator-sized layout, welcome/balance/setup/actions/promotion and Assets heading remain fixed; only the asset list scrolls. Compact spacing shows three complete rows initially. USD Coin is the fourth deterministic mock asset. After the full mock verification success is acknowledged with Back to Home, the session-only `PreviewAccountState.setupComplete` notifier removes the setup banner and makes space for all four rows. App restart resets this demonstration state; it does not verify a real account.

Short-height or enlarged-text layouts use an outer scroll fallback so dashboard controls remain reachable. Focused tests cover realistic Android safe-area insets, three/four-row visibility, fixed promotion position during asset scrolling, success-driven banner removal, and a short-screen fallback. The full suite now contains 25 passing tests.

Final Android walkthrough: three complete rows are visible on landing; swiping within the white asset list reveals USD Coin while the welcome/balance/setup/actions/promo and Assets heading retain their positions. Installed the final debug build on emulator-5554.


## Supplied Naira logo and profile corrections

The user's `../assets/davochainnairalogo3.png` is the selected Naira wallet/token variant. Its blue tile and white Naira symbol retain contrast in small wallet, funding/payment, withdrawal, review and transaction icons. It is copied unchanged to the existing `assets/images/brand/naira_coin.png` path; other variants remain supplied reference assets. Confirmed 1254x1254 PNG with transparent exterior. General Davochain branding still uses its standard logo.

Profile and Personal Information have a thin divider below the title. The shared portrait layout crops the padded asset canvas without modifying the photograph, aligns verification/edit badges to the lower-right portrait edge, and reduces header whitespace. Crypto Security uses the same blue lock artwork as adjacent security controls. Home and Settings footer SVGs now include the interior curved stroke and gear circle visible in the reference.

Verification: analyzer no issues; full suite 26 passing tests; Android debug build succeeded. Profile regression checks include portrait/badge overlap and compact identity spacing.
Android emulator verification confirmed the supplied Naira logo in Select Wallet, compact Profile and Personal Information portrait/badge layouts, blue Crypto Security icon, and corrected Home/Settings footer details. Final app PID-filtered Flutter/AndroidRuntime error check returned no entries.
