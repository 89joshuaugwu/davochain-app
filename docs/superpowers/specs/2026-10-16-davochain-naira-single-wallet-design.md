# Davochain Naira: one customer fiat wallet

Status: approved for implementation by the user on 16 October 2026, including the 1:1 relationship, selected currency mark, single-wallet plan and direct work/push on main.

## Confirmed product meaning

1 Davochain Naira represents exactly NGN 1. A customer has one branded naira wallet. Receiving account details map incoming Nigerian bank transfers to this wallet, including transfers from other people as requested. Customers buy crypto with it, sell crypto into it, and withdraw from it to a linked bank account. Crypto-to-crypto exchange uses Swap and debits the chosen funded crypto holding.

Davochain Naira is the customer-facing wallet name. NGN remains the underlying currency code in banking, quotes and ledger contracts. A custom mark does not create another currency, conversion rate, ISO code or public Unicode character. Retire NGD as a separate spendable balance after migration; retain it as a legacy alias when reading older records.

## Evidence from the current app

- `buy_crypto_models.dart`: BuyFundingWallet exposes separate Nigerian Naira/NGN and Davochain Naira/NGD entries. `buy_crypto_flow.dart` opens an extra funding-wallet selector after choosing a crypto asset.
- `wallet_repository.dart`: available balances separately store NGN and NGD. Dashboard and naira-withdrawal balance getters read NGN; receiving simulation credits NGD. This split explains why a deposit and a withdrawal can show different available funds.
- `crypto_naira_screens.dart`: withdrawal validates NGN including the current fee and already reads saved bank accounts from SettingsPreviewSession.
- `crypto_receipt_records.dart` and `gift_card_receipt_records.dart`: selling crypto/gift cards credits NGN and gift-card buying debits NGN. These paths must join the same wallet.
- `deposit_screens.dart:1019`: current copy says NGD funds cannot be withdrawn and rejects other-name senders. These rules contradict the requested product and must be replaced.
- `bank_details_share_button.dart`: BankDepositDetails.preview is a global fixture. It is not a per-customer account provisioner.
- Deposit wallet choices contain static USD examples; several screens use standard naira glyphs directly. Presentation must come from the same live balance/valuation projection.

## Recommended architecture

Use one customer wallet identity, `davochain_naira`, denominated in NGN with two decimal places. Keep NGN as the canonical existing money/ledger asset ID during this frontend consolidation, because most purchase/sale/withdrawal contracts already use it. Expose the wallet through a named accessor rather than spreading literal NGN keys across UI code. NGD becomes a read-only migration alias, not an alternative funding source or tradable crypto.

Alternatives considered: merely hiding NGN leaves two real balances and incorrect debits; making NGD a separately priced token contradicts the confirmed 1:1 wallet model and introduces unnecessary exchange behavior. Removing the NGN code from banking/FX records would confuse denomination with product branding.

Keep three concepts explicit: (1) spendable Davochain Naira balance, (2) receiving bank account mapped to it, (3) linked external bank accounts used as withdrawal destinations. Receiving details never serve as another wallet balance.

## Customer journeys

**Create/receive:** create the customer wallet, then request receiving-account provisioning through a gateway. Show creating, ready, retryable failure and unavailable states. Ready details offer bank, account name/number, Copy and Share. Incoming accepted transfer credits the wallet exactly once. Reading/copying/sharing details never credits funds. Support other-person senders as a product requirement; the eventual provider integration must actually support this behavior before production claims are enabled.

**Buy:** show Davochain Naira as the fixed/default source. Choose crypto, enter spend amount, show available wallet funds and quote, review, authorize and submit. Remove the NGN-versus-NGD choice. An empty wallet offers Add money. Never fall back to another balance silently.

**Sell:** choose a funded crypto holding and receive Davochain Naira. The resulting money becomes available to buy again or withdraw after the accepted outcome.

**Swap:** choose a source crypto holding with spendable funds and a different supported destination crypto. An empty funded list guides the customer to Buy. Do not add a synthetic NGD token or route a crypto-to-crypto swap through a second fiat wallet.

**Withdraw:** show Davochain Naira with the brand mark, not the Nigerian-flag NGN funding option. Choose an existing linked bank account or add one through the existing validated flow. Review amount, fee, total debit and bank amount separately. Validate the same spendable balance shown on screen, reserve once, and preserve pending/failed/released states. No other crypto balance funds a bank withdrawal implicitly.

**Gift cards:** purchases spend the same wallet; accepted sales/refunds credit it. Keep these consistent even though not explicitly named in the initial correction.

## Amount hierarchy and the selected mark

Use the approved custom D-shaped mark with two horizontal currency strokes for Davochain Naira amounts. Keep it monochrome and baseline aligned with Sora numerals; no coin badge around every amount. It inherits current text color and scales with accessibility text size. The supplied vector and private-use prototype font are under docs/design/davochain-naira; production copies live in assets after symbol implementation.

For crypto: quantity is explicit, naira equivalent comes first, and the USD estimate is smaller below it. Example structure: Bitcoin / 0.001 BTC / naira value / USD estimate. Both estimates derive from one quote snapshot with consistent timestamp and rounding; hide an unavailable conversion rather than inventing an amount. USD is a valuation, not another spendable wallet or payment source.

For Davochain Naira: primary custom-mark balance, followed by a compact naira equivalent if requested during recognition/onboarding, then a smaller USD estimate. Because it is 1:1, the naira equivalent is the same numeric value, not a second conversion. Recommend explaining the parity once instead of permanently repeating it on every card; retain both equivalents in detailed wallet views if desired.

Dashboard Available balance shows spendable Davochain Naira, not total crypto value. Crypto portfolio value stays separately labelled and is not counted twice. Hiding a balance hides primary/naira/USD amounts and screen-reader values together. Screen readers say the amount plus Davochain Naira. Plain-text copy/share uses `Davochain Naira 1,250.00` (or NGN in machine/external bank contracts); never send a private-use glyph to apps without its font. Bank settlement and explicit exchange-rate fields may still show NGN/standard naira notation to identify the real currency.

## Persistence migration

Audit provenance before deciding how old NGN and NGD amounts combine. Current local checkpoints hold independent balances, but never assume an imported pair are independent rather than mirrored. Consolidate verified independent funds at 1:1, preserving available-plus-reserved totals. A checkpoint with insufficient provenance must follow an explicit resolution policy instead of resetting, taking max, or blindly doubling money.

Migrate amounts, pending reservations/debits/credits and account defaults atomically under a versioned account migration. Preserve operation IDs, settled/rejected sets, fees, receipt history, read state, delivery outbox and account isolation. Translate legacy pending effects consistently so later success/failure cannot debit the retired wallet or release a different currency. Keep historical receipt facts intact, using a presentation alias for their wallet name. Re-running migration must be a no-op. Migration creates no synthetic deposit, notification burst or chart gain.

## Local versus backend boundary

Without a backend, provide deterministic per-test-account receiving fixtures via an injected local gateway; label them as previews and never present a fabricated bank account as a real issued account. Production provisioning, accepted-transfer webhooks, provider event verification, persistent bank linkage, withdrawals and reconciliation are later gateway adapters. Do not manufacture an account number on signup. Account creation can succeed with receiving details still pending.

## Acceptance

One source for wallet balances and every debit/credit; no second NGN/NGD selector; correct receiving/saved-bank separation; third-party receiving requirement represented accurately; safe one-time migration and pending-operation restore; funded crypto swap sources; exact naira arithmetic; coherent naira/USD estimates; visible/readable custom symbol with text fallbacks; genuine outcome notifications; no cross-account data leakage.
