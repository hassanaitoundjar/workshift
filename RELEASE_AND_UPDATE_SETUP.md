# GitHub Release and Update Setup Guide

This guide explains how to set up GitHub releases so the app's update mechanism works correctly.

## Current Status

- ✅ Update checker is implemented and working
- ✅ Version.json file is configured
- ⚠️ Need to create GitHub release with APK attached
- ⚠️ Download URL needs to point to direct APK download

## Step-by-Step Setup

### 1. Update version.json in Repository

Make sure `version.json` is committed to your repository with the correct version:

```json
{
  "version": "1.0.1",
  "buildNumber": "2",
  "downloadUrl": "https://github.com/hassanaitoundjar/workshift/releases/download/v1.0.1/app-release.apk",
  "forceUpdate": false,
  "releaseNotes": "Version 1.0.1\n\nNew Features:\n- Added automatic update checking system\n- Improved settings screen design\n- Enhanced Excel report generation"
}
```

**Important:** The `downloadUrl` must point to the direct download link of the APK file, not the releases page.

### 2. Create GitHub Release

You have two options:

#### Option A: Using GitHub CLI (Recommended)

1. **Authenticate with GitHub:**
   ```bash
   gh auth login
   ```

2. **Create the release with APK:**
   ```bash
   cd /home/laradev/backup/workshift
   
   # Create release tag and upload APK
   gh release create v1.0.1 \
     --title "Version 1.0.1" \
     --notes "Version 1.0.1

   New Features:
   - Added automatic update checking system
   - Improved settings screen design
   - Enhanced Excel report generation
   
   Bug Fixes:
   - Fixed overflow issues in various screens
   - Improved responsive design" \
     build/app/outputs/flutter-apk/app-release.apk
   ```

#### Option B: Using GitHub Web Interface

1. Go to your repository: https://github.com/hassanaitoundjar/workshift
2. Click "Releases" → "Create a new release"
3. **Tag version:** `v1.0.1`
4. **Release title:** `Version 1.0.1`
5. **Description:** Add release notes
6. **Attach APK:** Drag and drop `build/app/outputs/flutter-apk/app-release.apk`
7. Click "Publish release"

### 3. Verify Direct Download URL

After creating the release, the direct download URL format is:
```
https://github.com/hassanaitoundjar/workshift/releases/download/v1.0.1/app-release.apk
```

Replace:
- `v1.0.1` with your release tag
- `app-release.apk` with your actual APK filename

### 4. Update version.json After Each Release

When you create a new release:

1. **Update version.json:**
   - Change `version` to new version (e.g., "1.0.2")
   - Change `buildNumber` to new build number
   - Update `downloadUrl` to point to new release APK
   - Update `releaseNotes` with new changes

2. **Commit and push:**
   ```bash
   git add version.json
   git commit -m "Update version to 1.0.2"
   git push
   ```

3. **Create new GitHub release** with the new APK

## How It Works

1. **User clicks "Update" button** in Settings
2. **App fetches** `version.json` from GitHub raw URL
3. **Compares versions:** Current app version vs. version in JSON
4. **If update available:** Shows dialog with release notes
5. **User clicks "Update Now":** Opens direct download URL
6. **On Android:** Browser downloads APK, user can install it

## Testing the Update Mechanism

### Test Locally:

1. **Set current version lower** in `pubspec.yaml`:
   ```yaml
   version: 1.0.0+1
   ```

2. **Set version.json higher:**
   ```json
   {
     "version": "1.0.1",
     "buildNumber": "2"
   }
   ```

3. **Run app and click "Update"** - it should detect the update

### Test on Device:

1. Install APK with version `1.0.0+1`
2. Make sure `version.json` has version `1.0.1+2`
3. Click "Update" in Settings
4. Should show update dialog
5. Click "Update Now" - should download APK

## Troubleshooting

### Update not detected?
- Check `version.json` is accessible: https://raw.githubusercontent.com/hassanaitoundjar/workshift/main/version.json
- Verify version in JSON is higher than app version
- Check network connection

### Download doesn't work?
- Verify release exists on GitHub
- Check download URL format is correct
- Ensure APK is attached to release
- On Android, user may need to allow "Install from unknown sources"

### Version comparison issues?
- Make sure version format is `major.minor.patch` (e.g., "1.0.1")
- Build number should be integer (e.g., "2")

## Next Steps

1. ✅ Build APK (already done)
2. ⏳ Create GitHub release with APK
3. ⏳ Update version.json downloadUrl
4. ⏳ Commit and push version.json
5. ⏳ Test update mechanism


