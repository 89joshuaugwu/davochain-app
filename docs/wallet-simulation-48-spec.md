# Wallet simulation48 specification

User-approved scope: zero balances after new-account creation; completed local transactions update shared balances; realistic NGN crypto conversions researched from market sources; distinct security icons; zero holding labels; neutral Portfolio Buy action; Dashboard/Portfolio review and a Riverpod-first implementation plan. Riverpod migration itself is deferred.

Use the existing account-scoped wallet snapshot and receipt lifecycle. Typed wallet effects contain exact debits/credits, never parse presentation strings. Reserve source funds while pending, credit destination only on completion, refund a failed reservation. Apply each transaction once; reject insufficient funds; reset clears transactions and timers and invalidates older account effects. Only local preview records with effects may change simulation balances. Real provider events remain authoritative and cannot use the local ledger.

New accounts start at zero for NGN/NGD and ten crypto assets. Existing Login fixture stays available as a funded demo identity. Simulation remains session-local; durable multi-account storage is a later migration task, not a claim of banking authentication. Deposit screens expose Add funds and Confirm deposit in development only. The user explicitly confirmed no backend and requested no customer-facing preview or simulation labels. QR/copy/share must not fabricate a deposit.

Use one time-stamped CoinGecko NGN/USD quote snapshot for all supported crypto conversions and valuations. Preserve exact arithmetic and round acquired assets down. Rates are indicative market observations, not executable exchange quotes. Bundle the researched snapshot for deterministic offline demos; document refresh/integration before production.

Dashboard is a compact view; Portfolio sums crypto holdings only, excludes fiat and reports allocation of positive holdings. Zero accounts need a clear empty allocation state. Source metadata and selected-account quantities must agree on all screens. Do not present fixture percentage changes as user returns.
