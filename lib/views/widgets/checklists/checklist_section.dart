import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/views/components/empty_state.dart';
import '../../../controllers/checklists_controller.dart';
import '../../../core/localization/local_keys.dart';
import '../../components/text_buttons/app_text_button.dart';
import '../../components/text_buttons/button_variant.dart';
import '../../components/text_buttons/button_size.dart';
import '../responsive_text.dart';
import 'checklist_widget.dart';
import 'add_edit_checklist_modal.dart';

class ChecklistSection extends StatelessWidget {
  final int cardId;
  final bool isEditable;
  final bool showArchivedButton;

  const ChecklistSection({
    Key? key,
    required this.cardId,
    this.isEditable = true,
    this.showArchivedButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChecklistsController());

    // Load checklists for this card
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.currentCardId != cardId) {
        controller.loadChecklistsByCardId(cardId);
      }
    });

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          _buildSectionHeader(context, controller),

          const SizedBox(height: 16),

          // Checklists List
          Obx(() {
            if (controller.isLoading) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final checklists = controller.checklists;

            if (checklists.isEmpty) {
              return _buildEmptyState(context);
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: checklists.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final checklist = checklists[index];
                return ChecklistWidget(
                  checklist: checklist,
                  isEditable: isEditable,
                );
              },
            );
          }),

          // Archived Checklists Button
          if (showArchivedButton)
            Obx(() {
              final archivedCount = controller.statistics['archived'] ?? 0;
              if (archivedCount > 0) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: AppTextButton(
                    label: '${LocalKeys.viewArchived.tr} ($archivedCount)',
                    variant: AppButtonVariant.secondary,
                    size: AppButtonSize.small,
                    leadingIcon: Icons.archive_outlined,
                    onPressed: () =>
                        _showArchivedChecklists(context, controller),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    ChecklistsController controller,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Title with count
        Expanded(
          child: Obx(() {
            final count = controller.totalChecklists;
            return AppText(
              count > 0
                  ? '${LocalKeys.checklists.tr} ($count)'
                  : LocalKeys.checklists.tr,
              variant: AppTextVariant.h2,
            );
          }),
        ),

        // Add Checklist Button
        if (isEditable)
          AppTextButton(
            label: LocalKeys.addChecklist.tr,
            variant: AppButtonVariant.primary,
            size: AppButtonSize.small,
            leadingIcon: Icons.add,
            onPressed: () => _showAddChecklistModal(context, controller),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return EmptyState(
      title: LocalKeys.noChecklistFound.tr,
      subtitle: LocalKeys.addChecklist.tr,
      icon: Icons.checklist_outlined,
    );
  }

  void _showAddChecklistModal(
    BuildContext context,
    ChecklistsController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AddEditChecklistModal(
        cardId: cardId,
        onSaved: () {
          // Refresh the checklists after adding
          controller.loadChecklistsByCardId(cardId);
        },
      ),
    );
  }

  void _showArchivedChecklists(
    BuildContext context,
    ChecklistsController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) =>
          _ArchivedChecklistsModal(cardId: cardId, controller: controller),
    );
  }
}

class _ArchivedChecklistsModal extends StatelessWidget {
  final int cardId;
  final ChecklistsController controller;

  const _ArchivedChecklistsModal({
    required this.cardId,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // Load archived checklists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadArchivedChecklists(cardId: cardId);
    });

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppText(
                    LocalKeys.archivedChecklists.tr,
                    variant: AppTextVariant.h2,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Archived Checklists List
              Obx(() {
                if (controller.isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final archivedChecklists = controller.archivedChecklists;

                if (archivedChecklists.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.archive_outlined,
                          size: 48,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 16),
                        AppText(
                          LocalKeys.noArchivedChecklists.tr,
                          variant: AppTextVariant.body,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: archivedChecklists
                      .map(
                        (checklist) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ChecklistWidget(
                            checklist: checklist,
                            isEditable: true,
                            showArchiveActions: true,
                          ),
                        ),
                      )
                      .toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
