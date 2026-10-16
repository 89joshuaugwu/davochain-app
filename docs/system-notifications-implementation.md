# System notifications and portfolio ? build 53

Implemented from the approved 16 October notification design/plan. Delivery observes accepted local facts and never changes funds, status, authentication or verification decisions.

## Device experience

- Native Android notifications use the Davochain monochrome icon, brand accent, expanded text, private lock-screen visibility, and separate transaction/security/account/support/update/test channels. Android controls final styling, sound and visibility.
- A one-time invitation appears after reaching Home. Enable opens the real Android permission request; Not now keeps the inbox usable. Settings show effective device/channel permission, open phone settings, persist account preferences, offer private/default or detailed transaction copy, and send an explicit harmless test.
- Foreground transaction alerts are silent; security alerts retain their channel behavior. Historical/read/welcome/marketing-default/pending local initiation events do not create a phone burst. Denied/suppressed events are consumed, not replayed after permission is granted.
- Taps carry version/account/event IDs only. Existing account restore/unlock remains authoritative. Financial taps resolve the stored receipt, missing receipts fall back to history, security/account messages open their detail, and invalid/other-account payloads are discarded. Read items cancel their native notification. Logout/account switch invalidate queued delivery and clear visible account alerts.

## Local sources

Committed deposits, buy/sell/swap, gift-card transaction outcomes and withdrawal outcomes reuse the canonical receipt bridge. Basic/Advanced verification local statuses reuse the existing verification bridge. Accepted password/PIN changes, PIN lockout, linked bank, biometric preference changes and replaced security questions publish secret-free security facts. Routine unlock, copied addresses, shared receipts, refresh, own support messages, validation errors and deposit initiation stay quiet.

Remote deposits, remote verification decisions, support replies, new-device/IP detection, price alerts, marketing campaigns and new server events while terminated need a later backend/push transport. Email/SMS delivery is not available yet. No success is scheduled from the local pending timer. The immediate diagnostic tests an already-posted notification across background/process death; optional delayed diagnostics are not included.

## Persistence and limits

Installation permission invitation/request state and account preferences/outbox live in versioned SQLite metadata. Canonical facts flush before OS delivery; posting is checkpointed before calling Android. Account/generation guards run around awaited boundaries. A restored interrupted posting attempt is suppressed because it may already have been shown and dismissed. This intentionally trades a possible missed alert in that crash window for avoiding duplicate resurfacing; this is not an exactly-once delivery guarantee. An accepted fact not yet entered in an existing outbox remains eligible after restore.

Native icon resources are explicitly retained for resource shrinking. The local APK uses the existing optimized Dart/development-signing release helper; production signing and a production shrunk build remain a separate release pipeline.

## Portfolio behavior

Your assets lists funded crypto holdings. All assets uses the same ten-asset catalog as the searchable trading picker, with search and zero balances. Tapping BTC/ETH/SOL/USDT/USDC opens their existing local receiving page with QR/address/copy. XRP/ADA/DOGE/LTC/BNB open their asset overview; receiving is explicitly unavailable until supported addresses exist. These are existing local preview receiving details, not newly provisioned production addresses.

The performance total observes the current ledger. New per-account persisted valuation history records actual observed value changes, capped at 2,048 samples. There is no backfilled market history. Time filters anchor to the current observation; repeated unchanged observations do not create a trend. Value change includes funds added/removed. Cash-flow-adjusted investment returns remain unavailable until a valid source exists.

## Visual treatment

Explore uses generated transparent cobalt/ivory wallet-token-gift artwork, native accessible text and a finite entrance respecting reduced motion and lifecycle. Welcome, transaction and security notification details have contextual hierarchy, theme-aware surfaces, selectable facts and relevant destinations.

## Verification

Pending final regression/native release evidence. See workspace review/evidence/system-notifications for screenshots and logs.
