import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/localization/local_keys.dart';
import 'package:kanbankit/views/components/text_buttons/app_text_button.dart';
import 'package:kanbankit/views/components/text_buttons/button_variant.dart';

class ListFooterWidget extends StatelessWidget {
  final VoidCallback onAddCard;

  const ListFooterWidget({
    super.key,
    required this.onAddCard,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: AppTextButton(
        onPressed: onAddCard,
        label: LocalKeys.addCard.tr,
        leadingIcon: Icons.add,
        variant: AppButtonVariant.secondary,
      ),
    );
  }
}
