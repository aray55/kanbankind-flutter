import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:confetti/confetti.dart';
import 'package:kanbankit/views/widgets/responsive_text.dart';
import '../../controllers/task_editor_controller.dart';
import '../../controllers/checklist_controller.dart';
import '../../core/localization/local_keys.dart';
import '../../core/themes/app_colors.dart';
import 'checklist_widget.dart';

class ChecklistTab extends StatefulWidget {
  final TaskEditorController? controller;

  const ChecklistTab({super.key, this.controller});

  @override
  State<ChecklistTab> createState() => _ChecklistTabState();
}

class _ChecklistTabState extends State<ChecklistTab> {
  late ConfettiController _confettiController;
  bool _hasTriggeredCelebration = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }


  void _triggerCelebration() {
    _hasTriggeredCelebration = true;
    _confettiController.play();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller ?? Get.find<TaskEditorController>();
    final isNewTask = controller.editingTask?.id == null;

    return Stack(
      
      children: [
        // Main content
        if (isNewTask)
          _buildNewTaskChecklist(controller)
        else
          _buildExistingTaskChecklist(controller),

        // Confetti overlay
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: 1.5708, // radians - 90 degrees (down)
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
              Colors.red,
              Colors.yellow,
            ],
            numberOfParticles: 50,
            minBlastForce: 5,
            maxBlastForce: 20,
            gravity: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildNewTaskChecklist(TaskEditorController controller) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.checklist_rtl, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        LocalKeys.taskChecklist.tr,
                        variant: AppTextVariant.h2,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                      AppText(
                        LocalKeys.addChecklistItemsForNewTask.tr,
                        variant: AppTextVariant.body,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary.withValues(alpha: 0.7),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Add checklist item input
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Obx(
              () => Column(
                children: [
                  TextField(
                    controller: controller.checklistItemController,
                    decoration: InputDecoration(
                      
                      hintText: LocalKeys.addChecklistItemHint.tr,
                      
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.add, color: AppColors.primary),
                      suffixIcon: IconButton(
                        onPressed: () {
                          final text = controller.checklistItemController.text
                              .trim();
                          if (text.isNotEmpty) {
                            controller.addTempChecklistItem(text);
                            controller.checklistItemController.clear();
                          }
                        },
                        icon: Icon(Icons.send, color: AppColors.primary),
                      ),
                    ),
                    onSubmitted: (value) {
                      final text = value.trim();
                      if (text.isNotEmpty) {
                        controller.addTempChecklistItem(text);
                        controller.checklistItemController.clear();
                      }
                    },
                  ),
                  if (controller.tempChecklistItems.isNotEmpty) ...[
                    const Divider(),
                    AppText(
                      '${LocalKeys.itemsToAdd.tr} (${controller.tempChecklistItems.length}):',
                      variant: AppTextVariant.body,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Temporary checklist items
          Expanded(
            child: Obx(() {
              if (controller.tempChecklistItems.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.checklist_outlined,
                        size: 48,
                        color: AppColors.onSurface.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      AppText(
                        LocalKeys.noChecklistItems.tr,
                        variant: AppTextVariant.body,
                        fontWeight: FontWeight.w500,
                      ),
                      const SizedBox(height: 8),
                      AppText(
                        LocalKeys.addItemsAboveToCreateChecklist,
                        variant: AppTextVariant.body,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: controller.tempChecklistItems.length,
                itemBuilder: (context, index) {
                  final item = controller.tempChecklistItems[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.radio_button_unchecked,
                          size: 20,
                          color: AppColors.outline,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        IconButton(
                          onPressed: () =>
                              controller.removeTempChecklistItem(index),
                          icon: Icon(
                            Icons.close,
                            size: 16,
                            color: AppColors.error.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingTaskChecklist(TaskEditorController taskController) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // Use the old ChecklistWidget approach
          GetBuilder<ChecklistController>(
            init: ChecklistController(),
            builder: (checklistController) {
              // Load checklist items if not already loaded
              if (checklistController.currentTaskId !=
                  taskController.editingTask!.id!) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  checklistController.loadChecklistItems(
                    taskController.editingTask!.id!,
                  );
                });
              }

              return Column(
                children: [
                  // Reactive completion checker - wrapped in Obx
                  Obx(() {
                    // Check for completion reactively
                    if (checklistController.isAllCompleted &&
                        !_hasTriggeredCelebration) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _triggerCelebration();
                      });
                    } else if (!checklistController.isAllCompleted) {
                      _hasTriggeredCelebration = false;
                    }
                    return const SizedBox.shrink(); // Empty widget
                  }),

                  // Actual ChecklistWidget
                  ChecklistWidget(
                    taskId: taskController.editingTask!.id!,
                    showProgress: true,
                    showActions: true,
                    isEditable: true,
                    header: Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.checklist_rtl, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  LocalKeys.taskChecklist.tr,
                                  variant: AppTextVariant.h2,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                                AppText(
                                  LocalKeys.breakDownTaskIntoSmallerSteps.tr,
                                  variant: AppTextVariant.body,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Show temporary items that will be added when saving
          Obx(() {
            final tempItems = taskController.tempChecklistItems;
            if (tempItems.isEmpty) return const SizedBox.shrink();

            return Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      AppText(
                        '${LocalKeys.newItemsToAdd.tr} (${tempItems.length}):',
                        variant: AppTextVariant.body,
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurface.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 8),
                      ...tempItems.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.radio_button_unchecked,
                                size: 20,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppText(
                                  item,
                                  variant: AppTextVariant.body,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primary,
                                ),
                              ),
                              IconButton(
                                onPressed: () => taskController
                                    .removeTempChecklistItem(index),
                                icon: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: AppColors.error.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
