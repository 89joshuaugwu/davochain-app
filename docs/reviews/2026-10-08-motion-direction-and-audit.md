# Davochain motion direction and source audit

Status: design proposal only. No animation, application code, APK or device installation changed for this audit. The reported yellow line remains unfixed at the user's request.

## Design decision

Use **short, staged brand sequences** for meaningful outcomes. The accepted splash is the visual reference: separate logo pieces assemble, the composition moves into place, lettering reveals, supporting artwork enters, and everything settles. That ordered choreography is what gives it the feeling of a short film. Preserve that quality through deliberate sequences, not by giving every control a large animation.

The proposed system has five principal sequences: **completed**, **submitted**, **password unlock**, **fingerprint unlock**, and **working**. Small controls use restrained feedback. White space, cobalt blue, the supplied Davochain logo, crisp vector edges and a final still frame are the common visual language.

These timings and drawings are authored design decisions, not claims that a reference video was reproduced. No model can guarantee an identical interpretation from adjectives alone. The numeric storyboard below, deterministic preview frames and acceptance checklist are the implementation contract. The first implementation must generate reference frames before app-wide integration.

## Audit scope and evidence

- Searched all 47 Dart source files with project-wide queries for animation primitives, success/result callers, processing states, GIFs, timers, sheets and route transitions; inspected the shared implementations and principal callers.
- [Source index](2026-10-08-motion-source-index.md): 80 motion/result occurrences, including declarations and legacy code. This is a navigation index, not a claim of 80 distinct animations.
- Existing shared primitives: `DavoSuccessMark`, `DavoResultScreen`, `DavoAuthJourney`, `DavoAnimatedCheckbox`, `Entrance`, `showDavoToast`, `AppPageRoute`.
- Existing tests: `splash_motion_test.dart`, `success_motion_test.dart`, `auth_motion_test.dart`, `dashboard_motion_test.dart`, `animated_checkbox_test.dart`, `advanced_verification_flow_test.dart` and the receipt/layout regressions.
- This is a source audit, not a fresh device recording of every path. Native-provider/backend gaps remain as documented in the KYC and release reviews. Animation must never manufacture an outcome.
- The earlier `2026-10-08-mobile-motion-review.md` describes an older state. This document supersedes its proposed motion direction; it does not erase its historical findings.

## Yellow line: likely cause, no fix applied

The strongest source-backed explanation is inherited text decoration in `lib/shared/widgets/davo_auth_journey.dart`:

1. `LoginScreen` and `ReturningUnlockScreen` put `DavoAuthJourney` **around** their scaffold.
2. `DavoAuthJourney` draws its animation overlay as a sibling of that scaffold: `Positioned.fill → ColoredBox → Center → Text`.
3. The overlay has no `Material`/owned `DefaultTextStyle`. Its explicit `TextStyle` sets size, weight and color, but leaves decoration and font family inherited.
4. Flutter's installed `packages/flutter/lib/src/material/app.dart:46` defines its fallback text style with `TextDecoration.underline`, yellow `0xFFFFFF00`, and `TextDecorationStyle.double`. It is not merely a debug overflow stripe and should not be assumed to disappear in a release build.

The [Flutter MaterialApp documentation](https://api.flutter.dev/flutter/material/MaterialApp-class.html) describes the red/yellow fallback when text lacks a Material ancestor. This explains a yellow underline below **Signing in / Unlocking / Welcome back** particularly well. Without the user's exact frame, it remains a diagnosis candidate, not a confirmed visual reproduction of the reported line. Yellow/black diagonal stripes at a layout edge would instead suggest overflow; investigate that separately if the observed shape differs.

Later fix: give the overlay a full `Material` text environment and explicit themed Sora text with `TextDecoration.none`; keep its accessibility semantics and contrast. Test the effective `RichText` style, not just the supplied `Text.style`. Do not suppress Flutter diagnostics globally or hide overflow. The toast already has a Material wrapper and does not have this same structural issue.

## Current state and recommendation by journey

Paths below are relative to `lib/`. Symbol names are the stable anchors; line locations are in the source index.

| Journey / state | Current implementation | Proposed recipe / action |
|---|---|---|
| Cold splash and explicitly opened returning splash | `features/onboarding/presentation/brand_splash_screen.dart`, `BrandSplashScreen`; 2900 ms assembly, 320 ms exit, 700 ms reduced hold | **Keep accepted splash**, including recent oval removal. Use as reference, not a new redesign target. |
| Onboarding pages / indicators | `onboarding_screen.dart`; page-driven artwork/text and animated indicator | Keep gesture-linked page movement; no second entrance on every swipe. |
| Normal login password | `features/auth/presentation/login_flow.dart` → `DavoAuthJourney` | Password sequence P below; first fix text inheritance. |
| Returning password | `returning_unlock_screen.dart` → same journey | Exactly the same P sequence; prevent route duplication. |
| Returning fingerprint | same wrapper; 1000 ms pulsing ring then icon swap | Fingerprint sequence F; visibly different from password. Actual OS biometric result owns success. |
| Fingerprint setup finished | `fingerprint_setup_screen.dart`; shared 148 mark | Compact completed C, semantic label describes enrollment, not authentication. |
| Email / SMS verified | `verification_flow.dart`, `VerificationSuccessScreen` → shared result | Completed C, regular 1120 ms. |
| Incorrect OTP / PIN | `verification_flow.dart`; 430 ms shake and inline error | Error E; keep entered text/focus and explicit explanation. |
| PIN entry dots | `shared/widgets/transaction_pin_entry.dart`; animated decoration | Micro feedback M; never animate/display actual PIN characters. |
| New transaction PIN completed | `profile_settings_flow.dart`, `PinSuccessScreen` → shared result | Compact completed C. |
| Forgot-password reset completed | `login_flow.dart`, `_PasswordUpdatedStage`; shared mark | Compact completed C; security notice remains visible. |
| Change password from settings | `profile_settings_flow.dart`, `ChangePasswordScreen`; toast | Keep inline/toast confirmation. Do not add another full-screen result solely for animation. |
| Personal information saved | `PersonalInformationSuccessScreen`; 112 mark | Compact completed C with existing mark size. |
| Basic verification submitted | `verification_overview_screen.dart`; shared success check | **Submitted S**, static clock finale; keep Pending review. |
| Advanced verification submitted | `advanced_verification_flow.dart`; same check | **Submitted S**, same exact recipe as Basic. |
| Advanced face / ID / address / review step changes | same file; 220 ms switch / 180 ms reverse | Step K. Preserve draft/back behavior; photo slots cannot imply actual liveness success. |
| Legacy tier results, full verification, old face scanners | `profile_settings_flow.dart`: `TierCompletionV12Screen`, `FullyVerifiedV12Screen`, `VerificationProcessingV12Screen`, `FaceDetectionScreen`, `FaceDetectionV12Screen` | Not active from new overview. Leave out of rollout; no new budget on retired paths. Retained shared compatibility may change indirectly. |
| Buy crypto processing | `buy_crypto_screens.dart`, `BuyProgressScreen`; raster GIF + 2100 ms mock timer | Working W; replace GIF, remove animation-owned success assumption when state provider is wired. |
| Buy crypto completed | `BuySuccessScreen` → shared result | Completed C, regular. |
| Sell / convert / internal transfer / external withdrawal processing | `crypto_full_flow.dart`, `TransactionProgressScreen`; GIF + 1500 ms mock timer | Working W; actual transaction state selects submitted vs completed. |
| Sell / convert / transfer result | `TransactionSuccessScreen` branches by `TxKind` | Completed C only for confirmed completed state. Broadcast/pending external transfer uses Submitted S and accurate caller copy. |
| Crypto deposit confirmed | `DepositStatusScreen(success: true)` | Completed C. |
| Crypto deposit pending | same widget, alternate status | Pending W/static clock; never animate a success tick for a pending deposit. |
| Naira withdrawal submission | `crypto_full_flow.dart`; `Submitted Successfully` toast | Keep brief local acknowledgment; if a full result is introduced by product flow, use S. |
| Bank account name lookup | same file; finite 900 ms fixture lookup | Inline W, 16 px activity indicator, stable field height; provider outcome owns state. |
| Gift-card purchase completed | `GiftCardBuySuccessScreen`; shared mark | Completed C. |
| Gift-card sale submitted | `GiftCardSellSubmittedScreen`; shared check plus pending text | Submitted S to distinguish acceptance from credited funds. |
| Gift-card verification tracking | `GiftCardVerificationScreen`; 1300 ms reversing scale .96–1.04 | Pending W; keep clock size stable. Animate active status cue, not entire card breathing. |
| Gift review acceptance / card validity / signup agreement | `DavoAnimatedCheckbox`; 220 ms vector circle/check | Keep family; standardize M, accessibility and disabled state. |
| Gift tabs / physical vs E-code / subcategory / quantity | animated selected backgrounds, some immediate switches | M with bounded indicator movement; numeric quantity updates directly. |
| Gift upload slots / file added | local fixture states in `gift_card_flow.dart` | K attachment acknowledgment only after a file/provider confirms; no fake upload percentage. |
| Dashboard first entrance | `dashboard_screen.dart`, `_Entrance` → `Entrance` | D: one bounded 400 ms group sequence; preserve layout and immediate taps. |
| Dashboard balance hiding / changing wallet | AnimatedSwitcher | 160 ms crossfade; privacy mask takes effect immediately, with no outgoing amount left readable. |
| Portfolio assets / chart / allocation | mostly static | Keep numeric values static; optional 300 ms allocation reveal only on initial route entry, no data re-counting. |
| Portfolio Buy / Sell / Swap actions | neutral action buttons | Press feedback only; no selected-tab motion because these navigate. |
| Transaction history / completed receipt status | static records | Keep static. Revisiting a receipt must not replay transaction completion. |
| Address copy / transaction ID / reference copy / referral copy | clipboard + shared top toast | Micro acknowledgment M; preserve trailing copy column and full copied value. |
| Receipt preparation | `DavoReceiptExportFrame` busy flag + disabled buttons | Inline W while real export Future is pending; stop on success/failure; accessible busy label. |
| Receipt / wallet address share sheet | native Flutter modal transition; circular actions | Sheet H, same motion for both; do not animate contents inside receipt capture boundary. |
| Receipt download / X / Telegram / More | platform/file actions | Confirm download only after completion; returning from a chooser is not proof the user posted anything. |
| State / date / asset / network / bank / subcategory selectors | modal bottom sheets | Sheet H; preserve native drag, keyboard/safe-area behavior and focus return. |
| Settings toggles / tabs | `_DavoSwitch` 220 ms, `_SegButton` 200 ms | M; never make a disabled setting appear saved. |
| Limits progress | `_ProgressLimit` 600 ms to static .06 | Keep actual data value; 300 ms initial fill once. Never animate fake financial usage. |
| Notifications empty illustration | `notification_empty_exact.gif` | Inspect actual GIF during implementation; use first-frame static poster by default and for reduced motion. No perpetual empty-state loop. |
| Support / email sent / referral / rewards | toasts and static screens | Toast acknowledgment; a future actually credited redemption may use compact C after confirmed credit, not on mere request. |
| General settings content sheets proposed in Figma | not uniformly implemented | When implemented, reuse H. Motion does not require new pages. |
| Back navigation and ordinary routes | `core/navigation/app_page_route.dart` | Keep platform Material transitions and interactive back. Do not replace every route with branded choreography. |

## Fixed visual and timing contract

All durations below are milliseconds. Coordinates are logical pixels on a 148 × 148 hero canvas, scaled uniformly by `size / 148`. Center is `(74,74)`. Default hero size stays 148; existing 112/150 call sites keep their sizes. Never independently scale X/Y. Fonts and existing small text sizes remain unchanged.

- Primary `#135CF7`; pale blue `#EDF2FD`; white `#FFFFFF`; text uses existing theme ink/body colors.
- No yellow decorative strokes, dark oval, glow, confetti, orbiting coins, spinning checkmarks, elastic text or animated blur.
- Curves: `settle = Cubic(0.22,1,0.36,1)`; `standard = Cubic(0.4,0,0.2,1)`; `exit = Cubic(0.4,0,1,1)`; drawn paths use `Curves.linear`. Clamp every phase to 0…1. One master controller per sequence, no chained timers for drawing.
- Transform vector art only. Text may translate by at most 8 px and fade; never scale or blur it. Final transform values must be exact identity.
- One hero motion at a time. Result actions remain laid out, visible and available immediately; appearance never gates a user's exit.
- Every finite sequence stops repainting on its final frame. Do not replay on `setState`, orientation/layout changes, tab revisit or receipt opening. A new result/event ID permits a new play.
- Default haptics: retain existing feedback, prevent duplication. Do not add haptics to decorative stages; any confirmed-outcome haptic occurs once, never on pending status.

### C — Completed: branded assembly → confirmed seal (1120 ms)

Final image preserves the approved filled blue disc, white inset and blue check. It is not the older hollow outline mark.

| Time | Exact visual stage |
|---|---|
| 0–240 | Assemble the three supplied Davochain mark parts in blue on white. Use the existing splash clipping regions (dot `(0,.58,.29,1)`, upper `(0,0,1,.46)`, lower `(.30,.54,1,1)`); reuse its asset crop. Mark bounding width 58, proportional height `58*201/285`, centered on canvas. Upper offset `(14,-10)` → zero; lower `(-12,10)` → zero; dot opacity 0→1 in 0–120. Settling curve; no overshoot. |
| 240–440 | Fade assembled mark opacity 1→0. Simultaneously grow a centered blue disc radius 20→57 over 240–560, opacity 0→1 over 240–360. This overlap is a transition between drawings, not an unspecified path morph. |
| 420–660 | White inset grows radius 0→24, settle curve. Outer disc remains fixed at radius 57 after 560. |
| 640–880 | Draw check path `(62,74) → (71,83) → (88,66)` by `PathMetric.extractPath`, blue stroke 6.5, round caps/joins, linear length progression. |
| 580–800 | Existing heading and message fade 0→1, translate Y 8→0, settle curve. Keep their final layout space reserved from frame zero. |
| 720–940 | Optional result details fade 0→1, Y 6→0. Entire detail block is one unit, not one stagger per financial row. |
| 940–1120 | Hold exact final frame. No pulse or rebound. Actions were already available. No automatic navigation for ordinary result pages. |

Compact C: same drawing and stage ratios, total **680 ms**, for fingerprint enrollment, PIN reset and saved profile/password. All integer checkpoint times are `round(regularTime * 680 / 1120)`. Do not use compact C for a clipboard copy.

### S — Submitted: document received → waiting seal (900 ms)

Purpose: communicates that details/trade were received, with review still pending. The final symbol is a **clock**, not a checkmark.

| Time | Exact visual stage |
|---|---|
| 0–200 | Outline document appears: rounded rect `(56,42)-(92,86)`, corner radius 4, stroke 2.5 primary, opacity 0→1, Y −10→0. Two internal horizontal lines `(63,57)-(85,57)` and `(63,65)-(80,65)`, stroke 2. |
| 200–420 | Document translates Y 0→10 and fades 1→0; a blue disc grows radius 20→57, opacity 0→1. No paper flying outside the hero bounds. |
| 380–600 | White inset grows radius 0→24. Blue clock ring centered `(74,74)`, radius 13, stroke 2.5 fades in over 520–640. |
| 560–760 | Draw clock hands `(74,65) → (74,74) → (80,78)`, stroke 2.5, round caps, linear progression. |
| 460–680 | Heading/message Y 8→0 and opacity 0→1. Keep the explicit Pending review label. Details fade over 600–800. |
| 800–900 | Static hold. No ticking clock or auto-approval afterward. |

### P — Password unlock: dots → lock → welcome (1000 ms after confirmed authentication)

Before authentication resolves, use neutral Working W if needed; do not start a successful unlock based on a timer. Current local auth fixtures must remain isolated from future real authentication.

- Opaque overlay background matches the originating screen (white for login, primary blue for returning unlock). Preserve matching status/navigation-bar colors; do not flash a near-white layer over the blue page.
- Hero canvas 112×112, center `(56,56)`. On white use blue strokes; on blue use white strokes. Text remains Sora at its existing 20 px title size with no decoration.
- 0–140: overlay fades in. Four **decorative**, evenly spaced dots of radius 3 at X `[35,49,63,77]`, Y 56 fade in. Their number is fixed and reveals nothing about password length.
- 140–340: dots move to `(56,64)` and fade out; rounded lock body rect `(38,50)-(74,78)`, radius 6, appears over 220–360. Stroke 3.
- 300–520: draw shackle from `(45,50)` to `(45,41)`, cubic via `(45,26),(67,26),(67,41)`, to `(67,50)`. Stroke 3, round caps, path reveal; closed lock indicates accepted credentials, not a newly locked account.
- 520–680: lock fades out, check path `(40,56) → (51,67) → (73,45)` draws in with stroke 4. This is a precise crossfade, not a topology morph.
- 580–720: replace “Signing in” with “Welcome back” in a reserved text region using a 140 ms crossfade; do not shift hero Y when dots disappear.
- 720–840: still hold. 840–1000: scene fades out while destination fades in via one controlled route handoff. Do not briefly expose the old form or stack two route fades.
- Navigation callback fires at most once. Cancellation/disposal, backgrounding, invalid input and authentication failure never unlock an account.

### F — Fingerprint unlock: traced ridges → recognition → welcome (960 ms after biometric success)

Use an authored vector fingerprint, not a pulsing Material icon plus progress ring. Canvas 112×112. These cubic subpaths define the ridges, stroke 2.5 with round caps, unfilled:

```text
M28,58 C28,18 84,18 84,58
M35,63 C35,29 77,29 77,60 C77,76 70,86 63,91
M42,68 C42,43 70,41 70,61 C70,75 65,81 58,86
M49,72 C49,51 63,49 63,62 C63,72 58,78 52,82
M56,60 C56,72 50,82 43,88
```

- Background and text treatment match P.
- 0–120: overlay fades in; complete fingerprint appears at 18% foreground opacity as a static guide.
- 120–480: foreground ridges reveal by path length, outer-to-inner, offsets `[0,40,80,120,160]` ms, each lasting 200 ms. Clip strictly to the hero. No line travels under the label.
- 480–640: fingerprint foreground/guide fade out; same P check draws from 500–700. No scaling pulse.
- 620–760: “Welcome back” text crossfade. 760–800: still. 800–960: same single route handoff as P.
- The OS biometric prompt remains OS-controlled. Run this success sequence after its successful result; do not pretend to scan while waiting for the OS. Use an ordinary “Waiting for fingerprint” state before that result and handle cancellation inline.

### W — Working and pending

- Short actual asynchronous operation: static centered brand mark or context icon, with one 72-degree arc radius 34, stroke 2, primary 70% opacity, rotating linearly once per 1200 ms. No percentage unless the service provides one. The rotation does not drive completion.
- Use a 16 px scaled indicator for bank lookup/export buttons. Preserve button/field width and labels; disable duplicate submissions, not Back/Cancel when safe.
- Long pending review: static clock, static milestone list; active dot opacity .45→1→.45 over 1800 ms for **two cycles**, then stop. No fake milestone advancement; a real new status event may play one new two-cycle cue.
- Failure exits working immediately; preserve entered data and offer the actual retry action. Unknown duration never becomes a completed seal on a timer.
- Remove the processing GIF from active Buy/TransactionProgress paths during implementation; it loops independently of reduced-motion state and is less controllable than vector drawing.

### K — Steps and attachments

- Forward in-page step: outgoing opacity 1→0/Y 0→−4 in 100 ms; incoming opacity 0→1/Y 8→0 over the next 180 ms. Total 280 ms. Back mirrors Y signs. Only one field set is focusable/announced at a time.
- Keep height changes in the scroll region. Never overlay two accessible forms or discard draft values. Scroll to the next heading after layout; do not animate the entire viewport from bottom to top.
- Attachment accepted by provider: thumbnail crossfade 180 ms, corner check draws in 160 ms after file acceptance. No thumbnail scale jump. Failed/cancelled selection preserves existing content.

### H — Sheets

- App-owned sheet enters from its actual offscreen bottom position to final position over 280 ms, settle curve; barrier opacity 0→.32 over 160 ms. Exit 200 ms, exit curve; barrier follows the sheet's exit.
- Retain Flutter's modal route/drag system and tune supported transition APIs; do not build a competing overlay controller. Keep safe areas, keyboard resize, back behavior and accessibility focus handling.
- No stagger for Share buttons: Download, X, Telegram and More appear as a complete stable group. Receipt contents themselves remain static for PNG/PDF capture.

### M — Small controls, copy and toast

- Press: 90 ms to scale .985 for solid buttons, 140 ms back to 1; reduced motion uses color only. Never shrink a TextField or large form.
- Checkbox: retain 220 ms total. Fill circle 0–100; draw check 80–200; hold 200–220. Deselect reverse in 160. Keep 44 px minimum target and existing control size.
- Selected segment indicator: translate/resize within existing track over 180 ms standard curve; text crossfade 100. A navigation action is not a selected segment.
- Copy: retain the 32 px reserved trailing column; icon crossfades to small check in 120 ms only after clipboard success, holds 900 ms, returns in 120. Full value alignment never moves. Existing top toast remains sufficient if icon swapping would duplicate feedback excessively; default choose icon + accessible announcement, toast for longer explanatory messages.
- Toast: existing 180 ms fade/Y −8→0 entry, add 140 ms fade exit only when implementing this task; keep 3000 ms dwell and one visible toast. No animated full-screen success for local housekeeping.
- Password strength: preserve shared colors. Animate bar width 160 ms, label crossfade 100, with no height jump. Never increase small text sizes.

### D / E — First entrance and errors

- Dashboard: four groups, starts `[0,40,80,120]`, each opacity 0→1/Y 8→0 over 280 ms; max completion 400 ms. Header, balance, actions/banner, asset section. Play once per genuine page entry; no restart when hiding balance or scrolling assets. Immediate mask replacement takes precedence over motion.
- Error shake only for rejected OTP/PIN: X keyframes `[0,-4,4,-3,3,0]` at `[0,40,80,120,160,220]` ms. One cycle. Inline error text stays and is announced. No screen shake for network failures; use retry text.
- Existing route transitions stay native. Ordinary receipts, amounts, balances, transaction rows, search results and paragraphs remain static after rendering. No price count-up, shimmering logo, parallax form or novelty 3D rotation.

## Accessibility, lifecycle and trust requirements

- Reduced motion = `MediaQuery.disableAnimationsOf(context) || MediaQuery.accessibleNavigationOf(context)`. Completed/submitted results show final art and all copy immediately. Auth success shows static confirmation for 150 ms then hands off with no visual route animation; never add this delay before a real authentication result. Working uses a static icon plus accessible busy label. Sheets appear without slide/scale. No looping GIF remains in reduced-motion active paths.
- A preference change mid-animation must immediately settle, stop tickers and preserve the outcome. Foreground/background pauses ornamental motion; server work is independent. Returning to foreground must not replay a financial confirmation.
- Reserve final dimensions so no label, CTA, status or keyboard jumps during choreography. At 320×640 and 200% text scale content scrolls and actions remain reachable. No hard-coded center positions that overlap long text.
- `Semantics.liveRegion` announces a state transition once, not each frame. Art is excluded from redundant semantics. Busy scenes block accidental duplicate submit, not accessibility navigation.
- State mapping is explicit: `idle → working → completed | submitted | failed | cancelled`. Animation listens to state; its controller cannot set transaction approval, credit funds or authenticate credentials. Existing timers are frontend fixtures, not proof of success.
- Receipt export must capture static, complete content. No missing text because capture happened at opacity zero. Preserve native file/share behavior.
- Profile on physical Redmi 14C in profile mode; target UI and raster p95 frame time below 16.7 ms for 60 Hz. Record actual results, not a performance guarantee. Use repaint boundaries around the small hero; do not rebuild the page for each frame. See [Flutter rendering guidance](https://docs.flutter.dev/perf/rendering-performance) and [reduced-animation behavior](https://api.flutter.dev/flutter/animation/AnimationBehavior.html).

## Deliverables required before accepting implementation

1. A development-only motion gallery with scrubber; never placed in user Settings or production navigation. Scenarios C, compact C, S, P, F, W, K, H and reduced motion.
2. Storyboard images at C `[0,240,440,660,880,1120]`, S `[0,200,420,600,760,900]`, P `[0,140,340,520,680,840,1000]`, F `[0,120,320,480,640,800,960]` ms. Fixed 390×844 logical viewport and white/blue auth variants.
3. Real emulator and Redmi recordings, normal speed, without accelerating or trimming bad frames. Include failure/cancel and reduced-motion examples.
4. Tests for exact final geometry, no yellow decoration, state-driven transitions, immediate result actions, no duplicate callback, disposal/background/reduced-motion changes, narrow/large-text layout and static receipt capture.
5. Explicit status mapping for every row in the audit table. Legacy routes marked excluded. No claims that mock providers are now real because animation looks convincing.

Execution is specified in [the implementation plan](../superpowers/plans/2026-10-08-davochain-motion-system.md). The user has requested planning only; wait for an explicit implementation instruction.
