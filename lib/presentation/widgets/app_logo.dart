import 'package:flutter/material.dart';

/// Brand artwork for DataNaija.
///
/// Both variants use the app mark supplied in the image assets.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 96,
    this.variant = LogoVariant.mark,
  });

  /// Width of the logo. Height is derived from the artwork's aspect ratio.
  final double size;
  final LogoVariant variant;

  static const String markAsset = 'assets/images/app_logo.jpg';
  static const String lockupAsset = 'assets/images/app_logo.jpg';

  @override
  Widget build(BuildContext context) {
    final asset = variant == LogoVariant.lockup ? lockupAsset : markAsset;

    final cacheWidth = (size * MediaQuery.devicePixelRatioOf(context)).round();

    return Image.asset(
      asset,
      width: size,
      cacheWidth: cacheWidth,
      // Keep the intrinsic aspect ratio so the lockup is never squashed.
      fit: BoxFit.contain,
      // A missing asset should never break a screen — fall back to a
      // simple branded placeholder.
      errorBuilder: (context, error, stackTrace) => _Fallback(size: size),
    );
  }
}

/// Which piece of the brand artwork to render.
enum LogoVariant { mark, lockup }

/// Neutral placeholder used when the brand assets are unavailable.
class _Fallback extends StatelessWidget {
  const _Fallback({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF0A7A4C),
        borderRadius: BorderRadius.circular(size * 0.22),
      ),
      child: Center(
        child: Text(
          'D',
          style: TextStyle(
            fontSize: size * 0.5,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
