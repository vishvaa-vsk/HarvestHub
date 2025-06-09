import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../utils/performance_utils.dart';

/// Highly optimized bottom navigation bar to reduce frame drops during navigation
class OptimizedNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavigationItem> items;

  const OptimizedNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Container(
        height: 70,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 25,
              offset: Offset(0, -8),
              spreadRadius: 0,
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: items.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                return _OptimizedNavItem(
                  key: ValueKey('nav_item_$index'),
                  icon: item.icon,
                  label: item.label,
                  index: index,
                  isSelected: currentIndex == item.targetIndex,
                  onTap: onTap,
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String label;
  final int targetIndex;

  const NavigationItem({
    required this.icon,
    required this.label,
    required this.targetIndex,
  });
}

class _OptimizedNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool isSelected;
  final Function(int) onTap;

  const _OptimizedNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.index,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: InkWell(
        onTap: () {
          // Use navigation utility throttling for better performance
          if (NavigationUtils.canNavigate(
              throttleDuration: const Duration(milliseconds: 200))) {
            onTap(index);
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Use simple Icon instead of animated containers for better performance
              Icon(
                icon,
                color: isSelected
                    ? AppConstants.primaryGreen
                    : const Color(0xFF9E9E9E),
                size: 24,
              ),
              const SizedBox(height: 4),
              // Optimize text rendering
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? AppConstants.primaryGreen
                      : const Color(0xFF9E9E9E),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
