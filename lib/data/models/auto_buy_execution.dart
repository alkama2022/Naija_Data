import 'package:data_naija_app/core/utils/auto_buy_schedule_engine.dart';

/// One attempt of an Auto-Buy rule.
///
/// Every purchase attempt — successful, failed or skipped — is recorded so
/// the customer can see exactly what happened and when.
class AutoBuyExecution {
  const AutoBuyExecution({
    required this.id,
    required this.scheduleId,
    required this.scheduledFor,
    required this.status,
    required this.attempt,
    this.amount = 0,
    this.ref,
    this.error,
  });

  final String id;
  final String scheduleId;

  /// The slot this attempt belongs to.
  final DateTime scheduledFor;

  /// `Pending`, `Successful`, `Failed` or `Skipped`.
  final String status;

  /// How many times this slot was attempted.
  final int attempt;

  /// The amount charged (0 when nothing was charged).
  final int amount;

  /// The transaction reference, when the purchase succeeded.
  final String? ref;

  /// Why the attempt failed.
  final String? error;

  /// The attempt as a friendly local label.
  String get slotLabel => AutoBuyScheduleEngine.formatSlotLabel(scheduledFor);

  AutoBuyExecution copyWith({
    String? status,
    int? attempt,
    int? amount,
    String? ref,
    String? error,
  }) {
    return AutoBuyExecution(
      id: id,
      scheduleId: scheduleId,
      scheduledFor: scheduledFor,
      status: status ?? this.status,
      attempt: attempt ?? this.attempt,
      amount: amount ?? this.amount,
      ref: ref ?? this.ref,
      error: error ?? this.error,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'scheduleId': scheduleId,
        'scheduledFor': scheduledFor.toUtc().toIso8601String(),
        'status': status,
        'attempt': attempt,
        'amount': amount,
        'ref': ref,
        'error': error,
      };

  factory AutoBuyExecution.fromJson(Map<String, dynamic> json) {
    return AutoBuyExecution(
      id: json['id'] as String,
      scheduleId: json['scheduleId'] as String,
      scheduledFor: DateTime.parse(json['scheduledFor'] as String).toUtc(),
      status: json['status'] as String? ?? 'Pending',
      attempt: (json['attempt'] as num?)?.toInt() ?? 1,
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      ref: json['ref'] as String?,
      error: json['error'] as String?,
    );
  }
}
