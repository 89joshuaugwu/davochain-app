# Davochain v12 Cumulative Work Log

Purpose: preserve checkpoint status so later passes **do not redo completed work**. Only reopen a completed item when a new Figma revision or a reproducible mismatch is provided.

## Completed checkpoints

- [x] Asset consolidation — supplied ZIP assets consolidated under `assets/figma_exact/`; runtime aliases/manifests created.
- [x] Profile/Settings screen-state completion — Figma Profile/Settings states mapped and genuinely missing states added without rebuilding existing screens.
- [x] Profile/Settings title/header typography consistency audit.
- [x] Wider audit — **modal/sheet final verification**. See `WIDER_AUDIT_MODAL_SHEET_VERIFICATION_V12.md` for exact nodes, dimensions, corrections, and no-change verifications.

## Wider-audit items still open after the modal/sheet checkpoint

- [x] Naira Withdraw **full-screen** alignment (separate from `_NairaConfirm`, which was already closed). See `WIDER_AUDIT_WITHDRAW_ALIGNMENT_V12.md`.
- [x] Final internal/external Crypto Withdraw **full-screen** polish. See `WIDER_AUDIT_WITHDRAW_ALIGNMENT_V12.md`.
- [x] Scan/Paste Address final verification. See `WIDER_AUDIT_SCAN_SHARE_V12.md`.
- [x] Deposit final verification — CLOSED.
  - [x] BTC Deposit final patch — closed. See `DEPOSIT_BTC_NGD_FINAL_PATCH_V12.md`.
  - [x] NGD Deposit final patch — closed. See `DEPOSIT_BTC_NGD_FINAL_PATCH_V12.md`.
  - [x] Copy toast exact component/placement decision — closed. See `DEPOSIT_DETAILS_TOAST_FINAL_V12.md`.
  - [x] Deposit Details successful/pending alignment — closed. See `DEPOSIT_DETAILS_TOAST_FINAL_V12.md`.
- [x] Share Address final check. See `WIDER_AUDIT_SCAN_SHARE_V12.md`.
- [ ] Transaction PIN 4-vs-5 digit inconsistency reconciliation.
- [ ] Progress / success / detail / receipt final pixel pass.
- [ ] Transaction-flow CTA/back/cancel cleanup.
- [ ] Cumulative QA / build checks and final v12 packaging.

## Do not redo in the remaining wider audit

- Buy/Sell/Convert trade layout/review reconstruction.
- Segmented Buy/Sell/Convert toggle reconstruction.
- Modal architecture for the ten sheets closed in `WIDER_AUDIT_MODAL_SHEET_VERIFICATION_V12.md`.
- Cancel Reminder conversion to bottom sheet.
