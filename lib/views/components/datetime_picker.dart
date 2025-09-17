import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/controllers/datetime_picker_controller.dart';
import 'package:kanbankit/core/themes/app_colors.dart';
import 'package:kanbankit/core/themes/app_typography.dart';
import 'package:kanbankit/views/widgets/responsive_text.dart';

class DateTimePicker extends StatelessWidget {
  final String? label;
  final String? placeholder;
  final DateTimePickerMode mode;
  final DateTime? initialDateTime;
  final DateTime? minDate;
  final DateTime? maxDate;
  final Function(DateTime?)? onChanged;
  final Function(DateTime?)? onSelected;
  final bool enabled;
  final bool required;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final String? helperText;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const DateTimePicker({
    Key? key,
    this.label,
    this.placeholder,
    this.mode = DateTimePickerMode.dateTime,
    this.initialDateTime,
    this.minDate,
    this.maxDate,
    this.onChanged,
    this.onSelected,
    this.enabled = true,
    this.required = false,
    this.prefixIcon,
    this.suffixIcon,
    this.helperText,
    this.margin,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DateTimePickerController(), tag: key.toString());

    // Initialize controller
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setMode(mode);
      controller.setInitialDateTime(initialDateTime);
      controller.setDateConstraints(min: minDate, max: maxDate);
      controller.setCallbacks(onChange: onChanged, onSelect: onSelected);
    });

    return Container(
      margin: margin,
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null) ...[
            Row(
              children: [
                Text(label!, style: Get.theme.textTheme.titleMedium),
                if (required)
                  Text(
                    ' *',
                    style: Get.theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.error,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          Obx(
            () => InkWell(
              onTap: enabled ? () => _showPicker(context, controller) : null,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: controller.hasError
                        ? AppColors.error
                        : enabled
                        ? AppColors.outline
                        : AppColors.outline.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(8),
                  color: enabled
                      ? Get.theme.colorScheme.surface
                      : Get.theme.colorScheme.surface.withValues(alpha: 0.5),
                ),
                child: Row(
                  children: [
                    if (prefixIcon != null) ...[
                      Icon(
                        prefixIcon,
                        color: enabled
                            ? Get.theme.colorScheme.onSurface
                            : Get.theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: AppText(
                        controller.getDisplayText(placeholder: placeholder),
                        variant: AppTextVariant.body,
                        color: controller.selectedDateTime != null
                            ? (enabled
                                  ? Get.theme.colorScheme.onSurface
                                    : Get.theme.colorScheme.onSurface
                                          .withValues(alpha: 0.5))
                              : Get.theme.colorScheme.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                      ),
                    ),
                    if (controller.selectedDateTime != null && enabled) ...[
                      IconButton(
                        onPressed: () => controller.clearDateTime(),
                        icon: Icon(
                          Icons.clear,
                          size: 18,
                          color: Get.theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 24,
                          minHeight: 24,
                        ),
                      ),
                    ],
                    Icon(
                      suffixIcon ?? _getDefaultSuffixIcon(),
                      color: enabled
                          ? Get.theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            )
                          : Get.theme.colorScheme.onSurface.withValues(
                              alpha: 0.3,
                            ),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Obx(() {
            if (controller.hasError) {
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: AppText(
                  controller.errorMessage,
                  variant: AppTextVariant.body,
                  color: Get.theme.colorScheme.error,
                ),
              );
            }
            if (helperText != null) {
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: AppText(
                  helperText!,
                  variant: AppTextVariant.body,
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  IconData _getDefaultSuffixIcon() {
    switch (mode) {
      case DateTimePickerMode.date:
        return Icons.calendar_today;
      case DateTimePickerMode.time:
        return Icons.access_time;
      case DateTimePickerMode.dateTime:
        return Icons.event;
    }
  }

  Future<void> _showPicker(
    BuildContext context,
    DateTimePickerController controller,
  ) async {
    controller.openPicker();

    switch (controller.mode) {
      case DateTimePickerMode.date:
        await _showDatePicker(context, controller);
        break;
      case DateTimePickerMode.time:
        await _showTimePicker(context, controller);
        break;
      case DateTimePickerMode.dateTime:
        await _showDateTimePicker(context, controller);
        break;
    }

    controller.closePicker();
  }

  Future<void> _showDatePicker(
    BuildContext context,
    DateTimePickerController controller,
  ) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: controller.selectedDateTime ?? DateTime.now(),
      firstDate: controller.minDate ?? DateTime(1900),
      lastDate: controller.maxDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(data: Get.theme, child: child!);
      },
    );

    if (selectedDate != null) {
      // Preserve time if it exists
      final currentTime = controller.selectedDateTime;
      final newDateTime = currentTime != null
          ? DateTime(
              selectedDate.year,
              selectedDate.month,
              selectedDate.day,
              currentTime.hour,
              currentTime.minute,
            )
          : selectedDate;

      controller.selectDateTime(newDateTime);
    }
  }

  Future<void> _showTimePicker(
    BuildContext context,
    DateTimePickerController controller,
  ) async {
    final currentDateTime = controller.selectedDateTime ?? DateTime.now();
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentDateTime),
      builder: (context, child) {
        return Theme(data: Get.theme, child: child!);
      },
    );

    if (selectedTime != null) {
      final newDateTime = DateTime(
        currentDateTime.year,
        currentDateTime.month,
        currentDateTime.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      controller.selectDateTime(newDateTime);
    }
  }

  Future<void> _showDateTimePicker(
    BuildContext context,
    DateTimePickerController controller,
  ) async {
    // First show date picker
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: controller.selectedDateTime ?? DateTime.now(),
      firstDate: controller.minDate ?? DateTime(1900),
      lastDate: controller.maxDate ?? DateTime(2100),
      builder: (context, child) {
        return Theme(data: Get.theme, child: child!);
      },
    );

    if (selectedDate != null) {
      // Then show time picker
      final currentTime = controller.selectedDateTime ?? DateTime.now();
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(currentTime),
        builder: (context, child) {
          return Theme(data: Get.theme, child: child!);
        },
      );

      if (selectedTime != null) {
        final newDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );

        controller.selectDateTime(newDateTime);
      }
    }
  }
}

// Compact version for inline use
class CompactDateTimePicker extends StatelessWidget {
  final DateTimePickerMode mode;
  final DateTime? initialDateTime;
  final Function(DateTime?)? onChanged;
  final bool enabled;
  final String? placeholder;

  const CompactDateTimePicker({
    Key? key,
    this.mode = DateTimePickerMode.dateTime,
    this.initialDateTime,
    this.onChanged,
    this.enabled = true,
    this.placeholder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DateTimePickerController(), tag: key.toString());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setMode(mode);
      controller.setInitialDateTime(initialDateTime);
      controller.setCallbacks(onChange: onChanged);
    });

    return Obx(
      () => InkWell(
        onTap: enabled ? () => _showPicker(context, controller) : null,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: Get.theme.colorScheme.outline.withOpacity(0.5),
            ),
            borderRadius: BorderRadius.circular(6),
            color: enabled
                ? Get.theme.colorScheme.surface
                : Get.theme.colorScheme.surface.withOpacity(0.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getIcon(),
                size: 16,
                color: enabled
                    ? Get.theme.colorScheme.onSurface.withOpacity(0.7)
                    : Get.theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              const SizedBox(width: 8),
              Text(
                controller.getDisplayText(placeholder: placeholder),
                style: Get.theme.textTheme.bodySmall?.copyWith(
                  color: controller.selectedDateTime != null
                      ? (enabled
                            ? Get.theme.colorScheme.onSurface
                            : Get.theme.colorScheme.onSurface.withOpacity(0.5))
                      : Get.theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              if (controller.selectedDateTime != null && enabled) ...[
                const SizedBox(width: 4),
                InkWell(
                  onTap: () => controller.clearDateTime(),
                  borderRadius: BorderRadius.circular(12),
                  child: Icon(
                    Icons.close,
                    size: 14,
                    color: Get.theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (mode) {
      case DateTimePickerMode.date:
        return Icons.calendar_today;
      case DateTimePickerMode.time:
        return Icons.access_time;
      case DateTimePickerMode.dateTime:
        return Icons.event;
    }
  }

  Future<void> _showPicker(
    BuildContext context,
    DateTimePickerController controller,
  ) async {
    // Use the same picker logic as the main DateTimePicker
    switch (controller.mode) {
      case DateTimePickerMode.date:
        await _showDatePicker(context, controller);
        break;
      case DateTimePickerMode.time:
        await _showTimePicker(context, controller);
        break;
      case DateTimePickerMode.dateTime:
        await _showDateTimePicker(context, controller);
        break;
    }
  }

  Future<void> _showDatePicker(
    BuildContext context,
    DateTimePickerController controller,
  ) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: controller.selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(data: Get.theme, child: child!);
      },
    );

    if (selectedDate != null) {
      controller.selectDateTime(selectedDate);
    }
  }

  Future<void> _showTimePicker(
    BuildContext context,
    DateTimePickerController controller,
  ) async {
    final currentDateTime = controller.selectedDateTime ?? DateTime.now();
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(currentDateTime),
      builder: (context, child) {
        return Theme(data: Get.theme, child: child!);
      },
    );

    if (selectedTime != null) {
      final newDateTime = DateTime(
        currentDateTime.year,
        currentDateTime.month,
        currentDateTime.day,
        selectedTime.hour,
        selectedTime.minute,
      );
      controller.selectDateTime(newDateTime);
    }
  }

  Future<void> _showDateTimePicker(
    BuildContext context,
    DateTimePickerController controller,
  ) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: controller.selectedDateTime ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(data: Get.theme, child: child!);
      },
    );

    if (selectedDate != null) {
      final currentTime = controller.selectedDateTime ?? DateTime.now();
      final selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(currentTime),
        builder: (context, child) {
          return Theme(data: Get.theme, child: child!);
        },
      );

      if (selectedTime != null) {
        final newDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
        controller.selectDateTime(newDateTime);
      }
    }
  }
}
