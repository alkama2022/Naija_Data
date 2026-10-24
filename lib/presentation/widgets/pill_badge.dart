import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

/// Status pill badge (`.pill` in the prototype).
///
/// [status] can be 'Successful', 'Pending', or 'Failed'.
class PillBadge extends StatelessWidget {
  const PillBadge({
    super.key,
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final config = _config(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(kBorderRadiusPill),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  PillConfig _config(String status) {
    switch (status) {
      case 'Successful':
      case 'Active':
        return PillConfig(kPillSuccessBg, kPillSuccessFg);
      case 'Pending':
        return PillConfig(kPillPendingBg, kPillPendingFg);
      case 'Failed':
        return PillConfig(kPillFailedBg, kPillFailedFg);
      case 'Paused':
      case 'Skipped':
        return PillConfig(kPillPendingBg, kPillPendingFg);
      default:
        return PillConfig(kPillSuccessBg, kPillSuccessFg);
    }
  }
}

class PillConfig {
  final Color backgroundColor;
  final Color foregroundColor;

  PillConfig(this.backgroundColor, this.foregroundColor);
}
