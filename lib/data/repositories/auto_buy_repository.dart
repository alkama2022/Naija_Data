import 'dart:convert';

import 'package:data_naija_app/core/utils/auto_buy_frequency.dart';
import 'package:data_naija_app/core/utils/auto_buy_schedule_engine.dart';
import 'package:data_naija_app/core/utils/auto_buy_time.dart';
import 'package:data_naija_app/core/utils/phone_validator.dart';
import 'package:data_naija_app/core/utils/storage_service.dart';
import 'package:data_naija_app/data/mock/mock_data.dart';
import 'package:data_naija_app/data/models/auto_buy_execution.dart';
import 'package:data_naija_app/data/models/auto_buy_schedule.dart';
import 'package:data_naija_app/data/models/data_plan.dart';
import 'package:data_naija_app/data/repositories/app_repository.dart';
import 'package:flutter/foundation.dart';

/// Stores and runs the customer's Auto-Buy rules.
///
/// The rules live in the app's local storage, exactly like the rest of this
/// demo frontend's state. The **server** owns the real schedule, see
/// `datanaija-backend/src/lib/auto_buy/runner.ts`, and the rules created
/// here use the exact same contract, so the app can be pointed at the API
/// without changing this class.
///
/// The execution rules below mirror the backend one-for-one:
///  1. one attempt per (rule, slot), so a slot is never charged twice;
///  2. the bundle price and availability are re-checked before buying;
///  3. the wallet is never allowed to go negative;
///  4. a purchase is only successful once it is confirmed and recorded.
class AutoBuyRepository extends ChangeNotifier {
  AutoBuyRepository({required this.wallet});

  /// The wallet the automatic purchases are paid from.
  final AppRepository wallet;

  final List<AutoBuySchedule> _schedules = [];
  final List<AutoBuyExecution> _executions = [];

  /// Slots that are older than this are skipped instead of executed, so the
  /// customer is never charged for a purchase that was missed.
  static const int graceMinutes = 30;

  /// How many attempts are made before a rule is paused.
  static const int defaultMaxRetries = 3;

  /// All rules, newest first.
  List<AutoBuySchedule> get schedules => List.unmodifiable(_schedules);

  /// Every recorded attempt, newest first.
  List<AutoBuyExecution> get executions => List.unmodifiable(_executions);

  /// The active rules.
  List<AutoBuySchedule> get activeSchedules =>
      _schedules.where((s) => s.isActive).toList();

  /// Loads the rules from local storage. Safe to call more than once.
  Future<void> load() async {
    final raw = StorageService.getString(_storageKey);
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      final scheduleJson = (decoded['schedules'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      final executionJson = (decoded['executions'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();

      _schedules
        ..clear()
        ..addAll(scheduleJson.map(AutoBuySchedule.fromJson));
      _executions
        ..clear()
        ..addAll(executionJson.map(AutoBuyExecution.fromJson));
      notifyListeners();
    } catch (_) {
      // Corrupted storage must never stop the app from starting.
      _schedules.clear();
      _executions.clear();
    }
  }

  /// Persists the rules to local storage.
  ///
  /// A storage failure must never lose the in-memory rules or interrupt a
  /// purchase, so errors are swallowed here.
  Future<void> save() async {
    try {
      final payload = jsonEncode({
        'schedules': _schedules.map((s) => s.toJson()).toList(),
        'executions': _executions.map((e) => e.toJson()).toList(),
      });
      await StorageService.setString(_storageKey, payload);
    } catch (_) {
      // Keep the rules in memory; the next save will try again.
    }
  }

  /// A rule by id.
  AutoBuySchedule? findById(String id) {
    for (final schedule in _schedules) {
      if (schedule.id == id) return schedule;
    }
    return null;
  }

  /// Overrides the next purchase time of a rule.
  ///
  /// Test-only helper, used to simulate a rule that has come due.
  void setNextRunAt(String id, DateTime nextRunAt) {
    final index = _schedules.indexWhere((s) => s.id == id);
    if (index == -1) return;
    _schedules[index] = _schedules[index].copyWith(nextRunAt: nextRunAt);
    notifyListeners();
  }

  /// The recorded attempts of a rule, newest first.
  List<AutoBuyExecution> executionsFor(String scheduleId) {
    final result = _executions
        .where((execution) => execution.scheduleId == scheduleId)
        .toList();
    result.sort((a, b) => b.scheduledFor.compareTo(a.scheduledFor));
    return result;
  }

  /// Creates a rule and activates it.
  Future<AutoBuySchedule> create({
    required String network,
    required String planType,
    required String planGb,
    required String planDays,
    required int price,
    required String phone,
    required String frequency,
    required int interval,
    required AutoBuyUnit unit,
    required List<int> daysOfWeek,
    required String timeOfDay,
    String? startDate,
    int maxRetries = defaultMaxRetries,
  }) async {
    final now = DateTime.now().toUtc();

    final anchorAt = AutoBuyScheduleEngine.resolveAnchor(
      from: now,
      unit: unit,
      interval: interval,
      daysOfWeek: daysOfWeek,
      timeOfDay: timeOfDay,
      startDate: startDate,
    );

    final spec = AutoBuyScheduleSpec(
      frequency: frequency,
      interval: interval,
      unit: unit,
      daysOfWeek: daysOfWeek,
      timeOfDay: timeOfDay,
      timezone: kAutoBuyTimezone,
      anchorAt: anchorAt,
    );

    final schedule = AutoBuySchedule(
      id: _newId(),
      network: network,
      planType: planType,
      planGb: planGb,
      planDays: planDays,
      price: price,
      phone: phone,
      frequency: frequency,
      interval: interval,
      unit: unit.key,
      daysOfWeek: daysOfWeek,
      timeOfDay: timeOfDay,
      timezone: kAutoBuyTimezone,
      status: 'Active',
      anchorAt: anchorAt,
      nextRunAt: AutoBuyScheduleEngine.computeNextRun(spec, now),
      createdAt: now,
      maxRetries: maxRetries,
    );

    _schedules.insert(0, schedule);
    await save();
    notifyListeners();
    return schedule;
  }

  /// Edits a rule. The schedule is recalculated from the new values.
  Future<AutoBuySchedule> update(
    String id, {
    String? network,
    String? planType,
    String? planGb,
    String? planDays,
    int? price,
    String? phone,
    String? frequency,
    int? interval,
    AutoBuyUnit? unit,
    List<int>? daysOfWeek,
    String? timeOfDay,
    String? startDate,
  }) async {
    final index = _schedules.indexWhere((s) => s.id == id);
    if (index == -1) {
      throw StateError('Auto-Buy schedule not found: $id');
    }

    final existing = _schedules[index];
    final now = DateTime.now().toUtc();

    final newFrequency = frequency ?? existing.frequency;
    final newInterval = interval ?? existing.interval;
    final newUnit = unit ?? existing.unitType;
    final newDays = daysOfWeek ?? existing.daysOfWeek;
    final newTime = timeOfDay ?? existing.timeOfDay;

    final anchorAt = AutoBuyScheduleEngine.resolveAnchor(
      from: now,
      unit: newUnit,
      interval: newInterval,
      daysOfWeek: newDays,
      timeOfDay: newTime,
      startDate: startDate,
    );

    final spec = AutoBuyScheduleSpec(
      frequency: newFrequency,
      interval: newInterval,
      unit: newUnit,
      daysOfWeek: newDays,
      timeOfDay: newTime,
      timezone: kAutoBuyTimezone,
      anchorAt: anchorAt,
    );

    final updated = existing.copyWith(
      network: network,
      planType: planType,
      planGb: planGb,
      planDays: planDays,
      price: price,
      phone: phone,
      frequency: newFrequency,
      interval: newInterval,
      unit: newUnit.key,
      daysOfWeek: newDays,
      timeOfDay: newTime,
      anchorAt: anchorAt,
      nextRunAt: AutoBuyScheduleEngine.computeNextRun(spec, now),
      consecutiveFailures: 0,
    );

    _schedules[index] = updated;
    await save();
    notifyListeners();
    return updated;
  }

  /// Pauses or resumes a rule.
  Future<AutoBuySchedule> setStatus(String id, String status) async {
    final index = _schedules.indexWhere((s) => s.id == id);
    if (index == -1) {
      throw StateError('Auto-Buy schedule not found: $id');
    }

    var updated = _schedules[index].copyWith(status: status);

    if (status == 'Active') {
      // A resumed rule starts again from the next upcoming slot.
      final now = DateTime.now().toUtc();
      updated = updated.copyWith(
        nextRunAt: AutoBuyScheduleEngine.computeNextRun(updated.spec, now),
        consecutiveFailures: 0,
      );
    }

    _schedules[index] = updated;
    await save();
    notifyListeners();
    return updated;
  }

  /// Deletes a rule and its history.
  Future<void> delete(String id) async {
    _schedules.removeWhere((schedule) => schedule.id == id);
    _executions.removeWhere((execution) => execution.scheduleId == id);
    await save();
    notifyListeners();
  }

  /// Runs every rule that is due at [now].
  ///
  /// Returns the attempts that were made. This is the local mirror of the
  /// backend scheduler; in production the server runs the purchases.
  Future<List<AutoBuyExecution>> runDueSchedules({DateTime? now}) async {
    final moment = (now ?? DateTime.now()).toUtc();
    final results = <AutoBuyExecution>[];

    for (final schedule in List<AutoBuySchedule>.from(_schedules)) {
      if (!schedule.isActive) continue;
      if (schedule.nextRunAt.isAfter(moment)) continue;

      final outcome = await _executeSlot(schedule, schedule.nextRunAt, moment);
      results.add(outcome.execution);
    }

    if (results.isNotEmpty) {
      await save();
      notifyListeners();
    }
    return results;
  }

  /// Executes a single slot of a rule.
  Future<_SlotOutcome> _executeSlot(
    AutoBuySchedule schedule,
    DateTime slot,
    DateTime now,
  ) async {
    // 1. Idempotency: one attempt per (rule, slot).
    final existing = _findExecution(schedule.id, slot);

    if (existing != null && existing.status == 'Successful') {
      await _advance(schedule, slot, now);
      return _SlotOutcome(existing, 'already-completed');
    }

    if (existing != null &&
        existing.status == 'Failed' &&
        existing.attempt >= schedule.maxRetries) {
      await _advance(schedule, slot, now);
      return _SlotOutcome(existing, 'retries-exhausted');
    }

    // 2. A missed slot is skipped, never charged.
    if (now.difference(slot) > const Duration(minutes: graceMinutes)) {
      final skipped = (existing ??
              AutoBuyExecution(
                id: _newId(),
                scheduleId: schedule.id,
                scheduledFor: slot,
                status: 'Pending',
                attempt: 1,
              ))
          .copyWith(
        status: 'Skipped',
        error: 'Missed while the service was unavailable.',
      );
      _recordExecution(skipped);
      await _advance(schedule, slot, now);
      return _SlotOutcome(skipped, 'missed');
    }

    final attempt = (existing?.attempt ?? 0) + 1;
    var execution = (existing ??
            AutoBuyExecution(
              id: _newId(),
              scheduleId: schedule.id,
              scheduledFor: slot,
              status: 'Pending',
              attempt: attempt,
            ))
        .copyWith(status: 'Pending', attempt: attempt, error: null);
    _recordExecution(execution);

    // 3. Re-check the price and availability.
    final plan = _findPlan(
      schedule.planType,
      schedule.planGb,
      schedule.planDays,
    );
    if (plan == null) {
      return _fail(
        schedule,
        execution,
        slot,
        now,
        'This bundle is no longer available.',
        _FailureKind.unavailable,
      );
    }

    final price = plan.price;

    // 4. Balance check before anything is bought.
    if (!wallet.canAfford(price)) {
      return _fail(
        schedule,
        execution,
        slot,
        now,
        'Not enough balance. Fund your wallet so the automatic purchase can '
        'continue.',
        _FailureKind.insufficientFunds,
      );
    }

    // 5. Provider delivery.
    if (!isValidNigerianPhone(schedule.phone)) {
      return _fail(
        schedule,
        execution,
        slot,
        now,
        'Invalid recipient number.',
        _FailureKind.provider,
      );
    }

    // 6. Charge the wallet and record the transaction.
    final ref = buildExecutionRef(schedule.id, slot);
    final transaction = wallet.purchaseDataAutoBuy(
      network: schedule.network,
      type: '${schedule.planGb} - ${schedule.planDays}',
      price: price,
      phone: schedule.phone,
      ref: ref,
    );

    if (transaction == null) {
      // The balance changed between the check and the debit.
      return _fail(
        schedule,
        execution,
        slot,
        now,
        'Not enough balance. Fund your wallet so the automatic purchase can '
        'continue.',
        _FailureKind.insufficientFunds,
      );
    }

    execution = execution.copyWith(
      status: 'Successful',
      amount: price,
      ref: ref,
      error: null,
    );
    _recordExecution(execution);

    await _advance(schedule, slot, now, resetFailures: true);
    wallet.addNotification(
      title: 'Auto-Buy successful',
      body: 'Your ${schedule.network} ${schedule.planGb} was delivered '
          'automatically to ${schedule.phone}.',
      letter: 'D',
    );

    return _SlotOutcome(execution, 'successful');
  }

  /// Records a failed attempt and applies the retry policy.
  Future<_SlotOutcome> _fail(
    AutoBuySchedule schedule,
    AutoBuyExecution execution,
    DateTime slot,
    DateTime now,
    String message,
    _FailureKind kind,
  ) async {
    final failed = execution.copyWith(status: 'Failed', error: message);
    _recordExecution(failed);

    final failures = schedule.consecutiveFailures + 1;
    final canRetry =
        failures < schedule.maxRetries && failed.attempt < schedule.maxRetries;

    if (canRetry) {
      // Retry the *same* logical slot so the idempotency key, and the
      // transaction reference, stay stable across attempts.
      final delay = _retryDelay(kind, failed.attempt);
      _updateSchedule(
        schedule.id,
        nextRunAt: slot.add(delay),
        lastRunAt: now,
        consecutiveFailures: failures,
      );
    } else {
      // Give up: pause the rule so nothing is charged unexpectedly.
      _updateSchedule(
        schedule.id,
        nextRunAt: _nextSlot(schedule, slot),
        lastRunAt: now,
        consecutiveFailures: failures,
        status: 'Paused',
      );
    }

    wallet.addNotification(
      title: 'Auto-Buy failed',
      body: message,
      letter: 'D',
    );

    return _SlotOutcome(failed, 'failed');
  }

  /// Moves a rule on to its next regular slot.
  Future<void> _advance(
    AutoBuySchedule schedule,
    DateTime slot,
    DateTime now, {
    bool resetFailures = false,
  }) async {
    _updateSchedule(
      schedule.id,
      nextRunAt: _nextSlot(schedule, slot),
      lastRunAt: now,
      consecutiveFailures: resetFailures ? 0 : null,
    );
  }

  /// The next regular slot of a rule.
  DateTime _nextSlot(AutoBuySchedule schedule, DateTime slot) {
    return AutoBuyScheduleEngine.computeNextRun(schedule.spec, slot);
  }

  void _updateSchedule(
    String id, {
    DateTime? nextRunAt,
    DateTime? lastRunAt,
    int? consecutiveFailures,
    String? status,
  }) {
    final index = _schedules.indexWhere((s) => s.id == id);
    if (index == -1) return;
    _schedules[index] = _schedules[index].copyWith(
      nextRunAt: nextRunAt,
      lastRunAt: lastRunAt,
      consecutiveFailures: consecutiveFailures,
      status: status,
    );
  }

  void _recordExecution(AutoBuyExecution execution) {
    final index = _executions.indexWhere((e) => e.id == execution.id);
    if (index == -1) {
      _executions.insert(0, execution);
    } else {
      _executions[index] = execution;
    }
  }

  AutoBuyExecution? _findExecution(String scheduleId, DateTime slot) {
    for (final execution in _executions) {
      if (execution.scheduleId == scheduleId &&
          execution.scheduledFor.toUtc() == slot.toUtc()) {
        return execution;
      }
    }
    return null;
  }

  /// Looks the bundle up in the catalogue to re-check price and
  /// availability.
  DataPlanModel? _findPlan(String type, String gb, String days) {
    final config = MockData.dataTypes[type];
    if (config == null) return null;
    for (final plan in config.plans) {
      if (plan.gb == gb && plan.days == days) return plan;
    }
    return null;
  }

  /// The back-off before the next attempt of a failed slot.
  static Duration _retryDelay(_FailureKind kind, int attempt) {
    if (kind == _FailureKind.insufficientFunds) {
      return const Duration(hours: 6);
    }
    const delays = [15, 30, 60];
    final index = (attempt - 1).clamp(0, delays.length - 1);
    return Duration(minutes: delays[index]);
  }

  static const String _storageKey = 'auto_buy_schedules';

  static int _sequence = 0;

  static String _newId() {
    _sequence++;
    return 'ab-${DateTime.now().microsecondsSinceEpoch}-$_sequence';
  }
}

/// Why an attempt failed. Drives the retry policy.
enum _FailureKind { provider, insufficientFunds, unavailable }

/// The result of a single slot attempt.
class _SlotOutcome {
  const _SlotOutcome(this.execution, this.reason);

  final AutoBuyExecution execution;
  final String reason;
}

/// Builds the deterministic transaction reference for a scheduled slot.
///
/// The same slot always produces the same reference, so a repeated attempt
/// can never charge the customer twice.
String buildExecutionRef(String scheduleId, DateTime slot) {
  final cleaned = scheduleId.replaceAll('-', '');
  final schedulePart = cleaned
      .substring(0, cleaned.length < 8 ? cleaned.length : 8)
      .toUpperCase();
  final slotPart =
      slot.toUtc().millisecondsSinceEpoch.toRadixString(36).toUpperCase();
  return 'DNA$schedulePart$slotPart';
}
