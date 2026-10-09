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

The variable **Sora** font and OFL license are now bundled in `assets/fonts/sora/`, with weights 400, 500, 600 and 700 registered in `pubspec.yaml`. Review typography using this packaged font.

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

## Mobile experience pass - 2026-10-07

Implementation plan: `docs/plans/2026-10-07-mobile-experience.md`.

- Welcome uses a true PageView with finger-following illustration motion, reachable actions,
  accessible page selectors, Skip/Replay and Android Back to the previous introduction.
  Existing supplied artwork is retained. The security artwork is historically named
  `gift_cards.png`; the gift-card artwork is named `digital_assets.png`. Call sites now
  match actual content, rather than trusting those filenames.
- Splash is finite (780ms reveal, 1.2s handoff); reduced motion is static with a 250ms
  handoff and no transition. Removed perpetual illustration tickers.
- Shared auth primary buttons have press feedback, one activation haptic, explicit
  disabled/loading semantics and static reduced-motion loading. Native MaterialPageRoute
  transitions restore platform navigation behavior (including tested iOS edge back).
- Bundled Sora variable font and OFL license from Google Fonts, matching the existing
  font-family declarations. Dashboard three-row layout remains intact on the emulator.
- Explore demo opens the mock dashboard without credentials, with a clear sample-data
  notice. Login says demo preview, validates email shape, displays local busy feedback
  and prevents duplicate submission. No network authentication or credential persistence.
- Auth screens now declare system-bar appearance with AnnotatedRegion; transparent field
  interiors preserve their outer rounded borders. Back/password visibility have labels.
- Dashboard reduced-motion entrance is immediate with no delayed animation controllers.

Verification: 45 widget tests passed, flutter analyze reported no issues. Coverage includes
320x568 portrait at 2x text, 568x320 landscape at 2x text, slow swipe and Android Back,
demo/login/signup destinations, reduced-motion idle behavior, splash disposal, button
cancel/activation and native edge-swipe. This is debug-mode functional QA, not measured
release/profile performance. Android build and final emulator confirmation are recorded
in ../tmp/mobile-experience-build.txt and ../tmp/emulator-review/.

Figma connector was retried after the user reported restored access, but still returned
"This app connection requires reauthentication before other actions on this app can
succeed." No live Figma comparison was claimed. Full flow polish beyond this welcome,
shared motion and login pass remains in the plan's later passes, along with backend
security/integration and profile-mode performance testing.

Final emulator confirmation: installed the corrected debug APK; checked welcome artwork
alignment, dark login status icons, rounded input borders, Login/back, Skip/Replay,
Android Back between introduction pages and Explore demo into the dashboard. Scoped
Flutter/AndroidRuntime error log was empty. Recorded a local walkthrough at
`../tmp/emulator-review/davochain-mobile-preview.mp4`. Emulator left on the dashboard.

## Screenshot repair pass - 2026-10-07

Removed Explore demo and Replay from onboarding as requested. Welcome restores the
oval logo/name composition and offscreen currency artwork with a finite1.7s sequence
and3.2s handoff; reduced-motion shows the static composition for1.2s. Native OS splash
still briefly shows the brand mark before Flutter renders.

NGN wallet imagery uses the Nigerian flag; NGD uses supplied naira_coin.png.
Buy/crypto/gift PIN screens share TransactionPinEntryScreen: masked digits, lettered
keypad, reserved Confirm area, stable heading/keypad, scrolling fallback.
Fixed withdraw Add crypto asset row width, balance label/value widths, deposit share
sheet content wrapping/receipt brand mark width. Copy notification now appears below
the status bar; other snackbars are not globally migrated yet.

Shared showDavoDatePicker offers a branded native date wheel with cancel/confirm and
bounds; identity DOB uses it. Identity name/contact forms scroll above the keyboard.
State is a selector with36 states+FCT, phone prefix wider, reward rate cards taller,
activity currency marks use the supplied Davochain Naira logo.

Transaction-details rows use consistent label/value alignment, bounded wrapping,
copy icons, scrollable content and pinned Done/Share Receipt actions. Receipt previews
reuse these rows and scroll naturally; deposit-status address/hash rows now wrap with
copy controls. Their alignment is checked at 320x568 with 1.3x text.

Buy/Sell/Swap tab handlers now replace the current trade mode rather than popping the
flow or displaying decorative labels. Headings match the active mode, and switching
preserves the selected asset. A shared TradeFormLayout scrolls content above the
keyboard and anchors the action to the available bottom edge. Percentage amounts use
available asset units; input estimates use the existing local mock rates. Review and
transaction records remain sample frontend data pending the backend integration.

Verification: 54 tests passed and flutter analyze reported no issues. This covers
short-screen trade forms with keyboard insets, mode changes, receipt/deposit variants,
stable shared PIN layout, wallet branding, onboarding controls and the date picker.

## Approved splash motion pass - implemented 2026-10-07

Reference: https://dribbble.com/shots/25193732-Logo-Animation-on-Splash-Screen
User approved the following direction and authorized implementation after the fixes:
dot enters; two D components assemble with a soft spring; logo shifts left as Davochain
reveals and the oval expands; currency artwork rises partly offscreen; brief settle
then onboarding fade. Implemented as a finite 2.9-second Flutter sequence with a
320ms fade into onboarding; reduced motion shows the completed scene for 700ms and
uses an instant route change. The real engine entry point passes first-frame raster
readiness, so the reveal does not advance while the native launch screen covers it.
Backgrounding pauses the introduction and cancels its static hold until return.

The original transparent logo is clipped into its dot, upper and lower components;
no approximate replacement logo is drawn. The upper/lower shapes settle with a mild
spring, then the mark shifts left and shrinks into the wordmark as its text mask and
oval reveal. Existing outlined currency artwork rises partly offscreen at the bottom.
One controller owns the sequence; there are no ambient loops or added dependencies.

Android 12+ uses custom davochain_launch_dot_animated.xml and its 420ms native dot
entrance, followed by a 120ms native exit fade. Older Android launch backgrounds use
the same static dot. These custom native resources/style references must be preserved
if flutter_native_splash is regenerated; the package's image-only config cannot
describe this vector animation. iOS native image remains its existing static mark.

Also fixed the Deposit header: its text was correct but a 66px fixed box clipped the
last letter. Both crypto and Naira deposit headings now center across available space.

Verification: 58 widget tests passed, flutter analyze is clean, and Android debug APK
built successfully. Splash checks cover delayed renderer readiness, one-time routing,
disposal, pause/resume, reduced-motion changes, narrow/landscape layout and large text.

Release verification: built app-release.apk (version 0.10.0, build 11), installed with
adb install -r on the user's Redmi 14C, and launched successfully. Package flags confirm
it is not debuggable. Captured the completed animated welcome composition on the phone
at ../tmp/emulator-review/phone-release-review.png. Device disconnected after this;
no physical-device runtime-log result is claimed. The APK uses the project's existing
local debug signing configuration for device testing; store signing is not configured.


## Release preview polish - 8 October 2026

Version 0.11.0+12 adds the returning-user authentication preview and completes the current dashboard/receipt/result repairs.

The dashboard previously selected full-page scrolling whenever available body height was below 760 logical pixels. That included the physical phone viewport. Ordinary portrait phones now use a more compact header while keeping only Assets scrollable; tests prove three full assets before setup and all four after setup at 360x820 and 411x914 with safe-area padding. Landscape/very short screens and enlarged text retain readable full-page scrolling rather than clipped controls. Large-text asset rows and navigation adapt separately.

Logout now clears the navigation stack and opens Login. KYC Tier 1 is NIN with the profile/contact/selfie flow; Tier 2 is BVN. Biometrics defaults off. Settings > Security opens explicit fingerprint preview setup, and the nearby 'Preview returning login' shortcut runs the existing splash then the returning preview. Its fingerprint control appears above password input. It accepts sample input and simulates fingerprint unlock; no credential checking, fingerprint enrollment, operating-system authentication, persisted session or minimize/background locking is implemented. Normal launches still run the full onboarding flow as requested.

ReceiptDetailRow gives labels and values bounded columns, a consistent right edge and a reserved copy-control gutter. Long values wrap and copy retains the complete supplied string. Crypto, buy, gift and deposit-status details use it. Gift receipts scroll above pinned actions. Deposit address and bank-detail content no longer rely on fixed text heights.

DavoSuccessMark/DavoResultScreen unify finite vector success presentation across trade, deposit, gift, auth and profile/KYC outcomes. Motion finishes in 850 ms; reduced motion is static and no replay loop runs. Pending/processing outcomes preserve their status. Native Material route transitions, Android predictive-back behavior and iOS edge-swipe behavior remain in place; returning preview adds restrained finite entrances.

Documentation reviews: docs/reviews/2026-10-08-architecture-research-review.md, 2026-10-08-release-coverage-review.md and 2026-10-08-mobile-motion-review.md. Feature-first organization follows the boss's permitted structure, while production data/domain separation is still incomplete. tmp contains historical evidence/intermediates, not active app copies. No tmp cleanup or dependency installation was performed. README font and native-splash regeneration guidance is reconciled with bundled Sora and the custom Android animated dot.

Source verification: flutter analyze --no-pub reports no issues; flutter test --no-pub passes all 81 tests. Logs are ../tmp/release-polish-analysis.txt and ../tmp/release-polish-tests.txt. APK/package/device evidence is appended after the build and installation are verified.


APK/device verification for 0.11.0+12: flutter build apk --release succeeded (62.4 MB, assembleRelease 203.5 s), and flutter build apk --debug succeeded (46.0 s). Release installed with adb install -r on the Redmi 14C; Android reports versionName 0.11.0/versionCode 12 and flags without DEBUGGABLE. Emulator reports the same version with DEBUGGABLE. Both newly built archives contain all 724 declared source assets/font files, with zero missing entries and zero SHA-256 byte mismatches. Build logs: ../tmp/release-polish-build.txt and ../tmp/release-polish-debug-build.txt.

Bounded physical release walkthrough: normal splash reaches onboarding; sample login opens Dashboard. At the phone's 720x1640/density320 display, BTC/ETH/USDT are fully visible. Dragging Assets reveals the complete fourth row while the promo text bounds remain exactly [56,780][325,876]. Fingerprint preview setup enables the Settings switch; the explicit returning preview runs splash then shows the fingerprint above password, with correct white system icons. Simulated fingerprint unlock returns to Dashboard. Confirming Logout opens Login. PID-filtered logs for this walkthrough returned no matches for missing assets, fatal/unhandled exceptions, RenderFlex overflow or missing plugins. This is not an exhaustive all-screen runtime audit. Evidence screenshots: ../tmp/emulator-review/phone-polish-dashboard.png, phone-polish-dashboard-scrolled.png and phone-polish-unlock.png.


## 2026-10-08 UI polish and verification redesign (0.12.0+16)

- Active KYC is now Basic (personal/contact details, choose NIN or BVN, 11-digit entry; no face) and Advanced (face first, identity documents, proof of address, review). The overview is wired from dashboard, profile and limits. Session drafts resume; logout/account switch clears them. Submission remains Pending review. Native camera/file selection and backend KYC validation/upload/review are not integrated. See docs/reviews/2026-10-08-basic-advanced-verification.md.
- Earlier UI polish includes typed branded receipts, PNG/PDF exports and Android download/share handling, compact circular share actions, copy alignment, buy/sell/conversion review values, gift-card forms/reviews/progress, blue success and checkbox motion, password/fingerprint login transitions, searchable state selection, amount grouping, top toast and keyboard dismissal. Small text sizes were not increased.
- Dark mode readiness is audited only; implementation remains future work. See docs/reviews/2026-10-08-dark-mode-readiness-audit.md.
- Fresh regression suite: 138 tests passed; Flutter analyze reported no issues. Android release build/installation evidence is recorded in docs/reviews/2026-10-08-basic-advanced-verification.md.

## 2026-10-08 motion execution and Trade navigation (0.12.0+17)

Implemented staged completed/submitted and password/fingerprint recipes, lifecycle/cancellation guards, reduced motion, coordinated result reveals and development-only deterministic gallery. Fixed inherited yellow auth decoration and clipped sheet close targets; refined Verification overview without enlarging small text. Footer Trade now opens the existing Buy/Sell/Swap screen. Full suite: 152 passed, one optional capture skipped; analyzer clean; 53 opt-in storyboard checkpoints captured. Release installed on emulator, all 728 declared asset/font files match. Installed walkthrough exercised Trade tabs and both wallet/cryptocurrency Close controls. Physical phone disconnected; native providers/backend and physical profile evidence remain pending. See docs/reviews/2026-10-08-motion-implementation-progress.md.

## 2026-10-08 appearance implementation (0.13.0+18)

Light/Dark/System now persist with SharedPreferencesAsync, restore before ordinary content, and use context-owned DavoColors extensions plus Material themes. Appearance draft saves on Next, Back cancels, pending writes block Back and serialize; failure retains the previous choice. Shared/auth/onboarding/financial/gift/history/profile/verification UI migrated without increasing fonts or changing mock transactions. Blue brand surfaces, colorful art and white receipt exports preserved. Full suite 172 passed, optional capture skipped; final four financial tests passed after Dashboard refinements; analyzer clean. Release built and installed on emulator; 728 assets/fonts match. Cold restart and live System changes including an open wallet sheet verified. App left System and emulator OS Night No. Physical dark/iOS/accessibility/performance evidence remains unverified. See docs/reviews/2026-10-08-dark-mode-implementation.md.

## 2026-10-09 remaining settings interactions

Bank linking now continues through number lookup/review and updates the session account list and withdrawal selector. Naira bank-details sharing opens the native composer using the displayed immutable details; failure offers clipboard copying. Password changes validate signup rules and confirmation. Support requests retain pending references and details for revisits. Rewards validate/review redemption and atomically update points and an integer-kobo preview reward balance. Deletion requires typed confirmation and acknowledgment, shows a pending result, then clears session state/navigation on sign-out; both entry points are wired. All service actions use injectable SettingsGateway fixtures, not real backend operations. Davo Points now use blue Davochain-mark coins across rewards and ambassador totals, while currency/crypto icons remain separate. No small text increase, version bump or installation. See docs/reviews/2026-10-09-settings-interactions.md for implementation and verification evidence.


## 2026-10-09 supplied assets and settings fidelity (0.13.0+20)

Appearance uses the three updated phone PNGs and exact blue-wave background, a 480 ms interruption-safe preview transition, and bottom-anchored System phones. Preference groups restore supplied icons and blue controls. Email/Messages/Callie retain truthful local-preview request interactions; typed channels and stable conversation IDs preserve history. All 747 declared runtime assets/fonts validate and match the release APK. Analyzer clean; 224 tests passed with four optional skips; nine final Appearance/profile tests and the opt-in capture test passed after the alignment follow-up. Release 20 installed on emulator-5554 with matching pulled APK hash and clean launch/navigation logcat. Installed screenshots confirm all selector labels/icons. See docs/reviews/2026-10-09-settings-fidelity-and-supplied-assets.md for asset audit, motion recipe and integration boundaries.


## 2026-10-09 transaction details and receipts (0.13.0+22)

Shared immutable records now connect funding, crypto buy/sell/swap/internal/external transfers and gift-card outcomes to details, timelines, contextual issue requests, history and PNG/selectable PDF exports. Actual flow amounts, precision, fees, network, date/ref and pending/failed status are preserved; Preview remains explicit. Default export masking and optional personal notes retained. Per final user direction, only Standard is exposed and type-based page heading is removed; alternate style code retained for later. PDF fallback fonts include Naira/math/emoji with an isolated surrogate CMap fix; unsupported text offers image export. 273 tests pass, analyzer clean; release22 installed on emulator with all753assets/fonts matching and installed APK hash verified. Native PNG/PDFDownloads and saved contents checked; no launch/navigation crashes. Backend/providers and physical/iOS tests remain pending. See docs/reviews/2026-10-09-transaction-receipts-implementation.md.


## 2026-10-09 security questions and receipt identity (0.13.0+23)

Three distinct preset/custom security questions now enroll through guided setup and hidden-answer review. Password, returning fingerprint and PIN preview login enter the three-answer challenge before Home. Settings supports atomic replacement of all three questions through an expiring email-code preview. Answer/code attempt limits, cooldowns, cancellation, account switching and deletion are covered. This is session-only frontend behavior; no email is sent and primary authentication remains a fixture. Production needs account-scoped server authentication, OTP delivery and real MFA; security questions are an additional knowledge check.

Receipt/history Preview and Sample wording from release22 is now removed per user direction. Populated DC/date fixture IDs preserve accepted provider identifiers exactly. A standard layout uses distinct purchase/sale/deposit/withdrawal/swap/gift headlines, action icons, supplied BTC/ETH/SOL/USDT marks, NGN/NGD/USD badges, both swap assets and known gift product logos. Details, PNG and PDF share the identity. Gift-card progress now advances and animates across all three routes, including back/reduced motion.

Analyzer clean; full suite314passed, six optional captures skipped; final30receipt regression checks and opt-in visual confirmation passed. Release23APK79,635,999bytes, all753declaredassets/fonts/licenses match, three Android ABIs, no debuggable flag. Emulator install and pulled APK hash verified: eb77b50cf299656c4459181e497874430ef89d3a319b5de44c10900eb27cf84f. Native enrollment with custom question, PIN challenge to Home, swap identity and selectable PDF Download checked with clean crash/Flutter overflow logs. See docs/reviews/2026-10-09-security-questions-implementation.md and docs/reviews/2026-10-09-receipt-identity-and-gift-progress.md.


## 2026-10-09 single-question challenge and Nigeria-only signup (0.13.0+24)

Supersedes release23 login behavior: enrollment/reset retain exactly3questions, but each login asks1randomlyselectedquestion with1hiddenanswerfield. Selection remains stable during retries, matches only its bound answer, consumes successful challenges and preserves the shared cooldown across new challenges. Recovery picks a new challenge after replacement. Signup lists Nigeria only; a vector green-white-green flag now appears in picker/selected field/+234 prefix without emoji dependence. Analyzer clean, fullsuite317passed/six optional skips, visualcapturepassed. Release24 installed on Redmi14C and emulator; bothpulledAPKhashesmatch `474400ad850f27920e38846838813e41630f893ebb7abc4c7b44bd095fd2a6f8`. All753declaredfilesmatch. Nativeemulatorsignupflagchecked. See docs/reviews/2026-10-09-single-question-login-and-nigeria-signup.md. Production authentication/email remain pending.

## 2026-10-09 splash brand refinement (0.13.0+25)

Final logo/name reduced 6% at the existing raised position. Original Figma dollar, naira and bitcoin SVGs replace the stretched low-resolution footer; proportions and bottom crop follow the source design. User-requested timings preserved (2900 ms intro, 320 ms exit, 700 ms reduced hold). Analyzer clean, 19 related tests passed, three phone-size captures checked. Release25 installed and launched on Redmi14C and emulator; 756 declared assets match and both installed APK hashes verified. See docs/reviews/2026-10-09-splash-brand-refinement.md.

## 2026-10-09 safe-area review (0.13.0+26)

Selection/confirmation/warning sheets now preserve system insets and scroll on short views; modal routes retain top cutout protection. Country page scrolls and Nigeria picker reserves bottom navigation space. Bank form scrolls above the keyboard and account names wrap without fixed-height overflow. Right-edge close controls corrected. Initial33relatedchecks, final6bank/withdrawal checks and12country/auth/safe-area checks passed; analyzer clean. Release26 installed on emulator and country picker checked; all756declared files match. Physical-device confirmation pending. See docs/reviews/2026-10-09-safe-area-review.md.
