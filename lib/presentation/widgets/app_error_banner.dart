import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

/// Inline error feedback for forms such as Sign In and Sign Up.
///
/// The forms keep their existing layout; this only adds a readable message
/// above the action button when a request fails, so an offline device or a
/// backend error is never silent.
class AppErrorBanner extends StatelessWidget {
  const AppErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kPillFailedBg,
          border: Border.all(width: 1, color: const Color(0xFFF2C4BD)),
          borderRadius: BorderRadius.circular(kBorderRadiusInput),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 18,
              color: kPillFailedFg,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: kPillFailedFg,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
