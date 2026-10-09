# Security Questions Implementation Plan

Execution: subagent-driven-development, root serializes all Flutter/Dart commands. Existing checkout retained to preserve IDE edits; no commits/reset.

Goal: three-question enrollment, login challenge and email-verified atomic replacement with truthful frontend preview.

Spec: docs/superpowers/specs/2026-10-09-security-questions.md

- [x] Model/gateway validation, answer masking/hash, bounded retries and expiring single-use reset grants; red/green tests.
- [x] Blue/Sora guided setup, question picker, review/result, email code/reset and login challenge, light/dark/reducedmotion; red/green tests.
- [x] Root wire Settings, password/fingerprint/PIN login gates, cancellation, account lifecycle; red/green integration tests.
- [x] Independent source review, full analyzer/tests, batched visuals; build/install emulator and document boundaries.

Review risks: exactly3 distinct inputs, reset grant replay/expiry, back/cancel not unlocking, no secrets in review/storage/logs, no session mutation after disposed routes, preserving account config during ordinary logout.

User steering adds receipt asset/type identity, realistic fixture IDs without Preview labels, and corrected gift-card progress; included in the final combined release. Security review: docs/reviews/2026-10-09-security-questions-implementation.md.
