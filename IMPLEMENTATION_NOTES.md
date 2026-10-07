# Davochain v6 Implementation Notes

- Splash uses the recovered current Davochain/Figma cobalt composition and locally packaged brand artwork.
- Country selection remains data-driven; the flag, dial code, and phone constraints update with the selected country.
- Dashboard and Portfolio are full app states. Wallet/currency selectors, guideline panels, and share panels are modal states where appropriate.
- Dashboard high-visibility visuals use packaged assets rather than custom-painted approximations: profile, balance wave, promo artwork, quick actions, notification/earn controls, bottom navigation, and token artwork.
- Deposit branches into crypto QR/address UI or Davochain NGD bank-transfer UI.
- BTC, ETH, SOL, USDC, and USDT deposit screens use packaged QR images; the decorative pseudo-QR painter path has been removed.
- Crypto token artwork uses packaged Figma-derived PNG assets across Dashboard, Portfolio, Deposit, and Buy Crypto.
- Naira funding-wallet states use the packaged Nigerian flag asset instead of a hand-drawn green/white/green approximation.
- Buy Crypto is local/mock-driven in this milestone and includes amount, review, PIN, processing, success, and transaction-detail states.
- Copy actions use the dark floating success-toast treatment used throughout the prototype.
- Login and successful transaction-PIN setup route to the dashboard in this prototype.
- Legacy Davopay product naming is not used in shipped Dart UI copy.
- Sora is referenced by family name throughout the UI but font binaries are intentionally not bundled in this source snapshot; integrate the approved font in the host app for final typography QA.

## v9 — Gift Card Figma fidelity

Implemented the complete Gift Card board from Figma section `7319:59420` as interactive Flutter Buy/Sell flows. Added exact local Figma brand/card/UI assets, wired Dashboard and bottom-navigation Gift Card entry points, and documented the 15-state coverage in `GIFT_CARD_SCREEN_COVERAGE_V9.md`.
