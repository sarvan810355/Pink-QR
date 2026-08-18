# QR Bloom — Setup Guide

This repo ships the full `lib/` app (Dart/Flutter), `pubspec.yaml`, and assets.
Native `android/` and `ios/` platform folders are **not** committed (see
`.gitignore`) because they're version-pinned to whatever Flutter SDK builds
them — generating them locally avoids shipping a stale/incompatible Gradle
or Xcode config. Follow the steps below in order.

## 1. Generate native platform folders

```bash
flutter create --platforms=android,ios --org com.qrbloom .
flutter pub get
```

This scaffolds `android/` and `ios/` matching your installed Flutter SDK
version. Then apply the manifest/permission edits below.

## 2. Android — permissions & AdMob

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...>
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    <!-- Only needed if targeting Android 12 (API 32) or below for gallery saves -->
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"
        android:maxSdkVersion="32"/>

    <application ...>
        <!-- AdMob: replace with your real App ID from the AdMob console -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-3940256099942544~3347511713"/>
        <!-- ^ this is Google's public TEST app ID — swap before release -->
        ...
    </application>
</manifest>
```

In `android/app/build.gradle`, `mobile_scanner` requires:

```gradle
android {
    defaultConfig {
        minSdkVersion 21
    }
}
```

## 3. iOS — permissions & AdMob

Edit `ios/Runner/Info.plist`, add:

```xml
<key>NSCameraUsageDescription</key>
<string>QR Bloom uses your camera to scan QR codes.</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>QR Bloom needs photo access to import QR images and save your generated codes.</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>QR Bloom saves your styled QR codes to your photo library.</string>
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-3940256099942544~1458002511</string>
<!-- ^ Google's public TEST app ID — swap before release -->
```

`ios/Podfile` — set the deployment target (required by `mobile_scanner` /
`google_mobile_ads`):

```ruby
platform :ios, '14.0'
```

Then run `cd ios && pod install`.

## 4. Swap AdMob test IDs for real ones

Test ad unit IDs are wired in `lib/services/ads_service.dart`
(`bannerAdUnitId`, `interstitialAdUnitId`). Replace them — and the
`APPLICATION_ID` / `GADApplicationIdentifier` above — with your real AdMob
IDs before release. Never ship test IDs to production.

## 5. App icon

Add `flutter_launcher_icons` as a dev dependency and configure it:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.1

flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/icon/app_icon.png" # 1024x1024 pink QR Bloom mark
  min_sdk_android: 21
  background_color_ios: "#FFF6F9"
```

Drop a 1024×1024 PNG at `assets/icon/app_icon.png` (soft pink rounded QR
mark — a good motif: a small blooming flower sitting on a QR corner), then:

```bash
dart run flutter_launcher_icons
```

## 6. Splash screen

Add `flutter_native_splash`:

```yaml
dev_dependencies:
  flutter_native_splash: ^2.4.1

flutter_native_splash:
  color: "#FFF6F9"
  image: assets/icon/splash_logo.png   # centered logo, transparent bg
  color_dark: "#241B1E"
  image_dark: assets/icon/splash_logo_dark.png
  android_12:
    color: "#FFF6F9"
    image: assets/icon/splash_logo.png
    color_dark: "#241B1E"
    image_dark: assets/icon/splash_logo_dark.png
```

```bash
dart run flutter_native_splash:create
```

## 7. Chime sound (optional but recommended)

`lib/services/feedback_service.dart` plays `assets/sounds/chime.mp3` on
scan success and fails silently if it's missing. Add a short, soft chime
there for the full experience — see `assets/sounds/README.txt`.

## 8. Run it

```bash
flutter pub get
flutter run
```

## Notes

- **State management**: `provider` (see `lib/main.dart` — `HistoryService`,
  `ThemeService`, `PremiumService` are the three app-wide notifiers).
- **Design tokens**: everything visual lives in `lib/theme/app_theme.dart` —
  change palette/spacing/radii there to re-skin the whole app.
- **IAP**: `lib/services/premium_service.dart` is a local flag only, per the
  spec. Wire up the `in_app_purchase` plugin against a real store product ID
  in `SettingsScreen._unlockPremium` when ready to sell it for real.
- **WiFi/vCard formats**: built in `lib/services/qr_content_service.dart`
  following the standard `WIFI:` and `BEGIN:VCARD` specs — verified against
  common scanner apps' expected escaping rules.
