// Widget tests for the Auto-Buy screens.
//
// They cover the customer facing flows: setting up a rule, confirming it,
// managing it and the empty state.

import 'package:data_naija_app/core/utils/auto_buy_frequency.dart';
import 'package:data_naija_app/core/utils/storage_service.dart';
import 'package:data_naija_app/presentation/screens/auto_buy_detail_screen.dart';
import 'package:data_naija_app/presentation/screens/auto_buy_list_screen.dart';
import 'package:data_naija_app/presentation/screens/auto_buy_setup_screen.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_app.dart';

/// Creates an active rule.
Future<void> createRule({
  String planGb = '1GB',
  int price = 300,
  String frequency = 'daily',
}) async {
  await autoBuyRepository.create(
    network: 'MTN',
    planType: 'SME',
    planGb: planGb,
    planDays: '30 Days',
    price: price,
    phone: '08012345678',
    frequency: frequency,
    interval: 1,
    unit: AutoBuyUnit.days,
    daysOfWeek: const [],
    timeOfDay: '08:00',
  );
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.init();
    // Start every test with an empty set of rules.
    for (final schedule in List.of(autoBuyRepository.schedules)) {
      await autoBuyRepository.delete(schedule.id);
    }
  });

  /// Gives the test a tall viewport so the whole screen fits and every
  /// section is reachable without scrolling.
  void useTallScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('Auto-Buy setup screen', () {
    testWidgets('shows the steps and the summary', (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(testApp(home: const AutoBuySetupScreen()));
      await tester.pumpAndSettle();

      expect(find.text('New Auto-Buy'), findsOneWidget);
      expect(find.text('Select Network'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Select Data Bundle'), findsOneWidget);
      expect(find.text('How often?'), findsOneWidget);
      expect(find.text('Schedule summary'), findsOneWidget);
      expect(find.text('Activate Auto-Buy'), findsOneWidget);
    });

    testWidgets('offers every supported frequency', (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(testApp(home: const AutoBuySetupScreen()));
      await tester.pumpAndSettle();

      for (final label in [
        'Every 2 hours',
        'Every 4 hours',
        'Every 6 hours',
        'Every 12 hours',
        'Every day',
        'Every 2 days',
        'Every 3 days',
        'Every week',
        'Every 2 weeks',
        'Every month',
        'Custom schedule',
      ]) {
        expect(find.text(label), findsOneWidget, reason: label);
      }
    });

    testWidgets('the activation button is disabled until a bundle is picked',
        (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(testApp(home: const AutoBuySetupScreen()));
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Activate Auto-Buy'),
      );
      expect(button.onPressed, isNull);
    });

    testWidgets('picking a bundle enables activation', (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(testApp(home: const AutoBuySetupScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('1GB').first, warnIfMissed: false);
      await tester.pumpAndSettle();

      final button = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Activate Auto-Buy'),
      );
      expect(button.onPressed, isNotNull);
    });

    testWidgets('confirmation requires the consent checkbox', (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(testApp(home: const AutoBuySetupScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('1GB').first, warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Activate Auto-Buy'));
      await tester.pumpAndSettle();

      // The summary sheet is shown.
      expect(find.text('Confirm Auto-Buy'), findsOneWidget);
      expect(find.text('Confirm & Activate'), findsOneWidget);

      // The confirm button is disabled until the customer ticks the box.
      var confirm = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Confirm & Activate'),
      );
      expect(confirm.onPressed, isNull);

      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      confirm = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Confirm & Activate'),
      );
      expect(confirm.onPressed, isNotNull);
    });

    testWidgets('activating a rule creates it and shows the confirmation',
        (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(testApp(home: const AutoBuySetupScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('1GB').first, warnIfMissed: false);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Activate Auto-Buy'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm & Activate'));
      await tester.pumpAndSettle();

      expect(find.text('Auto-Buy activated'), findsOneWidget);
      expect(autoBuyRepository.schedules, hasLength(1));
      expect(autoBuyRepository.schedules.first.isActive, isTrue);
      expect(autoBuyRepository.schedules.first.price, 300);
    });

    testWidgets('a weekly rule asks for the weekdays', (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(testApp(home: const AutoBuySetupScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Every week'));
      await tester.pumpAndSettle();

      expect(find.text('Which days?'), findsOneWidget);
    });
  });

  group('Auto-Buy list screen', () {
    testWidgets('shows the empty state when there are no rules',
        (tester) async {
      await tester.pumpWidget(testApp(home: const AutoBuyListScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Auto-Buy'), findsOneWidget);
      expect(find.text('No Auto-Buy schedules yet'), findsOneWidget);
      expect(find.text('New Auto-Buy'), findsOneWidget);
    });

    testWidgets('lists a rule with its schedule and next purchase',
        (tester) async {
      useTallScreen(tester);
      await createRule();

      await tester.pumpWidget(testApp(home: const AutoBuyListScreen()));
      await tester.pumpAndSettle();

      expect(find.text('1GB · 30 Days'), findsOneWidget);
      expect(find.text('Every day at 8:00 AM'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.text('Pause'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('pausing a rule updates the card', (tester) async {
      useTallScreen(tester);
      await createRule();

      await tester.pumpWidget(testApp(home: const AutoBuyListScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pause'));
      await tester.pumpAndSettle();

      expect(autoBuyRepository.schedules.first.isActive, isFalse);
      expect(find.text('Paused'), findsOneWidget);
      expect(find.text('Resume'), findsOneWidget);
    });

    testWidgets('deleting a rule asks for confirmation first', (tester) async {
      useTallScreen(tester);
      await createRule();

      await tester.pumpWidget(testApp(home: const AutoBuyListScreen()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Auto-Buy?'), findsOneWidget);
      expect(autoBuyRepository.schedules, hasLength(1));

      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Delete'),
        ),
      );
      await tester.pumpAndSettle();

      expect(autoBuyRepository.schedules, isEmpty);
    });
  });

  group('Auto-Buy detail screen', () {
    testWidgets('shows the rule and its purchase history', (tester) async {
      useTallScreen(tester);
      await createRule();
      final id = autoBuyRepository.schedules.first.id;

      await tester.pumpWidget(
        testApp(home: AutoBuyDetailScreen(scheduleId: id)),
      );
      await tester.pumpAndSettle();

      expect(find.text('1GB · 30 Days'), findsOneWidget);
      expect(find.text('Every day at 8:00 AM'), findsOneWidget);
      expect(find.text('Purchase history'), findsOneWidget);
      expect(find.text('Pause Auto-Buy'), findsOneWidget);
      expect(find.text('Edit Schedule'), findsOneWidget);
    });

    testWidgets('handles a rule that no longer exists', (tester) async {
      await tester.pumpWidget(
        testApp(home: const AutoBuyDetailScreen(scheduleId: 'missing')),
      );
      await tester.pumpAndSettle();

      expect(find.text('This schedule no longer exists.'), findsOneWidget);
    });
  });
}
