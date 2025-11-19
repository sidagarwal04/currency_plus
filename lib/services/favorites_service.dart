import '../models/currency.dart';
import 'storage_service.dart';

/// Service for managing favorite currencies
class FavoritesService {
  final StorageService _storage = StorageService();
  List<String>? _cachedFavorites;

  /// Initialize the service
  Future<void> init() async {
    await _storage.init();
    _cachedFavorites = await _storage.getFavorites();
  }

  /// Get all favorite currency codes
  Future<List<String>> getFavoriteCodes() async {
    _cachedFavorites ??= await _storage.getFavorites();
    return _cachedFavorites!;
  }

  /// Get favorite currencies as Currency objects
  Future<List<Currency>> getFavorites() async {
    final codes = await getFavoriteCodes();
    return codes
        .map((code) => CurrencyData.findByCode(code))
        .where((currency) => currency != null)
        .cast<Currency>()
        .toList();
  }

  /// Add currency to favorites
  Future<bool> addFavorite(String currencyCode) async {
    final success = await _storage.addFavorite(currencyCode);
    if (success) {
      _cachedFavorites = await _storage.getFavorites();
    }
    return success;
  }

  /// Remove currency from favorites
  Future<bool> removeFavorite(String currencyCode) async {
    final success = await _storage.removeFavorite(currencyCode);
    if (success) {
      _cachedFavorites = await _storage.getFavorites();
    }
    return success;
  }

  /// Toggle favorite status
  Future<bool> toggleFavorite(String currencyCode) async {
    final isFav = await isFavorite(currencyCode);
    if (isFav) {
      return await removeFavorite(currencyCode);
    } else {
      return await addFavorite(currencyCode);
    }
  }

  /// Check if currency is a favorite
  Future<bool> isFavorite(String currencyCode) async {
    final favorites = await getFavoriteCodes();
    return favorites.contains(currencyCode);
  }

  /// Clear all favorites
  Future<bool> clearFavorites() async {
    final success = await _storage.saveFavorites([]);
    if (success) {
      _cachedFavorites = [];
    }
    return success;
  }

  /// Get count of favorites
  Future<int> getFavoriteCount() async {
    final favorites = await getFavoriteCodes();
    return favorites.length;
  }

  /// Reorder favorites
  Future<bool> reorderFavorites(List<String> newOrder) async {
    final success = await _storage.saveFavorites(newOrder);
    if (success) {
      _cachedFavorites = newOrder;
    }
    return success;
  }
}
