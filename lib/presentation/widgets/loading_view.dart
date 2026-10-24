import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/presentation/widgets/app_logo.dart';
import 'package:flutter/material.dart';

/// The app-wide loading state.
///
/// It is intentionally small and quiet: the brand mark, a smooth spinner and
/// the "Loading..." label, all using the existing design tokens.
class LoadingView extends StatelessWidget {
  const LoadingView({
    super.key,
    this.message = 'Loading...',
    this.showLogo = true,
  });

  final String message;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Center(
          child: Semantics(
            liveRegion: true,
            label: message,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showLogo) ...[
                  const AppLogo(size: 88, variant: LogoVariant.lockup),
                  const SizedBox(height: 28),
                ],
                SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.6,
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kTextMuted,
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
