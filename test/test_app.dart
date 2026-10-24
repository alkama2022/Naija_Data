// Test helper: wraps screens in MaterialApp with all routes registered.
import 'package:data_naija_app/data/models/auto_buy_schedule.dart';
import 'package:data_naija_app/presentation/routes/app_routes.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:data_naija_app/presentation/screens/auto_buy_detail_screen.dart';
import 'package:data_naija_app/presentation/screens/auto_buy_list_screen.dart';
import 'package:data_naija_app/presentation/screens/auto_buy_setup_screen.dart';
import 'package:data_naija_app/presentation/screens/buy_data_screen.dart';
import 'package:data_naija_app/presentation/screens/fund_wallet_screen.dart';
import 'package:data_naija_app/presentation/screens/help_screen.dart';
import 'package:data_naija_app/presentation/screens/home_screen.dart';
import 'package:data_naija_app/presentation/screens/kyc_screen.dart';
import 'package:data_naija_app/presentation/screens/notifications_screen.dart';
import 'package:data_naija_app/presentation/screens/onboarding_screen.dart';
import 'package:data_naija_app/presentation/screens/processing_screen.dart';
import 'package:data_naija_app/presentation/screens/profile_screen.dart';
import 'package:data_naija_app/presentation/screens/referral_screen.dart';
import 'package:data_naija_app/presentation/screens/review_purchase_screen.dart';
import 'package:data_naija_app/presentation/screens/security_screen.dart';
import 'package:data_naija_app/presentation/screens/select_bundle_screen.dart';
import 'package:data_naija_app/presentation/screens/signin_screen.dart';
import 'package:data_naija_app/presentation/screens/signup_screen.dart';
import 'package:data_naija_app/presentation/screens/success_screen.dart';
import 'package:data_naija_app/presentation/screens/transaction_detail_screen.dart';
import 'package:data_naija_app/presentation/screens/transactions_screen.dart';
import 'package:data_naija_app/presentation/screens/wallet_screen.dart';
import 'package:flutter/material.dart';

/// Builds the app the way `main.dart` does.
///
/// The real app rebuilds when the store changes, so the tests do the
/// same. Without this a screen that reads the store would not update.
Widget testApp({Widget? home}) {
  return ListenableBuilder(
    listenable: appStateListenable,
    builder: (context, child) {
      return MaterialApp(
        home: home,
        routes: {
          AppRoutes.onboarding: (_) => const OnboardingScreen(),
          AppRoutes.signIn: (_) => const SignInScreen(),
          AppRoutes.signUp: (_) => const SignUpScreen(),
          AppRoutes.home: (_) => const HomeScreen(),
          AppRoutes.buyData: (_) => const BuyDataScreen(),
          AppRoutes.selectBundle: (_) => const SelectBundleScreen(),
          AppRoutes.reviewPurchase: (_) => const ReviewPurchaseScreen(),
          AppRoutes.processing: (_) => const ProcessingScreen(),
          AppRoutes.success: (_) => const SuccessScreen(),
          AppRoutes.wallet: (_) => const WalletScreen(),
          AppRoutes.fundWallet: (_) => const FundWalletScreen(),
          AppRoutes.transactions: (_) => const TransactionsScreen(),
          AppRoutes.transactionDetail: (_) => const TransactionDetailScreen(),
          AppRoutes.notifications: (_) => const NotificationsScreen(),
          AppRoutes.profile: (_) => const ProfileScreen(),
          AppRoutes.help: (_) => const HelpScreen(),
          AppRoutes.security: (_) => const SecurityScreen(),
          AppRoutes.referral: (_) => const ReferralScreen(),
          AppRoutes.kyc: (_) => const KycScreen(),
          AppRoutes.autoBuy: (_) => const AutoBuyListScreen(),
          AppRoutes.autoBuyList: (_) => const AutoBuyListScreen(),
          AppRoutes.autoBuySetup: (context) => AutoBuySetupScreen(
                existing: ModalRoute.of(context)?.settings.arguments
                    as AutoBuySchedule?,
              ),
          AppRoutes.autoBuyDetail: (context) => AutoBuyDetailScreen(
                scheduleId:
                    ModalRoute.of(context)?.settings.arguments as String,
              ),
        },
      );
    },
  );
}
