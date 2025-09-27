import 'package:flutter/material.dart';

/// Utility class for color operations
class ColorUtils {
  /// Parse color from hex string
  static Color parseColor(String colorString) {
    try {
      // Remove # if present
      String hexColor = colorString.replaceAll('#', '');
      
      // Add alpha if not present
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      // Return default color if parsing fails
      return Colors.blue;
    }
  }

  /// Convert color to hex string
  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  /// Check if color is light (for determining text color)
  static bool isLightColor(Color color) {
    // Calculate luminance
    final luminance = (0.299 * color.red + 0.587 * color.green + 0.114 * color.blue) / 255;
    return luminance > 0.5;
  }

  /// Get contrasting text color for background
  static Color getContrastingTextColor(Color backgroundColor) {
    return isLightColor(backgroundColor) ? Colors.black87 : Colors.white;
  }

  /// Predefined label colors
  static const List<Color> predefinedColors = [
    Color(0xFF2196F3), // Blue
    Color(0xFF4CAF50), // Green
    Color(0xFFFF9800), // Orange
    Color(0xFFF44336), // Red
    Color(0xFF9C27B0), // Purple
    Color(0xFF607D8B), // Blue Grey
    Color(0xFF795548), // Brown
    Color(0xFFE91E63), // Pink
    Color(0xFF009688), // Teal
    Color(0xFFFFEB3B), // Yellow
    Color(0xFF3F51B5), // Indigo
    Color(0xFF8BC34A), // Light Green
    Color(0xFFFF5722), // Deep Orange
    Color(0xFF673AB7), // Deep Purple
    Color(0xFF00BCD4), // Cyan
    Color(0xFFCDDC39), // Lime
  ];

  /// Get predefined color names for UI
  static final Map<Color, String> colorNames = {
    Color(0xFF2196F3): 'Blue',
    Color(0xFF4CAF50): 'Green',
    Color(0xFFFF9800): 'Orange',
    Color(0xFFF44336): 'Red',
    Color(0xFF9C27B0): 'Purple',
    Color(0xFF607D8B): 'Blue Grey',
    Color(0xFF795548): 'Brown',
    Color(0xFFE91E63): 'Pink',
    Color(0xFF009688): 'Teal',
    Color(0xFFFFEB3B): 'Yellow',
    Color(0xFF3F51B5): 'Indigo',
    Color(0xFF8BC34A): 'Light Green',
    Color(0xFFFF5722): 'Deep Orange',
    Color(0xFF673AB7): 'Deep Purple',
    Color(0xFF00BCD4): 'Cyan',
    Color(0xFFCDDC39): 'Lime',
  };

  /// Generate a random color from predefined colors
  static Color getRandomColor() {
    final random = DateTime.now().millisecondsSinceEpoch % predefinedColors.length;
    return predefinedColors[random];
  }

  /// Find closest predefined color
  static Color findClosestPredefinedColor(Color targetColor) {
    Color closestColor = predefinedColors.first;
    double minDistance = double.infinity;

    for (final color in predefinedColors) {
      final distance = _colorDistance(targetColor, color);
      if (distance < minDistance) {
        minDistance = distance;
        closestColor = color;
      }
    }

    return closestColor;
  }

  /// Calculate distance between two colors
  static double _colorDistance(Color color1, Color color2) {
    final rDiff = color1.red - color2.red;
    final gDiff = color1.green - color2.green;
    final bDiff = color1.blue - color2.blue;
    
    return (rDiff * rDiff + gDiff * gDiff + bDiff * bDiff).toDouble();
  }

  /// Create a lighter version of the color
  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    
    return hsl.withLightness(lightness).toColor();
  }

  /// Create a darker version of the color
  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    
    return hsl.withLightness(lightness).toColor();
  }
}
