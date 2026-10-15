# Surface and information refinement 45

## Result

Light-mode wallet, payment and asset-selection sheets use white (#FFFFFF); search inputs use the softer canvas (#F8F9FB). Dark mode retains its elevated surface and field tokens. Existing app-theme sheet tint remains transparent.

Password recovery transitions align their content at the top. The password stage scrolls on short screens while the action stays at the bottom when space permits. Initial fingerprint setup also starts at the top; success outcomes remain centred. Password criteria can wrap on narrow screens.

The Naira withdrawal visibility icon follows the balance label, with a 48 px touch target. The deposit address card uses a compact label/address row, Show all/Hide, and a full-address copy action. Expanded addresses wrap; existing QR, network and bottom copy controls remain available.

Privacy, Terms, FAQs and About use structured local articles with readable headings and scrolling. FAQs have expandable answers. Published SettingsContentStore overrides continue to take precedence immediately.

## Editing content

Edit `lib/features/profile_settings/presentation/settings_articles.dart` to replace headings, introductions and sections. Alternatively call `SettingsContentStore.update(title, body)` with one of the existing exact menu titles. No sample or preview labels appear in the reader.

The bundled privacy and terms text is editorial copy for the requested product review, not business-approved legal policy. Obtain the business's actual data practices and legal approval before public publication. The copy deliberately avoids invented registration details, licences, retention periods, response guarantees or security certifications.

## Verification

Focused regression checks cover password top alignment, inline eye placement and toggling, compact and expanded deposit addresses, full-address copying, sheet/search colours, asset filtering, FAQ expansion, live content overrides and enlarged text. Eighteen light/dark captures were generated and representative password, withdrawal, deposit, selection and article views inspected.

Production-source analyzer passed with no issues. Full-suite and Android release verification are recorded in the workspace review evidence.

Onboarding was inspected in the previous batch and has slow-swipe/settling and large-text regression coverage. No new transition fault was reproduced from the supplied in-motion screenshot.
