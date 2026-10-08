# Dark-mode readiness audit — 8 October 2026

Historical audit snapshot. Implementation was subsequently authorized and completed in the current workspace; see [implementation review and evidence](2026-10-08-dark-mode-implementation.md). The counts and line references below describe the pre-migration source.

The current light interface has a useful shared foundation, but dark mode is not connected. Settings → Appearance is an interactive visual prototype: it changes the selected card locally, then closes. A reliable dark mode requires semantic colors across the screens, application-level preference state, asset decisions, and separate treatment of exported receipts.

## Scope and evidence limits

Read-only source and asset audit of the current Flutter app, using the Impeccable native audit guidance. Only this report was added. No application code was changed, and no build, widget test, emulator run, device screenshot, VoiceOver or TalkBack session was performed for this audit. Asset images inspected directly: `balance_wave.png`, `appearance_preview_exact.png`, and `davochain_logo.png`. These establish asset content, not rendered screen correctness. File lines refer to the inspected working tree; concurrent auth/receipt work can shift them.

This is a dark-mode planning review, not a complete accessibility or native-conformance certification. Appearance/theming readiness is **1/4**: a centralized light palette exists, but no dark variant or connected mode setting exists. Other audit dimensions are unscored because their runtime evidence is absent. No platform pass/fail or whole-app health score is claimed.

The app remains a frontend preview with mock financial data and local flow state (`DEVELOPMENT_CONTEXT.md:25–35`, `:153–154`). Dark-mode acceptance must not be described as verification of real payments, balances, account verification, authentication security, or backend behavior.

## Source baseline

Lexical scan of 42 Dart files under `lib`, excluding tests, assets, generated build outputs, and native code:

| Pattern | Occurrences | Interpretation |
|---|---:|---|
| `Color(0x…)` | 436 | Raw hexadecimal constructor occurrences, including alpha colors and palette declarations |
| `Colors.*` | 668 | Includes transparent, shadows, brand foregrounds, and legitimate fixed document colors |
| `Colors.white` / numbered white variants | 153 | Subset of the previous row; must classify by role before replacing |
| `AppColors.*` | 453 | Centralized but static light values, not context-dependent semantic tokens |
| `Theme.of(` | 21 | Concentrated in authentication/onboarding and app builder; not a completeness measure |

Counts are occurrences, not distinct colors, failing widgets, or lines. Regexes: `Color\(0x[0-9a-fA-F]+\)`, `Colors\.[A-Za-z]+`, `Colors\.white(?:\d+)?\b`, `AppColors\.[A-Za-z]+`, and `Theme\.of\(`. Recount after implementation; fixed brand colors, document rendering, and transparent barriers need a reviewed exception list rather than a zero-literal target.

| Hotspot | Raw hex | `Colors.*` | `AppColors.*` | `Theme.of` |
|---|---:|---:|---:|---:|
| `features/profile_settings/presentation/profile_settings_flow.dart` | 138 | 125 | 80 | 0 |
| `features/dashboard/presentation/dashboard_screen.dart` | 93 | 77 | 44 | 0 |
| `features/crypto/presentation/crypto_full_flow.dart` | 78 | 169 | 119 | 0 |
| `features/gift_cards/presentation/gift_card_flow.dart` | 48 | 69 | 48 | 0 |
| `features/buy_crypto/presentation/buy_crypto_screens.dart` | 13 | 49 | 36 | 0 |

All paths in this table are under `lib/`.

## Findings and priorities

### P1 — Appearance has no application effect or persistence

`lib/features/profile_settings/presentation/profile_settings_flow.dart:2063–2116` stores `int selected = 0` in `_AppearanceScreenState`. Light/Dark/System call local `setState`; Next only calls `Navigator.pop`. Reopening recreates Light as selected. The preview at `:2095–2101` always uses the same two raster images. `_AppearanceChoice` at `:2892–2950` paints a fixed miniature dark card, not a real dark interface, and selection is communicated by raster indicators without an explicit selected semantics state.

`lib/app.dart:20–23` supplies only `theme: AppTheme.light`; there is no `darkTheme`, explicit preference-driven `themeMode`, or preference store in the app. `AppTheme.light` is the sole factory (`lib/core/theme/app_theme.dart:26–38`). Flutter's default mode is System, but without a dark theme it falls back to the light theme. [Flutter MaterialApp.themeMode](https://api.flutter.dev/flutter/material/MaterialApp/themeMode.html).

Plan: retain the existing Light/Dark/System UI and Next action, bind its selection to an app-level controller, and apply/persist the choice on Next. Opening the screen reads the saved choice; back cancels any uncommitted selection. System resolves the OS preference and responds to changes while running. Use System for a new installation, preserve a saved explicit preference, and restore it before the first ordinary content frame. Announce selected state and give the preview an accurate theme-specific image or small live sample. Do not enable a working toggle until all reachable screens meet the migration gate.

### P1 — Static light colors override any future dark theme

`AppColors` (`lib/core/theme/app_theme.dart:3–24`) names physical colors such as `ink`, `offWhite`, and `fieldFill`, with no context-aware dark values. The text theme and field theme use these fixed values (`:42–117`). Updating `ColorScheme` alone would leave most custom UI unchanged.

The profile `_Shell` explicitly paints scaffold, app bar, and tint white (`profile_settings_flow.dart:3206–3210`). File-level constant styles at `:3811–3823` fix text to dark grays. Dashboard scaffold is `#F8F9FB` (`dashboard_screen.dart:46`), promotional text is fixed dark (`:792`), and its pastel action tiles are specified locally (`:602–629`). Crypto fields explicitly paint `#F5F6F9` (`crypto_full_flow.dart:2767`); shared trade form defaults to `#F8F9FB` (`trade_form_layout.dart:12`).

Plan: move surface/text/border/interaction/status roles to theme-resolved values. Convert constant color-bearing text styles to typography plus colors obtained in build context. Preserve layout, content, font choice, navigation, and current mock calculations during the migration. Do not globally replace white or invert hex values: white on a blue balance card is intentional; white pages and pale card backgrounds serve different roles.

### P1 — Inputs, feedback, sheets, and native overlays need state-specific colors

The shared light field theme uses `AppColors.muted` (`#A7A7A7`) for hints on white (`app_theme.dart:88–96`). Their mathematical opaque contrast is **2.41:1**. This is a concrete light-mode contrast weakness for readable hints, independent of dark-mode work. The current blue `#135CF7` with white is **5.38:1**; preserve this useful CTA relationship. Green `#20C55D` on white is **2.28:1**, and red `#F44336` on white is **3.68:1**: they are unsuitable for ordinary small text in those pairs. These are token-pair calculations, not rendered-screen measurements; opacity, background, text size, and actual usage still need checking. Disabled controls require separate assessment, not the same normal-text threshold.

Shared PIN entry fixes keypad text black (`transaction_pin_entry.dart:77`), tile fill pale (`:57`), and dot color to `AppColors.ink` (`:59`). Date sheet fixes white (`davo_date_picker.dart:11`) while embedding a Cupertino picker (`:15`), so Material and Cupertino brightness must agree. The inline decoration intentionally suppresses all borders (`inline_input_decoration.dart:11–19`); its surrounding field, not a global border override, owns focus/error treatment. Auth shell fixes white and light bars (`auth_widgets.dart:26–36`). Shared toast fixes dark background plus white text (`davo_toast.dart:85–99`); it needs a separately contrasted inverse feedback role, not automatic inversion.

Crypto selectors use transparent modal backgrounds (`crypto_full_flow.dart:34–65` and many later callers), so their inner sheet widgets must migrate too. Profile social dialog fixes white (`profile_settings_flow.dart:3800`), while other alert dialogs inherit theme (`:3801–3802`). Receipt share sheet fixes white (`davo_receipt_export_frame.dart:44`). Test all of these with loading, disabled, selected, focus, error, and destructive states.

Set text/input/cursor/selection colors, focus ring, error text and borders, disabled foreground/background, modal surfaces, scrims, divider, drag handle, and icon roles explicitly in the theme. Audit password strength separately (`password_strength_palette.dart:7–9`); the existing darker light-mode warning/success values should have appropriate dark equivalents while retaining text labels.

### P1 — System-bar styling assumes light content

`app_page_route.dart:10–18` applies dark status icons, light status brightness, and a white navigation bar. Dashboard `initState` separately sets the same light style (`dashboard_screen.dart:34–40`). Auth has another fixed style (`auth_widgets.dart:26–31`). These would disagree with a dark scaffold. Brand splash (`brand_splash_screen.dart:32–38`), onboarding (`onboarding_screen.dart:68–73`), and returning unlock (`returning_unlock_screen.dart:54–59`) already have blue/dark-background exceptions; preserve their foreground contrast rather than applying one global style to every route.

Plan: derive ordinary route/app-bar overlays from resolved brightness and surface color; retain explicit brand-screen exceptions. Verify status/navigation bars on push, pop, modal dismiss, OS appearance change, resume, and keyboard open/close. No `keyboardAppearance` setting was found in `lib`; supply it for text entry where supported and verify actual native keyboard/IME behavior. The app locks portrait (`main.dart:8`), so short portrait layouts and keyboard insets are the minimum supported acceptance conditions.

### P1 — Receipts must retain a deliberate document theme

Current receipt capture is real image/file generation: `davo_receipt_export_frame.dart:36–38` captures its `RenderRepaintBoundary`; `receipt_export_service.dart:63` renders PNG and `:103–107` puts that image into an A4 PDF. The frame's painted receipt subtree is white (`davo_receipt_export_frame.dart:72–75`), while `buy_receipt_screen.dart:72`, `:94`, `:124` contains text styles with inherited foregrounds. A future dark parent could therefore make pale inherited text appear on the fixed white receipt. Existing explicit dark `AppColors` values would conversely fail if the document background were blindly made dark.

Recommended policy: **the exported PNG/PDF and receipt paper remain white, with fixed dark document text and original brand/status colors selected for paper contrast**. The surrounding app bar, page canvas, buttons, and share sheet follow the active app appearance. Enclose the entire captured receipt subtree in a dedicated light document `Theme`/palette, including inherited text and icons. Do not theme only `ColoredBox`. Use the same immutable sample transaction for before/after export comparisons; confirm complete content, file readability, PNG transparency/background, PDF pagination and share preview. OS share/download UI follows the OS, which can differ from a manually selected app theme. Validate native behavior separately.

### P2 — Raster art and fixed previews require intentional variants

The inspected `assets/figma_exact/balance_wave.png` is pale, partly transparent mountain/wave art, painted in the blue balance card (`dashboard_screen.dart:381–382`). Preserve the recognizable layered wave; check its composited contrast and opacity on the chosen dark card instead of turning it into an opaque gray hill. `appearance_preview_exact.png` is a complete pale-blue raster landscape; changing the container cannot recolor it. Provide a dark preview variant or replace only this preview with a theme-aware sample that preserves the motif.

The inspected `assets/images/brand/davochain_logo.png` contains transparent two-tone blue shapes. `DavochainLogoLockup` supports explicit `logoColor` with a `ColorFilter` (`davochain_logo_lockup.dart:19–32`), and its text defaults white (`:7`). Use the two-tone original where it contrasts, and the existing white treatment on deep brand surfaces; do not apply a blanket monochrome filter to full artwork, bank logos, gift-card brands, crypto symbols, flags, QR codes, portraits, or receipt paper. Many navigation/status icons are PNGs (for example profile back at `profile_settings_flow.dart:3217–3221`); classify monochrome icons for themed tint or vector replacements, inspect antialiasing, and preserve multi-color brands. GIFs such as notification empty art and status animations need their frames checked for baked white backgrounds.

### P2 — Native launch behavior is a separate appearance boundary

Android provides day/night resource themes. Both Android 12 variants use fixed brand-blue splash background `#135CF7` and the animated launch mark (`android/app/src/main/res/values-v31/styles.xml:9–11`, `values-night-v31/styles.xml:9–11`); pre-12 drawable background also uses blue (`drawable/launch_background.xml:4`). `forceDarkAllowed=false` is present, preventing auto-darkening from substituting for deliberate Flutter theming. Day/night NormalTheme uses its parent's `?android:colorBackground`, so the transition into Flutter needs verification for flashes when app and OS preferences disagree.

iOS storyboard uses LaunchBackground and LaunchImage plus a white fallback view (`ios/Runner/Base.lproj/LaunchScreen.storyboard:19–22`). LaunchBackground's asset catalog has no dark appearance entry (`ios/Runner/Assets.xcassets/LaunchBackground.imageset/Contents.json`). `pubspec.yaml:49–60` configures a fixed blue generated splash. Keep the blue brand launch in both modes unless product direction changes; verify that the visible native asset and first Flutter splash match and that normal content opens with restored preference. Static launch art is not evidence of dark app support. No iOS launch/device run was possible in this audit.

### P2 — Accessibility needs a bounded dark-mode regression pass

Good existing foundations include reduced-motion handling in app builder (`app.dart:35`), routes (`app_page_route.dart:24`), auth widgets, splash/onboarding, toast, PIN entry, and success mark (`davo_success_mark.dart:29–30`); PIN digit/key semantics (`transaction_pin_entry.dart:52`, `:72`) and toast live-region semantics (`davo_toast.dart:70`) should survive migration. Dashboard contains explicit large-text adaptations (`dashboard_screen.dart:106`, `:361–366`, `:898`), so keep these branches.

Gaps include the always-repeating profile face detection controllers (`profile_settings_flow.dart:245`, `:1519`), switch animation (`:3351`), and spending progress animation (`:3387`), with no reduced-motion guard in that file. Appearance's fixed 180px card and raster selected indicator require large-text and screen-reader checks. Do not claim all fixed font sizes defeat scaling: Flutter Text normally respects text scaling; risk comes from fixed-height containers, clipping, and absolute layout. Verify actual behavior at 1.0× and 2.0× text scale, with TalkBack/VoiceOver selected-state announcements, focus order, 48px interaction target checks, grayscale/color-deficiency checks, and readable status labels in both themes. Flutter recommends checking contrast, controls, screen readers and large text. [Flutter accessibility checklist](https://docs.flutter.dev/ui/accessibility).

## Proposed color architecture and visual direction

Use a deep blue-gray canvas with visibly separated surfaces, crisp pale text, and controlled bright blue actions. Keep the dashboard's saturated blue balance card as the main brand anchor; let surrounding navigation and financial forms be quieter. Dark mode should retain borders, cards, hierarchy, and the blue/wave identity. Avoid one flat black background, glows, wholesale inversions, or bright white field islands.

Use `ColorScheme` for standard Material roles (`primary/onPrimary`, `surface/onSurface`, `onSurfaceVariant`, `outline`, `error/onError`) and component themes. Add a typed `ThemeExtension` for app-specific roles (status foreground/background, balance artwork treatment, semantic action tiles, toast inverse roles, field fill, receipt document policy). Flutter documents custom extensions with `copyWith`/`lerp`; this allows custom colors to participate in theme changes. [Flutter ThemeExtension](https://api.flutter.dev/flutter/material/ThemeExtension-class.html).

Suggested starting palette, subject to rendered comparison and full pairwise contrast checks:

| Semantic role | Current light basis / proposed light correction | Proposed dark |
|---|---|---|
| page canvas | `#F8F9FB` | `#0B1220` |
| base card/surface | `#FFFFFF` | `#101827` |
| elevated sheet/dialog | `#FFFFFF` | `#192437` |
| field fill | white or existing subtle gray by component | `#162135` |
| primary text | `#1C1C1C` | `#F3F6FC` |
| secondary text | `#686868` | `#AAB6C8` |
| readable hint | move `#A7A7A7` toward `#727A88` | `#96A5BC` |
| divider / outline | distinguish decorative divider from control outline | `#2B3B53` / `#60738F` |
| solid brand CTA / on CTA | `#135CF7` / white | `#135CF7` / white |
| text link / focus accent | `#135CF7` | `#8EADFF` |
| selected/brand soft surface | `#EDF2FD` | `#1B2E55` |
| success text / soft surface | darker green for readable text | `#66D991` / `#153327` |
| warning text / soft surface | existing dark amber | `#F4C46C` / `#382B17` |
| error text / soft surface | darker red for readable text | `#FF9A94` / `#3B2228` |
| receipt paper / receipt ink | white / fixed dark document palette | same document palette |

Calculated examples: proposed dark primary text on base surface is **16.41:1**, secondary **8.66:1**, and text link **8.10:1**. These do not certify every palette pair or component. Blue CTA remains **5.38:1** with white; use the lighter accent for links on dark surfaces. Design disabled states independently; communicate pending/success/failure with words/icons as well as hue. Do not make text links and filled buttons share a color merely because both are called primary.

## Phased implementation plan

1. **Freeze a reviewable light baseline and define roles.** Capture current representative screens and overlays after active auth/receipt repairs land. Record each remaining literal as brand, document, semantic UI, alpha overlay, or decoration. Define light/dark schemes and extension roles; choose explicit defaults and save/cancel behavior for Appearance. Exit: token map and screenshot baseline exist; the current light UI still has a reference.
2. **Build preference/theme foundation behind an unfinished-feature gate.** Add AppTheme.dark, a small application appearance controller with persisted Light/Dark/System values, and MaterialApp theme wiring. Keep state management proportional to this preview app; no financial-domain refactor is required. Resolve initial setting before normal content and react to OS changes in System. Add preference/controller tests and a small widget check for each mode. Exit: mode logic works in isolated harnesses; incomplete dark screens are not advertised as finished.
3. **Migrate shared components and exports first.** Auth shell, page routes, input decoration owners, app bars, buttons, PIN entry, toast, date picker including Cupertino brightness, trade form, result/success layouts, receipt frame/share sheet. Enforce light document subtree and asset exceptions. Preserve reduced-motion behavior. Exit: complete representative light/dark auth and receipt journeys, including export samples, pass visual/contrast review.
4. **Migrate high-reach surfaces.** Dashboard, asset selectors/wallet/deposit/withdraw/send/sell/swap, buy amount/review/details, transaction history, gift cards, then profile/settings/KYC/support/referrals/leaderboard and all nested sheets/dialogs. Work by screen/widget boundaries in the large files, not a repository-wide replace. Exit: every reachable screen and transient state has the chosen semantic roles and asset decisions; light screenshots match approved changes.
5. **Connect Appearance and complete native acceptance.** Replace the static preview as needed; bind saved selection and add selected semantics. Review system bars, keyboard, cold-start/resume transitions, and platform launch consistency. Run the matrix below, contrast/golden/widget checks and targeted real-device tests. Exit: no incomplete screen reachable in dark mode; all failures resolved or explicitly documented before calling the feature complete.

## Screen inventory and acceptance matrix

Run each row in explicit Light and Dark, plus System with OS light/dark and a live OS change. Include push/pop, back cancellation, and modal dismiss. Use deterministic sample data so comparisons mean something.

| Surface / source owner | States and special checks |
|---|---|
| Native splash → brand splash → onboarding (`android/res`, `ios/Runner`, `features/onboarding`) | cold/warm launch; brand mark/waves; no white/black flash; saved app preference differing from OS; reduce motion |
| Signup, login, forgotten/recovered password, email/SMS verification (`features/auth`) | empty/focus/filled/error/loading; password strength; OTP/PIN; text selection; keyboard shown; inline decoration; helper/readability |
| Returning unlock and fingerprint setup (`features/auth`) | blue-background bar exceptions; biometric prompt/fallback; preview labels; disabled/error/loading |
| Dashboard (`features/dashboard`) | balance visible/hidden; setup banner present/removed; notifications; promo art; every asset row; compact portrait and large text; saturated balance card remains readable |
| Crypto (`crypto_full_flow.dart`) | wallet/asset/network/bank/address selectors; deposit QR/address/copy; amount/max/conversion/review; insufficient or invalid input; withdrawal/sell/swap/transfer confirmations; warning sheets; PIN/progress/success/details |
| Buy crypto (`features/buy_crypto`) | amount field and asset sheet; disabled continue; validation/toasts; review; PIN; progress; result; transaction detail; receipt |
| Gift cards (`gift_card_flow.dart`) | catalogue/brand art; filters; buy/sell form; uploaded card preview; review; submitted/verification/PIN/status/details/receipt; multi-color art retained |
| Transaction history (`transaction_history_screen.dart`) | filters/date picker/search if present; empty and populated states; pending/success/failure labels; details and receipt entry |
| Profile/settings (`profile_settings_flow.dart`) | profile/menu/avatar; Appearance selected/cancel/save/reopen/restart; personal info/linked banks/PIN/password/biometrics; notification/privacy/security toggles; KYC tiers and document/face/upload screens |
| Support/referrals/leaderboard/notifications (`profile_settings_flow.dart`) | chat/input; empty GIF/portrait/medals; social open dialog; logout/delete alert; links; progress/switch animations with Reduce Motion |
| Every receipt + sharing (`davo_receipt_export_frame.dart`, `receipt_export_service.dart`, receipt bodies in flow files) | same sample exports from both app modes; complete PNG and PDF content; white paper/dark text; native share/download/cancel/error; OS picker theme may differ |

Cross-cutting checks: text scale 1.0× and 2.0×; smallest supported portrait height and keyboard open; focused/disabled/error/selected states; status/navigation bars on Android gesture and button navigation; TalkBack and VoiceOver; grayscale and increased-contrast settings where available; reduced motion before startup and during a session. Use screenshots from native runtime for visual acceptance. Existing tests are useful regression anchors (`auth_refinements_test.dart`, `amount_toast_keyboard_test.dart`, `pin_and_date_test.dart`, `profile_layout_test.dart`, `receipt_alignment_test.dart`, dashboard layout tests), but their presence is not proof that dark mode passes, and they were not run in this audit.

## Completion criteria

Appearance persists and changes the whole reachable interface; System follows the OS; screens remain readable without changing mock financial behavior; transient overlays and native bars match their actual surfaces; light mode retains approved visual identity; artwork has intentional variants/tints; receipt files remain paper-safe; no unverified backend or device claims appear in the handoff. Keep dark-mode implementation separate from current auth/receipt repairs so each regression can be traced.

## Follow-up component note

The State selector was subsequently replaced with `shared/widgets/davo_state_picker.dart`. It uses a white sheet and static AppColors, so include it in the semantic-color migration with other selectors. The original lexical counts remain the audit snapshot, not refreshed totals. Appearance still has no global theme persistence.
