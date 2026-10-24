// Tests for the sign in and sign up screens.

import 'package:data_naija_app/presentation/screens/signin_screen.dart';
import 'package:data_naija_app/presentation/screens/signup_screen.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';
import '../test_app.dart';

void main() {
  setUp(resetAppState);

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
      await tester.pumpWidget(testApp(home: const SignInScreen()));
      await settle(tester);

      await typeInto(
        tester,
        'Enter your email or phone number',
        '08012345678',
      );
      await typeInto(tester, 'Enter your password', 'password123');

      await tester.tap(find.text('Sign In'));
      await settle(tester);

      expect(appStore.isSignedIn, isTrue);
      expect(appStore.phone, '08012345678');
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
      await tester.pumpWidget(testApp(home: const SignUpScreen()));
      await settle(tester);

      await typeInto(tester, 'Enter your full name', 'Chinedu Okafor');
      await typeInto(
        tester,
        'Enter your email or phone number',
        '08012345678',
      );
      await typeInto(tester, 'Create a strong password', 'password123');

      await tester.tap(find.text('Create Account'));
      await settle(tester);

      expect(appStore.isSignedIn, isTrue);
      expect(appStore.phone, '08012345678');
    });
  });
}
