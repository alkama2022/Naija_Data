import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

/// Toast notification (`.toast` in the prototype).
/// Managed by [ToastOverlay] and shown via [ToastOverlay.of].
class ToastOverlay extends InheritedWidget {
  const ToastOverlay({
    super.key,
    required this.showToast,
    required super.child,
  });

  final VoidCallback Function(String message) showToast;

  static ToastOverlay? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ToastOverlay>();
  }

  @override
  bool updateShouldNotify(covariant ToastOverlay oldWidget) {
    return showToast != oldWidget.showToast;
  }
}

/// Displays a toast message at the bottom of the screen.
class Toast extends StatelessWidget {
  const Toast({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 20,
      right: 20,
      bottom: kToastBottom,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: kToastBg,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Text(
          message,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
