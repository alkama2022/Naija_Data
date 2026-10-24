import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/core/utils/currency_formatter.dart';
import 'package:data_naija_app/data/mock/mock_data.dart';
import 'package:data_naija_app/presentation/routes/app_routes.dart';
import 'package:data_naija_app/presentation/widgets/app_button.dart';
import 'package:data_naija_app/presentation/widgets/app_card.dart';
import 'package:data_naija_app/presentation/widgets/app_state_listener.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:data_naija_app/presentation/widgets/chip_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Referral screen — campaign vs referrals tabs, bonus, code, friends.
class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen>
    with AppStateListener<ReferralScreen> {
  String _tab = 'Campaign';

  @override
  Widget build(BuildContext context) {
    final isCampaign = _tab == 'Campaign';
    final bonus = appRepository.referralBonus;
    final minMove = MockData.referralMin;

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
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
                      Navigator.of(context)
                          .pushReplacementNamed(AppRoutes.profile);
                    }
                  },
                ),
                const SizedBox(width: 8),
                const Text(
                  'Referral',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: kTextPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 2,
                itemBuilder: (context, i) {
                  final h = i == 0 ? 'Campaign' : 'Referrals';
                  final isSelected = _tab == h;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChipFilter(
                      name: h,
                      isSelected: isSelected,
                      onTap: () => setState(() => _tab = h),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: isCampaign
                      ? _buildCampaign(bonus, minMove)
                      : _buildReferrals(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCampaign(int bonus, int minMove) {
    return [
      AppCard(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Flexible(
              child: Text(
                'Referral bonus',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: kTextMuted,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              formatNaira(bonus),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: kTextPrimary,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 10),
      AppButton(
        onPressed: bonus < minMove
            ? null
            : () {
                final moved = appRepository.moveReferralBonus();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      moved
                          ? '${formatNaira(bonus)} moved to your wallet'
                          : 'Could not move the bonus. Try again.',
                    ),
                  ),
                );
              },
        child: const Text('Move bonus to wallet'),
      ),
      const SizedBox(height: 6),
      Text(
        bonus < minMove
            ? 'You need at least ${formatNaira(minMove)} to move bonus to your wallet.'
            : 'Moves ${formatNaira(bonus)} into your wallet instantly.',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: kTextMuted,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 14),
      Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(14),
        color: const Color(0xFFE6F4EC),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How you earn',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: kTextPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Earn ${formatNaira(MockData.referralFirstBonus)} when a friend makes their first purchase, then ${MockData.referralPct}% of our profit on every purchase they make, for life. Up to ${formatNaira(MockData.referralCap)} a month.',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: kTextMuted,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          'Your unique referral code',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: kTextPrimary,
          ),
        ),
      ),
      const SizedBox(height: 6),
      AppCard(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                kReferralCode,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.06,
                  color: kTextPrimary,
                ),
              ),
            ),
            AppButton(
              child: const Text('Copy'),
              onPressed: () async {
                await Clipboard.setData(
                  const ClipboardData(text: kReferralCode),
                );
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Copied'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      AppButton(
        child: const Text('Refer a friend'),
        onPressed: () async {
        final message =
            'Join me on DataNaija! Use my referral code $kReferralCode to earn bonuses. Download the app.';
        final uri =
            Uri.parse('https://wa.me/?text=${Uri.encodeComponent(message)}');
        try {
          final launched = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
          if (!launched) {
            if (!mounted) return;
            await Clipboard.setData(ClipboardData(text: message));
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invite message copied to clipboard.'),
              ),
            );
          }
        } catch (_) {
          if (!mounted) return;
          await Clipboard.setData(ClipboardData(text: message));
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invite message copied to clipboard.'),
            ),
          );
        }
      },
      ),
    ];
  }

  List<Widget> _buildReferrals() {
    return [
      AppCard(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(0),
        child: Column(
          children: List.generate(
            appRepository.friends.length,
            (i) => Column(
              children: [
                if (i > 0) const Divider(height: 1),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F4EC),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        MockData.friends[i].initials,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: kAccent,
                        ),
                      ),
                    ),
                  ),
                  title: Text(
                    MockData.friends[i].name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: kTextPrimary,
                    ),
                  ),
                  subtitle: Text(
                    MockData.friends[i].status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: MockData.friends[i].status == 'Active'
                          ? const Color(0xFF0A5C3E)
                          : const Color(0xFF8A5A00),
                    ),
                  ),
                  trailing: Text(
                    '+${formatNaira(MockData.friends[i].earned)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0B7A4B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      const SizedBox(height: 10),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Text(
          'Earnings are added to your referral bonus when your friend\'s order is delivered.',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: kTextMuted,
          ),
        ),
      ),
    ];
  }
}
