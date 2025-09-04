import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStateProvider extends ChangeNotifier {
  // Theme settings
  ThemeMode _themeMode = ThemeMode.system;
  bool _isDarkMode = false;
  bool _isHighContrast = false;
  double _textScale = 1.0;
  Color _accentColor = Colors.blue;
  
  // Accessibility settings
  bool _isAccessibilityEnabled = false;
  bool _isVoiceFeedbackEnabled = true;
  bool _isLargeTextEnabled = false;
  bool _isHighContrastEnabled = false;
  bool _isReduceAnimationsEnabled = false;
  
  // Wake word settings
  String _wakeWord = 'Hey Sage';
  bool _isWakeWordEnabled = false;
  
  // App settings
  bool _isFirstLaunch = true;
  String _selectedLanguage = 'en';

  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _isDarkMode;
  bool get isHighContrast => _isHighContrast;
  double get textScale => _textScale;
  Color get accentColor => _accentColor;
  bool get isAccessibilityEnabled => _isAccessibilityEnabled;
  bool get isVoiceFeedbackEnabled => _isVoiceFeedbackEnabled;
  bool get isLargeTextEnabled => _isLargeTextEnabled;
  bool get isHighContrastEnabled => _isHighContrastEnabled;
  bool get isReduceAnimationsEnabled => _isReduceAnimationsEnabled;
  String get wakeWord => _wakeWord;
  bool get isWakeWordEnabled => _isWakeWordEnabled;
  bool get isFirstLaunch => _isFirstLaunch;
  String get selectedLanguage => _selectedLanguage;

  // Theme Data
  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _accentColor,
      brightness: Brightness.light,
    ).copyWith(
      primary: _accentColor,
      secondary: _accentColor.withOpacity(0.7),
    ),
    textTheme: _getTextTheme(Brightness.light),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
      ),
    ),
  );

  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _accentColor,
      brightness: Brightness.dark,
    ).copyWith(
      primary: _accentColor,
      secondary: _accentColor.withOpacity(0.7),
    ),
    textTheme: _getTextTheme(Brightness.dark),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _accentColor,
        foregroundColor: Colors.white,
      ),
    ),
  );

  ThemeData get highContrastTheme => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.highContrastLight(),
    textTheme: _getTextTheme(Brightness.light, highContrast: true),
  );

  TextTheme _getTextTheme(Brightness brightness, {bool highContrast = false}) {
    final baseTheme = brightness == Brightness.light 
        ? ThemeData.light().textTheme 
        : ThemeData.dark().textTheme;
        
    return baseTheme.apply(
      fontSizeFactor: _textScale,
      bodyColor: highContrast ? Colors.black : null,
      displayColor: highContrast ? Colors.black : null,
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

  Future<void> toggleHighContrast() async {
    _isHighContrast = !_isHighContrast;
    _isHighContrastEnabled = _isHighContrast;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> toggleLargeText() async {
    _isLargeTextEnabled = !_isLargeTextEnabled;
    _textScale = _isLargeTextEnabled ? 1.3 : 1.0;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> toggleReduceAnimations() async {
    _isReduceAnimationsEnabled = !_isReduceAnimationsEnabled;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> updateTextScale(double scale) async {
    _textScale = scale;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> updateAccentColor(Color color) async {
    _accentColor = color;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> toggleAccessibility() async {
    _isAccessibilityEnabled = !_isAccessibilityEnabled;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> toggleVoiceFeedback() async {
    _isVoiceFeedbackEnabled = !_isVoiceFeedbackEnabled;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> updateWakeWord(String wakeWord) async {
    _wakeWord = wakeWord;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> toggleWakeWord() async {
    _isWakeWordEnabled = !_isWakeWordEnabled;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> updateLanguage(String language) async {
    _selectedLanguage = language;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> markFirstLaunchComplete() async {
    _isFirstLaunch = false;
    await _saveSettings();
    notifyListeners();
  }

  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setBool('isHighContrast', _isHighContrast);
    await prefs.setDouble('textScale', _textScale);
    await prefs.setInt('accentColor', _accentColor.value);
    await prefs.setBool('isAccessibilityEnabled', _isAccessibilityEnabled);
    await prefs.setBool('isVoiceFeedbackEnabled', _isVoiceFeedbackEnabled);
    await prefs.setString('wakeWord', _wakeWord);
    await prefs.setBool('isWakeWordEnabled', _isWakeWordEnabled);
    await prefs.setBool('isFirstLaunch', _isFirstLaunch);
    await prefs.setString('selectedLanguage', _selectedLanguage);
  }

  // Load settings from SharedPreferences
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _isHighContrast = prefs.getBool('isHighContrast') ?? false;
    _textScale = prefs.getDouble('textScale') ?? 1.0;
    _accentColor = Color(prefs.getInt('accentColor') ?? Colors.blue.value);
    _isAccessibilityEnabled = prefs.getBool('isAccessibilityEnabled') ?? false;
    _isVoiceFeedbackEnabled = prefs.getBool('isVoiceFeedbackEnabled') ?? true;
    _wakeWord = prefs.getString('wakeWord') ?? 'Hey Sage';
    _isWakeWordEnabled = prefs.getBool('isWakeWordEnabled') ?? false;
    _isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;
    _selectedLanguage = prefs.getString('selectedLanguage') ?? 'en';
    notifyListeners();
  }

  // Get current theme based on settings
  ThemeData getCurrentTheme() {
    if (_isHighContrast) {
      return highContrastTheme;
    } else if (_isDarkMode) {
      return darkTheme;
    } else {
      return lightTheme;
    }
  }
}
