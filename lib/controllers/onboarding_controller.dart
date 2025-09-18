import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_swipe/liquid_swipe.dart';
import '../core/themes/app_colors.dart';
import '../core/services/user_pref_service.dart';
import '../core/routes/app_routes.dart';
import '../views/onboarding/onboarding_screen.dart';
import '../core/localization/local_keys.dart';

class OnboardingController extends GetxController {
  final liquidController = LiquidController();
  final RxInt currentPage = 0.obs;
  final UserPrefService _userPrefService = Get.find<UserPrefService>();

  late List<Widget> pages;

  @override
  void onInit() {
    super.onInit();
    _initializePages();
  }

  void _initializePages() {
    pages = [
      OnboardingPage(
        title: LocalKeys.welcomeToKanbanKit.tr,
        subtitle: LocalKeys.organizeTasksEffectively.tr,
        description: LocalKeys.kanbanKitHelpsYouManageTasks.tr,
        icon: Icons.dashboard_rounded,
        backgroundColor: AppColors.primary,
        gradientColor: AppColors.primaryDark,
      ),
      OnboardingPage(
        title: LocalKeys.createAndManageTasks.tr,
        subtitle: LocalKeys.stayOrganized.tr,
        description: LocalKeys.createTasksWithDetails.tr,
        icon: Icons.task_alt_rounded,
        backgroundColor: AppColors.secondary,
        gradientColor: AppColors.secondaryDark,
      ),
      OnboardingPage(
        title: LocalKeys.trackProgress.tr,
        subtitle: LocalKeys.visualizeWorkflow.tr,
        description: LocalKeys.moveTasksBetweenColumns.tr,
        icon: Icons.trending_up_rounded,
        backgroundColor: AppColors.tertiary,
        gradientColor: AppColors.tertiaryDark,
      ),
      OnboardingPage(
        title: LocalKeys.checklistFeature.tr,
        subtitle: LocalKeys.breakDownComplexTasks.tr,
        description: LocalKeys.addChecklistItemsToTasks.tr,
        icon: Icons.checklist_rtl_rounded,
        backgroundColor: AppColors.success,
        gradientColor: AppColors.successDark,
      ),
      OnboardingPage(
        title: LocalKeys.getStarted.tr,
        subtitle: LocalKeys.readyToBeginJourney.tr,
        description: LocalKeys.startUsingKanbanKitToday.tr,
        icon: Icons.rocket_launch_rounded,
        backgroundColor: AppColors.info,
        gradientColor: AppColors.infoDark,
      ),
    ];
  }

  void onPageChangeCallback(int activePageIndex) {
    currentPage.value = activePageIndex;
  }

  void nextPage() {
    if (currentPage.value < pages.length - 1) {
      liquidController.animateToPage(page: currentPage.value + 1);
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      liquidController.animateToPage(page: currentPage.value - 1);
    }
  }

  void skipToEnd() {
    liquidController.animateToPage(page: pages.length - 1);
  }

  void completeOnboarding() {
    // Mark onboarding as completed
    _userPrefService.setOnboardingCompleted(true);

    // Navigate to main app
    Get.offAllNamed(AppRoutes.board);
  }

  @override
  void onClose() {
    // LiquidController doesn't need manual disposal in newer versions
    super.onClose();
  }
}
