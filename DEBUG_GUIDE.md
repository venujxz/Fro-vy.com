# Platform-Specific Debugging Guide

Quick reference for troubleshooting on each platform.

## iOS / macOS

### Enable Debug Logging
```bash
# macOS
log stream --predicate 'processImageName == "frovy_app"' --level debug

# iOS (simulator)
xcrun simctl spawn booted log stream --level=debug --predicate 'process=frovy_app'
```

### Common Issues

**Issue:** Camera permission denied
```
Check: ios/Runner/Info.plist
- NSCameraUsageDescription
- NSPhotoLibraryUsageDescription
```

**Issue:** Backend connection fails
```
macOS/iOS uses: http://localhost:3000
Check: Firewall settings if backend is on different machine
```

**Issue:** Image picker crashes
```
Ensure Info.plist has NSPhotoLibraryUsageDescription
```

---

## Android

### Enable Debug Logging
```bash
adb logcat | grep -i frovy
# or
adb logcat flutter:V *:S
```

### Common Issues

**Issue:** Camera not working
```
Check AndroidManifest.xml permissions:
- android.permission.CAMERA
- android.permission.RECORD_AUDIO
```

**Issue:** Backend connection fails
```
Android Emulator uses: http://10.0.2.2:3000
Physical device uses: http://<your-backend-ip>:3000
```

**Issue:** Storage permission denied
```
Check targetSdk and minSdk versions
Android 13+: READ_MEDIA_IMAGES, READ_MEDIA_VIDEO permissions required
```

**Issue:** "No module named 'android'"
```bash
flutter clean
rm -rf pubspec.lock
flutter pub get
```

---

## Windows

### Enable Debug Logging
```bash
# In VS Code Debug Console
# Logs appear automatically when running with debugger
```

### Common Issues

**Issue:** App won't start
```
Ensure Visual Studio C++ build tools are installed
Run: flutter doctor -v
```

**Issue:** Backend connection fails
```
Windows uses: http://localhost:3000
Check: Firewall (port 3000 should be allowed)
```

**Issue:** Build fails with CMake error
```bash
flutter clean
del -r windows/build
flutter pub get
flutter run -d windows
```

---

## Linux

### Enable Debug Logging
```bash
# Check syslog
journalctl -f | grep frovy

# Or use strace
strace -e openat -p $(pidof frovy_app)
```

### Common Issues

**Issue:** GTK dependencies missing
```bash
sudo apt-get install libgtk-3-dev

# Ubuntu 20.04:
sudo apt-get install cmake pkg-config libgtk-3-dev clang ninja-build
```

**Issue:** Can't find flutter
```bash
export PATH="$PATH:$HOME/flutter/bin"
```

**Issue:** Backend connection fails
```
Linux uses: http://localhost:3000
Check: Service is running on port 3000
```

---

## Web

### Enable Debug Logging
```
Browser DevTools > Console
Look for print() output and errors
```

### Common Issues

**Issue:** CORS errors when calling backend
```
Backend must allow:
- Access-Control-Allow-Origin: *
- Content-Type: application/json
```

**Issue:** Image picker doesn't work
```
Use File input from web standards
Check browser permissions for file access
```

**Issue:** ML Kit not available
```
google_mlkit_text_recognition may not work on web
Fallback to server-side OCR processing
```

**Issue:** Camera access denied
```
Web doesn't have native camera support
Use image picker instead
```

---

## General Debugging

### Check Platform
```dart
import 'package:flutter/foundation.dart';
import 'dart:io';

void debugPlatform() {
  if (kIsWeb) print('Running on Web');
  if (Platform.isAndroid) print('Running on Android');
  if (Platform.isIOS) print('Running on iOS');
  if (Platform.isMacOS) print('Running on macOS');
  if (Platform.isWindows) print('Running on Windows');
  if (Platform.isLinux) print('Running on Linux');
}
```

### Check Backend URL
```dart
import 'package:frovy_app/util/platform_config.dart';

void main() {
  print('Backend URL: ${PlatformConfig.getBackendUrl()}');
  print('HTTP Timeout: ${PlatformConfig.getHttpTimeout()}');
  print('Platform: ${PlatformConfig.getPlatformName()}');
}
```

### Network Debugging
```bash
# macOS/Linux: Monitor network traffic
sudo tcpdump -i any -n 'tcp port 3000'

# Windows: Use netsh
netsh interface ipv4 show interfaces

# Check if backend is reachable
curl -v http://localhost:3000/personalize-analysis
curl -v http://10.0.2.2:3000/personalize-analysis  # Android emulator
```

---

## Performance Profiling

### All Platforms
```bash
# Build and profile release build
flutter run --profile

# In VS Code, open DevTools:
flutter pub global activate devtools
flutter pub global run devtools
```

### Memory Leaks
```bash
# Android
adb shell dumpsys meminfo

# iOS
Use Instruments in Xcode
Product > Profile > Memory
```

---

## Release Build Issues

### iOS
```bash
flutter build ios --release
# Issues? Check:
# - Code signing certificates
# - iOS Deployment Target matches Podfile
# - All permissions in Info.plist
```

### Android
```bash
flutter build apk --release
# Issues? Check:
# - Signing key configuration
# - Proguard rules
# - All required permissions
```

### macOS
```bash
flutter build macos --release
# Issues? Check:
# - Notarization requirements
# - Code signing
# - Deployment target
```

### Windows
```bash
flutter build windows --release
# Issues? Check:
# - MSVC installation
# - Windows SDK version
# - Path length (255 char limit)
```

### Linux
```bash
flutter build linux --release
# Issues? Check:
# - Build dependencies installed
# - GCC/Clang version
# - GTK version
```

---

## Useful Commands

```bash
# Check all platforms
flutter doctor -v

# Get dependencies
flutter pub get
flutter pub upgrade

# Clean everything
flutter clean
rm -rf pubspec.lock
rm -rf .dart_tool
flutter pub get

# Run with specific configuration
flutter run --debug    # Debug mode
flutter run --profile  # Profile mode
flutter run --release  # Release mode

# Build for all platforms
flutter build web
flutter build windows
flutter build macos
flutter build linux
flutter build apk      # Android
flutter build ios      # iOS

# Format and analyze
flutter format lib/
flutter analyze
```

---

## Backend Testing

### Local Development
```bash
# Terminal 1: Start backend
npm start  # or your backend command

# Terminal 2: Run Flutter app
flutter run -d android
```

### Test Backend Connectivity
```bash
curl -X POST http://localhost:3000/personalize-analysis \
  -H "Content-Type: application/json" \
  -d '{"extractedText":"sugar, salt", "allergies":[], "medicalConditions":""}'
```

---

## Emergency Fixes

### App Won't Start
```bash
flutter clean
rm -rf pubspec.lock
rm -rf .dart_tool
flutter pub get
flutter run
```

### Out of Memory
```bash
# Reduce image compression
# Reduce OCR batch size
# Check for memory leaks in platform_config.dart
```

### Permissions Issues
```bash
# Clear app data (Android)
adb shell pm clear com.example.frovy_app

# Uninstall and reinstall (all platforms)
flutter uninstall
flutter run
```

### Network Issues
```bash
# Check firewall
# Verify backend is running
# Try different backend URL in platform_config.dart
# Add logging to http requests
```

---

**Last Updated:** March 13, 2026
