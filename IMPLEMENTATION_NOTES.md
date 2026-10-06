# Davochain v4 Implementation Notes

- The splash now follows Figma node `3418:72060`: cobalt field, centered Davochain white lockup and contained bottom crypto outline artwork.
- Country selection is data-driven; the flag/dial code/phone-length constraint update with the selected country.
- Dashboard and Portfolio are full routes. Wallet/currency selectors, guidelines and share panels are modal states rather than duplicate screens.
- Deposit branches into crypto QR/address UI or Davochain NGD bank-transfer UI.
- Copy actions use the Figma-style dark floating success toast.
- Login and successful transaction-PIN setup route to the dashboard in this prototype.
- Crypto token icons are Flutter-rendered, keeping the new icon treatment while preserving Figma alignment.
- Bitcoin uses the bundled QR asset; other currencies use a deterministic visual QR placeholder until live wallet-address generation is connected.
- Legacy product naming has been removed from shipped UI copy.
