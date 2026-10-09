# Safe-area review

Reviewed screen scaffolds, shared authentication/trade/result layouts, dashboard navigation, receipt details/export controls, and modal selection routes for status-bar/cutout, bottom navigation, and keyboard insets.

Most page content already uses SafeArea. Dashboard content delegates the bottom inset to its protected navigation bar. Auth, trade, gift-card, settings, welcome/result, and receipt content retain their existing protection. Splash artwork intentionally reaches the screen edges.

Fixed gaps:

- Cryptocurrency/funding wallet selectors and withdrawal, network, bank, confirmation, warning, and cancellation sheets now protect bottom/side insets and scroll when the available height is short. Keyboard insets are applied outside their scroll viewport.
- Deposit and withdrawal modal routes now retain top/side cutout protection with useSafeArea.
- Sell-wallet and network-warning close controls anchor to the right edge rather than a fixed screen coordinate.
- The add-bank form uses the shared scrollable trade form layout, keeping its save action above the keyboard. Bank-field containers grow when account names wrap rather than overflowing a fixed height.
- Country selection now scrolls on short screens. The Nigeria picker also protects bottom/side insets instead of relying on its fixed bottom margin; its modal can use the available safe height.

Verification: new portrait/landscape selector tests reproduced unsafe last-row placement before the fix and passed afterward. A keyboard-open bank-search test selects Access Bank above the keyboard and checks for layout exceptions. The initial related suite passed 33 tests; after bank-form changes all six selector/withdrawal tests passed. Analyzer clean. This is targeted evidence, not a claim that every physical device or landscape page has been exercised.

Additional country-specific verification: portrait and landscape tests check Nigeria's position within cutout/navigation insets and Continue's position after selecting it. All 12 country/authentication/safe-area tests passed.

Release 0.13.0+26 built and installed on the emulator, which reports version code 26. Installed country-picker walkthrough and screenshot confirmed the Nigeria row remains above the gesture navigation area; crash buffer is empty. All 756 declared asset/font/license files match the APK, and all three Android ABIs are included. APK SHA-256: `5dcf72584f2e3619be40dd1a34bf872ae34be91f4b230874fb65ef74682643f7`. Physical phones were not connected at installation time; the boss's device remains to be checked with this new APK.
