# DavoChain v12 — Asset Consolidation

This pass consolidates the user-supplied exact Figma exports into `assets/figma_exact/` and rewires the non-welcome application flows to consume assets from that single root wherever those Figma exports apply.

## Source ZIPs consolidated
- `settingsandprofilegifs.zip`
- `dashboardandcryptoicons.zip`
- `dashboardandcryptoimages.zip`
- `dashbardandcryptgifs.zip`
- `giftcardsicons.zip`
- `giftcardsimages.zip`
- `settingsandprofilezipimages.zip` (including its 18 nested ZIP exports)
- `settingsandprofileicons.zip`

`assets/figma_exact/asset_manifest.csv` records every raw supplied file, its source ZIP, original path, byte size, and SHA-256 hash.

`assets/figma_exact/asset_alias_map.csv` records the flat runtime aliases used by the Flutter code. Exact supplied/canonical exports are preferred; a small number of legacy cumulative Figma assets are retained only where the latest ZIP set did not contain that particular visual (for example USDC/QR-related or some keypad/support helper artwork).

## Rewired Flutter areas
- Dashboard and dashboard crypto visuals
- Buy Crypto flow
- Full crypto/deposit/withdraw flow
- Gift Card flow
- Profile/Settings current asset roots

Welcome/onboarding screens were intentionally not touched.
