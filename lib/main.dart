import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/multi_currency_screen.dart';
import 'services/preferences_service.dart';
import 'services/storage_service.dart';
import 'services/history_service.dart';
import 'services/favorites_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final storageService = StorageService();
  await storageService.init();
  
  final preferencesService = PreferencesService();
  await preferencesService.init();
  
  final historyService = HistoryService();
  await historyService.init();
  
  final favoritesService = FavoritesService();
  await favoritesService.init();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: preferencesService),
        Provider.value(value: storageService),
        Provider.value(value: historyService),
        Provider.value(value: favoritesService),
      ],
      child: const CurrencyPlusApp(),
    ),
  );
}

class CurrencyPlusApp extends StatelessWidget {
  const CurrencyPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    final preferencesService = context.watch<PreferencesService>();
    
    return MaterialApp(
      title: 'Currency Plus',
      debugShowCheckedModeBanner: false,
      themeMode: preferencesService.getThemeMode(),
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      home: const MultiCurrencyScreen(),
    );
  }
  
  ThemeData _buildLightTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
    );
  }
  
  ThemeData _buildDarkTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: Brightness.dark,
      ),
      useMaterial3: true,
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
      ),
    );
  }
}
