import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/core/utils/currency_formatter.dart';
import 'package:data_naija_app/data/models/transaction.dart';
import 'package:data_naija_app/presentation/routes/app_routes.dart';
import 'package:data_naija_app/presentation/widgets/app_button.dart';
import 'package:data_naija_app/presentation/widgets/app_card.dart';
import 'package:data_naija_app/presentation/widgets/app_link_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Transaction Details screen — full details of a single transaction.
class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tx = ModalRoute.of(context)!.settings.arguments as TransactionModel?;

    if (tx == null) {
      return const Scaffold(
        body: Center(child: Text('Transaction not found')),
      );
    }

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
                          .pushReplacementNamed(AppRoutes.transactions);
                    }
                  },
                ),
                const SizedBox(width: 8),
                const Text(
                  'Transaction Details',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: kTextPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: tx.iconColor,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              tx.letter,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx.status,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: tx.statusColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${tx.title} · ${tx.subtitle}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: kTextMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _kvRow('Amount',
                        '${tx.amount > 0 ? '+' : '-'}${formatNaira(tx.amount)}',
                        valueColor:
                            tx.amount > 0 ? kAmountPositive : kAmountNegative),
                    _kvRow('Phone Number', tx.phone),
                    _kvRow('Date & Time', tx.date),
                    _kvRow('Reference ID', tx.ref),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.all(kPagePadding),
              child: Column(
                children: [
                  AppButton(
                    child: const Text('Copy Receipt'),
                    onPressed: () async {
                      final tx = ModalRoute.of(context)!.settings.arguments
                          as TransactionModel?;
                      if (tx == null) return;
                      final buffer = StringBuffer()
                        ..writeln('DataNaija Receipt')
                        ..writeln('Status: ${tx.status}')
                        ..writeln('Title: ${tx.title}')
                        ..writeln('Description: ${tx.subtitle}')
                        ..writeln('Phone: ${tx.phone}')
                        ..writeln('Amount: ${formatNaira(tx.amount)}')
                        ..writeln('Reference: ${tx.ref}')
                        ..writeln('Date: ${tx.date}');
                      await Clipboard.setData(
                          ClipboardData(text: buffer.toString()));
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Receipt copied to clipboard'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  AppLinkButton(
                    fullWidth: true,
                    onPressed: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(context)
                            .pushReplacementNamed(AppRoutes.transactions);
                      }
                    },
                    child: const Text('Back'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kvRow(String label, String value, {Color? valueColor}) {
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
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? kTextPrimary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
