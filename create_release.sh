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

echo "Creating GitHub release ${TAG}..."

# Create release
gh release create "${TAG}" \
  --title "Version ${VERSION}" \
  --notes "${RELEASE_NOTES}" \
  build/linux/x64/release/bundle/workshift

if [ $? -eq 0 ]; then
  echo "✅ Release created successfully!"
  echo "Release URL: https://github.com/hassanaitoundjar/workshift/releases/tag/${TAG}"
else
  echo "❌ Failed to create release. Make sure you're authenticated: gh auth login"
  exit 1
fi

