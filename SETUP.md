# QR Bloom — Setup Guide

Native `android/` and `ios/` folders, the app icon, splash screen, and a
placeholder chime sound are all committed and ready to run — this is a
clone-and-go project.

## 1. Run it

```bash
flutter pub get
flutter run
```

That's it for a local debug run using Google's public **test** AdMob IDs
(already wired in). Before releasing to a store, do the following:

## 2. Swap AdMob test IDs for real ones

Test ad unit IDs are wired in `lib/services/ads_service.dart`
(`bannerAdUnitId`, `interstitialAdUnitId`). Replace them — and the AdMob
App IDs below — with your real IDs from the AdMob console. Never ship
test IDs to production.

- Android: `com.google.android.gms.ads.APPLICATION_ID` meta-data in
  `android/app/src/main/AndroidManifest.xml`
- iOS: `GADApplicationIdentifier` in `ios/Runner/Info.plist`

## 3. Set your own bundle/application ID

Both platforms currently use `com.qrbloom.qr_bloom` (Android
`applicationId` in `android/app/build.gradle.kts`, iOS bundle ID in the
Xcode project). Change these to your own before publishing.

## 4. App icon & splash screen

Already generated from `assets/icon/app_icon.png` /
`splash_logo.png` / `splash_logo_dark.png` (a pink QR-corner + blooming
flower mark, produced by `scripts/generate_icon.py` since no design tool
was available when this project was built). To change the artwork:

1. Edit/replace the PNGs in `assets/icon/` (or tweak and re-run
   `python3 scripts/generate_icon.py`).
2. Regenerate:
   ```bash
   dart run flutter_launcher_icons
   dart run flutter_native_splash:create
   ```

Config for both lives at the bottom of `pubspec.yaml`
(`flutter_launcher_icons:` / `flutter_native_splash:` keys).

## 5. Chime sound

`assets/sounds/chime.wav` is a synthesized placeholder (a soft two-note
bell "ting", made by `scripts/generate_chime.py`). It's fine to ship as
is, or drop in a nicer recorded sound at the same path — see
`assets/sounds/README.txt`. `FeedbackService` fails silently if the file
is ever missing, so this is never a hard dependency.

## 6. Camera permission denial UX

Already wired with a friendly in-app screen (`PermissionDeniedView`)
instead of relying on the raw OS dialog — nothing to configure, just
verify the manifest strings above stay in sync if you change them.

## Notes for maintainers

- **State management**: `provider` (see `lib/main.dart` — `HistoryService`,
  `ThemeService`, `PremiumService` are the three app-wide notifiers).
- **Design tokens**: everything visual lives in `lib/theme/app_theme.dart` —
  change palette/spacing/radii there to re-skin the whole app.
- **IAP**: `lib/services/premium_service.dart` is a local flag only, per the
  spec. Wire up the `in_app_purchase` plugin against a real store product ID
  in `SettingsScreen._unlockPremium` when ready to sell it for real.
- **WiFi/vCard formats**: built in `lib/services/qr_content_service.dart`
  following the standard `WIFI:` and `BEGIN:VCARD` specs.
- **Heart-shaped QR modules**: `lib/widgets/heart_qr_painter.dart` hand-paints
  data modules as hearts (finder-pattern corners stay plain squares for scan
  reliability) using a high error-correction level. Verified against an
  independent decoder (OpenCV) via `scripts/verify_heart_qr.py` — requires
  `pip install opencv-python-headless segno` to re-run.
- Regenerating `android/`/`ios/` from scratch (e.g. after a major Flutter
  upgrade) is safe: `flutter create --platforms=android,ios --org com.qrbloom .`
  won't overwrite `lib/`, then re-apply steps 2–4 above.
