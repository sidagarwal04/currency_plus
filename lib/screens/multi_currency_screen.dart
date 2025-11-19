import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/currency.dart';
import '../services/hybrid_currency_service.dart';

class MultiCurrencyScreen extends StatefulWidget {
  const MultiCurrencyScreen({super.key});

  @override
  State<MultiCurrencyScreen> createState() => _MultiCurrencyScreenState();
}

class _MultiCurrencyScreenState extends State<MultiCurrencyScreen> {
  final HybridCurrencyService _currencyService = HybridCurrencyService();
  
  // All currencies in a single list (no separate base currency)
  List<Currency> _currencies = [
    CurrencyData.currencies[8], // INR (default first)
    CurrencyData.currencies[0], // USD
    CurrencyData.currencies[4], // AUD
    CurrencyData.currencies[10], // SGD
    CurrencyData.currencies[2], // GBP
    CurrencyData.currencies[3], // JPY
  ];
  
  final Map<String, double> _exchangeRates = {};
  final Map<String, TextEditingController> _currencyControllers = {};
  bool _isConverting = false; // Flag to prevent recursive conversions
  
  // Track which currency field is currently selected
  String? _selectedCurrencyCode;
  TextEditingController? _activeController;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await _loadSavedCurrencies();
    _initializeCurrencyControllers();
    // Set first currency as initially selected
    if (_currencies.isNotEmpty) {
      setState(() {
        _selectedCurrencyCode = _currencies[0].code;
        _activeController = _currencyControllers[_currencies[0].code];
      });
    }
    // Initial conversion - this will only happen once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currencies.isNotEmpty) {
        _convertAll(_currencies[0].code, _currencyControllers[_currencies[0].code]?.text ?? '0');
      }
    });
  }

  Future<void> _loadSavedCurrencies() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCodes = prefs.getStringList('currency_codes');
    if (savedCodes != null && savedCodes.isNotEmpty) {
      final loadedCurrencies = <Currency>[];
      for (final code in savedCodes) {
        final currency = CurrencyData.findByCode(code);
        if (currency != null) {
          loadedCurrencies.add(currency);
        }
      }
      if (loadedCurrencies.isNotEmpty) {
        _currencies = loadedCurrencies;
      }
    }
  }

  Future<void> _saveCurrencies() async {
    final prefs = await SharedPreferences.getInstance();
    final codes = _currencies.map((c) => c.code).toList();
    await prefs.setStringList('currency_codes', codes);
  }

  void _initializeCurrencyControllers() {
    // Initialize controllers for all currencies
    for (final currency in _currencies) {
      if (!_currencyControllers.containsKey(currency.code)) {
        final controller = TextEditingController(text: '0.00');
        controller.addListener(() {
          if (!_isConverting) {
            _convertAll(currency.code, controller.text);
          }
        });
        _currencyControllers[currency.code] = controller;
      }
    }
    
  }

  Future<void> _convertAll(String fromCurrencyCode, String amountText) async {
    amountText = amountText.trim();
    if (amountText.isEmpty || amountText == '0') return;

    final amount = double.tryParse(amountText);
    if (amount == null || amount < 0) return;

    // Prevent recursive conversions
    if (_isConverting) return;
    _isConverting = true;

    try {
      // Convert all other currencies
      for (final currency in _currencies) {
        if (currency.code == fromCurrencyCode) continue;

        final result = await _currencyService.convert(
          amount: amount,
          fromCurrency: fromCurrencyCode,
          toCurrency: currency.code,
        );

        if (result != null) {
          final rate = await _currencyService.getExchangeRate(
            fromCurrency: fromCurrencyCode,
            toCurrency: currency.code,
          );

          setState(() {
            // Update the appropriate controller
            final controller = _currencyControllers[currency.code];
            if (controller != null) {
              controller.value = TextEditingValue(
                text: result.toStringAsFixed(2),
                selection: TextSelection.fromPosition(
                  TextPosition(offset: result.toStringAsFixed(2).length),
                ),
              );
            }

            if (rate != null) {
              _exchangeRates[currency.code] = rate;
            }
          });
        }
      }
    } catch (e) {
      // Error handling - rates may be stale
    } finally {
      // Reset the flag after all conversions are done
      _isConverting = false;
    }
  }

  void _appendNumber(String number) {
    if (_activeController == null) return;
    
    setState(() {
      if (_activeController!.text == '0' || _activeController!.text == '0.00') {
        _activeController!.text = number;
      } else {
        _activeController!.text += number;
      }
    });
  }

  void _appendDecimal() {
    if (_activeController == null) return;
    
    if (!_activeController!.text.contains('.')) {
      setState(() {
        _activeController!.text += '.';
      });
    }
  }

  void _clear() {
    setState(() {
      for (var controller in _currencyControllers.values) {
        controller.text = '0.00';
      }
    });
  }

  void _backspace() {
    if (_activeController == null) return;
    
    setState(() {
      if (_activeController!.text.length > 1) {
        _activeController!.text = _activeController!.text.substring(
          0,
          _activeController!.text.length - 1,
        );
      } else {
        _activeController!.text = '0';
      }
    });
  }

  void _selectCurrencyField(String currencyCode, TextEditingController controller) {
    setState(() {
      _selectedCurrencyCode = currencyCode;
      _activeController = controller;
      // Clear the field when selected for new input
      if (controller.text != '0') {
        controller.text = '0';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[850] : Colors.grey[300],
      appBar: AppBar(
        backgroundColor: isDark ? Colors.grey[900] : Colors.grey[200],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        title: const Text(
          'CURRENCY PLUS',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Currency List (Reorderable)
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _currencies.length + 1, // +1 for add button
              onReorder: (oldIndex, newIndex) {
                if (oldIndex < _currencies.length && newIndex <= _currencies.length) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final currency = _currencies.removeAt(oldIndex);
                    _currencies.insert(newIndex, currency);
                    _saveCurrencies();
                    
                    // Update active controller reference after reorder
                    if (_selectedCurrencyCode != null) {
                      _activeController = _currencyControllers[_selectedCurrencyCode];
                    }
                  });
                }
              },
              itemBuilder: (context, index) {
                if (index < _currencies.length) {
                  final currency = _currencies[index];
                  return Padding(
                    key: Key(currency.code),
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _buildCurrencyRow(
                      currency: currency,
                      index: index,
                      onCurrencyChange: (newCurrency) {
                        setState(() {
                          _currencies[index] = newCurrency!;
                          _saveCurrencies();
                        });
                        final controller = _currencyControllers[currency.code];
                        if (controller != null) {
                          _convertAll(newCurrency!.code, controller.text);
                        }
                      },
                    ),
                  );
                } else {

                  // Add Currency Button
                  return InkWell(
                    key: const Key('add_currency_button'),
                    onTap: _addCurrency,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[800] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Add currency',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark ? Colors.grey[500] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),

          // Calculator Numpad
          Container(
            color: isDark ? Colors.grey[900] : Colors.white,
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                // Row 1 - Numbers 7-9
                Row(
                  children: [
                    _buildNumpadButton('7', onTap: () => _appendNumber('7')),
                    _buildNumpadButton('8', onTap: () => _appendNumber('8')),
                    _buildNumpadButton('9', onTap: () => _appendNumber('9')),
                  ],
                ),
                const SizedBox(height: 8),
                // Row 2 - Numbers 4-6
                Row(
                  children: [
                    _buildNumpadButton('4', onTap: () => _appendNumber('4')),
                    _buildNumpadButton('5', onTap: () => _appendNumber('5')),
                    _buildNumpadButton('6', onTap: () => _appendNumber('6')),
                  ],
                ),
                const SizedBox(height: 8),
                // Row 3 - Numbers 1-3
                Row(
                  children: [
                    _buildNumpadButton('1', onTap: () => _appendNumber('1')),
                    _buildNumpadButton('2', onTap: () => _appendNumber('2')),
                    _buildNumpadButton('3', onTap: () => _appendNumber('3')),
                  ],
                ),
                const SizedBox(height: 8),
                // Row 4 - Special buttons
                Row(
                  children: [
                    _buildNumpadButton('C', isSpecial: true, flex: 2, onTap: _clear),
                    _buildNumpadButton('0', onTap: () => _appendNumber('0')),
                    _buildNumpadButton('.', onTap: _appendDecimal),
                    _buildNumpadButton('⌫', isSpecial: true, flex: 2, onTap: _backspace),
                  ],
                ),
                // Bottom padding for gesture navigation
                SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyRow({
    required Currency currency,
    required int index,
    required ValueChanged<Currency?> onCurrencyChange,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Drag Handle
          Icon(
            Icons.drag_handle,
            color: isDark ? Colors.grey[500] : Colors.grey[600],
            size: 24,
          ),
          const SizedBox(width: 8),
          // Flag
          Text(
            currency.flag,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 12),

          // Currency Dropdown
          Expanded(
            flex: 2,
            child: DropdownButton<Currency>(
              value: currency,
              isExpanded: true,
              underline: const SizedBox(),
              icon: Icon(
                Icons.arrow_drop_down,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
              items: CurrencyData.currencies.map((curr) {
                return DropdownMenuItem<Currency>(
                  value: curr,
                  child: Text(
                    curr.code,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onCurrencyChange,
            ),
          ),

          // Amount Input Field
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () {
                // Select this field when tapped
                final controller = _currencyControllers[currency.code];
                if (controller != null) {
                  _selectCurrencyField(currency.code, controller);
                }
              },
              onLongPress: () {
                // Show delete option for all currencies
                _showRemoveCurrencyDialog(currency, index);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: _selectedCurrencyCode == currency.code
                      ? Colors.teal.withOpacity(0.3)
                      : (isDark ? Colors.grey[700] : Colors.white),
                  borderRadius: BorderRadius.circular(8),
                  border: _selectedCurrencyCode == currency.code
                      ? Border.all(color: Colors.teal, width: 2)
                      : null,
                ),
                child: Text(
                  _currencyControllers[currency.code]?.text ?? '0.00',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Remove Icon (for all currencies)
          GestureDetector(
            onTap: () => _showRemoveCurrencyDialog(currency, index),
            child: Icon(
              Icons.remove_circle_outline,
              color: Colors.red[400],
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumpadButton(String label, {bool isSpecial = false, int flex = 1, VoidCallback? onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Color buttonColor;
    if (isSpecial) {
      if (label == 'C') {
        buttonColor = Colors.red[300]!;
      } else if (label == '⌫') {
        buttonColor = Colors.orange[300]!;
      } else {
        buttonColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
      }
    } else {
      buttonColor = isDark ? Colors.grey[700]! : Colors.grey[300]!;
    }

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: buttonColor,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 60,
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: label.length > 1 ? 20 : 28,
                  fontWeight: FontWeight.w500,
                  color: isSpecial && label == 'C' 
                      ? Colors.white 
                      : (isDark ? Colors.white : Colors.black87),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addCurrency() {
    // Find currencies not yet in the list
    final availableCurrencies = CurrencyData.currencies.where(
      (currency) => !_currencies.contains(currency)
    ).toList();

    if (availableCurrencies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All currencies already added')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Currency'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: availableCurrencies.length,
              itemBuilder: (context, index) {
                final currency = availableCurrencies[index];
                return ListTile(
                  leading: Text(
                    currency.flag,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(currency.code),
                  subtitle: Text(currency.name),
                  onTap: () {
                    setState(() {
                      _currencies.add(currency);
                      _saveCurrencies();
                      // Initialize controller for new currency
                      final controller = TextEditingController(text: '0.00');
                      controller.addListener(() {
                        if (!_isConverting) {
                          _convertAll(currency.code, controller.text);
                        }
                      });
                      _currencyControllers[currency.code] = controller;
                    });
                    Navigator.pop(context);
                    if (_currencies.isNotEmpty) {
                      final firstController = _currencyControllers[_currencies[0].code];
                      if (firstController != null) {
                        _convertAll(_currencies[0].code, firstController.text);
                      }
                    }
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _showRemoveCurrencyDialog(Currency currency, int index) {
    // Prevent removing if it's the last currency
    if (_currencies.length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot remove the last currency')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Currency'),
          content: Text('Remove ${currency.name} (${currency.code}) from the list?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _currencies.removeAt(index);
                  _saveCurrencies();
                  // Remove the controller for this currency
                  final controller = _currencyControllers.remove(currency.code);
                  controller?.dispose();
                  // If this was the selected currency, select the first one
                  if (_selectedCurrencyCode == currency.code && _currencies.isNotEmpty) {
                    _selectedCurrencyCode = _currencies[0].code;
                    _activeController = _currencyControllers[_currencies[0].code];
                  }
                });
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    for (var controller in _currencyControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
