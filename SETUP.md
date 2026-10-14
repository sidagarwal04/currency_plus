# Currency Plus - Setup Guide

## 📋 Table of Contents
- [Prerequisites (Install Flutter First)](#prerequisites-install-flutter-first)
- [Project Installation](#project-installation)
- [API Configuration](#api-configuration)
- [Running & Building (Web & Mobile)](#running--building-web--mobile)
- [GitHub Setup](#github-setup)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites (Install Flutter First)

> **Important:** You must install the **Flutter SDK** before running `flutter pub get` or any other project commands. If you see `zsh: command not found: flutter`, install Flutter using the steps below.

### Required Software
- **Flutter SDK** 3.38.0 or higher (includes **Dart SDK** 3.10.0+)
- **Web Browser** (Chrome, Safari, Edge, Firefox) for running the Web version
- **Android Studio** (for Android APK builds) or **Xcode** (for iOS/macOS builds)

### 1. Install Flutter

#### macOS (Recommended: via Homebrew)
```bash
brew install --cask flutter
```
After installing, open a new terminal tab (or run `hash -r`) so your shell detects the `flutter` command.

#### Manual Installation (macOS / Linux / Windows)
1. Download the Flutter SDK from [docs.flutter.dev/get-started/install](https://docs.flutter.dev/get-started/install)
2. Extract it and add `flutter/bin` to your shell `PATH` (e.g., in `~/.zshrc`):
   ```bash
   export PATH="$PATH:/path/to/flutter/bin"
   source ~/.zshrc
   ```

### 2. Verify Your Flutter Installation
```bash
flutter --version
dart --version
flutter doctor
```

---

## Project Installation

### 1. Clone the Repository
```bash
git clone https://github.com/YOUR_USERNAME/currency_plus.git
cd currency_plus
```

### 2. Create the API Config File
`lib/config/api_config.dart` is gitignored so API keys are never committed. Copy the template file before building or running:

```bash
cp -n lib/config/api_config.example.dart lib/config/api_config.dart
```

### 3. Install Dependencies
```bash
flutter pub get
```

---

## API Configuration

### Live Rates Work Out of the Box
By default (`useDemoMode = false`), the app fetches **live exchange rates** automatically:
- If no custom API key is entered, it uses ExchangeRate-API's official free open v6 endpoint (`https://open.er-api.com/v6/latest/`).
- If you configure your own API key, it uses your dedicated v6 endpoint (`https://v6.exchangerate-api.com/v6/YOUR_KEY/latest/`).
- If you are offline, it automatically falls back to built-in offline reference rates for all 30+ currencies.

### Optional: Configure Your Own Dedicated API Key

1. Visit [ExchangeRate-API](https://www.exchangerate-api.com/) and sign up for a free account (1,500 requests/month)
2. Edit `lib/config/api_config.dart`:

```dart
class ApiConfig {
  static const String exchangeRateApiKey = 'your_api_key_here'; // Optional dedicated key
  static const bool useDemoMode = false; // Keep false for live rates
  
  static const String exchangeRateApiUrl = 'https://v6.exchangerate-api.com/v6';
  static const Duration cacheValidDuration = Duration(hours: 1);
  static const Duration apiTimeout = Duration(seconds: 10);
}
```

You can also pass the API key at build/run time via environment defines (useful for Netlify/CI):
```bash
flutter build web --dart-define=API_KEY=your_api_key_here
```

---

## Running & Building (Web & Mobile)

### Run on Web (Development)

```bash
# Option A: Launch directly in Chrome
flutter run -d chrome

# Option B: Start a local web server (open http://localhost:8080 in any browser)
flutter run -d web-server --web-port 8080
```

### Build Production Web App

```bash
flutter build web
```
**Output:** `build/web/` (ready to deploy to Netlify—see [NETLIFY_DEPLOY.md](NETLIFY_DEPLOY.md)).

### Run on Mobile / Desktop

```bash
# List available devices / emulators
flutter devices

# Run on connected device or emulator
flutter run
flutter run -d <device-id>
```

### Build Release Android APK

Use the provided build script:
```bash
./build_apk.sh
```

Or manually:
```bash
flutter build apk --release
```

**Output:** `build/app/outputs/flutter-apk/currency-convert.apk`

### Install APK on Android Device

```bash
# Via ADB
adb install -r build/app/outputs/flutter-apk/currency-convert.apk
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

3. **Add & Commit Files**
   ```bash
   git add .
   git status  # Review files to be committed
   git commit -m "Initial commit: Currency Plus app"
   ```

### Security Checklist

- [ ] `.gitignore` contains `lib/config/api_config.dart`
- [ ] `api_config.example.dart` exists with placeholder
- [ ] Your actual API key is NOT committed
- [ ] APK files are NOT committed

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

### `zsh: command not found: flutter`
- Flutter is not installed or not in your `PATH`.
- Install it via Homebrew (`brew install --cask flutter`) and open a new terminal window, or verify `/opt/homebrew/bin` is in your `PATH`.

### Error: `Target of URI doesn't exist: '../config/api_config.dart'`
- Run `cp -n lib/config/api_config.example.dart lib/config/api_config.dart` to create your local configuration file.

### Showing "Offline Reference Rates" Instead of "Live Exchange Rates"
- Check `lib/config/api_config.dart` and ensure `useDemoMode` is set to `false`.
- Ensure your device/browser has an active internet connection.

### Build Errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build web   # or ./build_apk.sh
```

---

## Quick Reference

### Useful Commands

```bash
# Web Development & Build
flutter run -d chrome                        # Run in Chrome
flutter run -d web-server --web-port 8080    # Run local web server at localhost:8080
flutter build web                            # Build production web bundle

# Mobile Development & Build
flutter run                                  # Run in debug mode
flutter run --release                        # Run in release mode
./build_apk.sh                               # Build Android APK (recommended)
flutter build apk --release                  # Build Android APK manually
flutter build appbundle                      # Build App Bundle for Play Store

# Maintenance
flutter clean                                # Clean build cache
flutter pub get                              # Install dependencies
flutter doctor                               # Check Flutter installation
flutter devices                              # List connected devices
```

### Project Structure

```
lib/
├── config/
│   ├── api_config.dart                # Local API config (gitignored)
│   └── api_config.example.dart        # Config template
├── models/
│   ├── conversion_history.dart        # Conversion history model
│   ├── currency.dart                  # Currency data (30+ currencies)
│   ├── exchange_rate_response.dart    # API response model
│   └── user_preferences.dart          # Theme & user settings model
├── screens/
│   ├── multi_currency_screen.dart     # Main responsive multi-currency UI
│   ├── currency_converter_screen.dart # Single-pair converter & favorites
│   └── history_screen.dart            # Conversion history & CSV export
└── services/
    ├── api_currency_service.dart      # Live ExchangeRate-API service
    ├── currency_service.dart          # Offline fallback rates (30+ currencies)
    ├── hybrid_currency_service.dart   # Automatic live + offline fallback service
    ├── favorites_service.dart         # Favorite currencies persistence
    ├── history_service.dart           # Conversion history persistence
    ├── preferences_service.dart       # Theme & user preferences
    └── storage_service.dart           # SharedPreferences wrapper
```

---

## Support

- **Issues:** [GitHub Issues](https://github.com/YOUR_USERNAME/currency_plus/issues)
- **API Docs:** [ExchangeRate-API Documentation](https://www.exchangerate-api.com/docs)
- **Flutter Docs:** [Flutter Documentation](https://flutter.dev/docs)

---

## License

MIT License - See LICENSE file for details.
