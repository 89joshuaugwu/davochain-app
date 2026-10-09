# Transaction details and receipts — 9 October 2026

## Result

Funding, crypto and gift-card outcomes now share immutable transaction facts with their details screen, history entry and receipt. Receipts support image sharing, selectable multi-page PDF, a standard Davochain presentation and personal notes. Pending and failed records retain their status throughout; local fixtures carry a Preview label.

## Interactions

- Naira/NGD deposits and withdrawals expose the accepted amount, bank/account information, fee and references. Crypto funding preserves small quantities and fee currency.
- Crypto purchases, sales, swaps and internal/external transfers use a stable record. Buy and history receipts retain the supplied dates and identifiers. Withdrawal acceptance carries the selected network and disclosed preview fee.
- Gift-card buy/sell handoffs retain the reviewed brand, category, country, type, quantity and available amount. View Receipt and Track Verification are separate actions. Completed/failed verification stops the pending indicator.
- Details show amount, direction and status, expandable fields, full-reference copying and a timeline of supplied events. No timer fabricates settlement. Report Issue opens the existing support form with transaction context; it does not send automatically.
- Supported, validated Bitcoin/EVM hashes expose explorer-link copy and OS sharing. Unsupported hashes/networks offer no invented explorer destination.
- Following the user's final direction, only Standard is exposed and the type-based page heading is removed. Celebration, Appreciation and Birthday presentation code is retained for later design work. Personal notes remain limited to 240 complete grapheme characters.
- Exported account/wallet details are masked by default. An explicit switch enables full details. In-app bank-account summaries retain the last four digits. Sensitive fields are omitted from automatically prepared support messages.

## Export correctness

PNG captures the receipt paper, excluding editing controls. Existing native save/share actions handle the generated PNG or PDF. Duplicate exports and edits during capture are guarded; failures restore the actions.

PDF uses vector text/decoration and flows long receipts across pages, repeating status and Preview information. Sora is accompanied by licensed Noto fallbacks for Naira and common emoji. The same fallback families are registered for on-screen rendering.

The installed PDF package's Unicode CMap encodes supplementary characters incorrectly for text selection. An isolated font adapter writes UTF-16BE surrogate pairs instead; the PDF dependency is pinned to 3.13.1, with an upgrade regression. A rendered birthday note containing 🎂 was checked for exact text extraction, alongside Naira, status and privacy masking. Font preflight declines a PDF when it cannot preserve visible characters and explains that image sharing preserves them; it never silently drops text.

Cached asset loads can return synchronous futures. Font loads are normalized to regular futures so checks and errors follow the caller's asynchronous error handling.

## Boundaries

History remains session-local and is cleared on sign-out. Support submission, transaction execution and authoritative transaction updates still need backend/provider endpoints. Fixtures do not move funds, provide regulatory claims or invent sender/settlement data. Backend adapters can supply accepted records, including their own statuses, references, fields and events.

## Verification

Meaningful red/green checks cover flow handoffs, immutable facts, precision, masking, status updates, terminal outcomes, contextual support, PDF pagination/Unicode and capture failures. Earlier layout assertions were updated where the shared detail screen intentionally replaces the old layout.

The final broad suite passed **273 tests**, with five opt-in visual captures skipped. The analyzer reports **no issues**. The provider-update capture race is covered by a confirmed red/green regression. A separate opt-in capture batch passed and PDF extraction confirms exact Naira and emoji text, Pending/Preview labels and masking. Release packaging and installed-device evidence are recorded below after completion.

Eight visual captures cover all four papers, light/dark receipt controls and light/narrow dark details with real fonts. PDF rendering and extraction are checked separately. A temporary formatting fragment that caused IDE-only diagnostics was removed; it was outside the app source.

## Final user refinements

The style selector and its title are removed, leaving one standard receipt. The type-based AppBar title (for example Purchase Receipt) is removed while back navigation remains. Transaction type remains part of the immutable receipt facts. This refinement is covered by explicit red/green tests.

On-device purchase PDF export exposed a missing U+2248 approximation symbol in the available fonts. Added licensed Noto Sans Math as a PDF fallback and a regression using an actual purchase record, preserving the quoted exchange-rate text without silently replacing it. Release 21 was installed and verified but superseded by release 22 for these final refinements.

## Final release evidence

- Release **0.13.0+22** built and installed on **emulator-5554** without clearing app data.
- Final full suite: **273 passed, five optional captures skipped**; analyzer: **no issues**.
- All **753** declared assets/font/license files match source bytes inside the APK; ARMv7, ARM64 and x86_64 libraries present; no debuggable flag.
- APK size: **79,308,291 bytes**. Installed APK pulled back and matched SHA-256: `d2f15282c69bed11c0e2562cde466d8c8de3b5909bd6e3fee781b0f9091f32b6`.
- Installed walkthrough: preview login ? History ? purchase details ? standard receipt. Amount/date/reference remain consistent; style controls and type-based AppBar heading are absent.
- Both PDF and PNG were actually saved to Android Downloads/Davochain. Pulled PDF text preserves 0.03 BTC, history reference, date, Preview, Naira and the approximation symbol; pulled PNG decodes at 949?1915 and contains the complete receipt through its footer. Saved artifact screenshots were visually inspected.
- Cold launch and receipt/download navigation produced no crash-buffer entries, unhandled exceptions or layout overflow messages.
- Evidence: workspace `tmp/receipt-fidelity-review`, `tmp/receipt22-tests.txt`, `tmp/receipt22-analyze.txt`, `tmp/receipt22-build.txt`, and `tmp/receipt-release-apk-audit.json`. Physical phone/iOS/provider transactions were not tested in this release.
