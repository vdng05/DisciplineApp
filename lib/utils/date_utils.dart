import 'package:intl/intl.dart';

class AppDateUtils {
  static final DateFormat _isoFormat = DateFormat('yyyy-MM-dd');

  /// Convert DateTime to 'yyyy-MM-dd' string
  static String formatDateIso(DateTime date) {
    return _isoFormat.format(date);
  }

  /// Parse 'yyyy-MM-dd' string to DateTime
  static DateTime parseDateIso(String isoString) {
    return _isoFormat.parse(isoString);
  }

  /// Returns true if two dates represent the same day
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Check if date is today
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// Check if date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  /// Short weekday label (T2, T3, T4, T5, T6, T7, CN)
  static String getWeekdayShort(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'T2';
      case DateTime.tuesday:
        return 'T3';
      case DateTime.wednesday:
        return 'T4';
      case DateTime.thursday:
        return 'T5';
      case DateTime.friday:
        return 'T6';
      case DateTime.saturday:
        return 'T7';
      case DateTime.sunday:
        return 'CN';
      default:
        return '';
    }
  }

  /// Full weekday name in Vietnamese
  static String getWeekdayFull(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Thứ Hai';
      case DateTime.tuesday:
        return 'Thứ Ba';
      case DateTime.wednesday:
        return 'Thứ Tư';
      case DateTime.thursday:
        return 'Thứ Năm';
      case DateTime.friday:
        return 'Thứ Sáu';
      case DateTime.saturday:
        return 'Thứ Bảy';
      case DateTime.sunday:
        return 'Chủ Nhật';
      default:
        return '';
    }
  }

  /// Format date for display: "Hôm nay, 05/11" or "Thứ Tư, 04/11"
  static String formatDisplayHeader(DateTime date) {
    if (isToday(date)) {
      return 'Hôm nay, ${DateFormat('dd/MM/yyyy').format(date)}';
    } else if (isYesterday(date)) {
      return 'Hôm qua, ${DateFormat('dd/MM/yyyy').format(date)}';
    } else {
      return '${getWeekdayFull(date.weekday)}, ${DateFormat('dd/MM/yyyy').format(date)}';
    }
  }

  /// Format day and month: "05/11"
  static String formatDayMonth(DateTime date) {
    return DateFormat('dd/MM').format(date);
  }

  /// Get the list of 7 days for the week containing [date] (Monday to Sunday)
  static List<DateTime> getDaysOfWeek(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(7, (index) {
      final day = monday.add(Duration(days: index));
      return DateTime(day.year, day.month, day.day);
    });
  }

  /// Get all days in the month for [date]
  static List<DateTime> getDaysInMonth(DateTime date) {
    final lastDay = DateTime(date.year, date.month + 1, 0);
    final totalDays = lastDay.day;

    return List.generate(totalDays, (index) {
      return DateTime(date.year, date.month, index + 1);
    });
  }

  /// Get start and end dates of a week
  static DateTime getStartOfWeek(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return d.subtract(Duration(days: d.weekday - 1));
  }

  static DateTime getEndOfWeek(DateTime date) {
    final start = getStartOfWeek(date);
    return start.add(const Duration(days: 6));
  }

  /// Get month name in Vietnamese
  static String getMonthName(int month) {
    return 'Tháng $month';
  }
}
