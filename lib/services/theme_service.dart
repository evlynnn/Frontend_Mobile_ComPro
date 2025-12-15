import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _notificationsKey = 'push_notifications';

  ThemeMode _themeMode = ThemeMode.light;
  bool _pushNotificationsEnabled = true;

  ThemeMode get themeMode => _themeMode;
  bool get pushNotificationsEnabled => _pushNotificationsEnabled;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeService() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(_themeKey) ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    _pushNotificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  Future<void> toggleTheme() async {
    final newMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }

  Future<void> setPushNotifications(bool enabled) async {
    _pushNotificationsEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
  }

  Future<void> togglePushNotifications() async {
    await setPushNotifications(!_pushNotificationsEnabled);
  }
}
