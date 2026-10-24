import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/core/utils/currency_formatter.dart';
import 'package:data_naija_app/data/mock/mock_data.dart';
import 'package:data_naija_app/presentation/routes/app_routes.dart';
import 'package:data_naija_app/presentation/widgets/app_button.dart';
import 'package:data_naija_app/presentation/widgets/app_card.dart';
import 'package:data_naija_app/presentation/widgets/app_link_button.dart';
import 'package:data_naija_app/presentation/widgets/app_state_listener.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:flutter/material.dart';

/// Review Purchase screen — summary of data purchase before confirmation.
class ReviewPurchaseScreen extends StatefulWidget {
  const ReviewPurchaseScreen({super.key});

  @override
  State<ReviewPurchaseScreen> createState() => _ReviewPurchaseScreenState();
}

class _ReviewPurchaseScreenState extends State<ReviewPurchaseScreen>
    with AppStateListener<ReviewPurchaseScreen> {
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final net = MockData.networks.firstWhere(
      (n) => n.name == appStore.selectedNetwork,
    );
    final chosenText =
        '${appStore.dataType} · ${appStore.selectedGb} - ${appStore.selectedDays}';
    final priceText = formatNaira(appStore.selectedPrice);

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  BackButton(
                    onPressed: () => Navigator.of(context)
                        .pushReplacementNamed(AppRoutes.selectBundle),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Review Purchase',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: kTextPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: net.bgColor,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            net.abbreviation,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: net.fgColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        net.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: kTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 18),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _kvRow('Phone Number', appStore.phone),
                    _kvRow('Data Bundle', chosenText),
                    _kvRow('Price', priceText),
                    _kvRow('Service Fee', '₦0'),
                    const Divider(height: 1),
                    _kvRow('Total', priceText, isTotal: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.all(kPagePadding),
                child: Column(
                  children: [
                    AppButton(
                      onPressed: _confirmPurchase,
                      child: const Text('Confirm Purchase'),
                    ),
                    const SizedBox(height: 8),
                    AppLinkButton(
                      fullWidth: true,
                      onPressed: () => Navigator.of(context)
                          .pushReplacementNamed(AppRoutes.selectBundle),
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _kvRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
              color: isTotal ? kTextPrimary : kTextMuted,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isTotal ? const Color(0xFF0B7A4B) : kTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmPurchase() async {
    // Guard against a double tap creating two purchases.
    if (_submitting) return;
    final price = appStore.selectedPrice;
    final balance = appRepository.balance;
    // The fingerprint only changes how the purchase is authorised; the
    // wallet still has to be able to pay for it.
    if (balance < price) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough balance. Fund your wallet.'),
        ),
      );
      return;
    }

    if (appStore.fingerprintEnabled) {
      // No biometric plugin in the demo, so ask for the same confirmation
      // the device prompt would provide.
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Confirm with fingerprint',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: const Text(
            'Touch the sensor to authorise this purchase.',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: kTextMuted,
              height: 1.45,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Use fingerprint'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }

    setState(() => _submitting = true);
    // Replace the review screen so Back from the receipt cannot land on a
    // stale confirmation and charge the wallet a second time.
    Navigator.of(context).pushReplacementNamed(AppRoutes.processing);
  }
}
