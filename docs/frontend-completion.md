# Frontend completion — 0.16.0+39

Scope: the five approved implementation areas, with physical-phone/manual testing deferred. This extends build 38; it does not deliver a backend service or certify production readiness.

## Exact financial arithmetic

`core/money/exact_decimal.dart` uses a BigInt coefficient and decimal scale for addition, subtraction, multiplication, comparison, division and explicit rounding. Amount entry stays decimal text through live buy/sell/convert/withdrawal routes and receipt construction. Gift denomination × quantity × rate preserves kobos. Conversion and percentage selection respect atomic precision; withdrawals include fees in eligibility. Buy amounts resolve down to supported atomic units, so an amount below one unit cannot proceed. Funding records and receipts accept canonical decimal quantities.

Numerical compatibility getters remain for existing callers and presentation/chart adapters. They must never become authoritative request payloads. Normalize legacy numeric ingress once; new integrations must pass canonical strings/atomic units. No binary floating-point financial arithmetic remains in the migrated feature paths. Approximate prices and local operation fixtures still require replacement by authoritative backend quotes.

## Accessibility and motion

Auth fields expose labels and live feedback. PIN keys expose semantic tap actions without announcing their values as plain text. Shared back/close targets are 48 pixels. Primary/secondary auth buttons, links and profile form fields grow with text; date selection is a named, keyboard-focusable button. Navigation exposes selected state and actions. Dashboard, portfolio and deposit content handle enlarged text; trade quantity displays retain precision. Buy/gift/profile transitions observe the shared reduced-motion policy. Existing hidden-tab ticker suspension, camera work draining and refresh motion remain intact.

Automated checks verify semantics, input actions, layout, text scaling, reduced motion and lifecycle. Actual TalkBack traversal and physical camera/biometric behavior are still manual acceptance items.

## Code organization

Buy amount state and gift amount/delivery state have focused controllers with disposal and account invalidation. Gift amount and delivery components are extracted. Dashboard panels, portfolio panels and deposit screens are separate library parts. Profile notifications, PIN, verification and support/rewards are separated; crypto bank withdrawal, trade and transaction outcome screens are separated. Public screen imports remain stable.

Removed the closed, unreachable legacy KYC chain (including its Errandy copy), the unused transfer review screen and orphaned helpers after reference checks. Active account information and verification routes remain available. Library parts intentionally preserve private helper access; this is a focused refactor rather than a replacement navigation/state framework.

Gift catalogue, buy, sell and shared components are separate parts, and profile shared controls/components are extracted from the settings screen root.

## Additional requested changes

The dashboard bell uses a red unread badge: 1–9, then `9+`, hidden at zero. The button announces the exact count, retains a 48-pixel target, and updates from the same stable-ID inbox as notification details. Immutable publication snapshots can include an aggregate count beyond a loaded page; stale responses cannot undo reads or cross account resets. See `notification-unread-badge.md`.

Keyboard investigation reproduced input connection interruptions from the global pointer-down unfocus listener. Background dismissal now waits for a completed background tap, allowing field switching and visibility controls to retain focus and typing. The gesture is excluded from accessibility semantics. Six focused keyboard/background checks passed. Initial native slide-in speed is not established by these widget tests; see `keyboard-focus-investigation.md`.

Independent source review caught and corrected a busy flag blocking Naira submission after PIN, dust trades producing zero destination/fiat units, and malformed funding ingress throwing. Regression coverage includes the full withdrawal journey and post-PIN fee coverage; zero proceeds cannot advance, and invalid funding data stays out of activity.

## Visual direction

Retained Davochain blue/Sora, branded refresh and green face guidance. Native action glyphs replace soft raster dashboard/navigation icons; brand/asset artwork stays intact. Balance and portfolio cards have clearer hierarchy, scalable content and coherent shared balances. Back controls use sharp native glyphs. Catalogue spacing, segmented controls and readable brand tiles retain the existing identity.

Reviewed all 46 supplied research images; the assessment is in the project-level `review/researchimage-analysis.md`. Useful patterns reinforce clear balances, grouped receipt facts and quiet status screens. No unrelated brand world or feature was copied.

## Performance evidence

Immutable portfolio snapshots cache each period's filtered/sorted points. Chart geometry caches its last size projection using weak snapshot keys; pointer inspection reuses it. Unchanged chart painters skip repaint, while changed selection/data/colors invalidate correctly. These remove identified repeated CPU/allocation work without disabling interaction.

Host-only benchmark, 1,000 history points × 1,000 reads, median of five samples:

| Range | Previous projection algorithm | Cached lookup |
| --- | ---: | ---: |
| 1D | 28,171 µs | 192 µs |
| All | 264,255 µs | 189 µs |

The benchmark checks equivalent results and is reproducible with `flutter test test/dashboard_projection_benchmark_test.dart`. These figures measure a Dart test process on the development computer. They are not startup, phone FPS, battery or camera memory measurements. Phone profiling remains deferred. Existing receipt export memory bounds/image disposal and camera lifetime draining remain in place.

## Remaining external acceptance

Authenticated backend adapters, secret storage, authoritative limits/quotes/fees, durable idempotency, realtime transaction reconciliation, uploads, notifications and fulfillment remain backend integration work. Managed release identity/signing, store configuration, platform parity and real-device acceptance remain release gates. See `backend-engineer-handoff.md` for contracts and `upgrade-implementation.md` for the earlier security/lifetime changes.

## Verified build

The complete automated suite passed 492 tests, with 11 optional capture tests skipped. Explicit capture verification produced 15 checked screens. After the final badge contrast and portfolio visibility/control changes, all 27 targeted checks passed. The final analyzer reported no issues, and the debug APK build succeeded.

Unread badge text meets 4.5:1 contrast on its red background. Portfolio visibility and performance controls have named 48-pixel targets; hiding the balance displays the currency and masked dots.

APK: version 0.16.0, build 39; 233,350,360 bytes; SHA-256 `C3829EB7EB778C20B40DF3D8627FC811B9D2412644CE16030A616671C6A59808`. Final verification logs and 15 captures are retained at project-level `review/evidence/frontend-completion-39/`. This build has not been installed or tested on the physical phone. Local integration and remaining work are recorded in `review/implementation-progress.md`.
