import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/localization/local_keys.dart';
import '../responsive_text.dart';

class ListsHeader extends StatelessWidget {
  final String boardTitle;
  final int totalLists;
  final int? totalArchivedLists;
  final bool isArchived;
  final String? searchQuery;
  final VoidCallback? onClearSearch;

  const ListsHeader({
    super.key,
    required this.boardTitle,
    required this.totalLists,
    this.totalArchivedLists,
    this.isArchived = false,
    this.searchQuery,
    this.onClearSearch,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasSearchQuery = searchQuery != null && searchQuery!.isNotEmpty;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Board title and lists count
          Row(
            children: [
              Icon(
                isArchived ? Icons.archive : Icons.view_column,
                color: colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      boardTitle,
                      variant: AppTextVariant.h2,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      isArchived 
                          ? LocalKeys.archivedBoards.tr
                          : _getListsCountText(),
                      variant: AppTextVariant.body2,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
              // Lists count badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isArchived 
                      ? colorScheme.secondary.withValues(alpha: 0.1)
                      : colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isArchived 
                        ? colorScheme.secondary.withValues(alpha: 0.2)
                        : colorScheme.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: AppText(
                  totalLists.toString(),
                  variant: AppTextVariant.body2,
                  color: isArchived ? colorScheme.secondary : colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          // Search results info (if searching)
          if (hasSearchQuery) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppText(
                      '${LocalKeys.searchResults.tr}: "$searchQuery"',
                      variant: AppTextVariant.body2,
                      color: colorScheme.primary,
                    ),
                  ),
                  if (onClearSearch != null)
                    GestureDetector(
                      onTap: onClearSearch,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.close,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          
          // Archive summary (if showing archived lists)
          if (isArchived && totalArchivedLists != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 8),
                AppText(
                  totalArchivedLists == 0
                      ? 'No archived lists'
                      : totalArchivedLists == 1
                          ? '1 archived list'
                          : '$totalArchivedLists archived lists',
                  variant: AppTextVariant.body2,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _getListsCountText() {
    if (totalLists == 0) {
      return 'No lists yet';
    } else if (totalLists == 1) {
      return '1 list';
    } else {
      return '$totalLists lists';
    }
  }
}
