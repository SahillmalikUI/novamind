import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NovaFloatingDock extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const NovaFloatingDock({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  static const List<_DockItem> _items = [
    _DockItem(
      label: 'Hub',
      icon: Icons.space_dashboard_rounded,
      activeColor: Color(0xFF8B5CF6),
    ),
    _DockItem(
      label: 'Tasks',
      icon: Icons.task_alt_rounded,
      activeColor: Color(0xFFA78BFA),
    ),
    _DockItem(
      label: 'Nova AI',
      icon: Icons.auto_awesome_rounded,
      activeColor: Color(0xFF22D3EE),
      isCenter: true,
    ),
    _DockItem(
      label: 'Arena',
      icon: Icons.quiz_rounded,
      activeColor: Color(0xFFFACC15),
    ),
    _DockItem(
      label: 'Profile',
      icon: Icons.person_rounded,
      activeColor: Color(0xFF60A5FA),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 68,
              decoration: BoxDecoration(
                color: const Color(0xFF0F1524).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_items.length, (index) {
                  final item = _items[index];
                  final isSelected = currentIndex == index;

                  return _DockButton(
                    item: item,
                    isSelected: isSelected,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onTabSelected(index);
                    },
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockItem {
  final String label;
  final IconData icon;
  final Color activeColor;
  final bool isCenter;

  const _DockItem({
    required this.label,
    required this.icon,
    required this.activeColor,
    this.isCenter = false,
  });
}

class _DockButton extends StatelessWidget {
  final _DockItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _DockButton({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (item.isCenter) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: isSelected ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF22D3EE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF22D3EE)
                      .withValues(alpha: isSelected ? 0.55 : 0.35),
                  blurRadius: isSelected ? 20 : 12,
                  spreadRadius: isSelected ? 2 : 0,
                ),
              ],
            ),
            child: Icon(
              item.icon,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? item.activeColor.withValues(alpha: 0.16)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              size: 22,
              color: isSelected
                  ? item.activeColor
                  : const Color(0xFF94A3B8).withValues(alpha: 0.7),
            ),
            const SizedBox(height: 3),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? item.activeColor
                    : const Color(0xFF94A3B8).withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
