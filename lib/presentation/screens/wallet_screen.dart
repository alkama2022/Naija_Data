import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/data/mock/mock_data.dart';
import 'package:data_naija_app/presentation/routes/app_routes.dart';
import 'package:data_naija_app/presentation/widgets/app_link_button.dart';
import 'package:data_naija_app/presentation/widgets/app_state_listener.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:data_naija_app/presentation/widgets/transaction_item.dart';
import 'package:data_naija_app/presentation/widgets/wallet_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wallet screen — balance, fund wallet, history, recent activity.
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with AppStateListener<WalletScreen> {
  @override
  Widget build(BuildContext context) {
    final recentTransactions = appRepository.transactions;

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                BackButton(
                  onPressed: () => Navigator.of(context)
                      .pushReplacementNamed(AppRoutes.home),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Wallet',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: kTextPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 26),
            WalletCard(
              balance: appRepository.balance,
              hideBalance: appStore.balanceHidden,
              onToggleVisibility: appStore.toggleBalanceVisibility,
              onFund: () {
                Navigator.of(context).pushNamed(AppRoutes.fundWallet);
              },
              accountNumber:
                  appStore.kycVerified ? MockData.defaultAccountNumber : null,
              onCopyAccount: appStore.kycVerified
                  ? () async {
                      await Clipboard.setData(
                        const ClipboardData(
                          text: MockData.defaultAccountNumber,
                        ),
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Account number copied'),
                        ),
                      );
                    }
                  : null,
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Wallet Activity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: kTextPrimary,
                  ),
                ),
                AppLinkButton(
                  child: const Text('See All'),
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.transactions),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: recentTransactions.isEmpty
                  ? const Center(
                      child: Text(
                        'No wallet activity yet.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: kTextMuted,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: recentTransactions.take(5).length,
                      itemBuilder: (context, i) {
                        final transaction = recentTransactions[i];
                        return TransactionItem(
                          transaction: transaction,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              AppRoutes.transactionDetail,
                              arguments: transaction,
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
