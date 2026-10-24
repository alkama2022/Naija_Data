import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/data/mock/mock_data.dart';
import 'package:data_naija_app/presentation/routes/app_routes.dart';
import 'package:data_naija_app/presentation/widgets/app_button.dart';
import 'package:data_naija_app/presentation/widgets/app_card.dart';
import 'package:data_naija_app/presentation/widgets/app_link_button.dart';
import 'package:data_naija_app/presentation/widgets/chip_filter.dart';
import 'package:data_naija_app/presentation/widgets/whatsapp_contact_option.dart';
import 'package:flutter/material.dart';

/// Help & Support screen — FAQ accordion and contact support.
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  String _tab = 'FAQs';
  int _openIndex = -1;

  @override
  Widget build(BuildContext context) {
    final isFaq = _tab == 'FAQs';

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
                      .pushReplacementNamed(AppRoutes.profile),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Help & Support',
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
                itemCount: ['FAQs', 'Contact Support'].length,
                itemBuilder: (context, i) {
                  final h = ['FAQs', 'Contact Support'][i];
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
            if (isFaq) ...[
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: MockData.faqs.length,
                  itemBuilder: (context, i) {
                    final faq = MockData.faqs[i];
                    final isOpen = _openIndex == i;
                    return Column(
                      children: [
                        AppButton(
                          variant: ButtonVariant.outline,
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  faq.question,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: kTextPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                isOpen ? '−' : '+',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: kAccent,
                                ),
                              ),
                            ],
                          ),
                          onPressed: () {
                            setState(() {
                              _openIndex = _openIndex == i ? -1 : i;
                            });
                          },
                        ),
                        if (isOpen) ...[
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              faq.answer,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: kTextMuted,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ] else ...[
              AppCard(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contact our team',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Reach us on WhatsApp or email: $kSupportContact',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: kTextMuted,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const WhatsAppSupportOption(),
                    const SizedBox(height: 8),
                    const WhatsAppChannelOption(),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(14),
                color: const Color(0xFFE6F4EC),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Need more help?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Our support team is here for you.',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: kTextMuted,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppLinkButton(
                      child: const Text('Get Help'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'A support agent will reach out shortly',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
