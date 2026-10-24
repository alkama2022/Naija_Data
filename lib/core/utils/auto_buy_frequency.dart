/// The unit a schedule interval is measured in.
enum AutoBuyUnit {
  hours('hours', 'hour'),
  days('days', 'day'),
  weeks('weeks', 'week'),
  months('months', 'month');

  const AutoBuyUnit(this.key, this.singular);

  /// The value stored on the schedule and sent to the API.
  final String key;

  /// The singular form, used in sentences ("every 1 day").
  final String singular;

  static AutoBuyUnit fromKey(String key) {
    return AutoBuyUnit.values.firstWhere(
      (unit) => unit.key == key,
      orElse: () => AutoBuyUnit.days,
    );
  }
}

/// One of the purchase frequencies a customer can pick.
class AutoBuyFrequencyOption {
  const AutoBuyFrequencyOption({
    required this.key,
    required this.label,
    required this.unit,
    required this.interval,
    this.supportsDaysOfWeek = false,
    this.supportsTimeOfDay = true,
  });

  /// Stable key stored on the schedule and sent to the API.
  final String key;

  /// The label shown in the app.
  final String label;

  /// The interval unit.
  final AutoBuyUnit unit;

  /// How many units between purchases.
  final int interval;

  /// Weekly-style rules let the customer pick the weekdays.
  final bool supportsDaysOfWeek;

  /// Rules measured in days or longer run at a wall-clock time of day.
  final bool supportsTimeOfDay;
}

/// The catalogue of supported frequencies.
///
/// Mirrors `AUTO_BUY_FREQUENCIES` in the backend so both ends offer exactly
/// the same choices.
class AutoBuyFrequencies {
  const AutoBuyFrequencies._();

  static const List<AutoBuyFrequencyOption> all = [
    AutoBuyFrequencyOption(
      key: 'every_2_hours',
      label: 'Every 2 hours',
      unit: AutoBuyUnit.hours,
      interval: 2,
    ),
    AutoBuyFrequencyOption(
      key: 'every_4_hours',
      label: 'Every 4 hours',
      unit: AutoBuyUnit.hours,
      interval: 4,
    ),
    AutoBuyFrequencyOption(
      key: 'every_6_hours',
      label: 'Every 6 hours',
      unit: AutoBuyUnit.hours,
      interval: 6,
    ),
    AutoBuyFrequencyOption(
      key: 'every_12_hours',
      label: 'Every 12 hours',
      unit: AutoBuyUnit.hours,
      interval: 12,
    ),
    AutoBuyFrequencyOption(
      key: 'daily',
      label: 'Every day',
      unit: AutoBuyUnit.days,
      interval: 1,
    ),
    AutoBuyFrequencyOption(
      key: 'every_2_days',
      label: 'Every 2 days',
      unit: AutoBuyUnit.days,
      interval: 2,
    ),
    AutoBuyFrequencyOption(
      key: 'every_3_days',
      label: 'Every 3 days',
      unit: AutoBuyUnit.days,
      interval: 3,
    ),
    AutoBuyFrequencyOption(
      key: 'weekly',
      label: 'Every week',
      unit: AutoBuyUnit.weeks,
      interval: 1,
      supportsDaysOfWeek: true,
    ),
    AutoBuyFrequencyOption(
      key: 'every_2_weeks',
      label: 'Every 2 weeks',
      unit: AutoBuyUnit.weeks,
      interval: 2,
      supportsDaysOfWeek: true,
    ),
    AutoBuyFrequencyOption(
      key: 'monthly',
      label: 'Every month',
      unit: AutoBuyUnit.months,
      interval: 1,
    ),
    AutoBuyFrequencyOption(
      key: 'custom',
      label: 'Custom schedule',
      unit: AutoBuyUnit.days,
      interval: 1,
      supportsDaysOfWeek: true,
    ),
  ];

  /// The default frequency of a new rule.
  static const String defaultKey = 'daily';

  /// Looks up an option by key.
  static AutoBuyFrequencyOption? byKey(String key) {
    for (final option in all) {
      if (option.key == key) return option;
    }
    return null;
  }

  /// The minimum interval a custom schedule may use.
  static const int customIntervalMin = 1;

  /// The maximum interval a custom schedule may use.
  static const int customIntervalMax = 365;
}
