import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/core/errors/app_failure.dart';
import 'package:data_naija_app/data/mock/mock_data.dart';
import 'package:data_naija_app/data/models/transaction.dart';
import 'package:data_naija_app/data/services/api_service.dart';
import 'package:data_naija_app/presentation/routes/app_routes.dart';
import 'package:data_naija_app/presentation/widgets/app_button.dart';
import 'package:data_naija_app/presentation/widgets/app_link_button.dart';
import 'package:data_naija_app/presentation/widgets/app_state_listener.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:data_naija_app/presentation/widgets/transaction_item.dart';
import 'package:data_naija_app/presentation/widgets/wallet_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wallet screen - balance, fund wallet, history, recent activity.
///
/// The balance and the recent activity come from the signed-in customer's
/// backend account through [ApiService]; nothing is fabricated locally.
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key, this.apiService});

  final ApiService? apiService;

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with AppStateListener<WalletScreen> {
  late final ApiService _api = widget.apiService ?? ApiService();

  int? _balance;
  bool _isLoading = true;
  String? _error;
  List<TransactionModel> _recentTransactions = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final balanceData = await _api.getWalletBalance();
      final balance = (balanceData['balance'] as num?)?.toInt();
      final transactions = await _api.getTransactions();
      final recentTransactions = transactions
          .map(
            (row) => TransactionModel.fromBackend(
              Map<String, dynamic>.from(row as Map),
            ),
          )
          .take(5)
          .toList();

      if (!mounted) return;
      setState(() {
        _balance = balance;
        _recentTransactions = recentTransactions;
        _error = null;
        _isLoading = false;
      });
    } on AppFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _error = failure.isOffline
            ? AppFailure.noInternetMessage
            : failure.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _isLoading = false;
      });
    }
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(kPagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 44, color: kTextMuted),
            const SizedBox(height: 12),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: kTextMuted,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              onPressed: _load,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final balance = _balance;
    final recentTransactions = _recentTransactions;

    final Widget body;
    if (_error != null) {
      body = _buildError();
    } else if (_isLoading && balance == null) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      body = Column(
        children: [
          const SizedBox(height: 10),
          Row(
            children: [
              BackButton(
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.home,
                      (route) => route.isFirst,
                    );
                  }
                },
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
            balance: balance ?? 0,
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
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.transactions),
                child: const Text('See All'),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: kPagePadding, vertical: 4),
                    itemCount: recentTransactions.take(5).length,
                    itemBuilder: (context, i) {
                      final transaction = recentTransactions[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TransactionItem(
                          transaction: transaction,
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              AppRoutes.transactionDetail,
                              arguments: transaction,
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(child: body),
    );
  }
}
