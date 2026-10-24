import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/core/utils/currency_formatter.dart';
import 'package:data_naija_app/data/mock/mock_data.dart';
import 'package:data_naija_app/data/models/auto_buy_execution.dart';
import 'package:data_naija_app/data/models/auto_buy_schedule.dart';
import 'package:data_naija_app/presentation/routes/app_routes.dart';
import 'package:data_naija_app/presentation/widgets/app_button.dart';
import 'package:data_naija_app/presentation/widgets/app_card.dart';
import 'package:data_naija_app/presentation/widgets/app_logo.dart';
import 'package:data_naija_app/presentation/widgets/app_state_listener.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:data_naija_app/presentation/widgets/pill_badge.dart';
import 'package:flutter/material.dart';

/// Auto-Buy rule details.
///
/// Shows the full rule, when the next purchase happens and the history of
/// every automatic purchase that was attempted.
class AutoBuyDetailScreen extends StatefulWidget {
  const AutoBuyDetailScreen({super.key, required this.scheduleId});

  /// The id of the rule to show.
  final String scheduleId;

  @override
  State<AutoBuyDetailScreen> createState() => _AutoBuyDetailScreenState();
}

class _AutoBuyDetailScreenState extends State<AutoBuyDetailScreen>
    with AppStateListener<AutoBuyDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final schedule = autoBuyRepository.findById(widget.scheduleId);

    if (schedule == null) {
      return Scaffold(
        backgroundColor: kBackground,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Row(
                children: [
                  BackButton(onPressed: () => Navigator.of(context).pop()),
                  const SizedBox(width: 8),
                  const Text(
                    'Auto-Buy',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: kTextPrimary,
                    ),
                  ),
                ],
              ),
              const Expanded(
                child: Center(
                  child: Text(
                    'This schedule no longer exists.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: kTextMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final executions = autoBuyRepository.executionsFor(schedule.id);
    final network = MockData.networks.firstWhere(
      (n) => n.name == schedule.network,
      orElse: () => MockData.networks.first,
    );

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                BackButton(onPressed: () => Navigator.of(context).pop()),
                const SizedBox(width: 8),
                const AppLogo(size: 32),
                const SizedBox(width: 8),
                const Text(
                  'Auto-Buy',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: kTextPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: kPagePadding),
                children: [
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: network.bgColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  network.abbreviation,
                                  style: TextStyle(
                                    fontSize: 13,
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
                                      fontSize: 16,
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
                            PillBadge(
                              status: schedule.isActive ? 'Active' : 'Paused',
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Divider(height: 1),
                        const SizedBox(height: 8),
                        _row('Schedule', schedule.summary),
                        _row('Price', formatNaira(schedule.price)),
                        _row('Number', schedule.phone),
                        _row(
                          'Next purchase',
                          schedule.isActive ? schedule.nextRunLabel : 'Paused',
                        ),
                        _row(
                          'Last purchase',
                          schedule.lastRunLabel ?? 'Not yet',
                        ),
                        _row('Time zone', 'Africa/Lagos (WAT)'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Purchase history',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: kTextPrimary,
                          ),
                        ),
                      ),
                      if (schedule.consecutiveFailures > 0)
                        Text(
                          '${schedule.consecutiveFailures} failed attempt'
                          '${schedule.consecutiveFailures == 1 ? '' : 's'}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF9B1C12),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (executions.isEmpty)
                    const AppCard(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No automatic purchases yet. The first one will show '
                        'here.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: kTextMuted,
                          height: 1.45,
                        ),
                      ),
                    )
                  else
                    ...executions.map(_executionTile),
                  const SizedBox(height: 16),
                  AppButton(
                    onPressed: () => _toggle(schedule),
                    child: Text(
                      schedule.isActive ? 'Pause Auto-Buy' : 'Resume Auto-Buy',
                    ),
                  ),
                  const SizedBox(height: 8),
                  AppButton(
                    variant: ButtonVariant.outline,
                    onPressed: () => Navigator.of(context).pushNamed(
                      AppRoutes.autoBuySetup,
                      arguments: schedule,
                    ),
                    child: const Text('Edit Schedule'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: kTextMuted,
            ),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: kTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _executionTile(AutoBuyExecution execution) {
    final statusLabel = switch (execution.status) {
      'Successful' => 'Successful',
      'Failed' => 'Failed',
      'Skipped' => 'Skipped',
      _ => 'Pending',
    };

    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: execution.status == 'Successful'
                  ? const Color(0xFFE6F4EC)
                  : const Color(0xFFFDE4E1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                execution.status == 'Successful'
                    ? Icons.check
                    : Icons.priority_high,
                size: 18,
                color: execution.status == 'Successful'
                    ? kAccent
                    : const Color(0xFF9B1C12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        execution.slotLabel,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: kTextPrimary,
                        ),
                      ),
                    ),
                    PillBadge(status: statusLabel),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  execution.status == 'Successful'
                      ? '${formatNaira(execution.amount)} charged'
                      : (execution.error ?? 'No purchase was made'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: kTextMuted,
                    height: 1.4,
                  ),
                ),
                if (execution.attempt > 1) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Attempt ${execution.attempt}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: kTextMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggle(AutoBuySchedule schedule) async {
    final pause = schedule.isActive;
    await autoBuyRepository.setStatus(
      schedule.id,
      pause ? 'Paused' : 'Active',
    );
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pause ? 'Auto-Buy paused.' : 'Auto-Buy resumed.'),
      ),
    );
  }
}
