# Legal reader and access refinement 46

## Reading layout

The shared reader uses 14px body copy, 1.65 line height, a 22px article title, distinct section headings, generous paragraph spacing, selectable text and scrolling. Headings are exposed to accessibility services. Paragraphs remain start-aligned: full justification creates uneven word spacing in narrow mobile columns. Theme tokens preserve light and dark contrast.

## Entry points

- Signup country/consent: existing Terms and conditions and Privacy policy text now opens its corresponding sheet. Reading does not tick consent or navigate away.
- Privacy preferences: Read Privacy Policy beside the data/permissions controls.
- Help, Legal & Compliance: two actual policy links; unsupported references to an unavailable AML policy and regulatory page removed.
- Naira withdrawal review: separate 48px information control opens Terms without accepting the consent row. Reserved width keeps text clear of that control.
- Gift-card Buy and Sell review: Terms and Conditions and Privacy Policy links. Sell retains the selected product's inline Trade Terms, acceptance and card-validity controls.
- Verification overview, Basic introduction/method selection and identity-number entry: Privacy link. Personal profile/contact collection also links Privacy.
- Advanced identity/document/selfie/address collection and review steps: Privacy link; processing and completion screens remain focused on their existing status.

The audit also searched crypto Buy/Sell/Swap, deposit, transfer, transaction history and receipt sources. No additional inactive policy/consent references were found in those flows. No new consent gate, policy acceptance, transaction action or backend call was added.

## Content ownership

Structured copy remains in settings_articles.dart and published SettingsContentStore updates still override it. The bundled policy copy is editorial product-review content; actual business practices and legal approval must be reconciled before public publication. No sample/preview label is shown in the UI.

## Verification

Regression coverage checks signup policy taps leave consent false, Privacy and Help links, entered BVN preservation without verification submission, Advanced return without progress, both gift review paths retaining selected-card terms, and withdrawal policy dismissal before explicit agreement. Full-suite, captures and installed-app evidence are retained in the workspace review folder.
