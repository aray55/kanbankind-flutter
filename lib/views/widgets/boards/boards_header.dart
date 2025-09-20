import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/controllers/board_controller.dart';
import 'package:kanbankit/core/localization/local_keys.dart';

import '../responsive_text.dart';

class BoardsHeader extends StatelessWidget {
  final BoardController controller;
  final bool isArchived;

  const BoardsHeader({
    super.key,
    required this.controller,
    this.isArchived = false,
  });

  @override
  Widget build(BuildContext context) {
    final totalBoards = isArchived
        ? controller.totalArchivedBoards
        : controller.searchQuery.isEmpty
            ? controller.totalBoards
            : controller.filteredBoards.length;

    final icon = isArchived ? Icons.archive : Icons.dashboard_outlined;

    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.secondary, size: 24),
        const SizedBox(width: 8),
        AppText(
          isArchived ? LocalKeys.archivedBoards.tr : LocalKeys.yourBoards.tr,
          variant: AppTextVariant.h2,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .primary
                .withValues(alpha: isArchived ? 0.1 : 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: AppText(
            totalBoards.toString(),
            variant: AppTextVariant.small,
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
