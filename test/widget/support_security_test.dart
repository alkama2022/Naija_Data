// Tests for the security and help/support screens.

import 'package:data_naija_app/presentation/screens/help_screen.dart';
import 'package:data_naija_app/presentation/screens/security_screen.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';
import '../test_app.dart';

void main() {
  setUp(resetAppState);

  Future<void> pump(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(testApp(home: screen));
    await settle(tester);
  }

  group('security', () {
    testWidgets('shows the fingerprint and balance switches', (tester) async {
      await pump(tester, const SecurityScreen());

      expect(find.text('Security'), findsOneWidget);
      expect(find.text('Fingerprint'), findsOneWidget);
      expect(find.text('Show wallet balance'), findsOneWidget);
      expect(find.byType(Switch), findsNWidgets(2));
    });

    testWidgets('the fingerprint switch updates the store', (tester) async {
      await pump(tester, const SecurityScreen());

      expect(appStore.fingerprintEnabled, isFalse);

      await tester.tap(find.byType(Switch).first);
      await settle(tester);

      expect(appStore.fingerprintEnabled, isTrue);
    });

    testWidgets('the balance switch toggles the home balance visibility',
        (tester) async {
      await pump(tester, const SecurityScreen());

      // The switch is on while the balance is visible.
      expect(appStore.balanceHidden, isFalse);

      await tester.tap(find.byType(Switch).last);
      await settle(tester);

      expect(appStore.balanceHidden, isTrue);
    });
  });

  group('help', () {
    testWidgets('shows the FAQ list on the FAQs tab', (tester) async {
      await pump(tester, const HelpScreen());

      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.text('How do I fund my wallet?'), findsOneWidget);
      expect(find.text('How do I buy data?'), findsOneWidget);
    });

    testWidgets('tapping a question opens its answer', (tester) async {
      await pump(tester, const HelpScreen());

      const answer =
          'Open Fund Wallet, enter an amount, pick a payment method and continue.';
      expect(find.text(answer), findsNothing);

      await tester.tap(find.text('How do I fund my wallet?'));
      await settle(tester);

      expect(find.text(answer), findsOneWidget);
    });

    testWidgets('the contact support tab shows the WhatsApp options',
        (tester) async {
      await pump(tester, const HelpScreen());

      await tester.tap(find.text('Contact Support'));
      await settle(tester);

      expect(find.text('Contact our team'), findsOneWidget);
      expect(find.text('Chat with Support'), findsOneWidget);
      expect(find.text('Follow Our WhatsApp Channel'), findsOneWidget);
    });
  });
}
