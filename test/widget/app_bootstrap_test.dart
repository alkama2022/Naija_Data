// Widget tests for the app bootstrap: the launch loading state, the offline
// state and the retry flow.

import 'package:data_naija_app/core/utils/auth_service.dart';
import 'package:data_naija_app/core/utils/connectivity_service.dart';
import 'package:data_naija_app/presentation/widgets/app_bootstrap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeConnectivity extends ConnectivityService {
  _FakeConnectivity(this.online);

  bool online;

  @override
  Future<bool> hasConnection({bool force = false}) async => online;
}

void main() {
  setUp(() async {
    ConnectivityService.resetForTesting();
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await AuthService.clearAuth();
  });

  group('AppBootstrap', () {
    testWidgets('shows the loading indicator while the app initialises',
        (WidgetTester tester) async {
      final connectivity = _FakeConnectivity(true);

      await tester.pumpWidget(
        MaterialApp(
          home: AppBootstrap(
            connectivity: connectivity,
            initializeLocalState: () async {},
          ),
        ),
      );
      await tester.pump();

      // While the local state loads, the session is checked and the backend
      // is probed, the customer sees the spinner and the "Loading..." copy.
      expect(find.text('Loading...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Let the initialisation finish.
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      // The bootstrap finished and the app moved on to a real screen.
      expect(find.text('Buy Data, Airtime and More'), findsOneWidget);
    });

    testWidgets('shows the offline message with a retry when there is no '
        'connection', (WidgetTester tester) async {
      final connectivity = _FakeConnectivity(false);

      await tester.pumpWidget(
        MaterialApp(
          home: AppBootstrap(
            connectivity: connectivity,
            initializeLocalState: () async {},
          ),
        ),
      );
      await tester.pump();

      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      expect(
        find.text('No internet connection. Please check your connection.'),
        findsOneWidget,
      );
      expect(find.text('Retry'), findsOneWidget);
      // The endless spinner must not keep spinning in the offline state.
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets(
        'retrying after the connection returns lets the app start again',
        (WidgetTester tester) async {
      final connectivity = _FakeConnectivity(false);

      await tester.pumpWidget(
        MaterialApp(
          home: AppBootstrap(
            connectivity: connectivity,
            initializeLocalState: () async {},
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      expect(
        find.text('No internet connection. Please check your connection.'),
        findsOneWidget,
      );

      // The customer retries from the offline screen.
      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      // The connection did not come back yet, so the retry state returns.
      expect(
        find.text('No internet connection. Please check your connection.'),
        findsOneWidget,
      );

      // Connectivity returns and the retry succeeds.
      connectivity.online = true;
      await tester.tap(find.text('Retry'));
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      expect(find.text('Buy Data, Airtime and More'), findsOneWidget);
    });

    testWidgets(
        'shows a retry view when the backend cannot be reached',
        (WidgetTester tester) async {
      final connectivity = _FakeConnectivity(true);
      ConnectivityService.resetForTesting(instance: connectivity);
      await AuthService.saveToken('stale-session-token');

      await tester.pumpWidget(
        MaterialApp(
          home: AppBootstrap(
            connectivity: connectivity,
            initializeLocalState: () async {},
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      // The device is online but the session check failed → a retryable
      // error view instead of a spinner that never stops.
      expect(find.text('Could not load DataNaija'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
