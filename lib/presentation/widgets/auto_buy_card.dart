import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/core/utils/currency_formatter.dart';
import 'package:data_naija_app/data/mock/mock_data.dart';
import 'package:data_naija_app/data/models/auto_buy_schedule.dart';
import 'package:data_naija_app/presentation/widgets/app_card.dart';
import 'package:data_naija_app/presentation/widgets/pill_badge.dart';
import 'package:flutter/material.dart';

/// A single Auto-Buy rule shown in the manage list.
///
/// The card shows what the rule buys, how often and when the next purchase
/// happens, plus the actions the customer can take on it.
class AutoBuyCard extends StatelessWidget {
  const AutoBuyCard({
    super.key,
    required this.schedule,
    this.onPause,
    this.onResume,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  final AutoBuySchedule schedule;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final network = MockData.networks.firstWhere(
      (n) => n.name == schedule.network,
      orElse: () => MockData.networks.first,
    );

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: network.bgColor,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    network.abbreviation,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: network.fgColor,
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
                      '${schedule.planGb} · ${schedule.planDays}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: kTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${schedule.network} · ${schedule.phone}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: kTextMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              PillBadge(
                status: schedule.isActive ? 'Active' : 'Paused',
              ),
            ],
          ),
          const SizedBox(height: 12),
          _infoRow(
            icon: Icons.schedule,
            label: 'Schedule',
            value: schedule.summary,
          ),
          const SizedBox(height: 6),
          _infoRow(
            icon: Icons.event,
            label: 'Next purchase',
            value: schedule.isActive
                ? schedule.nextRunLabel
                : 'Paused · resumes when you activate it',
          ),
          const SizedBox(height: 6),
          _infoRow(
            icon: Icons.payments_outlined,
            label: 'Price',
            value: '${formatNaira(schedule.price)} per purchase',
          ),
          if (schedule.consecutiveFailures > 0) ...[
            const SizedBox(height: 6),
            _infoRow(
              icon: Icons.error_outline,
              label: 'Last result',
              value: '${schedule.consecutiveFailures} failed attempt'
                  '${schedule.consecutiveFailures == 1 ? '' : 's'}',
            ),
          ] else if (schedule.lastRunLabel != null) ...[
            const SizedBox(height: 6),
            _infoRow(
              icon: Icons.history,
              label: 'Last purchase',
              value: schedule.lastRunLabel!,
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 4),
          Row(
            children: [
              if (schedule.isActive)
                _actionButton(
                  label: 'Pause',
                  icon: Icons.pause_circle_outline,
                  onPressed: onPause,
                )
              else
                _actionButton(
                  label: 'Resume',
                  icon: Icons.play_circle_outline,
                  onPressed: onResume,
                ),
              _actionButton(
                label: 'Edit',
                icon: Icons.edit_outlined,
                onPressed: onEdit,
              ),
              _actionButton(
                label: 'Delete',
                icon: Icons.delete_outline,
                onPressed: onDelete,
                isDestructive: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: kTextMuted),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: kTextMuted,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: kTextPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    final VoidCallback? onPressed,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? const Color(0xFF9B1C12) : kAccent;
    return Expanded(
      child: TextButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16, color: color),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}
