// Test helper: wraps screens in MaterialApp with all routes registered.
import 'dart:convert';
import 'dart:typed_data';

import 'package:data_naija_app/core/theme/app_theme.dart';
import 'package:data_naija_app/core/utils/connectivity_service.dart';
import 'package:data_naija_app/data/models/auto_buy_schedule.dart';
import 'package:data_naija_app/data/models/service.dart';
import 'package:data_naija_app/data/services/api_service.dart';
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
import 'package:data_naija_app/presentation/screens/service_purchase_screen.dart';
import 'package:data_naija_app/presentation/screens/signin_screen.dart';
import 'package:data_naija_app/presentation/screens/signup_screen.dart';
import 'package:data_naija_app/presentation/screens/success_screen.dart';
import 'package:data_naija_app/presentation/screens/transaction_detail_screen.dart';
import 'package:data_naija_app/presentation/screens/transactions_screen.dart';
import 'package:data_naija_app/presentation/screens/wallet_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class _TestHttpClient extends http.BaseClient {
  final Future<http.StreamedResponse> Function(Uri) handler;

  _TestHttpClient(this.handler);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async =>
      handler(request.url);
}

class _TestConnectivity extends ConnectivityService {
  @override
  Future<bool> hasConnection({bool force = false}) async => true;
}

Future<http.StreamedResponse> _testTransactions(Uri uri) async {
  if (uri.path.contains('/wallet/transactions')) {
    return http.StreamedResponse(
      Stream<Uint8List>.value(
        Uint8List.fromList(
          utf8.encode(
            jsonEncode(<Map<String, dynamic>>[
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
            ]),
          ),
        ),
      ),
      200,
      headers: <String, String>{'content-type': 'application/json'},
    );
  }

  if (uri.path.contains('/wallet/balance')) {
    return http.StreamedResponse(
      Stream<Uint8List>.value(
        Uint8List.fromList(
          utf8.encode(jsonEncode(<String, dynamic>{
            'balance': 5000,
            'balanceHidden': false,
          })),
        ),
      ),
      200,
      headers: <String, String>{'content-type': 'application/json'},
    );
  }

  return http.StreamedResponse(
    Stream<Uint8List>.value(Uint8List.fromList(utf8.encode(jsonEncode(<String, dynamic>{})))),
    404,
    headers: <String, String>{'content-type': 'application/json'},
  );
}

final ApiService testApi = ApiService.withClient(
  _TestHttpClient(_testTransactions),
  connectivity: _TestConnectivity(),
);

/// Builds the app the way `main.dart` does.
///
/// The real app rebuilds when the store changes, so the tests do the
/// same. Without this a screen that reads the store would not update.
Widget testApp({Widget? home}) {
  return ListenableBuilder(
    listenable: appStateListenable,
    builder: (context, child) {
      return MaterialApp(
        theme: buildTheme(),
        home: home,
        routes: {
          AppRoutes.onboarding: (_) => const OnboardingScreen(),
          AppRoutes.signIn: (_) => const SignInScreen(),
          AppRoutes.signUp: (_) => const SignUpScreen(),
          AppRoutes.home: (_) => const HomeScreen(),
          AppRoutes.buyData: (_) => const BuyDataScreen(),
          AppRoutes.servicePurchase: (context) => ServicePurchaseScreen(
                kind: ModalRoute.of(context)?.settings.arguments
                        as ServiceKind? ??
                    ServiceKind.airtime,
              ),
          AppRoutes.buyAirtime: (_) => const ServicePurchaseScreen(
                kind: ServiceKind.airtime,
              ),
          AppRoutes.cableTv: (_) => const ServicePurchaseScreen(
                kind: ServiceKind.cable,
              ),
          AppRoutes.electricity: (_) => const ServicePurchaseScreen(
                kind: ServiceKind.electricity,
              ),
          AppRoutes.bulkSms: (_) => const ServicePurchaseScreen(
                kind: ServiceKind.bulkSms,
              ),
          AppRoutes.eduPins: (_) => const ServicePurchaseScreen(
                kind: ServiceKind.eduPin,
              ),
          AppRoutes.examPins: (_) => const ServicePurchaseScreen(
                kind: ServiceKind.eduPin,
              ),
          AppRoutes.rechargePin: (_) => const ServicePurchaseScreen(
                kind: ServiceKind.rechargePin,
              ),
          AppRoutes.airtimeSwap: (_) => const ServicePurchaseScreen(
                kind: ServiceKind.swarp,
              ),
          AppRoutes.selectBundle: (_) => const SelectBundleScreen(),
          AppRoutes.reviewPurchase: (_) => const ReviewPurchaseScreen(),
          AppRoutes.processing: (_) => const ProcessingScreen(),
          AppRoutes.success: (_) => const SuccessScreen(),
          AppRoutes.wallet: (_) => WalletScreen(apiService: testApi),
          AppRoutes.fundWallet: (_) => const FundWalletScreen(),
          AppRoutes.transactions: (_) => TransactionsScreen(apiService: testApi),
          AppRoutes.transactionDetail: (_) => const TransactionDetailScreen(),
          AppRoutes.notifications: (_) => const NotificationsScreen(),
          AppRoutes.profile: (_) => const ProfileScreen(),
          AppRoutes.help: (_) => const HelpScreen(),
          AppRoutes.security: (_) => const SecurityScreen(),
          AppRoutes.referral: (_) => const ReferralScreen(),
          AppRoutes.kyc: (_) => const KycScreen(),
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
