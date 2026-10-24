// Tests for the buy-data flow: Buy Data -> Select Bundle -> (Review).
//
// The Processing screen runs a timer and a spin animation, so the end of
// the flow is covered in success_processing_test.dart.

import 'package:data_naija_app/presentation/screens/buy_data_screen.dart';
import 'package:data_naija_app/presentation/screens/select_bundle_screen.dart';
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

  group('buy data', () {
    testWidgets('shows the network step and the phone field', (tester) async {
      await pump(tester, const BuyDataScreen());

      expect(find.text('Buy Data'), findsOneWidget);
      expect(find.text('Select Network'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('the network chips select a network', (tester) async {
      await pump(tester, const BuyDataScreen());

      expect(appStore.selectedNetwork, 'MTN');

      await tester.tap(find.text('Airtel'));
      await settle(tester);

      expect(appStore.selectedNetwork, 'Airtel');
    });

    testWidgets('Next is disabled until the phone number is valid',
        (tester) async {
      await pump(tester, const BuyDataScreen());

      ElevatedButton nextButton() => tester.widget<ElevatedButton>(
            find.widgetWithText(ElevatedButton, 'Next'),
          );

      expect(nextButton().onPressed, isNull);

      await typeInto(tester, 'Enter phone number', '08012345678');
      await settle(tester);

      expect(nextButton().onPressed, isNotNull);
    });

    testWidgets('Next keeps the phone number and opens the bundle step',
        (tester) async {
      await pump(tester, const BuyDataScreen());

      await typeInto(tester, 'Enter phone number', '08012345678');
      await settle(tester);

      await tester.tap(find.text('Next'));
      await settle(tester);

      expect(appStore.phone, '08012345678');
      expect(find.text('Select Data Bundle'), findsOneWidget);
    });
  });

  group('select bundle', () {
    testWidgets('shows the plans for the selected family', (tester) async {
      await pump(tester, const SelectBundleScreen());

      expect(find.text('Select Data Bundle'), findsOneWidget);
      expect(find.text('Choose data type'), findsOneWidget);
      // The default family is SME, whose first plan is 500MB.
      expect(find.text('500MB'), findsOneWidget);
    });

    testWidgets('picking a plan updates the selection', (tester) async {
      await pump(tester, const SelectBundleScreen());

      await tester.tap(find.text('2GB'));
      await settle(tester);

      expect(appStore.selectedGb, '2GB');
      expect(appStore.selectedPrice, 600);
    });

    testWidgets('switching the data type resets the plan to that family',
        (tester) async {
      await pump(tester, const SelectBundleScreen());

      await tester.tap(find.text('Awoof'));
      await settle(tester);

      expect(appStore.dataType, 'Awoof');
      expect(appStore.selectedGb, '1.5GB');

      // Awoof is a "Today only" family.
      expect(find.text('Today only'), findsWidgets);
    });
  });
}
