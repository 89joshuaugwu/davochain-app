# KYC flow inventory — 8 October 2026

Read-only source audit of the existing Flutter preview. No application code was changed and no tests or builds were run for this inventory. Line references describe the working tree at audit time; it already contains user changes, so legacy source must be preserved while the live experience is replaced.

## Requested destination

- Basic verification: personal profile (name, date of birth, contact and address) → choose **NIN or BVN** → enter the selected 11-digit identifier → verification outcome. **No face verification in Basic.**
- Advanced verification: **face first** → government ID verification → supporting document verification → outcome.
- Tier 1/2/3 language and the serial NIN → BVN upgrade model are obsolete for the new live flow.
- Supporting document interpretation remains a product clarification: the existing code clearly separates government ID front/back from proof of address, but the requested document wording may mean something different. Do not silently combine those stages.

## Live entry points and navigation contracts

| Source | Current destination | Evidence |
| --- | --- | --- |
| Settings menu: “KYC Verification” | `KycTierOverviewScreen()` | `lib/features/profile_settings/presentation/profile_settings_flow.dart:74` |
| Dashboard: “Finish setting up your account” | `KycTierOverviewScreen()` | `lib/features/dashboard/presentation/dashboard_screen.dart:75–80` |
| Dashboard settings bottom-navigation branch | `startProfileSettingsFlow()` → `ProfileSettingsScreen` | dashboard line 156; profile flow line 29 |
| Dashboard header profile avatar | same settings flow | dashboard line 259 |

There is no named KYC route in `AppRoutes` or `DavochainApp.onGenerateRoute` (`lib/core/navigation/app_routes.dart`, `lib/app.dart`). Both KYC entries directly construct a widget. The profile `_push` helper (line 3796) calls `pushAppPage` and therefore uses `AppPageRoute`; the dashboard `_davoRoute` helper (line 2708) also constructs `AppPageRoute`. KYC processing is an exception: its delayed transition uses raw `MaterialPageRoute` with `pushReplacement` (lines 1383–1386).

`_Shell` provides the current white scaffold, safe area, back arrow, optional scroll container and header divider (line 3184). Its back button simply pops. Success actions commonly `popUntil(route.isFirst)`, so “Back to Home” actually returns to the navigator's first route; it does not explicitly navigate to `AppRoutes.dashboard`.

## Existing live timeline

```text
Settings / dashboard setup banner
  → KycTierOverviewScreen(completedTier: 0)
    → Tier 1 introduction
      → CompleteProfileV12Screen
      → CompleteProfileContactV12Screen
      → NinEntryV12Screen
      → VerificationProcessingV12Screen [1200ms automatic replacement]
      → KycSelfieV12Screen
      → FaceDetectionV12Screen [tap black frame to advance]
      → FaceReviewV12Screen
      → VerificationProcessingV12Screen [1200ms]
      → TierCompletionV12Screen(tier: 1)
      → newly pushed overview(completedTier: 1)
    → Tier 2 introduction
      → BvnEntryV12Screen
      → VerificationProcessingV12Screen [1200ms]
      → TierCompletionV12Screen(tier: 2)
      → newly pushed overview(completedTier: 2)
    → Tier 3 introduction
      → Tier3SelectIdScreen
      → Tier3UploadIdScreen
      → Tier3SelectDocumentScreen
      → Tier3UploadDocumentScreen
      → Tier3AddressReviewScreen
      → Tier3FaceSubmitScreen
      → Tier3VerificationProcessingScreen [wraps 1200ms processing]
      → FullyVerifiedV12Screen
      → Back to Home [writes setupComplete, pops to first route]
```

The overview shows active/completed/locked styling, but `_TierCard.onTap` is unconditional (line 2451). All three cards are navigable even when visually locked. `completedTier` is a widget argument, not stored account status. Opening KYC again from settings or the dashboard constructs a fresh overview with zero completed tiers.

## Screen and component map

| Existing source | Reuse opportunity / required adaptation |
| --- | --- |
| `KycTierOverviewScreen` (969), `KycTierIntroScreen` (1024) | Replace live Tier copy and hierarchy with Basic/Advanced. Old tier constructors can remain for legacy callers while live callers migrate. |
| `CompleteProfileV12Screen` (1127) | Reuse profile form/date picker. Current first, middle, last and DOB are all mandatory nonempty strings; middle-name requirement deserves deliberate treatment. Controllers are local and disposed; profile values are not passed onward. |
| `CompleteProfileContactV12Screen` (1140) | Reuse phone, residential address, 37-state picker and fixed Nigeria country. Continue currently hardcodes NIN (1200); new destination is method selection. Only nonempty phone/address/state validation exists. |
| `NinEntryV12Screen` (1286), `BvnEntryV12Screen` (1209) | Reuse number-entry visuals/info cards. Both accept when stripping nondigits yields length 11. Neither currently passes `digitsOnly` nor `maxLength` to `_Input`; numeric keyboard alone does not enforce input. NIN currently continues to selfie; BVN currently completes tier 2. Both must terminate Basic without face. |
| `KycSelfieV12Screen` (1444), `FaceDetectionV12Screen` (1507), `FaceReviewV12Screen` (1578) | Reuse face preparation/scan/review visuals for Advanced first step. Review currently routes to tier-1 completion and explicitly mentions NIN matching; adapt that continuation/copy to ID selection. |
| `Tier3SelectIdScreen` (1632), `Tier3UploadIdScreen` (1688) | Reuse government ID choice/upload structure after Advanced face. Third choice uses driver's-license art but repeats “International Passport”; selected choice is not passed to upload. Front upload is required; back optional. |
| `Tier3SelectDocumentScreen` (1750), `Tier3UploadDocumentScreen` (1814), `Tier3AddressReviewScreen` (1856) | Existing supporting documents are address proof. Choice is local and not passed forward. Upload/review are fixed preview artifacts. Adapt only after supporting-document meaning is settled. |
| `Tier3FaceSubmitScreen` (1927) | Existing face stage occurs last and shows a static image. It must not remain a second face requirement after new Advanced face-first routing. Preserve class if unreachable rather than deleting staged source. |
| `VerificationProcessingV12Screen` (1359), `TierCompletionV12Screen` (1419), `FullyVerifiedV12Screen` (1982) | Reuse result/processing visuals with explicit preview semantics, Basic/Advanced outcomes and deliberate state transition. Processing blindly advances after 1200ms. |
| `_Input` (3390), `_PrimaryButton` (3488), `_SecondaryButton` (3489) | Shared controls already support optional formatters, max length, enabled state, and haptic action. |
| `_V12ChoiceTile` (2568), `_KycInfoCard` (2235), `_KycRequirementLine` (2408) | Suitable for NIN/BVN selection, contextual explanation and preparation lists. |
| `_Tier3UploadLargeCard` (2668), `_Tier3UploadSmallCard` (2710), `_Tier3DocumentUploadCard` (2745), `_UploadedDocumentFile` (2780), `_Tier3DocumentNotice` (2817) | Existing upload-card styles can be reused with accurate selection/file state. Current cards do not acquire real camera/gallery/files. |

Reusable shared widgets imported by this file include `DavoResultScreen`, `DavoSuccessMark`, `DavoStatePicker`, and `showDavoDatePicker`. Existing art includes NIN/ID requirement icons, selfie preparation image, face review image, ID/passport/driver icons, document-edit icon and upload/camera/cloud icons. Tier medals and tier-number artwork should not dictate the new information architecture.

## Legacy island to preserve

The older `KycOverviewScreen` (203), `KycMethodScreen` (217), `GovernmentIdScreen` (228), `SelfieScreen` (236), and `FaceDetectionScreen` (245) form an internally connected island. Searches across `lib` found no live external construction of the old overview/method or old selfie/face screens. `KycOverviewScreen` contains fixed phone/email “Verified” and profile “Completed” labels. `GovernmentIdScreen` still contains “Errandy community” copy. Its upload sheet only dismisses on Take Photo/Gallery/File.

`AddressUpgradeScreen` (269) is reachable from that old overview and the separate legacy limits chain (`TransactionLimitsScreen` → `_LimitDetailScreen` → `IncreaseLimitsScreen`). Current settings menu does not expose the old `TransactionLimitsScreen`. Preserve these classes and their assets because this audit does not authorize deletion of the user's modified/staged work.

## Preview state and side effects

`PreviewAccountState` currently has one process-local value: `static final setupComplete = ValueNotifier<bool>(false)` (`lib/core/preview/preview_account_state.dart:6`). There is no Basic/Advanced status, selected method, profile draft, backend verification response, rejected/pending outcome or persistence.

Only `FullyVerifiedV12Screen`'s **Back to Home** handler sets `setupComplete=true` (profile flow line 1990). Merely reaching the success screen does not write it. Tier 1/2 completion writes no shared state. The full success screen nevertheless says “Your Account is Fully Verified” and promises all features/higher limits even though ID uploads, face photos and processing are previews.

Dashboard listens to `setupComplete` (line 50). False shows the setup banner and allocates three complete asset rows; true hides the banner and allocates four (line 121). This changes viewport space, not asset authorization: the BTC/ETH/USDT/USDC/SOL asset list remains scrollable. No other app writer/readers were found. Logout sets only `PreviewAuthState.unlocked=false`; it does not reset account setup status, so setup completion survives logout within the running preview process.

Uploads only flip local booleans: ID `front/back`; supporting document `uploaded`. ID back has no visible selected-file state and is not consumed. Document upload renders a canned file and review uses fixed address art/text. Face detection is an animated black placeholder advanced by tapping it, with a fixed face image on review. Processing always replaces itself after 1200ms; there is no failure path or server response.

## Document ambiguity and factual options

The active ID screen offers National ID card, International Passport and a duplicate Passport label with driver's-license artwork. Upload front says JPG/PNG/PDF max 5MB and back says Optional. Those are ID images.

The active supporting-document chooser explicitly says address verification and offers Utility Bill (Electricity/Water/Internet/etc), Bank Statement (last 3 months), Government Document (e.g. tax certificate), and Tenancy Agreement. Review renders an address-proof image with a hardcoded Lagos address. The old `AddressUpgradeScreen` separately lists utility bill (last 3 months), bank statement (last 6 months/from another bank) and tenancy agreement plus landlord utility bill. These timeframes differ, so they should not be treated as established policy.

## Existing test dependencies (read, not run)

| Test | Current contract affected by redesign |
| --- | --- |
| `test/returning_auth_preview_test.dart:38` | Tier 1 intro starts profile; Tier 2 intro starts BVN. |
| same file line 152 | BVN result is Tier 2, face review result is Tier 1, and next actions continue serial tiers. |
| same file line 216 | Completed contact opens NIN; completed NIN opens selfie. This expectation directly conflicts with the requested Basic flow. |
| `test/mobile_regressions_test.dart:52` | Dashboard setup action opens `KycTierOverviewScreen`. |
| `test/dashboard_asset_scrolling_test.dart:59` | Directly pushes `FullyVerifiedV12Screen`, taps Back to Home and expects setup banner removed, four visible rows, fifth scrollable. Both test setup/teardown reset `setupComplete`. |
| `test/nigeria_dropdown_test.dart:10` | Contact state picker contains 37 choices/FCT, supports search/clear/cancel, preserves selection, and fixes country to Nigeria; standalone picker checks keyboard and narrow-screen behavior. |

No existing dedicated end-to-end Advanced upload test was found. New route tests should assert that Basic NIN and BVN both bypass all face screens; Advanced reaches face before any ID/document screen; ID and supporting document remain separate; and outcome state changes only at the deliberate completion action. Existing dashboard scrolling and state-picker contracts should remain covered.
