import 'package:flutter/material.dart';

class NovaHeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const NovaHeaderIconButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 44,
          width: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.82),
            size: 22,
          ),
        ),
      ),
    );
  }
}