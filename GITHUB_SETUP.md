# GitHub Setup Guide for WorkShift App Updates

This guide will help you set up GitHub to host your app version information for automatic updates.

## Step 1: Create GitHub Repository

1. Go to [GitHub](https://github.com) and sign in
2. Click the "+" icon in the top right → "New repository"
3. Name it `workshift` (or any name you prefer)
4. Make it **Public** (so the raw URL is accessible)
5. Click "Create repository"

## Step 2: Push Your Code to GitHub

### Option A: Using GitHub Desktop
1. Download [GitHub Desktop](https://desktop.github.com/)
2. File → Add Local Repository → Select your project folder
3. Commit all files
4. Publish repository to GitHub

### Option B: Using Command Line

```bash
# Initialize git (if not already done)
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit: WorkShift app"

# Add your GitHub repository as remote
# Replace YOUR_USERNAME with your GitHub username
git remote add origin https://github.com/YOUR_USERNAME/workshift.git

# Push to GitHub
git branch -M main
git push -u origin main
```

## Step 3: Add version.json File

1. In your GitHub repository, click "Add file" → "Create new file"
2. Name it `version.json`
3. Copy the content from `version.json.example` or use this template:

```json
{
  "version": "1.0.0",
  "buildNumber": "1",
  "downloadUrl": "https://github.com/YOUR_USERNAME/workshift/releases/latest",
  "forceUpdate": false,
  "releaseNotes": "Initial release of WorkShift app."
}
```

4. Click "Commit new file"

## Step 4: Update the Code

Edit `lib/services/update_checker.dart` and update line 20:

```dart
static const String versionCheckUrl = 
    'https://raw.githubusercontent.com/YOUR_USERNAME/workshift/main/version.json';
```

Replace `YOUR_USERNAME` with your actual GitHub username.

## Step 5: Create GitHub Releases (For Downloads)

When you want to release a new version:

1. Go to your repository → "Releases" → "Create a new release"
2. Tag version: `v1.0.1` (or your version number)
3. Release title: `WorkShift v1.0.1`
4. Description: Your release notes
5. Upload your APK/IPA file
6. Click "Publish release"

Then update `version.json`:

```json
{
  "version": "1.0.1",
  "buildNumber": "2",
  "downloadUrl": "https://github.com/YOUR_USERNAME/workshift/releases/download/v1.0.1/workshift.apk",
  "forceUpdate": false,
  "releaseNotes": "Bug fixes and improvements."
}
```

## Step 6: Update Process

When you release a new version:

1. **Update `pubspec.yaml`**:
   ```yaml
   version: 1.0.1+2
   ```

2. **Update `version.json` in GitHub**:
   - Go to the file in GitHub
   - Click the pencil icon to edit
   - Update version, buildNumber, downloadUrl, and releaseNotes
   - Commit changes

3. **Build your app**:
   ```bash
   flutter build apk --release
   # or
   flutter build ios --release
   ```

4. **Create GitHub Release** with the new APK/IPA

5. **Users will see update notification** when they check for updates

## GitHub Raw URL Format

The raw URL format is:
```
https://raw.githubusercontent.com/USERNAME/REPO/BRANCH/FILENAME
```

Example:
```
https://raw.githubusercontent.com/johndoe/workshift/main/version.json
```

## Security Note

- The repository should be public for the raw URL to work
- Or use GitHub Pages for private repos
- Consider using GitHub Releases for secure downloads

## Testing

1. Make sure `version.json` is in your GitHub repo
2. Update the URL in `update_checker.dart`
3. Set a higher version in `version.json` than your current app
4. Click "Check for Updates" in the app
5. You should see the update dialog

## Troubleshooting

- **404 Error**: Check that the file exists and the URL is correct
- **CORS Error**: GitHub raw URLs should work fine, but if you have issues, use GitHub Pages
- **Not updating**: Ensure the version in JSON is higher than current app version

