import 'package:intl/intl.dart';

class DateHelpers {
  static DateTime get today => DateTime.now().withTimeOnly(0, 0, 0);
  
  static String formatDate(DateTime date) => DateFormat('MMM dd, yyyy').format(date);
  
  static String formatDateShort(DateTime date) => DateFormat('MMM dd').format(date);
  
  static String formatTime(DateTime date) => DateFormat('hh:mm a').format(date);
  
  static String formatRelative(DateTime date) {
    final now = today;
    final diff = date.difference(now).inDays;
    
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    if (diff > 0 && diff <= 7) return 'In $diff days';
    if (diff < 0 && diff >= -7) return '${-diff} days ago';
    
    return formatDate(date);
  }
  
  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
  
  static int daysBetween(DateTime from, DateTime to) =>
      to.withTimeOnly(0, 0, 0).difference(from.withTimeOnly(0, 0, 0)).inDays;
  
  static DateTime addDays(DateTime date, int days) =>
      date.add(Duration(days: days));
}

extension DateTimeExtension on DateTime {
  DateTime withTimeOnly(int hour, int minute, int second) =>
      DateTime(year, month, day, hour, minute, second);
}
