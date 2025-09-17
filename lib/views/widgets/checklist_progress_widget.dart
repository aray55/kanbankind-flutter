import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/localization/local_keys.dart';
import '../../models/check_list_progress_model.dart';
import '../../core/themes/app_colors.dart';
import 'responsive_text.dart';

class ChecklistProgressWidget extends StatelessWidget {
  final ChecklistProgress progress;
  final int totalItems;
  final int completedItems;
  final bool compact;
  final bool showPercentage;
  final bool showCounts;
  final Color? progressColor;
  final Color? backgroundColor;

  const ChecklistProgressWidget({
    Key? key,
    required this.progress,
    required this.totalItems,
    required this.completedItems,
    this.compact = false,
    this.showPercentage = true,
    this.showCounts = true,
    this.progressColor,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = totalItems > 0 ? (completedItems / totalItems) : 0.0;
    final isCompleted = totalItems > 0 && completedItems == totalItems;

    return Container(
      margin: EdgeInsets.symmetric(
        vertical: compact ? 4 : 8,
        horizontal: compact ? 4 : 8,
      ),
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(compact ? 8 : 12),
        border: Border.all(
          color: isCompleted
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with counts and percentage
          if (!compact || showCounts || showPercentage)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (showCounts)
                  Row(
                    children: [
                      Icon(
                        isCompleted ? Icons.check_circle : Icons.checklist,
                        size: compact ? 16 : 20,
                        color: isCompleted
                            ? AppColors.primary
                            : AppColors.infoDark,
                      ),
                      const SizedBox(width: 8),
                      AppText(
                        '$completedItems ${LocalKeys.of.tr} $totalItems ${LocalKeys.completed.tr}',
                        fontWeight: FontWeight.w500,
                        color: isCompleted
                              ? AppColors.primary
                              : AppColors.onSurface.withValues(alpha: 0.8),
                        ),
                      
                    ],
                  ),

                if (showPercentage)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: AppText(
                      '${(percentage * 100).round()}%',
                      fontWeight: FontWeight.bold,
                      color: isCompleted
                            ? AppColors.white
                            : AppColors.primary,
                      ),
                    ),
                  
              ],
            ),

          if (!compact || showCounts || showPercentage)
            SizedBox(height: compact ? 8 : 12),

          // Progress bar
          Container(
            height: compact ? 6 : 8,
            decoration: BoxDecoration(
              color: backgroundColor ?? AppColors.outline.withOpacity(0.2),
              borderRadius: BorderRadius.circular(compact ? 3 : 4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(compact ? 3 : 4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                width: MediaQuery.of(context).size.width * percentage,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isCompleted
                        ? [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.8),
                          ]
                        : [
                            progressColor ?? AppColors.primary,
                            (progressColor ?? AppColors.primary).withValues(
                              alpha: 0.7,
                            ),
                          ],
                  ),
                ),
              ),
            ),
          ),

          // Completion message
          if (isCompleted && !compact)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(Icons.celebration, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  AppText(
                    LocalKeys.allItemsCompleted.tr,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// Circular progress variant
class CircularChecklistProgressWidget extends StatelessWidget {
  final ChecklistProgress progress;
  final int totalItems;
  final int completedItems;
  final double size;
  final double strokeWidth;
  final bool showPercentage;
  final Color? progressColor;
  final Color? backgroundColor;

  const CircularChecklistProgressWidget({
    Key? key,
    required this.progress,
    required this.totalItems,
    required this.completedItems,
    this.size = 60,
    this.strokeWidth = 6,
    this.showPercentage = true,
    this.progressColor,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = totalItems > 0 ? (completedItems / totalItems) : 0.0;
    final isCompleted = totalItems > 0 && completedItems == totalItems;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              valueColor: AlwaysStoppedAnimation<Color>(
                backgroundColor ?? AppColors.outline.withOpacity(0.2),
              ),
            ),
          ),

          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: AnimatedBuilder(
              animation: Tween<double>(begin: 0, end: percentage).animate(
                CurvedAnimation(
                  parent: AnimationController(
                    duration: const Duration(milliseconds: 1000),
                    vsync: Navigator.of(context),
                  )..forward(),
                  curve: Curves.easeInOut,
                ),
              ),
              builder: (context, child) {
                return CircularProgressIndicator(
                  value: percentage,
                  strokeWidth: strokeWidth,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progressColor ?? AppColors.primary,
                  ),
                );
              },
            ),
          ),

          // Center content
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isCompleted)
                Icon(Icons.check, color: AppColors.primary, size: size * 0.3)
              else if (showPercentage)
                Text(
                  '${(percentage * 100).round()}%',
                  style: TextStyle(
                    fontSize: size * 0.2,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),

              if (!isCompleted)
                Text(
                  '$completedItems/$totalItems',
                  style: TextStyle(
                    fontSize: size * 0.12,
                    color: AppColors.onSurface.withOpacity(0.6),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// Mini progress indicator for list items
class MiniChecklistProgressWidget extends StatelessWidget {
  final int totalItems;
  final int completedItems;
  final double width;
  final double height;

  const MiniChecklistProgressWidget({
    Key? key,
    required this.totalItems,
    required this.completedItems,
    this.width = 40,
    this.height = 4,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = totalItems > 0 ? (completedItems / totalItems) : 0.0;
    final isCompleted = totalItems > 0 && completedItems == totalItems;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.outline.withOpacity(0.2),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(height / 2),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: width * percentage,
          decoration: BoxDecoration(
            color: isCompleted
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}
