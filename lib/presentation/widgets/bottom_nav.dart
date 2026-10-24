import 'package:data_naija_app/core/constants/app_constants.dart';
import 'package:data_naija_app/presentation/routes/app_routes.dart';
import 'package:flutter/material.dart';

/// Bottom navigation bar (`.nav` in the prototype).
/// Only shown on Home, Buy Data, Transactions, and Profile screens.
class CustomBottomNav extends StatelessWidget {
  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<_NavItem> _items = [
    _NavItem(AppRoutes.home, 'Home', Icons.home),
    _NavItem(AppRoutes.buyData, 'Data', Icons.data_usage),
    _NavItem(AppRoutes.transactions, 'Transactions', Icons.receipt_long),
    _NavItem(AppRoutes.profile, 'Profile', Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kNavBarHeight,
      decoration: const BoxDecoration(
        color: kSurface,
        border: Border(top: BorderSide(width: 1.0, color: kBorderLight)),
      ),
      child: Row(
        children: List.generate(_items.length, (index) {
          final item = _items[index];
          final isActive = currentIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item.icon,
                    size: kIconSize,
                    color:
                        isActive ? Theme.of(context).primaryColor : kTextMuted,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isActive
                          ? Theme.of(context).primaryColor
                          : kTextMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final String route;
  final String label;
  final IconData icon;

  const _NavItem(this.route, this.label, this.icon);
}
