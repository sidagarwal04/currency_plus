import 'package:flutter/material.dart';
import '../models/user_preferences.dart';
import 'storage_service.dart';

/// Service for managing user preferences
class PreferencesService extends ChangeNotifier {
  final StorageService _storage = StorageService();
  UserPreferences _preferences = const UserPreferences();

  UserPreferences get preferences => _preferences;
  bool get isDarkMode => _preferences.isDarkMode;
  bool get useSystemTheme => _preferences.useSystemTheme;

  /// Initialize the service
  Future<void> init() async {
    await _storage.init();
    _preferences = await _storage.getPreferences();
    notifyListeners();
  }

  /// Save preferences
  Future<bool> _savePreferences() async {
    final success = await _storage.savePreferences(_preferences);
    if (success) {
      notifyListeners();
    }
    return success;
  }

  /// Toggle dark mode
  Future<bool> toggleDarkMode() async {
    _preferences = _preferences.copyWith(isDarkMode: !_preferences.isDarkMode);
    return await _savePreferences();
  }

  /// Set dark mode
  Future<bool> setDarkMode(bool value) async {
    _preferences = _preferences.copyWith(isDarkMode: value);
    return await _savePreferences();
  }

  /// Set use system theme
  Future<bool> setUseSystemTheme(bool value) async {
    _preferences = _preferences.copyWith(useSystemTheme: value);
    return await _savePreferences();
  }

  /// Set default from currency
  Future<bool> setDefaultFromCurrency(String currencyCode) async {
    _preferences = _preferences.copyWith(defaultFromCurrency: currencyCode);
    return await _savePreferences();
  }

  /// Set default to currency
  Future<bool> setDefaultToCurrency(String currencyCode) async {
    _preferences = _preferences.copyWith(defaultToCurrency: currencyCode);
    return await _savePreferences();
  }

  /// Set save history
  Future<bool> setSaveHistory(bool value) async {
    _preferences = _preferences.copyWith(saveHistory: value);
    return await _savePreferences();
  }

  /// Set max history items
  Future<bool> setMaxHistoryItems(int value) async {
    _preferences = _preferences.copyWith(maxHistoryItems: value);
    return await _savePreferences();
  }

  /// Set show favorites
  Future<bool> setShowFavorites(bool value) async {
    _preferences = _preferences.copyWith(showFavorites: value);
    return await _savePreferences();
  }

  /// Reset to defaults
  Future<bool> resetToDefaults() async {
    _preferences = const UserPreferences();
    return await _savePreferences();
  }

  /// Get theme mode
  ThemeMode getThemeMode() {
    if (_preferences.useSystemTheme) {
      return ThemeMode.system;
    }
    return _preferences.isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }
}
