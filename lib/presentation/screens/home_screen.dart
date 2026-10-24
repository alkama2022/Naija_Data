import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/core/utils/url_launcher_helper.dart';
import 'package:data_naija_app/data/mock/mock_data.dart';
import 'package:data_naija_app/data/models/network.dart';
import 'package:data_naija_app/data/models/service.dart';
import 'package:data_naija_app/presentation/routes/app_routes.dart';
import 'package:data_naija_app/presentation/widgets/app_card.dart';
import 'package:data_naija_app/presentation/widgets/app_link_button.dart';
import 'package:data_naija_app/presentation/widgets/app_logo.dart';
import 'package:data_naija_app/presentation/widgets/app_state_listener.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:data_naija_app/presentation/widgets/service_tile.dart';
import 'package:data_naija_app/presentation/widgets/transaction_item.dart';
import 'package:data_naija_app/presentation/widgets/virtual_account_card.dart';
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
  @override
  Widget build(BuildContext context) {
    final recentTransactions = appRepository.transactions;

    return Scaffold(
      backgroundColor: kHomeBackground,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
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
                            Expanded(
                              child: Column(
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
                            ),
                            const SizedBox(width: 8),
                            Row(
                              children: [
                                SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    tooltip: 'Notifications',
                                    onPressed: () => Navigator.of(context)
                                        .pushNamed(AppRoutes.notifications),
                                    icon: const Icon(
                                      Icons.notifications_none,
                                      size: 22,
                                      color: kTextPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => Navigator.of(context)
                                      .pushNamed(AppRoutes.profile),
                                  child: Container(
                                    width: 44,
                                    height: 44,
                                    decoration: const BoxDecoration(
                                      color: kAccent,
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
                            Navigator.of(context)
                                .pushNamed(AppRoutes.fundWallet);
                          },
                          onReferral: () {
                            Navigator.of(context).pushNamed(AppRoutes.referral);
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
                        const SizedBox(height: 14),
                        _virtualAccounts(),
                        const SizedBox(height: 14),
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
                                Icons.account_balance_wallet_outlined,
                                size: 22,
                                color: kAccent,
                              ),
                              label: 'Wallet',
                              onTap: () => Navigator.of(context)
                                  .pushNamed(AppRoutes.wallet),
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
                              onTap: () => Navigator.of(context)
                                  .pushNamed(AppRoutes.help),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        // Auto-Buy and identity verification
                        _autoBuyAndVerifyRow(),
                        const SizedBox(height: 18),
                        // Services grid
                        const Text(
                          'Services',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: kTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _servicesGrid(),
                        const SizedBox(height: 14),
                        // Popular bundles
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                'Popular Data Bundles',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: kTextPrimary,
                                ),
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
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (final b in MockData.popularBundles)
                                Builder(builder: (context) {
                                  final net = MockData.networks.firstWhere(
                                    (n) => n.name == b.network,
                                  );
                                  return _popularBundleCard(net, b);
                                }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        // Recent transactions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                'Recent Transactions',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: kTextPrimary,
                                ),
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
                          margin: const EdgeInsets.only(bottom: kPagePadding),
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
                                    (i) => Column(
                                      children: [
                                        TransactionItem(
                                          transaction: recentTransactions[i],
                                          onTap: () {
                                            Navigator.of(context).pushNamed(
                                              AppRoutes.transactionDetail,
                                              arguments: recentTransactions[i],
                                            );
                                          },
                                        ),
                                        if (i <
                                            recentTransactions.take(3).length -
                                                1)
                                          const Divider(height: 1),
                                      ],
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
            // Support FAB (`.fab` in the prototype, shown on Home only).
            Positioned(
              right: 16,
              bottom: 88,
              child: _supportFab(),
            ),
          ],
        ),
      ),
    );
  }

  /// The funding accounts shown directly below the wallet.
  Widget _virtualAccounts() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Let both cards peek on wider phones, but never force a card wider
        // than the current screen. The row scrolls horizontally when the
        // second card does not fit.
        final cardWidth =
            constraints.maxWidth < 280 ? constraints.maxWidth : 280.0;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var i = 0; i < MockData.virtualAccounts.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                SizedBox(
                  width: cardWidth,
                  child: Builder(
                    builder: (context) {
                      final account = MockData.virtualAccounts[i];
                      return VirtualAccountCard(
                        account: account,
                        onCopy: () => _copyAccountNumber(
                          account.provider,
                          account.accountNumber,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _copyAccountNumber(String provider, String number) async {
    await Clipboard.setData(ClipboardData(text: number));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('$provider account number copied')),
      );
  }

  /// The WhatsApp support shortcut shown over the Home content.
  Widget _supportFab() {
    return Material(
      color: kAccent,
      shape: const CircleBorder(),
      elevation: 6,
      shadowColor: const Color(0x4D10231A),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () async {
          final ok = await UrlLauncher.contactSupport();
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                ok
                    ? 'Opening WhatsApp support...'
                    : 'Could not open WhatsApp. Check the installed apps.',
              ),
            ),
          );
        },
        child: const SizedBox(
          width: 52,
          height: 52,
          child: Icon(
            Icons.chat_bubble_outline,
            size: 24,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// Auto-Buy and Verify Account shortcuts, shown side by side.
  Widget _autoBuyAndVerifyRow() {
    final active = autoBuyRepository.activeSchedules.length;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _homeActionCard(
              leading: const AppLogo(size: 40),
              title: 'Auto-Buy',
              subtitle: active == 0
                  ? 'Let us buy your data on a schedule'
                  : '$active active schedule'
                      '${active == 1 ? '' : 's'}',
              onTap: () =>
                  Navigator.of(context).pushNamed(AppRoutes.autoBuyList),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _homeActionCard(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F4EC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  size: 21,
                  color: kAccent,
                ),
              ),
              title: 'Verify Account',
              subtitle: appStore.kycVerified ? 'Verified' : 'NIN or BVN',
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.kyc),
            ),
          ),
        ],
      ),
    );
  }

  /// A compact, tappable home shortcut with an icon, title and subtitle.
  Widget _homeActionCard({
    required Widget leading,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: kSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(width: 1.0, color: kCardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  leading,
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: kTextMuted,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: kTextPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: kTextMuted,
                ),
              ),
            ],
          ),
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
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 76),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F4EC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(child: icon),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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

  Widget _servicesGrid() {
    final items = [
      ServiceTile(
        label: 'Data',
        icon: Icons.data_usage,
        iconBackground: const Color(0xFFE6F4EC),
        iconColor: kAccent,
        onTap: () => Navigator.of(context).pushNamed(AppRoutes.buyData),
      ),
      ServiceTile(
        label: ServiceKind.airtime.tileLabel,
        icon: ServiceKind.airtime.icon,
        iconBackground: const Color(0xFFFDE4E1),
        iconColor: const Color(0xFFB42318),
        onTap: () => _openService(ServiceKind.airtime),
      ),
      ServiceTile(
        label: ServiceKind.cable.tileLabel,
        icon: ServiceKind.cable.icon,
        iconBackground: const Color(0xFFEDE9FE),
        iconColor: const Color(0xFF6D28D9),
        onTap: () => _openService(ServiceKind.cable),
      ),
      ServiceTile(
        label: ServiceKind.electricity.tileLabel,
        icon: ServiceKind.electricity.icon,
        iconBackground: const Color(0xFFFFF1D6),
        iconColor: const Color(0xFF8A5A00),
        onTap: () => _openService(ServiceKind.electricity),
      ),
      ServiceTile(
        label: ServiceKind.bulkSms.tileLabel,
        icon: ServiceKind.bulkSms.icon,
        iconBackground: const Color(0xFFE0F2FE),
        iconColor: const Color(0xFF0369A1),
        onTap: () => _openService(ServiceKind.bulkSms),
      ),
      ServiceTile(
        label: ServiceKind.eduPin.tileLabel,
        icon: ServiceKind.eduPin.icon,
        iconBackground: const Color(0xFFCCFBF1),
        iconColor: const Color(0xFF0F766E),
        onTap: () => _openService(ServiceKind.eduPin),
      ),
      ServiceTile(
        label: ServiceKind.rechargePin.tileLabel,
        icon: ServiceKind.rechargePin.icon,
        iconBackground: const Color(0xFFE0E7FF),
        iconColor: const Color(0xFF3730A3),
        onTap: () => _openService(ServiceKind.rechargePin),
      ),
      ServiceTile(
        label: ServiceKind.swarp.tileLabel,
        icon: ServiceKind.swarp.icon,
        iconBackground: const Color(0xFFDCFCE7),
        iconColor: const Color(0xFF166534),
        onTap: () => _openService(ServiceKind.swarp),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Four columns fit a normal phone. Narrow screens use three so the
        // labels (especially "Recharge Pin") are not squeezed.
        final columns = constraints.maxWidth < 340 ? 3 : 4;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisExtent: 112,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemBuilder: (context, i) => items[i],
        );
      },
    );
  }

  void _openService(ServiceKind kind) {
    Navigator.of(context).pushNamed(
      AppRoutes.servicePurchase,
      arguments: kind,
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
    // A fixed height would clip the labels when the customer increases the
    // system text size (or uses a font with taller metrics). The bar keeps
    // its 72px minimum height but is free to grow with its contents.
    return Container(
      constraints: const BoxConstraints(minHeight: kNavBarHeight),
      padding: const EdgeInsets.symmetric(vertical: 8),
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
    final isActive = index == 0;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (isActive) return;
          Navigator.of(context).pushNamed(route);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
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
