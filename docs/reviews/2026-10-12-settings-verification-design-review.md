# Settings and verification implementation, 12 October 2026

Figma access recovered through the Primary connection. The Company connection still required reauthentication. Layouts and source assets were read from child nodes in file z5bMfbhPLQQyZUK8lHU5jo, section 7829:84583. The supplied screenshots and final user directions resolve behavior differences in the design.

## Implemented behavior

- Compact Basic/Advanced overview. One Basic Verification introduction explains that either BVN or NIN is accepted, followed by profile name/DOB, phone/address, identity-method selection and direct number entry. Both methods share an identity icon; the green circular check indicates complete eleven-digit format.
- Basic submission waits for its verification operation, then displays verified completion. Failure permits retry; cancellation/disposal/session reset prevent stale approvals. No pending Basic state remains.
- Advanced follows ID selection and front upload (back optional), selfie introduction, real guided capture, review/matching, identity completion, address selection/upload/review/edit, address verification and final completion. Downstream steps remain gated.
- Original covered-face reference, supplied requirement icons, medal artwork, document preview assets and yellow explanatory notices. Safe areas, short-height scrolling, keyboard access, dark themes and reduced motion are retained.
- Personal Information allows editing only Username (3-24 letters, digits or underscores). Email, phone, country and address have verified indicators; full name and date of birth remain fixed. Only username saves changes.
- Privacy, FAQs, Terms and About share one scrollable settings overlay. Content can be supplied dynamically; missing content has an empty state instead of invented legal text.

## Native interactions and motion

System document selection and camera capture replace upload fixtures in the application. JPG/PNG/PDF content is validated, bounded to 5 MiB and cached privately. Images show their actual preview; Android PDF preview uses PdfRenderer. Replace/remove/reset clean owned cache files without deleting original documents.

The front camera supplies a live feed. On-device face/pose detection gates a five-second frontal countdown and subsequent right, left and nod instructions. Optional spoken guidance and a mute control accompany visible instructions. The first frontal photograph is retained for review. Permissions, lifecycle interruptions, cancellation and unavailable hardware have explicit handling.

Native OS biometrics confirm enrollment and returning unlock, retaining password/PIN fallback and the existing one-question login challenge. Device biometric confirmation does not supply backend primary authentication.

Vertical scrolling stays clamped. A small clipped edge response adds movement without revealing a blank gap. Dashboard refresh uses a floating white/blue indicator above stationary content, completes from a Future and prevents concurrent refreshes.

Processing Figma node 7829:87153 exported no motion tracks. It references a generic third-party card-loader visual; the existing Davochain working indicator was retained for brand consistency. Static source evidence cannot establish which animation is smoother.

## Verification evidence

Full automated suite: 338 passed, eight optional captures skipped. The final native guard/username/refresh suite passed eight tests. Light/dark verification captures passed and were visually inspected. Analyzer reported no issues. The standalone Flutter handoff reference was renamed Flutter-reference.dart.txt, removing the IDE's out-of-project Dart import errors.

Release 0.13.0+27 built successfully, installed on emulator-5554 and on Redmi device CI49FIXKM7BUOVA6; the phone reported versionCode 27/versionName 0.13.0. The phone disconnected after successful installation. Subsequent display-only corrections restore compound icon vectors, correct the Opening label and show PDF upload thumbnails. Reinstallation of those final corrections requires reconnecting the phone. Emulator/native evidence is recorded in the device QA checklist.

## Integration boundaries

Identity approval and primary account authentication remain injectable frontend fixtures until their server/provider integrations exist. On-device pose detection is a guided capture aid, not a certified anti-spoofing or identity match. Live human head poses and iOS still require physical-device validation. Do not claim production KYC approval from the local loading result.

The React Native handoff ZIP contains original splash assets/font/license, unchanged 2900 ms timeline and 320 ms exit/700 ms reduced hold contract, source reference text, final frame and an actual Flutter timeline render. No Lottie file exists for this procedural animation.

## Final follow-ups for build 28

- ID front/back upload and camera cards have consistent heights, centered labels, the supplied camera symbol, matched borders/radii, larger document thumbnails, right-aligned Remove actions and an Uploaded check badge. Take Photo asks Front of ID or Back of ID; cancellation opens no camera. Back remains optional. Large-text/small-screen captures were checked.
- Signup and Basic contact inputs normalize leading 0 and pasted +234/00234 before enforcing the ten-digit national-number limit. Cursor positions are preserved; entering 08161780381 produces 8161780381. Country selection uses one surface and remains Nigeria-only.
- Password strength is red, amber/orange and green in signup and recovery. Dashboard adds bounded edge response alongside floating refresh.
- Real rear-camera QR scanning uses mobile_scanner 7.4.2, supports tap-to-focus and available-device torch, and pauses on lifecycle/manual-entry transitions. Paste Address opens a separate animated form with explicit clipboard paste and format validation for the current asset/network. Valid scans open that form for review; they do not initiate transfers. Network changes are revalidated and supported wallet URIs are normalized before confirmation. These are format checks; checksum/provider/chain approval remains a backend responsibility.
- The reported face countdown stall has a concrete timing correction: the old 800 ms freshness deadline could reset a valid hold while slow detection was processing. Detection remains required; bounded delays preserve/pause progress, a stopped stream expires, and live no-face/pose/decoder feedback is visible. Tests simulate slow frames completing the five-second hold. Physical Redmi capture must be retested after installing build 28; no claim of confirmed physical capture is made.
- Settings PIN has independent eye toggles, exact four-digit validation, visible mismatch/match feedback, gated Save, keyboard-safe scrolling and secret clearing. The existing frontend success contract remains; no raw PIN is persisted or new backend mutation invented.

Primary implementation references: [mobile_scanner documentation](https://pub.dev/packages/mobile_scanner), [Bitcoin address URI specification](https://github.com/bitcoin/bips/blob/master/bip-0021.mediawiki), [Ethereum request URI specification](https://eips.ethereum.org/EIPS/eip-681). Contract transaction requests and mismatched explicit chain IDs are rejected rather than treated as wallet recipients.

The final camera correction also trims CameraX trailing NV21 allocation padding while rejecting incomplete frames. Live frontal alignment now uses the same 15-degree bound as saved-photo validation; nod return is measured against the captured frontal pitch. Seven final conversion/freshness/guidance tests passed and the analyzer was clean. These address concrete driver/timing/gating issues; final on-phone retesting is still required.

Release28 final full suite: 355 passed, nine optional captures skipped; final APK audit790 declared files, none missing/mismatched, three ABIs. Release28 was installed on Redmi CI49FIXKM7BUOVA6 and reportedversionCode28/versionName0.13.0; launch succeeded. User subsequently clarified phone normalization: preserve leading0 while typing; strip only at11digits. This supersedes immediatezero removal in build28 and is implemented for signup and Basic contact in build29. Ten-digit leading-zero partial numbers cannot continue.

Physical user feedback on build28 confirmed opposite directions during right/left prompts. Build29 inverts camera-space yaw for user-relative front-camera instructions. Regression verifies negative detector yaw advances the user-right hold and positive yaw advances user-left. Phone-normalization and camera corrections final12tests passed; physical direction retest remains required after installation.
