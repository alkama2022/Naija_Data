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

    // Avoid forcing infinite width inside Row (e.g. code-copy buttons).


    // Use LayoutBuilder to detect bounded constraints (full width in Column,
    // intrinsic in Row).
    return LayoutBuilder(
      builder: (context, constraints) {
        if (width != null) {
          return ConstrainedBox(
            constraints: BoxConstraints(minHeight: height),
            child: SizedBox(
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
                  minimumSize: Size(0, height),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: child,
              ),
            ),
          );
        }

        final bool bounded =
            constraints.hasBoundedWidth && constraints.maxWidth.isFinite;
        if (bounded) {
          return ConstrainedBox(
            constraints: BoxConstraints(minHeight: height),
            child: SizedBox(
              width: double.infinity,
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
                  minimumSize: Size(0, height),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: child,
              ),
            ),
          );
        }

        return ConstrainedBox(
          constraints: BoxConstraints(minHeight: height),
          child: SizedBox(
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
                minimumSize: Size(0, height),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

enum ButtonVariant { primary, primaryWhite, outline }
