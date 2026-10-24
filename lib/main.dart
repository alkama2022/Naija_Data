import 'dart:async';

import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/core/theme/app_theme.dart';
import 'package:data_naija_app/core/utils/storage_service.dart';
import 'package:data_naija_app/data/models/auto_buy_schedule.dart';
import 'package:data_naija_app/presentation/routes/app_routes.dart';
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
import 'package:data_naija_app/presentation/screens/splash_screen.dart';
import 'package:data_naija_app/presentation/screens/success_screen.dart';
import 'package:data_naija_app/presentation/screens/transaction_detail_screen.dart';
import 'package:data_naija_app/presentation/screens/transactions_screen.dart';
import 'package:data_naija_app/presentation/screens/wallet_screen.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  // The local storage holds the Auto-Buy schedules and the wallet, so it has
  // to be ready before the first screen is built.
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  appStore.restore();
  await appRepository.load();
  await autoBuyRepository.load();

  // Catch up on automatic purchases that came due while the app was closed.
  // A failure here must never stop the app from starting.
  try {
    await autoBuyRepository.runDueSchedules();
  } catch (_) {
    // The rules stay in storage and will be retried on the next run.
  }

  runApp(const DataNaijaApp());
}

class DataNaijaApp extends StatefulWidget {
  const DataNaijaApp({super.key});

  @override
  State<DataNaijaApp> createState() => _DataNaijaAppState();
}

class _DataNaijaAppState extends State<DataNaijaApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Auto-Buy runs on the server in production. Locally, catch up whenever
    // the customer comes back to the app.
    if (state == AppLifecycleState.resumed) {
      unawaited(autoBuyRepository.runDueSchedules());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only the accent rebuilds the MaterialApp. Everywhere else, screens
    // listen to the state they need themselves.
    return ValueListenableBuilder<int>(
      valueListenable: appStore.accentIndexNotifier,
      builder: (context, accentIndex, child) {
        final accentColor = kThemeAccentOptions[
            accentIndex.clamp(0, kThemeAccentOptions.length - 1)];

        return MaterialApp(
          title: 'DataNaija',
          debugShowCheckedModeBanner: false,
          theme: buildTheme(accentColor: accentColor),
          initialRoute: AppRoutes.splash,
          routes: {
            AppRoutes.splash: (context) => const SplashScreen(),
            AppRoutes.onboarding: (context) => const OnboardingScreen(),
            AppRoutes.signIn: (context) => const SignInScreen(),
            AppRoutes.signUp: (context) => const SignUpScreen(),
            AppRoutes.home: (context) => const HomeScreen(),
            AppRoutes.buyData: (context) => const BuyDataScreen(),
            AppRoutes.selectBundle: (context) => const SelectBundleScreen(),
            AppRoutes.reviewPurchase: (context) => const ReviewPurchaseScreen(),
            AppRoutes.processing: (context) => ProcessingScreen(),
            AppRoutes.success: (context) => const SuccessScreen(),
            AppRoutes.wallet: (context) => const WalletScreen(),
            AppRoutes.fundWallet: (context) => const FundWalletScreen(),
            AppRoutes.transactions: (context) => const TransactionsScreen(),
            AppRoutes.transactionDetail: (context) =>
                const TransactionDetailScreen(),
            AppRoutes.notifications: (context) => const NotificationsScreen(),
            AppRoutes.profile: (context) => ProfileScreen(),
            AppRoutes.help: (context) => const HelpScreen(),
            AppRoutes.security: (context) => SecurityScreen(),
            AppRoutes.referral: (context) => ReferralScreen(),
            AppRoutes.kyc: (context) => KycScreen(),
            AppRoutes.autoBuy: (context) => const AutoBuyListScreen(),
            AppRoutes.autoBuyList: (context) => const AutoBuyListScreen(),
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
}
