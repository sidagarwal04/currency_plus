import 'package:intl/intl.dart';
import '../models/conversion_history.dart';
import 'storage_service.dart';

/// Service for managing conversion history
class HistoryService {
  final StorageService _storage = StorageService();
  List<ConversionHistory>? _cachedHistory;

  /// Initialize the service
  Future<void> init() async {
    await _storage.init();
    _cachedHistory = await _storage.getHistory();
  }

  /// Add conversion to history
  Future<bool> addConversion({
    required double amount,
    required String fromCurrency,
    required String toCurrency,
    required double result,
    required double exchangeRate,
    required bool wasOnline,
  }) async {
    final conversion = ConversionHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      fromCurrency: fromCurrency,
      toCurrency: toCurrency,
      result: result,
      exchangeRate: exchangeRate,
      timestamp: DateTime.now(),
      wasOnline: wasOnline,
    );

    final success = await _storage.addToHistory(conversion);
    if (success) {
      _cachedHistory = await _storage.getHistory();
    }
    return success;
  }

  /// Get all history
  Future<List<ConversionHistory>> getHistory() async {
    _cachedHistory ??= await _storage.getHistory();
    return _cachedHistory!;
  }

  /// Get history filtered by currency
  Future<List<ConversionHistory>> getHistoryForCurrency(String currencyCode) async {
    final history = await getHistory();
    return history.where((h) =>
        h.fromCurrency == currencyCode || h.toCurrency == currencyCode).toList();
  }

  /// Get history for date range
  Future<List<ConversionHistory>> getHistoryForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final history = await getHistory();
    return history.where((h) =>
        h.timestamp.isAfter(startDate) && h.timestamp.isBefore(endDate)).toList();
  }

  /// Get history for today
  Future<List<ConversionHistory>> getTodayHistory() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return await getHistoryForDateRange(
      startDate: startOfDay,
      endDate: endOfDay,
    );
  }

  /// Clear all history
  Future<bool> clearHistory() async {
    final success = await _storage.clearHistory();
    if (success) {
      _cachedHistory = [];
    }
    return success;
  }

  /// Delete specific conversion
  Future<bool> deleteConversion(String id) async {
    final history = await getHistory();
    history.removeWhere((h) => h.id == id);
    final success = await _storage.saveHistory(history);
    if (success) {
      _cachedHistory = history;
    }
    return success;
  }

  /// Export history to CSV format
  String exportToCSV() {
    if (_cachedHistory == null || _cachedHistory!.isEmpty) {
      return 'No history to export';
    }

    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('Timestamp,Amount,From,To,Result,Exchange Rate,Source');

    // Data rows
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    for (final conversion in _cachedHistory!) {
      buffer.writeln([
        dateFormat.format(conversion.timestamp),
        conversion.amount,
        conversion.fromCurrency,
        conversion.toCurrency,
        conversion.result.toStringAsFixed(2),
        conversion.exchangeRate.toStringAsFixed(4),
        conversion.wasOnline ? 'Online' : 'Offline',
      ].join(','));
    }

    return buffer.toString();
  }

  /// Get statistics
  Future<Map<String, dynamic>> getStatistics() async {
    final history = await getHistory();
    
    if (history.isEmpty) {
      return {
        'totalConversions': 0,
        'mostUsedFromCurrency': 'N/A',
        'mostUsedToCurrency': 'N/A',
        'onlineConversions': 0,
        'offlineConversions': 0,
      };
    }

    final fromCurrencyCounts = <String, int>{};
    final toCurrencyCounts = <String, int>{};
    int onlineCount = 0;
    int offlineCount = 0;

    for (final conversion in history) {
      fromCurrencyCounts[conversion.fromCurrency] =
          (fromCurrencyCounts[conversion.fromCurrency] ?? 0) + 1;
      toCurrencyCounts[conversion.toCurrency] =
          (toCurrencyCounts[conversion.toCurrency] ?? 0) + 1;
      
      if (conversion.wasOnline) {
        onlineCount++;
      } else {
        offlineCount++;
      }
    }

    final mostUsedFrom = fromCurrencyCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
    final mostUsedTo = toCurrencyCounts.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return {
      'totalConversions': history.length,
      'mostUsedFromCurrency': mostUsedFrom,
      'mostUsedToCurrency': mostUsedTo,
      'onlineConversions': onlineCount,
      'offlineConversions': offlineCount,
    };
  }
}
