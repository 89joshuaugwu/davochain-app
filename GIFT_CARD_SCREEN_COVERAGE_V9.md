# Davochain Gift Card Figma Coverage — v9

Authoritative Figma section: `7319:59420` in **Davopay and Davochain**.

This release maps all 15 top-level Gift Card frames/states into interactive Flutter flows. Repeated inactive/active states are implemented as state transitions inside reusable screens instead of duplicated static pages.

| # | Figma node | Figma state | Flutter implementation |
|---|---|---|---|
| 1 | `7319:59421` | Gift cards landing | `GiftCardHomeScreen` |
| 2 | `7319:59517` | Sell Gift Card brand selector | `GiftCardBrandScreen(mode: sell)` |
| 3 | `7319:59604` | Sell Card — step 1 inactive | `GiftCardSellFormScreen` initial state |
| 4 | `7319:59653` | Sell Card — step 1 active/uploaded | `GiftCardSellFormScreen` amount/upload state |
| 5 | `7319:59699` | Sell Card — review/trade breakdown | `GiftCardSellReviewScreen` review state |
| 6 | `7319:59758` | Sell Card — confirmed review | `GiftCardSellReviewScreen` accepted/confirmed state |
| 7 | `7319:59820` | Transaction submitted | `GiftCardSellSubmittedScreen` |
| 8 | `7319:59878` | Verification progress | `GiftCardVerificationScreen` |
| 9 | `7319:59934` | Buy Gift Cards brand selector | `GiftCardBrandScreen(mode: buy)` |
| 10 | `7319:60033` | Buy Card configuration | `GiftCardBuyFormScreen` |
| 11 | `7319:60078` | Delivery details | `GiftCardDeliveryScreen` |
| 12 | `7319:60136` | Review purchase | `GiftCardBuyReviewScreen` |
| 13 | `7319:60176` | Payment method | `GiftCardPaymentScreen` |
| 14 | `7319:60217` | Transaction PIN | `GiftCardPinScreen` |
| 15 | `7319:60242` | Purchase successful | `GiftCardBuySuccessScreen` |

## Entry points

- Dashboard quick action **Gift Cards** opens the Gift Card module.
- Bottom navigation **Gift Cards** opens the same production flow instead of a coming-soon placeholder.

## Interaction coverage

- Buy / Sell mode switching with haptics.
- Brand search and category filtering.
- Gift-card selection with exact Figma brand assets.
- Sell: physical/e-code state, subcategory, amount, rate calculation, exact card-photo upload state, terms acknowledgement, submission, and verification progress.
- Buy: subcategory, amount, quantity, recipient mode, email/phone fields, delivery method, review, NGN-wallet payment, transaction PIN, success details, and copy actions.
- Native Flutter page transitions, AnimatedContainer/AnimatedSwitcher state changes, haptic feedback, verification pulse and success entrance motion.

## PIN note

Figma copy in node `7319:60217` says “6-digit security PIN”, while the same frame visibly contains four PIN boxes. v9 follows the visible interaction design and the rest of the Davochain transaction-PIN pattern: four PIN positions.
