# Davochain mobile app: backend engineer handoff

Prepared from the implemented Flutter source on 13 October 2026. Paths below are relative to `davochain-app/`. This is an internal engineering handoff, not customer-facing app copy.

## 1. What must be delivered

The backend engineer must supply an account-scoped authentication service, authoritative profile and verification records, a financial ledger and payment/trade orchestration, provider integrations, persistent transaction history, settings, notifications, support and rewards data. The mobile screens already demonstrate these journeys, but the source does not establish deployed HTTP endpoints or a production API client.

**Every HTTP method and route in this document is a proposed contract for alignment.** No proposed route is an assertion that an API currently exists. There is no verified backend base URL in the inspected `lib/` source. Backend implementation language, hosting, vendors and database choices remain backend decisions.

Deliver these artifacts alongside the service:

1. Versioned OpenAPI specification with JSON schemas, examples, authentication rules, error codes and status transitions; include upload and realtime contracts that OpenAPI alone may not describe.
2. Development and staging environments, environment-specific public configuration, sandbox provider integrations and controlled test accounts.
3. A contract mapping from each mobile journey to its requests, responses, asynchronous events and required permissions.
4. Server-owned account/transaction state, immutable identifiers, ledger reconciliation and durable idempotency.
5. Seeded success, pending, rejection and failure scenarios; automated contract/integration checks and an operational runbook.
6. Product-approved fees, supported assets/networks, NGD rules, verification limits, reward rules and content. Fixture amounts and labels are not business authority.

## 2. Implemented scope and evidence

| Implemented surface | Source to inspect | Backend data/operation required |
|---|---|---|
| Country selection, registration, password creation | `lib/features/auth/presentation/signup_flow.dart`, `create_password_screen.dart` | Nigeria signup, full name, email, phone, optional referral, consent, password, registration progress |
| Email/SMS verification, transaction PIN setup | `lib/features/auth/presentation/verification_flow.dart` | Real delivery, OTP challenge verification/resend, PIN enrollment |
| Login, forgotten password, returning unlock | `login_flow.dart`, `returning_unlock_screen.dart`, `fingerprint_setup_screen.dart` under auth | Sessions, credential checks, reset grants, device binding and session renewal |
| Security-question setup, random login question, reset | `lib/features/security_questions/security_questions_service.dart` and presentation files | Account-owned enrollment, challenges, throttling, real reset email and one-use replacement grants |
| Home balance, wallets, assets, portfolio | `lib/features/dashboard/presentation/dashboard_screen.dart` | Balances, available/held amounts, valuations, allocations, prices and limits |
| Naira receiving bank details and crypto receiving address | Same dashboard file: `NairaDepositScreen`, `CryptoDepositScreen` | Assigned bank accounts, asset/network address, deposit instructions and server-confirmed deposits |
| Buy crypto | `lib/features/buy_crypto/presentation/buy_crypto_models.dart`, `buy_crypto_screens.dart`, `buy_crypto_flow.dart` | NGN/NGD funding wallet, asset quotes and accepted orders |
| Sell, convert, Naira withdrawal, crypto withdrawal/internal send | `lib/features/crypto/presentation/crypto_full_flow.dart` | Quotes, bank resolution, payouts, username resolution, external transfer validation and execution |
| Gift card buy/sell, delivery, payment, review | `lib/features/gift_cards/presentation/gift_card_flow.dart` | Catalog, subcategories, rates, uploaded evidence, fulfillment and review status |
| Transactions, details and exportable receipts | `lib/features/transactions/presentation/transaction_history_screen.dart`, `lib/shared/receipts/` | Durable accepted facts and history; shared transaction identity/status |
| Personal information/avatar and account limits | `lib/features/profile_settings/presentation/profile_settings_flow.dart` | Profile, editing policy, username uniqueness, server eligibility and remaining limits |
| Basic and Advanced verification | `presentation/verification/` and `verification_media/` under profile settings | NIN/BVN checks; ID, selfie and address document submission/review |
| Linked bank accounts and password change | `settings_action_flows.dart`, `settings_personal_action_flows.dart` | Bank catalog/resolution, account linking and authenticated password change |
| PIN reset, crypto protection settings | `profile_settings_flow.dart` | Reset proof and PIN replacement; authoritative security policy |
| Notification center, category/channel settings and privacy | Same profile file; `lib/core/preview/preview_account_state.dart` | Notification records/read state, preferences, consent and push registration |
| Points, referral analytics, ambassador application/dashboard/leaderboard | Profile file and `settings_personal_action_flows.dart` | Reward ledger/redemption, referral attribution and qualification, ambassador review/statistics |
| Support email/chat/messages and help/legal content | `support_conversation_screens.dart`, `settings_personal_action_flows.dart`, `settings_content_overlay.dart` | Tickets, conversations, agent replies, help content, approved contact/link destinations |
| Logout and account deletion request | Profile file, personal action flows | Session revocation; durable deletion workflow and outcome |

The main tabs are **Home, Trade, Gift Cards, Settings**, in `lib/shared/widgets/davo_main_shell.dart`. Named app routes in `lib/core/navigation/app_routes.dart` are mobile navigation identifiers, not API paths.

**Do not infer extra backend scope from marketing or sample copy.** No implemented bill-payment journey, virtual/debit card issuing journey, USD bank-account provisioning journey, international wire flow or contact transfer management was established in this source inventory. Gift cards are implemented; payment cards are a different product. Example notification text mentioning salary/USD/wire transfers does not establish those features. Contact access and block-user rows are preferences/information surfaces; a contacts synchronization or block-list management API needs separate product agreement.

## 3. Current code boundaries to replace or adapt

### Existing Dart contracts and native integrations

These are existing code interfaces, not existing server interfaces:

| Interface/model | Current behavior | Required integration |
|---|---|---|
| `SettingsGateway.resolveBank(String bank, String number) -> Future<LinkedBank>` | Preview validates ten digits and returns a fixed account-holder name | Resolve a bank code/account number through the backend, returning a stable resolution identifier and verified display name |
| `SettingsGateway.linkBank(LinkedBank) -> Future<void>` | Delay only | Persist a previously resolved account; return a stable bank-account ID in a revised DTO |
| `changePassword(current, next) -> Future<void>` | Delay only | Verify current credentials, change password and return session/revocation policy |
| `submitSupport(subject, message, orderId) -> Future<SupportTicket>` | Generates a local reference | Persist ticket, verify ownership of attached order and return server timestamps/status |
| `submitChat(subject, message, conversationId) -> Future<SupportTicket>` | Default method wraps `submitSupport`; does not implement transport/chat | Real conversation/message service; stable conversation/message IDs and reply updates |
| `redeemPoints(int) -> Future<RewardRedemption>` | Returns `points * 5` kobo | Atomic points debit and wallet credit with server-owned exchange policy |
| `requestDeletion(reason) -> Future<DeletionRequest>` | Generates a local reference | Persistent request, eligibility, review/retention state and eventual account closure |
| `AdvancedVerificationFlowScreen.verifyIdentity`, `.verifyAddress` | Optional `Future<bool> Function()` callbacks, with local fallback behavior | Replace booleans with structured review results including pending/rejected/error; pass uploaded media IDs and verification case IDs |
| `VerificationMediaGateway.pickIdentity`, `.pickDocument`, `.captureFace` | Native identity image camera/gallery, address file/camera, guided selfie capture; attachment cache and local review | Upload actual bytes and submit server asset IDs; local paths cannot be backend references |
| `BiometricGateway.authenticate(reason)`, `.cancel()` | `local_auth` device prompt | Keep device authentication local; backend session authorization must be independently valid |
| `DavochainDashboardScreen.onRefresh` / `DavoDashboardContent.onRefresh` | Optional `Future<void> Function()`; fallback waits 700 milliseconds and rebuilds | Load account-scoped authoritative dashboard data; animation completion does not create financial facts |
| Wallet scanner gateway/address parser | Camera scan and local format checks | Server validates supported network, address/checksum, memo requirements and transfer eligibility |

`SettingsGateway`, `LinkedBank`, `SupportTicket`, `RewardRedemption` and `DeletionRequest` live in `lib/core/preview/settings_preview_session.dart`. Reusable model fields today:

- `LinkedBank`: `bank`, `number`, `name` (strings).
- `SupportTicket`: `reference`, `subject`, `message`, `orderId`, `createdAt`, `channel` (`email`/`chat`), optional `conversationId`.
- `RewardRedemption`: `reference`, integer `points`, integer `creditKobo`, `createdAt`.
- `DeletionRequest`: `reference`, `reason`, `createdAt`.

### Local state that must not become backend authority

- `LocalPreviewProfile` is a process-local display identity and sample avatar/photo bytes. Registration/login reset other local sessions; these do not authenticate users or load server accounts.
- `PreviewAuthState` stores display email, separate app-unlock/payment fingerprint flags, a process-local sample or user-entered PIN, and a payment retry counter/lock deadline. It never persists the PIN and is not secure credential storage or server authorization. The sample account PIN is `1234`; registration stores its confirmed PIN for that preview session only.
- `PreviewAccountState` holds `setupComplete`, eleven notification booleans, three channel preference rows and a set of notification titles marked read. Persist actual read state by notification ID, not title.
- `SettingsPreviewSession` contains sample bank accounts, locally accumulated tickets/redemptions, sample earned points (`15`), and a local deletion request.
- `VerificationSession.basicVerified` currently aliases `basicSubmitted`. `submitAdvanced()` sets address completion locally. These are presentation progression flags, not provider approval. Separate submission/review/approval before granting financial permissions.
- `PreviewTransactionOperation.buy()` and `.transfer()` return delayed local `submitted` outcomes. They make no payment request.
- `ReceiptActivity.submitPreview()` creates pending receipts and simulates completion after **20 seconds**. `accept()` accepts provider facts without starting that timer. Production records must use server status and `preview: false`; never run real orders through the simulated lifecycle.
- `FundingActivity` is a local feed, not a ledger or deposit poller. Copying or sharing receiving bank/address details must not create a deposit record. A deposit exists only after the server receives a legitimate provider/chain event.
- `FundingActivity.accept()` and `ReceiptActivity.accept()` currently prevent completed records from regressing. Reversal, refund and chain-reorganization states require an agreed model and mobile mapping; silently mapping a reversal to `failed` will not reliably update the current feed.

The architecture review in `docs/reviews/2026-10-08-architecture-research-review.md` recommends defining domain/repository boundaries and API contracts before choosing an HTTP/state-management stack. Existing KYC inventories and old Tier screens in `profile_settings_flow.dart` include staged/legacy paths; the profile menu currently opens `VerificationOverviewScreen`. Use current Basic/Advanced source as the integration baseline, and resolve duplicated limits/verification copy with product.

## 4. Cross-cutting API contract

### Identity, authentication and authorization

Use immutable opaque `user_id`, `session_id`, `wallet_id`, `bank_account_id`, `transaction_id`, `verification_case_id`, `upload_id`, `notification_id`, `ticket_id` and `conversation_id`. Email, phone, username, account number and display name are attributes, not primary identities. Scope every read/write to the authenticated account and verify referenced object ownership.

Recommended transport contract: TLS, versioned API prefix (for example `/v1`), bearer access token, short-lived access-token expiry plus rotating/revocable refresh tokens. Final mechanism is a joint mobile/backend decision; document token lifetimes, refresh concurrency, rotation replay handling, logout and all-device revocation. The app needs a secure-storage/session integration; do not embed privileged provider keys in Dart or build-time environment values.

Model pre-authentication as a restricted flow: registration ID or short-lived onboarding token; login challenge ID if extra proof is required; password/PIN/security-question reset grant with explicit purpose and expiry. An OTP or answered question alone must not authorize an unrelated transaction. Return `next_action` and eligible challenge types, rather than asking mobile to guess account status.

Server determines KYC eligibility, suspended/deletion state, transaction limits, recipient eligibility and risk decisions. Biometric success unlocks local UI or protected credentials; it is not a backend-issued access token and does not transmit fingerprint/Face ID templates. If device-bound signing or attestation is desired, supply its exact enrollment/challenge protocol separately.

### Transaction PIN and fingerprint handoff

The implemented `FingerprintSettingsScreen` separates app unlock from payment confirmation. Existing enabled app unlock is preserved when opening settings; payment confirmation starts off and requires a successful device prompt before enabling it. `TransactionPinEntryScreen` compares the session PIN, warns after four incorrect payment PINs, and pauses payments for one hour after the fifth. Cancellation, unavailable biometrics and device errors leave PIN entry available. An active payment lock blocks both PIN and fingerprint payment confirmation while valid PIN app unlock remains available. Generation and route checks discard stale device results, and confirmation callbacks run once. Logout, account switching and new preview sessions clear this local state. These are preview behaviors, not authoritative financial controls.

The following are **proposed integration requirements**, not existing endpoints or deployed contracts:

- Authoritative PIN verification must run on the backend under the authenticated immutable account/session identity and a specific transaction or quote. Return an explicit result such as `verified`, `incorrect_pin`, `payment_locked` or `additional_proof_required`, with the remaining attempt count and server-owned lock state. An accepted proof must be short-lived, single-use and bound to the exact operation, amount/currency, recipient and quote version; never accept a client `confirmed: true` or local biometric boolean as authorization.
- Keep payment retry counters and locks durable and account-scoped across devices, process restarts, logout/login and concurrent requests. Atomically count the fifth failed verification and enforce the payment-only one-hour lock. Return `locked_until` as a UTC ISO-8601 timestamp and `server_time` so mobile can display remaining time; the server decides expiry. Reject every execution path while locked, including biometric authorization paths. This policy does not itself suspend the account or terminate its session.
- PIN recovery needs a real server-created recovery challenge, verified delivery/proof, expiration, resend/attempt limits, and a single-use grant restricted to PIN replacement. Define whether verified recovery clears the payment lock and counters; the current preview save clears both. Arbitrary four-digit recovery input is insufficient. PIN creation/replacement and successful payment authorization must return updated authoritative retry/lock state. Never log PINs, recovery codes or authorization proofs; never persist the preview PIN as a production credential.
- If fingerprint payments are supported, design a device-bound key enrollment and signed challenge protocol. After independently authenticated enrollment, store the private key in the platform's protected key storage, with required biometric access control. The server supplies an unpredictable expiring challenge bound to account/session, enrolled device key and exact transaction details; the device signs only after biometric consent, and the server verifies the signature, binding, expiry, replay prevention, revocation and risk rules. `local_auth.authenticate()` alone does not produce that signature or establish a server trust relationship. No fingerprint templates should be collected or transmitted.
- Persist app-unlock and payment-confirmation preferences separately. Scope sensitive local preferences to the account/device and store session tokens/keys through appropriate platform secure storage; define enrollment status and server preference synchronization where supported. Enabling a switch must not enroll a trusted server key implicitly. Disabling payment fingerprint, device removal, credential changes and account revocation need agreed key revocation/session invalidation rules. Clear account-specific cached state on sign-out and ignore stale responses after a session changes, while retaining the server's authoritative retry lock.

Replace the local transaction gate with a repository that consumes authoritative PIN verification, recovery and lock responses and hands operation-bound proofs to payment execution. The existing `VoidCallback onConfirm` only advances preview UI; it cannot carry production authorization. Contract tests should cover wrong PIN concurrency, fourth-attempt warning, fifth-attempt lock, lock expiry, no biometric bypass, cancellation/error fallback, secure recovery, revoked keys, replayed challenges, stale account responses and repeated confirmation taps.

### Money and quotes

- Represent fiat values as integer minor units with explicit currency and scale: `{"currency":"NGN","minor":"1000000","scale":2}` means NGN10,000. Use integer/string JSON values consistently; decimal strings avoid JavaScript numeric range issues.
- Represent crypto as an exact decimal string or integer atomic units plus explicit asset/network decimals. Include precision metadata in the asset/network catalog. Do not reuse `double` arithmetic from `BuyCryptoOrder` or `FundingRecord` in financial execution.
- `NGD` (Davochain Naira) is a separate wallet option in the app. Specify issuer, backing, spendability, conversion/redemption, transferability, scale, fees and NGN relationship. Do not silently identify NGD with NGN because both show the Naira symbol.
- Current crypto fixture assets are BTC, ETH, SOL, USDT; rates, USD conversion (`1463.08`) and USDT rate (`1540`) are examples. Backend supplies prices, timestamp/source, supported markets and asset-network combinations.
- Return gross amount, debit amount, net amount, fee components/currencies, quote rate and expiry. Define fee-inclusive/exclusive input, min/max amounts, rounding mode, dust handling and insufficient funds treatment.
- Executions consume an immutable `quote_id`, selected wallet/recipient and transaction authorization proof. Backend recalculates/enforces totals. Expired/repriced quotes require another explicit user review; do not execute a different amount silently.
- Balances distinguish available, held/pending and total. A held balance during a pending payout is not an additional debit. Commit ledger changes atomically, reconcile with providers and maintain an auditable ledger.

### Status and timing

Return UTC ISO-8601 timestamps (`created_at`, `updated_at`, `completed_at`, `expires_at`) and date-only DOB (`YYYY-MM-DD`). Mobile formats local display. Do not use phone time as receipt truth.

Proposed transaction server statuses: `accepted`, `processing`, `awaiting_confirmation`, `completed`, `failed`, `cancelled`, `reversed`, `refunded`. Current receipt UI only supports `pending`, `completed`, `failed`; agree an adapter and extend UI for other meaningful states. `accepted`/`processing`/`awaiting_confirmation` map to pending; distinguish final failure from a recoverable transport timeout.

Proposed KYC states per check/tier: `not_started`, `draft`, `submitted`, `in_review`, `approved`, `rejected`, `action_required`, `expired`. Include user-safe rejection reason, actionable field/media requirements, submission version and allowed next actions. Account approval and one verified document are distinct states.

### Idempotency, concurrency and pagination

Require `Idempotency-Key` for value-moving operations (trades, withdrawals, internal sends, giftcard orders, reward redemption) and non-repeatable submissions. Scope it to account and operation, bind to canonical request content, retain it for a documented retry window, return the original outcome on identical replay and reject changed payloads under the same key. Status retrieval must recover an accepted operation after a timeout. Multiple taps, resumed apps and provider retries must never double-charge.

Use optimistic resource versions/ETags for contested profile/preferences/draft changes where needed. A stale response from an old login must not update the new account. Server events include resource version/sequence to prevent out-of-order status rollback.

List responses: `{"data":[],"page":{"next_cursor":null,"has_more":false},"request_id":"..."}`. Supply stable cursor ordering with an ID tie-breaker, maximum/default page sizes and filter semantics for transactions, notifications, tickets, messages, reward entries and referrals. Avoid returning unbounded histories. Document null versus omitted fields and backward-compatible additions.

### Errors and transport behavior

Suggested error response:

```json
{
  "error": {
    "code": "QUOTE_EXPIRED",
    "message": "This rate has expired. Review a new quote.",
    "field_errors": {},
    "retryable": false,
    "retry_after_seconds": null
  },
  "request_id": "req_example"
}
```

Document `400` malformed input, `401` expired/invalid session, `403` forbidden/eligibility, `404` absent/inaccessible resource, `409` conflicting/stale/idempotency state, `422` validation, `429` throttling and `5xx` upstream/server faults. Supply machine codes for incorrect OTP/PIN/answer, expired challenge, duplicate username/bank, unsupported network, quote expired, insufficient balance, limit exceeded, KYC required/rejected, provider unavailable, upload invalid and deletion blocked. Return server retry deadlines for countdowns. Never return answer hashes, OTP values, PINs, passwords, provider credentials or internal stack traces.

Specify connect/read/upload timeout budgets and retry policy. A timeout after execution is **unknown outcome**, so the mobile client queries the same transaction/idempotency key instead of creating a new operation. Cancellation of a request or closing a screen does not mean a provider transaction was cancelled.

## 5. Proposed endpoint inventory

All paths below are relative proposals under `/v1`. Consolidate them if the backend architecture benefits, while preserving capabilities and outcomes. `GET` catalog/config calls may be public or authenticated as documented; all account operations need authenticated or narrowly scoped onboarding/recovery authorization.

### Auth, onboarding and session security

| Proposed method/path | Request essentials | Response essentials |
|---|---|---|
| `GET /onboarding/config` | App/platform/version if needed | Allowed country `NG`, phone/password policies, consent document versions, enabled auth methods |
| `POST /auth/registrations` | Full name, email, E.164 phone, country, password, optional referral, consent versions | Registration ID/onboarding token, verification requirements and next action |
| `POST /auth/challenges` | Purpose (`verify_email`, `verify_phone`, recovery), channel and scoped registration/account context | Challenge ID, masked destination, expiry and resend deadline; no OTP |
| `POST /auth/challenges/{id}/verify` | Code and scoped token | Verified purpose and next action or one-use grant |
| `POST /auth/challenges/{id}/resend` | Scoped token | New/reused challenge semantics and server cooldown |
| `POST /auth/login` | Email/password and device metadata | Tokens/account state or restricted login challenge; no full session before required proof |
| `POST /auth/login/challenges/{id}/verify` | Required answer/proof | Session tokens and account snapshot |
| `POST /auth/token/refresh` | Refresh token/device binding | Rotated tokens and expiry |
| `POST /auth/logout` | Session scope | Revoked result; retries safe |
| `POST /auth/password-resets` | Email | Generic acknowledgment and recovery challenge context that avoids account enumeration |
| `POST /auth/password-resets/confirm` | Verified challenge/grant and new password | Reset outcome, session revocation/reauthentication requirement |
| `POST /me/password/change` | Current/new password; step-up if required | Changed timestamp and session policy |
| `GET /me/security` | None | PIN/questions enrollment, device/session policy, crypto preferences |
| `POST /me/transaction-pin` | PIN and enrollment grant/proof | Enrollment result; never return PIN |
| `POST /me/transaction-authorizations` | PIN or supported proof plus quote/operation binding | Short-lived, single-purpose authorization token or failure/lock deadline |
| `POST /me/pin-reset-challenges` / `POST /me/pin-resets` | Recovery purpose/channel; then proof grant/new PIN | Challenge metadata; then reset outcome |

The exact split of registration/password submission must support the current multi-screen flow without persisting a half-authenticated account as fully usable. Nigeria phone input is ten national digits without leading zero at signup; transport should normalize to `+234...`. Do not require the display string including spaces. Password and PIN policy must be supplied rather than inferred from screen criteria.

Current email/SMS verification and forgotten-password screens use four-digit codes; transaction PIN setup/reset uses four digits, with reset delivered by email or SMS in the UI. Security-question reset separately uses six-digit fixture codes. Publish challenge-specific code length/alphabet/expiry/resend/attempt policy and align frontend validation accordingly; a generic OTP schema must not accidentally make these distinct flows incompatible. All checks must happen on the server even if local forms already validate length.

### Security questions

| Proposed method/path | Contract |
|---|---|
| `GET /security-question-options` | Stable default question IDs/text, custom-question policy |
| `GET /me/security-questions` | Enrollment flag and three selected question labels/IDs; never answers |
| `POST /me/security-questions` | Exactly three distinct question/answer entries, authenticated proof; reject overwrite of existing enrollment |
| `POST /me/security-questions/reset-challenges` | Real email challenge with expiry/cooldown |
| `POST /me/security-questions/reset-challenges/{id}/verify` | Code; issue one-use, enrollment-version-bound replacement grant |
| `PUT /me/security-questions` | Replacement grant plus validated new entries; atomic replacement/invalidation |

Existing service canonicalizes trim/collapsed whitespace/lowercase, allows answers of 3–120 characters, selects one random enrolled question for login, locks after five failed answers for 30 seconds, uses six-digit reset codes with five-minute expiry, 30-second resend and five-minute replacement grants. **These are implemented fixture behaviors to align or revise, not production policy.** Backend needs slow salted hashing, account/challenge/risk-aware throttling, constant-time verification as appropriate, cancellation/expiry/replay rules and no answer disclosure. The local SHA-256 construction is not a production password/answer-storage design. Confirm whether security questions remain a required login factor and which stronger recovery routes are supported.

### Profile, bank accounts, preferences and deletion

| Proposed method/path | Contract |
|---|---|
| `GET /me` | User ID, names, email/phone verification, country, username, DOB, address, avatar, account state, KYC summary and next actions |
| `PATCH /me/profile` | Editable fields only, version; return canonical profile and restricted/verification-required fields |
| `GET /usernames/availability?username=...` | Availability/validation policy; final write still atomically enforces uniqueness |
| `POST /me/avatar` or scoped upload finalization | Uploaded media ID; return authorized avatar URL/version |
| `GET /banks?country=NG` | Stable bank codes/names, availability; display logo mapping can stay mobile-owned |
| `POST /bank-account-resolutions` | Bank code and ten-digit account number; return resolution ID/name/expiry |
| `GET /me/bank-accounts` / `POST /me/bank-accounts` | Durable linked accounts; link via resolution ID/proof, enforce ownership and duplicates |
| `GET /me/limits` | Per operation/currency/tier limits, spent/remaining, reset time/timezone, eligibility and upgrade requirements |
| `GET /me/preferences` / `PATCH /me/preferences` | Stable keys for notification/privacy/security preferences, version and enforced policy |
| `POST /me/deletion-requests` / `GET /me/deletion-requests/{id}` | Reason/proof, reference, requested state, blockers, retention explanation and closure timeline |

The source has linked-account screens in settings and a separate withdrawal bank form/model (`BankAccount`) in crypto. Both must use one canonical server bank-account record/catalog. Bank removal is not established by the inspected journey; add a deletion endpoint only if product defines removal/default-account behavior.

Profile fields in local source include first/middle/last names, username, phone, DOB, residential address and Nigerian state used by profile completion, and display full name/email/country. Confirm which verified fields are immutable and how corrections trigger re-verification. Do not accept client `basicVerified`, `identityVerified` or equivalent approval flags.

### KYC and upload lifecycle

| Proposed method/path | Contract |
|---|---|
| `GET /me/verification` / `GET /verification/requirements` | Per-tier/check state, latest cases, required documents/sides/form fields, allowed file types and next steps |
| `PUT /me/verification/profile` | Personal-information draft with validation and version |
| `POST /me/verification/basic` | Method `nin`/`bvn`, eleven-digit identifier and required profile/consent; return case ID and submission/review state |
| `POST /uploads` | Purpose, filename, MIME, byte size, checksum; return scoped upload ID, upload mechanism/URL and expiry |
| `POST /uploads/{id}/complete` | Checksum/content completion; return validated/quarantined/ready state |
| `POST /me/verification/identity` | Document type, front/back media IDs where required, selfie ID and case/version; return review state |
| `POST /me/verification/address` | Address/document type/media ID and case/version; return review state |
| `GET /me/verification/cases/{id}` | Current case status, checks, reasons and required resubmissions |

Current Basic journey requires completed personal profile then NIN or BVN with exactly eleven digits; local state only retains identifier last four. Advanced current source proceeds through government ID upload, guided selfie/matching, and proof of address. ID choices: National ID card, international passport, driver's licence. Address choices: utility bill, bank statement, government document, tenancy agreement. Backend must specify required ID sides per type; current `identityDocumentsAdded` only checks the front, so a mandatory back side needs frontend gating too.

The native media gateway captures/picks actual attachments. `pickIdentity` uses camera or gallery and is image-only (`allowPdf: false`); `pickDocument` for address evidence supports JPG/PNG/PDF file selection or camera capture; `captureFace` opens guided native selfie capture. Local attachments expose `path`, `name`, `bytes`, `kind`, optional PDF preview path and ownership/cleanup metadata. Current validation accepts JPG/PNG/PDF signatures by context, rejects empty or above 5 MiB, and rejects images above 24 megapixels. Preserve or deliberately revise these limits with server enforcement. The backend receives original content, not local filesystem paths, UI preview thumbnails or boolean `uploaded` flags.

For uploads supply permitted methods/headers, content length, progress expectations, expiring URLs, retry/refresh, ownership checks, checksum verification, content sniffing, scan/quarantine, abandoned-upload cleanup and safe download authorization. Do not expose public KYC/giftcard/student-ID buckets. Store documents encrypted with least-privilege reviewer access and retention/deletion/audit policies. Strip unnecessary metadata; redact identity numbers and image contents from logs, analytics, crash reports and push payloads.

Device face guidance/ML detection improves capture quality; it does not establish liveness, identity matching or approval. Specify provider session tokens, challenge/liveness evidence, SDK requirement, confidence/risk policy and manual-review fallback if those checks are required. Do not ship provider secrets. Document consent, processing locations and who can view/export biometric/identity content.

### Wallets, deposits and payouts

| Proposed method/path | Contract |
|---|---|
| `GET /assets` / `GET /assets/{id}/networks` | BTC/ETH/SOL/USDT availability, stable network IDs, decimals, min/max, fees, address/memo policy, confirmations, deposit/withdraw enablement |
| `GET /me/wallets` / `GET /me/portfolio` | NGN/NGD/crypto wallets, exact available/held/total quantities, fiat valuation timestamp and allocation |
| `GET /me/dashboard` (optional aggregation) | Consistent balance/wallet/portfolio summary, account setup/KYC capabilities, unread count and latest relevant activity with snapshot timestamps/version |
| `GET /market/prices` | Price pairs, exact rate strings, timestamp, stale/availability indicator |
| `GET /me/deposit-accounts?currency=NGN` | Assigned bank code/name, account name/number, assignment state and instructions |
| `POST /me/deposit-addresses` | Asset/network IDs; return assigned address, optional memo/tag, confirmations/instructions and expiry if any |
| `GET /me/deposits` / `GET /me/deposits/{id}` | Real provider-backed deposit records and confirmation/review status |
| `POST /withdrawal-quotes` | Source wallet, fiat amount and linked bank-account ID; return fees/net/debit/limits/expiry |
| `POST /withdrawals` | Quote ID, authorization proof, idempotency key; return accepted transaction/status |

Do not credit balance when bank details are displayed, address copied, QR shown or a user claims to have paid. Bank/chain provider event processing validates the receiving account, amount, currency, unique event, confirmations and eligibility before ledger credit. Supply deposit minimums, unsupported asset/network behavior, recovery process, smart-contract deposit policy and risk-hold behavior; current deposit guidance is static copy and requires provider/product confirmation.

The rotating pull-to-refresh is currently used on Dashboard through `DavoFloatingRefresh`; additional placements are not implemented by this handoff. Choose one aggregation endpoint or coordinated wallet/profile/price/activity reads with a defined consistency/as-of policy. Return per-section freshness and actionable errors when part of the aggregate fails; retain last-known data with its timestamp rather than substituting fixture balances. Rate-limit/coalesce repeated refreshes and avoid overlapping stale responses. The animation's minimum turns/duration is UI feedback only: it neither determines provider completion nor authorizes a balance update. History, portfolio, notifications and gift catalog can later reuse refresh behavior when their API data is integrated.

### Crypto trade and send

| Proposed method/path | Contract |
|---|---|
| `POST /trade-quotes` | Operation `buy`/`sell`/`convert`, source wallet/asset, destination asset/wallet and exact input amount |
| `POST /trades` | Quote ID and authorization proof; return accepted transaction and fulfillment status |
| `POST /transfer-recipients/resolve` | Davochain username; return scoped recipient ID/minimal display identity and eligibility |
| `POST /crypto-withdrawal-quotes` | Asset/network/wallet, exact quantity, external address and memo if required; validate/screen server-side |
| `POST /crypto-withdrawals` | Quote ID, authorization proof and idempotency key; return transaction/provider status/hash when known |
| `POST /internal-transfer-quotes` / `POST /internal-transfers` | Source wallet/quantity/resolved recipient; then quote/proof/idempotency key |

Current `TxKind` is `internal`, `external`, `sell`, `conversion`. Internal send is to a Davochain username; it is not a generic fiat beneficiary/contact flow. External screens select networks and show network/sanction warnings; local address parsing supports Bitcoin/Ethereum/Solana/Tron URI forms and some EVM chain checks. That parser is only a format check. Backend must validate real supported asset/network combinations, checksums, destination restrictions, sanctions/risk decisions and memo requirements. Never trust a warning acknowledgment to clear server risk checks.

Fixture internal transfers advertise zero fees and external transfers use example fees. Confirm fee rules, wrapped BTC/BEP20 support, Tron/ERC20 USDT support and Solana behavior from the actual custody/provider capability; do not derive supported custody solely from the UI dropdown. Supply blockchain confirmations, transaction hash/explorer metadata, broadcast/retry policy and reorganization handling. Protect against duplicate provider broadcast on retried jobs.

### Gift card catalog, sell review and buy fulfillment

| Proposed method/path | Contract |
|---|---|
| `GET /gift-card-brands` / `GET /gift-card-products` | Stable IDs, name/category, buy/sell availability, country/currency, physical/e-code, denominations/quantity bounds, subcategory and artwork |
| `POST /gift-card-quotes` | Buy/sell, product/subcategory, face-value currency/amount, quantity, funding/payout wallet; exact rate/fee/net/expiry |
| `POST /gift-card-sales` | Quote ID, physical/e-code evidence media IDs/secure code fields, accepted terms; accepted review transaction |
| `POST /gift-card-orders` | Quote ID, funding wallet, delivery type/recipient details, proof/idempotency; accepted order |
| `GET /gift-card-orders/{id}` | Review/payment/fulfillment status, timeline, delivery result and safe remediation |
| `GET /gift-card-orders/{id}/delivery` | Authenticated, ownership-checked access to purchased sensitive code/content where product permits |

Current catalog fixtures: Amazon, iTunes/Apple, Google Play, Steam, Walmart, Razer Gold, eBay, AMEX gift cards; categories all/shopping/gaming/streaming/food. Selling uses physical/e-code, selected subcategory/country/face value and an upload flag. Some country/subcategory/rate values are hardcoded (for example France, `865` NGN per unit); uploaded sell evidence is not a completed native upload integration. Backend must deliver real inventory and acceptance rules before submission is reliable.

Buying includes amount/quantity, For Me/Send Gift, email, optional phone and Instant Delivery/Email Delivery before payment/PIN. **Integration gap:** `GiftCardDeliveryScreen` currently passes only brand/amount/quantity to `GiftCardBuyReviewScreen`; delivery email/phone/mode are not propagated. Introduce a typed order draft that carries validated delivery fields through review, payment and execution. Define email/recipient schema and allowed destinations from product/provider. Supply unavailable inventory, rate changes, review rejection, partially fulfilled quantity, failed delivery, retry/resend and refund states. Never mark a sale completed before accepted review plus payout, or a purchase fulfilled merely because payment was accepted. Gift-card codes are sensitive, must not appear in general history, push payloads or unprotected receipt exports.

### Transactions and receipts

| Proposed method/path | Contract |
|---|---|
| `GET /me/transactions` | Cursor, type/status/asset/date filters; canonical transaction summaries |
| `GET /me/transactions/{id}` | Durable transaction facts, fees/parties, status/version, server events/timestamps, funding/trade/order identifiers |
| `GET /me/transactions/{id}/receipt` | Structured receipt-safe facts with sensitivity metadata, if separate from detail resource |

Existing `ReceiptRecord`: `id`, `reference`, string `type`, `ReceiptStatus`, `occurredAt`, formatted `amount`, explicit `assets`, `ReceiptField[]`, `ReceiptEvent[]`, `preview`. Fields carry `label`, `value`, `sensitive`, `copyable`; events carry `label`, `description`, optional `occurredAt`, `state` (`complete`, `current`, `upcoming`). Backend should return typed amounts/parties/fees; mobile converts them into presentation labels rather than parsing formatted receipt strings.

Existing `FundingRecord`: ID, direction/status, amount/currency/destination, timestamp, optional network/reference/hash/bank/account-number/name, fee and preview marker. Align this with canonical transaction DTOs to avoid unrelated IDs between outcome, details, history, support and receipts. Supply both opaque ID and customer-friendly reference; no phone-clock-generated `receiptDemoId` for real operations.

Receipt styles (standard/celebration/appreciation/birthday), optional 240-character note and sensitive reveal/export toggle are presentation choices. PDF/image export and sharing already run locally in `lib/shared/services/receipt_export_service.dart`; a server PDF endpoint is not required by current implementation. Decide whether notes/styles persist; avoid adding an unnecessary mutation if they remain local. Agree safe sensitive-field defaults and that a receipt is a snapshot of server facts, not proof that a still-pending transaction settled.

### Notifications, support, content and rewards

| Proposed method/path | Contract |
|---|---|
| `GET /me/notifications` / `PATCH /me/notifications/{id}` | Categories all/transactions/security/rewards; ID/title/body/timestamps/read-at and allowlisted target resource |
| `POST /me/push-devices` / `DELETE /me/push-devices/{id}` | Platform/provider token, install ID and consent; safe replacement/revocation on logout |
| `GET /support/topics` / `GET /content/{key}` | FAQ/help/about/privacy/terms versions and approved support destinations |
| `POST /me/support/tickets` / `GET /me/support/tickets` / `GET /me/support/tickets/{id}` | Subject/message/optional owned transaction ID, channel, reference/status/time and reply data |
| `POST /me/support/conversations` / `GET /me/support/conversations` | Conversation ID, channel/topic/status and last-message summary |
| `GET /me/support/conversations/{id}/messages` / `POST /me/support/conversations/{id}/messages` | Cursor, message ID/sender role/body/server time/delivery state; client message ID for deduplication |
| `GET /me/rewards` / `GET /me/reward-entries` | Earned/redeemed/available points, credited wallet money, policy version and ledger entries |
| `POST /me/reward-redemptions` | Integer points, wallet and authorization if required; atomic debit/credit result/reference |
| `GET /me/referrals` / `GET /me/referrals/invitees` | Owned referral code/real share link, qualification counts/status, safe invitee display data and rewards |
| `POST /me/ambassador-applications` / `GET /me/ambassador` | School, student ID and uploaded student-ID asset; review/enrollment/tier/statistics |
| `GET /ambassadors/leaderboard` | Period/scope/rank, consent-safe display names/avatar/school/referral metrics and cursor |

Notification category keys must cover the eleven existing preferences: crypto purchases/sales/swaps, deposits, withdrawals, gift-card transactions, security alerts, login activity, promotions, product updates, tips/education. Channel preferences use push/email/SMS in UI; define precedence with OS permission and mandatory security notices. Privacy fields include contact access, personalization, marketing and analytics; distinguish legal/account consent from device permissions and enforce applicable server-side behavior.

Support chat today stores locally generated tickets/messages and does not receive real agent replies. Specify message delivery/read policy, reconnect, moderation, hours/SLA and any attachment requirements; current support contract does not establish attachment uploads. Bind `orderId` to a real transaction owned by the requesting account. No outgoing support email from the user's device is needed merely because the screen is named Email Support; select and document backend delivery semantics.

Points preview gives `5` kobo per point. Referral copy advertises a successful NGN50,000 transaction and 2,000 points for both parties, while sample analytics use unrelated fixed counts. Treat these as policy questions: qualification event, exclusion/refund reversal, fraud prevention, lifetime cap, expiry, minimum redemption, conversion rate and tax/accounting treatment. Student-ID upload currently only changes a boolean and submits to a local dashboard; it requires a real upload and reviewed application, not automatic enrollment.

The giftcard referral banner now opens the existing `ReferralDashboardScreen` and uses neutral referral copy. The destination still contains sample reward copy (including a Naira reward headline versus points in its how-it-works text). Backend/product must publish one authoritative campaign definition with reward asset/amount, qualification terms and effective version, and render every entry point consistently from that policy.

## 6. Asynchronous integrations and operational ownership

### Provider webhooks (backend-only)

Implement vendor-specific signed webhook consumers for bank deposits/payouts, crypto custody/chain confirmations, KYC review, gift-card fulfillment/review and support/reward events where applicable. The Flutter app is not a webhook endpoint and must not possess vendor signing secrets.

For each integration supply signature/timestamp verification, replay window, unique event ID storage, durable queue, retries/dead-letter/manual replay, out-of-order handling, ledger transaction linkage and reconciliation. Acknowledge only after durable acceptance; make processing idempotent. Document which event conclusively means funds/fulfillment are completed versus accepted/authorized/broadcast.

### Mobile state updates

Choose authenticated polling, SSE or WebSocket updates; push can signal an update but must not serve as sole ledger truth. Supply access/refresh/reconnect protocol, resource scopes, event ID/cursor, heartbeat/backoff, resource versions and missed-event recovery. Suggested envelope:

```json
{
  "event_id": "evt_example",
  "type": "transaction.updated",
  "resource_id": "txn_example",
  "resource_version": 3,
  "occurred_at": "2026-10-13T10:00:00Z",
  "data": {"status": "completed"}
}
```

Mobile refreshes the authoritative detail/balance after an event, checks current session/account and deduplicates receipt/outcome presentation. Recover pending transactions after process termination, backgrounding, offline periods or missing push permission. Updates must apply to history/details/receipt and wallet consistently. Never substitute the existing 20-second timer for provider confirmation.

### Administration and operations

Backend needs reviewer tools or documented processes for KYC action-required/rejection, giftcard disputes, failed/stuck payouts, deletion requests, support responses, reward/referral corrections and ambassador applications. These are operational requirements behind implemented screens, not a request to add an admin app to this Flutter repository. Record privileged decisions with actor, reason, timestamp and previous/new state.

Provide request/transaction correlation IDs, redacted structured logs, queue/provider health, pending-age/reconciliation alerts and safe support lookup by customer reference. Define backup/recovery objectives, data retention and access auditing with the responsible business/operations team.

## 7. Example request/response shapes

These examples demonstrate proposed types, not complete schemas or available APIs. Identifiers and amounts are synthetic.

### Login with an additional question

```json
{
  "email": "person@example.test",
  "password": "<entered password>",
  "device": {"installation_id": "install_example", "platform": "android"}
}
```

```json
{
  "next_action": "security_question",
  "login_challenge": {
    "id": "challenge_example",
    "question": "What was your childhood nickname?",
    "expires_at": "2026-10-13T10:05:00Z"
  },
  "request_id": "req_example"
}
```

Only successful required proof returns access/refresh credentials. Store and log neither password nor answer in request diagnostics.

### Account snapshot

```json
{
  "id": "user_example",
  "version": 7,
  "profile": {
    "first_name": "Ada", "middle_name": null, "last_name": "Example",
    "email": "person@example.test", "email_verified": true,
    "phone": "+2348012345678", "phone_verified": true,
    "country": "NG", "username": "ada_example", "date_of_birth": "1996-08-24",
    "address": {"line1": "Example address", "city": "Abuja", "state": "FCT", "country": "NG"},
    "avatar_url": null
  },
  "account_status": "active",
  "verification": {"basic": "in_review", "advanced": "not_started"},
  "security": {"pin_enrolled": true, "security_questions_enrolled": true},
  "capabilities": {"buy_crypto": false, "withdraw_ngn": false},
  "next_actions": ["await_basic_review"]
}
```

Capability examples are illustrative; product/backend must establish the actual permission rules.

### Quote followed by accepted execution

```json
{
  "operation": "buy",
  "source_wallet_id": "wallet_ngn_example",
  "destination_asset_id": "btc",
  "input": {"currency": "NGN", "minor": "1000000", "scale": 2}
}
```

```json
{
  "id": "quote_example",
  "expires_at": "2026-10-13T10:01:00Z",
  "input": {"currency": "NGN", "minor": "1000000", "scale": 2},
  "debit": {"currency": "NGN", "minor": "1000000", "scale": 2},
  "output": {"asset_id": "btc", "quantity": "0.00041666", "decimals": 8},
  "fees": [{"type": "trade", "currency": "NGN", "minor": "0", "scale": 2}],
  "rate": {"base": "BTC", "quote": "NGN", "value": "24000000", "as_of": "2026-10-13T10:00:00Z"}
}
```

Execution body: `{"quote_id":"quote_example","authorization_token":"proof_example"}` with the same `Idempotency-Key` on retries. Example accepted response:

```json
{
  "id": "txn_example", "reference": "DC-EXAMPLE", "type": "crypto_buy",
  "status": "processing", "version": 1,
  "created_at": "2026-10-13T10:00:10Z", "completed_at": null,
  "source_wallet_id": "wallet_ngn_example", "quote_id": "quote_example",
  "input": {"currency": "NGN", "minor": "1000000", "scale": 2},
  "output": {"asset_id": "btc", "quantity": "0.00041666", "decimals": 8},
  "events": [{"code": "accepted", "occurred_at": "2026-10-13T10:00:10Z"}],
  "failure": null
}
```

### Verification submission

```json
{
  "document_type": "national_id",
  "front_upload_id": "upload_front_example",
  "back_upload_id": "upload_back_example",
  "selfie_upload_id": "upload_selfie_example",
  "profile_version": 7,
  "consent_version": "kyc-example"
}
```

```json
{
  "id": "case_example", "tier": "advanced", "status": "in_review", "version": 1,
  "submitted_at": "2026-10-13T10:00:00Z",
  "checks": {"identity": "in_review", "face": "in_review", "address": "not_started"},
  "required_actions": [], "reason": null
}
```

### Support and rewards

Support create input: `{"subject":"Withdrawal question","message":"Please review my withdrawal.","transaction_id":"txn_example","channel":"email"}`. Return durable ticket ID/reference, status, timestamps and conversation ID when applicable. Message responses need independent IDs and sender roles; one ticket is not one whole chat transcript.

Reward input: `{"points":10,"destination_wallet_id":"wallet_ngn_example"}`. Return redemption ID/reference/status, integer points debited, exact credit money, reward policy version and updated available points. If credit is asynchronous, return pending and update the same redemption; never let local `points * 5` create spendable funds.

## 8. Delivery priorities and acceptance gates

| Priority | Backend package | Depends on | Acceptance gate |
|---|---|---|---|
| P0 | Contract schemas, environments, auth/session/error handling | Product identity and auth policy | Mobile can register, verify, sign in/reset, refresh and revoke without local fixtures |
| P0 | Profile, security/PIN, Basic KYC, limits/capabilities | Auth; identity vendor and approved eligibility rules | Server status survives restart and prevents unapproved operations |
| P0 | Ledger, wallets, bank catalog/linking/deposit assignment, transaction records | Currency/NGD policy; banking/custody accounts | Balances reconcile; real deposits/history share immutable IDs |
| P0 | Quote/execution/idempotency/provider events | Ledger; provider sandboxes | One accepted operation creates exactly one debit/fulfillment; timeout recovery proven |
| P1 | Buy/sell/convert and NGN/crypto withdrawal/internal send | P0; network/risk/fee policy | Each enabled path handles pending/completed/failed and returns receipt facts |
| P1 | Advanced KYC uploads and review | Secure storage; review provider/ops | Real media submission, pending/rejection/resubmission and permissions proven |
| P1 | Giftcard buy/sell catalog/payment/review/delivery | Providers; ledger; secure uploads | Inventory/rate/review/fulfillment/refund scenarios represented accurately |
| P1 | Preferences, notifications, push and support | Account data; delivery/support tools | Durable read/settings state, safe targets and real agent reply delivery |
| P2 | Rewards, referrals and ambassadors | Approved reward policy; fraud/review controls | Atomic redemption and deterministic qualification/reversal behavior |
| P2 | Managed help/legal content and deletion operations | Approved content; retention/closure policy | Versioned consent content and trackable deletion status |

Priorities are a proposed implementation sequence, not permission to expose incomplete financial journeys. Enable a journey only once its required contract/provider/policy gates are satisfied. If rewards/ambassadors/deletion are launch commitments, promote their priority rather than leaving sample success behavior in production.

Backend integration acceptance scenarios:

1. Signup email/phone duplicate/invalid inputs, unavailable referral, consent version mismatch, delivery failure, expired/wrong/replayed OTP, throttling and recovery across app restart.
2. Valid/invalid credentials, required question, expired/stale/replayed question/reset grants, account lock/suspension, concurrent refresh, logout, password-change revocation and account isolation.
3. PIN enrollment/reset/wrong-attempt lock and transaction proof binding; biometric cancellation/unavailability never fabricates a session or approval.
4. KYC draft/resume, rejected identifier, provider outage, pending/manual review, approved/action-required outcomes, missing ID side, wrong/large/corrupt media, upload interruption, replaced-document invalidation and account-scoped access.
5. Quote expires while review is open; unsupported pair/network, exact decimals/minimums, insufficient/held balance, concurrent spends, fee changes and limit reset boundaries.
6. Repeated taps/identical retries/reused key with changed payload, request timeout after provider acceptance, app termination, delayed/duplicate/out-of-order webhook and reconciliation after missed events.
7. Bank deposit only after verified event; payout provider failure; chain broadcast pending/confirmed/failed/reorg; internal recipient not found/self-send/suspended where policy applies.
8. Giftcard evidence review rejection, inventory unavailable, delivery failure/partial fulfillment and agreed refund/retry behavior; codes remain private.
9. Same transaction ID/reference/status across result, details, history, support and export; server timestamps and numeric facts remain unchanged by receipt style/note.
10. Cursor lists with empty/large history and consistent filters, duplicated event IDs, reconnect/missed-event recovery, old account response discarded after logout/login.
11. Notifications use IDs, preferences persist and opt-out behavior matches policy; unauthorized deep-link/resource access is denied; support messages persist and actual replies arrive.
12. Reward race/double redemption, invalid quantity, referral qualification/refund reversal and fraud hold; ambassador application is reviewed; deletion with pending funds/transactions follows an explicit policy.

Supply contract fixtures and sandbox controls for these scenarios. Frontend unit/widget tests and device QA are complementary; passing local UI tests does not certify a provider or ledger integration. This handoff was produced by source inspection; no Flutter/Dart commands or live backend tests were run for it.

## 9. Information, access and decisions required from backend/product

### Configuration and credentials delivery

- Real development/staging/production API origins; version prefix; realtime origin; TLS/network requirements and compatibility policy.
- Public mobile configuration names/values for API origin, environment, supported providers/features, upload limits and polling/realtime choice. Proposed names such as `API_BASE_URL` are not asserted to exist today.
- Auth/session specification, test accounts by KYC/security/balance state, sandbox OTP delivery/test mechanism, and reset controls. Production responses must never include the fixture `previewCode`.
- Provider sandbox access for authorized backend staff: banking/payout/account resolution, custody/chain, KYC/liveness and giftcard distribution/review. Keep all privileged credentials and webhook secrets server-side, delivered through approved secret management.
- Push project/app identifiers, Android/iOS registration setup, APNs/FCM server access held by backend and correct platform bundle/application mappings.
- Upload storage environment, allowed MIME/signatures, lifecycle rules, signed URL expiry and access/retention policy; no public bucket secrets in the app.
- Referral/share/deep-link domains and support/legal destinations; the current truncated example referral URL is not a usable production link.
- CI contract validation endpoint/spec artifact, release process, request-correlation access, provider event replay tooling and staging reset/seed procedure.

### Business and engineering decisions to close

| Decision | Why it blocks correct integration |
|---|---|
| Launch country/currencies and NGD definition | Current signup is Nigeria; USD marketing/sample text is broader than implemented capabilities |
| Actual supported assets/networks/pairs | Dropdowns and local regex are not proof that providers support deposits/withdrawals |
| KYC vendor, Basic/Advanced approval and permissions | Local submission currently looks verified; approved server checks must control capabilities |
| Verified field edits, DOB/age/address requirements and document sides | Prevents accepting invalid profile changes or incomplete identity evidence |
| Address document recency and review SLA | Current/legacy screens differ, including three- versus six-month bank-statement copy |
| Fee, spread, quote TTL, rounding, min/max and remaining limit windows | Review amounts and execution must agree; all fixture rates/fees need replacement |
| Deposit confirmations, smart-contract/memo support and risk holds | Receiving instructions, pending state and recovery depend on vendor behavior |
| PIN length/reset method, mandatory step-up and crypto security toggles | User toggles must not disable required server authorization |
| Security-question role and recovery policy | Existing local behavior must be replaced with account-scoped, throttled real checks |
| NGN payout ownership/default bank/removal behavior | Separate bank UIs need one consistent backend beneficiary model |
| Giftcard countries/denominations/e-code evidence, delivery and refund policy | Catalog, confidential code handling and fulfilled status need deterministic rules |
| Points conversion/expiry, referral qualification and reversal | Fixed sample counts/rates cannot create financial liabilities |
| Ambassador review/tiers/leaderboard privacy | Local upload flag cannot enroll a real student automatically |
| Privacy/marketing/analytics and mandatory notifications | Preferences must have consistent effects across channels/device/server |
| Deletion blockers, pending-funds resolution and retention | A requested deletion is distinct from immediate erasure/closure |
| Transaction cancellation/reversal/refund statuses | Current three-state receipt model cannot express every provider outcome |
| Chat transport, support routing/hours/SLA and approved legal content | Screens need real conversations/destinations and versioned content |
| Backend/frontend contract owner and migration plan | Existing local gateway/callback/model seams need coordinated typed DTO changes |

## 10. Handoff completion checklist

- [ ] Backend engineer has reviewed the source mapping and proposed endpoints; agreed routes and DTOs are published as a versioned specification.
- [ ] Product has approved capability/limit/currency/network/fee/KYC/reward/deletion policies and corrected conflicting static copy.
- [ ] Staging providers, account fixtures, real OTP delivery and secure upload/review workflows are accessible to the integration team.
- [ ] Mobile adapters replace process-local auth/profile/settings/financial/KYC authority with account-scoped repositories and server DTOs.
- [ ] Production financial records bypass simulated completion and use authoritative balances, history, references and timestamps.
- [ ] Error, pending, rejection, retry, cancellation, timeout and resume behaviors are demonstrated using server scenarios.
- [ ] Security/ownership/idempotency/reconciliation/retention checks pass with operational evidence.
- [ ] Every enabled customer journey has a named backend/operations owner, monitoring and a documented recovery path.

The intended result is a mobile app whose displayed state and accepted actions match durable backend facts, with enough contract detail for frontend and backend engineers to integrate without guessing provider behavior or business policy.


## 11. Read-only pull-to-refresh integration added during this handoff

The app now uses the same branded refresh on Home, transaction history, portfolio, the wallet-balance selector, the notification centre/detail, gift-card home/brand catalogues, financial outcome pages (pending/completed/failed), and transaction details. Amount-entry, PIN, camera and receipt-export screens do not initiate this refresh.

`lib/shared/widgets/davo_refresh_region.dart` provides `DavoRefreshScope`, `DavoRefreshDelegate` and `DavoRefreshRequest`. Install the scope above the application Navigator so pushed pages and sheets inherit the same authenticated read adapter. The callback receives a `DavoRefreshTarget` and, for transaction pages, an existing `recordId`. The callback must finish only after its fetch and state publication have succeeded. These callbacks are integration seams; an HTTP client and persistent repositories still need to be connected.

| Refresh target | Required authoritative read | State to publish before completing |
|---|---|---|
| `dashboard` | Dashboard aggregate, wallet balances, portfolio valuation and limits | Current account snapshot and visible wallet/asset values |
| `transactionHistory` | Transaction list with current filters/cursor policy | Updated summaries keyed by stable transaction IDs |
| `portfolio` | Holdings and valuation/price snapshot | Asset quantities, valuations, allocation and as-of timestamp |
| `portfolioPerformance` plus `period` | Portfolio history and optional adjusted summary for the selected range | `PortfolioPerformanceController` snapshot and range-specific metadata |
| `walletBalances` | Account wallets and available/held balances | Wallet selector balances and eligibility |
| `notifications` | Notification list/read state; specific notification detail when applicable | Stable-ID notification DTOs and actual read timestamps |
| `giftCardCatalogue` | Current available catalogue, rates, inventory and market statistics | Catalogue state while preserving Buy/Sell, search/filter selections |
| `transaction` plus `recordId` | `GET /me/transactions/{id}` and relevant related wallet/history reads | Same accepted record ID, canonical status, amount/reference/events and version |

Refreshing a transaction must never call submit/execution endpoints, generate another transaction ID, re-enter PIN authorization or derive completion from animation. This is particularly important when an execution request timed out after server acceptance. Read that existing operation; expose pending until the server confirms its outcome. If no accepted ID was returned, use the agreed operation/idempotency-key reconciliation contract rather than blindly resubmitting.

The floating artwork completes at least two 900ms revolutions when motion is enabled and continues while its read remains in flight. Reduced motion skips that visual minimum. Failed reads preserve the last accepted data and allow another pull. Concurrent pulls in the same region are suppressed; animation completion is not a financial/status event. Unmounting cancels the UI-owned minimum hold, and motion pauses in the background.

For provider transactions, publish DTOs through the shared transaction repository and `ReceiptActivity.accept` adaptation with `preview: false`, maintaining the same ID. Existing result/details observers then resolve the updated record rather than creating a new one. Replace local/static wallet, catalogue and notification fixtures with observable repositories; an empty refresh callback alone cannot make static fixtures live. Reject stale responses after account/session changes, apply server versions and reconcile missed/out-of-order updates. Share outcome/history/detail/receipt identity and balances consistently.

Acceptance checks: pull a pending accepted transaction after an offline interval and observe a server-confirmed completion on the same open page; preserve its ID/count/amount/reference; failure leaves it pending and retry works; pulling a completed transaction does not execute it again; category/filter/expanded-detail state remains selected; duplicate concurrent pulls trigger one read; logout/account switch discards old responses; amount/PIN/camera/export controls do not accidentally initiate refresh.

### Portfolio performance page and history contract

The Portfolio chart button now opens `PortfolioPerformanceScreen` in `lib/features/dashboard/presentation/portfolio_performance_screen.dart`. Models and optional repository/controller/loader adapters are in `lib/features/dashboard/portfolio_performance.dart`. This replaces the earlier inactive-control gap. The page supports 1D/1W/1M/1Y/All, chronological chart point inspection, accessible point selection, value hiding and read-only refresh. It carries the caller's initial value visibility. A current valuation alone is displayed as one point; historical values and returns are not fabricated.

Proposed endpoint: **`GET /me/portfolio/performance?period=1M&currency=NGN`**. The current client range policy uses rolling 24 hours, 7 days, 30 days, 365 days or all available history, anchored to the snapshot's `as_of`; agree the same policy with backend/product. Return current value, actual dated history, currency, as-of/version and optional **period-specific, cash-flow-adjusted** investment change/percentage. A valuation delta includes deposits/withdrawals and must not be labeled investment return. Define fee inclusion, pricing times, missing-price behavior, FX conversion, methodology and historical retention with product before presenting adjusted performance.

Example response (values illustrated solely to explain the proposed transport):

```json
{
  "currency": "NGN",
  "as_of": "2026-10-13T15:00:00Z",
  "version": 7,
  "current_value_kobo": "128450035",
  "history": [{"at": "2026-10-13T15:00:00Z", "value_kobo": "128450035"}],
  "performance": {}
}
```

Map history entries to `PortfolioValuePoint(timestamp, valueKobo)` and current value to `PortfolioPerformanceSnapshot.current`. Optional adjusted summaries map by `PortfolioPerformancePeriod` to `PortfolioAdjustedPerformance(changeKobo, percent)`, where percent is percentage points (2.50 means 2.50%, not 250%). Integer kobo prevents display rounding from altering cents. Do not attach All-period returns to 1D metadata; an absent summary is not a zero return.

`PortfolioPerformanceScreen` accepts an account-owned `PortfolioPerformanceController` and/or `PortfolioPerformanceLoader` returning a snapshot for a period. Supplied controllers remain caller-owned. The screen loads on entry and range changes; its generation guard discards older loader responses and changes of controller/loader ownership. Bind these adapters at navigation using authenticated repositories. The default currently matches the existing portfolio current value (128450035 kobo) and supplies no historic returns.

Shared refresh now includes `DavoRefreshTarget.portfolioPerformance` and optional `DavoRefreshRequest.period` (for example `1W`). The scope/read adapter must publish its snapshot before completion. A page-supplied loader can override the region callback; otherwise it delegates to the shared scope. Publish actual history when available, preserve last known data on failure, keep adjusted summaries scoped to their range, reject old-account responses and update the parent holdings/balance snapshot consistently.

Acceptance: initial range requests 1M; switching periods filters actual timestamped valuations and requests the matching range; dragging/tapping and accessibility selection inspect the correct point; hidden mode exposes no values through chart/slider semantics; sparse/flat/empty history is valid; exact kobo survives formatting; cash deposits do not imply gains; late responses cannot overwrite a newer period/account; network failures retain existing valuations and permit retry.


## Build 39 financial integration boundary

The remaining financial feature calculations now use `ExactDecimal`, BigInt arithmetic and canonical strings. Live input must stay exact across quote/review/acceptance/receipt paths. `BuyCryptoOrder` can carry `quantityDecimals` captured from wallet metadata; its numeric getters and `ngnPerUnit` are compatibility/presentation adapters. Do not serialize them.

Deliver currency/asset/network precision metadata, price/quote IDs, canonical amount and fee quantities, their currencies, rounding rules and minimum/maximum limits. Use decimal strings or atomic/minor-unit strings in JSON, including values beyond JavaScript's safe integer range. Compare quotes and accepted operations using exact values and immutable account/operation identities. A receipt must use the accepted quote/operation snapshot, not a recomputed display estimate or current market rate.

Buy quantities currently resolve down to supported atomic precision; sell/convert percentages resolve down to available atomic units; fiat/gift costs round at two decimal places. These are explicit development policies, not authority to override provider quote rules. Replace seeded pricing and local operation fixtures with agreed server-owned quotes and record the quote's exact quantities before submission. Network fee eligibility must include both amount and fee in the appropriate wallet; do not retry a timed-out money mutation without its original idempotency key.

Portfolio period projections and chart geometry now cache within immutable snapshots. Publish a new snapshot for fresh data; never mutate its lists in place. Account reset invalidates open amount controllers. Continue rejecting late old-account responses and reconcile receipt status from read/event updates.


## Shared notification inbox and unread count

`NotificationInbox` now provides immutable stable-ID records to the bell and notification center. Publish the server's total unread count as well as the current page; the badge caps visual counts at `9+` while accessibility announces the exact number. Mark-read uses IDs. `PreviewAccountState.readNotifications` is a legacy fixture title-set view only and must not identify backend records.

Capture an inbox publication token when starting a read; rejected tokens indicate a superseding read/update or account reset. The adapter must also order concurrent server responses using request sequence or server revision, acknowledge read mutations, retry/reconcile errors and preserve account ownership. Local mark-read behavior does not supply an HTTP implementation or durable server acknowledgment. Sign-out/account reset clears the canonical inbox scope. See `notification-unread-badge.md`.
