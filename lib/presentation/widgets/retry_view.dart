import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/presentation/widgets/app_button.dart';
import 'package:flutter/material.dart';

/// Full-screen feedback shown when the app cannot reach the internet or a
/// backend request failed.
///
/// The Retry action is always visible so the customer is never trapped on a
/// spinner, and the message is always a complete sentence with the reason.
class RetryView extends StatelessWidget {
  const RetryView({
    super.key,
    required this.message,
    required this.onRetry,
    this.title,
    this.icon = Icons.wifi_off_rounded,
    this.retrying = false,
  });

  final String message;
  final VoidCallback onRetry;
  final String? title;
  final IconData icon;

  /// When true the Retry button is disabled and shows its own spinner.
  final bool retrying;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(kPagePadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE6F4EC),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 30, color: accent),
                ),
                const SizedBox(height: 18),
                if (title != null) ...[
                  Text(
                    title!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: kFontSizeHeading,
                      fontWeight: FontWeight.w800,
                      color: kTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: kFontSizeBody,
                    fontWeight: FontWeight.w500,
                    color: kTextMuted,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 22),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 240),
                  child: AppButton(
                    onPressed: retrying ? null : onRetry,
                    child: retrying
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text('Retry'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
