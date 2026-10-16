# Unlock theme correction, build 52

The returning unlock screen used a hardcoded white card while its heading, password label, field and disabled button followed the active theme. This produced nearly white text and a dark field inside a white card when the active app theme was dark.

The card now uses DavoColors.surface and supporting copy uses DavoColors.bodyMuted. Light mode retains a white card, dark heading/labels and white password field; dark mode has a consistent dark card and light text. Blue outer background, layout, authentication, fingerprint fallback and navigation are unchanged.

Validation: 20 focused authentication tests passed; two final phone-size light/dark capture tests passed; flutter analyze --no-pub reported no issues. Independent review found no important issues. Release build 0.19.1+52 completed with the existing package and signing certificate. APK SHA256: 11AC2BB4D4406884D284080839220CE15931D0A6714A51F1180108B7B5B1D57C. Evidence: workspace review/evidence/unlock-theme-52. App was not installed over the user's ongoing PIN-reset session. System notification/PIN-reset analysis is documentation for a future implementation, not a feature in this APK.
