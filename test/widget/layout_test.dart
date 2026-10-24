// Layout regression tests.
//
// Widget tests draw every character as a fixed-size box by default, which
// makes text far wider than it is on a device. These tests load a real
// proportional font (under the family the app asks for) and lay every
// screen out on phone-sized viewports, so an overflow here is a real one
// rather than a test-font artefact.

import 'dart:io';

import 'package:data_naija_app/presentation/screens/auto_buy_list_screen.dart';
import 'package:data_naija_app/presentation/screens/auto_buy_setup_screen.dart';
import 'package:data_naija_app/presentation/screens/buy_data_screen.dart';
import 'package:data_naija_app/presentation/screens/fund_wallet_screen.dart';
import 'package:data_naija_app/presentation/screens/help_screen.dart';
import 'package:data_naija_app/presentation/screens/home_screen.dart';
import 'package:data_naija_app/presentation/screens/kyc_screen.dart';
import 'package:data_naija_app/presentation/screens/notifications_screen.dart';
import 'package:data_naija_app/presentation/screens/onboarding_screen.dart';
import 'package:data_naija_app/presentation/screens/profile_screen.dart';
import 'package:data_naija_app/presentation/screens/referral_screen.dart';
import 'package:data_naija_app/presentation/screens/review_purchase_screen.dart';
import 'package:data_naija_app/presentation/screens/security_screen.dart';
import 'package:data_naija_app/presentation/screens/select_bundle_screen.dart';
import 'package:data_naija_app/presentation/screens/signin_screen.dart';
import 'package:data_naija_app/presentation/screens/signup_screen.dart';
import 'package:data_naija_app/presentation/screens/success_screen.dart';
import 'package:data_naija_app/presentation/screens/transactions_screen.dart';
import 'package:data_naija_app/presentation/screens/wallet_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';
import '../test_app.dart';

/// The phone sizes we check. 320 is the narrowest screen Flutter still
/// targets; 412 is a common larger Android phone.
const List<Size> _phoneSizes = [
  Size(320, 568),
  Size(360, 640),
  Size(390, 844),
  Size(412, 915),
];

/// System text sizes that must not break the layout. Android and iOS both
/// expose a slider above the default, so the screens are checked at the
/// common accessibility settings instead of only at 1.0.
const List<double> _textScales = [1.3, 1.5];

/// Candidate real font files used so text measures like it does on a
/// device. The first one that exists wins.
const List<List<String>> _fontCandidates = [
  ['C:/Windows/Fonts/segoeui.ttf', 'C:/Windows/Fonts/segoeuib.ttf'],
  ['/System/Library/Fonts/Helvetica.ttc'],
  ['/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'],
];

/// Registers a real proportional font under the family the app requests.
///
/// Returns false when no font file is available, in which case the layout
/// tests still run but with the fixed-width test font.
Future<bool> _loadRealFont() async {
  for (final candidates in _fontCandidates) {
    final files = candidates.where((p) => File(p).existsSync()).toList();
    if (files.isEmpty) continue;

    final loader = FontLoader('Plus Jakarta Sans');
    for (final path in files) {
      final bytes = File(path).readAsBytesSync();
      loader.addFont(Future.value(ByteData.sublistView(bytes)));
    }
    await loader.load();
    return true;
  }
  return false;
}

/// The screens that fit in a phone-sized viewport without scrolling
/// horizontally, with the widest possible content.
final Map<String, Widget Function()> _screens = {
  'onboarding': () => const OnboardingScreen(),
  'sign in': () => const SignInScreen(),
  'sign up': () => const SignUpScreen(),
  'home': () => const HomeScreen(),
  'buy data': () => const BuyDataScreen(),
  'select bundle': () => const SelectBundleScreen(),
  'review purchase': () => const ReviewPurchaseScreen(),
  'success': () => const SuccessScreen(),
  'wallet': () => const WalletScreen(),
  'fund wallet': () => const FundWalletScreen(),
  'transactions': () => const TransactionsScreen(),
  'notifications': () => const NotificationsScreen(),
  'profile': () => const ProfileScreen(),
  'help': () => const HelpScreen(),
  'security': () => const SecurityScreen(),
  'referral': () => const ReferralScreen(),
  'kyc': () => const KycScreen(),
  'auto-buy list': () => const AutoBuyListScreen(),
  'auto-buy setup': () => const AutoBuySetupScreen(),
};

void main() {
  setUpAll(() async {
    await _loadRealFont();
  });

  setUp(resetAppState);

  for (final size in _phoneSizes) {
    group('at $size', () {
      for (final entry in _screens.entries) {
        testWidgets('${entry.key} lays out without overflow', (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          await tester.pumpWidget(testApp(home: entry.value()));
          await settle(tester);

          expect(tester.takeException(), isNull);
        });
      }
    });
  }

  // The bottom of the phone range is where large text is tightest, so the
  // scaled checks run at 320 and at the prototype artboard width.
  for (final scale in _textScales) {
    for (final size in const [Size(320, 568), Size(390, 844)]) {
      group('at $size with text scale $scale', () {
        for (final entry in _screens.entries) {
          testWidgets('${entry.key} lays out without overflow',
              (tester) async {
            tester.view.physicalSize = size;
            tester.view.devicePixelRatio = 1.0;
            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);
            tester.platformDispatcher.textScaleFactorTestValue = scale;
            addTearDown(
                tester.platformDispatcher.clearTextScaleFactorTestValue);

            await tester.pumpWidget(testApp(home: entry.value()));
            await settle(tester);

            expect(tester.takeException(), isNull);
          });
        }
      });
    }
  }
}
