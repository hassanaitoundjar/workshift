# Quick Release Guide

## Option 1: Using GitHub CLI (Recommended)

1. **Authenticate**:
   ```bash
   gh auth login
   ```
   Follow the prompts to authenticate.

2. **Create the release**:
   ```bash
   ./create_release.sh
   ```

## Option 2: Manual Release via Web Interface

1. **Build Android APK** (if Android SDK is set up):
   ```bash
   flutter build apk --release
   ```
   APK location: `build/app/outputs/flutter-apk/app-release.apk`

2. **Go to GitHub Releases**:
   https://github.com/hassanaitoundjar/workshift/releases/new

3. **Fill in the form**:
   - **Tag**: `v1.0.1` (or create new tag)
   - **Release title**: `Version 1.0.1`
   - **Description**: Copy from `version.json` releaseNotes
   - **Attach binaries**: 
     - Upload `build/linux/x64/release/bundle/workshift` (Linux)
     - Upload `build/app/outputs/flutter-apk/app-release.apk` (Android, if built)

4. **Click "Publish release"**

## Option 3: Using GitHub API (if you have a token)

```bash
export GH_TOKEN=your_github_token
./create_release.sh
```

## After Creating the Release

The release will be available at:
- https://github.com/hassanaitoundjar/workshift/releases/latest

The update check in your app will automatically point to this release!

