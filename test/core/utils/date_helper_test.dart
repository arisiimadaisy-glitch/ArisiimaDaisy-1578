import 'package:flutter_test/flutter_test.dart';
import 'package:login_app/core/utils/date_helper.dart';

void main() {
  group('DateHelper', () {
    test('formatDate returns correct format', () {
      final date = DateTime(2024, 1, 15);
      final result = DateHelper.formatDate(date);
      expect(result, 'Jan 15, 2024');
    });

    test('formatDateRange returns correct format for same month', () {
      final start = DateTime(2024, 1, 15);
      final end = DateTime(2024, 1, 21);
      final result = DateHelper.formatDateRange(start, end);
      expect(result, 'Jan 15 - 21');
    });

    test('formatDateRange returns correct format for different months', () {
      final start = DateTime(2024, 1, 25);
      final end = DateTime(2024, 2, 5);
      final result = DateHelper.formatDateRange(start, end);
      expect(result, 'Jan 25 - Feb 5');
    });

    test('getStartOfDay removes time component', () {
      final date = DateTime(2024, 1, 15, 14, 30, 45);
      final result = DateHelper.getStartOfDay(date);
      expect(result.hour, 0);
      expect(result.minute, 0);
      expect(result.second, 0);
    });

    test('getEndOfDay sets time to 23:59:59', () {
      final date = DateTime(2024, 1, 15, 10, 0, 0);
      final result = DateHelper.getEndOfDay(date);
      expect(result.hour, 23);
      expect(result.minute, 59);
      expect(result.second, 59);
    });

    test('getStartOfWeek returns Monday', () {
      final date = DateTime(2024, 1, 17); // Wednesday
      final result = DateHelper.getStartOfWeek(date);
      expect(result.weekday, DateTime.monday);
      expect(result.day, 15);
    });

    test('getStartOfMonth returns first day', () {
      final date = DateTime(2024, 1, 17);
      final result = DateHelper.getStartOfMonth(date);
      expect(result.day, 1);
      expect(result.month, 1);
    });

    test('compareDates returns correct comparison', () {
      final date1 = DateTime(2024, 1, 15);
      final date2 = DateTime(2024, 1, 20);
      final date3 = DateTime(2024, 1, 15);

      expect(DateHelper.compareDates(date1, date2), -1);
      expect(DateHelper.compareDates(date2, date1), 1);
      expect(DateHelper.compareDates(date1, date3), 0);
    });

    test('isSameDay returns true for same day', () {
      final date1 = DateTime(2024, 1, 15, 10, 0);
      final date2 = DateTime(2024, 1, 15, 18, 30);
      expect(DateHelper.isSameDay(date1, date2), true);
    });

    test('isSameDay returns false for different days', () {
      final date1 = DateTime(2024, 1, 15);
      final date2 = DateTime(2024, 1, 16);
      expect(DateHelper.isSameDay(date1, date2), false);
    });

    test('getDateFilter returns correct range for today', () {
      final result = DateHelper.getDateFilter(DateFilterType.today);
      final now = DateTime.now();
      expect(DateHelper.isSameDay(result.start, now), true);
      expect(DateHelper.isSameDay(result.end, now), true);
    });

    test('DateRange contains checks if date is in range', () {
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 1, 31);
      final range = DateRange(start: start, end: end);

      expect(range.contains(DateTime(2024, 1, 15)), true);
      expect(range.contains(DateTime(2023, 12, 31)), false);
      expect(range.contains(DateTime(2024, 2, 1)), false);
    });
  });
}
