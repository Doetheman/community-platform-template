import 'package:intl/intl.dart';

class EventDateUtils {
  // Format methods
  static String formatDateShort(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  static String formatDateFull(DateTime date) {
    return DateFormat('EEEE, MMMM d, y').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

  static String formatDateAndTime(DateTime date) {
    return '${formatDateFull(date)} at ${formatTime(date)}';
  }

  // Date comparison methods
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day;
  }

  static bool isThisWeek(DateTime date) {
    final now = DateTime.now();
    final weekEnd = DateTime(now.year, now.month, now.day + 7);
    return date.isAfter(now) && date.isBefore(weekEnd);
  }

  static bool isThisMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  // Helper for getting relative date description
  static String getRelativeDateDescription(DateTime date) {
    if (isToday(date)) {
      return 'Today';
    } else if (isTomorrow(date)) {
      return 'Tomorrow';
    } else if (isThisWeek(date)) {
      return DateFormat('EEEE').format(date); // Just the day name
    } else if (isThisMonth(date)) {
      return DateFormat('MMM d').format(date); // Month and day
    } else {
      return DateFormat('MMM d, y').format(date); // Month, day and year
    }
  }

  // Normalize a date to midnight for date comparison
  static DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Group dates by a specific duration - useful for calendar views
  static Map<DateTime, List<T>> groupByDate<T>(
    List<T> items,
    DateTime Function(T) dateSelector,
  ) {
    final Map<DateTime, List<T>> groupedMap = {};

    for (final item in items) {
      final date = dateSelector(item);
      final normalizedDate = normalizeDate(date);

      if (groupedMap[normalizedDate] == null) {
        groupedMap[normalizedDate] = [];
      }

      groupedMap[normalizedDate]!.add(item);
    }

    return groupedMap;
  }
}
