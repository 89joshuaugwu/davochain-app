# Davochain preview polish implementation plan

**Goal:** Make the existing mobile preview feel consistent, responsive and personal while preserving native camera validation and backend boundaries.

**Design:** Keep bottom navigation on Home, Trade, Gift Cards and Settings roots only. Use consistent thin outline settings icons and a soft fade at the dashboard asset viewport. Notifications filter by category, have separated tappable rows and a Rewards empty state. Registration starts a local profile without an avatar; login starts a sample existing profile. Basic verification updates the local identity, and profile photos use the native image picker. Verification badges distinguish gray unverified, blue inner/gray outer Basic and blue fully verified.

**Media:** ID uploads accept images only through the native gallery, preserve front/back camera selection and image validation, and use larger thumbnails with adjacent replace/remove controls. Address evidence retains image/PDF support. Face capture uses a tapered face-shaped opening, external blur, progress ticks replacing the countdown number, and a short scan reveal of the first captured frontal photo. Guidance and capture remain driven by actual detected poses; reduced motion skips decorative animation.

**Transactions:** Newly submitted local preview transactions stay pending for 20 seconds, then complete by identity in shared receipt activity. History, result screens and open receipts update consistently. Timers cannot complete another session's records, failed or non-preview transactions. Historical sample records remain unchanged. Naira withdrawal receives a clear header/back control and visible balance currency label.

## Tasks
- [ ] Root: shared main-page navigation, dashboard viewport fade and local-profile dashboard binding.
- [ ] Profile: session identity, auth registration/login binding, Basic identity application, photo editing, badge states, consistent settings icons and interactive notifications.
- [ ] Media: native image-only ID picker, upload thumbnail layout, face-shaped progress and capture/review scan motion.
- [ ] Transactions: shared 20-second preview lifecycle, responsive receipts/history/results, withdrawal corrections.
- [ ] Integration: analyzer, targeted/full tests, layout captures and emulator checks; fix regressions and record limitations.

**Execution:** User explicitly auto-approved planning and implementation. Independent file ownership is delegated under the parallel-agents skill; Flutter commands remain serialized by the root agent. Preserve the shared working tree without committing unrelated changes.

**Review focus:** Session reset during a pending transaction; registration versus login fixtures; failed/cancelled image selection; large text/small viewport; lost face detection and reduced motion.
