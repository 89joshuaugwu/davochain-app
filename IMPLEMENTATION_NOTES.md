# Davochain implementation notes

## Figma sources implemented
- Splash / onboarding: `3418:72059`
- Sign up / Create Account: `3418:73383`
- Create Password: `3418:73484`
- Login + Forgot Password flow: `3418:73656`

## Architecture decisions
- The three onboarding compositions are one stateful screen shell, not three routes.
- Final gift-card onboarding state remains part of the same carousel because it shares the same art/title/body/progress/CTA structure.
- Figma input/error/active screenshots are implemented as runtime widget states.
- Forgot Password email, OTP, new-password and success compositions are one animated state machine on one route.
- Reusable auth field, button, scaffold, entrance animation and route transition components are shared across the flow.
- All visible app assets referenced by this milestone are local files; no temporary Figma asset URL is used at runtime.

## Branding rule
All user-visible branding in this source says **Davochain**. Legacy product-name copy has been removed from the implemented flow.

## Backend boundary
Authentication actions are frontend-complete but are not connected to production APIs yet. The Login button currently exposes a development SnackBar instead of pretending that authentication succeeded.
