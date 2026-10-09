# Splash brand refinement

The Davochain splash retains the Davopay family treatment: blue background, white brand lockup, and outlined dollar, naira, and bitcoin artwork. The final lockup is 6% smaller, keeping its existing raised position.

The stretched 390 × 844 background image is replaced by the original vector currency artwork from the supplied Figma file `z5bMfbhPLQQyZUK8lHU5jo`: dollar `3418:72065`, naira `3418:72073`, bitcoin `3418:72097`. The SVGs are bundled under `assets/images/brand/splash_*.svg`. Their placement and bottom crop follow the original 390 × 844 source frame; proportions scale with viewport width so tall phones do not stretch the symbols.

As requested, animation timings remain unchanged: 2900 ms introduction, 320 ms exit fade, 700 ms reduced-motion hold. Reveal phases, lifecycle handling, and startup readiness handling are preserved.

Validation: all 19 splash, onboarding, and returning-authentication tests passed. Opt-in captures at 320 × 640, 390 × 844, and 414 × 896 passed and were generated under `tmp/splash-refinement-review`. These use the bundled Sora font and render the artwork at 3× resolution. The analyzer reported no issues.

Release 0.13.0+25 built and installed on the Redmi 14C and emulator. Both devices report version code 25 and launched successfully. All 756 declared asset/font/license files match the APK, including the three currency SVGs; all three Android ABIs are included. Both installed APK hashes match the build: `b242405741deb628fa92badb835976ff7a32b09b8e0f3d87742df4c37fe35ca1`.
