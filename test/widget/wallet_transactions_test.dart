// Tests for the wallet and transaction-history screens.

import 'package:data_naija_app/presentation/screens/transactions_screen.dart';
import 'package:data_naija_app/presentation/screens/wallet_screen.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:data_naija_app/presentation/widgets/transaction_item.dart';
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

  group('wallet', () {
    testWidgets('shows the balance and the fund action', (tester) async {
      await pump(tester, const WalletScreen());

      expect(find.text('Wallet'), findsOneWidget);
      expect(find.text('Wallet Balance'), findsOneWidget);
      expect(find.text('₦5,000.00'), findsWidgets);
      expect(find.text('Fund Wallet'), findsWidgets);
    });

    testWidgets('the balance can be hidden and shown again', (tester) async {
      await pump(tester, const WalletScreen());

      await tester.tap(find.byIcon(Icons.visibility));
      await settle(tester);

      expect(appStore.balanceHidden, isTrue);
      expect(find.text('₦ ••••••'), findsWidgets);
    });

    testWidgets('the account number appears only after verification',
        (tester) async {
      await pump(tester, const WalletScreen());

      // Not verified yet: no funding account is shown.
      expect(find.textContaining('0123456789'), findsNothing);

      appStore.setKycVerified(true);
      await settle(tester);

      expect(find.textContaining('0123456789'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
    });
  });

  group('transactions', () {
    testWidgets('lists the sample transactions', (tester) async {
      await pump(tester, const TransactionsScreen());

      expect(find.text('Transactions'), findsOneWidget);
      expect(find.byType(TransactionItem), findsWidgets);
      // Filters are present.
      expect(find.text('Successful'), findsWidgets);
    });

    testWidgets('filtering by status narrows the list', (tester) async {
      await pump(tester, const TransactionsScreen());

      final all = find.byType(TransactionItem).evaluate().length;
      expect(all, greaterThan(1));

      // The "Failed" filter chip is the list's first "Failed" text; the
      // status pills come after it in the tree.
      await tester.tap(find.text('Failed').first);
      await settle(tester);

      final failed = find.byType(TransactionItem).evaluate().length;
      expect(failed, lessThan(all));
      expect(failed, greaterThan(0));
    });

    testWidgets('searching narrows the list', (tester) async {
      await pump(tester, const TransactionsScreen());

      await typeInto(tester, 'Search transactions...', 'Airtime');
      await settle(tester);

      expect(find.byType(TransactionItem), findsOneWidget);
    });

    testWidgets('searching with no matches shows the empty state',
        (tester) async {
      await pump(tester, const TransactionsScreen());

      await typeInto(tester, 'Search transactions...', 'zzzz-no-match');
      await settle(tester);

      expect(find.text('No transactions found.'), findsOneWidget);
    });
  });
}
