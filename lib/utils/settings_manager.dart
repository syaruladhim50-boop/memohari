import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager extends ChangeNotifier {
  static final SettingsManager instance = SettingsManager._internal();
  SettingsManager._internal();

  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // Defaults
  double _fontSizeOffset = 0.0;
  bool _isDarkMode = true;
  bool _glowEffects = true;

  // Getters
  double get fontSizeOffset => _fontSizeOffset;
  bool get isDarkMode => _isDarkMode;
  bool get glowEffects => _glowEffects;

  // Initialize and load preferences
  Future<void> init() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _fontSizeOffset = _prefs.getDouble('fontSizeOffset') ?? 0.0;
    _isDarkMode = _prefs.getBool('isDarkMode') ?? true;
    _glowEffects = _prefs.getBool('glowEffects') ?? true;
    _isInitialized = true;
  }

  // Setters that persist and notify
  Future<void> updateFontSizeOffset(double val) async {
    _fontSizeOffset = val;
    await _prefs.setDouble('fontSizeOffset', val);
    notifyListeners();
  }

  Future<void> updateDarkMode(bool val) async {
    _isDarkMode = val;
    await _prefs.setBool('isDarkMode', val);
    notifyListeners();
  }

  Future<void> updateGlowEffects(bool val) async {
    _glowEffects = val;
    await _prefs.setBool('glowEffects', val);
    notifyListeners();
  }
}
