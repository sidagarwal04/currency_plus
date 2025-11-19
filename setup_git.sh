#!/bin/bash

echo "🔒 Setting up Git repository safely..."
echo ""

# Initialize git if not already done
if [ ! -d ".git" ]; then
    echo "📦 Initializing Git repository..."
    git init
else
    echo "✅ Git repository already initialized"
fi

echo ""
echo "🔍 Checking if API key file will be ignored..."
if git check-ignore -q lib/config/api_config.dart; then
    echo "✅ api_config.dart is properly ignored"
else
    echo "❌ WARNING: api_config.dart is NOT ignored!"
    echo "   Please check your .gitignore file"
    exit 1
fi

echo ""
echo "📝 Files that will be committed:"
git add .
git status --short | head -20

echo ""
echo "⚠️  IMPORTANT: Review the files above carefully!"
echo ""
echo "🔍 Checking for sensitive files..."

if git ls-files | grep -q "api_config.dart"; then
    echo "❌ ERROR: api_config.dart found in staged files!"
    echo "   DO NOT PROCEED!"
    exit 1
fi

if git ls-files | grep -q "\.apk"; then
    echo "⚠️  WARNING: APK files found in staged files"
fi

echo "✅ No api_config.dart found in staged files"
echo ""
echo "📋 Next steps:"
echo "1. Review the staged files above"
echo "2. If everything looks good, run:"
echo "   git commit -m 'Initial commit: Currency Plus app'"
echo "3. Create a GitHub repository"
echo "4. Run:"
echo "   git remote add origin https://github.com/YOUR_USERNAME/currency_plus.git"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "📖 See GITHUB_SETUP.md for detailed instructions"
