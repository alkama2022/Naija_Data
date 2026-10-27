// Tests for the wallet and transaction-history screens.

import 'dart:convert';
import 'dart:typed_data';

import 'package:data_naija_app/core/utils/connectivity_service.dart';
import 'package:data_naija_app/data/services/api_service.dart';
import 'package:data_naija_app/presentation/screens/transactions_screen.dart';
import 'package:data_naija_app/presentation/screens/wallet_screen.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:data_naija_app/presentation/widgets/transaction_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers.dart';
import '../test_app.dart';

class _StubHttpClient extends http.BaseClient {
  _StubHttpClient(this.handler);

  final Future<http.StreamedResponse> Function(Uri) handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async =>
      handler(request.url);
}

class _FakeConnectivity extends ConnectivityService {
  _FakeConnectivity(this.online);

  final bool online;

  @override
  Future<bool> hasConnection({bool force = false}) async => online;
}

ApiService _api({
  ConnectivityService? connectivity,
  Future<http.StreamedResponse> Function(Uri) handler = _transactions,
}) =>
    ApiService.withClient(
      _StubHttpClient(handler),
      connectivity: connectivity ?? _FakeConnectivity(true),
    );

Future<http.StreamedResponse> _transactions(Uri uri) async {
  if (uri.path.contains('/wallet/transactions')) {
    final status = uri.queryParameters['status'] ?? 'All';
    final query = (uri.queryParameters['q'] ?? '').toLowerCase();
    var list = <Map<String, dynamic>>[
      {
        'id': 'tx-1',
        'title': 'Data Purchase',
        'subtitle': 'MTN 1GB',
        'amount': -1000,
        'status': 'Successful',
        'phone': '08012345678',
        'ref': 'DN123456789',
        'typeKey': 'd',
        'createdAt': '2025-04-25T14:15:00.000Z',
      },
      {
        'id': 'tx-2',
        'title': 'Airtime Purchase',
        'subtitle': 'Airtel',
        'amount': -500,
        'status': 'Failed',
        'phone': '08098765432',
        'ref': 'DN123456742',
        'typeKey': 'a',
        'createdAt': '2025-04-24T11:20:00.000Z',
      },
    ];
    if (status != 'All') {
      list = list.where((t) => t['status'] == status).toList();
    }
    if (query.isNotEmpty) {
      list = list
          .where(
            (t) =>
                '${t['title']} ${t['subtitle']} ${t['ref']}'.toLowerCase().contains(
                  query,
                ),
          )
          .toList();
    }
    return _json(list, 200);
  }

  if (uri.path.contains('/wallet/balance')) {
    return _json(
      <String, dynamic>{'balance': 5000, 'balanceHidden': false},
      200,
    );
  }

  return _json(<String, dynamic>{}, 404);
}

Future<http.StreamedResponse> _emptyTransactions(Uri uri) async =>
    _json(<Map<String, dynamic>>[], 200);

http.StreamedResponse _json(Object body, int status) => http.StreamedResponse(
      Stream<Uint8List>.value(
        Uint8List.fromList(utf8.encode(jsonEncode(body))),
      ),
      status,
      headers: <String, String>{'content-type': 'application/json'},
    );

void main() {
  setUp(() async {
    resetAppState();
    // The wallet screens do not persist anything, but SharedPreferences is
    // initialized so the AuthService singleton is safe in tests.
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  Future<void> pump(WidgetTester tester, Widget screen) async {
    await tester.pumpWidget(testApp(home: screen));
    await settle(tester);
  }

  group('wallet', () {
    testWidgets('shows the balance and the fund action', (tester) async {
      await pump(
        tester,
        WalletScreen(
          apiService: _api(handler: _transactions),
        ),
      );

      expect(find.text('Wallet'), findsOneWidget);
      expect(find.text('Wallet Balance'), findsOneWidget);
      expect(find.text('₦5,000.00'), findsWidgets);
      expect(find.text('Fund Wallet'), findsWidgets);
    });

    testWidgets('the balance can be hidden and shown again', (tester) async {
      await pump(
        tester,
        WalletScreen(
          apiService: _api(handler: _transactions),
        ),
      );

      await tester.tap(find.byIcon(Icons.visibility));
      await settle(tester);

      expect(appStore.balanceHidden, isTrue);
      expect(find.text('₦ ••••••'), findsWidgets);
    });

    testWidgets('the account number appears only after verification',
        (tester) async {
      await pump(
        tester,
        WalletScreen(
          apiService: _api(handler: _transactions),
        ),
      );

      // Not verified yet: no funding account is shown.
      expect(find.textContaining('0123456789'), findsNothing);

      appStore.setKycVerified(true);
      await settle(tester);

      expect(find.textContaining('0123456789'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
    });
  });

  group('transactions', () {
    testWidgets('lists the transactions from the backend', (tester) async {
      await pump(
        tester,
        TransactionsScreen(
          apiService: _api(handler: _transactions),
        ),
      );

      expect(find.text('Transactions'), findsOneWidget);
      expect(find.byType(TransactionItem), findsNWidgets(2));
      // Filters are present.
      expect(find.text('Successful'), findsWidgets);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Failed'), findsWidgets);
    });

    testWidgets('shows the empty state when the backend has none',
        (tester) async {
      await pump(
        tester,
        TransactionsScreen(
          apiService: _api(handler: _emptyTransactions),
        ),
      );

      expect(find.text('No transactions found.'), findsOneWidget);
    });

    testWidgets('shows the error state and retries after fixing the backend',
        (tester) async {
      var failing = true;
      late final ApiService api;

      api = ApiService.withClient(
        _StubHttpClient((uri) async {
          if (failing) {
            return _json(<String, dynamic>{'error': 'Internal server error'}, 500);
          }
          return _transactions(uri);
        }),
        connectivity: _FakeConnectivity(true),
      );

      await tester.pumpWidget(testApp(home: TransactionsScreen(apiService: api)));
      await settle(tester);

      expect(find.text('Internal server error'), findsOneWidget);
      expect(find.byType(TransactionItem), findsNothing);

      failing = false;
      await tester.tap(find.text('Retry'));
      await settle(tester);

      expect(find.byType(TransactionItem), findsNWidgets(2));
    });

    testWidgets('shows the offline state when there is no connection',
        (tester) async {
      await pump(
        tester,
        TransactionsScreen(
          apiService: _api(
            connectivity: _FakeConnectivity(false),
            handler: _transactions,
          ),
        ),
      );

      expect(
        find.text('No internet connection. Please check your connection.'),
        findsOneWidget,
      );
      expect(find.byType(TransactionItem), findsNothing);
    });

    testWidgets('filtering by status narrows the list', (tester) async {
      await pump(
        tester,
        TransactionsScreen(
          apiService: _api(handler: _transactions),
        ),
      );

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
      await pump(
        tester,
        TransactionsScreen(
          apiService: _api(handler: _transactions),
        ),
      );

      await typeInto(tester, 'Search transactions...', 'Airtime');
      await settle(tester);

      // The backend filters by the search text we send.
      expect(find.byType(TransactionItem), findsOneWidget);
      expect(find.text('Airtime Purchase'), findsOneWidget);
      expect(find.text('Data Purchase'), findsNothing);
    });

    testWidgets('searching with no matches shows the empty state',
        (tester) async {
      await pump(
        tester,
        TransactionsScreen(
          apiService: _api(handler: _transactions),
        ),
      );

      await typeInto(tester, 'Search transactions...', 'zzzz-no-match');
      await settle(tester);

      expect(find.text('No transactions found.'), findsOneWidget);
    });
  });
}
