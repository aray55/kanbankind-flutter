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

  // Observable for current theme brightness
  final Rx<Brightness> _currentBrightness = Brightness.light.obs;
  Brightness get currentBrightness => _currentBrightness.value;

  // Flag to track if controller is ready to update themes
  bool _isInitialized = false;

  @override
  void onInit() {
    super.onInit();
    _userPrefService = Get.find<UserPrefService>();
    _loadSavedTheme();
    _isInitialized = true;
  }

  @override
  void onReady() {
    super.onReady();
    // Update theme once the widget tree is ready
    if (Get.context != null) {
      _updateTheme();
      // Notify GetBuilder to rebuild UI
      update();
    }
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
  void _updateTheme([BuildContext? context]) {
    // Don't update theme if controller is not initialized or no context available
    if (!_isInitialized) return;

    final buildContext = context ?? Get.context;
    if (buildContext == null) return;

    switch (_themeMode.value) {
      case ThemeMode.light:
        _currentBrightness.value = Brightness.light;
        break;
      case ThemeMode.dark:
        _currentBrightness.value = Brightness.dark;
        break;
      case ThemeMode.system:
        final systemBrightness = buildContext.mounted
            ? MediaQuery.of(buildContext).platformBrightness
            : Brightness.light;
        _currentBrightness.value = systemBrightness;
        break;
    }
  }

  // Get current theme data based on brightness
  ThemeData getCurrentTheme(BuildContext context) {
    return _currentBrightness.value == Brightness.dark
        ? AppTheme.darkTheme(context)
        : AppTheme.lightTheme(context);
  }

  // Change theme mode
  Future<void> changeThemeMode(
    ThemeMode newThemeMode, [
    BuildContext? context,
  ]) async {
    _themeMode.value = newThemeMode;
    _updateTheme(context);

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

    // Update GetX theme if context is available
    final buildContext = context ?? Get.context;
    if (buildContext != null) {
      final newTheme = getCurrentTheme(buildContext);
      Get.changeTheme(newTheme);
    }

    // Notify GetBuilder to rebuild UI
    update();
  }

  // Toggle between light and dark theme
  Future<void> toggleTheme([BuildContext? context]) async {
    if (_themeMode.value == ThemeMode.light) {
      await changeThemeMode(ThemeMode.dark, context);
    } else if (_themeMode.value == ThemeMode.dark) {
      await changeThemeMode(ThemeMode.light, context);
    } else {
      // If system mode, toggle to opposite of current system theme
      final buildContext = context ?? Get.context;
      if (buildContext != null) {
        final systemBrightness = MediaQuery.of(buildContext).platformBrightness;
        if (systemBrightness == Brightness.dark) {
          await changeThemeMode(ThemeMode.light, context);
        } else {
          await changeThemeMode(ThemeMode.dark, context);
        }
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
  void handleSystemThemeChange([BuildContext? context]) {
    if (_themeMode.value == ThemeMode.system) {
      _updateTheme(context);
      final buildContext = context ?? Get.context;
      if (buildContext != null) {
        Get.changeTheme(getCurrentTheme(buildContext));
      }
      // Notify GetBuilder to rebuild UI
      update();
    }
  }
}
