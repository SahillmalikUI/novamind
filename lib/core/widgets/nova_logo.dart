import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Your brand mark. Replaces the old glowing "orb" everywhere.
///
/// Uses assets/logo.png. Because the logo already carries its own rounded dark
/// tile, it reads as a clean app-icon on the dark background at any size.
class NovaLogo extends StatelessWidget {
  final double size;

  /// Adds a soft violet lift behind the mark — nice for the login / splash hero.
  final bool glow;

  const NovaLogo({super.key, this.size = 96, this.glow = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.24),
        boxShadow: glow
            ? [
                BoxShadow(
                  color: Nova.violet.withValues(alpha: 0.30),
                  blurRadius: size * 0.5,
                  spreadRadius: size * 0.02,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.24),
        child: Image.asset(
          'assets/logo.png',
          height: size,
          width: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}

/// Small header lockup: mark + wordmark + optional subtitle. Use in app bars.
class NovaWordmark extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double markSize;

  const NovaWordmark({
    super.key,
    this.title = 'NovaMind',
    this.subtitle,
    this.markSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NovaLogo(size: markSize),
        const SizedBox(width: Nova.s12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: Nova.h2),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: Nova.label),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
