import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/activity_log_controller.dart';
import '../../../models/activity_log_model.dart';
import '../../../core/localization/local_keys.dart';
import '../../components/empty_state.dart';
import 'activity_item_widget.dart';

/// Activity Timeline Widget
/// Displays activity logs grouped by date with timeline UI
class ActivityTimelineWidget extends StatelessWidget {
  final int? cardId;
  final EntityType? entityType;
  final int? entityId;
  final bool showHeader;
  final int? limit;

  const ActivityTimelineWidget({
    Key? key,
    this.cardId,
    this.entityType,
    this.entityId,
    this.showHeader = true,
    this.limit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activityLogController = Get.find<ActivityLogController>();
    final theme = Theme.of(context);

    // Load activities
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (cardId != null) {
        activityLogController.loadCardActivityLogs(cardId!, showLoading: false);
      } else if (entityType != null && entityId != null) {
        activityLogController.loadActivityLogsForEntity(
          entityType: entityType!,
          entityId: entityId!,
          showLoading: false,
        );
      } else {
        activityLogController.loadRecentActivityLogs(
          limit: limit ?? 50,
          showLoading: false,
        );
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        if (showHeader) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.history,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  LocalKeys.activityLog.tr,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
        ],

        // Timeline
        Obx(() {
          if (activityLogController.isLoading) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final timeline = activityLogController.activityTimeline;

          if (timeline.isEmpty) {
            return EmptyState(
              icon: Icons.history,
              title: LocalKeys.noActivity.tr,
              subtitle: LocalKeys.recentActivity.tr,
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: timeline.length,
            itemBuilder: (context, index) {
              final dateKey = timeline.keys.elementAt(index);
              final activities = timeline[dateKey]!;

              return _buildTimelineSection(
                context,
                dateKey,
                activities,
                theme,
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildTimelineSection(
    BuildContext context,
    String dateKey,
    List<ActivityLogModel> activities,
    ThemeData theme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header
        Padding(
          padding: const EdgeInsets.only(bottom: 12, top: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _getDateLabel(dateKey),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 1,
                  color: theme.dividerColor.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
        ),

        // Activities for this date
        ...activities.map((activity) => Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ActivityItemWidget(
                key: ValueKey('activity_item_${activity.id}'),
                activity: activity,
              ),
            )),
      ],
    );
  }

  String _getDateLabel(String dateKey) {
    switch (dateKey) {
      case 'Today':
        return LocalKeys.today.tr;
      case 'Yesterday':
        return LocalKeys.yesterday.tr;
      default:
        return dateKey;
    }
  }
}
