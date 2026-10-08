# Davochain Motion System Implementation Plan

Execution authorized on 2026-10-08. See [implementation progress and delivery evidence](../../reviews/2026-10-08-motion-implementation-progress.md) for implemented recipes, verification, APK delivery and remaining provider/performance work. Unchecked steps below remain the original acceptance checklist, not a claim that implementation has not started.

> **For agentic workers:** Use `superpowers:executing-plans` to implement this plan task-by-task after the user authorizes implementation. Do not start implementation merely because this plan exists. Do not delegate unless the current user/developer instructions permit it. Steps use checkbox syntax for tracking.

**Goal:** Give Davochain precise, staged brand motion across confirmed outcomes and authentication, while distinguishing pending submissions and preserving readable, responsive UI.

**Architecture:** Use Flutter vector artwork and one controller per scene. Domain/caller state owns outcomes; animation only presents them. Preserve shared result layout, native navigation and the accepted splash, and migrate callers through shared recipes instead of adding independent animations in each feature file.

**Tech Stack:** Existing Flutter/Dart, `CustomPainter`, path metrics, animation controllers, themed Material, current Flutter test tooling. No new runtime dependencies, Lottie/Rive/video files, image-generation or external asset downloads are required.

**Spec:** [Motion direction, audit and exact storyboard](../../reviews/2026-10-08-motion-direction-and-audit.md). Read the entire spec before editing; its C/S/P/F/W/K/H/M/D/E recipe definitions are normative.

## Global constraints

- Current authorization is **audit and plan only**. The yellow underline is not fixed yet. Implementation requires the user's subsequent instruction.
- Preserve the accepted splash assembly, 2900 ms timeline, reduced-motion behavior, current logo, currency artwork, and removal of the oval.
- Keep existing small font sizes. Use Sora, theme colors, crisp vector strokes and exact final transforms.
- Primary `#135CF7`, pale blue `#EDF2FD`; settle `Cubic(0.22,1,0.36,1)`, standard `Cubic(0.4,0,0.2,1)`, exit `Cubic(0.4,0,1,1)`, path reveal linear.
- Hero canvas 148×148, center `(74,74)`; C final disc radius 57, inset radius 24, check `(62,74)→(71,83)→(88,66)`, stroke 6.5 round caps/joins. Existing 112/150 sizes scale uniformly.
- C 1120 ms, compact C 680 ms, S 900 ms, P 1000 ms, F 960 ms. No improvised timings, alternate glyphs, springs, confetti, shadows or extra stages.
- Result actions are visible/enabled immediately according to domain state. Normal result pages never auto-navigate because an animation ended.
- Pending/broadcast/review is not completed/approved. No timer, GIF or animation controller may manufacture success.
- Reduced motion checks both disableAnimations and accessibleNavigation; settle on preference changes and cancel safely on disposal.
- Current workspace contains substantial unrelated changes. Do not reset/stage/commit them wholesale. No automatic commit, deployment or phone installation during plan execution unless requested.
- Existing fixture/provider gaps are out of motion scope. Do not claim native biometric/KYC or real transactions were implemented by these changes.

## Review focus

1. A successful animation surviving a route cancellation must never perform a late auth/navigation callback (Tasks 1/3/4).
2. A delayed/failed service must not become a successful transaction after the expected animation duration (Tasks 3/4/5).
3. Text at 200% scale and keyboard-open small screens must stay readable with reachable actions (Tasks 2/3/5/6).
4. Rebuilding or revisiting a historical transaction must not replay completion or expose previously hidden balance text (Tasks 2/4/6).
5. Exporting a receipt during another UI animation must produce the complete static artifact (Task 6).

## Proposed files and interfaces

Create:

- `lib/shared/motion/davo_motion_spec.dart`: enums, durations, curve constants, frame/phase helpers. No timers or widgets here.
- `lib/shared/motion/davo_motion_policy.dart`: common reduced-motion/lifecycle policy.
- `lib/shared/motion/davo_outcome_artwork.dart`: pure completed/submitted vector/asset composition at an explicit progress value.
- `lib/shared/motion/davo_outcome_sequence.dart`: finite scene controller; one play per event/mount.
- `lib/shared/motion/davo_working_indicator.dart`: real busy/pending status cue, independent of operation completion.
- `lib/shared/motion/davo_auth_artwork.dart`: pure password/fingerprint hero at explicit progress, including ridge paths from spec.
- `tool/motion_gallery.dart`: development-only entry point with deterministic scene scrubber and state controls.

Modify existing files only where the audit table maps them. Do not split entire feature modules as part of motion work.

Interfaces to lock before implementation:

```dart
enum DavoOutcomeKind { completed, submitted }
enum DavoOutcomeTempo { regular, compact }
enum DavoWorkingKind { operation, reviewPending }
enum AuthJourneyState { idle, working, accepted, failed }

// Names below describe proposed APIs, not existing implementations.
abstract final class DavoMotionSpec {
  static Duration outcomeDuration(DavoOutcomeKind kind, DavoOutcomeTempo tempo);
  static double phase(double elapsedMs, double startMs, double endMs, Curve curve);
}
abstract final class DavoMotionPolicy {
  static bool reduce(BuildContext context);
}

DavoOutcomeArtwork({required DavoOutcomeKind kind,
  required double progress, double size = 148});
DavoOutcomeSequence({Object? eventKey,
  required DavoOutcomeKind kind,
  DavoOutcomeTempo tempo = DavoOutcomeTempo.regular,
  required Widget Function(BuildContext, double progress) builder});
DavoWorkingIndicator({required DavoWorkingKind kind,
  required bool active, required String semanticLabel, double size = 72});
DavoAuthArtwork({required AuthJourneyMethod method,
  required double progress, required Color foreground, double size = 112});
```

`phase` returns 0 before start, 1 after end, and the curved clamped local progress between them. Submitted duration is always 900 ms; compact is only applied to completed. Artwork classes are stateless and have no callbacks/controllers. `eventKey == null` means play once for the lifetime of that sequence State; a non-null changed event key resets for a genuine new event. Never create a random event key inside `build`.

Retain `DavoSuccessMark` as a compatibility adapter around completed artwork/sequence. Its existing size and semanticLabel parameters keep working. In a coordinated result scene, use pure artwork directly so it does not create a second controller.

Extend `DavoResultScreen` with `outcomeKind` (default completed), `outcomeTempo` (default regular), and optional `outcomeEventKey`. Keep existing title/message/actions/details/appBar APIs. Preserve optional custom marks for legacy compatibility; only the default mark uses coordinated outcome art. Actions remain outside the scene's opacity transforms.

Update `DavoAuthJourney` to consume `AuthJourneyState` in addition to its method/child/onComplete, with an explicit background/foreground palette appropriate to login vs returning unlock. Working never calls onComplete. Accepted triggers the appropriate P/F recipe and at most one completion callback. Failed returns control to caller error UI. Existing preview authentication is passed through an explicit local fixture decision at the caller; do not label it real credential verification.

## Task 1 — Reproduce and isolate the yellow-line issue

**Files:** `lib/shared/widgets/davo_auth_journey.dart`; `test/auth_motion_test.dart`.

- [ ] Add a failing regression that pumps real `LoginScreen` and returning unlock through their existing wrappers; inspect effective `RichText.text.style` for Signing in, Unlocking and Welcome back at early and late checkpoints. Assert Sora and decoration none. Include reduced motion and the blue returning screen.
- [ ] Run `flutter test test/auth_motion_test.dart`. Confirm failure is the inherited decoration/font rather than a guessed overflow diagnosis. Capture a current frame before changing anything; if no underline reproduces, locate the reported frame before applying an unrelated workaround.
- [ ] After reproduction, wrap the overlay with Material and intentional default text style. Do not disable debug painting, clip overflow or change text size. This is the only bug fix in this task; choreography comes later.
- [ ] Re-run auth tests. Retain invalid-input, double-tap and dispose-before-completion coverage; assert callback count zero after cancellation and exactly one after accepted completion.

**Deliverable:** proven explanation and isolated text-environment fix, ready for review before motion changes.

## Task 2 — Implement completed/submitted storyboards and preview gallery

**Files:** new shared motion spec/policy/outcome files; `lib/shared/widgets/davo_success_mark.dart`; `lib/shared/widgets/davo_result_screen.dart`; `tool/motion_gallery.dart`; `test/success_motion_test.dart`; new `test/outcome_storyboard_test.dart`.

- [ ] Write tests for C final geometry; S final clock with no check; compact duration 680; S duration 900; policy OR logic; no replay on rebuild; replay on changed event key; stopped ticker at final frame; immediate actions; reduced motion from first frame and changed mid-scene; disposal/background safety.
- [ ] Run the new tests and record expected failures before implementing APIs above.
- [ ] Implement pure artwork with the exact C/S path coordinates and per-stage tables in the spec. Reuse original brand asset/crop, with no hand-drawn replacement logo. Implement outcome scene controller and compatibility mark adapter.
- [ ] Coordinate result heading/details with the same progress clock. Honor existing layout, all semantics and stable dimensions. For reduced motion show final artwork and full text immediately.
- [ ] Implement gallery using explicit progress values, scenario selector, white/blue backdrop, and 0–duration scrubber. No gallery import in `main.dart`, `app.dart` or user settings. Run with `flutter run -t tool/motion_gallery.dart` only.
- [ ] Export C/S checkpoint images at exact times listed in the spec. Store review evidence under `docs/reviews/motion-reference/` with recipe/time/device-scale in each filename. Do not approve a golden by merely regenerating it after a failed test; inspect against the tables.
- [ ] Run `flutter test test/success_motion_test.dart test/outcome_storyboard_test.dart test/trade_layout_regression_test.dart`. Test 320×640 and 200% text scale. No clipped/hidden result actions or duplicated semantic status.

**Deliverable:** exact finite C/S sequences and a reviewable motion gallery, before broad caller migration.

## Task 3 — Separate password and fingerprint success scenes

**Files:** new auth artwork file; `davo_auth_journey.dart`; `features/auth/presentation/login_flow.dart`; `returning_unlock_screen.dart`; `test/auth_motion_test.dart`; gallery.

- [ ] Add tests for each AuthJourneyState: working remains working beyond 5 seconds, failed/cancelled never route, accepted P completes once at 1000 ms, accepted F once at 960 ms; reduced accepted at 150 ms with no visual transition. Preserve invalid-email behavior. Fixture validation is clearly distinct from actual provider validation.
- [ ] Implement P lock/dot paths and F ridge paths exactly. Keep label baseline/hero position stable before and after decorative elements disappear. Capture both text states at their checkpoints.
- [ ] Own Material text/theme and system-bar colors through handoff. Dismiss keyboard before centering scene; use safe available bounds. Keep originating white/blue palette and prevent a white flash on returning unlock.
- [ ] Ensure a single destination transition: scene fades out over P 840–1000 / F 800–960, destination fades in under it. Do not expose old credentials form during the handoff. Native OS biometric prompts remain native; success art starts only after acceptance from the caller.
- [ ] Add white/blue P/F gallery cases and capture prescribed frames. Inspect all five fingerprint ridges and the two-segment check; reject a pulsing stock fingerprint icon substituted for the specified drawing.
- [ ] Run `flutter test test/auth_motion_test.dart test/returning_auth_preview_test.dart test/login_preview_test.dart`. Exercise back, minimize/resume, rapid repeated submit, mid-animation reduce-motion toggle and keyboard-open narrow layout.

**Deliverable:** distinct, exact authentication motion with no yellow underlines or false-success timer.

## Task 4 — Map all result callers to the correct outcome

**Files:** `features/auth/presentation/verification_flow.dart`, `fingerprint_setup_screen.dart`, `login_flow.dart`; `features/profile_settings/presentation/profile_settings_flow.dart`; both active verification files; `features/buy_crypto/presentation/buy_crypto_screens.dart`; `features/crypto/presentation/crypto_full_flow.dart`; `features/gift_cards/presentation/gift_card_flow.dart`; result tests.

- [ ] Create a table-driven `test/outcome_mapping_test.dart` covering every active C/S row in the audit: email/SMS; enrollment; PIN/password/profile updates; Basic/Advanced submitted; Buy/Sell/Convert/internal transfer/confirmed external transfer; pending external transfer; confirmed/pending deposit; gift purchase/submitted sale.
- [ ] Set kind/tempo explicitly at each caller. For standalone layouts use the shared sequence/artwork; do not copy painter code into features. Pending KYC/gift sale must end on S clock and retain Pending wording. Confirmed states use C check. Existing local fixture results remain clearly separated from eventual production provider state in code/tests.
- [ ] Supply stable event identity when records provide it. Otherwise null/mount identity is acceptable for a new result route; no timestamp keys from build. Keep historical receipts static and avoid replay on return from details.
- [ ] Leave unreachable legacy tier flows outside rollout. Keep compatibility adapter behavior so retained old tests still compile; do not reintroduce those routes from the new overview.
- [ ] Run outcome, success, gift review, advanced verification, basic verification, buy review and receipt-layout tests. Verify buttons remain usable at time zero and status is not inferred from a completed animation.

**Deliverable:** complete active outcome coverage and a checked mapping matrix appended to the review evidence.

## Task 5 — Replace uncontrolled processing motion and improve step feedback

**Files:** working indicator; active Buy/TransactionProgress, bank lookup, gift verification, active Advanced flow; gallery; `test/working_motion_test.dart`; existing relevant flow tests.

- [ ] Add tests for indeterminate operation state beyond its visual cycle, actual failure, actual accepted/completed signal, cancellation and reduced motion. Pending cue stops after two 1800 ms cycles and never changes milestones itself.
- [ ] Implement W and replace the active processing GIFs. Keep local demo timing in an isolated fixture adapter if required by the current frontend; the production-facing indicator/controller consumes state and never invents it. No backend build-out in this task.
- [ ] Replace whole-orb pulsing in gift review with the bounded active-dot cue. Apply K step transitions to active Advanced KYC, preserving draft, focus and Back. Attachment acknowledgment starts only after the existing selection/provider contract reports an accepted file, not at button press.
- [ ] Stop decorative animation while hidden/backgrounded; resume only if still working. Do not replay a completion on resume. Keep pending descriptions static and legible.
- [ ] Run `flutter test test/working_motion_test.dart test/advanced_verification_flow_test.dart test/withdraw_refinement_test.dart test/gift_review_layout_test.dart`. Test long labels, 320 px width and 200% text scale.

**Deliverable:** processing/pending visuals that communicate actual state and respect accessibility.

## Task 6 — Apply restrained motion to sheets and everyday feedback

**Files:** existing shared checkbox/auth fields/toast/copy rows/receipt export/state/date picker widgets; dashboard entrance and active selector call sites identified in source index. Add helpers only where reused; preserve platform modal controllers.

- [ ] Verify existing behavior before changing it. Keep controls already matching M; avoid rewriting them for stylistic uniformity alone.
- [ ] Add meaningful tests for copy value/column stability, export-busy cancellation and complete receipt capture, balance privacy mask with no outgoing readable amount, one dashboard entrance per route, and sheet focus restoration with keyboard/safe areas.
- [ ] Apply H and M exact timings. Add receipt preparation activity outside the capture boundary. Do not animate receipt data or require animation settlement to obtain a complete PNG/PDF.
- [ ] Apply D grouping, E error cue and bounded strength/segment transitions. Keep financial amounts, balances, historical status badges and routine lists static. Inspect the notification GIF and choose a static poster for empty states/reduced motion.
- [ ] Run `flutter test test/dashboard_motion_test.dart test/animated_checkbox_test.dart test/receipt_export_test.dart test/receipt_alignment_test.dart test/amount_toast_keyboard_test.dart test/nigeria_dropdown_test.dart test/pin_and_date_test.dart` plus the newly added behavior tests.

**Deliverable:** consistent small feedback without overwhelming the main outcome scenes.

## Task 7 — Final visual, lifecycle and physical-device verification

- [ ] Run `flutter analyze` and `flutter test`; report exact results and remaining failures. Do not count only the new tests as whole-app coverage.
- [ ] Record splash (must match accepted behavior), C/compact C/S/P/F/W, sheet opening/closing, failed auth, cancelled operation and reduced motion on emulator and connected Redmi 14C. Use UI-tree-driven interactions. If phone unavailable, mark device verification pending rather than substituting emulator performance.
- [ ] Profile on the real phone in profile mode. Record warm and cold runs separately, frame UI/raster p95 and missed frames. Target 16.7 ms on a 60 Hz device; investigate full-page rebuilds/GIF decoding/oversized layers if missed. No performance promise based on a debug emulator recording.
- [ ] Compare fixed-time storyboard images against the spec, including exact final radii, stroke widths, S clock, F ridges, unchanged font sizes, absence of yellow line/oval/glow, and static receipt capture. Keep normal-speed clips as evidence.
- [ ] Inspect route replacement and system bars for a single clean auth handoff, working scenes after background/resume, screen-reader announcements, large text and action reachability.
- [ ] Update audit mapping with implemented/retained/excluded/provider-blocked status per journey. Request user review of concrete recordings, not an abstract promise of a polished animation.
- [ ] Build/install only when the user requests that delivery. Preserve signing/configuration and unrelated edits; do not claim production auth/KYC has become real.

## Exact handoff prompt for another model

> Read `docs/reviews/2026-10-08-motion-direction-and-audit.md`, its source index, and `docs/superpowers/plans/2026-10-08-davochain-motion-system.md`. Implement the plan in order. The C/S/P/F timelines, paths, palette and acceptance checkpoints are fixed; do not reinterpret them as generic fade/scale/bounce animations. Preserve the accepted splash and all small text sizes. First reproduce the yellow text-decoration issue. Create deterministic gallery frames before migrating callers. Pending is never success; provider/fixture state owns outcomes. Preserve existing dirty work, do not commit or install without authorization, and report each completed task with its tests and frame evidence. If current source differs materially from the audited source, explain the discrepancy before changing the visual contract.

No application implementation was performed while preparing this plan.
