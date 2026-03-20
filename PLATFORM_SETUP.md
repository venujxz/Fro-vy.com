# Frovy App - Cross-Platform Setup Guide

This document outlines the proper setup for running the Frovy app on all supported platforms.

## Supported Platforms

- ✅ **iOS** (14.0+)
- ✅ **Android** (API 23+)
- ✅ **macOS** (11.0+)
- ✅ **Windows** (10+)
- ✅ **Linux** (Ubuntu 20.04+)
- ✅ **Web** (Chrome, Firefox, Safari, Edge)

## Platform-Specific Setup

### iOS Setup

**Prerequisites:**
- Xcode 12.0+
- iOS 14.0 or higher
- CocoaPods

**Steps:**
1. Open iOS project: `open ios/Runner.xcworkspace`
2. Select Runner target
3. Go to Build Settings and ensure minimum iOS version is 14.0
4. Run: `flutter pub get && flutter run -d ios`

**Key Configurations:**
- Minimum iOS version: **14.0** (set in `ios/Podfile`)
- Camera permissions defined in `ios/Runner/Info.plist`
- Photo library access for image picker

---

### Android Setup

**Prerequisites:**
- Android SDK 23+
- Android Studio
- Java JDK 11+

**Steps:**
1. Open Android project: `open android/app`
2. Sync Gradle files
3. Run: `flutter pub get && flutter run -d android`

**Key Configurations:**
- Minimum SDK version: **23** (set in `android/app/build.gradle.kts`)
- Target SDK: Automatically handled by Flutter
- Permissions in `android/app/src/main/AndroidManifest.xml`:
  - Camera
  - Microphone
  - Read/Write External Storage
  - Internet
  - Android 13+ Media file permissions

**Emulator Note:**
- The app uses `10.0.2.2:3000` for backend calls when running on Android Emulator
- For physical devices, update the backend URL in `lib/util/platform_config.dart`

---

### macOS Setup

**Prerequisites:**
- Xcode 12.0+
- macOS 11.0+
- CocoaPods

**Steps:**
1. Run: `flutter pub get`
2. Run: `flutter run -d macos`

**Key Configurations:**
- Minimum macOS version: **11.0** (set in `macos/Podfile`)
- Camera and file access permissions configured

---

### Windows Setup

**Prerequisites:**
- Visual Studio 2022 (Community or higher)
- Windows 10+
- CMake 3.14+

**Steps:**
1. Run: `flutter pub get`
2. Run: `flutter run -d windows`

**Build Release:**
```bash
flutter build windows --release
```

---

### Linux Setup

**Prerequisites:**
- CMake 3.14+
- GTK 3.0+
- pkg-config
- GCC/Clang

**Install dependencies (Ubuntu/Debian):**
```bash
sudo apt-get install cmake pkg-config libgtk-3-dev
```

**Steps:**
1. Run: `flutter pub get`
2. Run: `flutter run -d linux`

---

### Web Setup

**Prerequisites:**
- Chrome, Firefox, Safari, or Edge browser

**Steps:**
1. Run: `flutter pub get`
2. Run: `flutter run -d chrome`
   - Or `-d firefox`, `-d safari`, `-d edge`

**Key Configurations:**
- Web deployment URL should be configured in `lib/util/platform_config.dart`
- Currently backend defaults to `http://localhost:3000` for web development
- For production, update the backend URL in `PlatformConfig.getBackendUrl()`

---

## Platform-Agnostic Features

### Backend URL Handling

The app intelligently detects the platform and uses the appropriate backend URL:

```dart
// Automatically selects the correct URL based on platform:
// - Android Emulator: http://10.0.2.2:3000
// - iOS/macOS/Desktop: http://localhost:3000
// - Web: Configured separately
final url = PlatformConfig.getBackendUrl();
```

Edit `lib/util/platform_config.dart` to customize backend URLs for your deployment.

### Camera & Image Support

- **Mobile (iOS/Android):** Native camera access
- **Desktop (macOS/Windows/Linux):** Image picker from file system
- **Web:** Limited to file picker

---

## Dependencies & Versions

Key cross-platform dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  camera: ^0.11.0+2          # Camera support
  image_picker: ^1.0.7        # Image selection
  path_provider: ^2.1.2       # File path access
  http: ^1.2.1                # Network requests
  google_mlkit_text_recognition: ^0.15.1  # OCR
  easy_localization: ^3.0.8   # Multi-language
  shared_preferences: ^2.5.4  # Local storage
```

All dependencies support all target platforms.

---

## Common Issues & Solutions

### Issue: "No devices found"
**Solution:** Ensure you have an iOS simulator running or an Android emulator/device connected.

### Issue: Android emulator can't reach backend
**Solution:** Use `10.0.2.2` instead of `localhost` (automatically handled by `PlatformConfig`)

### Issue: iOS camera permission denied
**Solution:** Check `ios/Runner/Info.plist` for camera permission strings

### Issue: Web camera access issues
**Solution:** Camera is not supported on web; use image picker instead

### Issue: macOS requires notarization for distribution
**Solution:** See Apple's Developer documentation for code signing and notarization

---

## Running Tests

```bash
flutter test
```

---

## Building for Release

### iOS
```bash
flutter build ios --release
```

### Android
```bash
flutter build apk --release
```

### macOS
```bash
flutter build macos --release
```

### Windows
```bash
flutter build windows --release
```

### Linux
```bash
flutter build linux --release
```

### Web
```bash
flutter build web --release
```

---

## Environment Variables

Create a `.env` file for sensitive configuration:

```env
BACKEND_URL=https://your-backend.com
API_KEY=your-api-key
```

Load in Dart:
```dart
String backendUrl = PlatformConfig.getBackendUrl();
```

---

## Git Workflow

**Avoid committing platform-specific build files:**

```bash
# Already configured in .gitignore:
build/
android/
ios/
windows/
linux/
macos/
web/
.dart_tool/
pubspec.lock
```

---

## Platform Matrix

| Feature | iOS | Android | macOS | Windows | Linux | Web |
|---------|-----|---------|-------|---------|-------|-----|
| Camera | ✅ | ✅ | ✅ | ⚠️ | ⚠️ | ❌ |
| Image Picker | ✅ | ✅ | ✅ | ✅ | ✅ | ⚠️ |
| Text Recognition (OCR) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| File Storage | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Network Requests | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Localization | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Dark Theme | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

✅ = Fully supported | ⚠️ = Limited support | ❌ = Not supported

---

## Support & Troubleshooting

For detailed troubleshooting:
1. Check Flutter's official documentation: https://flutter.dev
2. Review plugin-specific issues on pub.dev
3. Check platform-specific logs:
   - iOS: `xcrun simctl spawn booted log stream --level=debug`
   - Android: `adb logcat`
   - Others: Check the console output in VS Code

---

Last Updated: March 13, 2026
