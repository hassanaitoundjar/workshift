#!/bin/bash

# Build Android APK for Workshift App
# This script builds a release APK

set -e  # Exit on error

FLUTTER="/home/laradev/development/flutter/bin/flutter"
PROJECT_DIR="/home/laradev/backup/workshift"

echo "🚀 Building Android APK for Workshift..."
echo "================================================"

cd "$PROJECT_DIR"

# Step 1: Clean previous builds
echo "📦 Cleaning previous builds..."
$FLUTTER clean

# Step 2: Get dependencies
echo "📥 Getting dependencies..."
$FLUTTER pub get

# Step 3: Generate localizations
echo "🌍 Generating localizations..."
$FLUTTER gen-l10n

# Step 4: Build APK
echo "🔨 Building release APK..."
$FLUTTER build apk --release

# Step 5: Show output location
echo ""
echo "================================================"
echo "✅ Build completed successfully!"
echo ""
echo "📱 APK Location:"
APK_PATH="$PROJECT_DIR/build/app/outputs/flutter-apk/app-release.apk"
if [ -f "$APK_PATH" ]; then
    APK_SIZE=$(du -h "$APK_PATH" | cut -f1)
    echo "   $APK_PATH"
    echo "   Size: $APK_SIZE"
    echo ""
    echo "📋 You can install this APK on your Android device!"
else
    echo "   ⚠️  APK not found at expected location"
fi
echo "================================================"
