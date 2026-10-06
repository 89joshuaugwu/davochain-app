# Davochain Profile / Settings — Figma Coverage v10

Source: Figma section `7319:60302` in `Davopay-and-Davochain`.

## Coverage summary

All 49 top-level frames in the section are represented by native Flutter screens, reusable state variants, or modal/dialog states.

### Transaction limits
- 7319:60363 — Account/currency selector → `TransactionLimitsScreen`
- 7319:60461 / 7319:60569 — USD send/receive states → `LimitDetailScreen(kind: usd)` + segment state
- 7319:60675 / 7319:60768 — NGN send/receive states → `LimitDetailScreen(kind: ngn)` + segment state
- 7319:60861 / 7319:60952 — Crypto withdrawal/deposit states → `LimitDetailScreen(kind: crypto)` + segment state
- 7319:61703 — Increase Transfer Limits → `IncreaseLimitsScreen`
- 7319:61772 — Confirm Your Address → `AddressUpgradeScreen`
- 7319:61847 — Upload document action sheet → `_uploadSheet`

### Profile / account / KYC
- 7319:61043 — Profile → `ProfileSettingsScreen`
- 7319:61237 — Account information → `AccountInformationScreen`
- 7319:61329 — KYC status overview → `KycOverviewScreen`
- 7319:61415 — Identity / selfie method → `KycMethodScreen`
- 7319:61484 — Government ID type selection → `GovernmentIdScreen`
- 7319:61561 — Upload ID sheet → `_uploadSheet`
- 7319:61575 — Selfie instructions → `SelfieScreen`
- 7319:61645 — Live face detection → `FaceDetectionScreen` with animated scan line

### Password / notifications
- 7319:61863 — Change Password → `ChangePasswordScreen`
- 7319:61917 — Empty notifications → Rewards/empty state in `NotificationCenterScreen`
- 7319:61967 — Notification list + filters → `NotificationCenterScreen`
- 7319:62062 — Alert Preferences → `NotificationSettingsScreen`
- 7319:62140 — Transaction Alerts → `NotificationChannelScreen(type: 0)`
- 7319:63293 — Security Alerts → `NotificationChannelScreen(type: 1)`
- 7319:63353 — Marketing & News → `NotificationChannelScreen(type: 2)`

### Customer support
- 7319:63413 — Customer Support contact list → `CustomerSupportScreen`
- 7319:63517 — Instagram external-open dialog → `_socialDialog`
- 7319:63525 — X external-open dialog → `_socialDialog`
- 7319:63533 — LinkedIn external-open dialog → `_socialDialog`
- 7319:63541 — Support home / help hub → `SupportHubScreen`
- 7319:63730 — Empty Messages → `SupportMessagesScreen`
- 7319:63858 — Initial Callie support chat options → `SupportChatScreen`
- 7319:64022 — Chosen support category + question input → `SupportChatScreen.choice` state
- 7319:64204 — Email Support → `EmailSupportScreen`
- 7319:62205 — Full Help Center catalog → `HelpCenterScreen`

### Transaction PIN
- 7319:64243 — Reset PIN method choice → `ResetPinStartScreen`
- 7319:64312 / 7319:64372 — SMS code empty/filled → `VerifyPinCodeScreen(email: false)`
- 7319:64432 / 7319:64492 — Email code empty/filled → `VerifyPinCodeScreen(email: true)`
- 7319:64552 / 7319:64608 — New / confirm transaction PIN → `NewTransactionPinScreen`
- 7319:64664 — PIN reset success → `PinSuccessScreen`

### Rewards / referrals / ambassador
- 7319:62629 — Referral Dashboard → `ReferralDashboardScreen`
- 7319:62697 — Referral Analytics → `ReferralAnalyticsScreen`
- 7319:62843 — Davo Points Dashboard → `DavoPointsScreen`
- 7319:62950 — Student Ambassador Details → `StudentAmbassadorScreen`
- 7319:62963 — Ambassador Dashboard → `AmbassadorDashboardScreen`
- 7319:63125 — Ambassador Leaderboard → `AmbassadorLeaderboardScreen`

## Navigation wiring
- Dashboard profile avatar opens Profile / Settings.
- Dashboard notification button opens Notification Center.
- Bottom navigation Settings opens Profile / Settings.
- Existing Gift Card and crypto flows are retained from cumulative v9.

## Motion / state coverage
- Existing app-wide 440ms fade + slide + scale route transition is reused.
- Biometrics and notification switches animate between states.
- Transaction-limit segmented controls animate between Figma variants.
- Limit progress bars animate into place.
- Live face-detection scan line loops continuously.
- PIN success uses an elastic scale entrance.
- Support chat changes from choice list to selected category/question state interactively.
- KYC/document upload sheets and social-open confirmation dialogs use native modal transitions.
