// Tests for the VTU services added alongside data: airtime, cable TV,
// electricity, bulk SMS, edu pins, recharge pin and Swarp.

import 'package:data_naija_app/data/models/service.dart';
import 'package:data_naija_app/presentation/screens/home_screen.dart';
import 'package:data_naija_app/presentation/screens/service_purchase_screen.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';
import '../test_app.dart';

void main() {
  setUp(resetAppState);

  Future<void> pumpService(WidgetTester tester, ServiceKind kind) async {
    useTallScreen(tester);
    await tester.pumpWidget(
      testApp(home: ServicePurchaseScreen(kind: kind)),
    );
    await settle(tester);
  }

  group('services on home', () {
    testWidgets('the services grid opens every service', (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(testApp(home: const HomeScreen()));
      await settle(tester);

      // Each tile opens the shared screen with the matching title.
      for (final kind in ServiceKind.values) {
        final tile = find.text(kind.tileLabel);
        await tester.ensureVisible(tile);
        await settle(tester);
        await tester.tap(tile);
        await settle(tester);

        expect(find.text(kind.title), findsWidgets);
        expect(find.text(kind.description), findsOneWidget);

        await tester.pageBack();
        await settle(tester);
      }
    });
  });

  group('airtime', () {
    testWidgets('buys airtime and records the transaction', (tester) async {
      await pumpService(tester, ServiceKind.airtime);

      expect(find.text('Buy Airtime'), findsWidgets);
      expect(find.text('Select Network'), findsOneWidget);

      await typeInto(tester, 'Enter phone number', '08012345678');
      await settle(tester);

      await tester.tap(find.text('Pay ₦500'));
      await settle(tester);

      expect(find.text('Purchase Successful'), findsOneWidget);
      expect(find.text('₦500.00'), findsOneWidget);
      expect(appRepository.balance, 4500);
    });

    testWidgets('requires a valid phone number and a minimum amount',
        (tester) async {
      await pumpService(tester, ServiceKind.airtime);

      // The button is disabled before a number is entered.
      expect(find.text('Pay ₦500'), findsOneWidget);

      await typeInto(tester, 'Enter phone number', '08012345678');
      await settle(tester);

      await typeInto(tester, 'Enter amount', '10');
      await settle(tester);

      expect(find.text('Pay ₦10'), findsOneWidget);
      await tester.tap(find.text('Pay ₦10'));
      await settle(tester);

      // Below the ₦50 minimum, nothing is bought.
      expect(find.text('Purchase Successful'), findsNothing);
      expect(appRepository.balance, 5000);
    });
  });

  group('cable TV', () {
    testWidgets('switch provider and package, then pay', (tester) async {
      await pumpService(tester, ServiceKind.cable);

      expect(find.text('Select Provider'), findsOneWidget);
      expect(find.text('Padi'), findsWidgets);

      await tester.tap(find.text('GOtv'));
      await settle(tester);

      expect(find.text('Smallie'), findsWidgets);
      expect(find.text('Padi'), findsNothing);

      await typeInto(tester, 'Enter smartcard number', '1234567890');
      await settle(tester);

      await tester.tap(find.text('Pay ₦1,900'));
      await settle(tester);

      expect(find.text('Purchase Successful'), findsOneWidget);
      expect(appRepository.balance, 3100);
    });
  });

  group('electricity', () {
    testWidgets('pays a prepaid or postpaid meter bill', (tester) async {
      await pumpService(tester, ServiceKind.electricity);

      expect(find.text('Meter Type'), findsOneWidget);
      expect(find.text('Prepaid'), findsOneWidget);
      expect(find.text('Postpaid'), findsOneWidget);

      await typeInto(tester, 'Enter meter number', '12345678901');
      await settle(tester);

      await tester.tap(find.text('Pay ₦1,000'));
      await settle(tester);

      expect(find.text('Purchase Successful'), findsOneWidget);
      expect(find.textContaining('EKEDC'), findsWidgets);
      expect(appRepository.balance, 4000);
    });
  });

  group('bulk SMS', () {
    testWidgets('sends to several recipients', (tester) async {
      await pumpService(tester, ServiceKind.bulkSms);

      expect(find.text('Recipient Numbers'), findsOneWidget);
      expect(find.text('100 SMS'), findsWidgets);

      await typeInto(
        tester,
        'e.g. 08012345678, 08098765432',
        '08012345678, 08098765432',
      );
      await typeInto(tester, 'Type your message', 'Hello from DataNaija');
      await settle(tester);

      await tester.tap(find.text('Pay ₦700'));
      await settle(tester);

      expect(find.text('Purchase Successful'), findsOneWidget);
      expect(find.textContaining('2 recipients'), findsWidgets);
      expect(appRepository.balance, 4300);
    });
  });

  group('edu pins', () {
    testWidgets('buys an exam pin for the customer number', (tester) async {
      await pumpService(tester, ServiceKind.eduPin);

      expect(find.text('Choose a pin'), findsOneWidget);
      expect(find.text('WAEC Result Checker'), findsWidgets);

      await typeInto(tester, 'Enter phone number', '08012345678');
      await settle(tester);

      await tester.tap(find.text('Pay ₦3,500'));
      await settle(tester);

      expect(find.text('Purchase Successful'), findsOneWidget);
      expect(appRepository.balance, 1500);
    });
  });

  group('recharge pin', () {
    testWidgets('buys a recharge pin by SMS', (tester) async {
      await pumpService(tester, ServiceKind.rechargePin);

      await typeInto(tester, 'Enter phone number', '08012345678');
      await settle(tester);

      await tester.tap(find.text('Pay ₦500'));
      await settle(tester);

      expect(find.text('Purchase Successful'), findsOneWidget);
      expect(appRepository.balance, 4500);
    });
  });

  group('Swarp', () {
    testWidgets('swaps airtime for wallet cash', (tester) async {
      await pumpService(tester, ServiceKind.swarp);

      expect(find.text('Swarp'), findsWidgets);
      expect(find.text('Swap for ₦425'), findsOneWidget);

      await typeInto(tester, 'Enter phone number', '08012345678');
      await settle(tester);

      await tester.tap(find.text('Swap for ₦425'));
      await settle(tester);

      expect(find.text('Swap Successful'), findsOneWidget);
      expect(appRepository.balance, 5425);
    });
  });
}
