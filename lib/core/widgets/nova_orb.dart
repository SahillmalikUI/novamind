import 'package:flutter/material.dart';

class NovaOrb extends StatelessWidget {
  final double size;
  final IconData icon;
  final double iconSize;

  const NovaOrb({
    super.key,
    this.size = 108,
    this.icon = Icons.auto_awesome_rounded,
    this.iconSize = 46,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFA78BFA),
            Color(0xFF7C3AED),
            Color(0xFF22D3EE),
          ],
          stops: [0.05, 0.36, 0.70, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.50),
            blurRadius: 34,
            spreadRadius: 3,
          ),
          BoxShadow(
            color: const Color(0xFF22D3EE).withValues(alpha: 0.30),
            blurRadius: 55,
            spreadRadius: 8,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: size * 0.72,
            width: size * 0.72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.22),
                width: 1.3,
              ),
            ),
          ),
          Icon(icon, color: Colors.white, size: iconSize),
        ],
      ),
    );
  }
}

class NovaMiniOrb extends StatelessWidget {
  final IconData icon;

  const NovaMiniOrb({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return NovaOrb(size: 46, icon: icon, iconSize: 23);
  }
}
