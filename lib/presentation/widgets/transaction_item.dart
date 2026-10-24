import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/core/utils/currency_formatter.dart';
import 'package:data_naija_app/data/models/transaction.dart';
import 'package:data_naija_app/presentation/widgets/pill_badge.dart';
import 'package:flutter/material.dart';

/// Transaction list row (`.tx` in the prototype).
class TransactionItem extends StatelessWidget {
  const TransactionItem({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  final TransactionModel transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.amount > 0;
    final amountColor = isCredit ? kAmountPositive : kAmountNegative;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      visualDensity: VisualDensity(horizontal: 0, vertical: -2),
      onTap: onTap,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: transaction.iconColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            transaction.letter,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            transaction.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            transaction.subtitle,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: kTextMuted,
            ),
          ),
        ],
      ),
      subtitle: Text(
        transaction.date,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: kTextMuted,
        ),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${isCredit ? '+' : '-'}${formatNaira(transaction.amount)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: amountColor,
            ),
          ),
          const SizedBox(height: 4),
          PillBadge(status: transaction.status),
        ],
      ),
    );
  }
}
