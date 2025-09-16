import 'package:get/get.dart';
import 'package:kanbankit/core/utils/date_utils.dart';

enum DateTimePickerMode { date, time, dateTime }

class DateTimePickerController extends GetxController {
  // Observable selected date and time
  final Rx<DateTime?> _selectedDateTime = Rx<DateTime?>(null);
  DateTime? get selectedDateTime => _selectedDateTime.value;

  // Observable picker mode
  final Rx<DateTimePickerMode> _mode = DateTimePickerMode.dateTime.obs;
  DateTimePickerMode get mode => _mode.value;

  // Observable for UI state
  final RxBool _isPickerOpen = false.obs;
  bool get isPickerOpen => _isPickerOpen.value;

  // Observable for validation
  final RxBool _hasError = false.obs;
  bool get hasError => _hasError.value;

  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  // Minimum and maximum date constraints
  DateTime? minDate;
  DateTime? maxDate;

  // Callbacks
  Function(DateTime?)? onDateTimeChanged;
  Function(DateTime?)? onDateTimeSelected;

  @override
  void onInit() {
    super.onInit();
    // Set default constraints
    minDate = DateTime(1900);
    maxDate = DateTime(2100);
  }

  // Set the picker mode
  void setMode(DateTimePickerMode newMode) {
    _mode.value = newMode;
  }

  // Set date constraints
  void setDateConstraints({DateTime? min, DateTime? max}) {
    minDate = min;
    maxDate = max;
    _validateDateTime();
  }

  // Set callbacks
  void setCallbacks({
    Function(DateTime?)? onChange,
    Function(DateTime?)? onSelect,
  }) {
    onDateTimeChanged = onChange;
    onDateTimeSelected = onSelect;
  }

  // Set initial date time
  void setInitialDateTime(DateTime? dateTime) {
    _selectedDateTime.value = dateTime;
    _validateDateTime();
  }

  // Update selected date time
  void updateDateTime(DateTime? dateTime) {
    _selectedDateTime.value = dateTime;
    _validateDateTime();
    onDateTimeChanged?.call(dateTime);
  }

  // Select and confirm date time
  void selectDateTime(DateTime? dateTime) {
    updateDateTime(dateTime);
    onDateTimeSelected?.call(dateTime);
    _isPickerOpen.value = false;
  }

  // Clear selected date time
  void clearDateTime() {
    _selectedDateTime.value = null;
    _clearError();
    onDateTimeChanged?.call(null);
  }

  // Open picker
  void openPicker() {
    _isPickerOpen.value = true;
  }

  // Close picker
  void closePicker() {
    _isPickerOpen.value = false;
  }

  // Validate selected date time
  void _validateDateTime() {
    _clearError();
    
    if (_selectedDateTime.value == null) return;

    final dateTime = _selectedDateTime.value!;

    if (minDate != null && dateTime.isBefore(minDate!)) {
      _setError('Date cannot be before ${AppDateUtils.formatDate(minDate!)}');
      return;
    }

    if (maxDate != null && dateTime.isAfter(maxDate!)) {
      _setError('Date cannot be after ${AppDateUtils.formatDate(maxDate!)}');
      return;
    }
  }

  // Set error state
  void _setError(String message) {
    _hasError.value = true;
    _errorMessage.value = message;
  }

  // Clear error state
  void _clearError() {
    _hasError.value = false;
    _errorMessage.value = '';
  }

  // Format selected date time based on mode
  String getFormattedDateTime() {
    if (_selectedDateTime.value == null) return '';

    switch (_mode.value) {
      case DateTimePickerMode.date:
        return AppDateUtils.formatDate(_selectedDateTime.value!);
      case DateTimePickerMode.time:
        return AppDateUtils.formatTime(_selectedDateTime.value!);
      case DateTimePickerMode.dateTime:
        return AppDateUtils.formatDateTime(_selectedDateTime.value!);
    }
  }

  // Get display text for the picker
  String getDisplayText({String? placeholder}) {
    if (_selectedDateTime.value == null) {
      return placeholder ?? _getDefaultPlaceholder();
    }
    return getFormattedDateTime();
  }

  // Get default placeholder based on mode
  String _getDefaultPlaceholder() {
    switch (_mode.value) {
      case DateTimePickerMode.date:
        return 'Select Date';
      case DateTimePickerMode.time:
        return 'Select Time';
      case DateTimePickerMode.dateTime:
        return 'Select Date & Time';
    }
  }

  // Check if selected date is today
  bool isSelectedDateToday() {
    if (_selectedDateTime.value == null) return false;
    return AppDateUtils.isToday(_selectedDateTime.value!);
  }

  // Check if selected date is overdue
  bool isSelectedDateOverdue() {
    if (_selectedDateTime.value == null) return false;
    return AppDateUtils.isOverdue(_selectedDateTime.value!);
  }

  // Get relative time description
  String getRelativeTimeDescription() {
    if (_selectedDateTime.value == null) return '';

    final now = DateTime.now();
    final selected = _selectedDateTime.value!;
    final difference = selected.difference(now);

    if (difference.isNegative) {
      final absDifference = difference.abs();
      if (absDifference.inDays > 0) {
        return '${absDifference.inDays} day${absDifference.inDays > 1 ? 's' : ''} ago';
      } else if (absDifference.inHours > 0) {
        return '${absDifference.inHours} hour${absDifference.inHours > 1 ? 's' : ''} ago';
      } else {
        return '${absDifference.inMinutes} minute${absDifference.inMinutes > 1 ? 's' : ''} ago';
      }
    } else {
      if (difference.inDays > 0) {
        return 'In ${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
      } else if (difference.inHours > 0) {
        return 'In ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
      } else {
        return 'In ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
      }
    }
  }

  @override
  void onClose() {
    // Clean up when controller is disposed
    onDateTimeChanged = null;
    onDateTimeSelected = null;
    super.onClose();
  }
}
