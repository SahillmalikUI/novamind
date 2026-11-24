import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// The app background.
///
/// Old version stacked three glowing blobs that competed for attention. This
/// one is a single deep canvas with one soft violet glow up top — enough
/// atmosphere to feel designed, quiet enough to let content lead.
class NovaBackground extends StatelessWidget {
  const NovaBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -1.05),
          radius: 1.15,
          colors: [
            Color(0xFF171B33), // faint violet lift near the top
            Nova.bg,
            Color(0xFF080A12), // settles to near-black at the bottom
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: SizedBox.expand(),
    );
  }
}
