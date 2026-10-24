import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/core/utils/currency_formatter.dart';
import 'package:data_naija_app/presentation/widgets/app_button.dart';
import 'package:data_naija_app/presentation/widgets/app_link_button.dart';
import 'package:flutter/material.dart';

/// Wallet balance card (`.wal` in the prototype) with gradient background.
class WalletCard extends StatelessWidget {
  const WalletCard({
    super.key,
    required this.balance,
    this.hideBalance = false,
    this.onToggleVisibility,
    this.onFund,
    this.accountNumber,
    this.onCopyAccount,
  });

  final int balance;
  final bool hideBalance;
  final VoidCallback? onToggleVisibility;
  final VoidCallback? onFund;
  final String? accountNumber;
  final VoidCallback? onCopyAccount;

  @override
  Widget build(BuildContext context) {
    final displayBalance = hideBalance ? '₦ ••••••' : formatNaira(balance);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [kWalletGradientStart, kWalletGradientEnd],
        ),
        borderRadius: BorderRadius.circular(kBorderRadiusWallet),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Wallet Balance',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: kMutedOnWallet,
                      fontWeight: FontWeight.w500,
                      fontSize: kFontSizeLabel,
                    ),
              ),
              GestureDetector(
                onTap: onToggleVisibility,
                child: Icon(
                  hideBalance ? Icons.visibility_off : Icons.visibility,
                  color: kMutedOnWallet,
                  size: kBigIconSize,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            displayBalance,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: kWeightExtraBold,
              color: kTextOnAccent,
              letterSpacing: -0.02,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  variant: ButtonVariant.primaryWhite,
                  onPressed: onFund,
                  child: const Text(
                    'Fund Wallet',
                    style: TextStyle(
                      fontSize: kFontSizeButton,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (accountNumber != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$kMockBankName · $accountNumber',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: kTextOnAccent,
                    ),
                  ),
                  AppLinkButton(
                    onPressed: onCopyAccount,
                    child: const Text(
                      'Copy',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: kTextOnAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
