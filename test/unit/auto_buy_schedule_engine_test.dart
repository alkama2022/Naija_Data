// Unit tests for the Auto-Buy schedule engine.
//
// These mirror the backend's `test/auto_buy_schedule.test.ts` so the app
// preview and the server always agree on the next purchase time.

import 'package:data_naija_app/core/utils/auto_buy_frequency.dart';
import 'package:data_naija_app/core/utils/auto_buy_schedule_engine.dart';
import 'package:data_naija_app/core/utils/auto_buy_time.dart';
import 'package:flutter_test/flutter_test.dart';

/// Builds a UTC instant.
DateTime utc(int year, int month, int day, [int hour = 0, int minute = 0]) {
  return DateTime.utc(year, month, day, hour, minute);
}

/// The wall-clock parts of an instant inside Lagos.
({int year, int month, int day, int hour, int minute, int weekday}) localParts(
    DateTime instant) {
  final local = toAutoBuyWallClock(instant);
  return (
    year: local.year,
    month: local.month,
    day: local.day,
    hour: local.hour,
    minute: local.minute,
    weekday: local.weekday,
  );
}

/// The default spec: every day at 08:00, anchored on Monday 19 Oct 2026.
AutoBuyScheduleSpec spec({
  String frequency = 'daily',
  int interval = 1,
  AutoBuyUnit unit = AutoBuyUnit.days,
  List<int> daysOfWeek = const [],
  String timeOfDay = '08:00',
  DateTime? anchorAt,
}) {
  return AutoBuyScheduleSpec(
    frequency: frequency,
    interval: interval,
    unit: unit,
    daysOfWeek: daysOfWeek,
    timeOfDay: timeOfDay,
    timezone: kAutoBuyTimezone,
    anchorAt: anchorAt ?? utc(2026, 10, 19, 7),
  );
}

void main() {
  group('time zone handling', () {
    test('Africa/Lagos is UTC+1 all year', () {
      expect(
        toAutoBuyWallClock(utc(2026, 1, 15, 12)).hour,
        13,
      );
      expect(
        toAutoBuyWallClock(utc(2026, 7, 15, 12)).hour,
        13,
      );
    });

    test('a Lagos 08:00 slot is 07:00 UTC', () {
      final anchor = AutoBuyScheduleEngine.resolveAnchor(
        from: utc(2026, 10, 19),
        unit: AutoBuyUnit.days,
        interval: 1,
        timeOfDay: '08:00',
        startDate: '2026-10-19',
      );

      expect(anchor.toIso8601String(), '2026-10-19T07:00:00.000Z');
      expect(localParts(anchor).hour, 8);
      expect(localParts(anchor).day, 19);
    });
  });

  group('calendar date strings', () {
    test('format and parse round-trip a calendar day', () {
      for (final date in [
        DateTime.utc(2026, 1, 1),
        DateTime.utc(2026, 10, 15),
        DateTime.utc(2026, 12, 31),
      ]) {
        final encoded = formatAutoBuyDateString(date);
        final decoded = parseAutoBuyDateString(encoded);
        expect(decoded, isNotNull, reason: encoded);
        expect(decoded!.year, date.year);
        expect(decoded.month, date.month);
        expect(decoded.day, date.day);
      }
    });

    test('format drops any time of day', () {
      expect(
        formatAutoBuyDateString(DateTime.utc(2026, 10, 15, 23, 59)),
        '2026-10-15',
      );
    });

    test('parse rejects malformed and impossible dates', () {
      expect(parseAutoBuyDateString('2026-13-01'), isNull);
      expect(parseAutoBuyDateString('2026-02-30'), isNull);
      expect(parseAutoBuyDateString('not-a-date'), isNull);
    });
  });

  group('resolveAnchor', () {
    test('uses the requested start date and time', () {
      final anchor = AutoBuyScheduleEngine.resolveAnchor(
        from: utc(2026, 10, 19),
        unit: AutoBuyUnit.days,
        interval: 1,
        timeOfDay: '06:30',
        startDate: '2026-10-25',
      );

      expect(localParts(anchor).day, 25);
      expect(localParts(anchor).hour, 6);
      expect(localParts(anchor).minute, 30);
    });

    test('weekly rules anchor on the first selected weekday', () {
      // 2026-10-19 is a Monday; the first selected weekday is Wednesday.
      final anchor = AutoBuyScheduleEngine.resolveAnchor(
        from: utc(2026, 10, 19),
        unit: AutoBuyUnit.weeks,
        interval: 1,
        daysOfWeek: const [3, 5],
        timeOfDay: '08:00',
        startDate: '2026-10-19',
      );

      expect(localParts(anchor).day, 21);
      expect(localParts(anchor).hour, 8);
    });
  });

  group('computeNextRun — every N hours', () {
    test('every 2 hours advances in absolute time', () {
      final next = AutoBuyScheduleEngine.computeNextRun(
        spec(frequency: 'every_2_hours', unit: AutoBuyUnit.hours, interval: 2),
        utc(2026, 10, 19, 14),
      );
      expect(localParts(next).day, 19);
      expect(localParts(next).hour, 16);
    });

    test('every 4 hours', () {
      final next = AutoBuyScheduleEngine.computeNextRun(
        spec(frequency: 'every_4_hours', unit: AutoBuyUnit.hours, interval: 4),
        utc(2026, 10, 19, 9),
      );
      expect(localParts(next).hour, 12);
    });

    test('every 6 hours', () {
      final next = AutoBuyScheduleEngine.computeNextRun(
        spec(frequency: 'every_6_hours', unit: AutoBuyUnit.hours, interval: 6),
        utc(2026, 10, 19, 9),
      );
      expect(localParts(next).hour, 14);
    });

    test('every 12 hours rolls over to the next day', () {
      final next = AutoBuyScheduleEngine.computeNextRun(
        spec(
          frequency: 'every_12_hours',
          unit: AutoBuyUnit.hours,
          interval: 12,
        ),
        utc(2026, 10, 19, 20),
      );
      expect(localParts(next).day, 20);
      expect(localParts(next).hour, 8);
    });

    test('an hourly rule that starts in the future runs at the start time', () {
      final next = AutoBuyScheduleEngine.computeNextRun(
        spec(
          frequency: 'every_2_hours',
          unit: AutoBuyUnit.hours,
          interval: 2,
          anchorAt: utc(2026, 10, 19, 17),
        ),
        utc(2026, 10, 19, 14),
      );
      expect(localParts(next).hour, 18);
    });
  });

  group('computeNextRun — day based rules', () {
    test('every day keeps the wall-clock time', () {
      final next = AutoBuyScheduleEngine.computeNextRun(
        spec(),
        utc(2026, 10, 19, 14),
      );
      expect(localParts(next).day, 20);
      expect(localParts(next).hour, 8);
    });

    test('every day before the slot time runs the same day', () {
      final next = AutoBuyScheduleEngine.computeNextRun(
        spec(),
        utc(2026, 10, 19, 6),
      );
      expect(localParts(next).day, 19);
      expect(localParts(next).hour, 8);
    });

    test('every 2 days', () {
      final next = AutoBuyScheduleEngine.computeNextRun(
        spec(frequency: 'every_2_days', interval: 2),
        utc(2026, 10, 19, 14),
      );
      expect(localParts(next).day, 21);
    });

    test('every 3 days', () {
      final next = AutoBuyScheduleEngine.computeNextRun(
        spec(frequency: 'every_3_days', interval: 3),
        utc(2026, 10, 19, 14),
      );
      expect(localParts(next).day, 22);
    });

    test('a custom 5 day interval', () {
      final next = AutoBuyScheduleEngine.computeNextRun(
        spec(frequency: 'custom', interval: 5),
        utc(2026, 10, 19, 14),
      );
      expect(localParts(next).day, 24);
    });
  });

  group('computeNextRun — weekly rules', () {
    test('runs on the selected weekdays only', () {
      final rule = spec(
        frequency: 'weekly',
        unit: AutoBuyUnit.weeks,
        daysOfWeek: const [1, 3, 5],
      );

      final fromMonday = AutoBuyScheduleEngine.computeNextRun(
        rule,
        utc(2026, 10, 19, 8),
      );
      expect(localParts(fromMonday).day, 21);

      final fromWednesday = AutoBuyScheduleEngine.computeNextRun(
        rule,
        utc(2026, 10, 21, 8),
      );
      expect(localParts(fromWednesday).day, 23);

      final fromFriday = AutoBuyScheduleEngine.computeNextRun(
        rule,
        utc(2026, 10, 23, 8),
      );
      expect(localParts(fromFriday).day, 26);
    });

    test('every 2 weeks only fires every second week', () {
      final rule = spec(
        frequency: 'every_2_weeks',
        unit: AutoBuyUnit.weeks,
        interval: 2,
        daysOfWeek: const [1],
      );

      final first = AutoBuyScheduleEngine.computeNextRun(
        rule,
        utc(2026, 10, 19, 8),
      );
      expect(localParts(first).month, 11);
      expect(localParts(first).day, 2);

      final second = AutoBuyScheduleEngine.computeNextRun(
        rule,
        utc(2026, 11, 2, 8),
      );
      expect(localParts(second).month, 11);
      expect(localParts(second).day, 16);
    });
  });

  group('computeNextRun — monthly rules', () {
    test('repeats on the same day of the month', () {
      final next = AutoBuyScheduleEngine.computeNextRun(
        spec(frequency: 'monthly', unit: AutoBuyUnit.months),
        utc(2026, 10, 19, 14),
      );
      expect(localParts(next).year, 2026);
      expect(localParts(next).month, 11);
      expect(localParts(next).day, 19);
    });

    test('clamps to the last day of a shorter month', () {
      // 31 October -> 30 November -> 31 December -> 31 January -> 28 February.
      final rule = spec(
        frequency: 'monthly',
        unit: AutoBuyUnit.months,
        anchorAt: utc(2026, 10, 31, 7),
      );

      final november = AutoBuyScheduleEngine.computeNextRun(
        rule,
        utc(2026, 10, 31, 9),
      );
      expect(localParts(november).month, 11);
      expect(localParts(november).day, 30);

      final december = AutoBuyScheduleEngine.computeNextRun(
        rule,
        utc(2026, 11, 30, 9),
      );
      expect(localParts(december).month, 12);
      expect(localParts(december).day, 31);

      final january = AutoBuyScheduleEngine.computeNextRun(
        rule,
        utc(2026, 12, 31, 9),
      );
      expect(localParts(january).year, 2027);
      expect(localParts(january).month, 1);
      expect(localParts(january).day, 31);

      final february = AutoBuyScheduleEngine.computeNextRun(
        rule,
        utc(2027, 1, 31, 9),
      );
      expect(localParts(february).year, 2027);
      expect(localParts(february).month, 2);
      expect(localParts(february).day, 28);
    });
  });

  group('frequency catalogue', () {
    test('offers every documented frequency', () {
      final keys = AutoBuyFrequencies.all.map((o) => o.key).toList();
      expect(
          keys,
          containsAll(<String>[
            'every_2_hours',
            'every_4_hours',
            'every_6_hours',
            'every_12_hours',
            'daily',
            'every_2_days',
            'every_3_days',
            'weekly',
            'every_2_weeks',
            'monthly',
            'custom',
          ]));
    });

    test('weekly rules allow picking the weekdays', () {
      expect(
        AutoBuyFrequencies.byKey('weekly')!.supportsDaysOfWeek,
        isTrue,
      );
      expect(
        AutoBuyFrequencies.byKey('every_2_weeks')!.supportsDaysOfWeek,
        isTrue,
      );
      expect(
        AutoBuyFrequencies.byKey('daily')!.supportsDaysOfWeek,
        isFalse,
      );
    });
  });

  group('helpers', () {
    test('normalises the weekday list', () {
      expect(AutoBuyScheduleEngine.normalizeDaysOfWeek([5, 1, 3, 3, 9, 0]),
          [1, 3, 5]);
      expect(AutoBuyScheduleEngine.normalizeDaysOfWeek([]), isEmpty);
      expect(AutoBuyScheduleEngine.normalizeDaysOfWeek(null), isEmpty);
    });

    test('describes a schedule in plain language', () {
      expect(
        AutoBuyScheduleEngine.describe(
          spec(
              frequency: 'every_4_hours', unit: AutoBuyUnit.hours, interval: 4),
        ),
        'Every 4 hours from 8:00 AM',
      );
      expect(AutoBuyScheduleEngine.describe(spec()), 'Every day at 8:00 AM');
      expect(
        AutoBuyScheduleEngine.describe(
          spec(frequency: 'every_2_days', interval: 2),
        ),
        'Every 2 days at 8:00 AM',
      );
      expect(
        AutoBuyScheduleEngine.describe(
          spec(
            frequency: 'weekly',
            unit: AutoBuyUnit.weeks,
            daysOfWeek: const [1, 3, 5],
          ),
        ),
        'Mon, Wed, Fri at 8:00 AM',
      );
      expect(
        AutoBuyScheduleEngine.describe(
          spec(
            frequency: 'every_2_weeks',
            unit: AutoBuyUnit.weeks,
            interval: 2,
            daysOfWeek: const [1, 5],
          ),
        ),
        'Every 2 weeks on Mon, Fri at 8:00 AM',
      );
      expect(
        AutoBuyScheduleEngine.describe(
          spec(frequency: 'monthly', unit: AutoBuyUnit.months),
        ),
        'Every month on the 19th at 8:00 AM',
      );
    });

    test('formats a slot label in the Nigerian time zone', () {
      final label = AutoBuyScheduleEngine.formatSlotLabel(
        utc(2026, 10, 20, 7),
      );
      expect(label, 'Tue, 20 Oct 2026 · 8:00 AM WAT');
    });
  });
}
