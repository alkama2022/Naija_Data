// Tests for the home screen: content, the header actions, the quick
// actions, the support shortcut, and the layout at phone sizes.

import 'package:data_naija_app/presentation/screens/home_screen.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:data_naija_app/presentation/widgets/transaction_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';
import '../test_app.dart';

void main() {
  setUp(resetAppState);

  /// Pumps the home screen on a phone-sized viewport.
  ///
  /// The viewport is the prototype's 390 × 844 so the layout matches the
  /// design and overflows are caught rather than hidden by a tall screen.
  Future<void> pumpHome(WidgetTester tester,
      {Size size = const Size(390, 844)}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(testApp(home: const HomeScreen()));
    await settle(tester);
  }

  group('home content', () {
    testWidgets('shows the greeting, wallet and section headings',
        (tester) async {
      await pumpHome(tester);

      expect(find.text('Hello, Chinedu'), findsOneWidget);
      expect(find.text('Good morning!'), findsOneWidget);
      expect(find.text('Wallet Balance'), findsOneWidget);
      expect(find.text('Fund Wallet'), findsOneWidget);
      expect(find.text('Referral'), findsOneWidget);
      expect(find.text('Palmpay'), findsOneWidget);
      expect(find.text('Moniepoint'), findsOneWidget);
      expect(find.text('6684717385'), findsOneWidget);
      expect(find.text('0123456789'), findsOneWidget);
      expect(find.text('BBKDATA'), findsNWidgets(2));
      expect(find.text('Popular Data Bundles'), findsOneWidget);
      expect(find.text('Recent Transactions'), findsOneWidget);
      expect(find.text('Auto-Buy'), findsOneWidget);
      expect(find.text('Verify Account'), findsOneWidget);
      expect(find.text('NIN or BVN'), findsOneWidget);
    });

    testWidgets('shows the KYC nudge until the customer is verified',
        (tester) async {
      await pumpHome(tester);

      expect(
        find.text('Verify your identity to get your funding account ›'),
        findsOneWidget,
      );

      appStore.setKycVerified(true);
      await settle(tester);

      expect(
        find.text('Verify your identity to get your funding account ›'),
        findsNothing,
      );
    });

    testWidgets('lists the recent transactions', (tester) async {
      await pumpHome(tester);

      // The home screen shows at most the three most recent transactions.
      expect(find.byType(TransactionItem), findsNWidgets(3));
    });
  });

  group('home actions', () {
    testWidgets('the notifications button opens the notifications screen',
        (tester) async {
      await pumpHome(tester);

      await tester.tap(find.byIcon(Icons.notifications_none));
      await settle(tester);

      expect(find.text('Notifications'), findsWidgets);
    });

    testWidgets('the profile avatar opens the profile screen', (tester) async {
      await pumpHome(tester);

      await tester.tap(find.text('CO'));
      await settle(tester);

      expect(find.text('Chinedu Okafor'), findsWidgets);
    });

    testWidgets('the Buy Data quick action opens the buy screen',
        (tester) async {
      await pumpHome(tester);

      await tester.tap(find.text('Buy Data'));
      await settle(tester);

      expect(find.text('Select Network'), findsOneWidget);
    });

    testWidgets('the Transactions quick action opens the history',
        (tester) async {
      await pumpHome(tester);

      // Two "Transactions" labels exist only in the nav, so tap the quick
      // action by its first occurrence.
      await tester.tap(find.text('Transactions').first);
      await settle(tester);

      expect(find.text('All'), findsWidgets);
    });

    testWidgets('the Auto-Buy card opens the Auto-Buy list', (tester) async {
      await pumpHome(tester);

      await tester.ensureVisible(find.text('Auto-Buy'));
      await settle(tester);
      await tester.tap(find.text('Auto-Buy'));
      await settle(tester);

      expect(find.text('Auto-Buy'), findsWidgets);
      // The empty state is the copy shown when there are no rules.
      expect(find.textContaining('No Auto-Buy'), findsWidgets);
    });

    testWidgets('the Verify Account card opens the KYC screen', (tester) async {
      await pumpHome(tester);

      await tester.ensureVisible(find.text('Verify Account'));
      await settle(tester);
      await tester.tap(find.text('Verify Account'));
      await settle(tester);

      expect(find.text('Verify your identity'), findsOneWidget);
      expect(find.text('BVN'), findsOneWidget);
      expect(find.text('NIN'), findsOneWidget);
    });

    testWidgets('the Verify Account card reflects the verified state',
        (tester) async {
      await pumpHome(tester);

      appStore.setKycVerified(true);
      await settle(tester);

      expect(find.text('Verify Account'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
    });

    testWidgets('the bottom nav opens the profile screen', (tester) async {
      await pumpHome(tester);

      await tester.tap(find.text('Profile'));
      await settle(tester);

      expect(find.text('Chinedu Okafor'), findsWidgets);
    });

    testWidgets('the support shortcut is shown on home', (tester) async {
      await pumpHome(tester);

      expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
    });

    testWidgets('the Referral button opens the referral screen',
        (tester) async {
      await pumpHome(tester);

      await tester.tap(find.text('Referral'));
      await settle(tester);

      expect(find.text('Referral bonus'), findsOneWidget);
    });

    testWidgets('copies the Palmpay account number', (tester) async {
      final calls = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          calls.add(call);
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null),
      );

      await pumpHome(tester);

      final copyButton = find.byTooltip('Copy Palmpay account number');
      await tester.ensureVisible(copyButton);
      await settle(tester);
      await tester.tap(copyButton);
      await tester.pump();

      expect(
        calls
            .where((call) => call.method == 'Clipboard.setData')
            .map((call) => (call.arguments as Map)['text']),
        contains('6684717385'),
      );
      expect(find.text('Palmpay account number copied'), findsOneWidget);
    });

    testWidgets('copies the Moniepoint account number', (tester) async {
      final calls = <MethodCall>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          calls.add(call);
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null),
      );

      await pumpHome(tester);

      final copyButton = find.byTooltip('Copy Moniepoint account number');
      await tester.ensureVisible(copyButton);
      await settle(tester);
      await tester.tap(copyButton);
      await tester.pump();

      expect(
        calls
            .where((call) => call.method == 'Clipboard.setData')
            .map((call) => (call.arguments as Map)['text']),
        contains('0123456789'),
      );
      expect(find.text('Moniepoint account number copied'), findsOneWidget);
    });
  });

  group('home layout', () {
    for (final size in const [
      Size(390, 844),
      Size(360, 640),
      Size(320, 568),
      Size(412, 915),
    ]) {
      testWidgets('lays out without overflow at $size', (tester) async {
        await pumpHome(tester, size: size);

        expect(tester.takeException(), isNull);
      });
    }
  });
}
