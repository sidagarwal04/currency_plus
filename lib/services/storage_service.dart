import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/conversion_history.dart';
import '../models/user_preferences.dart';

/// Service for local data persistence
class StorageService {
  static const String _historyKey = 'conversion_history';
  static const String _favoritesKey = 'favorite_currencies';
  static const String _preferencesKey = 'user_preferences';

  SharedPreferences? _prefs;

  /// Initialize the service
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Ensure preferences are loaded
  Future<SharedPreferences> get _preferences async {
    if (_prefs == null) {
      await init();
    }
    return _prefs!;
  }

  // ============ History Methods ============

  /// Save conversion history
  Future<bool> saveHistory(List<ConversionHistory> history) async {
    try {
      final prefs = await _preferences;
      final jsonList = history.map((h) => h.toJson()).toList();
      final jsonString = json.encode(jsonList);
      return await prefs.setString(_historyKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  /// Get conversion history
  Future<List<ConversionHistory>> getHistory() async {
    try {
      final prefs = await _preferences;
      final jsonString = prefs.getString(_historyKey);
      
      if (jsonString == null) return [];
      
      final jsonList = json.decode(jsonString) as List;
      return jsonList
          .map((item) => ConversionHistory.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Add single conversion to history
  Future<bool> addToHistory(ConversionHistory conversion) async {
    final history = await getHistory();
    history.insert(0, conversion); // Add to beginning
    
    // Limit history size
    final maxItems = (await getPreferences()).maxHistoryItems;
    if (history.length > maxItems) {
      history.removeRange(maxItems, history.length);
    }
    
    return await saveHistory(history);
  }

  /// Clear all history
  Future<bool> clearHistory() async {
    try {
      final prefs = await _preferences;
      return await prefs.remove(_historyKey);
    } catch (e) {
      return false;
    }
  }

  // ============ Favorites Methods ============

  /// Save favorite currencies
  Future<bool> saveFavorites(List<String> favorites) async {
    try {
      final prefs = await _preferences;
      return await prefs.setStringList(_favoritesKey, favorites);
    } catch (e) {
      return false;
    }
  }

  /// Get favorite currencies
  Future<List<String>> getFavorites() async {
    try {
      final prefs = await _preferences;
      return prefs.getStringList(_favoritesKey) ?? [];
    } catch (e) {
      return [];
    }
  }

  /// Add currency to favorites
  Future<bool> addFavorite(String currencyCode) async {
    final favorites = await getFavorites();
    if (!favorites.contains(currencyCode)) {
      favorites.add(currencyCode);
      return await saveFavorites(favorites);
    }
    return true;
  }

  /// Remove currency from favorites
  Future<bool> removeFavorite(String currencyCode) async {
    final favorites = await getFavorites();
    favorites.remove(currencyCode);
    return await saveFavorites(favorites);
  }

  /// Check if currency is favorite
  Future<bool> isFavorite(String currencyCode) async {
    final favorites = await getFavorites();
    return favorites.contains(currencyCode);
  }

  // ============ Preferences Methods ============

  /// Save user preferences
  Future<bool> savePreferences(UserPreferences preferences) async {
    try {
      final prefs = await _preferences;
      final jsonString = json.encode(preferences.toJson());
      return await prefs.setString(_preferencesKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  /// Get user preferences
  Future<UserPreferences> getPreferences() async {
    try {
      final prefs = await _preferences;
      final jsonString = prefs.getString(_preferencesKey);
      
      if (jsonString == null) return const UserPreferences();
      
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return UserPreferences.fromJson(jsonMap);
    } catch (e) {
      return const UserPreferences();
    }
  }

  /// Clear all data
  Future<bool> clearAll() async {
    try {
      final prefs = await _preferences;
      await prefs.remove(_historyKey);
      await prefs.remove(_favoritesKey);
      await prefs.remove(_preferencesKey);
      return true;
    } catch (e) {
      return false;
    }
  }
}
