# Visual and confirmation restoration — build 41

Approved scope: restore the supplied Davochain assets/reference composition while preserving responsive layouts, exact financial arithmetic and shared wallet facts. No state-management migration is included in this batch.

## Assets and layout

The supplied BTC/ETH/USDC originals are 256x256, USDT is 200x200, and the coins/cards artwork is 736x736. These replace the former 28–37-pixel coin files and 137x87 promotion file byte-for-byte, without recompression. SVG home, gift, buy, sell, eye and portfolio-performance assets are copied from the user's Downloads files. Footer Trade and Settings remain the existing chosen glyphs. Gift action and outline variants serve their respective contexts, including delivery controls. The final referral reference uses a full-color party-popper emoji and the user-supplied ₦5,000/₦500 copy. Its vector artwork is Twemoji by Twitter, Inc. and other contributors, licensed CC BY 4.0; source: https://github.com/jdecked/twemoji/blob/main/assets/svg/1f389.svg, included license: `assets/figma_exact/TWEMOJI-LICENSE.txt`.

The home visibility icon sits beside Available Balance. Promotion art remains present on narrow phones and with enlarged text. Portfolio and NGN withdrawal cards restore the mountain artwork. Portfolio allocation again uses a weighted segmented bar and compact colored tiles; count, percentages and values come from the current wallet snapshot rather than copying reference balances. Portfolio actions and trade tabs use Davochain blue selection styling. Swap uses paired cards and the central swap control while retaining exact conversion calculations.

Deposit identifies the coin and network before the QR. Its bordered address card shows a shortened value initially, can reveal/hide the complete value, and always copies the full address. The footer wraps content without covering address controls. Shared QR/export miniatures use their own fixed physical text scale.

## Gift cards and profile photos

The promotion's artwork is enlarged in its display frame to match the reference proportion; its source pixels are unchanged. Notification rows use 9-pixel vertical padding, 3/4-pixel copy gaps and a smaller timestamp, retaining two-line summaries and content-driven growth for large text.

Reselecting the currently active gift card type previously erased its selected product. It now preserves selection/evidence. Continue still requires a product, supported denomination/precision and valid evidence; missing requirements are explained. Image attachment itself does not substitute for these requirements.

Settings profile photos are read-only. Personal Information owns a picked-photo draft; Save Changes commits it, leaving discards it, and account changes invalidate it. Photo-only changes can be saved without changing an untouched empty username; edited usernames retain validation.

## Fingerprint and payment PIN

Fingerprint has a dedicated settings page with separate app unlock and payment confirmation preferences. App unlock is enabled through device confirmation; payment confirmation remains off until separately enabled. Transaction confirmation offers fingerprint only when opted in, invokes the device biometric gateway, and retains PIN fallback on cancellation/unavailability/failure. Stale account/popped-route prompt results cannot invoke confirmation. Callback delivery is once-only.

Payment PINs are compared against session credentials established by the existing setup/reset flows. The local sample account uses `1234`; registered accounts must create their own PIN. After four incorrect payment PINs, a warning offers Reset PIN or one final try. The fifth incorrect entry pauses payments for one hour. It does not suspend the account or log out the user; resetting a PIN during the active pause preserves that pause. Sell/swap now use this same confirmation gate, and recheck account generation and available funds after confirmation. Late crypto progress from an old account cannot create a receipt in a new session.

These are local behavior gates, not authoritative account security. PIN state/preferences/retry counters are session-only; local recovery still needs replacement with verified server recovery. Backend enforcement must persist account-scoped attempts/lock expiry across restarts and devices, issue transaction-bound challenges/proofs, enforce recovery policy and securely manage session/device keys. See the transaction PIN/fingerprint section in `backend-engineer-handoff.md`. Device biometric success is not a substitute for server payment authorization. Permanent production signing remains pending.

## Verification

Regression coverage includes product/evidence preservation, missing denomination/product guidance, photo draft/save/discard, malformed username handling, device biometric cancellation/error/stale result, PIN warning/lock and reset behavior, shared sell/swap authorization, post-confirmation balance/account revalidation, deposit full-copy/reveal and stale-account progress. Phone-size coverage retains 320x568 through 480x960, normal and 200% text, actual Sora font and safe-area insets.

The full suite passed **589 tests**, with **11 optional captures skipped**. After the last banner, notification-spacing and Buy-tab refinements, targeted runs passed **78**, **18**, **78** and **76** checks respectively. Final analyzer: **No issues found**. The release build succeeded. Signature verification matches the existing development certificate; manifest inspection confirms version `0.17.0`, code `41`, non-debuggable.

APK: `build/app/outputs/flutter-apk/app-release.apk`, **133,633,234 bytes**, SHA-256 `327F8B0A6A395C1F4ABEB9EEEE76AE101C6B5387F0ECBF4007EFDE8F908DFDE6`. Emulator update install returned Success. The physical phone was no longer connected at final installation; its update remains pending. This is development-signed optimized release compilation, with permanent production signing/backend integration still outstanding.

Final command results, local integration and evidence locations are recorded in project-level `review/implementation-progress.md`. Evidence is retained in `review/evidence/visual-restoration-41/`.
