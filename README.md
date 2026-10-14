# Currency Plus 💱

A modern, responsive currency converter app for Mobile and Web built with Flutter.

![Flutter](https://img.shields.io/badge/Flutter-3.38.0+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.10.0+-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Features

- 💱 **30+ Currencies** - Major world currencies (INR, USD, EUR, GBP, JPY, SGD, AED, THB, and more)
- 🌐 **Live Exchange Rates** - Real-time rates via ExchangeRate-API (works out of the box via the open v6 endpoint or with your own API key)
- 📴 **Offline Support** - Automatically falls back to cached/offline rates without internet
- 💻 **Responsive Web & Mobile UI** - Adaptive two-column split layout on desktop/web and collapsible bottom numpad on mobile
- ⌨️ **Numpad & Physical Keyboard Support** - Built-in calculator numpad plus full physical keyboard input (`0–9`, `.`, `Backspace`, `Esc`, `↑`/`↓`)
- 🔍 **Searchable Currency Picker** - Quickly search currencies by code, country name, or symbol
- ⚡ **Quick Presets & One-Tap Copy** - Instant preset chips (`1`, `10`, `100`, `500`, `1000`) and clipboard copy
- 🔄 **Multi-Currency & Single-Pair Views** - Convert across a custom list of currencies or use the pair converter with favorites & history
- 📌 **Reorderable** - Drag to reorder currencies
- 💾 **State Persistence** - Currencies, favorites, history, and theme preferences are saved automatically
- 🌙 **Dark & Light Mode** - Full Material Design 3 dark and light themes

## 📱 App Screen
![WhatsApp Image 2026-01-13 at 11 59 06 AM](https://github.com/user-attachments/assets/258a90d2-2b2a-4a85-8128-7a360edcde3f)

## 🚀 Quick Start

### 1. Install Flutter First
Make sure the Flutter SDK is installed on your machine before running any commands:

```bash
# macOS (via Homebrew)
brew install --cask flutter

# Verify installation
flutter --version
```
*(For Windows, Linux, or manual installation, see the [official Flutter installation guide](https://docs.flutter.dev/get-started/install) or [SETUP.md](SETUP.md).)*

### 2. Clone & Configure

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/currency_plus.git
cd currency_plus

# Copy API config file (required before running/building)
cp -n lib/config/api_config.example.dart lib/config/api_config.dart

# Install dependencies
flutter pub get
```

### 3. Run the App

```bash
# Run on Web (Chrome)
flutter run -d chrome

# Run on Web Server (open http://localhost:8080 in any browser)
flutter run -d web-server --web-port 8080

# Run on connected mobile device / emulator
flutter run

# Build Android APK
./build_apk.sh

# Build Production Web Bundle
flutter build web
```

**📖 See [SETUP.md](SETUP.md) for detailed installation, web/mobile setup, and configuration instructions.**

## 🎯 Usage

- **Switch Base Currency:** Tap any currency row (or press `↑` / `↓` on desktop/web)
- **Quick Amounts:** Tap the preset chips (`1`, `10`, `100`, `500`, `1000`) in the top bar
- **Add Currency:** Tap the **"Add currency"** button and search by code or name
- **Change a Row's Currency:** Tap the currency flag/code badge on any row
- **Remove Currency:** Tap the red `⊖` icon on the right of a row
- **Reorder:** Drag the `☰` handle to reorder rows
- **Enter Amount:** Use the on-screen numpad or type directly on your keyboard
- **Copy Amount:** Tap the copy icon on any currency row
- **Clear / Backspace:** Tap `C` (or press `Esc` / `C`) to clear, and `⌫` (or `Backspace`) to delete

## 🛠️ Built With

- **[Flutter](https://flutter.dev/)** - Cross-platform UI framework (Mobile & Web)
- **[ExchangeRate-API](https://www.exchangerate-api.com/)** - Real-time exchange rate data
- **[Provider](https://pub.dev/packages/provider)** - State management
- **[SharedPreferences](https://pub.dev/packages/shared_preferences)** - Local storage

## 📋 Requirements

- **Flutter SDK** 3.38.0+ (must be installed first)
- **Dart SDK** 3.10.0+ (bundled with Flutter)
- **Chrome / Any modern browser** (for Web development)
- **Android Studio** (for Android builds) or **Xcode** (for iOS/macOS builds)

## 🔑 API Setup

The app works with **live exchange rates out of the box** using ExchangeRate-API's official open v6 endpoint (`https://open.er-api.com/v6/latest/`).

To use your own dedicated API key (optional, or for higher rate limits):
1. Get a free API key from [ExchangeRate-API](https://www.exchangerate-api.com/) (1,500 requests/month)
2. Copy `lib/config/api_config.example.dart` to `lib/config/api_config.dart`
3. Add your API key to `exchangeRateApiKey` (or pass `--dart-define=API_KEY=your_key` when building for Web/Netlify)
4. Keep `useDemoMode = false`

**Note:** If your device is offline, the app automatically falls back to built-in offline reference rates for all 30+ currencies.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [ExchangeRate-API](https://www.exchangerate-api.com/) for providing free exchange rate data
- [Flutter team](https://flutter.dev/) for the amazing framework
- All contributors and users of this project

## 📞 Support

For issues, questions, or suggestions:
- 🐛 [Report a Bug](https://github.com/YOUR_USERNAME/currency_plus/issues)
- 💡 [Request a Feature](https://github.com/YOUR_USERNAME/currency_plus/issues)
- 📖 [Read the Docs](SETUP.md)

---

Made with ❤️ using Flutter
