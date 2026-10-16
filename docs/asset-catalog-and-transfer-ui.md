# Asset catalog and transfers

Home shows at most five crypto assets. Funded holdings come first, sorted by their exact value under a common FX quote; zero balances follow in the curated USDT, BTC, ETH, USDC, SOL order, then remaining assets alphabetically. Portfolio shows all ten catalog assets at zero, with search by name or ticker. This popular shortlist is a product choice, not a live market ranking.

Davochain Naira is the primary displayed value, followed by `= naira` and approximate USD. Crypto quantities retain their own ticker. Hiding portfolio values also hides allocation values, percentages and monetary accessibility labels. Portfolio totals validate constituent quotes without requiring a cash holding; missing constituent prices show unavailable. Historical performance retains recorded naira valuations and does not invent historical USD FX.

The shared searchable receiving/withdrawal picker includes the one Davochain Naira cash wallet and catalog crypto. No add/plus step is needed. Existing ten logos are reused. Receiving and external withdrawals only offer the existing five supported network assets; other catalog assets remain searchable but do not invent blockchain addresses or networks. Internal transfers can use quoted holdings. Cash withdrawals still use linked banks.

Internal crypto transfer fields have consistent padding and minimum heights, a clear recipient context, and Next keyboard focus. The form retains entered amounts across asset changes and invalidates submission after an account-generation change. Review/PIN and existing exact-money acceptance checks remain in place.

The deposit banner was removed only from the bottom of Home as requested. Deposit details, the notification inbox, phone notifications and the optional deposit voice setting remain available. Voice copy punctuation was corrected.

Verification evidence is stored in workspace `review/evidence/asset-catalog-57`. Light/dark and narrow 200-percent text captures were inspected. Independent review found three Important issues; reproducing tests and corrections cover privacy, sparse/mismatched quote totals and unpriced holding quantities. One pre-existing minor remains: allocation zero rows outside simulation should be filtered when the production catalog adapter is connected. Actual banking callbacks, recipient resolution and physical-device audio/network acceptance remain backend/device integration work.

Validation: full `flutter test --no-pub --reporter expanded` passed775 tests, with18 optional capture tests skipped. `flutter analyze --no-pub` reported no issues. Final captures and native package acceptance are recorded below once completed.
Final confirmation: seven capture/transfer/picker checks passed after the external-unavailability copy clarification; analyzer again reported no issues. Native font rendering is authoritative; enlarged widget screenshots can use test fallback blocks for an explicitly styled button.

Release: version0.19.1+57 built successfully in256.7seconds (131.4MB), with the existing development signer. SHA256 `F243AACF751FA5F38BBEF4817FF637B9D3BC2C5A4D4662D39C3FA5CA27E10AD0`. Installed with `adb install -r` on Android API34, versionCode57 verified. Launch reached the returning Joshua account password gate, with no crash-buffer entries; data was not cleared. Authenticated native Portfolio/form navigation was not repeated because unlocking requires the user. Widget flow/capture evidence covers the changed screens. This remains a local development APK, not a store-signed production release.
