# Davochain appearance design

The user authorized planning and implementation automatically on 8 October 2026. This is an architectural change to existing theme ownership, informed by the dark-mode readiness audit. Keep work in the current workspace and do not commit automatically.

Use context-resolved `DavoColors`, a ThemeExtension, alongside Material ColorScheme. Preserve immutable AppColors for brand/document constants. Never use a process-global dark flag or invert rendered artwork. Dark canvas #0B1220, surface #101827, elevated #192437, field #162135, text #F3F6FC, secondary #AAB6C8, hint #96A5BC, border #60738F, divider #2B3B53, link #8EADFF, soft blue #1B2E55; filled blue CTA #135CF7 with white stays fixed. Sora sizes and accepted splash stay unchanged. Multicolor logos, flags, gift cards and portraits retain original colors. Receipt paper remains a light theme subtree and exports stay white with dark ink.

AppearanceController owns ThemeMode, defaults System, restores a valid saved name before runApp, and persists using SharedPreferencesAsync. Invalid/missing preference falls back System. Failed writes retain the previous mode and show an actionable error. Save applies after persistence; Back cancels the draft. Appearance selection is semantic and previews a live sample. System mode follows platform brightness while running.

Replace explicit UI text/surface/border colors by role within widget owners. Preserve on-brand white foregrounds, QR paper and document colors. Make system bars agree with actual surface and input keyboard brightness; retain white icons on blue auth/splash. Sheets, dialogs, loading/result scenes, selectors and native pickers participate. No changes to mock financial or authentication behavior.

Acceptance: preference persistence/failure/cancellation/system changes tested; representative auth, Dashboard, trading, gift cards, Verification and Appearance screens render in both modes and at 2x text; exports light in dark app; reduced motion works; analyzer and regression suite pass. Build Android release and inspect installed dark/light screens before calling all reachable UI complete. iOS/native biometric providers and exhaustive screen-reader/performance evidence remain separately bounded.

Alternatives rejected: Material ColorScheme alone leaves explicit custom light colors unchanged; globally mutable AppColors makes nested light receipts and previews incorrect. Context-resolved tokens plus targeted migration provide correct nested theming.
