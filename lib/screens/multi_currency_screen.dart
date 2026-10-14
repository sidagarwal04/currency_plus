import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/currency.dart';
import '../services/hybrid_currency_service.dart';
import '../services/preferences_service.dart';
import 'currency_converter_screen.dart';
import 'history_screen.dart';

class MultiCurrencyScreen extends StatefulWidget {
  const MultiCurrencyScreen({super.key});

  @override
  State<MultiCurrencyScreen> createState() => _MultiCurrencyScreenState();
}

class _MultiCurrencyScreenState extends State<MultiCurrencyScreen> {
  final HybridCurrencyService _currencyService = HybridCurrencyService();
  final FocusNode _keyboardFocusNode = FocusNode();
  final NumberFormat _displayFormatter = NumberFormat('#,##0.00');

  List<Currency> _currencies = [
    CurrencyData.currencies[8], // INR
    CurrencyData.currencies[0], // USD
    CurrencyData.currencies[1], // EUR
    CurrencyData.currencies[2], // GBP
    CurrencyData.currencies[4], // AUD
    CurrencyData.currencies[10], // SGD
  ];

  final Map<String, double> _exchangeRates = {};
  final Map<String, TextEditingController> _currencyControllers = {};
  bool _isConverting = false;
  bool _replaceOnNextDigit = true;
  bool _showKeypadOnMobile = true;

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
    if (_currencies.isNotEmpty) {
      final firstCode = _currencies[0].code;
      final firstController = _currencyControllers[firstCode];
      if (firstController != null &&
          (firstController.text == '0' || firstController.text == '0.00')) {
        firstController.text = '100';
      }
      setState(() {
        _selectedCurrencyCode = firstCode;
        _activeController = firstController;
        _replaceOnNextDigit = true;
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_currencies.isNotEmpty) {
        final code = _currencies[0].code;
        _convertAll(code, _currencyControllers[code]?.text ?? '100');
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

  void _ensureControllerForCurrency(String code, {String initialText = '0.00'}) {
    if (!_currencyControllers.containsKey(code)) {
      final controller = TextEditingController(text: initialText);
      controller.addListener(() {
        if (!_isConverting && _selectedCurrencyCode == code) {
          _convertAll(code, controller.text);
        }
      });
      _currencyControllers[code] = controller;
    }
  }

  void _initializeCurrencyControllers() {
    for (int i = 0; i < _currencies.length; i++) {
      final currency = _currencies[i];
      _ensureControllerForCurrency(
        currency.code,
        initialText: i == 0 ? '100' : '0.00',
      );
    }
  }

  Future<void> _convertAll(String fromCurrencyCode, String amountText) async {
    if (_isConverting) return;

    final cleaned = amountText.replaceAll(',', '').trim();
    final amount = cleaned.isEmpty ? 0.0 : (double.tryParse(cleaned) ?? 0.0);
    if (amount < 0) return;

    _isConverting = true;

    try {
      final updatedRates = <String, double>{fromCurrencyCode: 1.0};
      final updatedValues = <String, String>{};

      for (final currency in _currencies) {
        if (currency.code == fromCurrencyCode) continue;

        final rate = await _currencyService.getExchangeRate(
          fromCurrency: fromCurrencyCode,
          toCurrency: currency.code,
        );

        final result = await _currencyService.convert(
          amount: amount,
          fromCurrency: fromCurrencyCode,
          toCurrency: currency.code,
        );

        if (rate != null) {
          updatedRates[currency.code] = rate;
        }
        if (result != null) {
          updatedValues[currency.code] = result.toStringAsFixed(2);
        }
      }

      if (!mounted) return;

      setState(() {
        _exchangeRates
          ..clear()
          ..addAll(updatedRates);

        for (final entry in updatedValues.entries) {
          final controller = _currencyControllers[entry.key];
          if (controller != null) {
            controller.value = TextEditingValue(
              text: entry.value,
              selection: TextSelection.collapsed(offset: entry.value.length),
            );
          }
        }
      });
    } catch (_) {
      // Ignore transient conversion errors
    } finally {
      _isConverting = false;
    }
  }

  void _setQuickAmount(String value) {
    if (_activeController == null || _selectedCurrencyCode == null) return;
    setState(() {
      _activeController!.text = value;
      _replaceOnNextDigit = true;
    });
    _convertAll(_selectedCurrencyCode!, value);
  }

  void _appendNumber(String number) {
    if (_activeController == null || _selectedCurrencyCode == null) return;

    setState(() {
      final current = _activeController!.text;
      if (_replaceOnNextDigit || current == '0' || current == '0.00') {
        _activeController!.text = number;
        _replaceOnNextDigit = false;
      } else if (current.length < 15) {
        // Limit decimal places to 4 when typing
        final dotIndex = current.indexOf('.');
        if (dotIndex != -1 && current.length - dotIndex > 4) {
          return;
        }
        _activeController!.text = current + number;
      }
    });
    _convertAll(_selectedCurrencyCode!, _activeController!.text);
  }

  void _appendDecimal() {
    if (_activeController == null || _selectedCurrencyCode == null) return;

    setState(() {
      if (_replaceOnNextDigit) {
        _activeController!.text = '0.';
        _replaceOnNextDigit = false;
      } else if (!_activeController!.text.contains('.')) {
        _activeController!.text += '.';
      }
    });
    _convertAll(_selectedCurrencyCode!, _activeController!.text);
  }

  void _clear() {
    if (_selectedCurrencyCode == null) return;
    setState(() {
      _replaceOnNextDigit = true;
      for (final controller in _currencyControllers.values) {
        controller.text = '0.00';
      }
      if (_activeController != null) {
        _activeController!.text = '0';
      }
    });
    _convertAll(_selectedCurrencyCode!, '0');
  }

  void _backspace() {
    if (_activeController == null || _selectedCurrencyCode == null) return;

    setState(() {
      if (_replaceOnNextDigit) {
        _activeController!.text = '0';
        _replaceOnNextDigit = false;
        return;
      }
      final current = _activeController!.text;
      if (current.length > 1) {
        _activeController!.text = current.substring(0, current.length - 1);
      } else {
        _activeController!.text = '0';
      }
    });
    _convertAll(_selectedCurrencyCode!, _activeController!.text);
  }

  void _selectCurrencyField(
    String currencyCode,
    TextEditingController controller,
  ) {
    setState(() {
      _selectedCurrencyCode = currencyCode;
      _activeController = controller;
      _replaceOnNextDigit = true;
      _showKeypadOnMobile = true;
    });
    _keyboardFocusNode.requestFocus();
    _convertAll(currencyCode, controller.text);
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    // Do not intercept keys if a modal dialog/sheet is open
    if (ModalRoute.of(context)?.isCurrent != true) {
      return KeyEventResult.ignored;
    }

    final character = event.character;
    final key = event.logicalKey;

    if (character != null && RegExp(r'^[0-9]$').hasMatch(character)) {
      _appendNumber(character);
      return KeyEventResult.handled;
    }

    if (character == '.' || key == LogicalKeyboardKey.numpadDecimal) {
      _appendDecimal();
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.backspace) {
      _backspace();
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.escape ||
        key == LogicalKeyboardKey.delete ||
        character == 'c' ||
        character == 'C') {
      _clear();
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowUp) {
      if (_currencies.isEmpty) return KeyEventResult.ignored;
      final currentIdx = _currencies.indexWhere(
        (c) => c.code == _selectedCurrencyCode,
      );
      final delta = key == LogicalKeyboardKey.arrowDown ? 1 : -1;
      final nextIdx =
          (currentIdx + delta + _currencies.length) % _currencies.length;
      final nextCurrency = _currencies[nextIdx];
      final nextController = _currencyControllers[nextCurrency.code];
      if (nextController != null) {
        _selectCurrencyField(nextCurrency.code, nextController);
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  String _formatAmountForDisplay(String rawText, bool isSelected) {
    if (isSelected && !_replaceOnNextDigit) {
      return rawText;
    }
    final cleaned = rawText.replaceAll(',', '').trim();
    final parsed = double.tryParse(cleaned);
    if (parsed == null) return rawText;
    if (parsed >= 1000) {
      return _displayFormatter.format(parsed);
    }
    return parsed.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Focus(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        appBar: _buildAppBar(context, colorScheme, isDark),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Use side-by-side layout on wide screens (desktop/tablet/web)
              // or landscape screens where vertical height is constrained
              final bool isWideLayout =
                  constraints.maxWidth >= 760 ||
                  (constraints.maxWidth >= 560 && constraints.maxHeight < 540);

              if (isWideLayout) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1140),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left Panel: Currency List
                          Expanded(
                            flex: 7,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildHeaderStatusCard(colorScheme, isDark),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: _buildCurrencyList(
                                    colorScheme,
                                    isDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          // Right Panel: Adaptive Calculator Keypad Card
                          SizedBox(
                            width: (constraints.maxWidth * 0.34).clamp(
                              280.0,
                              360.0,
                            ),
                            child: _buildSideNumpadCard(
                              colorScheme,
                              isDark,
                              constraints.maxHeight - 32,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // Mobile / Narrow Portrait Layout
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                        child: _buildHeaderStatusCard(
                          colorScheme,
                          isDark,
                          isCompact: true,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: _buildCurrencyList(colorScheme, isDark),
                        ),
                      ),
                      if (_showKeypadOnMobile)
                        _buildMobileBottomNumpad(
                          colorScheme,
                          isDark,
                          constraints.maxHeight,
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final width = MediaQuery.of(context).size.width;
    final isMobileWidth = width < 760;

    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      titleSpacing: 16,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/icon.png',
              width: 34,
              height: 34,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Currency Plus',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  _currencyService.isLiveApiActive
                      ? 'Live Exchange Rates'
                      : 'Offline Reference Rates',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: _currencyService.isLiveApiActive
                        ? Colors.green
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        // Toggle Single vs Multi Converter
        IconButton(
          icon: const Icon(Icons.swap_horiz_rounded),
          tooltip: 'Pair Converter & Favorites',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CurrencyConverterScreen(),
              ),
            );
          },
        ),
        // Conversion History
        IconButton(
          icon: const Icon(Icons.history_rounded),
          tooltip: 'Conversion History',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HistoryScreen(),
              ),
            );
          },
        ),
        // Toggle Keypad button on mobile
        if (isMobileWidth)
          IconButton(
            icon: Icon(
              _showKeypadOnMobile
                  ? Icons.keyboard_hide_rounded
                  : Icons.dialpad_rounded,
            ),
            tooltip: _showKeypadOnMobile ? 'Hide Keypad' : 'Show Keypad',
            onPressed: () {
              setState(() {
                _showKeypadOnMobile = !_showKeypadOnMobile;
              });
            },
          ),
        // Dark / Light mode toggle
        Consumer<PreferencesService>(
          builder: (context, prefs, _) {
            final effectiveDark =
                Theme.of(context).brightness == Brightness.dark;
            return IconButton(
              icon: Icon(
                effectiveDark
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded,
              ),
              tooltip: effectiveDark
                  ? 'Switch to Light Mode'
                  : 'Switch to Dark Mode',
              onPressed: () {
                prefs.setDarkMode(!effectiveDark);
              },
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildHeaderStatusCard(
    ColorScheme colorScheme,
    bool isDark, {
    bool isCompact = false,
  }) {
    final activeCurrency = CurrencyData.findByCode(
      _selectedCurrencyCode ?? 'USD',
    );
    final presets = ['1', '10', '100', '500', '1000'];

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 12 : 16,
        vertical: isCompact ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          if (activeCurrency != null) ...[
            Text(
              activeCurrency.flag,
              style: TextStyle(fontSize: isCompact ? 20 : 22),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Base: ${activeCurrency.code}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: isCompact ? 13 : 14,
                  ),
                ),
                if (!isCompact)
                  Text(
                    'Click any row or press ↑↓ to switch base currency',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(width: 12),
          // Quick preset chips aligned to the right
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: presets.map((preset) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: ActionChip(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        label: Text(
                          '${activeCurrency?.symbol ?? ''}$preset',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () => _setQuickAmount(preset),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyList(ColorScheme colorScheme, bool isDark) {
    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      padding: const EdgeInsets.symmetric(vertical: 6),
      itemCount: _currencies.length + 1,
      onReorder: (oldIndex, newIndex) {
        if (oldIndex < _currencies.length && newIndex <= _currencies.length) {
          setState(() {
            if (newIndex > oldIndex) {
              newIndex -= 1;
            }
            if (newIndex >= _currencies.length) {
              newIndex = _currencies.length - 1;
            }
            final currency = _currencies.removeAt(oldIndex);
            _currencies.insert(newIndex, currency);
            _saveCurrencies();

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
            key: ValueKey('currency_row_${currency.code}'),
            padding: const EdgeInsets.only(bottom: 8),
            child: _buildCurrencyRow(
              currency: currency,
              index: index,
              colorScheme: colorScheme,
              isDark: isDark,
            ),
          );
        } else {
          // Add Currency Button
          return Padding(
            key: const ValueKey('add_currency_button'),
            padding: const EdgeInsets.only(top: 4, bottom: 16),
            child: OutlinedButton.icon(
              onPressed: () => _showCurrencyPickerModal(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(
                  color: colorScheme.primary.withValues(alpha: 0.5),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                backgroundColor: isDark
                    ? const Color(0xFF1E293B).withValues(alpha: 0.6)
                    : Colors.white,
              ),
              icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
              label: const Text(
                'Add currency',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildCurrencyRow({
    required Currency currency,
    required int index,
    required ColorScheme colorScheme,
    required bool isDark,
  }) {
    final isSelected = _selectedCurrencyCode == currency.code;
    final controller = _currencyControllers[currency.code];
    final rawAmount = controller?.text ?? '0.00';
    final displayAmount = _formatAmountForDisplay(rawAmount, isSelected);
    final rate = _exchangeRates[currency.code];
    final baseCode = _selectedCurrencyCode ?? _currencies.first.code;

    return Material(
      color: isSelected
          ? (isDark
                ? colorScheme.primaryContainer.withValues(alpha: 0.35)
                : colorScheme.primaryContainer.withValues(alpha: 0.45))
          : (isDark ? const Color(0xFF1E293B) : Colors.white),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          if (controller != null) {
            _selectCurrencyField(currency.code, controller);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant.withValues(alpha: 0.4),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
          //Drag Handle
          ReorderableDragStartListener(
            index: index,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 4,
                vertical: 8,
              ),
              child: Icon(
                Icons.drag_handle,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                size: 24,
              ),
            ),
          ),
              const SizedBox(width: 6),

              // Currency Selector Pill + Rate Info (expands naturally)
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _showCurrencyPickerModal(replaceIndex: index),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: Row(
                      children: [
                        Text(
                          currency.flag,
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    currency.code,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 18,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ],
                              ),
                              Text(
                                currency.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              if (!isSelected && rate != null)
                                Text(
                                  '1 $baseCode = ${rate.toStringAsFixed(rate < 0.1 ? 4 : 2)} ${currency.code}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.primary,
                                  ),
                                )
                              else if (isSelected)
                                Text(
                                  'Active input',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.primary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Amount Display Pill (compact & right-aligned, no wasted empty space)
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 110, maxWidth: 190),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark
                              ? const Color(0xFF0F172A)
                              : Colors.white.withValues(alpha: 0.9))
                        : (isDark
                              ? const Color(0xFF0F172A).withValues(alpha: 0.5)
                              : const Color(0xFFF8FAFC)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary.withValues(alpha: 0.5)
                          : colorScheme.outlineVariant.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        currency.symbol,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            displayAmount,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 4),

              // Copy button
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.copy_rounded,
                  size: 17,
                  color: colorScheme.onSurfaceVariant,
                ),
                tooltip: 'Copy amount',
                onPressed: () {
                  Clipboard.setData(
                    ClipboardData(text: '${currency.code} $displayAmount'),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Copied ${currency.code} $displayAmount'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),

              // Remove currency button
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  Icons.remove_circle_outline,
                  size: 20,
                  color: Colors.red[400],
                ),
                tooltip: 'Remove ${currency.code}',
                onPressed: () => _showRemoveCurrencyDialog(currency, index),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSideNumpadCard(
    ColorScheme colorScheme,
    bool isDark,
    double availableHeight,
  ) {
    final activeCurrency = CurrencyData.findByCode(
      _selectedCurrencyCode ?? 'USD',
    );
    final rawText = _activeController?.text ?? '0';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Active Currency Display Display Box
          if (availableHeight >= 320) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0F172A)
                    : colorScheme.primaryContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        activeCurrency?.flag ?? '💱',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        activeCurrency?.code ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: colorScheme.primary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Selected Input',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${activeCurrency?.symbol ?? ''} ${_formatAmountForDisplay(rawText, true)}',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Flexible 4-row Numpad Grid that never overflows vertically
          Expanded(
            child: _buildFlexibleNumpadGrid(colorScheme, isDark),
          ),

          if (availableHeight >= 380) ...[
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.keyboard_alt_outlined,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Keyboard typing supported (0-9, ., Backspace, Esc)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMobileBottomNumpad(
    ColorScheme colorScheme,
    bool isDark,
    double totalScreenHeight,
  ) {
    // Dynamically size keypad height between 180px and 260px so it never overflows
    final double keypadHeight = (totalScreenHeight * 0.34).clamp(170.0, 250.0);

    return Container(
      height: keypadHeight,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: _buildFlexibleNumpadGrid(colorScheme, isDark),
    );
  }

  Widget _buildFlexibleNumpadGrid(ColorScheme colorScheme, bool isDark) {
    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildNumpadButton(
                '7',
                colorScheme: colorScheme,
                isDark: isDark,
                onTap: () => _appendNumber('7'),
              ),
              _buildNumpadButton(
                '8',
                colorScheme: colorScheme,
                isDark: isDark,
                onTap: () => _appendNumber('8'),
              ),
              _buildNumpadButton(
                '9',
                colorScheme: colorScheme,
                isDark: isDark,
                onTap: () => _appendNumber('9'),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildNumpadButton(
                '4',
                colorScheme: colorScheme,
                isDark: isDark,
                onTap: () => _appendNumber('4'),
              ),
              _buildNumpadButton(
                '5',
                colorScheme: colorScheme,
                isDark: isDark,
                onTap: () => _appendNumber('5'),
              ),
              _buildNumpadButton(
                '6',
                colorScheme: colorScheme,
                isDark: isDark,
                onTap: () => _appendNumber('6'),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildNumpadButton(
                '1',
                colorScheme: colorScheme,
                isDark: isDark,
                onTap: () => _appendNumber('1'),
              ),
              _buildNumpadButton(
                '2',
                colorScheme: colorScheme,
                isDark: isDark,
                onTap: () => _appendNumber('2'),
              ),
              _buildNumpadButton(
                '3',
                colorScheme: colorScheme,
                isDark: isDark,
                onTap: () => _appendNumber('3'),
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildNumpadButton(
                'C',
                isSpecial: true,
                colorScheme: colorScheme,
                isDark: isDark,
                onTap: _clear,
              ),
              _buildNumpadButton(
                '0',
                colorScheme: colorScheme,
                isDark: isDark,
                onTap: () => _appendNumber('0'),
              ),
              _buildNumpadButton(
                '.',
                colorScheme: colorScheme,
                isDark: isDark,
                onTap: _appendDecimal,
              ),
              _buildNumpadButton(
                '⌫',
                isSpecial: true,
                colorScheme: colorScheme,
                isDark: isDark,
                onTap: _backspace,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNumpadButton(
    String label, {
    bool isSpecial = false,
    int flex = 1,
    required ColorScheme colorScheme,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    Color bgColor;
    Color textColor;

    if (isSpecial && label == 'C') {
      bgColor = isDark
          ? Colors.red.shade900.withValues(alpha: 0.6)
          : Colors.red.shade50;
      textColor = isDark ? Colors.red.shade200 : Colors.red.shade700;
    } else if (isSpecial && label == '⌫') {
      bgColor = isDark
          ? Colors.amber.shade900.withValues(alpha: 0.5)
          : Colors.amber.shade50;
      textColor = isDark ? Colors.amber.shade200 : Colors.amber.shade800;
    } else {
      bgColor = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
      textColor = colorScheme.onSurface;
    }

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCurrencyPickerModal({int? replaceIndex}) {
    final existingCodes = _currencies.map((c) => c.code).toSet();
    final availableCurrencies = CurrencyData.currencies.where((c) {
      if (replaceIndex != null && _currencies[replaceIndex].code == c.code) {
        return true;
      }
      return !existingCodes.contains(c.code);
    }).toList();

    if (availableCurrencies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All currencies already added')),
      );
      return;
    }

    String searchQuery = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: 560),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filtered = availableCurrencies.where((c) {
              final q = searchQuery.toLowerCase().trim();
              if (q.isEmpty) return true;
              return c.code.toLowerCase().contains(q) ||
                  c.name.toLowerCase().contains(q) ||
                  c.symbol.toLowerCase().contains(q);
            }).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.75,
              minChildSize: 0.5,
              maxChildSize: 0.92,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            replaceIndex != null
                                ? 'Switch Currency'
                                : 'Add Currency',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Search currency code or country...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (val) {
                          setModalState(() {
                            searchQuery = val;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: filtered.isEmpty
                            ? const Center(
                                child: Text('No matching currencies found'),
                              )
                            : ListView.separated(
                                controller: scrollController,
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) =>
                                    const Divider(height: 1),
                                itemBuilder: (context, idx) {
                                  final currency = filtered[idx];
                                  return ListTile(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    leading: Text(
                                      currency.flag,
                                      style: const TextStyle(fontSize: 26),
                                    ),
                                    title: Text(
                                      '${currency.code} • ${currency.name}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                     trailing: Text(
                                      currency.symbol,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _ensureControllerForCurrency(
                                          currency.code,
                                        );
                                        if (replaceIndex != null) {
                                          final oldCode =
                                              _currencies[replaceIndex].code;
                                          _currencies[replaceIndex] = currency;
                                          if (_selectedCurrencyCode ==
                                              oldCode) {
                                            _selectedCurrencyCode =
                                                currency.code;
                                            _activeController =
                                                _currencyControllers[currency
                                                    .code];
                                            _activeController?.text =
                                                _currencyControllers[oldCode]
                                                    ?.text ??
                                                '100';
                                          }
                                        } else {
                                          _currencies.add(currency);
                                        }
                                        _saveCurrencies();
                                      });
                                      Navigator.pop(context);
                                      final activeCode =
                                          _selectedCurrencyCode ??
                                          _currencies.first.code;
                                      final activeText =
                                          _currencyControllers[activeCode]
                                              ?.text ??
                                          '100';
                                      _convertAll(activeCode, activeText);
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showRemoveCurrencyDialog(Currency currency, int index) {
    if (_currencies.length <= 1) {
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
          content: Text(
            'Remove ${currency.name} (${currency.code}) from the list?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  _currencies.removeAt(index);
                  _saveCurrencies();
                  final controller = _currencyControllers.remove(currency.code);
                  controller?.dispose();
                  if (_selectedCurrencyCode == currency.code &&
                      _currencies.isNotEmpty) {
                    _selectedCurrencyCode = _currencies[0].code;
                    _activeController =
                        _currencyControllers[_currencies[0].code];
                  }
                });
                Navigator.pop(context);
              },
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    for (final controller in _currencyControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
