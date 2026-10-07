# Davochain v12 — Modal / Sheet Final Verification

Checkpoint scope: **modal/sheet verification only**. This record exists so later passes do not rebuild or re-audit already-closed sheet work unless a new Figma revision is supplied.

Figma file: `z5bMfbhPLQQyZUK8lHU5jo` (`Davopay and Davochain`).

## Closed sheets

| Flutter implementation | Figma node | Exact root | Final status |
| --- | --- | --- | --- |
| `_WithdrawWalletSheet` | `7319:56657` | 390×472, top radius 16, `#F8F9FB` | **Closed.** Handle 85×4 at y=6, title y=32, close 32×32 at x=342/y=20. Wallet row text baselines corrected to Figma y positions. |
| `_SellWalletSheet` | `7319:59224` | 390×242, top radius 20, `#F8F9FB` | **Closed.** Correct Sell-specific Figma sheet confirmed (not Buy sheet `7319:59387`). Handle/title/close and NGN row already matched; no rebuild. |
| `_PaymentSheet` | `7319:58186` + populated state `7319:58246` | 390×384, top radius 16, `#F8F9FB` | **Closed.** Saved-bank row baselines corrected and exact 16×16 `ep:arrow-right` derivative added. Row starts remain y=117 and y=185. |
| `_BankSheet` | `7319:58077` | 390×813, top radius 16, white | **Closed.** Handle x=164/y=11/62×5, close icon visual x=16/y=36/24×24, title y=37, search y=76. Bank list content corrected: 40×40 icon anchors to row top and label y=row+10.5. |
| `_ExternalWithdrawConfirmSheet` | `7319:57847` | 390×407, top radius 16, white | **Closed.** Header x=14/y=42, close visual x=343/y=42/32×32, summary card x=14/y=106/361×159, Confirm x=14/y=329/361×48 already matched. |
| `_InternalWithdrawConfirmSheet` | `7319:57996` | 390×539, top radius 20, white | **Closed.** Close x=16/y=32/23×24, Payment PIN label x=270/y=36.5, card x=16/y=80/358×287, notice y=383, button y=466 already matched. |
| `_NairaConfirm` | `7319:58379` | 390×539, top radius 20, white | **Closed.** Converted to fixed Figma geometry: amount y=108; detail baselines y=153/200/247/294/347; agreement icon/text y=411; disabled/active button x=16/y=467/360×48. |
| `SelectNetworkSheet` | `7319:56459` | 390×407, top radius 16, white | **Closed.** Figma intentionally has no drag handle/close control. Title y=41, warning x=23/y=73/350×72, network rows y=163 and y=250 already matched. |
| `SanctionWarningSheet` | `7319:56442` | 390×627, top radius 16, white | **Closed.** Handle x=149/y=15/92×5, close x=342/y=27/32×32, body baselines and button x=17/y=530/361×48 already matched. Davochain naming remains intentional in app copy. |
| `CancelReminderSheet` | `7319:58533` | 390×229, top radius 16, white | **Closed.** Figma intentionally has no handle/close icon. Title y=24, prompt y=58, Continue button x=38/y=101/314×48, Cancel x=38/y=165/314×48 already matched. |

## Exact asset derivative added in this checkpoint

- `assets/figma_exact/crypto_ep_arrow_right_exact.png` — rasterized directly from supplied exact Figma SVG `dashboard_crypto_icons__ep_arrow-right.svg` for the saved Payment Method rows. Recorded in `asset_alias_map.csv`.

## Source changes in this checkpoint

Only `lib/features/crypto/presentation/crypto_full_flow.dart` was behavior/layout-patched. The pre-pass source backup is stored outside the app folder as:

`/mnt/data/davochain_v12_work/crypto_full_flow_before_modal_sheet_final_verification.dart`

No Profile/Settings, onboarding/welcome, dashboard, gift-card, receipt, deposit, PIN, or other wider-audit screens were changed in this checkpoint.
