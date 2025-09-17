import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/localization/local_keys.dart';
import 'package:kanbankit/core/services/user_pref_service.dart';

import 'responsive_text.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final userPrefService = Get.find<UserPrefService>();
    return AlertDialog(
      title: AppText(LocalKeys.chooseLanguage.tr),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const AppText('English', variant: AppTextVariant.body),
            onTap: () {
              Get.updateLocale(const Locale('en', 'US'));
              userPrefService.saveLocale('en_US');
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            title: const AppText('العربية', variant: AppTextVariant.body),
            onTap: () {
              Get.updateLocale(const Locale('ar', 'YE'));
              userPrefService.saveLocale('ar_YE');
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
