extension DateTimeExtensions on DateTime {
  String get iso8601String => toIso8601String();

  int get yearOnly => year;

  String get formattedDate => '$day/$month/$year';

  String get formattedWithTime => '$day/$month/$year ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    return isAfter(startOfWeek.copyWith(hour: 0, minute: 0, second: 0));
  }

  DateTime get startOfDay => DateTime(year, month, day);
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);

  int daysBetween(DateTime other) => difference(other).abs().inDays;
}
