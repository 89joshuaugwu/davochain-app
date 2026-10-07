# Profile / Settings Title Typography Audit — v12

Source: Figma section `3418:85446` in `Davopay and Davochain`.
This audit is read-only against Figma. The Flutter code is the only implementation target.

## Navigation title families confirmed from Figma

- **Inter Medium 20 / 1.35 / #1C1C1C**: Profile, Personal Information, KYC Verification (selfie flow).
- **Sora Regular 20 / 1.35 / #424242**: Notification, Notification Settings, Reset Transaction PIN, Transaction PIN, Crypto Security, Notifications, Privacy, Appearance, Customer Support, Help Centre.
- **Sora Regular 16 / 1.35 / #1C1C1C**: Verify Your Account, Verify your identity, Face Verification, Ambassador Leaderboard.
- **Sora SemiBold 16 / 1.35 / #1C1C1C**: Linked Accounts, Add Bank Account, Messages overlay, Help overlay.
- **Sora Medium 16 / 1.35 / #1C1C1C**: Rewards.
- **Sora Bold 16 / 1.35 / #1C1C1C**: Email Support.
- **Sora SemiBold 14 / 1.35 / #1C1C1C**: Callie support-chat header.

## Screens where Figma uses a body title instead of a centered navigation title

- Referral Analytics: `Performance Hub` is Sora Medium 14 blue at y=112; `Referral Analytics` is Sora Regular 20 #424242 at y=139.
- Davo points Dashboard: Sora Regular 20 #424242 body title at y=107.
- Student Ambassador Details: Sora Regular 20 #1C1C1C body title at y=108.
- Ambassador Dashboard: no centered navigation title; the first header card starts at y=108. `Hi, Callie` is Sora Regular 14 blue and `Ambassador` is Sora SemiBold 16 blue.

## Flutter corrections applied in this pass

- Added `_navSora16Medium`, `_navSora16SemiBold`, and `_navSora14SemiBold` constants.
- Rewards now uses Sora Medium 16.
- Linked Accounts and Add Bank Account now use Sora SemiBold 16.
- Support Messages and the Support Help overlay now use Sora SemiBold 16.
- Support Chat `Callie` navigation title uses Sora SemiBold 14.
- Referral Analytics no longer renders a duplicate centered app-bar title; its Figma body title hierarchy is used instead.
- Davo points Dashboard no longer renders its heading as a centered app-bar title; the heading is now placed in the body with the Figma typography.
- Student Ambassador Details no longer renders as a centered app-bar title; it is a body title as in Figma.
- Ambassador Dashboard no longer renders a false centered `Davo points Dashboard` title.
- Ambassador Dashboard header text was corrected to Sora Regular 14 blue (`Hi, Callie`) and Sora SemiBold 16 blue (`Ambassador`).
- `_Shell` now omits the title widget when a Figma screen intentionally has no centered title.

## Font-runtime note

The Flutter source declares Sora / Inter / Poppins / Open Sans by family name, but the current repository does not bundle font files in `pubspec.yaml`. The size, weight, line-height and color mappings are now aligned to Figma, but exact typeface rendering on a device still depends on the runtime having those families available. This is a repository-level font availability constraint, not a Figma measurement ambiguity.
