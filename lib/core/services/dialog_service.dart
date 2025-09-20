import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/localization/local_keys.dart';

import '../../views/widgets/responsive_text.dart';
import '../themes/app_colors.dart' show AppColors;

class DialogService {
  void showSnack({
    required String message,
    String title = 'Info',
    Color? backgroundColor,
    SnackPosition position = SnackPosition.BOTTOM,
    IconData icon = Icons.info_outline,
  }) {
    Get.closeAllSnackbars();
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: backgroundColor ?? AppColors.primary,
      colorText: AppColors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      icon: Icon(icon, color: AppColors.white),
      duration: const Duration(seconds: 3),
    );
  }

  Future<bool> confirm({
    required String title,
    required String message,
    String confirmText = 'OK',
    String cancelText = 'Cancel',
  }) async {
    final result = await Get.defaultDialog<bool>(
      title: title,
      middleText: message,
      textConfirm: confirmText,
      textCancel: cancelText,
      onConfirm: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
    );
    return result ?? false;
  }

  void showLoading({String message = 'Loading...'}) {
    if (Get.isDialogOpen == true) return;
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
                const SizedBox(width: 16),
                Text(message),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void showSuccessSnackbar({
    required String title,
    required String message,
    Color? backgroundColor,
    SnackPosition position = SnackPosition.BOTTOM,
    IconData icon = Icons.check_circle_outline,
  }) {
    Get.closeAllSnackbars();
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor ?? AppColors.primary,
      colorText: AppColors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      icon: Icon(icon, color: AppColors.white),
      duration: const Duration(seconds: 3),
    );
  }

  void showErrorSnackbar({
    required String title,
    required String message,
    Color? backgroundColor,
    SnackPosition position = SnackPosition.BOTTOM,
    IconData icon = Icons.error_outline,
  }) {
    Get.closeAllSnackbars();
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: backgroundColor ?? AppColors.primary,
      colorText: AppColors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      icon: Icon(icon, color: AppColors.white),
      duration: const Duration(seconds: 3),
    );
  }

  /// حوار تأكيد

  /// حوار إدخال نص (مثال: نسخ البورد)
  Future<String?> promptInput({
    required String title,
    String? initialValue,
    String label = '',
    String confirmText = 'OK',
    String cancelText = 'Cancel',
  }) async {
    final controller = TextEditingController(text: initialValue);
    final result = await Get.dialog<String>(
      AlertDialog(
        title: AppText(title, variant: AppTextVariant.h2),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: AppText(cancelText, variant: AppTextVariant.button),
          ),
          FilledButton(
            onPressed: () => Get.back(result: controller.text.trim()),
            child: AppText(confirmText, variant: AppTextVariant.button),
          ),
        ],
      ),
    );
    return result;
  }

  /// حوار بحث
  Future<String?> searchDialog({
    required String title,
    required String hint,
  }) async {
    final controller = TextEditingController();
    final result = await Get.dialog<String>(
      AlertDialog(
        title: AppText(title, variant: AppTextVariant.h2),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (value) => Get.back(result: value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: AppText(LocalKeys.cancel.tr, variant: AppTextVariant.button),
          ),
          FilledButton(
            onPressed: () => Get.back(result: controller.text.trim()),
            child: AppText(LocalKeys.searchBoards.tr, variant: AppTextVariant.button),
          ),
        ],
      ),
    );
    return result?.trim().isEmpty == true ? null : result?.trim();
  }

  void hideLoading() {
    if (Get.isDialogOpen == true) Get.back();
  }
}
