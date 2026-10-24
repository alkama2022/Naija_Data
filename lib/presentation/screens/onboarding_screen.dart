import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/presentation/routes/app_routes.dart';
import 'package:data_naija_app/presentation/widgets/app_logo.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:data_naija_app/presentation/widgets/app_button.dart';
import 'package:data_naija_app/presentation/widgets/app_link_button.dart';
import 'package:flutter/material.dart';

/// Two-slide onboarding carousel (`.ob` in the prototype).
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _page = 0; // 0 or 1

  @override
  Widget build(BuildContext context) {
    final isFirst = _page == 0;

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isFirst) ...[
                      // Brand mark shown on the first slide.
                      const AppLogo(size: 150),
                    ] else ...[
                      Container(
                        width: 230,
                        height: 230,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F4EC),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.account_balance_wallet,
                            size: 80,
                            color: kAccent,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    Text(
                      isFirst
                          ? 'Buy Data, Airtime and More'
                          : 'Your Wallet, Your Control',
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                        color: kTextPrimary,
                        letterSpacing: -0.02,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        isFirst
                            ? 'Stay connected with affordable data and airtime on all networks in Nigeria.'
                            : 'Fund your wallet and enjoy faster, easier transactions anytime, anywhere.',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: kTextMuted,
                          height: 1.45,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isFirst ? kAccent : const Color(0xFFCFD9D3),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isFirst ? const Color(0xFFCFD9D3) : kAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppButton(
                child: const Text('Continue'),
                onPressed: () {
                  if (isFirst) {
                    setState(() => _page = 1);
                  } else {
                    appStore.setOnboardingSeen(true);
                    Navigator.of(context)
                        .pushReplacementNamed(AppRoutes.signIn);
                  }
                },
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AppLinkButton(
                child: const Text('Skip'),
                onPressed: () {
                  appStore.setOnboardingSeen(true);
                  Navigator.of(context).pushReplacementNamed(AppRoutes.signIn);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
