import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/enums/board_view_mode.dart';
import '../responsive_text.dart';
import '../../../core/localization/local_keys.dart';

class ViewModeToggle extends StatelessWidget {
  final BoardViewMode currentMode;
  final Function(BoardViewMode) onModeChanged;

  const ViewModeToggle({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildToggleButton(
            context,
            mode: BoardViewMode.active,
            icon: Icons.dashboard_outlined,
            label: LocalKeys.yourBoards.tr,
          ),
          _buildToggleButton(
            context,
            mode: BoardViewMode.archived,
            icon: Icons.archive_outlined,
            label: LocalKeys.archivedBoards.tr,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    BuildContext context, {
    required BoardViewMode mode,
    required IconData icon,
    required String label,
  }) {
    final isSelected = currentMode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () => onModeChanged(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 20,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurfaceVariant),
              const SizedBox(width: 8),
              Flexible(
                child: AppText(
                  label,
                  variant: AppTextVariant.body,
                  color: isSelected
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
