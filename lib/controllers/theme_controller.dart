import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/services/user_pref_service.dart';
import 'package:kanbankit/core/themes/app_theme.dart';

enum ThemeMode { light, dark, system }

class ThemeController extends GetxController {
  late UserPrefService _userPrefService;
  
  // Observable theme mode
  final Rx<ThemeMode> _themeMode = ThemeMode.system.obs;
  ThemeMode get themeMode => _themeMode.value;
  
  // Observable for current theme data
  final Rx<ThemeData> _currentTheme = AppTheme.lightTheme.obs;
  ThemeData get currentTheme => _currentTheme.value;
  
  // Observable for current theme brightness
  final Rx<Brightness> _currentBrightness = Brightness.light.obs;
  Brightness get currentBrightness => _currentBrightness.value;

  @override
  void onInit() {
    super.onInit();
    _userPrefService = Get.find<UserPrefService>();
    _loadSavedTheme();
    _updateTheme();
  }

  // Load saved theme from storage
  void _loadSavedTheme() {
    final savedTheme = _userPrefService.getSavedThemeMode();
    if (savedTheme != null) {
      switch (savedTheme) {
        case 'light':
          _themeMode.value = ThemeMode.light;
          break;
        case 'dark':
          _themeMode.value = ThemeMode.dark;
          break;
        case 'system':
        default:
          _themeMode.value = ThemeMode.system;
          break;
      }
    }
  }

  // Update theme based on current theme mode
  void _updateTheme() {
    switch (_themeMode.value) {
      case ThemeMode.light:
        _currentTheme.value = AppTheme.lightTheme;
        _currentBrightness.value = Brightness.light;
        break;
      case ThemeMode.dark:
        _currentTheme.value = AppTheme.darkTheme;
        _currentBrightness.value = Brightness.dark;
        break;
      case ThemeMode.system:
        final systemBrightness = Get.context?.mediaQuery.platformBrightness ?? Brightness.light;
        if (systemBrightness == Brightness.dark) {
          _currentTheme.value = AppTheme.darkTheme;
          _currentBrightness.value = Brightness.dark;
        } else {
          _currentTheme.value = AppTheme.lightTheme;
          _currentBrightness.value = Brightness.light;
        }
        break;
    }
  }

  // Change theme mode
  Future<void> changeThemeMode(ThemeMode newThemeMode) async {
    _themeMode.value = newThemeMode;
    _updateTheme();
    
    // Save to storage
    String themeModeString;
    switch (newThemeMode) {
      case ThemeMode.light:
        themeModeString = 'light';
        break;
      case ThemeMode.dark:
        themeModeString = 'dark';
        break;
      case ThemeMode.system:
        themeModeString = 'system';
        break;
    }
    
    await _userPrefService.saveThemeMode(themeModeString);
    
    // Update GetX theme
    Get.changeTheme(_currentTheme.value);
  }

  // Toggle between light and dark theme
  Future<void> toggleTheme() async {
    if (_themeMode.value == ThemeMode.light) {
      await changeThemeMode(ThemeMode.dark);
    } else if (_themeMode.value == ThemeMode.dark) {
      await changeThemeMode(ThemeMode.light);
    } else {
      // If system mode, toggle to opposite of current system theme
      final systemBrightness = Get.context?.mediaQuery.platformBrightness ?? Brightness.light;
      if (systemBrightness == Brightness.dark) {
        await changeThemeMode(ThemeMode.light);
      } else {
        await changeThemeMode(ThemeMode.dark);
      }
    }
  }

  // Check if current theme is dark
  bool get isDarkMode {
    return _currentBrightness.value == Brightness.dark;
  }

  // Check if current theme is light
  bool get isLightMode {
    return _currentBrightness.value == Brightness.light;
  }

  // Check if system theme mode is enabled
  bool get isSystemMode {
    return _themeMode.value == ThemeMode.system;
  }

  // Get theme mode display name
  String get themeModeDisplayName {
    switch (_themeMode.value) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  // Listen to system theme changes when in system mode
  void handleSystemThemeChange() {
    if (_themeMode.value == ThemeMode.system) {
      _updateTheme();
      Get.changeTheme(_currentTheme.value);
    }
  }
}
