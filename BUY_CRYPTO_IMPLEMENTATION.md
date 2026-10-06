# Davochain Buy Crypto — Frontend-only milestone

This build implements the Buy Crypto flow without backend/API dependencies and aligns it to the current Figma frames under node `7319:55770`.

Implemented interaction path:

1. Dashboard **Buy Crypto** action
2. Cryptocurrency selector bottom sheet (BTC, ETH, SOL, USDT)
3. Funding-wallet selector bottom sheet (Nigerian Naira / Davochain Naira)
4. Buy amount screen with inactive/active states
5. Percentage shortcuts (10%, 25%, 50%, 75%, Max)
6. Local quote / estimated crypto calculation
7. Review and confirmation screen
8. Four-digit transaction-PIN authorization screen
9. Figma-backed local processing state with restrained native motion
10. Purchase-success state
11. Figma-aligned transaction-details screen
12. Repeat-purchase and return-to-dashboard actions

Fidelity corrections in this pass:

- Review **Confirm** no longer bypasses authorization; it routes through the PIN screen first.
- BTC, ETH, SOL, USDT, Nigerian flag, close/back, review arrow, PIN shield/lock/backspace, processing, and copy visuals use packaged Figma assets rather than generic Material/custom-painted substitutes.
- The processing custom painter was removed.
- Transaction details now follow the compact Figma layout: amount/status header, To, Asset, Date, Network Fee, Transaction ID, Done, and Share Receipt.
- The Figma PIN copy has a conflicting 5-digit active-state label while rendering four boxes. The interaction intentionally remains four digits to match the actual component geometry and inactive state.

No HTTP client, API endpoint, wallet service, authentication service, payment processor, exchange API, or backend call is used by this feature. Balances, rates, quotes, processing, success states, and transaction identifiers remain demo data for frontend testing.
