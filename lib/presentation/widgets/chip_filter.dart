import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

/// Selectable chip filter (`.chip` / `.chip.on` in the prototype).
class ChipFilter extends StatelessWidget {
  const ChipFilter({
    super.key,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1.5,
            color: isSelected ? Theme.of(context).primaryColor : kBorderMedium,
          ),
          borderRadius: BorderRadius.circular(999),
          color: isSelected
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : kBackground,
        ),
        child: Center(
          child: Text(
            name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isSelected ? Theme.of(context).primaryColor : kTextPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
