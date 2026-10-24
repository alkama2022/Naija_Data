// Widget and unit tests for the DataNaija application.

import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/core/utils/currency_formatter.dart';
import 'package:data_naija_app/core/utils/phone_validator.dart';
import 'package:data_naija_app/core/utils/url_launcher_helper.dart';
import 'package:data_naija_app/presentation/widgets/whatsapp_contact_option.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('WhatsApp support option renders correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WhatsAppSupportOption(),
        ),
      ),
    );

    expect(find.text('Chat with Support'), findsOneWidget);
    expect(
      find.text(
          'Need help? Chat with our support team directly on WhatsApp.\n$kWhatsAppPhoneDisplay'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.chat), findsOneWidget);
  });

  testWidgets('WhatsApp channel option renders correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WhatsAppChannelOption(),
        ),
      ),
    );

    expect(find.text('Follow Our WhatsApp Channel'), findsOneWidget);
    expect(
      find.text(
        'Stay updated with announcements, important information, and the latest news.',
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.update), findsOneWidget);
  });

  test('WhatsApp constants match expected values', () {
    expect(kWhatsAppPhoneNumber, '2348126573474');
    expect(kWhatsAppPhoneDisplay, '+234 812 657 3474');
    expect(kWhatsAppChannelUrl,
        'https://whatsapp.com/channel/0029Vb9lWtd2Jl8GYqy2YP0r');
    expect(kWhatsAppDirectLink, 'https://wa.me/2348126573474');
    expect(kWhatsAppSupportMessage,
        'Hello, I need assistance with your application.');
  });

  test('UrlLauncher helper exposes correct methods', () {
    expect(UrlLauncher.contactSupport, isA<Future<bool> Function()>());
    expect(UrlLauncher.followChannel, isA<Future<bool> Function()>());
    expect(UrlLauncher.launch, isA<Future<bool> Function(String)>());
  });

  group('phone validator', () {
    test('validates correct Nigerian phone numbers', () {
      expect(isValidNigerianPhone('08012345678'), isTrue);
      expect(isValidNigerianPhone('07012345678'), isTrue);
      expect(isValidNigerianPhone('09012345678'), isTrue);
      expect(isValidNigerianPhone('08112345678'), isTrue);
      expect(isValidNigerianPhone('09112345678'), isTrue);
    });

    test('rejects invalid Nigerian phone numbers', () {
      expect(isValidNigerianPhone('06012345678'), isFalse);
      expect(isValidNigerianPhone('0801234567'), isFalse);
      expect(isValidNigerianPhone('080123456789'), isFalse);
      expect(isValidNigerianPhone(''), isFalse);
      expect(isValidNigerianPhone(null), isFalse);
      expect(isValidNigerianPhone('abcdefghijk'), isFalse);
    });

    test('strips non-digit characters', () {
      expect(isValidNigerianPhone('080-1234-5678'), isTrue);
      expect(isValidNigerianPhone('080 1234 5678'), isTrue);
    });
  });

  group('currency formatter', () {
    test('formats naira amounts correctly', () {
      expect(formatNaira(1000), '₦1,000.00');
      expect(formatNaira(5000), '₦5,000.00');
      expect(formatNaira(1500), '₦1,500.00');
    });

    test('uses absolute value for negative amounts', () {
      expect(formatNaira(-1000), '₦1,000.00');
      expect(formatNaira(-5000), '₦5,000.00');
    });

    test('formats whole numbers without decimals', () {
      expect(formatNairaWhole(1000), '₦1,000');
      expect(formatNairaWhole(5000), '₦5,000');
    });
  });
}
