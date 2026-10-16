---
version: alpha
name: Davochain
description: Calm mobile wallet, crypto and gift-card tools in the established blue identity.
colors:
  primary: '#135CF7'
  primarySoft: '#EDF2FD'
  surface: '#FFFFFF'
  ink: '#1C1C1C'
  bodyMuted: '#686868'
typography:
  sans:
    fontFamily: Sora, DavoNotoSans, sans-serif
omitted:
  - section: rounded
    reason: Existing runtime component shapes remain authoritative; this refinement changes no shape tokens.
  - section: spacing
    reason: Existing component-specific Flutter insets remain authoritative; relevant values are documented below.
components:
  button: {}
  receipt: {}
  refresh: {}
  verification: {}
---

# Davochain Design System

## Overview
### Creative North Star
Calm, recognizable money tools. Preserve the existing blue-and-white identity; improve hierarchy and interaction without a wholesale redesign.
### Product context and register
Mobile Flutter wallet, crypto and gift-card product. English interface, Nigerian audience. Financial facts take precedence over decoration. The signup finale has restrained brand expression.

## Colors
Runtime authority: `lib/core/theme/app_theme.dart` and `davo_colors.dart`. Primary #135CF7, primary soft #EDF2FD, light surface #FFFFFF, ink #1C1C1C, secondary text #686868. Resolve theme-aware surfaces through DavoColors; exported receipt paper remains white.

## Typography
Sora for headings, body and financial data, using existing bundled fallbacks. Preserve full amounts and identifiers. Wrap long values; never hide critical facts to fit a layout.

## Layout
Phone-first, scrollable content, fixed accessible primary action where already established. Typical page padding 16?24 logical pixels. Share receipt uses compact label/value rows, stacking at narrow widths or larger text scales.

## Elevation & Depth
Quiet surfaces and thin borders; avoid decorative shadows around every section.

## Shapes
Use existing rounded cards and buttons. The signup illustration uses the wallet silhouette and Davochain logo as its signature.

## Components
### Foundational visual states
Always communicate state in text as well as color.
### Buttons and actions
Reuse DavoPrimaryButton. Keep Continue/Explore available during acknowledgement motion.
### Navigation and data display
Maintain existing routes and receipt details. Share presentation is distinct from the editable settings controls.
### Forms and overlays
Reuse existing fields and export/share sheet; sensitive details remain masked by default.
### Iconography
Existing outlined Material icons and asset icons. Preserve the supplied Davochain logo.
### Motion
Reuse DavoRefreshRegion. Verification acknowledgement makes two 800ms ball-headed orbits followed by a 1000ms check reveal; reduced motion shows completion immediately. No timer authorizes money or navigation.
### Content and data visualization
Show actual account facts. No invented balances, returns, rewards or activity.

## Do's and Don'ts
Borrow clear amount/status hierarchy and grouped facts from references. Keep the current identity and avoid promotional clutter. Deposit initiation is internal processing; only outcomes enter public feeds. Dismissing an alert never deletes its financial transaction.
