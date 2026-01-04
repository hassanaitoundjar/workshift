#!/bin/bash

# Script to create a GitHub release for WorkShift
# Make sure you're authenticated: gh auth login

VERSION="1.0.1"
TAG="v${VERSION}"
RELEASE_NOTES="Version 1.0.1 - Update Check Test

New Features:
- Added automatic update checking system
- Improved settings screen design
- Enhanced Excel report generation

Bug Fixes:
- Fixed overflow issues in various screens
- Improved responsive design

Performance:
- Optimized app loading time
- Better memory management"

echo "Building Android APK..."
flutter build apk --release

if [ $? -ne 0 ]; then
  echo "⚠️  Android build failed. Continuing with Linux build only..."
  ANDROID_APK=""
else
  ANDROID_APK="build/app/outputs/flutter-apk/app-release.apk"
  echo "✅ Android APK built successfully!"
fi

echo ""
echo "Creating GitHub release ${TAG}..."

# Prepare files array
FILES=("build/linux/x64/release/bundle/workshift")
if [ -n "$ANDROID_APK" ] && [ -f "$ANDROID_APK" ]; then
  FILES+=("$ANDROID_APK")
  echo "📦 Including Android APK in release"
fi

# Create release
gh release create "${TAG}" \
  --title "Version ${VERSION}" \
  --notes "${RELEASE_NOTES}" \
  "${FILES[@]}"

if [ $? -eq 0 ]; then
  echo "✅ Release created successfully!"
  echo "Release URL: https://github.com/hassanaitoundjar/workshift/releases/tag/${TAG}"
  echo ""
  echo "📝 Next steps:"
  echo "1. Update version.json downloadUrl to:"
  if [ -n "$ANDROID_APK" ] && [ -f "$ANDROID_APK" ]; then
    echo "   https://github.com/hassanaitoundjar/workshift/releases/download/${TAG}/app-release.apk"
  fi
  echo "2. Commit and push version.json to repository"
  echo "3. Test the update mechanism in the app"
else
  echo "❌ Failed to create release. Make sure you're authenticated: gh auth login"
  exit 1
fi

