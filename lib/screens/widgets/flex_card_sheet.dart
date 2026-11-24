import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/gamification_provider.dart';

class FlexCardTheme {
  final String name;
  final List<Color> gradient;
  final Color border;
  final Color glow;
  final Color accent;

  const FlexCardTheme({
    required this.name,
    required this.gradient,
    required this.border,
    required this.glow,
    required this.accent,
  });
}

class FlexCardSheet extends StatefulWidget {
  final String name;
  final GamificationState gamification;

  const FlexCardSheet({
    super.key,
    required this.name,
    required this.gamification,
  });

  static void show(
    BuildContext context, {
    String name = 'NovaMind User',
    GamificationState? gamification,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Consumer(
        builder: (context, ref, _) {
          final GamificationState g =
              gamification ?? ref.read(gamificationProvider);
          return FlexCardSheet(name: name, gamification: g);
        },
      ),
    );
  }

  @override
  State<FlexCardSheet> createState() => _FlexCardSheetState();
}

class _FlexCardSheetState extends State<FlexCardSheet> {
  static const List<FlexCardTheme> _themes = [
    FlexCardTheme(
      name: 'Cyber Neon',
      gradient: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
      border: Color(0xFF22D3EE),
      glow: Color(0xFF8B5CF6),
      accent: Color(0xFF22D3EE),
    ),
    FlexCardTheme(
      name: 'Obsidian Gold',
      gradient: [Color(0xFF1F1D17), Color(0xFF09090B)],
      border: Color(0xFFF59E0B),
      glow: Color(0xFFD97706),
      accent: Color(0xFFFBBF24),
    ),
    FlexCardTheme(
      name: 'Solar Plasma',
      gradient: [Color(0xFF4A044E), Color(0xFF18021E)],
      border: Color(0xFFF43F5E),
      glow: Color(0xFFEC4899),
      accent: Color(0xFFFB7185),
    ),
  ];

  int _selectedThemeIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = _themes[_selectedThemeIndex];
    final g = widget.gamification;
    final displayName =
        widget.name.isNotEmpty ? widget.name : 'NovaMind User';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
      decoration: const BoxDecoration(
        color: Color(0xFF080B16),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Your Cognitive Flex Card',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Share your mental velocity on Instagram Stories & TikTok',
            style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5),
          ),

          const SizedBox(height: 16),

          // Theme Selector Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_themes.length, (i) {
              final isSelected = _selectedThemeIndex == i;
              final t = _themes[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() => _selectedThemeIndex = i);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? t.border.withValues(alpha: 0.2)
                          : Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? t.border : Colors.white12,
                        width: 1.2,
                      ),
                    ),
                    child: Text(
                      t.name,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white60,
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 18),

          // The actual Story Flex Card
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: theme.gradient,
              ),
              border: Border.all(
                color: theme.border.withValues(alpha: 0.45),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.glow.withValues(alpha: 0.35),
                  blurRadius: 35,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Branding Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'NOVAMIND',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        letterSpacing: 2.2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.accent.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '⚡ TOP 5% VELOCITY',
                        style: TextStyle(
                          color: theme.accent,
                          fontWeight: FontWeight.w800,
                          fontSize: 10.5,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Avatar
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [theme.glow, theme.border],
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 34,
                    backgroundColor: const Color(0xFF141A2A),
                    child: Text(
                      displayName.isNotEmpty
                          ? displayName[0].toUpperCase()
                          : 'N',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Level ${g.level} • ${g.rankTitle}',
                  style: TextStyle(
                    color: theme.accent,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 20),

                // Stat Pills
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _flexPill('🔥 ${g.streakDays} Days', 'Streak'),
                    _flexPill('⚡ ${g.xp} XP', 'Cognitive XP'),
                    _flexPill('⏳ ${g.focusMinutesTotal}m', 'Deep Focus'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Action Button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
              Clipboard.setData(ClipboardData(
                text: '🧠 Check out my NovaMind cognitive velocity: Level ${g.level} ${g.rankTitle} with ${g.xp} XP! Built with NovaMind AI.',
              ));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFF1E1035),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: theme.border),
                  ),
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: Color(0xFF22D3EE), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Card stats copied! Ready for Instagram & TikTok 🚀',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: [theme.glow, theme.border],
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.border.withValues(alpha: 0.3),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Copy & Share Story Card',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _flexPill(String val, String lbl) {
    return Column(
      children: [
        Text(
          val,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          lbl,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
