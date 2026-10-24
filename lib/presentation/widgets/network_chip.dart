import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

/// Selectable network chip (`.net` in the prototype) used for carrier selection.
class NetworkChip extends StatelessWidget {
  const NetworkChip({
    super.key,
    required this.network,
    required this.color,
    required this.textColor,
    required this.abbreviation,
    required this.isSelected,
    required this.onTap,
  });

  final String network;
  final Color color;
  final Color textColor;
  final String abbreviation;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 104,
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          border: Border.all(
            width: 2.0,
            color: isSelected ? Theme.of(context).primaryColor : kBorderLight,
          ),
          borderRadius: BorderRadius.circular(16.0),
          color: isSelected ? const Color(0xFFF0FAF5) : kBackground,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  abbreviation,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              network,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: kTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
