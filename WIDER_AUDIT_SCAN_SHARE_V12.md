# Davochain v12 — Scan/Paste Address + Share Address Final Verification

This checkpoint closes only the two wider-audit items below. It does **not** reopen already-closed trade, modal/sheet, Naira Withdraw, or internal/external withdraw work.

## 1. Scan / Paste Address — CLOSED

Authoritative Figma frame: `7319:57871` (`Crypto Withdraw Mode - Wallet`).

### Exact Figma-backed Scan state

Verified and retained:

- Root background: `#F8F9FB`.
- Back icon: Figma x=8, y=60, 24×24. The Flutter body uses the same x and a SafeArea-local y offset that resolves to the Figma header position.
- Header: `Scan or Paste Address`, Sora SemiBold 14.
- Tabs:
  - Scan QR Code: x=16, y=111, 170×48, radius 4, selected `#135CF7`.
  - Paste Address: x=202, y=111, 172×48, radius 4, inactive `#EAF0FB`.
- Camera panel: x=16, y=185, 359×485, radius 8, `#191919`.
- Scanner frame: x=51, y=197, 290×290.
- Flashlight control: 42×42 at x=175, y=495, with exact 24×24 flashlight asset.
- Instruction baseline: y=548.
- `Enter Address manually` baseline: y=569.

The previous Flutter screen used white as the page background; this checkpoint corrects it to the exact Figma `#F8F9FB`.

### Paste state limitation and functional treatment

Figma provides **one** frame containing the Scan/Paste tabs and the Scan content. There is no second detailed Figma frame that specifies the content below the active Paste tab. Therefore, no separate invented design is claimed as pixel-perfect Figma.

The functional Paste state now:

- Preserves the exact Figma tab geometry and swaps the selected/inactive colors correctly.
- Uses the same 358×48 wallet-address field geometry and `#F5F6F9` input treatment already defined by the authoritative external-withdraw Figma flow (`7319:57609`).
- Uses the same Open Sans 16 address-entry typography used by that Figma address field.
- Supports real clipboard paste instead of displaying a hard-coded sample address.
- Enables `Use Address` only when a non-empty address is present and returns the pasted/typed value to the withdrawal flow.

This is a design-system-consistent functional extension only where Figma is silent.

## 2. Share Address — CLOSED

Authoritative Figma bottom sheet: `7319:55228` (`Share Address`).

Verified / corrected:

- Sheet: 390×257, white, 16px top-left/top-right radius.
- Figma has no drag handle and no close icon; Flutter does not invent either.
- Preview card: x=16, y=59, 84.56×124.43, radius 4.
- Preview card border corrected from the prior soft `.5px #EBEDF3` approximation to the Figma `1px #B3B3B3` stroke.
- Preview title, QR, crypto badge, network/address labels and address geometry remain aligned to the Figma coordinates.
- The tiny preview-footer Davochain lockup is now the direct Figma-exported visual instead of a reconstructed logo + text row.
- `Share` heading: x=137, y=59.2.
- Description: x=137, y=89.2.
- Four action groups begin at y=124.2 with exact 40×40 circles:
  - Download circle x=143.
  - X circle x=206.
  - Telegram circle x=266.5.
  - More circle x=327.
- Action labels remain at y=170.2.
- Download / X / Telegram / More now use native-aspect PNGs rasterized from the exact supplied/extracted Figma SVGs. Telegram keeps its Figma 23×26 icon geometry rather than forcing a square icon.

## Files changed in this checkpoint

- `lib/features/crypto/presentation/crypto_full_flow.dart`
- `lib/features/dashboard/presentation/dashboard_screen.dart`
- `assets/figma_exact/share_preview_lockup_exact.png`
- `assets/figma_exact/share_download_native_exact.png`
- `assets/figma_exact/share_x_native_exact.png`
- `assets/figma_exact/share_telegram_native_exact.png`
- `assets/figma_exact/share_more_native_exact.png`
- `V12_WORK_LOG.md`

## Reopen rule

Do not redo either item in later passes unless:

1. the Figma design is revised,
2. a device/emulator screenshot shows a reproducible runtime mismatch, or
3. navigation/business requirements for the Paste state change.
