# Outcome feedback audit

Date: 2026-10-08. Scope: source-level tracing of active authentication, settings, deposits and withdrawals. This review does not certify live payment, authentication or verification services. Product code was not changed for this audit.

Following approval, first-account welcome, Naira withdrawal outcomes and deposit event feedback were implemented. See [implementation and verification notes](2026-10-08-funding-and-account-welcome-implementation.md) for the resulting behavior and remaining provider integration.

## Main findings

The clearest missing outcome pages are initial transaction PIN creation and Naira bank withdrawal. Both currently leave the input flow without a durable result. Several settings buttons also claim success through a toast despite having no corresponding operation implemented; those need operation state before richer confirmation UI.

Reuse the existing motion system: compact completed C (680 ms) for account changes; regular completed C (1120 ms) for confirmed financial outcomes; submitted S (900 ms) for accepted requests still awaiting completion. PIN authorization itself does not need an extra success page before the transaction result. Keep actions immediately available, never navigate because an animation finishes, support reduced motion and both themes, and preserve existing Sora text sizes.

## Deposits and withdrawals by method

| Method | Current path and feedback | Assessment and recommendation |
| --- | --- | --- |
| Naira withdrawal to an existing bank account | `NairaWithdrawScreen` → payment method → review/terms → `CryptoPinScreen` → “Submitted Successfully” toast → pop | **Highest-priority gap.** Replace the toast-and-pop after an accepted operation with “Withdrawal submitted”, submitted S, amount, bank, masked account, fee, status and available reference. Actions: View details / Back to wallet. Show completed C only after confirmed payout. Source: `crypto_full_flow.dart:394–539`. |
| Naira withdrawal to a newly entered bank account | Same withdrawal path; `AddBankScreen` collects bank and number, resolves a fixture name, then returns a `BankAccount` to the caller | Same missing withdrawal result. Returning to the payment selection is useful and should stay; add lightweight confirmation of account selection rather than another full success page in the middle. The name resolution is a timed fixture, not bank verification, and this does not establish persistent linking. Source: `crypto_full_flow.dart:795–925`. |
| Crypto withdrawal to another Davochain user | Entry → review → PIN → `TransactionProgressScreen` → completed `TransactionSuccessScreen` | Result screen already exists, including receipt access. Internal completion comes from the preview operation. Connect actual transfer results later; no extra “PIN successful” screen. Sources: `crypto_full_flow.dart:1748–1778,1955–2135`, `preview_transaction_operation.dart`. |
| Crypto withdrawal to an external wallet | Asset/address/network → review → PIN → progress → “Withdrawal submitted” with pending outcome and pending receipt | Correct distinction already exists: submission is not blockchain completion. Extend real status tracking with pending, confirmed, failed and cancelled states. Preserve the selected network in the operation and receipt: `_confirm` currently passes target, amount and asset to progress, but does not pass its selected `network`. Source: `crypto_full_flow.dart:1700–1778,1955–2135`. |
| Crypto deposit: BTC, ETH, SOL, USDT | Wallet/asset selection → receiving address, QR, network information, warnings, copy/share | These are receiving instructions, not completed deposits. Do not show success for opening this screen, copying an address or sharing a QR. Add a fresh deposit event outcome when an actual wallet-credit event arrives; pending while awaiting required confirmations. Source: `dashboard_screen.dart:220–260,1941–2167`. |
| Existing crypto deposit history | A sample history row opens `DepositStatusScreen(success: true)`; completed mark is settled/static. A pending variant also exists | Historical details are already covered and should not replay celebration every visit. Current deposit details are hard-coded BTC samples and a boolean status, not a live multi-asset event model. Generalize asset, quantity, network, hash, confirmations and status before wiring real arrivals. Sources: `transaction_history_screen.dart:115`, `crypto_full_flow.dart:3834–3920`. |
| Naira deposit by bank transfer | Receiving-bank details, copy controls and “Share Details”; copy has toast; Share Details currently only says details are ready to share | No credited-deposit outcome or actual share action in this page. Implement share separately from deposit completion. Show “Deposit received” only after credited funds are confirmed, with amount, destination wallet, reference, date and transaction details. Source: `dashboard_screen.dart:2541–2672`. |
| Card / USSD / mobile-money deposit or withdrawal | No separate active funding/withdrawal flow found in the inspected feature sources | Do not invent success states for methods the app does not implement. Gift-card purchases are a different feature. Crypto Buy funding currently selects an existing NGN or NGD wallet, not a debit/credit-card deposit. Source: `buy_crypto_models.dart:24–54`, `buy_crypto_flow.dart`. |

Additional financial-flow checks to retain in implementation:

- Naira withdrawal currently displays an enabled Continue button even when its callback does nothing because the form is incomplete. Its readiness check is text-based, without robust amount, available-balance or daily-limit validation. Use parsed amounts and authoritative limits before authorizing an operation.
- Deposit copy says incoming transfers fund NGD and that NGD funds cannot be withdrawn, while the application also offers NGN withdrawal and NGN/NGD purchase funding. Make the receiving wallet and eligible withdrawal balance explicit. These may be different wallets; the audit does not assume a business-policy change.
- Cancellation of review/PIN must leave the transaction unsubmitted. Failed operations must preserve useful context for retry; no successful mark or balance change on failure.
- Externally received deposits need event-driven feedback. Neither waiting a fixed duration nor tapping “I paid” establishes that funds arrived.

## Other outcome gaps

| Action | Current behavior | Proposed treatment |
| --- | --- | --- |
| First transaction PIN setup | After matching confirmation, clears navigation stack directly to Home (`verification_flow.dart:383–406`) | Compact C “Transaction PIN created”, then explicit Go to Home. Emit only after the intended PIN setup operation succeeds; the present implementation only compares locally entered values. First entry and mismatch stay inside the form. |
| Change password in Settings | Always-active CTA only shows “Password updated” (`profile_settings_flow.dart:279`) | Validate old/new/confirm fields, handle operation state, then compact C “Password changed” with Back to security. Keep failure on the form. This is separate from forgot-password reset, which already has a result. |
| Link bank account in Settings | Bank selection immediately pops; linked-account cards are static (`profile_settings_flow.dart:2000–2059`) | Complete number entry, account resolution, review and linking before “Bank account linked”. Merely choosing a bank is not account linking. |
| Send support email/request | Only shows “Email sent”; no send operation in handler (`profile_settings_flow.dart:790`) | After accepted submission, show submitted S “Request submitted” and actual ticket reference when available, then Back to support. Launching an email composer alone is not delivery. |
| Redeem Davo points | Only shows “Points redeemed”; displayed balances/activity are static (`profile_settings_flow.dart:803`) | Validate redemption and update state after acceptance. Completed C with credited amount if confirmed; submitted S if credit is pending. |
| Delete account | Confirmation closes the dialog; neither deletion nor outcome is implemented (`profile_settings_flow.dart:3863`) | Implement the actual request first. “Deletion requested” for a pending request; “Account deleted” only for confirmed deletion. Do not add a celebratory successful state to the current no-op. |

## Already covered / no extra page needed

- Email/SMS verification, forgot-password reset, transaction PIN reset, personal-information update and fingerprint setup already have result presentations. Some are preview state; the presence of UI does not establish provider persistence.
- Basic and Advanced KYC already show submitted outcomes rather than approval. Retain that distinction.
- Crypto Buy, Sell/Swap, and gift-card purchase/submission already have outcomes.
- Login/returning-user unlock already has its password/fingerprint transition into Home. Adding another generic success page would duplicate closure.
- Copy/download/share acknowledgements, appearance saves, simple toggles, selecting a bank/wallet/network, and ordinary logout do not need full success pages.
- Settings outcome buttons that `popUntil(isFirst)` should be checked against the intended destination. Prefer returning to the relevant settings section for account changes, and to the wallet/history for financial outcomes.

## Implementation order and acceptance

1. Add initial PIN setup closure and Naira withdrawal submission result using shared `DavoResultScreen`/motion recipes. Preserve existing transaction authorization flow.
2. Generalize deposit transaction data and wire fresh pending/credited events separately from settled history details. Preserve asset and selected network through financial operations and receipts.
3. Finish password-change, settings bank-linking, support and rewards operations, then attach outcomes to their accepted results. Account deletion remains a separate operation change.
4. Verify invalid input, PIN mismatch, cancellation, delayed/failed operation, repeated taps, return navigation, light/dark, reduced motion and large text. Ensure histories do not replay completion, receipts match the accepted operation, and no result appears just because an animation or timer ended.

The source audit was completed without rebuilding or reinstalling the app. No runtime financial transaction was performed.
