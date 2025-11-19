/// Model for API response from exchange rate service
class ExchangeRateResponse {
  final String result;
  final String baseCode;
  final Map<String, double> conversionRates;
  final int timeLastUpdateUnix;
  final String timeLastUpdateUtc;
  final int timeNextUpdateUnix;
  final String timeNextUpdateUtc;

  ExchangeRateResponse({
    required this.result,
    required this.baseCode,
    required this.conversionRates,
    required this.timeLastUpdateUnix,
    required this.timeLastUpdateUtc,
    required this.timeNextUpdateUnix,
    required this.timeNextUpdateUtc,
  });

  factory ExchangeRateResponse.fromJson(Map<String, dynamic> json) {
    return ExchangeRateResponse(
      result: json['result'] as String,
      baseCode: json['base_code'] as String,
      conversionRates: (json['conversion_rates'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, (value as num).toDouble())),
      timeLastUpdateUnix: json['time_last_update_unix'] as int,
      timeLastUpdateUtc: json['time_last_update_utc'] as String,
      timeNextUpdateUnix: json['time_next_update_unix'] as int,
      timeNextUpdateUtc: json['time_next_update_utc'] as String,
    );
  }

  bool get isSuccess => result == 'success';

  DateTime get lastUpdateTime =>
      DateTime.fromMillisecondsSinceEpoch(timeLastUpdateUnix * 1000);

  DateTime get nextUpdateTime =>
      DateTime.fromMillisecondsSinceEpoch(timeNextUpdateUnix * 1000);
}

/// Model for rate change information
class RateChange {
  final double currentRate;
  final double previousRate;
  final double changeAmount;
  final double changePercentage;
  final bool isIncrease;

  RateChange({
    required this.currentRate,
    required this.previousRate,
  })  : changeAmount = currentRate - previousRate,
        changePercentage = ((currentRate - previousRate) / previousRate) * 100,
        isIncrease = currentRate > previousRate;

  String get changeSign => isIncrease ? '+' : '';
  
  String get formattedPercentage => 
      '$changeSign${changePercentage.toStringAsFixed(2)}%';
}
