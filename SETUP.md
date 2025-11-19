# Currency Plus - Setup Guide

## 📋 Table of Contents
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [API Configuration](#api-configuration)
- [Building & Running](#building--running)
- [GitHub Setup](#github-setup)

---

## Prerequisites

### Required Software
- **Flutter SDK** 3.38.0 or higher
- **Dart SDK** 3.10.0 or higher
- **Android Studio** (for Android builds) or **Xcode** (for iOS builds)

### Check Your Installation
```bash
flutter --version
dart --version
```

---

## Installation

### 1. Clone the Repository
```bash
git clone https://github.com/YOUR_USERNAME/currency_plus.git
cd currency_plus
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Verify Installation
```bash
flutter doctor
```
Fix any issues reported by `flutter doctor`.

---

## API Configuration

### Get Your API Key

1. Visit [ExchangeRate-API](https://www.exchangerate-api.com/)
2. Sign up for a free account
3. Get your API key from the dashboard (1,500 requests/month free)

### Configure the App

```bash
# Copy the example config file
cp lib/config/api_config.example.dart lib/config/api_config.dart
```

Edit `lib/config/api_config.dart`:
```dart
class ApiConfig {
  static const String exchangeRateApiKey = 'your_api_key_here'; // Add your key
  static const bool useDemoMode = false; // Set to false for live rates
  
  static const String exchangeRateApiUrl = 'https://v6.exchangerate-api.com/v6';
  static const Duration cacheValidDuration = Duration(hours: 1);
  static const Duration apiTimeout = Duration(seconds: 10);
}
```

**Note:** The app works offline without an API key, but you'll get static exchange rates.

---

## Building & Running

### Run in Development Mode

```bash
# Run on connected device/emulator
flutter run

# Run on specific device
flutter devices  # List available devices
flutter run -d <device-id>
```

### Build Release APK

Use the provided build script:
```bash
./build_apk.sh
```

Or manually:
```bash
flutter build apk --release
```

**Output:** `build/app/outputs/flutter-apk/currency-convert.apk`

### Install on Device

```bash
# Via ADB
adb install -r build/app/outputs/flutter-apk/currency-convert.apk

# Or manually
# Transfer the APK to your device and install
```

---

## GitHub Setup

### Initial Setup

1. **Initialize Git** (if not already done)
   ```bash
   git init
   ```

2. **Verify API Key is Excluded**
   ```bash
   git check-ignore lib/config/api_config.dart
   # Should output: lib/config/api_config.dart
   ```

3. **Add Files**
   ```bash
   git add .
   git status  # Review files to be committed
   ```

4. **Create Initial Commit**
   ```bash
   git commit -m "Initial commit: Currency Plus app"
   ```

### Push to GitHub

1. **Create Repository on GitHub**
   - Go to https://github.com/new
   - Name: `currency_plus`
   - Choose Public or Private
   - **Don't** initialize with README
   - Click "Create repository"

2. **Connect and Push**
   ```bash
   git remote add origin https://github.com/YOUR_USERNAME/currency_plus.git
   git branch -M main
   git push -u origin main
   ```

### Security Checklist

- [ ] `.gitignore` contains `lib/config/api_config.dart`
- [ ] `api_config.example.dart` exists with placeholder
- [ ] Your actual API key is NOT committed
- [ ] APK files are NOT committed

### If You Accidentally Expose Your Key

1. **Immediately revoke** the API key at exchangerate-api.com
2. Generate a new key
3. Remove from Git history:
   ```bash
   git filter-branch --force --index-filter \
   "git rm --cached --ignore-unmatch lib/config/api_config.dart" \
   --prune-empty --tag-name-filter cat -- --all
   
   git push origin --force --all
   ```
4. Update your local file with the new key

---

## App Icon Setup (Optional)

### Generate Custom App Icon

1. Place your icon image at `assets/icon.png` (512x512px recommended)

2. Run the icon generator:
   ```bash
   dart run flutter_launcher_icons
   ```

3. Rebuild the app:
   ```bash
   ./build_apk.sh
   ```

---

## Troubleshooting

### API Key Not Working
- Verify the key is correct in `lib/config/api_config.dart`
- Check `useDemoMode` is set to `false`
- Ensure you have internet connection
- Check your API quota hasn't been exceeded

### Build Errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
./build_apk.sh
```

### App Crashes on Startup
- Check `flutter run` output for errors
- Verify all dependencies are installed: `flutter pub get`
- Try clearing app data on device

### State Not Persisting
- Ensure `shared_preferences` is properly installed
- Check device storage permissions

---

## Quick Reference

### Useful Commands

```bash
# Development
flutter run                    # Run in debug mode
flutter run --release          # Run in release mode
flutter run -d chrome          # Run on web

# Building
./build_apk.sh                 # Build APK (recommended)
flutter build apk --release    # Build APK manually
flutter build appbundle        # Build App Bundle for Play Store

# Maintenance
flutter clean                  # Clean build cache
flutter pub get                # Install dependencies
flutter pub upgrade            # Upgrade dependencies
flutter doctor                 # Check installation
flutter devices                # List connected devices

# Git
git status                     # Check what will be committed
git add .                      # Stage all changes
git commit -m "message"        # Commit changes
git push                       # Push to GitHub
```

### Project Structure

```
lib/
├── config/
│   ├── api_config.dart          # Your API key (gitignored)
│   └── api_config.example.dart  # Template
├── models/
│   └── currency.dart            # Currency data (30+ currencies)
├── screens/
│   └── multi_currency_screen.dart  # Main UI
└── services/
    └── hybrid_currency_service.dart # API + offline support
```

---

## Support

- **Issues:** [GitHub Issues](https://github.com/YOUR_USERNAME/currency_plus/issues)
- **API Docs:** [ExchangeRate-API Documentation](https://www.exchangerate-api.com/docs)
- **Flutter Docs:** [Flutter Documentation](https://flutter.dev/docs)

---

## License

MIT License - See LICENSE file for details.
