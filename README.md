# QR Bloom 🌸

A premium, "girly minimalist" QR code generator + scanner built with
Flutter — soft pink palette, rounded everything, playful sparkle
animations, and a full aesthetic customizer for your codes.

## Highlights

- **Generate** URL, Text, WiFi, Contact, Social, and Event QR codes with a
  live preview and full customizer (pattern style, pastel palette, cute
  frames, center stickers).
- **Scan** with a pink animated scan-line, flashlight, gallery import, and
  smart content-aware result actions (open link, save contact, copy, etc).
- **History** with search, swipe-to-delete, and heart favorites.
- **Share as Story** — export any QR as a pretty branded card image, ready
  for Instagram Story.
- **Day Pink / Night Pink** theming, local history persistence, and a
  local-flag "Remove Ads + Unlock All Stickers & Frames" premium toggle.

## Getting started

See [`SETUP.md`](./SETUP.md) for generating the native `android/`/`ios/`
folders, permissions, AdMob IDs, app icon, and splash screen setup.

```bash
flutter create --platforms=android,ios --org com.qrbloom .
flutter pub get
flutter run
```

## Project structure

```
lib/
  main.dart              # app entry, Provider wiring
  theme/app_theme.dart   # colors, spacing, radii, gradients, text styles
  models/                # QrHistoryItem, QrStyleConfig
  services/               # history, QR content builders, theme, premium, ads, feedback
  widgets/                # shared UI: buttons, cards, nav bar, QR renderer, sheets
  screens/                # Home, Scan, Generate (+ tabs), History, Detail, Settings
```
