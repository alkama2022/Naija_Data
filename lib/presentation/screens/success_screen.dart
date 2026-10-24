import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/core/utils/currency_formatter.dart';
import 'package:data_naija_app/data/mock/mock_data.dart';
import 'package:data_naija_app/presentation/routes/app_routes.dart';
import 'package:data_naija_app/presentation/widgets/app_button.dart';
import 'package:data_naija_app/presentation/widgets/app_card.dart';
import 'package:data_naija_app/presentation/widgets/app_link_button.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:flutter/material.dart';

/// Purchase Successful screen — confirmation with receipt details.
class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final net = MockData.networks.firstWhere(
      (n) => n.name == appStore.selectedNetwork,
    );
    final chosenText =
        '${appStore.dataType} · ${appStore.selectedGb} - ${appStore.selectedDays}';
    // The purchase is recorded before this screen is shown, so the receipt
    // shows the real reference and amount instead of inventing them.
    final transaction = appRepository.lastTransaction;
    final priceText =
        formatNaira(transaction?.amount.abs() ?? appStore.selectedPrice);
    final ref = transaction?.ref ?? '—';
    final phone = transaction?.phone ?? appStore.phone;

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(kPagePadding),
            child: Column(
              children: [
                const SizedBox(height: 60),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A7A4C),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 36,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Purchase Successful',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: kTextPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'You have successfully purchased ${appStore.selectedGb} data for ${net.name}.',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: kTextMuted,
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _kvRow('Phone Number', phone),
                      _kvRow('Data Bundle', chosenText),
                      _kvRow('Amount', priceText),
                      _kvRow('Reference ID', ref),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  child: const Text('View Transaction'),
                  onPressed: () {
                    if (transaction == null) {
                      Navigator.of(context)
                          .pushReplacementNamed(AppRoutes.transactions);
                      return;
                    }
                    Navigator.of(context).pushReplacementNamed(
                      AppRoutes.transactionDetail,
                      arguments: transaction,
                    );
                  },
                ),
                const SizedBox(height: 8),
                AppLinkButton(
                  fullWidth: true,
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
                  },
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _kvRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: kTextMuted,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: kTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
