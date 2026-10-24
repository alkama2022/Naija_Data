import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/data/mock/mock_data.dart';
import 'package:data_naija_app/data/models/network.dart';
import 'package:data_naija_app/presentation/routes/app_routes.dart';
import 'package:data_naija_app/presentation/widgets/app_card.dart';
import 'package:data_naija_app/presentation/widgets/app_link_button.dart';
import 'package:data_naija_app/presentation/widgets/app_logo.dart';
import 'package:data_naija_app/presentation/widgets/app_state_listener.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:data_naija_app/presentation/widgets/transaction_item.dart';
import 'package:data_naija_app/presentation/widgets/wallet_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Home screen — greeting, wallet, quick actions, popular bundles, recent transactions.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AppStateListener<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final recentTransactions = appRepository.transactions;

    return Scaffold(
      backgroundColor: kHomeBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(kPagePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Hello, Chinedu',
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                                color: kTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Good morning!',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: kTextMuted,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0A7A4C),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Text(
                                  'CO',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    // Wallet card
                    WalletCard(
                      balance: appRepository.balance,
                      hideBalance: appStore.balanceHidden,
                      onToggleVisibility: appStore.toggleBalanceVisibility,
                      onFund: () {
                        Navigator.of(context).pushNamed(AppRoutes.fundWallet);
                      },
                      accountNumber: appStore.kycVerified
                          ? MockData.defaultAccountNumber
                          : null,
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
                    const SizedBox(height: 16),
                    // KYC nudge
                    if (!appStore.kycVerified) ...[
                      GestureDetector(
                        onTap: () =>
                            Navigator.of(context).pushNamed(AppRoutes.kyc),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                              color: const Color(0xFFF3DFA8),
                            ),
                            borderRadius: BorderRadius.circular(14),
                            color: const Color(0xFFFFF8E6),
                          ),
                          child: const Text(
                            'Verify your identity to get your funding account ›',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF5A4A12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    // Quick actions
                    Row(
                      children: [
                        _quickAction(
                          icon: const Icon(
                            Icons.data_usage,
                            size: 22,
                            color: kAccent,
                          ),
                          label: 'Buy Data',
                          onTap: () => Navigator.of(context)
                              .pushNamed(AppRoutes.buyData),
                        ),
                        _quickAction(
                          icon: const Icon(
                            Icons.phone,
                            size: 22,
                            color: kAccent,
                          ),
                          label: 'Buy Airtime',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Airtime is coming soon'),
                              ),
                            );
                          },
                        ),
                        _quickAction(
                          icon: const Icon(
                            Icons.receipt_long,
                            size: 22,
                            color: kAccent,
                          ),
                          label: 'Transactions',
                          onTap: () => Navigator.of(context)
                              .pushNamed(AppRoutes.transactions),
                        ),
                        _quickAction(
                          icon: const Icon(
                            Icons.help_outline,
                            size: 22,
                            color: kAccent,
                          ),
                          label: 'Help',
                          onTap: () =>
                              Navigator.of(context).pushNamed(AppRoutes.help),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Auto-Buy banner
                    _autoBuyBanner(),
                    const SizedBox(height: 14),
                    // Popular bundles
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Popular Data Bundles',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: kTextPrimary,
                          ),
                        ),
                        AppLinkButton(
                          child: const Text('See All'),
                          onPressed: () => Navigator.of(context)
                              .pushNamed(AppRoutes.buyData),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      // The bundle cards need the room for the network,
                      // the size, the price and the validity.
                      height: 132,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: MockData.popularBundles.length,
                        itemBuilder: (context, i) {
                          final b = MockData.popularBundles[i];
                          final net = MockData.networks.firstWhere(
                            (n) => n.name == b.network,
                          );
                          return _popularBundleCard(net, b);
                        },
                      ),
                    ),
                    const SizedBox(height: 14),
                    // Recent transactions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Transactions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: kTextPrimary,
                          ),
                        ),
                        AppLinkButton(
                          child: const Text('See All'),
                          onPressed: () => Navigator.of(context)
                              .pushNamed(AppRoutes.transactions),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    AppCard(
                      padding: const EdgeInsets.all(0),
                      margin: const EdgeInsets.only(bottom: 100),
                      child: recentTransactions.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'No transactions yet.',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: kTextMuted,
                                ),
                              ),
                            )
                          : Column(
                              children: List.generate(
                                recentTransactions.take(3).length,
                                (i) => TransactionItem(
                                  transaction: recentTransactions[i],
                                  onTap: () {
                                    Navigator.of(context).pushNamed(
                                      AppRoutes.transactionDetail,
                                      arguments: recentTransactions[i],
                                    );
                                  },
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            // Bottom nav
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  /// The Auto-Buy entry point shown on the home screen.
  Widget _autoBuyBanner() {
    final active = autoBuyRepository.activeSchedules.length;

    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(AppRoutes.autoBuyList),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(width: 1.0, color: kCardBorder),
        ),
        child: Row(
          children: [
            const AppLogo(size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Auto-Buy',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: kTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    active == 0
                        ? 'Let us buy your data on a schedule'
                        : '$active active schedule'
                            '${active == 1 ? '' : 's'}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: kTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: kTextMuted),
          ],
        ),
      ),
    );
  }

  Widget _quickAction({
    required Widget icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 76,
          decoration: BoxDecoration(
            color: const Color(0xFFE6F4EC),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: kAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _popularBundleCard(NetworkModel net, PopularBundle bundle) {
    return Container(
      width: 104,
      margin: const EdgeInsets.only(right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 4),
          Text(
            bundle.network,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: kTextPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            bundle.gb,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: kTextPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          Text(
            bundle.priceText,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0B7A4B),
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 1),
          Text(
            bundle.days,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: kTextMuted,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: kNavBarHeight,
      decoration: const BoxDecoration(
        color: kSurface,
        border: Border(top: BorderSide(width: 1.0, color: kBorderLight)),
      ),
      child: Row(
        children: [
          _navItem(0, Icons.home, 'Home', AppRoutes.home),
          _navItem(1, Icons.data_usage, 'Data', AppRoutes.buyData),
          _navItem(
              2, Icons.receipt_long, 'Transactions', AppRoutes.transactions),
          _navItem(3, Icons.person, 'Profile', AppRoutes.profile),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label, String route) {
    final isActive = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedIndex = index);
          Navigator.of(context).pushNamed(route);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive ? Theme.of(context).primaryColor : kTextMuted,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isActive ? Theme.of(context).primaryColor : kTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
