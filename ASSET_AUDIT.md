# Davochain Flutter — Figma Asset Audit

This snapshot contains the cumulative asset-fidelity pass for the screens implemented so far.

## Packaged visual assets

The following high-visibility visuals are local files and do not depend on temporary Figma URLs:

- Davochain brand mark and native splash artwork
- Splash cobalt background / lower crypto-outline artwork
- All three onboarding illustrations
- Authentication field, status, navigation, Nigerian flag, and validation icons
- Dashboard profile avatar
- Dashboard balance-wave artwork
- Dashboard promo artwork
- Dashboard Earn, notification, visibility, deposit, quick-action, and bottom-navigation icons
- Bitcoin, Ethereum, Solana, Tether, and USD Coin artwork shared across Dashboard, Portfolio, Deposit, and Buy Crypto
- Crypto deposit QR images for BTC, ETH, SOL, USDT, and USDC

## Native Flutter primitives retained intentionally

These remain native Flutter because they are interface primitives rather than missing source artwork:

- cards, sheets, rounded rectangles, dividers, borders, shadows, and solid/gradient surfaces
- OTP/PIN input structure, shake/haptic error behavior, and other state animations
- processing/success motion
- simple platform-style close/back/copy/info/chevron glyphs where Figma uses an equivalent utility icon

## Runtime policy

- No Figma-hosted runtime image URLs.
- No visual asset requires a backend/API to render.
- Buy Crypto remains local/mock-driven until backend integration is intentionally started.
- Exact token/profile/promo/balance/nav/action artwork is not replaced by custom painters.
- The host app still needs its approved Sora font integration for pixel-level typography matching.
