import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/data/models/auto_buy_schedule.dart';
import 'package:data_naija_app/presentation/routes/app_routes.dart';
import 'package:data_naija_app/presentation/widgets/app_button.dart';
import 'package:data_naija_app/presentation/widgets/app_logo.dart';
import 'package:data_naija_app/presentation/widgets/app_state_listener.dart';
import 'package:data_naija_app/presentation/widgets/app_store.dart';
import 'package:data_naija_app/presentation/widgets/auto_buy_card.dart';
import 'package:flutter/material.dart';

/// Auto-Buy management screen.
///
/// Lists every rule the customer created with the actions they can take on
/// each one: pause, resume, edit and delete.
class AutoBuyListScreen extends StatefulWidget {
  const AutoBuyListScreen({super.key});

  @override
  State<AutoBuyListScreen> createState() => _AutoBuyListScreenState();
}

class _AutoBuyListScreenState extends State<AutoBuyListScreen>
    with AppStateListener<AutoBuyListScreen> {
  @override
  void initState() {
    super.initState();
    // Pick up anything that ran while the app was closed. Deferred by a
    // frame so the repository's notification never lands in the middle of
    // this screen's first build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _runDueSchedules();
    });
  }

  Future<void> _runDueSchedules() async {
    try {
      await autoBuyRepository.load();
      final executed = await autoBuyRepository.runDueSchedules();
      if (executed.isNotEmpty && mounted) setState(() {});
    } catch (_) {
      // A failed catch-up must never block the screen.
    }
  }

  @override
  Widget build(BuildContext context) {
    final schedules = autoBuyRepository.schedules;

    return Scaffold(
      backgroundColor: kHomeBackground,
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
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.home,
                        (route) => route.isFirst,
                      );
                    }
                  },
                ),
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
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kPagePadding),
              child: AppButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.autoBuySetup),
                child: const Text('New Auto-Buy'),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: schedules.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: kPagePadding,
                      ),
                      itemCount: schedules.length,
                      itemBuilder: (context, i) {
                        final schedule = schedules[i];
                        return AutoBuyCard(
                          schedule: schedule,
                          onTap: () => _openDetail(schedule),
                          onPause: () => _toggle(schedule, pause: true),
                          onResume: () => _toggle(schedule, pause: false),
                          onEdit: () => _edit(schedule),
                          onDelete: () => _confirmDelete(schedule),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: Color(0xFFE6F4EC),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.autorenew,
                size: 34,
                color: kAccent,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No Auto-Buy schedules yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: kTextPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Set up a rule and we will buy your data for you on the '
              'schedule you choose.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: kTextMuted,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openDetail(AutoBuySchedule schedule) {
    Navigator.of(context).pushNamed(
      AppRoutes.autoBuyDetail,
      arguments: schedule.id,
    );
  }

  void _edit(AutoBuySchedule schedule) {
    Navigator.of(context).pushNamed(
      AppRoutes.autoBuySetup,
      arguments: schedule,
    );
  }

  Future<void> _toggle(
    AutoBuySchedule schedule, {
    required bool pause,
  }) async {
    await autoBuyRepository.setStatus(
      schedule.id,
      pause ? 'Paused' : 'Active',
    );
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          pause
              ? 'Auto-Buy paused.'
              : 'Auto-Buy resumed. Next purchase: '
                  '${schedule.nextRunLabel}',
        ),
      ),
    );
  }

  Future<void> _confirmDelete(AutoBuySchedule schedule) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusCard),
        ),
        title: const Text(
          'Delete Auto-Buy?',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: kTextPrimary,
          ),
        ),
        content: const Text(
          'This schedule will be removed and no more automatic purchases '
          'will be made.',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: kTextMuted,
            height: 1.45,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(0xFF9B1C12)),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await autoBuyRepository.delete(schedule.id);
    if (!mounted) return;
    setState(() {});
  }
}
