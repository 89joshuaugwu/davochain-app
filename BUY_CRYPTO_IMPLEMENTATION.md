# Davochain Buy Crypto – Frontend-only milestone

This build implements the Buy Crypto Figma flow without backend/API dependencies.

Implemented interaction path:

1. Dashboard **Buy Crypto** action
2. Cryptocurrency selector bottom sheet (BTC, ETH, SOL, USDT)
3. Funding-wallet selector bottom sheet (Nigerian Naira / Davochain Naira)
4. Buy amount screen with inactive/active states in one stateful screen
5. Percentage shortcuts (10%, 25%, 50%, 75%, Max)
6. Local quote/estimated crypto calculation
7. Review and confirmation screen
8. Animated local processing state
9. Purchase-success state
10. Local transaction-details screen
11. Repeat-purchase and return-to-dashboard actions

No HTTP client, API endpoint, wallet service, authentication service, payment processor, exchange API, or backend call is used in this feature. All balances, rates, quotes, processing, success states, and transaction IDs are local demo data for frontend testing.

The Figma source contains neighboring Sell, Convert/Swap, Withdraw and deposit-detail frames in the same section. They were intentionally not treated as Buy Crypto screens in this milestone. The Buy/Sell/Convert segmented control is visually preserved on the Buy screen; Sell and Convert remain separate future modules.
