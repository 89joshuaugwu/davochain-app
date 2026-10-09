# Receipt System Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Complete consistent transaction details, receipt exports, support context and optional styles across Davochain transaction types.

**Architecture:** Immutable shared receipt record; existing flow adapters; shared details and export presentation. Facts remain stable while presentation options change.

**Tech Stack:** Flutter/Dart, existing pdf/share_plus/native export channel, Sora assets.

**Spec:** docs/superpowers/specs/2026-10-09-receipt-system.md

## Global Constraints

Retain small text sizes, light/dark/reduced-motion support, truthful Preview labels, no fake provider/settlement data, no commits or resets. Root owns serialized Flutter CLI verification.

## Tasks

- [x] 1. Shared record and themed receipt export UI; PNG and selectable multi-page PDF, masking and immutable facts; meaningful red/green tests.
- [x] 2. Shared transaction details/timeline/support context plus funding adapters; tests for pending/completed records and prefilled issue requests.
- [x] 3. Gift-card receipt adapters and correctly labeled outcome actions/history; regression tests.
- [x] 4. Crypto buy/sell/swap/transfer/deposit adapters and stable history records; regressions.
- [x] 5. Review full integration, analyzer/full tests, bounded light/dark captures, release build and emulator installation; write evidence.

## Review Focus

Long IDs and tiny crypto amounts must retain exact values. Pending/failed exports never look completed. Theme/note changes never change facts. Shared content masks sensitive data unless explicitly changed. Only supplied timeline timestamps and actual record status are displayed.

## Ledger

Ruling: user explicitly approved all comparison improvements and prior autonomous implementation; proceed with written spec/plan without repeating approval. Existing shared checkout retained to preserve user IDE edits.

Implementation review: docs/reviews/2026-10-09-transaction-receipts-implementation.md. Shared foundation, funding, gift and crypto integrations passed focused red/green checks and independent source review. Final release gate runs the full suite, analyzer and build serially.

Final user refinement: only Standard is exposed, with the type-based page heading removed; alternate style code retained. All 273 tests pass and analyzer is clean. Release22 installed; all753declared files match source, installed APK hash matches, native PNG/PDFDownloads and saved-file contents verified.
