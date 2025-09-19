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
      title: AppText(
        LocalKeys.chooseLanguage.tr,
        variant: AppTextVariant.h2,
        fontWeight: FontWeight.w600,
      ),
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

class LanguageSwitcherBottomSheet extends StatelessWidget {
  const LanguageSwitcherBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final userPrefService = Get.find<UserPrefService>();
    final currentLocale = Get.locale ?? const Locale('en', 'US');

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: Get.theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.onSurfaceVariant.withValues(
                alpha: 0.4,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(
                Icons.language,
                color: Get.theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              AppText(
                LocalKeys.chooseLanguage.tr,
                variant: AppTextVariant.h2,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: Get.theme.colorScheme.outline.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                _buildLanguageOption(
                  context: context,
                  locale: const Locale('en', 'US'),
                  title: 'English',
                  icon: Icons.abc,
                  currentLocale: currentLocale,
                  userPrefService: userPrefService,
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Get.theme.colorScheme.outline.withOpacity(0.1),
                ),
                _buildLanguageOption(
                  context: context,
                  locale: const Locale('ar', 'YE'),
                  title: 'العربية',
                  icon: Icons.translate,
                  currentLocale: currentLocale,
                  userPrefService: userPrefService,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required Locale locale,
    required String title,
    required IconData icon,
    required Locale currentLocale,
    required UserPrefService userPrefService,
  }) {
    final isSelected =
        currentLocale.languageCode == locale.languageCode &&
        currentLocale.countryCode == locale.countryCode;

    return InkWell(
      onTap: () {
        Get.updateLocale(locale);
        String localeString = '${locale.languageCode}_${locale.countryCode}';
        userPrefService.saveLocale(localeString);
        Get.back();
      },
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? Get.theme.colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
          border: isSelected
              ? Border.all(color: Get.theme.colorScheme.primary)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Get.theme.colorScheme.primary
                  : Get.theme.colorScheme.onSurface,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    title,
                    variant: AppTextVariant.body,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                    color: isSelected
                        ? Get.theme.colorScheme.primary
                        : Get.theme.colorScheme.onSurface,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Get.theme.colorScheme.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  static void show() {
    Get.bottomSheet(
      const LanguageSwitcherBottomSheet(),
      isScrollControlled: true,
    );
  }
}
