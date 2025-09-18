import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/localization/app_translations.dart';
import 'package:kanbankit/core/services/user_pref_service.dart';
import 'package:kanbankit/core/themes/app_theme.dart';
import 'package:kanbankit/controllers/theme_controller.dart' as theme_ctrl;
import 'core/localization/local_keys.dart' show LocalKeys;
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'views/board/board_page.dart';
import 'views/splash/splash_screen.dart';
import 'bindings/board_binding.dart';

class KanbanKitApp extends StatefulWidget {
  const KanbanKitApp({super.key});

  @override
  State<KanbanKitApp> createState() => _KanbanKitAppState();
}

class _KanbanKitAppState extends State<KanbanKitApp> {
  bool _showSplash = true;

  void _hideSplash() {
    setState(() {
      _showSplash = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get saved locale if any
    final userPrefService = Get.find<UserPrefService>();
    String? savedLocale = userPrefService.getSavedLocale();
    Locale? initialLocale;
    if (savedLocale != null) {
      initialLocale = Locale(savedLocale);
    }

    return GetBuilder<theme_ctrl.ThemeController>(
      builder: (themeController) {
        return GetMaterialApp(
          title: LocalKeys.appName.tr,
          theme: AppTheme.lightTheme(context),
          darkTheme: AppTheme.darkTheme(context),
          themeMode: _getFlutterThemeMode(themeController.themeMode),
          home: _showSplash
              ? SplashScreen(onComplete: _hideSplash)
              : const BoardPage(),
          initialRoute: _showSplash ? '/' : AppRoutes.board,
          getPages: AppPages.pages,
          initialBinding: BoardBinding(),
          debugShowCheckedModeBanner: false,
          translations: AppTranslations(),
          locale: initialLocale ?? Get.deviceLocale,
          fallbackLocale: const Locale('en', 'US'),
        );
      },
    );
  }

  ThemeMode _getFlutterThemeMode(theme_ctrl.ThemeMode themeMode) {
    switch (themeMode) {
      case theme_ctrl.ThemeMode.light:
        return ThemeMode.light;
      case theme_ctrl.ThemeMode.dark:
        return ThemeMode.dark;
      case theme_ctrl.ThemeMode.system:
        return ThemeMode.system;
    }
  }
}
