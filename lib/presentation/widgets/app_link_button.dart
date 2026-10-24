import 'package:flutter/material.dart';

/// Small text link button (`.lk` in the prototype) used for secondary actions.
class AppLinkButton extends StatelessWidget {
  const AppLinkButton({
    super.key,
    required this.child,
    this.onPressed,
    this.fullWidth = false,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final button = TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).primaryColor,
        padding: EdgeInsets.zero,
        minimumSize: Size(fullWidth ? double.infinity : 0, 44),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        alignment: Alignment.centerLeft,
      ),
      child: child,
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
