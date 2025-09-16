import 'package:intl/intl.dart';

class AppDateUtils {
  // Basic formatting methods
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }
  
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy HH:mm').format(dateTime);
  }
  
  static String formatTime(DateTime time) {
    return DateFormat('HH:mm').format(time);
  }

  // Extended formatting methods for date picker
  static String formatDateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatDateLong(DateTime date) {
    return DateFormat('EEEE, MMMM dd, yyyy').format(date);
  }

  static String formatTimeWithSeconds(DateTime time) {
    return DateFormat('HH:mm:ss').format(time);
  }

  static String formatTime12Hour(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  static String formatDateTimeShort(DateTime dateTime) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
  }

  static String formatDateTimeLong(DateTime dateTime) {
    return DateFormat('EEEE, MMMM dd, yyyy \'at\' h:mm a').format(dateTime);
  }

  static String formatDateTimeWithSeconds(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy HH:mm:ss').format(dateTime);
  }

  // Relative time formatting
  static String formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.isNegative) {
      final absDifference = difference.abs();
      if (absDifference.inDays > 7) {
        return formatDate(dateTime);
      } else if (absDifference.inDays > 0) {
        return '${absDifference.inDays} day${absDifference.inDays > 1 ? 's' : ''} ago';
      } else if (absDifference.inHours > 0) {
        return '${absDifference.inHours} hour${absDifference.inHours > 1 ? 's' : ''} ago';
      } else if (absDifference.inMinutes > 0) {
        return '${absDifference.inMinutes} minute${absDifference.inMinutes > 1 ? 's' : ''} ago';
      } else {
        return 'Just now';
      }
    } else {
      if (difference.inDays > 7) {
        return formatDate(dateTime);
      } else if (difference.inDays > 0) {
        return 'In ${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
      } else if (difference.inHours > 0) {
        return 'In ${difference.inHours} hour${difference.inHours > 1 ? 's' : ''}';
      } else if (difference.inMinutes > 0) {
        return 'In ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
      } else {
        return 'Now';
      }
    }
  }

  // Validation and comparison methods
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }
  
  static bool isOverdue(DateTime dueDate) {
    return dueDate.isBefore(DateTime.now());
  }

  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
           date.month == tomorrow.month &&
           date.day == tomorrow.day;
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
           date.month == yesterday.month &&
           date.day == yesterday.day;
  }

  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
           date.isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  static bool isThisYear(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year;
  }

  // Utility methods for date picker
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  static DateTime startOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  static DateTime endOfWeek(DateTime date) {
    return startOfWeek(date).add(const Duration(days: 6));
  }

  static DateTime startOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  static DateTime endOfMonth(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }

  static int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  // Smart formatting based on context
  static String formatSmart(DateTime dateTime) {
    if (isToday(dateTime)) {
      return 'Today ${formatTime(dateTime)}';
    } else if (isTomorrow(dateTime)) {
      return 'Tomorrow ${formatTime(dateTime)}';
    } else if (isYesterday(dateTime)) {
      return 'Yesterday ${formatTime(dateTime)}';
    } else if (isThisWeek(dateTime)) {
      return DateFormat('EEEE HH:mm').format(dateTime);
    } else if (isThisYear(dateTime)) {
      return DateFormat('MMM dd, HH:mm').format(dateTime);
    } else {
      return formatDateTime(dateTime);
    }
  }

  // Parse methods
  static DateTime? tryParseDate(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  static DateTime? tryParseDateFormat(String dateString, String format) {
    try {
      return DateFormat(format).parse(dateString);
    } catch (e) {
      return null;
    }
  }
}
