import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/presentation/routes/app_routes.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:flutter/material.dart';

/// Processing screen — spinner while purchase is being processed.
class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({super.key});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    // Simulate processing then navigate to success
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      final tx = appRepository.purchaseData(
        network: appStore.selectedNetwork,
        type: '${appStore.selectedGb} - ${appStore.selectedDays}',
        price: appStore.selectedPrice,
        phone: appStore.phone,
        // The backend needs the bundle family to identify the plan and
        // to look up the real price.
        dataType: appStore.dataType,
      );
      if (tx == null) {
        // The wallet could not cover the purchase. Send the customer back
        // to the review so they can fund the wallet and try again.
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Not enough balance. Fund your wallet and retry.'),
          ),
        );
        Navigator.of(context).pushReplacementNamed(AppRoutes.reviewPurchase);
        return;
      }
      Navigator.of(context).pushReplacementNamed(AppRoutes.success);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Leaving mid-purchase would silently cancel the order.
      canPop: false,
      child: Scaffold(
        backgroundColor: kBackground,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _controller.value * 6.28,
                      child: SizedBox(
                        width: 64,
                        height: 64,
                        child: CircularProgressIndicator(
                          strokeWidth: 6,
                          valueColor: AlwaysStoppedAnimation(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 14),
                const Text(
                  'Processing...',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: kTextPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Your data purchase is being processed. Please don\'t close the app.',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: kTextMuted,
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
