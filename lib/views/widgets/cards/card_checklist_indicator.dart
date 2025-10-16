import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/checklists_controller.dart';
import '../responsive_text.dart';

class CardChecklistIndicator extends StatelessWidget {
  final int cardId;
  final bool compact;

  const CardChecklistIndicator({
    Key? key,
    required this.cardId,
    this.compact = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChecklistsController>();

    // Always load checklists for this specific card to prevent data sharing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Force reload for this specific card
      controller.loadChecklistsByCardId(cardId);
    });

    return Obx(() {
      // Only show data if we're looking at the correct card
      if (controller.currentCardId != cardId) {
        return const SizedBox.shrink();
      }
      
      final totalChecklists = controller.totalChecklists;
      final statistics = controller.statistics;
      
      if (totalChecklists == 0) {
        return const SizedBox.shrink();
      }

      if (compact) {
        return _buildCompactIndicator(context, totalChecklists, statistics);
      } else {
        return _buildDetailedIndicator(context, totalChecklists, statistics);
      }
    });
  }

  Widget _buildCompactIndicator(
    BuildContext context,
    int totalChecklists,
    Map<String, int> statistics,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.checklist_outlined,
            size: 12,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 4),
          AppText(
            totalChecklists.toString(),
            variant: AppTextVariant.small,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedIndicator(
    BuildContext context,
    int totalChecklists,
    Map<String, int> statistics,
  ) {
    final activeCount = statistics['active'] ?? 0;
    final archivedCount = statistics['archived'] ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.checklist_outlined,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
              AppText(
                '$activeCount Checklists',
                variant: AppTextVariant.body,
              ),
            ],
          ),
          if (archivedCount > 0) ...[
            const SizedBox(height: 2),
            AppText(
              '$archivedCount archived',
              variant: AppTextVariant.small,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ],
        ],
      ),
    );
  }
}
