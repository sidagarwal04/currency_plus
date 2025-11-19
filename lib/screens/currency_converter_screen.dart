import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/currency.dart';
import '../services/hybrid_currency_service.dart';
import '../services/history_service.dart';
import '../services/favorites_service.dart';
import '../services/preferences_service.dart';
import 'history_screen.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final TextEditingController _amountController = TextEditingController();
  final HybridCurrencyService _currencyService = HybridCurrencyService();

  Currency _fromCurrency = CurrencyData.currencies[0]; // USD
  Currency _toCurrency = CurrencyData.currencies[1]; // EUR
  double? _convertedAmount;
  double? _exchangeRate;
  bool _isLoading = false;
  String? _errorMessage;
  Set<String> _favoriteCodes = {};

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _updateExchangeRate();
  }
  
  Future<void> _loadFavorites() async {
    final favoritesService = context.read<FavoritesService>();
    final codes = await favoritesService.getFavoriteCodes();
    setState(() {
      _favoriteCodes = codes.toSet();
    });
  }
  
  Future<void> _toggleFavorite(String currencyCode) async {
    final favoritesService = context.read<FavoritesService>();
    await favoritesService.toggleFavorite(currencyCode);
    await _loadFavorites();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _updateExchangeRate() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final rate = await _currencyService.getExchangeRate(
        fromCurrency: _fromCurrency.code,
        toCurrency: _toCurrency.code,
      );
      setState(() {
        _exchangeRate = rate;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to fetch exchange rate';
        _isLoading = false;
      });
    }
  }

  Future<void> _convertCurrency() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      setState(() {
        _convertedAmount = null;
      });
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount < 0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a valid amount'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _currencyService.convert(
        amount: amount,
        fromCurrency: _fromCurrency.code,
        toCurrency: _toCurrency.code,
      );

      setState(() {
        _convertedAmount = result;
        _isLoading = false;
      });
      
      // Track conversion in history
      if (result != null) {
        final historyService = context.read<HistoryService>();
        await historyService.addConversion(
          amount: amount,
          fromCurrency: _fromCurrency.code,
          toCurrency: _toCurrency.code,
          result: result,
          exchangeRate: _exchangeRate ?? 0,
          wasOnline: _currencyService.isUsingApi, // Track if API mode was used
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Conversion failed';
      });
    }
  }

  void _swapCurrencies() {
    setState(() {
      final temp = _fromCurrency;
      _fromCurrency = _toCurrency;
      _toCurrency = temp;
      _updateExchangeRate();
      _convertCurrency();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Plus'),
        centerTitle: true,
        elevation: 0,
        actions: [
          // History button
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'View History',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HistoryScreen(),
                ),
              );
            },
          ),
          // Theme toggle button
          Consumer<PreferencesService>(
            builder: (context, prefs, _) {
              return IconButton(
                icon: Icon(
                  prefs.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                tooltip: prefs.isDarkMode ? 'Light Mode' : 'Dark Mode',
                onPressed: () {
                  prefs.toggleDarkMode();
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.currency_exchange,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Currency Converter',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _currencyService.isUsingApi
                                ? Icons.cloud_done
                                : Icons.cloud_off,
                            size: 16,
                            color: _currencyService.isUsingApi
                                ? Colors.green
                                : Colors.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _currencyService.isUsingApi
                                ? 'Phase 2 - Live Rates'
                                : 'Offline Mode',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Amount Input
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                decoration: InputDecoration(
                  labelText: 'Amount',
                  hintText: 'Enter amount',
                  prefixIcon: const Icon(Icons.attach_money),
                  suffixIcon: _amountController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _amountController.clear();
                            setState(() {
                              _convertedAmount = null;
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  _convertCurrency();
                },
              ),
              const SizedBox(height: 24),

              // From Currency Selector
              _buildCurrencySelector(
                label: 'From',
                selectedCurrency: _fromCurrency,
                onChanged: (currency) {
                  setState(() {
                    _fromCurrency = currency!;
                    _updateExchangeRate();
                    _convertCurrency();
                  });
                },
              ),
              const SizedBox(height: 16),

              // Swap Button
              Center(
                child: IconButton.filled(
                  onPressed: _swapCurrencies,
                  icon: const Icon(Icons.swap_vert),
                  iconSize: 32,
                  tooltip: 'Swap currencies',
                ),
              ),
              const SizedBox(height: 16),

              // To Currency Selector
              _buildCurrencySelector(
                label: 'To',
                selectedCurrency: _toCurrency,
                onChanged: (currency) {
                  setState(() {
                    _toCurrency = currency!;
                    _updateExchangeRate();
                    _convertCurrency();
                  });
                },
              ),
              const SizedBox(height: 24),

              // Exchange Rate Display
              if (_exchangeRate != null)
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.info_outline, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '1 ${_fromCurrency.code} = ${_exchangeRate!.toStringAsFixed(4)} ${_toCurrency.code}',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              // Result Display
              if (_convertedAmount != null)
                Card(
                  elevation: 2,
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Text(
                          'Converted Amount',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              _toCurrency.symbol,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _convertedAmount!.toStringAsFixed(2),
                              style: Theme.of(context)
                                  .textTheme
                                  .displaySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${_toCurrency.flag} ${_toCurrency.name}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // Loading Indicator
              if (_isLoading)
                const Card(
                  elevation: 0,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Fetching latest rates...'),
                      ],
                    ),
                  ),
                ),

              // Error Message
              if (_errorMessage != null)
                Card(
                  elevation: 0,
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red.shade900,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: Colors.red.shade900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Phase 2 Notice
              Card(
                elevation: 0,
                color: _currencyService.isUsingApi
                    ? Colors.green.shade50
                    : Colors.amber.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _currencyService.isUsingApi
                                ? Icons.cloud_done
                                : Icons.lightbulb_outline,
                            color: _currencyService.isUsingApi
                                ? Colors.green.shade900
                                : Colors.amber.shade900,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _currencyService.isUsingApi
                                  ? 'Phase 2: Using real-time exchange rates!'
                                  : 'Using offline exchange rates',
                              style: TextStyle(
                                color: _currencyService.isUsingApi
                                    ? Colors.green.shade900
                                    : Colors.amber.shade900,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_currencyService.lastUpdateTime != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Last updated: ${_formatUpdateTime(_currencyService.lastUpdateTime!)}',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Toggle between online and offline modes',
                              style: TextStyle(
                                color: _currencyService.isUsingApi
                                    ? Colors.green.shade700
                                    : Colors.amber.shade700,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Switch(
                            value: _currencyService.isUsingApi,
                            onChanged: (value) {
                              setState(() {
                                _currencyService.setUseApi(value);
                                _updateExchangeRate();
                                _convertCurrency();
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencySelector({
    required String label,
    required Currency selectedCurrency,
    required ValueChanged<Currency?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12, bottom: 8),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        DropdownButtonFormField<Currency>(
          initialValue: selectedCurrency,
          decoration: InputDecoration(
            prefixIcon: Text(
              selectedCurrency.flag,
              style: const TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 60),
          ),
          isExpanded: true,
          items: CurrencyData.currencies.map((currency) {
            final isFavorite = _favoriteCodes.contains(currency.code);
            return DropdownMenuItem<Currency>(
              value: currency,
              child: Row(
                children: [
                  Text(
                    currency.flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          currency.code,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          currency.name,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Favorite star icon
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.star : Icons.star_border,
                      color: isFavorite ? Colors.amber : Colors.grey,
                      size: 20,
                    ),
                    onPressed: () => _toggleFavorite(currency.code),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  String _formatUpdateTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hr ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}
