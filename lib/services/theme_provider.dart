import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  ThemeProvider() {
    _loadFromPrefs();
  }

  bool get isDarkMode => _isDarkMode;

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners(); // Notify listeners when preference is loaded
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setBool('isDarkMode', _isDarkMode));
    notifyListeners(); // Notify listeners about the change
  }
}
