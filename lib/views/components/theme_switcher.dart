import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/controllers/theme_controller.dart';
import 'package:kanbankit/controllers/theme_controller.dart'
    as theme_controller;
import 'package:kanbankit/core/localization/local_keys.dart';
import 'package:kanbankit/views/components/icon_buttons/app_icon_button.dart';

import '../../core/themes/app_colors.dart';
import 'icon_buttons/icon_button_style.dart';
import 'icon_buttons/icon_button_variant.dart';

class ThemeSwitcher extends StatelessWidget {
  final bool showLabel;
  final bool isCompact;

  const ThemeSwitcher({Key? key, this.showLabel = true, this.isCompact = false})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeController>(
      builder: (controller) {
        if (isCompact) {
          return _buildCompactSwitcher(controller);
        }
        return _buildFullSwitcher(controller);
      },
    );
  }

  Widget _buildCompactSwitcher(ThemeController controller) {
    return AppIconButton(
      style: AppIconButtonStyle.plain,
      variant: AppIconButtonVariant.values.first,
      onPressed: () => controller.toggleTheme(),
      child: Obx(
        () => Icon(controller.isDarkMode ? Icons.light_mode : Icons.dark_mode),
      ),
    );
  }

  Widget _buildFullSwitcher(ThemeController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showLabel) ...[
              Row(
                children: [
                  Icon(
                    Icons.palette_outlined,
                    color: Get.theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    LocalKeys.theme.tr,
                    style: Get.theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            _buildThemeOptions(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOptions(ThemeController controller) {
    return Obx(
      () => Column(
        children: [
          _buildThemeOption(
            controller,
            theme_controller.ThemeMode.light,
            Icons.light_mode,
            LocalKeys.lightTheme.tr,
            LocalKeys.alwaysUseLightTheme.tr,
          ),
          const SizedBox(height: 8),
          _buildThemeOption(
            controller,
            theme_controller.ThemeMode.dark,
            Icons.dark_mode,
            LocalKeys.darkTheme.tr,
            LocalKeys.alwaysUseDarkTheme.tr,
          ),
          const SizedBox(height: 8),
          _buildThemeOption(
            controller,
            theme_controller.ThemeMode.system,
            Icons.settings_brightness,
            LocalKeys.systemTheme.tr,
            LocalKeys.followSystemTheme.tr,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    ThemeController controller,
    theme_controller.ThemeMode mode,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final isSelected = controller.themeMode == mode;

    return InkWell(
      onTap: () => controller.changeThemeMode(mode),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isSelected
              ? Get.theme.colorScheme.primary.withOpacity(0.1)
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
                  Text(
                    title,
                    style: Get.theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: isSelected
                          ? Get.theme.colorScheme.primary
                          : Get.theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Get.theme.textTheme.bodySmall?.copyWith(
                      color: Get.theme.colorScheme.onSurfaceVariant,
                    ),
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
}

class ThemeSwitcherDialog extends StatelessWidget {
  const ThemeSwitcherDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  Icons.palette_outlined,
                  color: Get.theme.colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  LocalKeys.chooseTheme.tr,
                  style: Get.theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const ThemeSwitcher(showLabel: false),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(onPressed: () => Get.back(), child: Text('Done'.tr)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static void show() {
    Get.dialog(const ThemeSwitcherDialog());
  }
}

class ThemeSwitcherBottomSheet extends StatelessWidget {
  const ThemeSwitcherBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(
                Icons.palette_outlined,
                color: Get.theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                LocalKeys.chooseTheme.tr,
                style: Get.theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const ThemeSwitcher(showLabel: false),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  static void show() {
    Get.bottomSheet(const ThemeSwitcherBottomSheet(), isScrollControlled: true);
  }
}
