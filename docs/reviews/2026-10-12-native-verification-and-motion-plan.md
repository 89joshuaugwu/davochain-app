# Native verification and restrained motion

The user authorized analysis and implementation of real device interactions while the backend is still being prepared. Preserve the revised Figma verification flow, covered selfie reference, yellow notices, safe areas, existing brand motion, and the agreed startup timings.

## Device interactions

- Open the system file picker for JPG/PNG/PDF documents and the camera for ID photos. Validate non-empty content, actual file signature, and the 5 MB limit; show selected filename/size, replace/remove actions, and a real image/PDF preview. Keep temporary attachments in app-private storage and clean them on cancellation/replacement/session reset.
- Open the front camera for guided face capture. Explain the camera use before entry; honor permission denial, unsupported cameras, lifecycle changes, and cancellation. Use optional spoken instructions with a mute control, an animated five-second front-facing countdown, then short right/left/nod prompts. Capture the initial front-facing photo automatically and retain that photo for review rather than the final head-turn frame.
- Use on-device face/pose detection to gate the guided countdown. This supports frontend/device testing; it is not a production anti-spoofing or identity-approval service. Server/provider verification remains the authority when integrated.
- Enable real OS biometric prompting for enrollment confirmation and returning unlock. Keep password/PIN fallback and the existing security-question challenge. Do not store fingerprint data or treat a local device unlock as backend authentication.

## Motion

- Keep scroll positions clamped. Add a very small bounded edge response inside a clipped viewport, with a quick spring return and no exposed blank region. Apply it to vertical scroll surfaces; do not disturb horizontal selectors or text entry.
- On Home, pull-to-refresh shows a floating white circle with blue motion above content. Do not insert header padding or shift the dashboard. A refresh completes from its Future, prevents concurrent refreshes, and honors reduced motion.
- Keep the established Davochain working indicator for identity matching. The supplied Figma processing node refers to a third-party card-loader image; compare its role against the existing brand animation, preserving a consistent identity-checking message and operation-driven completion.

## Validation and handoff

Test document validation/cancellation, guidance pose/timing logic, native permission failures, stale results after reset, attachment cleanup, biometric success/failure/cancellation, scroll boundaries, refresh concurrency, keyboard/safe-area behavior, and reduced motion. Run camera/file/biometric entry on the emulator; actual guided head movement also requires a real front camera and person.

Complete the settings/verification visual confirmation, regenerate the release APK, audit bundled assets, and install on the active emulator. Provide a React Native splash ZIP containing original assets, exact motion contract, reference source, and video. List other backend-independent tests: sharing/downloading receipts, theme persistence, file previews, forms/validation, native biometric prompts, permissions, lifecycle, navigation and accessibility.

Sources: camera and local_auth maintained Flutter package documentation; Google ML Kit face-detection documentation; file_picker and flutter_tts package documentation. These establish platform/setup/lifecycle behavior; they do not claim that local head movement is production liveness verification.
