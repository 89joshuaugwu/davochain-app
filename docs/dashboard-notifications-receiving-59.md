# Dashboard, notifications and receiving refinement (build 59)

## Delivered behavior

- Dashboard cash card is 16 logical pixels shorter. Actions move upward and the mountain moves upward with them. Naira and USD equivalents retain separate lines. Standard phone layouts keep three complete crypto rows; short screens and enlarged text retain scrolling.
- Buy/sell cash quotes use the custom Davochain glyph. Tappable currency selectors receive a thin outline, 48-pixel minimum target and blue keyboard focus border. The fixed cash wallet remains plain.
- Deposit announcement preferences now store an optional native English voice ID and a Natural, Deep, Warm or Bright style. Styles adjust pitch/rate; they are not claims about a speaker's gender or age. Installed voices are listed by locale, with offline/internet labels. The fixed phrase, default-off preference, deposit-only acceptance, replay suppression and native silent/DND/channel/volume checks remain in force.
- Voice enumeration and speech cancellation are separate. Changing styles cannot cancel discovery; stalled engine initialization is cleaned up after eight seconds even when pending speech was cancelled.
- Notification actions menu provides Mark all as read and Clear notifications. Clearing requires confirmation and checks the inbox account generation again afterward. Both operate across all categories, update unread badges, dismiss corresponding phone alerts, suppress pending speech and preserve consumed event IDs. Transaction/receipt records are independent.
- All ten catalog assets open the receiving page. QR content is generated from the copied address, with quiet zone and error correction. XRP has a separately copyable required destination tag; the address QR explicitly does not contain it.

## Receiving boundary

All crypto destinations are fixed **test-network UI fixtures**, not backend-issued customer wallets. Each page and share preview identifies testing. Do not send real funds or expect chain deposits to credit the ledger. Live issuance, custody, token contract/network validation and chain monitoring require the backend. Existing external withdrawal support remains restricted to its five previously supported assets.

Catalog remains ten crypto assets and twelve gift-card brands. This update completes the receiving pages; it does not invent additional tradable assets or gift-card inventory.

## Sources and evidence

Android voice IDs, locales and network requirements follow [Android Voice](https://developer.android.com/reference/android/speech/tts/Voice) and [TextToSpeech](https://developer.android.com/reference/android/speech/tts/TextToSpeech). These APIs do not provide reliable gender/age metadata.

Screenshots and release artifact: workspace `review/evidence/dashboard-card-59`. Automated and device results are recorded below after verification. Installed voice quality/variety depends on the phone's TTS engine; audible voice previews require manual listening on an unlocked device.

## Verification results

- Full regression run: 794 passed, 18 optional captures skipped, three old presentation assertions failed because of the intentionally replaced address/rate display. After updating those expectations, all 27 tests in the three affected files passed. This verifies all 797 distinct normal tests across the full run and focused rerun; no runtime logic was changed for those assertion updates.
- Static analysis: no issues. Dedicated light/dark capture: passed, fourteen captures generated for dashboard, buy/sell, receiving and notification/voice surfaces; representative light/dark images visually inspected. Voice screenshots use a controlled installed-voice fixture; they do not represent a recording or an actual device's voice inventory.
- Rendered XRP QR codes decoded with ZXing in both themes and matched the copied address. All ten assets have automated QR-data/clipboard correspondence checks; XRP tag copying is tested separately.
- Independent review completed; separate speech cancellation and stalled initialization timeout findings were corrected.
- APK `0.19.1+59`: release build succeeded in 402.1 seconds, 138,170,274 bytes. SHA-256 `49A24DF466738304165040BB4DFD47CCBF87D975A8B4AF219EC5A81E7C8C517D`. Existing development signer retained (`d0de9b8311199a2eb6a238d106b45eaa9d30fe4ef0ef7b9b5808edc3988e2411`).
- Replacement installation with `adb install -r`: Success on emulator-5554; Android package metadata confirms version code 59. No uninstall or data reset. A newly connected physical phone was not modified.
- Native screen acceptance is limited by the emulator's independent System UI ANR during startup (screenshot in the evidence directory). The package installs and its process starts, but authenticated screens and audible voice previews are not claimed as manually verified. Automated layout/copy/notification/voice preference checks remain the verification evidence for those paths.
