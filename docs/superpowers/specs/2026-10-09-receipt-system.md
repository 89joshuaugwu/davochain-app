# Davochain transaction details and receipts

Approved scope: user requested all improvements from the screenshot comparison. Preserve small Sora sizes, blue branding, accepted app artwork and animations, and reversible local preview boundaries. Work in the existing checkout without staging, committing or resetting unrelated changes. No provider integration or invented settlement events.

## Shared contract

Create `lib/shared/receipts/receipt_record.dart` with immutable `ReceiptRecord`: `id`, `reference` (String), `type` (String), `status` (ReceiptStatus enum pending/completed/failed), `occurredAt` (DateTime), `amount` (String display primary amount), `preview` (bool default true), `fields` (List<ReceiptField>), `events` (List<ReceiptEvent> default empty). ReceiptField named arguments `label`, `value`, `sensitive` bool=false, `copyable` bool=false. ReceiptEvent named `label`, `description`, `occurredAt` nullableDateTime, `state` ReceiptEventState complete/current/upcoming. Values are accepted record data, never editable in themes. Provide canonical date formatting and mask sensitive values by default for exported content, with explicit unmask toggle. Preserve crypto quantity precision in display strings; IDs copied full and only shortened visually.

Create `receipt_screen.dart` public `ReceiptScreen({required ReceiptRecord record})`: clean branded default, optional Celebration/Appreciation/Birthday variants in original Davochain blue art using vector Flutter motifs, restrained preview-switch animation, reduced motion instant; optional personal note max240 characters only; visible Preview banner in all exported artifacts when record.preview. Transaction status remains explicit on every theme. Persistent export actions image and PDF. Existing native share/save sheet reused, actual PNG file and multi-page vector/selectable-text PDF with Sora font and Unicode Naira. Image/PDF use same masked display fields, selected style and note. No editable factual fields.

Create `transaction_record_details_screen.dart` public `TransactionRecordDetailsScreen({required ReceiptRecord record})`: prominent amount/direction/status, grouped fields, copyable IDs, expand details, accepted-event timeline; Share Receipt routes ReceiptScreen. Report Issue opens existing EmailSupportScreen prefilled immutable transaction context without submitting automatically. Add optional initialSubject/initialOrderId/initialMessage to EmailSupportScreen; user edits request and submits through existing truthful local-preview gateway. No fabricated timeline timestamps; no hardcoded time-to-settlement promises. External explorer only for a validated hash and supported network via launch_url; if dependency unavailable use copy link + OS share instead of no-op navigation. No sensitive identifiers or support notes leaked through exported receipts.

## Flow integration

FundingDetailsScreen maps accepted FundingRecord with real status, date, amount, bank/network/hash/fee. Include transaction ID even absent separate reference; bank accounts/addresses sensitive, ID/hash copyable. Deposit/wd both share, timeline/status/support.

Gift buy/sell results map stable state-held preview records and actual available amount/category/quantity data. Replace misleading Save New Trade with View Receipt; preserve sell verification action as separately labeled Track Verification. Pass optional ReceiptRecord into outcome widgets to allow future accepted provider records. Preserve mock/preview status watermark. Add gift activities to local history only when a flow produces outcome; do not invent purchase submission just for tapping receipt.

BuyTransactionDetailsScreen gets stable optional ReceiptRecord (or stable date/id held state) shared with receipt. BuyReceiptScreen maps to shared ReceiptScreen. Existing constructors compatible. Crypto TransactionDetailsScreen accepts optional ReceiptRecord; shared detail/receipt use same record with stable local fixture fallback. Update history samples to supply stable records matching sample title/date/amount; do not use DateTime.now on rebuild. Crypto deposit sample gets receipt/support capabilities. Do not overwrite accepted pending funding statuses.

## Verification

Meaningful tests: shared facts identical across style selection and PDF/image; masking defaults and explicit toggle; preview/status survives styles; selectable PDF bytes with long multi-page receipt; pending timeline contains only supplied event times; linked issue prefill; funding/gift export navigation; stable buy/history record date/ID; narrow 320px dark/light 2x text, long hashes and crypto precision; async duplicate/export failure/disposal guards. Serialize Flutter CLI from root to avoid cache races. Full analyzer and tests, final visual capture review. Emulator release only after final successful validation; existing request authorizes installation.

## Final user direction

Expose only the standard receipt and remove the type-based page title. Keep the alternate presentation code for later design, with no public style selector. Personal notes, masking and image/PDF actions remain.
