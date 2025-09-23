import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/localization/local_keys.dart';
import '../../../controllers/checklist_item_controller.dart';
import '../../../controllers/checklists_controller.dart';

import '../responsive_text.dart';
import 'checklist_widget.dart';

enum ChecklistViewMode { active, archived }

class ChecklistSection extends StatefulWidget {
  final int cardId;
  final VoidCallback? onRefresh;

  const ChecklistSection({Key? key, required this.cardId, this.onRefresh})
    : super(key: key);

  @override
  State<ChecklistSection> createState() => _ChecklistSectionState();
}

class _ChecklistSectionState extends State<ChecklistSection> {
  late final ChecklistsController _checklistsController;
  late final ChecklistItemController _itemsController;
  ChecklistViewMode _viewMode = ChecklistViewMode.active;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with fallback creation if not found
    _checklistsController = Get.put(ChecklistsController(), permanent: false);
    _itemsController = Get.put(ChecklistItemController(), permanent: false);
    _loadData();
  }

  Future<void> _loadData() async {
    if (_viewMode == ChecklistViewMode.active) {
      await _checklistsController.loadChecklistsByCardId(widget.cardId);
      // Load items for each active checklist
      for (final checklist in _checklistsController.checklists) {
        await _itemsController.loadChecklistItemsByChecklistId(checklist.id!);
      }
    } else {
      await _checklistsController.loadArchivedChecklists(cardId: widget.cardId);
      // Load items for each archived checklist
      for (final checklist in _checklistsController.archivedChecklists) {
        await _itemsController.loadChecklistItemsByChecklistId(checklist.id!);
      }
    }
  }

  Future<void> _refresh() async {
    await _loadData();
    widget.onRefresh?.call();
  }

  void _switchViewMode(ChecklistViewMode newMode) {
    if (_viewMode != newMode) {
      setState(() {
        _viewMode = newMode;
      });
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChecklistsController>(
      builder: (checklistsController) {
        return GetBuilder<ChecklistItemController>(
          builder: (itemsController) {
            final checklists = _viewMode == ChecklistViewMode.active 
                ? checklistsController.checklists
                : checklistsController.archivedChecklists;

            if (checklists.isEmpty) {
              return _buildEmptyState();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section header (fixed at top)
                _buildSectionHeader(checklists.length),

                // Scrollable checklists content
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Checklists
                        ...checklists.map((checklist) {
                          final items = itemsController.checklistItems
                              .where((item) => item.checklistId == checklist.id)
                              .toList();

                          return ChecklistWidget(
                            key: ValueKey(checklist.id),
                            checklist: checklist,
                            items: items,
                            onRefresh: _refresh,
                          );
                        }).toList(),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildSectionHeader(int checklistCount) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          // Title and Add button row
          Row(
            children: [
              Icon(Icons.checklist, size: 24, color: colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      LocalKeys.checklists.tr,
                      variant: AppTextVariant.h2,
                      fontWeight: FontWeight.w600,
                    ),
                    AppText(
                      '$checklistCount ${checklistCount == 1 ? LocalKeys.checklist.tr : LocalKeys.checklists.tr}',
                      variant: AppTextVariant.small,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ],
                ),
              ),
              if (_viewMode == ChecklistViewMode.active)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: _showAddChecklistDialog,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add, size: 16),
                      const SizedBox(width: 4),
                      Flexible(
                        child: AppText(
                          LocalKeys.addChecklist.tr,
                          variant: AppTextVariant.small,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // View mode toggle
          _buildViewModeToggle(),
        ],
      ),
    );
  }

  Widget _buildViewModeToggle() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
            mode: ChecklistViewMode.active,
            icon: Icons.checklist,
            label: LocalKeys.checklists.tr,
          ),
          _buildToggleButton(
            mode: ChecklistViewMode.archived,
            icon: Icons.archive,
            label: LocalKeys.archived.tr,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required ChecklistViewMode mode,
    required IconData icon,
    required String label,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final isSelected = _viewMode == mode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(6),
        onTap: () => _switchViewMode(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected 
                    ? colorScheme.onPrimary 
                    : colorScheme.onSurface.withOpacity(0.6),
              ),
              const SizedBox(width: 6),
              AppText(
                label,
                variant: AppTextVariant.small,
                color: isSelected 
                    ? colorScheme.onPrimary 
                    : colorScheme.onSurface.withOpacity(0.8),
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    final isArchived = _viewMode == ChecklistViewMode.archived;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(
              isArchived ? Icons.archive : Icons.checklist,
              size: 64,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            AppText(
              isArchived ? LocalKeys.noArchivedChecklists.tr : LocalKeys.noChecklists.tr,
              variant: AppTextVariant.h2,
              fontWeight: FontWeight.w500,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            AppText(
              isArchived 
                  ? 'Archived checklists will appear here when you archive them'
                  : LocalKeys.noChecklistsDescription.tr,
              variant: AppTextVariant.body,
              color: colorScheme.onSurface.withOpacity(0.6),
              textAlign: TextAlign.center,
            ),
            if (!isArchived) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: _showAddChecklistDialog,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add, size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: AppText(
                        LocalKeys.createFirstChecklist.tr,
                        variant: AppTextVariant.button,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddChecklistDialog() {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: AppText(LocalKeys.addChecklist.tr, variant: AppTextVariant.h2),
        content: TextField(
          controller: titleController,
          decoration: InputDecoration(
            labelText: LocalKeys.checklistTitle.tr,
            hintText: LocalKeys.enterChecklistTitle.tr,
            border: const OutlineInputBorder(),
          ),
          maxLength: 255,
          autofocus: true,
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: AppText(LocalKeys.cancel.tr, variant: AppTextVariant.button),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: () async {
              final title = titleController.text.trim();
              if (title.isNotEmpty) {
                Navigator.of(context).pop();
                await _checklistsController.createChecklist(
                  cardId: widget.cardId,
                  title: title,
                );
                _refresh();
              }
            },
            child: AppText(LocalKeys.create.tr, variant: AppTextVariant.button),
          ),
        ],
      ),
    );
  }
}
