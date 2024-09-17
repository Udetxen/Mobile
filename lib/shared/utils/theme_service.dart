import 'package:flutter/foundation.dart';
import 'package:udetxen/shared/config/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  final prefs = getIt<SharedPreferences>();

  void saveThemeMode(bool isDarkMode) {
    prefs.setBool(_themeKey, isDarkMode);
  }

  void toggleThemeMode() {
    bool currentMode = prefs.getBool(_themeKey) ?? false;
    prefs.setBool(_themeKey, !currentMode);
    notifyListeners();
  }

  bool get isDarkMode {
    bool currentMode = prefs.getBool(_themeKey) ?? false;
    return currentMode;
  }
}
