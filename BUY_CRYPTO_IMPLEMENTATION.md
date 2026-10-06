# Davochain Buy Crypto — Frontend-only milestone

This build implements the Buy Crypto flow without backend/API dependencies.

Implemented interaction path:

1. Dashboard **Buy Crypto** action
2. Cryptocurrency selector bottom sheet (BTC, ETH, SOL, USDT)
3. Funding-wallet selector bottom sheet (Nigerian Naira / Davochain Naira)
4. Buy amount screen with inactive/active states
5. Percentage shortcuts (10%, 25%, 50%, 75%, Max)
6. Local quote / estimated crypto calculation
7. Review and confirmation screen
8. Transaction-PIN state
9. Animated local processing state
10. Purchase-success state
11. Local transaction-details screen
12. Repeat-purchase and return-to-dashboard actions

The crypto selector uses packaged token artwork and the Nigerian Naira funding option uses the packaged flag asset. No HTTP client, API endpoint, wallet service, authentication service, payment processor, exchange API, or backend call is used by this feature. Balances, rates, quotes, processing, success states, and transaction identifiers remain demo data for frontend testing.

The Figma source contains neighboring Sell, Convert/Swap, Withdraw, and deposit-detail frames. They are not treated as Buy Crypto implementation scope in this milestone. The Buy/Sell/Convert segmented control remains visible on the Buy screen; Sell and Convert are separate future modules.
