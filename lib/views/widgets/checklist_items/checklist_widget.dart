import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/views/components/icon_buttons/icon_button_style.dart';
import '../../../core/localization/local_keys.dart';
import '../../../models/checklist_model.dart';
import '../../../models/checklist_item_model.dart';
import '../../../controllers/checklist_item_controller.dart';
import '../../components/icon_buttons/app_icon_button.dart';
import '../responsive_text.dart';
import 'checklist_item_widget.dart';
import 'checklist_options_modal.dart';

class ChecklistWidget extends StatefulWidget {
  final ChecklistModel checklist;
  final List<ChecklistItemModel> items;
  final VoidCallback? onRefresh;

  const ChecklistWidget({
    Key? key,
    required this.checklist,
    required this.items,
    this.onRefresh,
  }) : super(key: key);

  @override
  State<ChecklistWidget> createState() => _ChecklistWidgetState();
}

class _ChecklistWidgetState extends State<ChecklistWidget> {
  late final TextEditingController _addItemController;
  late final FocusNode _addItemFocusNode;
  bool _isAddingItem = false;

  @override
  void initState() {
    super.initState();
    _addItemController = TextEditingController();
    _addItemFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _addItemController.dispose();
    _addItemFocusNode.dispose();
    super.dispose();
  }

  double get _completionProgress {
    if (widget.items.isEmpty) return 0.0;
    final completedCount = widget.items.where((item) => item.isDone).length;
    return completedCount / widget.items.length;
  }

  int get _completedCount => widget.items.where((item) => item.isDone).length;
  int get _totalCount => widget.items.length;

  void _showAddItemField() {
    setState(() => _isAddingItem = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addItemFocusNode.requestFocus();
    });
  }

  void _hideAddItemField() {
    setState(() => _isAddingItem = false);
    _addItemController.clear();
  }

  Future<void> _addItem() async {
    final title = _addItemController.text.trim();
    if (title.isEmpty) return;

    try {
      final controller = Get.put(ChecklistItemController(), permanent: false);
      await controller.createChecklistItem(
        checklistId: widget.checklist.id!,
        title: title,
      );
      
      _addItemController.clear();
      widget.onRefresh?.call();
    } catch (e) {
      // Error handling is done in the controller
    }
  }

  void _showChecklistOptions() {
    ChecklistOptionsModal.show(context, checklist: widget.checklist);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),

          // Progress bar
          if (widget.items.isNotEmpty) _buildProgressBar(),

          // Items list
          _buildItemsList(),

          // Add item field
          _buildAddItemSection(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  widget.checklist.title,
                  variant: AppTextVariant.h2,
                  fontWeight: FontWeight.w600,
                ),
                if (widget.items.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  AppText(
                    '${_completedCount} ${LocalKeys.of_.tr} ${_totalCount} ${LocalKeys.completed.tr}',
                    variant: AppTextVariant.small,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ],
              ],
            ),
          ),
          AppIconButton(
            style: AppIconButtonStyle.plain,
            onPressed: _showChecklistOptions,
            child: Icon(
              Icons.more_vert,
              size: 20,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                LocalKeys.progress.tr,
                variant: AppTextVariant.small,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              AppText(
                '${(_completionProgress * 100).toInt()}%',
                variant: AppTextVariant.small,
                fontWeight: FontWeight.w500,
                color: colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _completionProgress,
            backgroundColor: colorScheme.primary.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            borderRadius: BorderRadius.circular(4),
            minHeight: 6,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildItemsList() {
    if (widget.items.isEmpty && !_isAddingItem) {
      return _buildEmptyState();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ReorderableListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.items.length,
        onReorder: _onReorder,
        itemBuilder: (context, index) {
          final item = widget.items[index];
          return ChecklistItemWidget(
            key: ValueKey(item.id),
            item: item,
            onToggle: () => _toggleItem(item),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.checklist,
              size: 48,
              color: colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            AppText(
              LocalKeys.noChecklistItems.tr,
              variant: AppTextVariant.body,
              color: colorScheme.onSurface.withOpacity(0.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            AppText(
              LocalKeys.addFirstChecklistItem.tr,
              variant: AppTextVariant.small,
              color: colorScheme.onSurface.withOpacity(0.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddItemSection() {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withOpacity(0.1),
          ),
        ),
      ),
      child: _isAddingItem ? _buildAddItemField() : _buildAddItemButton(),
    );
  }

  Widget _buildAddItemButton() {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: _showAddItemField,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.3),
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.add,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 12),
              AppText(
                LocalKeys.addItem.tr,
                variant: AppTextVariant.body,
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddItemField() {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _addItemController,
            focusNode: _addItemFocusNode,
            decoration: InputDecoration(
              hintText: LocalKeys.enterItemTitle.tr,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: colorScheme.outline.withOpacity(0.3),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: colorScheme.outline.withOpacity(0.3),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: colorScheme.primary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            onSubmitted: (_) => _addItem(),
            maxLength: 255,
            buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
          ),
        ),
        const SizedBox(width: 8),
        AppIconButton(
          style: AppIconButtonStyle.filled,
          onPressed: _addItem,
          child: const Icon(Icons.check, size: 18),
        ),
        const SizedBox(width: 4),
        AppIconButton(
          style: AppIconButtonStyle.plain,
          onPressed: _hideAddItemField,
          child: Icon(
            Icons.close,
            size: 18,
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  void _toggleItem(ChecklistItemModel item) {
    final controller = Get.put(ChecklistItemController(), permanent: false);
    controller.toggleItemDone(item.id!);
    widget.onRefresh?.call();
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final items = List<ChecklistItemModel>.from(widget.items);
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    // Update positions
    final reorderedItems = items.asMap().entries.map((entry) {
      return entry.value.copyWith(position: (entry.key + 1) * 1024.0);
    }).toList();

    final controller = Get.put(ChecklistItemController(), permanent: false);
    controller.reorderItems(reorderedItems);
    widget.onRefresh?.call();
  }
}
