import 'package:data_naija_app/core/utils/auto_buy_frequency.dart';
import 'package:data_naija_app/core/utils/auto_buy_schedule_engine.dart';
import 'package:data_naija_app/core/utils/auto_buy_time.dart';

/// A customer created Auto-Buy rule.
///
/// "Buy this bundle, for this number, on this schedule."
///
/// The JSON shape is the same one the backend returns, so the app can be
/// pointed at the API without changing the model.
class AutoBuySchedule {
  const AutoBuySchedule({
    required this.id,
    required this.network,
    required this.planType,
    required this.planGb,
    required this.planDays,
    required this.price,
    required this.phone,
    required this.frequency,
    required this.interval,
    required this.unit,
    required this.daysOfWeek,
    required this.timeOfDay,
    required this.timezone,
    required this.status,
    required this.anchorAt,
    required this.nextRunAt,
    required this.createdAt,
    this.lastRunAt,
    this.consecutiveFailures = 0,
    this.maxRetries = 3,
  });

  final String id;
  final String network;

  /// The bundle family, e.g. `SME`.
  final String planType;

  /// The bundle size, e.g. `1GB`.
  final String planGb;

  /// The bundle validity, e.g. `30 Days`.
  final String planDays;

  /// The price in Naira.
  final int price;

  /// The recipient number.
  final String phone;

  /// The frequency key, e.g. `daily`.
  final String frequency;

  /// How many units between purchases.
  final int interval;

  /// The interval unit key, e.g. `days`.
  final String unit;

  /// ISO weekdays (1 = Monday … 7 = Sunday).
  final List<int> daysOfWeek;

  /// The wall-clock time of the purchase, `'HH:mm'`.
  final String timeOfDay;

  /// The zone the wall-clock time is expressed in.
  final String timezone;

  /// `Active` or `Paused`.
  final String status;

  /// The first slot of the schedule.
  final DateTime anchorAt;

  /// The next slot that will be attempted.
  final DateTime nextRunAt;

  /// When the rule last ran.
  final DateTime? lastRunAt;

  /// How many attempts failed in a row.
  final int consecutiveFailures;

  /// How many attempts are made before the rule is paused.
  final int maxRetries;

  final DateTime createdAt;

  /// The interval unit as an enum.
  AutoBuyUnit get unitType => AutoBuyUnit.fromKey(unit);

  /// Whether the rule is currently running.
  bool get isActive => status == 'Active';

  /// A short description of the schedule, e.g. `Every day at 8:00 AM`.
  String get summary => AutoBuyScheduleEngine.describe(spec);

  /// The next purchase as a friendly local label.
  String get nextRunLabel => AutoBuyScheduleEngine.formatSlotLabel(nextRunAt);

  /// The last purchase as a friendly local label.
  String? get lastRunLabel => lastRunAt == null
      ? null
      : AutoBuyScheduleEngine.formatSlotLabel(lastRunAt!);

  /// The maths input for the schedule engine.
  AutoBuyScheduleSpec get spec => AutoBuyScheduleSpec(
        frequency: frequency,
        interval: interval,
        unit: unitType,
        daysOfWeek: daysOfWeek,
        timeOfDay: timeOfDay,
        timezone: timezone,
        anchorAt: anchorAt,
      );

  /// The bundle description, e.g. `SME · 1GB - 30 Days`.
  String get bundleLabel => '$planType · $planGb - $planDays';

  AutoBuySchedule copyWith({
    String? network,
    String? planType,
    String? planGb,
    String? planDays,
    int? price,
    String? phone,
    String? frequency,
    int? interval,
    String? unit,
    List<int>? daysOfWeek,
    String? timeOfDay,
    String? timezone,
    String? status,
    DateTime? anchorAt,
    DateTime? nextRunAt,
    DateTime? lastRunAt,
    int? consecutiveFailures,
    int? maxRetries,
  }) {
    return AutoBuySchedule(
      id: id,
      network: network ?? this.network,
      planType: planType ?? this.planType,
      planGb: planGb ?? this.planGb,
      planDays: planDays ?? this.planDays,
      price: price ?? this.price,
      phone: phone ?? this.phone,
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      unit: unit ?? this.unit,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      timezone: timezone ?? this.timezone,
      status: status ?? this.status,
      anchorAt: anchorAt ?? this.anchorAt,
      nextRunAt: nextRunAt ?? this.nextRunAt,
      lastRunAt: lastRunAt ?? this.lastRunAt,
      consecutiveFailures: consecutiveFailures ?? this.consecutiveFailures,
      maxRetries: maxRetries ?? this.maxRetries,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'network': network,
        'planType': planType,
        'planGb': planGb,
        'planDays': planDays,
        'price': price,
        'phone': phone,
        'frequency': frequency,
        'interval': interval,
        'unit': unit,
        'daysOfWeek': daysOfWeek,
        'timeOfDay': timeOfDay,
        'timezone': timezone,
        'status': status,
        'anchorAt': anchorAt.toUtc().toIso8601String(),
        'nextRunAt': nextRunAt.toUtc().toIso8601String(),
        'lastRunAt': lastRunAt?.toUtc().toIso8601String(),
        'consecutiveFailures': consecutiveFailures,
        'maxRetries': maxRetries,
        'createdAt': createdAt.toUtc().toIso8601String(),
      };

  factory AutoBuySchedule.fromJson(Map<String, dynamic> json) {
    return AutoBuySchedule(
      id: json['id'] as String,
      network: json['network'] as String,
      planType: json['planType'] as String,
      planGb: json['planGb'] as String,
      planDays: json['planDays'] as String,
      price: (json['price'] as num).toInt(),
      phone: json['phone'] as String,
      frequency: json['frequency'] as String,
      interval: (json['interval'] as num?)?.toInt() ?? 1,
      unit: json['unit'] as String? ?? 'days',
      daysOfWeek: (json['daysOfWeek'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      timeOfDay: json['timeOfDay'] as String? ?? '08:00',
      timezone: json['timezone'] as String? ?? kAutoBuyTimezone,
      status: json['status'] as String? ?? 'Active',
      anchorAt: DateTime.parse(json['anchorAt'] as String).toUtc(),
      nextRunAt: DateTime.parse(json['nextRunAt'] as String).toUtc(),
      lastRunAt: json['lastRunAt'] == null
          ? null
          : DateTime.parse(json['lastRunAt'] as String).toUtc(),
      consecutiveFailures: (json['consecutiveFailures'] as num?)?.toInt() ?? 0,
      maxRetries: (json['maxRetries'] as num?)?.toInt() ?? 3,
      createdAt: DateTime.parse(json['createdAt'] as String).toUtc(),
    );
  }
}
