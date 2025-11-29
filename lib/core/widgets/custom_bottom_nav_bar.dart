import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Custom Bottom Navigation Bar - Consistent style for Donor & Hospital
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<CustomNavItem> items;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightRed,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = currentIndex == index;

              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon
                      Icon(
                        isSelected ? item.activeIcon ?? item.icon : item.icon,
                        color: isSelected ? AppColors.red : AppColors.grey,
                        size: 26,
                      ),
                      const SizedBox(height: 4),
                      // Label
                      Text(
                        item.label,
                        style: TextStyle(
                          color: isSelected ? AppColors.red : AppColors.grey,
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// Custom Navigation Item
class CustomNavItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  const CustomNavItem({
    required this.icon,
    this.activeIcon,
    required this.label,
  });
}
