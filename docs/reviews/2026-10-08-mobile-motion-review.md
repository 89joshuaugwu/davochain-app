# Mobile motion and confirmation review ? 8 October 2026

The preview now uses one finite, vector-based success accent instead of separate GIF and elastic-check treatments. A cobalt ring traces around a white disc, a check draws into place, and a soft halo with three small accents fades out. The complete sequence lasts 850 ms and settles without looping. Reduced motion renders the completed mark immediately. The caller still determines the transaction outcome; animation is presentation, not proof of settlement.

| Area | Result |
| --- | --- |
| Buy | Purchase wording and the entered order amount; shared scrollable result with pinned actions |
| Sell, conversion, internal/external withdrawal | Shared result mark/layout; existing details/navigation preserved |
| Deposit | Successful status receives the mark; pending remains pending |
| Gift card purchase | Shared mark with aligned receipt rows and pinned actions |
| Gift card sale submission | Submission confirmation uses the mark; trade review remains pending |
| Password recovery | Shared mark, scrollable copy and pinned login action; unsupported other-device signout promise removed |
| Email/phone verification | Shared result layout, existing next-stage route preserved |
| Profile PIN, profile information, KYC tier, full verification | Shared mark; KYC processing retains its processing treatment |
| Fingerprint preview setup | Finite success mark after explicitly enabling the simulated preview |

Route motion already uses native MaterialPageRoute transitions through AppPageRoute. The installed Flutter SDK's Android default is PredictiveBackPageTransitionsBuilder; iOS retains its interactive edge swipe. The shared route bypasses visual transitions with reduced motion. Preserve those platform behaviors rather than replacing every navigation with an ornamental transition. Splash-to-onboarding/returning preview uses its restrained fade, onboarding uses page motion, and shared buttons already provide press feedback and haptics.

The returning-user preview adds a finite entrance for the lockup and content card. Its fingerprint control sits above password input. It explicitly simulates authentication and stores only session preview booleans; normal cold starts still run onboarding. Background/minimize locking, stored sessions, password verification and native biometric authentication remain backend/security integration work as requested.

The supplied Dribbble links are visual references. Their accessible page text did not establish a complete video playback review; the implemented animation is an original Flutter vector treatment using Davochain's cobalt palette, not a recreation claimed from those videos.

Residual preview limitations recorded in the release-coverage review include inconsistent historical sample transaction amounts/rates/dates and mock share/payment responses. These require shared transaction records and backend contracts before production integration.
