// Tests for the sign in and sign up screens.

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:data_naija_app/core/utils/connectivity_service.dart';
import 'package:data_naija_app/data/services/api_service.dart';
import 'package:data_naija_app/presentation/screens/signin_screen.dart';
import 'package:data_naija_app/presentation/screens/signup_screen.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers.dart';
import '../test_app.dart';

class _StubHttpClient extends http.BaseClient {
  _StubHttpClient(this.responder);

  final Future<http.StreamedResponse> Function() responder;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async => responder();
}

class _FakeConnectivity extends ConnectivityService {
  _FakeConnectivity(this.online);

  final bool online;

  @override
  Future<bool> hasConnection({bool force = false}) async => online;
}

ApiService _api({
  ConnectivityService? connectivity,
  Future<http.StreamedResponse> Function() responder = _signInResponse,
}) =>
    ApiService.withClient(_StubHttpClient(responder), connectivity: connectivity);

Future<http.StreamedResponse> _signInResponse() async => http.StreamedResponse(
      Stream<Uint8List>.value(
        utf8.encode(
          '{"token":"tok-123","user":{"phone":"08012345678"}}',
        ),
      ),
      200,
      headers: <String, String>{'content-type': 'application/json'},
    );

void main() {
  setUp(() async {
    resetAppState();
    // The sign in flow persists the session through SharedPreferences, which
    // the widget tests replace with in-memory values.
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('sign in', () {
    testWidgets('shows the fields and the actions', (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(testApp(home: const SignInScreen()));
      await settle(tester);

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Email or Phone Number'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Remember me'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Create an Account'), findsOneWidget);
    });

    testWidgets('the sign in button signs the customer in', (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(
        testApp(home: SignInScreen(apiService: _api(connectivity: _FakeConnectivity(true)))),
      );
      await settle(tester);

      await typeInto(
        tester,
        'Enter your email or phone number',
        '08012345678',
      );
      await typeInto(tester, 'Enter your password', 'password123');

      await tester.tap(find.text('Sign In'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      expect(appStore.isSignedIn, isTrue);
      expect(appStore.phone, '08012345678');
    });

    testWidgets('the sign in button shows a spinner and stops it on success',
        (tester) async {
      final completer = Completer<http.StreamedResponse>();
      final api = ApiService.withClient(
        _StubHttpClient(() => completer.future),
        connectivity: _FakeConnectivity(true),
      );

      useTallScreen(tester);
      await tester.pumpWidget(testApp(home: SignInScreen(apiService: api)));
      await settle(tester);

      await typeInto(
        tester,
        'Enter your email or phone number',
        '08012345678',
      );
      await typeInto(tester, 'Enter your password', 'password123');

      await tester.tap(find.text('Sign In'));
      await tester.pump();

      // The button swaps its label for a spinner while the request runs.
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Sign In'), findsNothing);

      completer.complete(
        http.StreamedResponse(
          Stream<Uint8List>.value(
            utf8.encode(
              '{"token":"tok-123","user":{"phone":"08012345678"}}',
            ),
          ),
          200,
          headers: <String, String>{'content-type': 'application/json'},
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      expect(appStore.isSignedIn, isTrue);
      expect(appStore.phone, '08012345678');
    });

    testWidgets('the sign in button shows the offline message when there is no '
        'connection', (tester) async {
      final api = ApiService.withClient(
        _StubHttpClient(() => _signInResponse()),
        connectivity: _FakeConnectivity(false),
      );

      useTallScreen(tester);
      await tester.pumpWidget(testApp(home: SignInScreen(apiService: api)));
      await settle(tester);

      await typeInto(
        tester,
        'Enter your email or phone number',
        '08012345678',
      );
      await typeInto(tester, 'Enter your password', 'password123');

      await tester.tap(find.text('Sign In'));
      await settle(tester);

      expect(
        find.text('No internet connection. Please check your connection.'),
        findsOneWidget,
      );
      // The customer stays on the form instead of being left on a spinner.
      expect(appStore.isSignedIn, isFalse);
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('the password can be hidden and shown again', (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(testApp(home: const SignInScreen()));
      await settle(tester);

      TextField field() => tester.widget<TextField>(
            find.widgetWithText(TextField, 'Enter your password'),
          );

      expect(field().obscureText, isTrue);

      await tester.tap(find.byIcon(Icons.visibility_off));
      await settle(tester);

      expect(field().obscureText, isFalse);
    });

    testWidgets('the forgot password link explains it is not available',
        (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(testApp(home: const SignInScreen()));
      await settle(tester);

      await tester.tap(find.text('Forgot Password?'));
      await settle(tester);

      expect(
        find.text(
          'Password resets require a connection to DataNaija servers. '
          'Contact support to recover your account.',
        ),
        findsOneWidget,
      );
    });
  });

  group('sign up', () {
    testWidgets('shows the fields and the actions', (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(testApp(home: const SignUpScreen()));
      await settle(tester);

      expect(find.text('Create Account'), findsWidgets);
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email or Phone Number'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Already have an account?'), findsOneWidget);
    });

    testWidgets('the create account button creates the account',
        (tester) async {
      useTallScreen(tester);
      await tester.pumpWidget(
        testApp(home: SignUpScreen(apiService: _api(connectivity: _FakeConnectivity(true)))),
      );
      await settle(tester);

      await typeInto(tester, 'Enter your full name', 'Chinedu Okafor');
      await typeInto(
        tester,
        'Enter your email or phone number',
        '08012345678',
      );
      await typeInto(tester, 'Create a strong password', 'password123');

      await tester.tap(find.text('Create Account'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      expect(appStore.isSignedIn, isTrue);
      expect(appStore.phone, '08012345678');
    });
  });
}
