// Widget tests for the shared loading and retry feedback widgets.

import 'package:data_naija_app/core/errors/app_failure.dart';
import 'package:data_naija_app/presentation/widgets/loading_view.dart';
import 'package:data_naija_app/presentation/widgets/retry_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('LoadingView shows the loading text and a spinner',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: LoadingView())),
    );

    expect(find.text('Loading...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('LoadingView can render a custom loading message',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: LoadingView(message: 'Checking your session...')),
      ),
    );

    expect(find.text('Checking your session...'), findsOneWidget);
    expect(find.text('Loading...'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('RetryView shows the offline message and a retry action',
      (WidgetTester tester) async {
    var retries = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RetryView(
            message: AppFailure.noInternetMessage,
            onRetry: () => retries++,
          ),
        ),
      ),
    );

    expect(
      find.text('No internet connection. Please check your connection.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(retries, 1);
  });

  testWidgets('RetryView shows a spinner and disables retrying while busy',
      (WidgetTester tester) async {
    var retries = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RetryView(
            message: AppFailure.noInternetMessage,
            onRetry: () => retries++,
            retrying: true,
          ),
        ),
      ),
    );

    // While a retry is running the customer sees a spinner instead of a
    // second "Retry" label, and the action is disabled.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Retry'), findsNothing);

    final ElevatedButton button = tester.widget<ElevatedButton>(
      find.byType(ElevatedButton),
    );
    expect(button.onPressed, isNull);
  });
}
