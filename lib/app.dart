import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/localization/app_translations.dart';
import 'core/localization/local_keys.dart' show LocalKeys;
import 'views/board/board_page.dart';
import 'bindings/board_binding.dart';

class KanbanKitApp extends StatelessWidget {
  const KanbanKitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: LocalKeys.appName.tr,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const BoardPage(),
      initialBinding: BoardBinding(),
      debugShowCheckedModeBanner: false,
      translations: AppTranslations(),
      locale: Get.deviceLocale,
      
      fallbackLocale: const Locale('en', 'US'),
    );
  }
}
