/// Model for conversion history entry
class ConversionHistory {
  final String id;
  final double amount;
  final String fromCurrency;
  final String toCurrency;
  final double result;
  final double exchangeRate;
  final DateTime timestamp;
  final bool wasOnline;

  ConversionHistory({
    required this.id,
    required this.amount,
    required this.fromCurrency,
    required this.toCurrency,
    required this.result,
    required this.exchangeRate,
    required this.timestamp,
    required this.wasOnline,
  });

  /// Create from JSON
  factory ConversionHistory.fromJson(Map<String, dynamic> json) {
    return ConversionHistory(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      fromCurrency: json['fromCurrency'] as String,
      toCurrency: json['toCurrency'] as String,
      result: (json['result'] as num).toDouble(),
      exchangeRate: (json['exchangeRate'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      wasOnline: json['wasOnline'] as bool,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'fromCurrency': fromCurrency,
      'toCurrency': toCurrency,
      'result': result,
      'exchangeRate': exchangeRate,
      'timestamp': timestamp.toIso8601String(),
      'wasOnline': wasOnline,
    };
  }

  /// Create a new instance with updated values
  ConversionHistory copyWith({
    String? id,
    double? amount,
    String? fromCurrency,
    String? toCurrency,
    double? result,
    double? exchangeRate,
    DateTime? timestamp,
    bool? wasOnline,
  }) {
    return ConversionHistory(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      result: result ?? this.result,
      exchangeRate: exchangeRate ?? this.exchangeRate,
      timestamp: timestamp ?? this.timestamp,
      wasOnline: wasOnline ?? this.wasOnline,
    );
  }

  /// Format for display
  String get formattedConversion =>
      '$amount $fromCurrency → ${result.toStringAsFixed(2)} $toCurrency';

  /// Time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${difference.inDays ~/ 365 > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${difference.inDays ~/ 30 > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min ago';
    } else {
      return 'Just now';
    }
  }
}
