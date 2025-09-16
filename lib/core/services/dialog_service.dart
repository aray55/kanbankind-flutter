import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
      snackPosition: position,
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
      snackPosition: position,
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
      snackPosition: position,
      backgroundColor: backgroundColor ?? AppColors.primary,
      colorText: AppColors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      icon: Icon(icon, color: AppColors.white),
      duration: const Duration(seconds: 3),
    );
  }

  void hideLoading() {
    if (Get.isDialogOpen == true) Get.back();
  }
}