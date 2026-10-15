# Account behavior and release checks, build 48

Version: 0.18.6+48. User clarified that there is no backend for this presentation and requested normal product copy without preview or simulation labels. Internal adapter names and this engineering documentation remain explicit about their authority.

## Implemented

- New registrations create zero NGN, NGD and ten crypto balances.
- Add funds / Confirm deposit on receiving pages creates a pending local deposit. The shared lifecycle completes after 20 seconds and credits once. Copy/share/QR actions do not create a deposit.
- Buys debit the selected NGN/NGD source. Sells credit NGN; swaps credit the destination crypto. Transfers, withdrawals and gift purchases debit sources; successful gift sales credit NGN. Outgoing pending funds reserve once, failed requests refund once, insufficient requests fail consistently, and account-generation changes reject stale effects.
- One dated CoinGecko snapshot supplies ten crypto prices, portfolio values and consistent USD estimates. Exact units and floor rounding determine receipts and credits.
- Distinct password, PIN, security-question and crypto-security icons; authentic fingerprint retained. Empty holdings show zero. Portfolio actions use neutral styling and allocation counts positive holdings. Removed fixture gain labels and local sync badge from active account views.

## Verification

- Final full test suite: 650 passed, 16 optional capture tests skipped. A sparse wallet refresh without optional FX metadata is covered by the passing post-PIN authorization test.
- Focused verification after correction: 21 passed, including authorization, all ten asset precisions, lifecycle, insufficient-funds status consistency, one-kobo sell rounding, USD quote agreement, normal deposit wording and light/dark render captures.
- Source analyzer: no issues found. Read-only code review found three consistency issues; all corrected and independently rechecked.
- Widget evidence: workspace review/evidence/wallet-simulation-48/widgets. Release installed successfully with adb install -r; package versionCode 48 / versionName 0.18.6 confirmed. Native flow evidence appended below.

## Limits for handoff

Account funds/history are session-local. Durable per-account storage and restart reconciliation are explicitly planned in the Riverpod migration document. The funded existing Login identity remains available; new registration is the zero-balance path. There is no bank, chain or exchange backend in this project; this release performs the agreed local presentation flows.

Review: dashboard-portfolio-and-state-review-48.md.
Migration plan: superpowers/plans/2026-10-15-riverpod-account-state.md.

## APK identity

- Bytes: 134777791
- SHA256: 17CFF6FA46B8946173E8D56AB32D94B15973434230F13BDB977F4258E06A9154
- Development signing certificate SHA256: d0de9b8311199a2eb6a238d106b45eaa9d30fe4ef0ef7b9b5808edc3988e2411

## Native emulator verification

Installed build 48 with `adb install -r`: Success. Completed onboarding, account details, password, email and SMS verification, PIN creation/confirmation and welcome. Newly registered Account Review opened Home with zero Naira and crypto.

Added NGN 100000 through Add funds / Confirm deposit. Pending Home balance stayed zero; completion updated it to NGN 100000. Bought BTC with NGN 50000 after transaction PIN: cash NGN 50000, BTC 0.00045809 valued at NGN 49999.58. Dashboard and Portfolio quantities/valuation agreed, allocation Bitcoin 100%. Sold BTC 0.00022904 after PIN: completed cash NGN 74999.24 and remaining BTC 0.00022905 valued at NGN 25000.33. No app FATAL EXCEPTION, Unhandled Exception or E/flutter matches in captured process log. Native screenshots visually inspected; normal product wording appears in deposit entry and outcomes.

Swap, outgoing transfer/withdrawal, gift debit/credit, failure refund, duplicate settlement and stale-account protection were checked in automated tests; they were not all repeated natively in this pass. Physical phone absent from final adb inventory; only emulator-5554 was connected. No phone installation claimed.

Native evidence: workspace `review/evidence/wallet-simulation-48/emulator/`. UI tree-driven actions only. Existing emulator startup/package optimization was slow during upgrade; installed app completed the tested flows.
