# App Update System Setup Guide

This guide explains how to set up the automatic update checking system for your WorkShift app.

## Overview

The app includes an update checker that:
- Checks for new versions online
- Shows update dialog when new version is available
- Supports force updates (required updates)
- Opens download link when user clicks "Update Now"

## Setup Steps

### 1. Host a Version JSON File

You need to host a JSON file that contains the latest version information. You can host it on:
- GitHub (as a raw file)
- Your own server
- Any static file hosting service

**Example JSON file (`version.json`):**
```json
{
  "version": "1.0.1",
  "buildNumber": "2",
  "downloadUrl": "https://your-domain.com/downloads/workshift.apk",
  "forceUpdate": false,
  "releaseNotes": "Bug fixes and performance improvements.\n- Fixed Excel export issue\n- Improved UI responsiveness"
}
```

### 2. Update the Version Check URL

Edit `lib/services/update_checker.dart` and update the `versionCheckUrl`:

```dart
static const String versionCheckUrl = 
    'https://your-domain.com/api/version.json';
    // Or use GitHub raw URL:
    // 'https://raw.githubusercontent.com/yourusername/workshift/main/version.json';
```

### 3. JSON File Fields

- **version**: The version string (e.g., "1.0.1")
- **buildNumber**: The build number (e.g., "2")
- **downloadUrl**: URL where users can download the new APK/IPA
- **forceUpdate**: `true` if update is mandatory, `false` if optional
- **releaseNotes**: Optional release notes (supports `\n` for new lines)

### 4. Hosting Options

#### Option A: GitHub (Free)
1. Create a repository (or use existing)
2. Create a `version.json` file in the repository
3. Use the raw GitHub URL:
   ```
   https://raw.githubusercontent.com/yourusername/repo/main/version.json
   ```

#### Option B: Your Own Server
1. Upload `version.json` to your server
2. Make sure it's accessible via HTTP/HTTPS
3. Use the full URL in `update_checker.dart`

#### Option C: Firebase Hosting / Netlify / Vercel
1. Upload `version.json` to your hosting service
2. Use the public URL

### 5. Update Process

When you release a new version:

1. **Update `pubspec.yaml`**:
   ```yaml
   version: 1.0.1+2  # version+buildNumber
   ```

2. **Update your hosted `version.json`**:
   ```json
   {
     "version": "1.0.1",
     "buildNumber": "2",
     "downloadUrl": "https://your-domain.com/downloads/workshift-v1.0.1.apk",
     "forceUpdate": false,
     "releaseNotes": "Your release notes here"
   }
   ```

3. **Build and distribute** your new APK/IPA

4. **Users will see update notification** when they click "Check for Updates" in Settings

### 6. Force Updates

To make an update mandatory (users can't dismiss it):
```json
{
  "forceUpdate": true,
  ...
}
```

### 7. Download URLs

For Android APK:
- Direct download link to your APK file
- Example: `https://your-domain.com/downloads/workshift.apk`

For iOS IPA:
- App Store link (recommended)
- Example: `https://apps.apple.com/app/workshift/id123456789`

## Testing

1. Set a higher version in your `version.json` than your current app version
2. Click "Check for Updates" in Settings
3. You should see the update dialog

## Security Notes

- Use HTTPS for version check URL
- Validate the JSON structure on your server
- Consider adding authentication if needed
- Verify download URLs before opening them

## Troubleshooting

- **Update not showing**: Check that version in JSON is higher than current app version
- **Download link not opening**: Ensure URL is valid and accessible
- **Network errors**: Check internet connection and URL accessibility

