# Currency Plus 💱

A modern, feature-rich currency converter app built with Flutter.

![Flutter](https://img.shields.io/badge/Flutter-3.38.0-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.10.0-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Features

- 💱 **30+ Currencies** - Major world currencies (USD, EUR, GBP, JPY, SGD, AED, THB, and more)
- 🌐 **Live Exchange Rates** - Real-time rates via ExchangeRate-API
- 📴 **Offline Support** - Works without internet using cached rates
- ⌨️ **Custom Numpad** - Built-in calculator-style numpad, no phone keyboard
- 🔄 **Multi-Currency View** - Convert one amount to multiple currencies at once
- 📌 **Reorderable** - Drag to reorder currencies
- ➕ **Add/Remove** - Dynamically add or remove currencies
- 💾 **State Persistence** - Your preferences are saved automatically
- 🌙 **Dark Mode** - Full dark mode support
- 🎨 **Material Design 3** - Clean, modern interface

## 📱 App Screen
![WhatsApp Image 2026-01-13 at 11 59 06 AM](https://github.com/user-attachments/assets/258a90d2-2b2a-4a85-8128-7a360edcde3f)

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/currency_plus.git
cd currency_plus

# Install dependencies
flutter pub get

# Configure API key (see SETUP.md)
cp lib/config/api_config.example.dart lib/config/api_config.dart
# Edit api_config.dart and add your API key

# Run the app
flutter run

# Build APK
./build_apk.sh
```

**📖 See [SETUP.md](SETUP.md) for detailed installation and configuration instructions.**

## 🎯 Usage

- **Add Currency:** Tap "Add currency" button
- **Remove Currency:** Tap the red ⊖ icon
- **Reorder:** Long-press ☰ handle and drag
- **Enter Amount:** Tap any currency field and use the numpad
- **Clear:** Tap red C button
- **Delete:** Tap orange ⌫ button

## 🛠️ Built With

- **[Flutter](https://flutter.dev/)** - UI framework
- **[ExchangeRate-API](https://www.exchangerate-api.com/)** - Exchange rate data
- **[Provider](https://pub.dev/packages/provider)** - State management
- **[SharedPreferences](https://pub.dev/packages/shared_preferences)** - Local storage

## 📋 Requirements

- Flutter 3.38.0+
- Dart 3.10.0+
- Android SDK (for Android) or Xcode (for iOS)

## 🔑 API Setup

1. Get a free API key from [ExchangeRate-API](https://www.exchangerate-api.com/) (1,500 requests/month)
2. Copy `lib/config/api_config.example.dart` to `lib/config/api_config.dart`
3. Add your API key
4. Set `useDemoMode = false`

**Note:** App works offline with cached rates if no API key is configured.

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
