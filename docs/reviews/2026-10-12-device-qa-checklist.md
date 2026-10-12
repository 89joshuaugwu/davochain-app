# Device testing before the backend

These interactions can be tested with real device APIs while account/provider responses remain fixtures.

| Area | What to test now | Evidence / remaining work |
| --- | --- | --- |
| Basic BVN/NIN | Requirements, 11-digit check, loading, completion, failure/retry, back/reset | Automated flow coverage; emulator completed BVN without pending |
| Personal information | Only username editable, validation/save, fixed DOB/name, verified detail badges | Automated test and emulator inspection passed |
| Documents | System picker, JPG/PNG/PDF, actual filename/size, preview, replace/remove, cancellation, invalid/oversized files | Emulator selected a PNG and replaced it with a PDF; Android renderer completed; file-kind tests passed |
| Camera | Permission prompt, denial/retry, live feed, cancel, background/resume, photo review/retake | Emulator permission prompt, live feed and cancellation verified; real human capture still needs phone testing |
| Guided selfie | Centered frontal pose holds five seconds, initial photo retained, right/left/nod gates, spoken prompts/mute | Pose/countdown logic tests passed; emulator had no human face and correctly remained at five seconds; full capture and audible voice need physical testing |
| Biometrics | OS confirmation, success, cancellation, unavailability, password/PIN fallback, security-question challenge afterwards | Failure/success boundaries tested with injected gateway; native unenrolled emulator showed fallback and did not enable biometrics; enrolled-device success still needs testing |
| Motion | Clamped edges, no blank overscroll gap, floating refresh, concurrent pull prevention, reduced motion | Automated refresh tests passed; emulator screenshot shows floating blue/white indicator over stationary Home content |
| Files/receipts | Native PNG/PDF download, share sheet, correct asset/transaction identity | Available without backend; previous receipt release verified emulator exports |
| General settings | One modal pattern, scrolling, empty/loading/dynamic content, dismissal | Automated overlay test passed; final policy/content payloads still need backend/content owner |
| Adaptation | Dark theme, keyboard, safe areas, large text, short screens, route cancellation | Light/dark captures and targeted flow tests passed; boss's physical phone should confirm system insets |

Test fixtures are sufficient for navigation and loading-state work. They cannot establish production BVN/NIN approval, identity matching, anti-spoofing, delivered email OTPs, account authentication, live balances or actual transfers. Those require their real services.

Native camera captures and document originals remain local to the device; no upload server is connected. Permission prompts are requested only when entering the corresponding feature. The system document picker does not require broad storage access. Android is validated here; iOS requires a Mac/device build and permission checks.

Evidence files are under the workspace `tmp` directory: native-full-tests.txt, native-guard-regressions.txt, native-last-visual-tests.txt, native-last-analyze.txt, native-live-camera-granted-27.png, native-floating-refresh-27.png and updated-verification-review/. Release/installation evidence is recorded after the final artifact audit.

The final visual round exported the complete small Figma icon vectors directly with SVG_STRING. This preserves compound paths and transparency, avoiding colored raster backgrounds in dark mode. No source Figma nodes were modified. The opt-in final capture passed after this correction.

Build 28 adds actual QR scanning, hardware torch/tap-to-focus, animated manual address review, network revalidation, leading-zero phone normalization, red/amber/green password strength, dashboard edge feedback and Settings PIN visibility/matching controls. The Basic introduction now precedes the personal-detail forms. Final decoder/lifecycle/phone/PIN evidence is recorded in delivery-targeted-tests.txt and final-camera-fix-tests.txt. Final APK and emulator evidence will be appended after build/audit.

Final build29 audit:125862902bytes;790declaredfilesmatch;arm64-v8a/armeabi-v7a/x86_64;SHA256e14bdff10892ee985243b33ad1b388f64688a0653e78760e00faf9bb1792ea06. Emulatorbuild28 live scannerfeed/manualvalidBTCreturn/disabledunavailabletorch/front-backIDsheet verified. QRpostertargetdidnotappearinthevirtualscene,sorealQRdecodeandphysicaltorchremainphysicaltests. Build29phoneinstallpendingUSBreconnect;build28phoneinstallandlaunchconfirmed.

Build29 installed on Redmi CI49FIXKM7BUOVA6 after reconnect: adb install -r Success, versionCode29/versionName0.13.0 confirmed, MainActivity launch succeeded. Emulator build29 also installed/launched. Physical face direction/countdown and QR/torch retest now available on the phone.

Build30 adds a centered face-proportioned oval guide (width/height0.74), clipped outside-only Gaussian blur and dimming, white/blue alignment stroke and clearer move-closer/back feedback. The interior remains unfiltered. Geometry/clipping and capture regression tests passed8checks; visualartifact tmp/face-oval-overlay-review.png inspected. Device photo remains the original camera capture, not the blurred display.
