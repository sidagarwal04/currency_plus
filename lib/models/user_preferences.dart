/// Model for user preferences and settings
class UserPreferences {
  final bool isDarkMode;
  final bool useSystemTheme;
  final String defaultFromCurrency;
  final String defaultToCurrency;
  final bool saveHistory;
  final int maxHistoryItems;
  final bool showFavorites;

  const UserPreferences({
    this.isDarkMode = false,
    this.useSystemTheme = true,
    this.defaultFromCurrency = 'USD',
    this.defaultToCurrency = 'EUR',
    this.saveHistory = true,
    this.maxHistoryItems = 100,
    this.showFavorites = true,
  });

  /// Create from JSON
  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      isDarkMode: json['isDarkMode'] as bool? ?? false,
      useSystemTheme: json['useSystemTheme'] as bool? ?? true,
      defaultFromCurrency: json['defaultFromCurrency'] as String? ?? 'USD',
      defaultToCurrency: json['defaultToCurrency'] as String? ?? 'EUR',
      saveHistory: json['saveHistory'] as bool? ?? true,
      maxHistoryItems: json['maxHistoryItems'] as int? ?? 100,
      showFavorites: json['showFavorites'] as bool? ?? true,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'useSystemTheme': useSystemTheme,
      'defaultFromCurrency': defaultFromCurrency,
      'defaultToCurrency': defaultToCurrency,
      'saveHistory': saveHistory,
      'maxHistoryItems': maxHistoryItems,
      'showFavorites': showFavorites,
    };
  }

  /// Create a copy with updated values
  UserPreferences copyWith({
    bool? isDarkMode,
    bool? useSystemTheme,
    String? defaultFromCurrency,
    String? defaultToCurrency,
    bool? saveHistory,
    int? maxHistoryItems,
    bool? showFavorites,
  }) {
    return UserPreferences(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      useSystemTheme: useSystemTheme ?? this.useSystemTheme,
      defaultFromCurrency: defaultFromCurrency ?? this.defaultFromCurrency,
      defaultToCurrency: defaultToCurrency ?? this.defaultToCurrency,
      saveHistory: saveHistory ?? this.saveHistory,
      maxHistoryItems: maxHistoryItems ?? this.maxHistoryItems,
      showFavorites: showFavorites ?? this.showFavorites,
    );
  }
}
