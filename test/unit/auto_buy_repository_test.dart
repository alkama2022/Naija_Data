// Unit tests for the Auto-Buy repository.
//
// They cover the money-safety rules the feature depends on: the wallet is
// never charged twice for the same slot, it never goes negative, a failed
// purchase is not charged, and every attempt is recorded.

import 'package:data_naija_app/core/utils/auto_buy_frequency.dart';
import 'package:data_naija_app/core/utils/storage_service.dart';
import 'package:data_naija_app/data/models/auto_buy_schedule.dart';
import 'package:data_naija_app/data/repositories/app_repository.dart';
import 'package:data_naija_app/data/repositories/auto_buy_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Creates a repository whose wallet holds exactly [balance] naira.
({AutoBuyRepository repository, AppRepository wallet}) buildRepository({
  int balance = 5000,
}) {
  final wallet = AppRepository();
  wallet.setBalance(balance);
  return (repository: AutoBuyRepository(wallet: wallet), wallet: wallet);
}

/// Creates an active rule.
Future<AutoBuySchedule> createSchedule(
  AutoBuyRepository repository, {
  int price = 300,
  String planGb = '1GB',
  String planDays = '30 Days',
  int maxRetries = 3,
  String phone = '08012345678',
  String frequency = 'daily',
  AutoBuyUnit unit = AutoBuyUnit.days,
  List<int> daysOfWeek = const [],
}) {
  return repository.create(
    network: 'MTN',
    planType: 'SME',
    planGb: planGb,
    planDays: planDays,
    price: price,
    phone: phone,
    frequency: frequency,
    interval: 1,
    unit: unit,
    daysOfWeek: daysOfWeek,
    timeOfDay: '08:00',
    maxRetries: maxRetries,
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
  });

  group('creating and editing schedules', () {
    test('creates an active rule with a next purchase in the future', () async {
      final repo = buildRepository().repository;

      final schedule = await createSchedule(repo);

      expect(repo.schedules, hasLength(1));
      expect(schedule.isActive, isTrue);
      expect(schedule.price, 300);
      expect(schedule.summary, 'Every day at 8:00 AM');
      expect(schedule.nextRunAt.isAfter(DateTime.now().toUtc()), isTrue);
    });

    test('edits a rule and recalculates the schedule', () async {
      final repo = buildRepository().repository;
      final schedule = await createSchedule(repo);

      final updated = await repo.update(
        schedule.id,
        planGb: '2GB',
        planDays: '30 Days',
        price: 600,
        frequency: 'weekly',
        unit: AutoBuyUnit.weeks,
        daysOfWeek: const [1, 3, 5],
        timeOfDay: '20:00',
      );

      expect(updated.planGb, '2GB');
      expect(updated.price, 600);
      expect(updated.daysOfWeek, [1, 3, 5]);
      expect(updated.summary, 'Mon, Wed, Fri at 8:00 PM');
      expect(repo.findById(schedule.id)!.planGb, '2GB');
    });

    test('pauses and resumes a rule', () async {
      final repo = buildRepository().repository;
      final schedule = await createSchedule(repo);

      final paused = await repo.setStatus(schedule.id, 'Paused');
      expect(paused.isActive, isFalse);
      expect(repo.activeSchedules, isEmpty);

      final resumed = await repo.setStatus(schedule.id, 'Active');
      expect(resumed.isActive, isTrue);
      expect(resumed.nextRunAt.isAfter(DateTime.now().toUtc()), isTrue);
    });

    test('deletes a rule and its history', () async {
      final repo = buildRepository().repository;
      final schedule = await createSchedule(repo);

      await repo.delete(schedule.id);

      expect(repo.schedules, isEmpty);
      expect(repo.findById(schedule.id), isNull);
      expect(repo.executionsFor(schedule.id), isEmpty);
    });
  });

  group('executing a due schedule', () {
    test('charges the wallet, records the transaction and advances', () async {
      final setup = buildRepository(balance: 5000);
      final repo = setup.repository;
      final wallet = setup.wallet;

      final schedule = await createSchedule(repo);
      final due = DateTime.now().toUtc().subtract(const Duration(minutes: 1));
      repo.setNextRunAt(schedule.id, due);

      final executed = await repo.runDueSchedules(now: due);

      expect(executed, hasLength(1));
      expect(executed.first.status, 'Successful');
      expect(executed.first.amount, 300);
      expect(wallet.balance, 4700);

      // The transaction is in the history with the auto-buy title.
      final autoBuyTransactions = wallet.transactions
          .where((t) => t.title == 'Auto-Buy Data Purchase')
          .toList();
      expect(autoBuyTransactions, hasLength(1));
      expect(autoBuyTransactions.first.amount, -300);
      expect(autoBuyTransactions.first.ref, executed.first.ref);

      // The customer is notified.
      expect(
        wallet.notifications.any((n) => n.title == 'Auto-Buy successful'),
        isTrue,
      );

      // The rule moved on to the next slot.
      expect(repo.findById(schedule.id)!.nextRunAt.isAfter(due), isTrue);
      expect(repo.executionsFor(schedule.id), hasLength(1));
    });

    test('never charges twice for the same slot', () async {
      final setup = buildRepository(balance: 5000);
      final repo = setup.repository;
      final wallet = setup.wallet;

      final schedule = await createSchedule(repo);
      final due = DateTime.now().toUtc().subtract(const Duration(minutes: 1));
      repo.setNextRunAt(schedule.id, due);

      await repo.runDueSchedules(now: due);
      final balanceAfterFirst = wallet.balance;
      expect(balanceAfterFirst, 4700);

      // A second run for the very same slot must not charge again.
      repo.setNextRunAt(schedule.id, due);
      await repo.runDueSchedules(now: due);

      expect(wallet.balance, balanceAfterFirst);
      expect(
        wallet.transactions
            .where((t) => t.title == 'Auto-Buy Data Purchase')
            .length,
        1,
      );
    });

    test('does not purchase when the wallet is short', () async {
      final setup = buildRepository(balance: 100);
      final repo = setup.repository;
      final wallet = setup.wallet;

      final schedule = await createSchedule(repo);
      final due = DateTime.now().toUtc().subtract(const Duration(minutes: 1));
      repo.setNextRunAt(schedule.id, due);

      final executed = await repo.runDueSchedules(now: due);

      expect(executed.first.status, 'Failed');
      expect(executed.first.amount, 0);
      expect(wallet.balance, 100); // never negative
      expect(
        wallet.transactions
            .where((t) => t.title == 'Auto-Buy Data Purchase')
            .isEmpty,
        isTrue,
      );
      expect(
        wallet.notifications.any((n) => n.title == 'Auto-Buy failed'),
        isTrue,
      );

      // The rule is retried in six hours, not paused straight away.
      final reloaded = repo.findById(schedule.id)!;
      expect(reloaded.isActive, isTrue);
      expect(reloaded.consecutiveFailures, 1);
      expect(reloaded.nextRunAt.difference(due).inMinutes, greaterThan(300));
    });

    test('does not purchase a bundle that is no longer available', () async {
      final setup = buildRepository(balance: 5000);
      final repo = setup.repository;
      final wallet = setup.wallet;

      final schedule =
          await createSchedule(repo, planGb: '99GB'); // not in the catalogue
      final due = DateTime.now().toUtc().subtract(const Duration(minutes: 1));
      repo.setNextRunAt(schedule.id, due);

      final executed = await repo.runDueSchedules(now: due);

      expect(executed.first.status, 'Failed');
      expect(executed.first.error, contains('no longer available'));
      expect(wallet.balance, 5000);
    });

    test('pauses the rule once the retries are used up', () async {
      final setup = buildRepository(balance: 100);
      final repo = setup.repository;

      final schedule = await createSchedule(repo, maxRetries: 1);
      final due = DateTime.now().toUtc().subtract(const Duration(minutes: 1));
      repo.setNextRunAt(schedule.id, due);

      await repo.runDueSchedules(now: due);

      final reloaded = repo.findById(schedule.id)!;
      expect(reloaded.isActive, isFalse);
      expect(reloaded.consecutiveFailures, 1);
    });

    test('skips a slot that was missed instead of charging for it', () async {
      final setup = buildRepository(balance: 5000);
      final repo = setup.repository;
      final wallet = setup.wallet;

      final schedule = await createSchedule(repo);
      // The service was down for six hours, so the slot is long past.
      final missedSlot =
          DateTime.now().toUtc().subtract(const Duration(hours: 6));
      repo.setNextRunAt(schedule.id, missedSlot);

      final executed = await repo.runDueSchedules();

      expect(executed.first.status, 'Skipped');
      expect(wallet.balance, 5000);
    });

    test('does not run a paused rule', () async {
      final setup = buildRepository(balance: 5000);
      final repo = setup.repository;
      final wallet = setup.wallet;

      final schedule = await createSchedule(repo);
      final due = DateTime.now().toUtc().subtract(const Duration(minutes: 1));
      repo.setNextRunAt(schedule.id, due);
      await repo.setStatus(schedule.id, 'Paused');

      final executed = await repo.runDueSchedules(now: due);

      expect(executed, isEmpty);
      expect(wallet.balance, 5000);
    });
  });

  group('transaction reference', () {
    test('is stable for the same slot and different across slots', () {
      final slot = DateTime.utc(2026, 10, 20, 7);
      final other = DateTime.utc(2026, 10, 21, 7);

      expect(
        buildExecutionRef('schedule-1', slot),
        buildExecutionRef('schedule-1', slot),
      );
      expect(
        buildExecutionRef('schedule-1', slot),
        isNot(buildExecutionRef('schedule-1', other)),
      );
    });
  });
}
