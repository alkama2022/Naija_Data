/// Time-zone helpers for Auto-Buy schedules.
///
/// Nigeria runs on West Africa Time (WAT) which is UTC+1 all year round —
/// there is no daylight saving, so a single fixed offset is exact.
///
/// The engine works with "wall clock" dates: [DateTime]s whose UTC fields
/// hold the local time in the customer's zone. Wall-clock arithmetic (add a
/// day, jump to the next Monday) is then plain `DateTime` maths, and the
/// wall clock is converted back to a real UTC instant only at the very end.
///
/// This is the Dart twin of `src/lib/auto_buy/time.ts` in the backend. Both
/// implementations must stay in sync so the app preview and the server
/// agree on the next purchase time.
library;

/// The zone every Nigerian customer schedules in.
const String kAutoBuyTimezone = 'Africa/Lagos';

/// WAT is UTC+1 and never changes.
const int kAutoBuyTimezoneOffsetMinutes = 60;

/// Converts a UTC instant into the local wall clock of [kAutoBuyTimezone].
DateTime toAutoBuyWallClock(DateTime instant) {
  return instant.toUtc().add(
        const Duration(minutes: kAutoBuyTimezoneOffsetMinutes),
      );
}

/// Converts a local wall clock back into a UTC instant.
DateTime fromAutoBuyWallClock(DateTime wallClock) {
  return wallClock.toUtc().subtract(
        const Duration(minutes: kAutoBuyTimezoneOffsetMinutes),
      );
}

/// ISO weekday of a wall-clock date: 1 = Monday … 7 = Sunday.
int autoBuyIsoWeekday(DateTime wallClock) {
  final day = wallClock.toUtc().weekday; // 1 = Monday … 7 = Sunday
  return day;
}

/// Monday 00:00 of the week the given wall-clock date belongs to.
DateTime autoBuyStartOfWeek(DateTime wallClock) {
  final utc = wallClock.toUtc();
  return DateTime.utc(
    utc.year,
    utc.month,
    utc.day,
  ).subtract(Duration(days: autoBuyIsoWeekday(utc) - 1));
}

/// Number of days in a given month.
int autoBuyDaysInMonth(int year, int month) {
  // Day 0 of the next month is the last day of this one.
  return DateTime.utc(year, month + 1, 0).day;
}

/// Parses a `'HH:mm'` string. Returns null when the value is malformed.
({int hour, int minute})? parseAutoBuyTimeOfDay(String value) {
  final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(value.trim());
  if (match == null) return null;
  final hour = int.parse(match.group(1)!);
  final minute = int.parse(match.group(2)!);
  if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
  return (hour: hour, minute: minute);
}

/// Formats an hour/minute pair as `'HH:mm'`.
String formatAutoBuyTimeOfDay(int hour, int minute) {
  return '${hour.toString().padLeft(2, '0')}:'
      '${minute.toString().padLeft(2, '0')}';
}

/// Formats an hour/minute pair as a 12-hour clock label, e.g. `8:00 AM`.
String formatAutoBuyClock(int hour, int minute) {
  final suffix = hour >= 12 ? 'PM' : 'AM';
  final displayHour = hour % 12 == 0 ? 12 : hour % 12;
  return '$displayHour:${minute.toString().padLeft(2, '0')} $suffix';
}

/// Parses a `'YYYY-MM-DD'` calendar date.
DateTime? parseAutoBuyDateString(String value) {
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value.trim());
  if (match == null) return null;
  final year = int.parse(match.group(1)!);
  final month = int.parse(match.group(2)!);
  final day = int.parse(match.group(3)!);
  if (month < 1 || month > 12) return null;
  if (day < 1 || day > autoBuyDaysInMonth(year, month)) return null;
  return DateTime.utc(year, month, day);
}

/// Formats a wall-clock date as `'YYYY-MM-DD'`.
String formatAutoBuyDateString(DateTime wallClock) {
  final utc = wallClock.toUtc();
  return '${utc.year.toString().padLeft(4, '0')}-'
      '${utc.month.toString().padLeft(2, '0')}-'
      '${utc.day.toString().padLeft(2, '0')}';
}

/// The short weekday labels, Monday first.
const List<String> kAutoBuyWeekdayLabels = [
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];
