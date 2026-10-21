import 'package:intl/intl.dart';

/// Helper functions for date operations
class DateHelper {
  DateHelper._();

  /// Format a date to a human-readable string
  /// Example: "Jan 15, 2024"
  static String formatDate(DateTime date, {String pattern = 'MMM d, y'}) {
    return DateFormat(pattern).format(date);
  }

  /// Format a date range to a human-readable string
  /// Example: "Jan 15 - Jan 21"
  static String formatDateRange(DateTime start, DateTime end) {
    if (start.year == end.year && start.month == end.month) {
      // Same month: "Jan 15 - 21"
      return '${DateFormat('MMM d').format(start)} - ${end.day}';
    } else if (start.year == end.year) {
      // Same year: "Jan 15 - Feb 21"
      return '${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d').format(end)}';
    } else {
      // Different years: "Dec 25, 2023 - Jan 5, 2024"
      return '${DateFormat('MMM d, y').format(start)} - ${DateFormat('MMM d, y').format(end)}';
    }
  }

  /// Get the start of the day (00:00:00)
  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get the end of the day (23:59:59)
  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Get the start of the week (Monday 00:00:00)
  static DateTime getStartOfWeek(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return getStartOfDay(monday);
  }

  /// Get the end of the week (Sunday 23:59:59)
  static DateTime getEndOfWeek(DateTime date) {
    final sunday = date.add(Duration(days: DateTime.daysPerWeek - date.weekday));
    return getEndOfDay(sunday);
  }

  /// Get the start of the month (1st day 00:00:00)
  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get the end of the month (last day 23:59:59)
  static DateTime getEndOfMonth(DateTime date) {
    final nextMonth = date.month == 12
        ? DateTime(date.year + 1, 1, 1)
        : DateTime(date.year, date.month + 1, 1);
    return getEndOfDay(nextMonth.subtract(const Duration(days: 1)));
  }

  /// Get the start of the year (Jan 1 00:00:00)
  static DateTime getStartOfYear(DateTime date) {
    return DateTime(date.year, 1, 1);
  }

  /// Get the end of the year (Dec 31 23:59:59)
  static DateTime getEndOfYear(DateTime date) {
    return getEndOfDay(DateTime(date.year, 12, 31));
  }

  /// Compare two dates (ignoring time)
  /// Returns: -1 if date1 < date2, 0 if equal, 1 if date1 > date2
  static int compareDates(DateTime date1, DateTime date2) {
    final d1 = getStartOfDay(date1);
    final d2 = getStartOfDay(date2);
    return d1.compareTo(d2);
  }

  /// Check if two dates are on the same day
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  /// Check if a date is today
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// Check if a date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  /// Get date filters for common periods
  static DateRange getDateFilter(DateFilterType type, {DateTime? customStart, DateTime? customEnd}) {
    final now = DateTime.now();
    
    switch (type) {
      case DateFilterType.today:
        return DateRange(
          start: getStartOfDay(now),
          end: getEndOfDay(now),
        );
      
      case DateFilterType.yesterday:
        final yesterday = now.subtract(const Duration(days: 1));
        return DateRange(
          start: getStartOfDay(yesterday),
          end: getEndOfDay(yesterday),
        );
      
      case DateFilterType.thisWeek:
        return DateRange(
          start: getStartOfWeek(now),
          end: getEndOfWeek(now),
        );
      
      case DateFilterType.lastWeek:
        final lastWeek = now.subtract(const Duration(days: 7));
        return DateRange(
          start: getStartOfWeek(lastWeek),
          end: getEndOfWeek(lastWeek),
        );
      
      case DateFilterType.thisMonth:
        return DateRange(
          start: getStartOfMonth(now),
          end: getEndOfMonth(now),
        );
      
      case DateFilterType.lastMonth:
        final lastMonth = DateTime(now.year, now.month - 1, now.day);
        return DateRange(
          start: getStartOfMonth(lastMonth),
          end: getEndOfMonth(lastMonth),
        );
      
      case DateFilterType.thisYear:
        return DateRange(
          start: getStartOfYear(now),
          end: getEndOfYear(now),
        );
      
      case DateFilterType.lastYear:
        final lastYear = DateTime(now.year - 1, now.month, now.day);
        return DateRange(
          start: getStartOfYear(lastYear),
          end: getEndOfYear(lastYear),
        );
      
      case DateFilterType.last7Days:
        return DateRange(
          start: getStartOfDay(now.subtract(const Duration(days: 6))),
          end: getEndOfDay(now),
        );
      
      case DateFilterType.last30Days:
        return DateRange(
          start: getStartOfDay(now.subtract(const Duration(days: 29))),
          end: getEndOfDay(now),
        );
      
      case DateFilterType.custom:
        if (customStart == null || customEnd == null) {
          throw ArgumentError('Custom date filter requires start and end dates');
        }
        return DateRange(
          start: getStartOfDay(customStart),
          end: getEndOfDay(customEnd),
        );
      
      case DateFilterType.allTime:
        return DateRange(
          start: DateTime(2000, 1, 1),
          end: getEndOfDay(now),
        );
    }
  }
}

/// Date filter types
enum DateFilterType {
  today,
  yesterday,
  thisWeek,
  lastWeek,
  thisMonth,
  lastMonth,
  thisYear,
  lastYear,
  last7Days,
  last30Days,
  custom,
  allTime,
}

/// Date range model
class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({
    required this.start,
    required this.end,
  });

  bool contains(DateTime date) {
    return date.isAfter(start.subtract(const Duration(milliseconds: 1))) &&
        date.isBefore(end.add(const Duration(milliseconds: 1)));
  }

  @override
  String toString() {
    return '${DateHelper.formatDate(start)} - ${DateHelper.formatDate(end)}';
  }
}
