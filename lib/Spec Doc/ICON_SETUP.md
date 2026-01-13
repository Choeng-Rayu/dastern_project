# App Icon Setup Guide

## Current Status
✅ App name changed to "Das Tern" in both Android and iOS
✅ Flutter Launcher Icons package configured

## Next Steps

### 1. Copy the Icon Image
Please copy your icon image to:
```
/home/rayu/dastern_project/assets/app_icon.png
```

The icon should be:
- At least 1024x1024 pixels
- PNG format
- Square shape

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Generate App Icons
After copying the icon, run:
```bash
flutter pub run flutter_launcher_icons
```

This will automatically generate all required icon sizes for:
- Android (all densities)
- iOS (all sizes)
- Adaptive icons for Android

### 4. Rebuild the App
```bash
flutter clean
flutter build apk
# or
flutter run
```

## Manual Alternative (if above doesn't work)

If you prefer to manually set up icons:

### Android
Replace icons in:
- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` (72x72)
- `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` (48x48)
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` (96x96)
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` (144x144)
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` (192x192)

### iOS
Replace icons in:
`ios/Runner/Assets.xcassets/AppIcon.appiconset/`

You can use online tools like:
- https://appicon.co/
- https://easyappicon.com/

Just upload your 1024x1024 icon and download the generated assets.
