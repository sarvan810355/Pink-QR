import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Tracks Day Pink / Night Pink theme preference, persisted locally.
class ThemeService extends ChangeNotifier {
  static const _key = 'qr_bloom_dark_mode';

  bool _isNight = false;
  bool get isNight => _isNight;
  ThemeMode get themeMode => _isNight ? ThemeMode.dark : ThemeMode.light;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _isNight = prefs.getBool(_key) ?? false;
    notifyListeners();
  }

  Future<void> toggle(bool night) async {
    _isNight = night;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, night);
  }
}
