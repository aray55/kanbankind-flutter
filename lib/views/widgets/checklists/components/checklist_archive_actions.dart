import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/checklists_controller.dart';
import '../../../../core/localization/local_keys.dart';
import '../../../../models/checklist_model.dart';
import '../../../components/text_buttons/app_text_button.dart';
import '../../../components/text_buttons/button_variant.dart';
import '../../../components/text_buttons/button_size.dart';

class ChecklistArchiveActions extends StatelessWidget {
  final ChecklistModel checklist;
  final VoidCallback? onActionCompleted;

  const ChecklistArchiveActions({
    Key? key,
    required this.checklist,
    this.onActionCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChecklistsController>();

    return Container(
      key: ValueKey('checklist_archive_actions_${checklist.id}'),
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          AppTextButton(
            label: LocalKeys.unarchive.tr,
            variant: AppButtonVariant.secondary,
            size: AppButtonSize.small,
            leadingIcon: Icons.unarchive_outlined,
            onPressed: () => _unarchiveChecklist(controller),
          ),
          const SizedBox(width: 8),
          AppTextButton(
            label: LocalKeys.delete.tr,
            variant: AppButtonVariant.danger,
            size: AppButtonSize.small,
            leadingIcon: Icons.delete_outline,
            onPressed: () => _confirmDelete(context, controller),
          ),
        ],
      ),
    );
  }

  void _unarchiveChecklist(ChecklistsController controller) {
    controller.unarchiveChecklist(checklist.id!);
    onActionCompleted?.call();
  }

  void _confirmDelete(BuildContext context, ChecklistsController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalKeys.deleteChecklist.tr),
        content: Text(LocalKeys.deleteChecklistConfirmation.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(LocalKeys.cancel.tr),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.deleteChecklist(checklist.id!);
              onActionCompleted?.call();
            },
            child: Text(LocalKeys.delete.tr),
          ),
        ],
      ),
    );
  }
}
