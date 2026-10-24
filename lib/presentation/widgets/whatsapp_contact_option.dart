import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/core/utils/url_launcher_helper.dart';
import 'package:data_naija_app/presentation/widgets/app_card.dart';
import 'package:flutter/material.dart';

/// A single WhatsApp contact option row.
///
/// Displays an icon, title, description, and trailing chevron within a card.
/// Tapping the entire row launches the corresponding WhatsApp URL via
/// [UrlLauncher], with a snackbar shown on failure.
class WhatsAppContactOption extends StatelessWidget {
  const WhatsAppContactOption({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(kBorderRadiusCard),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: kAccent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 22,
                  color: kAccent,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: kTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: kTextMuted,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: kTextMuted,
            ),
          ],
        ),
      ),
    );
  }
}

/// Option to start a WhatsApp conversation with support.
class WhatsAppSupportOption extends StatelessWidget {
  const WhatsAppSupportOption({super.key});

  @override
  Widget build(BuildContext context) {
    return WhatsAppContactOption(
      icon: Icons.chat,
      title: 'Chat with Support',
      description:
          'Need help? Chat with our support team directly on WhatsApp.\n$kWhatsAppPhoneDisplay',
      onTap: () async {
        final success = await UrlLauncher.contactSupport();
        if (!success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Unable to open WhatsApp. Please try again later.',
              ),
            ),
          );
        }
      },
    );
  }
}

/// Option to follow the DataNaija WhatsApp Channel.
class WhatsAppChannelOption extends StatelessWidget {
  const WhatsAppChannelOption({super.key});

  @override
  Widget build(BuildContext context) {
    return WhatsAppContactOption(
      icon: Icons.update,
      title: 'Follow Our WhatsApp Channel',
      description:
          'Stay updated with announcements, important information, and the latest news.',
      onTap: () async {
        final success = await UrlLauncher.followChannel();
        if (!success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Unable to open WhatsApp Channel. Please try again later.',
              ),
            ),
          );
        }
      },
    );
  }
}
