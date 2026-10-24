import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/presentation/routes/app_routes.dart';
import 'package:data_naija_app/presentation/widgets/app_logo.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:flutter/material.dart';

/// Splash screen — shows branding, then sends the customer to the right
/// starting point: onboarding the first time, sign in afterwards.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // A short brand moment is enough. The old 2.2s wait made every launch
    // feel slow for no benefit.
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;

      final String next;
      if (appStore.isSignedIn) {
        next = AppRoutes.home;
      } else if (appStore.onboardingSeen) {
        next = AppRoutes.signIn;
      } else {
        next = AppRoutes.onboarding;
      }
      appStore.setScreen(next);
      Navigator.of(context).pushReplacementNamed(next);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Full brand lockup: app mark + "Data Naija" wordmark.
            const AppLogo(size: 190, variant: LogoVariant.lockup),
            const SizedBox(height: 16),
            const Text(
              'Fast · Secure · Reliable',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: kTextMuted,
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Buy Data · Buy Airtime · Fund Wallet',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: kMutedOnWallet,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
