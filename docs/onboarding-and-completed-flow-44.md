# Onboarding and completed-flow refinement - 0.18.2+44

15 October 2026. Scoped to the user's onboarding/auth and gift-review screenshot corrections, plus accepted transaction exit navigation. No backend or state-management migration.

- Onboarding uses the supplied Figma copy, blue headings and left-aligned progress indicators directly above the heading. Login is a full-width pale-blue secondary action. Existing images, swiping, Skip, reduced motion and Android page-back remain.
- Country selection has an Already have an account? Login redirect. Consent/Continue sit higher, leaving Login at the bottom. Consent is a square checkbox; the country field grows with text size.
- Shared resend rows group prompt and Resend Code on the left, with only the countdown at the right; narrow/enlarged layouts wrap. OTP expiry and resend restrictions are unchanged.
- Shared password-strength palette uses the requested brighter orange and green. Signup and password recovery share the palette for meters and met criteria. Password rules are unchanged.
- Gift sale review has an underlined Trade Terms heading and green acceptance check. Actual uploaded evidence uses contain fitting rather than cropping. No stock picture replaces uploaded evidence.
- Completed/accepted outcome Back (arrow and Android) discards completed form routes and opens a clean Trade tab, Gift Cards tab with matching buy/sell mode, or Wallet/Home for funding/transfers. Accepted wallet/receipt state remains intact. Starting another trade opens a fresh flow above a clean hub. Details/Receipt remain ordinary pushed routes so Back returns to the outcome.

Implementation: finishDavoTransaction centralizes navigation cleanup. DavoResultScreen and gift scaffolds opt in to exit handling; ordinary editable forms keep their Back behavior. Funding outcomes share the cleanup policy for deposits and withdrawals.

Verification: new navigation tests cover both back controls across crypto buy/sell/swap/withdrawal, gift buy/sell and Naira withdrawal/deposit; additional checks cover fresh gift trades and Details returning to the result. Country Login redirect has a regression check. An independent read-only review approved the navigation changes without blockers. Final suite, captures and artifact identity are recorded in the root review ledger after completion.

Final verification before packaging: analyzer reported no issues; full suite passed 625 tests with 12 optional captures skipped. Explicit scoped capture/funding/navigation run passed 31 tests and produced 16 light/dark screenshots. Impeccable's mechanical scan returned no findings; the native screenshots were also inspected. The old funding-route assertion was updated to verify the requested clean Wallet hub rather than an artificial retained root.
