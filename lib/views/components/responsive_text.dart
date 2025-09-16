import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kanbankit/core/themes/app_typography.dart';

import '../../core/localization/local_keys.dart' show LocalKeys;

class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final String? shortText;
  final double? minFontSize;
  final double? maxFontSize;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.shortText,
    this.minFontSize,
    this.maxFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.of(context).size.width;
        final availableWidth = constraints.maxWidth;

        // Determine text content based on available space
        String displayText = text;
        TextStyle finalStyle = style ?? AppTypography().body;

        // Screen size breakpoints
        final isSmallScreen = screenWidth < 600;
        final isMediumScreen = screenWidth >= 600 && screenWidth < 1024;
        final isLargeScreen = screenWidth >= 1024;

        // Adjust font size based on screen size
        double fontSize = finalStyle.fontSize ?? 14.0;
        if (maxFontSize != null && minFontSize != null) {
          if (isSmallScreen) {
            fontSize = minFontSize!;
          } else if (isMediumScreen) {
            fontSize = (minFontSize! + maxFontSize!) / 2;
          } else if (isLargeScreen) {
            fontSize = maxFontSize!;
          }
        } else {
          // Default responsive font sizing
          if (isSmallScreen) {
            fontSize = fontSize * 0.8;
          } else if (isMediumScreen) {
            fontSize = fontSize * 0.9;
          }
        }

        // Use short text for very narrow spaces
        if (availableWidth < 80 && shortText != null) {
          displayText = shortText!;
        } else if (availableWidth < 120) {
          // Use abbreviated text for narrow spaces
          displayText = _getAbbreviatedText(text);
        }

        finalStyle = finalStyle.copyWith(fontSize: fontSize);

        return Text(
          displayText,
          style: finalStyle,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow ?? TextOverflow.ellipsis,
        );
      },
    );
  }

  String _getAbbreviatedText(String originalText) {
    // Create abbreviations for common Kanban terms
    switch (originalText.toLowerCase()) {
      case 'to do':
        return LocalKeys.todo.tr;
      case 'in progress':
        return LocalKeys.inProgress.tr;
      case 'done':
        return LocalKeys.done.tr;
      default:
        // For other text, return first word or first few characters
        final words = originalText.split(' ');
        if (words.length > 1) {
          return words.first;
        } else if (originalText.length > 8) {
          return '${originalText.substring(0, 6)}...';
        }
        return originalText;
    }
  }
}

// Specialized responsive text for Kanban column headers
class KanbanColumnTitle extends StatelessWidget {
  final String title;
  final Color textColor;
  final FontWeight? fontWeight;

  const KanbanColumnTitle({
    super.key,
    required this.title,
    this.textColor = Colors.white,
    this.fontWeight = FontWeight.bold,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        // Determine display strategy based on available width
        if (availableWidth < 60) {
          // Very narrow: show just initials
          return Text(
            _getInitials(title),
            style: TextStyle(
              fontSize: 14,
              fontWeight: fontWeight,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          );
        } else if (availableWidth < 100) {
          // Narrow: show abbreviated version
          return Text(
            _getAbbreviation(title),
            style: TextStyle(
              fontSize: 16,
              fontWeight: fontWeight,
              color: textColor,
            ),
            overflow: TextOverflow.ellipsis,
          );
        } else {
          // Normal width: show full title
          return Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: fontWeight,
              color: textColor,
            ),
            overflow: TextOverflow.ellipsis,
          );
        }
      },
    );
  }

  String _getInitials(String text) {
    final words = text.split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (text.length >= 2) {
      return text.substring(0, 2).toUpperCase();
    }
    return text.toUpperCase();
  }

  String _getAbbreviation(String text) {
    switch (text.toLowerCase()) {
      case 'to do':
        return LocalKeys.todo.tr;
      case 'in progress':
        return LocalKeys.inProgress.tr;
      case 'done':
        return LocalKeys.done.tr;
      default:
        final words = text.split(' ');
        if (words.length > 1) {
          return words.first;
        }
        return text.length > 8 ? '${text.substring(0, 6)}...' : text;
    }
  }
}
