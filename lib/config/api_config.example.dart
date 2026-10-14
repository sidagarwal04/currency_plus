/// API Configuration Template
/// Copy this file to api_config.dart and add your actual API key
class ApiConfig {
  // ExchangeRate-API
  // Free tier: 1,500 requests/month
  // Get your free API key at: https://www.exchangerate-api.com/
  
  // TODO: Replace with your actual API key from https://www.exchangerate-api.com/
  // Steps:
  // 1. Go to https://www.exchangerate-api.com/
  // 2. Sign up for free tier
  // 3. Get your API key from dashboard
  // 4. Replace 'YOUR_API_KEY_HERE' with your actual key
  static const String exchangeRateApiKey = 'YOUR_API_KEY_HERE';
  
  // Set to false to use live rates (uses ExchangeRate-API's free open v6 endpoint
  // if no dedicated key is set, or your keyed v6 endpoint if a key is provided)
  // When true, app forces offline reference rates even if internet is available
  static const bool useDemoMode = false;
  
  // API Base URL
  static const String exchangeRateApiUrl = 'https://v6.exchangerate-api.com/v6';
  
  // Cache settings
  static const Duration cacheValidDuration = Duration(hours: 1);
  static const Duration apiTimeout = Duration(seconds: 10);
}
