#!/bin/bash

# WorkShift GitHub Setup Script
# This script helps you push your app to GitHub and set up version checking

echo "🚀 WorkShift GitHub Setup"
echo "========================"
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed. Please install Git first."
    exit 1
fi

# Check if already a git repository
if [ -d .git ]; then
    echo "✅ Git repository already initialized"
else
    echo "📦 Initializing Git repository..."
    git init
    echo "✅ Git repository initialized"
fi

# Add all files
echo "📝 Adding files to Git..."
git add .

# Check if there are changes to commit
if git diff --staged --quiet; then
    echo "ℹ️  No changes to commit"
else
    echo "💾 Committing changes..."
    git commit -m "Initial commit: WorkShift app with update checker"
    echo "✅ Changes committed"
fi

echo ""
echo "📋 Next Steps:"
echo "=============="
echo ""
echo "1. Create a GitHub repository:"
echo "   - Go to https://github.com/new"
echo "   - Name it 'workshift' (or your preferred name)"
echo "   - Make it PUBLIC (required for raw URLs)"
echo "   - Don't initialize with README, .gitignore, or license"
echo ""
echo "2. Add the remote and push:"
echo "   git remote add origin https://github.com/YOUR_USERNAME/workshift.git"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "3. Add version.json file to GitHub:"
echo "   - Go to your repository on GitHub"
echo "   - Click 'Add file' → 'Create new file'"
echo "   - Name it 'version.json'"
echo "   - Copy content from version.json.example"
echo "   - Commit the file"
echo ""
echo "4. Update lib/services/update_checker.dart:"
echo "   - Replace 'yourusername' with your GitHub username"
echo "   - Replace 'workshift' if you used a different repo name"
echo ""
echo "5. Test the update checker:"
echo "   - Update version.json with a higher version number"
echo "   - Click 'Check for Updates' in the app"
echo ""
echo "✨ Setup complete! Follow the steps above to push to GitHub."

