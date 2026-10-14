# Notification unread count

The dashboard bell and notification center share `NotificationInbox.instance`.
Its immutable records use stable notification IDs and canonical read flags.
Opening a notification marks that ID read immediately; listeners update the
mounted dashboard without navigating away or remounting it. Preview account
resets restore the four sample notifications and invalidate pending publications.
The legacy `PreviewAccountState.readNotifications` title set is a delegating view
of this same inbox, preserving existing preview callers without extra read state.

The bell retains a 48 × 48 tap target and a native 24 px blue glyph. Its red
superscript badge displays `1` through `9`, then `9+`; zero hides it. The 20 px
badge stays fixed at enlarged text settings. The whole button announces the
exact count, for example “Notifications, 12 unread”, and exposes one tap action;
the badge text has no separate semantics node.

## Backend adapter contract

This change adds no HTTP endpoint, polling, push subscription, or server-backed
read persistence. The four records remain explicit preview fixtures. A backend
adapter should capture `capturePublicationToken()` before its asynchronous
request and pass that token to `publish(records, token: ..., unreadCount: ...)`.
Publication rejects responses superseded by a local read, a newer publication,
or an account reset. Retry/refetch with a fresh token after a rejected response.

Provide stable unique IDs and server read flags. An optional authoritative
`unreadCount` includes notifications outside the loaded page and must be at
least the unread count of the records supplied. Local reads decrement that
aggregate once; repeated reads are idempotent. Without an aggregate, the count
is derived from the loaded records. Adapters remain responsible for account
identity, server ordering/version checks, read acknowledgements and failure
reconciliation; do not combine partial pages as if they were the entire inbox.

Focused tests cover badge boundaries, exact accessible counts, enlarged text,
tap behavior, live dashboard updates, center read actions, resets, immutable
snapshots, duplicate-title identity, aggregate counts and stale publications.
