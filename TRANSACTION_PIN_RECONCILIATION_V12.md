# Davochain v12 — Transaction PIN Reconciliation

Status: **CLOSED**

This checkpoint resolves the transaction-PIN inconsistency without changing the Figma file.

## Authoritative design decision

The transaction PIN is **4 digits**.

Figma evidence already audited in the `Enter Pin NAIRA` states:

- Inactive PIN states (`7319:58547`, `7319:58582`, `7319:58617`) explicitly say: `Please enter your 4-digit security PIN...`.
- Those states render exactly four PIN boxes, each 60×70, at x = 63, 131, 199 and 267.
- Active states (`7319:58652`, `7319:58665`, `7319:58678`) contain stale `5-digit` copy, but the active OTP component visibly renders only four digits (`1`, `2`, `3`, `4`).
- Therefore the active `5-digit` wording is treated as a Figma copy typo, not as a five-digit product requirement.

## Code corrections

### Withdrawal transaction PIN

`lib/features/crypto/presentation/crypto_full_flow.dart`

- Active-state copy changed from `5-digit` to `4-digit`.
- Input logic already stops accepting digits at `pin.length < 4`.
- Active/Confirm state already occurs only at `pin.length == 4`.
- PIN UI already renders exactly four 60×70 slots.
- Naira withdrawal, Internal Crypto Withdraw and External Crypto Withdraw all route through the same `CryptoPinScreen`, so they now share one four-digit implementation.

### Buy Crypto transaction PIN

`lib/features/buy_crypto/presentation/buy_crypto_screens.dart`

- Active-state copy changed from `5-digit` to `4-digit`.
- Existing logic remains capped at four digits and `_confirm()` rejects any value whose length is not 4.
- UI continues to render four PIN slots.

### Gift Card transaction PIN consistency

`lib/features/gift_cards/presentation/gift_card_flow.dart`

- Corrected stale `6-digit` copy to `4-digit` because this screen already rendered four slots, stopped input at four digits and enabled Confirm at four digits.
- This prevents another transaction-PIN copy contradiction elsewhere in the Flutter source.

### Transaction PIN setup/reset

`lib/features/profile_settings/presentation/profile_settings_flow.dart`

- New PIN and Confirm New PIN fields now enforce `maxLength: 4`.
- Both fields accept digits only through `FilteringTextInputFormatter.digitsOnly`.
- The length counter is hidden so the existing Figma field appearance is preserved.
- Save remains enabled only when both values contain exactly four digits and match.

## Route consistency

The current withdrawal routes all use `CryptoPinScreen`:

- Naira Withdraw confirmation → `CryptoPinScreen`
- Internal Crypto Withdraw confirmation → `CryptoPinScreen`
- External Crypto Withdraw confirmation → `CryptoPinScreen`
- Legacy/current Transfer Review confirmation → `CryptoPinScreen`

No separate five-digit withdrawal PIN implementation remains.

## Static verification

The Flutter `lib/` source was searched for the following inconsistent patterns:

- `5-digit` / `5 digit` / `five-digit`
- `maxLength: 5` / `maxLength = 5`
- PIN/string `length == 5`, `!= 5`, `< 5`, `<= 5`, `> 5`, `>= 5`
- `List.generate(5` for PIN-like slot rendering
- `6-digit security PIN`

Result after patch: **no matches**.

The remaining transaction/security PIN references consistently describe or enforce four digits.

## Validation limitation

Flutter/Dart SDK is not installed in this execution environment, so this checkpoint uses source-level structural/search validation rather than claiming `flutter analyze`, `flutter test` or a device build.
