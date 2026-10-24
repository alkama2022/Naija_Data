// Tests for the processing and success screens.
//
// The Processing screen runs a 1.6s timer and a spin animation, so this
// file drives it with explicit pumps instead of pumpAndSettle.

import 'package:data_naija_app/presentation/routes/app_routes.dart';
import 'package:data_naija_app/presentation/screens/review_purchase_screen.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';
import '../test_app.dart';

void main() {
  setUp(resetAppState);

  /// Opens [route] using a real navigator so pushReplacementNamed works.
  ///
  /// [settleAfter] must be false for screens that animate or run a timer
  /// (like Processing), otherwise waiting for everything would run the
  /// timer to completion before the test can look at the screen.
  Future<void> startAt(
    WidgetTester tester,
    String route, {
    bool settleAfter = true,
  }) async {
    const key = ValueKey('start');
    await tester.pumpWidget(testApp(home: const SizedBox(key: key)));
    await settle(tester);
    final context = tester.element(find.byKey(key));
    Navigator.of(context).pushNamed(route);
    if (settleAfter) {
      await settle(tester);
    } else {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }
  }

  group('processing', () {
    testWidgets('shows the spinner while the purchase is running',
        (tester) async {
      appStore.setPhone('08012345678');
      await startAt(tester, AppRoutes.processing, settleAfter: false);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Processing...'), findsOneWidget);

      // Let the timer fire and the navigation settle.
      await tester.pump(const Duration(milliseconds: 1700));
      await settle(tester);
    });

    testWidgets('a successful purchase records a transaction and shows it',
        (tester) async {
      appStore.setPhone('08012345678');
      final balanceBefore = appRepository.balance;

      await startAt(tester, AppRoutes.processing, settleAfter: false);
      await tester.pump(const Duration(milliseconds: 1700));
      await settle(tester);

      expect(find.text('Purchase Successful'), findsOneWidget);
      expect(appRepository.balance, lessThan(balanceBefore));
      expect(appRepository.lastTransaction?.title, 'Data Purchase');
    });

    testWidgets('an unaffordable purchase goes back to the review screen',
        (tester) async {
      appStore.setPhone('08012345678');
      appRepository.setBalance(0);

      await startAt(tester, AppRoutes.processing, settleAfter: false);
      await tester.pump(const Duration(milliseconds: 1700));
      await settle(tester);

      // It must not have recorded a purchase.
      expect(appRepository.lastTransaction, isNull);
      expect(find.byType(ReviewPurchaseScreen), findsOneWidget);
    });
  });

  group('success', () {
    testWidgets('shows the receipt and the two follow-up actions',
        (tester) async {
      await startAt(tester, AppRoutes.success);

      expect(find.text('Purchase Successful'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Data Bundle'), findsOneWidget);
      expect(find.text('Reference ID'), findsOneWidget);
      expect(find.text('View Transaction'), findsOneWidget);
      expect(find.text('Back to Home'), findsOneWidget);
    });
  });
}
