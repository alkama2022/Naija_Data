import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

/// Primary filled button (`.g` in the prototype).
///
/// [variant] controls the fill style:
///   - [ButtonVariant.primary] — accent background, white text
///   - [ButtonVariant.primaryWhite] — white background, accent text
///   - [ButtonVariant.outline] — transparent background, accent border/text
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.child,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.width,
    this.height = kButtonMinHeight,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final double? width;
  final double height;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    late final Color backgroundColor;
    late final Color foregroundColor;
    late final Color? sideColor;

    switch (variant) {
      case ButtonVariant.primary:
        backgroundColor =
            enabled ? theme.primaryColor : const Color(0xFFBFCBC4);
        foregroundColor = kTextOnAccent;
        sideColor = null;
      case ButtonVariant.primaryWhite:
        backgroundColor = enabled ? kSurface : const Color(0xFFBFCBC4);
        foregroundColor = enabled ? theme.primaryColor : kTextMuted;
        sideColor = null;
      case ButtonVariant.outline:
        backgroundColor = kSurface;
        foregroundColor = enabled ? theme.primaryColor : kTextMuted;
        sideColor = enabled ? theme.primaryColor : kBorderMedium;
    }

    final button = SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 0,
          side: sideColor != null
              ? BorderSide(width: 1.5, color: sideColor)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(kBorderRadiusButton),
          ),
        ),
        child: child,
      ),
    );

    if (variant == ButtonVariant.outline) {
      return button;
    }
    return button;
  }
}

enum ButtonVariant { primary, primaryWhite, outline }

/// Small ghost button (`.o` in the prototype) with outline styling.
class AppGhostButton extends StatelessWidget {
  const AppGhostButton({
    super.key,
    required this.child,
    this.onPressed,
    this.fullWidth = false,
    this.height = kSmallButtonMinHeight,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final bool fullWidth;
  final double height;

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Theme.of(context).primaryColor,
        side: const BorderSide(width: 1.5, color: kBorderMedium),
        minimumSize: Size(double.infinity, height),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(kBorderRadiusButton),
        ),
      ),
      child: child,
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
