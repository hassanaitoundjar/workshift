#!/bin/bash

# Script to set up Firebase Hosting for app updates
# This is a better alternative to GitHub for hosting updates

echo "🔥 Setting up Firebase Hosting for WorkShift Updates"
echo ""

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI not found. Installing..."
    echo "Please run: npm install -g firebase-tools"
    echo "Then run: firebase login"
    exit 1
fi

# Check if user is logged in
if ! firebase projects:list &> /dev/null; then
    echo "❌ Not logged in to Firebase. Please run: firebase login"
    exit 1
fi

echo "✅ Firebase CLI is ready"
echo ""

# Create update_files directory structure
echo "📁 Creating directory structure..."
mkdir -p update_files/downloads
echo "✅ Created update_files/ directory"

# Copy version.json
if [ -f "version.json" ]; then
    cp version.json update_files/
    echo "✅ Copied version.json"
else
    echo "⚠️  version.json not found. Creating default..."
    cat > update_files/version.json << EOF
{
  "version": "1.0.1",
  "buildNumber": "2",
  "downloadUrl": "https://YOUR-PROJECT-ID.web.app/downloads/app-release.apk",
  "forceUpdate": false,
  "releaseNotes": "Version 1.0.1\n\nNew Features:\n- Added automatic update checking system"
}
EOF
    echo "✅ Created default version.json"
fi

# Copy APK if it exists
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    cp build/app/outputs/flutter-apk/app-release.apk update_files/downloads/
    echo "✅ Copied APK to update_files/downloads/"
else
    echo "⚠️  APK not found. Build it first with: flutter build apk --release"
fi

# Create firebase.json if it doesn't exist
if [ ! -f "firebase.json" ]; then
    echo "📝 Creating firebase.json..."
    cat > firebase.json << EOF
{
  "hosting": {
    "public": "update_files",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "headers": [
      {
        "source": "**/*.apk",
        "headers": [
          {
            "key": "Content-Type",
            "value": "application/vnd.android.package-archive"
          }
        ]
      },
      {
        "source": "**/*.json",
        "headers": [
          {
            "key": "Content-Type",
            "value": "application/json"
          }
        ]
      }
    ]
  }
}
EOF
    echo "✅ Created firebase.json"
fi

echo ""
echo "🚀 Next steps:"
echo ""
echo "1. Initialize Firebase (if not done):"
echo "   firebase init hosting"
echo "   - Select 'use an existing project' or create new"
echo "   - Public directory: update_files"
echo "   - Single-page app: No"
echo ""
echo "2. Deploy:"
echo "   firebase deploy --only hosting"
echo ""
echo "3. Update versionCheckUrl in lib/services/update_checker.dart:"
echo "   Change to: https://YOUR-PROJECT-ID.web.app/version.json"
echo ""
echo "4. Update version.json downloadUrl:"
echo "   Change to: https://YOUR-PROJECT-ID.web.app/downloads/app-release.apk"
echo ""
echo "✅ Setup complete! Files are ready in update_files/"


