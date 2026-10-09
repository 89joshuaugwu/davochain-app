# Settings fidelity and supplied assets ? 9 October 2026

## Delivered scope

Appearance now follows the supplied three-tile layout: Light, Dark and System have distinct surfaces, blue selection checks and the supplied phone artwork. The exact blue-wave background supplied in the follow-up is copied unchanged as `assets/images/appearance/phone_preview_background.png`, from Downloads `d8aa797bc001c50fc9da7f4504c68a2a54411fc0.png`. It remains stationary behind all modes. System displays the updated dual-phone image. The paired phones are enlarged and bottom-aligned to match the reference composition. The follow-up removes their vertical padding and aligns image content itself to the bottom, eliminating the floating gap. Existing small Sora text sizes are retained.

Selection changes the local draft. Next saves through AppearanceController; Back cancels. While saving, the button reads Saving?, mode selection and Back are disabled, and failed persistence leaves the draft available for retry.

The preview transition lasts 480 ms with easeOutCubic, crossfades weighted layers and moves incoming artwork by at most 8 logical pixels. A restrained, clipped light sweep accompanies the transition. Rapid selections continue from the current visible weights, without flashing an empty background. Reduced motion uses immediate replacement. Backgrounding settles the controller and leaves no active ticker. Images are precached and decode widths are bounded to 1200 pixels.

Crypto Security, Privacy and Notifications restore the supplied icons, compact typography, grouped surfaces and blue controls. Visual switch size is compact while the interactive target remains 48 pixels. Existing off preferences are preserved. Data & Permissions and Block Users have explicit preview detail sheets.

Email Support restores Email Us, the Rapid Response banner, filled fields and optional Order ID badge. The first field uses the unambiguous Subject label. Requests retain validation, pending references, retry and saved-request revisit. Submit request describes the preview action accurately. The supplied 24-hour response text remains design copy; the preview itself sends no email.

Messages restores the compose/close controls and a single-line Ask a question action. Callie uses branded agent headers, compact bubbles and a bottom-pinned composer that remains outside conversation scrolling. Text requests are saved locally. Attachment, GIF and microphone actions explain the missing provider capability; they do not pretend to upload or record.

Support entries now have an explicit email/chat channel and stable conversation ID. An editable email subject cannot reclassify an entry as chat. The inbox groups chat entries into conversations, and reopening restores every accepted message in order. Email requests show only email entries.

## Asset audit

The supplied package audit covers 327 entries including archive members: 53 PNGs, 251 SVGs, 18 ZIPs, four GIFs and one manifest. All raster images decode, and ZIP checksums pass. Five SVG exports are empty: Privacy Indicator/None in three sets, Vector 314 and zondicons_exclamation-solid. Their unused runtime aliases were moved to `docs/reviews/asset-export-placeholders`; original supplied exports remain untouched. No active icon depends on these files.

Twenty exact settings SVG aliases were added to the existing declared icon folder. The three new phone images and the follow-up background are declared through the Appearance asset directory. The older lower-resolution duo image is superseded by the supplied updated preview rather than introducing a second runtime copy for the same role. Existing crypto/currency artwork and accepted splash assets retain their roles.

The machine-readable audit is `../tmp/supplied-asset-audit-2026-10-09.json`. Static light/dark screen and transition captures are in `../tmp/settings-fidelity-review/`. Real Sora and MaterialIcons are loaded in the opt-in capture harness.

## Verification

- `flutter analyze`: no issues.
- Full regression suite: 224 tests passed, four optional capture tests skipped.
- After the bottom-anchor follow-up: nine Appearance/profile regression tests plus the opt-in capture test passed (ten total).
- Capture harness produced 21 light/dark and motion frames with the exact background. The updated System screenshot confirms the phone pair meets the bottom edge.
- Supplied image and archive audit passed except the five documented empty exports; all 747 declared runtime assets/fonts parse or decode without errors.
- Read-only review found no material issues after channel/conversation corrections.
- Release `0.13.0+20` built successfully: 74,961,165 bytes, ARM64/ARMv7/x86_64 libraries, no debuggable flag. All 747 declared asset/font files match the source bytes in the APK.
- Installed successfully on `emulator-5554` without removing app data. Pulled installed APK SHA-256 matches the built file: `94993b658939a2b57b598df79b65362d9498028e3161bf3cdf0b6ae34d3e60d0`.
- Cold launch succeeded. Logcat contains no fatal exceptions, Flutter errors, missing-asset messages or RenderFlex overflow reports during login, settings navigation and all three appearance selections.
- Installed walkthrough exercised the preview login, Settings ? Appearance, and Light/Dark/System selection. The emulator is left on the System preview. Actual device screenshots confirm the blue background, bottom-anchored System phones and visible labels/icons: `../tmp/emulator-release-20-appearance-system.png`, `...-dark.png`, `...-light.png`. These installed captures are authoritative for rendered selector details; a few opt-in offscreen captures omit retained paint details after screen changes.

## Integration boundaries

Local support requests and preference fixtures are frontend preview state. Authenticated delivery, live agent/AI responses, media storage/recording and server-backed preference enforcement remain backend/provider integrations. This refinement does not claim those integrations are complete.
