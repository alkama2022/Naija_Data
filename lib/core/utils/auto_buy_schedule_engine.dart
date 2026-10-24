import 'package:data_naija_app/core/utils/auto_buy_frequency.dart';
import 'package:data_naija_app/core/utils/auto_buy_time.dart';

/// Everything the schedule maths needs to know about a rule.
///
/// This is the Dart twin of `ScheduleSpec` in
/// `datanaija-backend/src/lib/auto_buy/schedule.ts`. Both implementations
/// must stay in sync so the app preview and the server always agree on the
/// next purchase time.
class AutoBuyScheduleSpec {
  const AutoBuyScheduleSpec({
    required this.frequency,
    required this.interval,
    required this.unit,
    required this.daysOfWeek,
    required this.timeOfDay,
    required this.timezone,
    required this.anchorAt,
  });

  /// The frequency key (`daily`, `weekly`, `custom`, …).
  final String frequency;

  /// How many units between purchases.
  final int interval;

  /// The interval unit.
  final AutoBuyUnit unit;

  /// ISO weekdays (1 = Monday … 7 = Sunday). Only used by week based rules.
  final List<int> daysOfWeek;

  /// The wall-clock time of the purchase, `'HH:mm'`.
  final String timeOfDay;

  /// The zone the wall-clock time is expressed in.
  final String timezone;

  /// The first slot of the schedule. Defines its phase.
  final DateTime anchorAt;
}

/// The schedule maths.
///
/// A schedule is anchored on its first slot. Every later slot is derived
/// from that anchor, so the schedule never drifts — even if the service was
/// unavailable for a while.
class AutoBuyScheduleEngine {
  const AutoBuyScheduleEngine._();

  /// Sorts, de-duplicates and clamps a weekday list to 1-7.
  static List<int> normalizeDaysOfWeek(List<int>? days) {
    if (days == null || days.isEmpty) return const [];
    final unique = <int>{};
    for (final day in days) {
      if (day >= 1 && day <= 7) unique.add(day);
    }
    final sorted = unique.toList()..sort();
    return sorted;
  }

  /// Resolves the anchor (phase) of a schedule.
  ///
  /// [startDate] is a `'YYYY-MM-DD'` calendar date in the schedule's own
  /// zone. [from] is the moment the rule is created.
  static DateTime resolveAnchor({
    required DateTime from,
    required AutoBuyUnit unit,
    required int interval,
    List<int> daysOfWeek = const [],
    String timeOfDay = '08:00',
    String? startDate,
  }) {
    final time = parseAutoBuyTimeOfDay(timeOfDay) ?? (hour: 8, minute: 0);

    var base = DateTime.utc(
      toAutoBuyWallClock(from).year,
      toAutoBuyWallClock(from).month,
      toAutoBuyWallClock(from).day,
    );

    final parsedStart =
        startDate == null ? null : parseAutoBuyDateString(startDate);
    if (parsedStart != null) {
      base = DateTime.utc(parsedStart.year, parsedStart.month, parsedStart.day);
    }

    // Weekly rules anchor on the first selected weekday on/after the base
    // date, so the "every N weeks" parity is well defined.
    if (unit == AutoBuyUnit.weeks) {
      final days = normalizeDaysOfWeek(daysOfWeek);
      if (days.isNotEmpty) {
        for (var offset = 0; offset <= 7; offset++) {
          final candidate = base.add(Duration(days: offset));
          if (days.contains(autoBuyIsoWeekday(candidate))) {
            base = candidate;
            break;
          }
        }
      }
    }

    final anchored = DateTime.utc(
      base.year,
      base.month,
      base.day,
      time.hour,
      time.minute,
    );
    return fromAutoBuyWallClock(anchored);
  }

  /// The first slot of [spec] that is strictly after [from].
  static DateTime computeNextRun(AutoBuyScheduleSpec spec, DateTime from) {
    switch (spec.unit) {
      case AutoBuyUnit.hours:
        return _nextHourSlot(spec, from);
      case AutoBuyUnit.days:
        return _nextDaySlot(spec, from);
      case AutoBuyUnit.weeks:
        return _nextWeekSlot(spec, from);
      case AutoBuyUnit.months:
        return _nextMonthSlot(spec, from);
    }
  }

  /// Hour based rules advance in absolute time from the anchor.
  static DateTime _nextHourSlot(
    AutoBuyScheduleSpec spec,
    DateTime from,
  ) {
    final step = Duration(hours: spec.interval < 1 ? 1 : spec.interval);
    final anchor = spec.anchorAt.toUtc();
    final now = from.toUtc();

    if (anchor.isAfter(now)) return anchor;

    final elapsed = now.difference(anchor);
    final periods = elapsed.inMinutes ~/ step.inMinutes + 1;
    return anchor.add(step * periods);
  }

  /// Day based rules keep the anchor's wall-clock time.
  static DateTime _nextDaySlot(
    AutoBuyScheduleSpec spec,
    DateTime from,
  ) {
    final anchor = toAutoBuyWallClock(spec.anchorAt);
    final now = toAutoBuyWallClock(from);
    final step = spec.interval < 1 ? 1 : spec.interval;

    final anchorDay = DateTime.utc(anchor.year, anchor.month, anchor.day);
    final nowDay = DateTime.utc(now.year, now.month, now.day);
    final daysApart = nowDay.difference(anchorDay).inDays;

    var periods = daysApart < 0 ? 0 : daysApart ~/ step;
    for (var guard = 0; guard < 400; guard++) {
      final candidate = anchor.add(Duration(days: periods * step));
      if (candidate.isAfter(now)) {
        return fromAutoBuyWallClock(candidate);
      }
      periods++;
    }
    return fromAutoBuyWallClock(anchor.add(Duration(days: periods * step)));
  }

  /// Week based rules run on the selected weekdays of every N-th week,
  /// counting from the anchor's week.
  static DateTime _nextWeekSlot(
    AutoBuyScheduleSpec spec,
    DateTime from,
  ) {
    final anchor = toAutoBuyWallClock(spec.anchorAt);
    final now = toAutoBuyWallClock(from);
    final time = parseAutoBuyTimeOfDay(spec.timeOfDay) ?? (hour: 8, minute: 0);

    final days = normalizeDaysOfWeek(spec.daysOfWeek);
    final weekdays = days.isNotEmpty ? days : <int>[autoBuyIsoWeekday(anchor)];

    final anchorWeekStart = autoBuyStartOfWeek(anchor);
    final step = spec.interval < 1 ? 1 : spec.interval;

    // 104 weeks ≈ two years of look-ahead.
    for (var week = 0; week < 104; week++) {
      final weekStart = anchorWeekStart.add(Duration(days: week * step * 7));
      for (final weekday in weekdays) {
        final candidate = DateTime.utc(
          weekStart.add(Duration(days: weekday - 1)).year,
          weekStart.add(Duration(days: weekday - 1)).month,
          weekStart.add(Duration(days: weekday - 1)).day,
          time.hour,
          time.minute,
        );
        // Slots before the anchor are not part of this schedule.
        if (candidate.isBefore(anchor)) continue;
        if (candidate.isAfter(now)) {
          return fromAutoBuyWallClock(candidate);
        }
      }
    }
    return fromAutoBuyWallClock(anchorWeekStart.add(const Duration(days: 7)));
  }

  /// Month based rules repeat on the anchor's day-of-month.
  static DateTime _nextMonthSlot(
    AutoBuyScheduleSpec spec,
    DateTime from,
  ) {
    final anchor = toAutoBuyWallClock(spec.anchorAt);
    final now = toAutoBuyWallClock(from);
    final time = parseAutoBuyTimeOfDay(spec.timeOfDay) ?? (hour: 8, minute: 0);

    final anchorYear = anchor.year;
    final anchorMonth = anchor.month;
    final anchorDay = anchor.day;
    final step = spec.interval < 1 ? 1 : spec.interval;

    final monthsBetween =
        (now.year - anchorYear) * 12 + (now.month - anchorMonth);

    var periods = monthsBetween < 0 ? 0 : monthsBetween ~/ step;
    for (var guard = 0; guard < 600; guard++) {
      final total = anchorMonth - 1 + periods * step;
      final year = anchorYear + total ~/ 12;
      final month = total % 12 + 1;
      // "The 31st" becomes "the last day" in shorter months.
      final day = anchorDay > autoBuyDaysInMonth(year, month)
          ? autoBuyDaysInMonth(year, month)
          : anchorDay;

      final candidate = DateTime.utc(year, month, day, time.hour, time.minute);
      if (candidate.isAfter(now)) {
        return fromAutoBuyWallClock(candidate);
      }
      periods++;
    }
    return fromAutoBuyWallClock(anchor);
  }

  /// A short, human readable summary of a schedule.
  static String describe(AutoBuyScheduleSpec spec) {
    final time = parseAutoBuyTimeOfDay(spec.timeOfDay);
    final timeLabel = time == null
        ? spec.timeOfDay
        : formatAutoBuyClock(time.hour, time.minute);
    final interval = spec.interval < 1 ? 1 : spec.interval;

    switch (spec.unit) {
      case AutoBuyUnit.hours:
        return 'Every $interval hour${interval == 1 ? '' : 's'}'
            '${time == null ? '' : ' from $timeLabel'}';
      case AutoBuyUnit.days:
        return interval == 1
            ? 'Every day at $timeLabel'
            : 'Every $interval days at $timeLabel';
      case AutoBuyUnit.weeks:
        final days = normalizeDaysOfWeek(spec.daysOfWeek);
        final dayLabel = days.isNotEmpty
            ? days.map((d) => kAutoBuyWeekdayLabels[d - 1]).join(', ')
            : 'the same weekday';
        return interval == 1
            ? '$dayLabel at $timeLabel'
            : 'Every $interval weeks on $dayLabel at $timeLabel';
      case AutoBuyUnit.months:
        final anchor = toAutoBuyWallClock(spec.anchorAt);
        return interval == 1
            ? 'Every month on the ${_ordinal(anchor.day)} at $timeLabel'
            : 'Every $interval months on the ${_ordinal(anchor.day)} '
                'at $timeLabel';
    }
  }

  /// Formats an instant as a local label, e.g.
  /// `Tue, 20 Oct 2026 · 8:00 AM WAT`.
  static String formatSlotLabel(DateTime instant) {
    final local = toAutoBuyWallClock(instant);
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final weekday = kAutoBuyWeekdayLabels[autoBuyIsoWeekday(local) - 1];
    final clock = formatAutoBuyClock(local.hour, local.minute);
    return '$weekday, ${local.day} ${months[local.month - 1]} ${local.year} · '
        '$clock WAT';
  }

  /// "1st", "2nd", "3rd", "4th" …
  static String _ordinal(int value) {
    final mod100 = value % 100;
    if (mod100 >= 11 && mod100 <= 13) return '${value}th';
    switch (value % 10) {
      case 1:
        return '${value}st';
      case 2:
        return '${value}nd';
      case 3:
        return '${value}rd';
      default:
        return '${value}th';
    }
  }
}
