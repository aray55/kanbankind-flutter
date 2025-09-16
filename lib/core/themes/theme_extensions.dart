// import 'package:flutter/material.dart';
// import 'app_theme.dart';

// /// Extension methods to easily access custom theme colors and utilities
// extension ThemeExtensions on BuildContext {
//   /// Get the current color scheme
//   ColorScheme get colorScheme => Theme.of(this).colorScheme;
  
//   /// Get the current text theme
//   TextTheme get textTheme => Theme.of(this).textTheme;
  
//   /// Check if the current theme is dark
//   bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  
//   /// Get Kanban column colors based on current theme
//   Color getKanbanColor(String columnType) {
//     if (isDarkMode) {
//       switch (columnType.toLowerCase()) {
//         case 'todo':
//           return AppTheme.kanbanColors['todoDark']!;
//         case 'inprogress':
//         case 'in_progress':
//           return AppTheme.kanbanColors['inProgressDark']!;
//         case 'done':
//           return AppTheme.kanbanColors['doneDark']!;
//         default:
//           return colorScheme.surfaceContainerHighest;
//       }
//     } else {
//       switch (columnType.toLowerCase()) {
//         case 'todo':
//           return AppTheme.kanbanColors['todo']!;
//         case 'inprogress':
//         case 'in_progress':
//           return AppTheme.kanbanColors['inProgress']!;
//         case 'done':
//           return AppTheme.kanbanColors['done']!;
//         default:
//           return colorScheme.surfaceVariant;
//       }
//     }
//   }
  
//   /// Get status colors
//   Color getStatusColor(String status) {
//     switch (status.toLowerCase()) {
//       case 'success':
//         return AppTheme.statusColors['success']!;
//       case 'warning':
//         return AppTheme.statusColors['warning']!;
//       case 'error':
//         return AppTheme.statusColors['error']!;
//       case 'info':
//         return AppTheme.statusColors['info']!;
//       default:
//         return colorScheme.primary;
//     }
//   }
  
//   /// Get appropriate text color for a given background color
//   Color getTextColorForBackground(Color backgroundColor) {
//     // Calculate luminance to determine if we need light or dark text
//     final luminance = backgroundColor.computeLuminance();
//     return luminance > 0.5 ? Colors.black87 : Colors.white;
//   }
  
//   /// Common padding values
//   EdgeInsets get paddingSmall => const EdgeInsets.all(8.0);
//   EdgeInsets get paddingMedium => const EdgeInsets.all(16.0);
//   EdgeInsets get paddingLarge => const EdgeInsets.all(24.0);
  
//   /// Common border radius values
//   BorderRadius get radiusSmall => BorderRadius.circular(4.0);
//   BorderRadius get radiusMedium => BorderRadius.circular(8.0);
//   BorderRadius get radiusLarge => BorderRadius.circular(12.0);
//   BorderRadius get radiusXLarge => BorderRadius.circular(16.0);
// }

// /// Custom theme data extensions
// extension CustomThemeData on ThemeData {
//   /// Get elevation for different components
//   double get cardElevation => brightness == Brightness.dark ? 4.0 : 2.0;
//   double get buttonElevation => 2.0;
//   double get fabElevation => 4.0;
  
//   /// Get custom spacing values
//   double get spacingXS => 4.0;
//   double get spacingS => 8.0;
//   double get spacingM => 16.0;
//   double get spacingL => 24.0;
//   double get spacingXL => 32.0;
// }
