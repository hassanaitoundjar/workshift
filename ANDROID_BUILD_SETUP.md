# Android Build Setup Guide

To build Android APKs, you need to set up the Android SDK.

## Quick Setup (Recommended)

### Option 1: Install Android Studio

1. Download Android Studio from: https://developer.android.com/studio
2. Install and launch Android Studio
3. Go through the setup wizard (it will install Android SDK automatically)
4. Set up Android SDK path:
   ```bash
   flutter config --android-sdk /path/to/Android/Sdk
   ```
   (Usually: `~/Android/Sdk` on Linux)

### Option 2: Install Android SDK Command Line Tools Only

1. Download command line tools from: https://developer.android.com/studio#command-tools
2. Extract to a directory (e.g., `~/android-sdk`)
3. Set environment variables:
   ```bash
   export ANDROID_HOME=~/android-sdk
   export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
   ```
4. Install SDK components:
   ```bash
   sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"
   ```
5. Configure Flutter:
   ```bash
   flutter config --android-sdk $ANDROID_HOME
   ```

## Verify Setup

```bash
flutter doctor
```

You should see:
```
[✓] Android toolchain - develop for Android devices
```

## Build Android APK

Once set up, you can build:

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release
```

The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

## Current Status

The `create_release.sh` script will:
- ✅ Try to build Android APK automatically
- ✅ If Android SDK is not available, it will skip Android and continue with Linux build
- ✅ Include both builds in the release if both are available

## For Now

You can create the release with just the Linux build. When you set up Android SDK later, the script will automatically include the Android APK in future releases.

