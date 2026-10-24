// Tests for the splash screen.

import 'package:data_naija_app/presentation/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';
import '../test_app.dart';

void main() {
  setUp(resetAppState);

  testWidgets('shows the brand and the tagline', (tester) async {
    await tester.pumpWidget(testApp(home: const SplashScreen()));
    await tester.pump();

    expect(find.text('Fast · Secure · Reliable'), findsOneWidget);
    expect(find.text('Buy Data · Buy Airtime · Fund Wallet'), findsOneWidget);
    // The brand artwork is on the screen.
    expect(find.byType(Image), findsWidgets);

    // Let the timer that moves the splash on finish, so the test does not
    // end with a pending timer.
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pumpAndSettle();
  });

  testWidgets('moves on to the onboarding by itself', (tester) async {
    await tester.pumpWidget(testApp(home: const SplashScreen()));
    await tester.pump();

    // The splash waits a moment before it moves on.
    await tester.pump(const Duration(milliseconds: 2300));
    await tester.pumpAndSettle();

    expect(find.text('Onboarding'), findsNothing);
    expect(
      find.text('Buy Data, Airtime and More'),
      findsOneWidget,
    );
  });
}
