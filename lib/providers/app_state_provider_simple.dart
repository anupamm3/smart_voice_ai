import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStateProvider extends ChangeNotifier {
  // Theme settings
  ThemeMode _themeMode = ThemeMode.system;
  bool _isDarkMode = false;
  double _textScale = 1.0;
  Color _accentColor = Colors.blue;
  
  // Accessibility settings
  bool _isLargeTextEnabled = false;
  bool _isHighContrastEnabled = false;
  bool _isReduceAnimationsEnabled = false;
  
  // App settings
  bool _isFirstLaunch = true;
  String _selectedLanguage = 'en';

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;
  double get textScale => _textScale;
  Color get accentColor => _accentColor;
  bool get isLargeTextEnabled => _isLargeTextEnabled;
  bool get isHighContrastEnabled => _isHighContrastEnabled;
  bool get isReduceAnimationsEnabled => _isReduceAnimationsEnabled;
  bool get isFirstLaunch => _isFirstLaunch;
  String get selectedLanguage => _selectedLanguage;

  // Theme Data
  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _accentColor,
      brightness: Brightness.light,
    ),
    textTheme: _getTextTheme(Brightness.light),
  );

  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _accentColor,
      brightness: Brightness.dark,
    ),
    textTheme: _getTextTheme(Brightness.dark),
  );

  TextTheme _getTextTheme(Brightness brightness) {
    final baseTheme = brightness == Brightness.light 
        ? ThemeData.light().textTheme 
        : ThemeData.dark().textTheme;
        
    return baseTheme.apply(
      fontSizeFactor: _textScale,
    );
  }

  // Methods to update settings
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    _isDarkMode = mode == ThemeMode.dark;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> toggleLargeText() async {
    _isLargeTextEnabled = !_isLargeTextEnabled;
    _textScale = _isLargeTextEnabled ? 1.3 : 1.0;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> toggleHighContrast() async {
    _isHighContrastEnabled = !_isHighContrastEnabled;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> toggleReduceAnimations() async {
    _isReduceAnimationsEnabled = !_isReduceAnimationsEnabled;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> updateAccentColor(Color color) async {
    _accentColor = color;
    await _saveSettings();
    notifyListeners();
  }

  // Load settings from SharedPreferences
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _themeMode = _isDarkMode ? ThemeMode.dark : ThemeMode.light;
      _textScale = prefs.getDouble('textScale') ?? 1.0;
      _isLargeTextEnabled = _textScale > 1.0;
      _isHighContrastEnabled = prefs.getBool('isHighContrast') ?? false;
      _isReduceAnimationsEnabled = prefs.getBool('isReduceAnimations') ?? false;
      _isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
      _selectedLanguage = prefs.getString('selectedLanguage') ?? 'en';
      
      // Load accent color
      final colorValue = prefs.getInt('accentColor');
      if (colorValue != null) {
        _accentColor = Color(colorValue);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _isDarkMode);
      await prefs.setDouble('textScale', _textScale);
      await prefs.setBool('isHighContrast', _isHighContrastEnabled);
      await prefs.setBool('isReduceAnimations', _isReduceAnimationsEnabled);
      await prefs.setBool('isFirstLaunch', _isFirstLaunch);
      await prefs.setString('selectedLanguage', _selectedLanguage);
      await prefs.setInt('accentColor', _accentColor.value);
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  // Initialize the provider
  Future<void> initialize() async {
    await loadSettings();
  }
}
