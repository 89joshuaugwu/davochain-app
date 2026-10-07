# Davochain mobile experience

User-authorized implementation; main workspace is `davochain-app`.

## Direction

Keep the current split-D identity, cobalt/sky-blue palette, supplied illustrations,
approved fixed dashboard header and independently scrolling assets. Make the welcome
flow the expressive focal moment. Financial interactions should feel quick and calm.
All data and verification remain a frontend preview; no real authentication or payment
claims. Figma connector requires reauthentication, so this pass uses the existing
implementation, supplied screenshots and local artwork rather than claiming a live
Figma comparison.

## This implementation

1. Replace velocity-only onboarding with a real PageView. Keep three supplied images
   and existing titles. Include reachable Next/Create Account/Login actions, accessible
   page selectors, Skip, and Android Back to the previous page. Compact/large-text
   layouts must scroll content without hiding the bottom actions.
2. A finite splash reveal, short and interruptible on disposal; reduced motion skips
   decorative movement. No permanent ambient animation or ticker during onboarding.
3. Shared auth buttons gain restrained press feedback, single activation haptics,
   accessible disabled/loading states. Use platform page transitions and back gestures.
4. Bundle the already-requested Sora font and its OFL license, avoiding network font
   dependencies. Check actual text layout after changing font metrics.
5. Make login's preview boundary explicit and provide a direct demo entry from
   onboarding. No credentials are required to preview; existing form flow stays usable.
6. Respect reduced motion in dashboard entrance and keep existing scrolling contracts.

## Verification

Widget coverage: slow swipes, page navigation/back, routing, 320x568 and 2x text,
reduced motion settling, splash disposal, button disabled/loading/repeated input.
Run flutter analyze, full flutter test, Android build, emulator screenshots and
navigation walkthrough. Inspect scoped runtime errors. Record outcomes and remaining
work in DEVELOPMENT_CONTEXT.md. Do not claim profile-mode performance from debug QA.

## Later passes

Complete flow-by-flow Figma comparison when connection is available. Audit trade,
gift-card, KYC, referral, notifications and settings state handling; replace remaining
decorative actions with mock behavior or explicit unavailable states. Validate all
transaction cancellation and success routes, image sharing, accessibility and
profile-mode frame performance. Real auth, authorization and transaction security
remain backend integration work.
