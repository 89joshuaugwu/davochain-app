# Receipt identities and gift-card progress

Receipts retain one standard sharing layout and a blank app-bar title. Inside the receipt, each transaction has an action icon and a specific headline: purchase, sale, deposit, withdrawal, swap or gift-card trade. Coin/currency badges identify BTC, ETH, SOL, USDT, NGN, NGD and USD. Swaps show both assets; gift-card trades use the supplied product logo when recognized and a gift icon otherwise.

The same identity appears in transaction details, the shared image and PDF. Supplied SVG marks remain vector graphics in PDFs; gift logos are small embedded images while transaction text remains selectable. Asset inference excludes sensitive fields and fees. Callers can provide explicit asset metadata when connecting endpoints.

Generated fixture IDs now use DC/date identifiers. Receipt/history Preview and Sample banners have been removed as requested; internal fixture metadata remains available for integration. Accepted provider IDs and references are preserved exactly. Pending and failed statuses are retained.

Gift-card buying now advances through details, delivery and review at one-third, two-thirds and full progress. Selling advances through details, review and confirmation. Back navigation restores the previous step. The blue line transitions in 220 ms and updates immediately with reduced motion.

Validation includes real route tests for gift-card progress, all currency badges, seven transaction identities, supplied gift product assets, accepted-ID preservation, PDF generation and receipt/history consistency. A batched visual review covers six receipt identities, light/dark screens and narrow details at twice normal text size. It identified an unavailable arrow glyph and a split monetary amount; the heading now uses ?to? and the amount scales down as one line with Naira font fallback. PDF text extraction confirms populated IDs and absence of Preview labels.

Release evidence is recorded below after the combined checks and emulator installation.

## Combined release verification

Release: `0.13.0+23`, installed on `emulator-5554` (API 36). Flutter analyzer reports no issues. Full suite: 314 passed, six optional capture tests skipped. Receipt visual confirmation passed separately. The final receipt identity/external-withdrawal regression batch passed all 30 checks after the last mapping change.

Release APK: 79,635,999 bytes, ARM32/ARM64/x86_64, no debuggable flag. All 753 declared asset, font and license files match their source bytes; no files missing. The installed base APK SHA-256 matches the build: `eb77b50cf299656c4459181e497874430ef89d3a319b5de44c10900eb27cf84f`.

On the installed emulator, enrolled two preset questions and one custom question, confirmed disabled duplicate selection and hidden review answers, saved through the accepted result, then followed returning PIN login into the three-question challenge. All three matching answers opened Home. The same release opened a BTC/USDT swap receipt with the expected identity and populated ID. A native Download saved a selectable PDF with both asset badges, the same transaction facts, and no Preview wording. Crash and Flutter error/overflow scans were empty.

Evidence: `tmp/combined-final-analyze.txt`, `tmp/combined-final-tests.txt`, `tmp/receipt-external-final-tests.txt`, `tmp/receipt-visual-confirmation.txt`, `tmp/combined-release-build.txt`, `tmp/receipt-release-apk-audit.json`, `tmp/emulator-questions-review.png`, `tmp/emulator-questions-challenge.png`, `tmp/emulator-receipt-swap.png`, `tmp/receipt-fidelity-review/emulator-release23-swap.pdf`, and emulator logcat files. These paths are relative to the project workspace, one level above the Flutter app.

Physical installation: Redmi 14C (`CI49FIXKM7BUOVA6`) accepted `adb install -r` successfully. Android reports versionCode23/versionName0.13.0. Pulled base APK matches the verified release hash. App launch command succeeded. This verifies installation; the full feature walkthrough above was performed on the emulator.
