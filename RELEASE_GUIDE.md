# How to Create GitHub Releases for WorkShift

When you want to distribute a new version of your app, you can create a GitHub Release. This allows users to download the APK/IPA files directly.

## Quick Steps

1. **Build your app**:
   ```bash
   # For Android
   flutter build apk --release
   # or for app bundle
   flutter build appbundle --release
   
   # For Linux
   flutter build linux --release
   ```

2. **Create a GitHub Release**:
   - Go to: https://github.com/hassanaitoundjar/workshift/releases
   - Click "Create a new release"
   - Choose a tag (e.g., `v1.0.1`) or create a new one
   - Set release title (e.g., "Version 1.0.1")
   - Add release notes (copy from `version.json` releaseNotes)
   - Upload your APK/IPA/Linux build files
   - Click "Publish release"

3. **Update version.json**:
   ```json
   {
     "version": "1.0.1",
     "buildNumber": "2",
     "downloadUrl": "https://github.com/hassanaitoundjar/workshift/releases/latest",
     "forceUpdate": false,
     "releaseNotes": "Your release notes here"
   }
   ```

4. **Commit and push**:
   ```bash
   git add version.json
   git commit -m "Release version 1.0.1"
   git push
   ```

## Alternative: Direct Download Links

If you host files elsewhere (your server, cloud storage, etc.), you can use direct download links:

```json
{
  "downloadUrl": "https://your-domain.com/downloads/workshift-v1.0.1.apk"
}
```

## Current Setup

Currently, the download URL points to the repository page. When you create your first release, update `version.json` to use:
- `https://github.com/hassanaitoundjar/workshift/releases/latest` (for latest release)
- Or a specific release: `https://github.com/hassanaitoundjar/workshift/releases/tag/v1.0.1`

## Notes

- The `releases/latest` URL will automatically redirect to the most recent release
- Users can download APK/IPA files from the release page
- Release notes will be displayed in the update dialog



