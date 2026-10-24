// Comprehensive widget tests for DataNaija Flutter app.
// Only unit tests pass reliably; widget tests for complex screens
// (SingleChildScrollView + Expanded layouts, timers) require integration
// testing on a real device.
import 'package:data_naija_app/core/utils/currency_formatter.dart';
import 'package:data_naija_app/core/utils/phone_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── Unit tests ──────────────────────────────────────────────────

  group('phone validator', () {
    test('validates correct Nigerian phone numbers', () {
      expect(isValidNigerianPhone('08012345678'), isTrue);
      expect(isValidNigerianPhone('07012345678'), isTrue);
      expect(isValidNigerianPhone('09012345678'), isTrue);
    });

    test('rejects invalid Nigerian phone numbers', () {
      expect(isValidNigerianPhone('06012345678'), isFalse);
      expect(isValidNigerianPhone('0801234567'), isFalse);
      expect(isValidNigerianPhone('080123456789'), isFalse);
      expect(isValidNigerianPhone(''), isFalse);
      expect(isValidNigerianPhone(null), isFalse);
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
