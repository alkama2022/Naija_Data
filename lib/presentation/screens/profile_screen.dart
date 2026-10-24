import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/core/utils/auth_service.dart';
import 'package:data_naija_app/data/mock/mock_data.dart';
import 'package:data_naija_app/presentation/routes/app_routes.dart';
import 'package:data_naija_app/presentation/widgets/app_card.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:flutter/material.dart';

/// Profile screen — user info, menu rows, sign out.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    'Profile',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: kTextPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A7A4C),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'CO',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chinedu Okafor',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: kTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          MockData.defaultUser.email,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: kTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(0),
                child: Column(
                  children: [
                    _menuRow('Auto-Buy', 'Automate your data purchases', () {
                      Navigator.of(context).pushNamed(AppRoutes.autoBuyList);
                    }),
                    const Divider(height: 1),
                    _menuRow(
                        'Security', 'Change your account security settings',
                        () {
                      Navigator.of(context).pushNamed(AppRoutes.security);
                    }),
                    const Divider(height: 1),
                    _menuRow('My Referral', 'Earn bonuses by referring friends',
                        () {
                      Navigator.of(context).pushNamed(AppRoutes.referral);
                    }),
                    const Divider(height: 1),
                    _menuRow('Notifications', 'Manage your notifications', () {
                      Navigator.of(context).pushNamed(AppRoutes.notifications);
                    }),
                    const Divider(height: 1),
                    _menuRow('Help & Support', 'Get help from our support team',
                        () {
                      Navigator.of(context).pushNamed(AppRoutes.help);
                    }),
                    const Divider(height: 1),
                    _menuRow('FAQs', 'Frequently asked questions', () {
                      Navigator.of(context).pushNamed(AppRoutes.help);
                    }),
                    const Divider(height: 1),
                    _menuRow('About DataNaija', 'DataNaija v1.0 (demo)', () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'DataNaija',
                        applicationVersion: '1.0.0+1',
                        applicationIcon: Image.asset(
                          'assets/images/app_mark.png',
                          width: 48,
                          height: 48,
                        ),
                        children: const [
                          Text(
                            'Nigerian VTU mobile app frontend (design reference implementation). '
                            'All data is locally simulated for demonstration purposes.',
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.all(kPagePadding),
                child: OutlinedButton(
                  onPressed: () {
                    appStore.setSignedIn(false);
                    AuthService.clearAuth();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.signIn, (route) => false);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFC0352B),
                    side: const BorderSide(
                      width: 1.5,
                      color: Color(0xFFE9A9A3),
                    ),
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Sign Out'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuRow(String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: kTextPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: kTextMuted,
        ),
      ),
      trailing: const Text(
        '›',
        style: TextStyle(
          fontSize: 14,
          color: kTextMuted,
        ),
      ),
      onTap: onTap,
    );
  }
}
