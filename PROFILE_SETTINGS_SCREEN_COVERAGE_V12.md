# Davochain Profile / Settings — Figma Coverage v12

Source section: Figma `3418:85446` (`Profile/Settings`) in `Davopay-and-Davochain`.

Scope of this checkpoint: screen/state completeness and navigation/state wiring only. This pass does **not** attempt the later pixel-level fidelity/alignment audit.

## Result

All 69 top-level Figma frames in `3418:85446` are represented in Flutter as a screen, an interactive state of a screen, or a modal/dialog state.

One genuinely missing sequence state was found and added: **Tier 3 — “Verifying your ID and address”** (`7431:71046`). The Tier 3 flow now proceeds `Face submit -> verification processing -> fully verified` instead of skipping directly to success.

The explicit inactive/active pairs in Figma are now represented by actual Flutter input state where the design provides both variants: Complete Profile, BVN, NIN, verification-code entry, and new Transaction PIN.

## Main Profile / account

| Figma node | Figma state | Flutter representation |
|---|---|---|
| `3418:86187` | Profile | `ProfileSettingsScreen` |
| `3418:86381` | Personal Information | `PersonalInformationV12Screen` view state |
| `7319:71829` | Personal Information Verified / edit | `PersonalInformationV12Screen` edit state |
| `7431:70052` | Personal Information Success | `PersonalInformationSuccessScreen` |
| `7431:73018` | Linked Bank Accounts | `LinkedAccountsScreen` |
| `7442:73173` | Add Bank Account | `AddBankAccountScreen` |
| `7545:71753` | Appearance | `AppearanceScreen` |

The visible **Delete Account** action in the Profile frame is also restored. Figma supplies no separate destination frame/prototype target for it, so no unsupported full-screen design was invented.

## Notifications / settings / privacy

| Figma node | Figma state | Flutter representation |
|---|---|---|
| `3418:87061` | Notification — empty | `NotificationCenterScreen.empty()` |
| `3418:87111` | Notification — populated | `NotificationCenterScreen` |
| `3418:87206` | Notification Settings — alert preferences | `NotificationSettingsScreen` |
| `3418:87284` | Notification Settings — transaction channels | `NotificationChannelScreen(type: 0)` |
| `7442:73688` | Crypto Security | `CryptoSecurityScreen` |
| `7442:73958` | Notifications preferences | `NotificationsPreferencesScreen` |
| `7442:74356` | Privacy | `PrivacyScreen` |

## Transaction PIN reset

| Figma node | Figma state | Flutter representation |
|---|---|---|
| `3418:89387` | Reset Transaction PIN — method selection | `ResetPinStartScreen` |
| `3418:89456` | Phone verification code — empty | `VerifyPinCodeScreen(email: false)` inactive state |
| `3418:89516` | Phone verification code — filled | same screen, active at 4 digits |
| `3418:89576` | Email verification code — empty | `VerifyPinCodeScreen(email: true)` inactive state |
| `3418:89636` | Email verification code — filled | same screen, active at 4 digits |
| `3418:89696` | New Transaction PIN — inactive | `NewTransactionPinScreen` inactive state |
| `3418:89752` | New Transaction PIN — active | same screen, active when both 4-digit PINs match |
| `3418:89808` | PIN Transaction Success | `PinSuccessScreen` |

The inactive PIN buttons use the Figma inactive blue (`#89ADFB`) rather than presenting the active action prematurely.

## Tier 1 — BVN

| Figma node | Figma state | Flutter representation |
|---|---|---|
| `7431:70191` | Verify Your Account — Tier overview | `KycTierOverviewScreen(completedTier: 0)` |
| `7431:70488` | Tier 1: BVN Verification | `KycTierIntroScreen(tier: 1)` |
| `7431:71488` | Complete profile — inactive | `CompleteProfileV12Screen` inactive state |
| `7431:71569` | Complete profile — active | same screen, active when required fields are populated |
| `7431:71519` | Continue Complete Profile | `CompleteProfileContactV12Screen` |
| `7431:71406` | Link your BVN — inactive | `BvnEntryV12Screen` inactive state |
| `7431:71600` | Link your BVN — active | same screen, active at 11 digits |
| `7431:71177` | Enter BVN Processing | `VerificationProcessingV12Screen` BVN variant |
| `7431:71641` | Tier 1 Completed | `TierCompletionV12Screen(tier: 1)` |

## Tier 2 — NIN / face verification

| Figma node | Figma state | Flutter representation |
|---|---|---|
| `7431:70289` | Verify Tier 2 Your Account | `KycTierOverviewScreen(completedTier: 1)` |
| `7431:70567` | Tier 2: NIN Verification | `KycTierIntroScreen(tier: 2)` |
| `7431:71436` | Link your NIN — inactive | `NinEntryV12Screen` inactive state |
| `7431:71462` | Link your NIN — active | same screen, active at 11 digits |
| `7431:71230` | Enter NIN Processing | `VerificationProcessingV12Screen` NIN variant |
| `7431:71335` | Take a selfie | `KycSelfieV12Screen` |
| `7431:71882` | Live face detection | `FaceDetectionV12Screen` |
| `7431:71738` | Review your photo | `FaceReviewV12Screen` |
| `7431:71283` | Face Verification Processing | `VerificationProcessingV12Screen` face-match variant |
| `7431:71682` | Tier 2 Completed | `TierCompletionV12Screen(tier: 2)` |
| `7431:70387` | Account overview with Tier 1 + 2 completed | `KycTierOverviewScreen(completedTier: 2)` |

## Tier 3 — ID / address / final verification

| Figma node | Figma state | Flutter representation |
|---|---|---|
| `7431:70647` | Verify Your Tier 3 Account | `KycTierIntroScreen(tier: 3)` |
| `7431:70724` | Tier 3 Select ID | `Tier3SelectIdScreen` |
| `7431:71099` | Tier 3 Upload ID | `Tier3UploadIdScreen` |
| `7431:70808` | Tier 3 Select Document | `Tier3SelectDocumentScreen` |
| `7431:71940` | Tier 3 Upload Document — empty | `Tier3UploadDocumentScreen` empty state |
| `7431:70902` | Tier 3 Upload Document — file selected | same screen, uploaded state |
| `7431:70980` | Tier 3 Address Details | `Tier3AddressReviewScreen` |
| `7431:71812` | Final Face Verification | `Tier3FaceSubmitScreen` |
| `7431:71046` | Verifying your ID and address | **`Tier3VerificationProcessingScreen` — added in this pass** |
| `7431:71724` | Account Fully Verified | `FullyVerifiedV12Screen` |

## Customer support / help

| Figma node | Figma state | Flutter representation |
|---|---|---|
| `7545:70865` | Customer Support contacts | `CustomerSupportScreen` |
| `7545:70980` | Customer Support hub | `SupportHubScreen` |
| `7545:71101` | Customer Support Message — empty | `SupportMessagesScreen` |
| `7545:71229` | Customer Support Chat — initial choices | `SupportChatScreen` initial state |
| `7545:71393` | Customer Support Chat — category selected | same screen, selected-choice state |
| `7545:71575` | Email Support | `EmailSupportScreen` |
| `3418:87349` | Customer Support — full help catalog | `HelpCenterScreen` |
| `7545:71614` | Help Centre — popular topics | `HelpCentreScreen` |
| `3418:88661` | Open Instagram confirmation | `_socialDialog(..., 'Instagram')` |
| `3418:88669` | Open X confirmation | `_socialDialog(..., 'X')` |
| `3418:88677` | Open LinkedIn confirmation | `_socialDialog(..., 'Linkedln')` |

## Rewards / ambassador

| Figma node | Figma state | Flutter representation |
|---|---|---|
| `3418:87773` | Referral Dashboard | `ReferralDashboardScreen` |
| `3418:87841` | Referral Analytics | `ReferralAnalyticsScreen` |
| `3418:87987` | Davo Points Dashboard | `DavoPointsScreen` |
| `3418:88094` | Student Ambassador Details | `StudentAmbassadorScreen` |
| `3418:88107` | Ambassador Dashboard | `AmbassadorDashboardScreen` |
| `3418:88269` | Ambassador Leaderboard | `AmbassadorLeaderboardScreen` |

## Completion changes in this checkpoint

- Restored the Profile frame's visible **Delete Account** action.
- Modeled Notification empty/populated frames as explicit `NotificationCenterScreen` data states.
- Added inactive/active input-state behavior for Complete Profile, BVN, NIN, SMS/email verification code, and Transaction PIN.
- Added the missing Tier 3 verification-processing state and inserted it into the correct flow before success.
- Fixed two malformed multiline Dart string literals in the Profile/Settings file while auditing the state implementation.
- Preserved all pre-existing screens outside this Profile/Settings completion pass.

## Validation available in this environment

The Flutter SDK is not installed in this runtime, so `flutter analyze` / `flutter test` cannot be executed here. Static checks performed for this pass:

- balanced `()`, `[]`, `{}` in `profile_settings_flow.dart`;
- no unescaped newline inside ordinary Dart string literals;
- all `assets/figma_exact/...` references used by the Profile/Settings file resolve to files in the cumulative tree.
