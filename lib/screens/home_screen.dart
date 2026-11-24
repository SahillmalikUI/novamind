import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';
import '../providers/task_provider.dart';
import '../providers/gamification_provider.dart';
import '../services/auth_service.dart';
import '../core/widgets/nova_background.dart';
import '../core/widgets/nova_living_core.dart';
import 'login_screen.dart';
import 'task_screen.dart';
import 'chat_screen.dart';
import 'quiz_screen.dart';
import 'study_planner_screen.dart';
import 'summarizer_screen.dart';
import 'focus_screen.dart';
import 'widgets/neural_calibration_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const HomeScreen({super.key, this.onNavigateTab});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
      ),
      (_) => false,
    );
  }

  void _goTo(int tabIndex, Widget fallbackScreen) {
    HapticFeedback.lightImpact();
    if (widget.onNavigateTab != null) {
      widget.onNavigateTab!(tabIndex);
    } else {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              fallbackScreen,
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) =>
                  FadeTransition(opacity: animation, child: child),
        ),
      );
    }
  }

  void _pushModal(Widget screen) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final tasksAsync = ref.watch(tasksProvider);
    final gamification = ref.watch(gamificationProvider);

    final userName = profileAsync.maybeWhen(
      data: (p) => p.name.isNotEmpty ? p.name : 'Learner',
      orElse: () => 'Learner',
    );

    return Scaffold(
      backgroundColor: const Color(0xFF080B16),
      body: Stack(
        children: [
          const NovaBackground(),
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 96),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Top Cyber Bar (Profile, Streaks, XP, Logout)
                      _buildTopCyberBar(userName, gamification),

                      if (!gamification.hasCalibrated) ...[
                        const SizedBox(height: 14),
                        _buildCalibrationBanner(),
                      ],

                      const SizedBox(height: 20),

                      // 2. Living Core Hero Cockpit
                      _buildLivingCoreHero(),

                      const SizedBox(height: 24),

                      // 3. Quick Spark AI Prompt Carousel
                      _buildSparkPrompts(),

                      const SizedBox(height: 24),

                      // 4. Section Label
                      Row(
                        children: [
                          Container(
                            width: 3,
                            height: 16,
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6),
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0xFF8B5CF6),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'COGNITIVE MATRIX',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // 5. Cyber-Bento Grid
                      _buildBentoGrid(tasksAsync),

                      const SizedBox(height: 20),

                      // 6. Daily Cognitive Wisdom
                      _buildDailyWisdomCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Top Cyber Bar ---
  Widget _buildTopCyberBar(String userName, GamificationState gamification) {
    return Row(
      children: [
        // Avatar with pulse ring
        Container(
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF22D3EE)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: const Color(0xFF141A2A),
            child: Text(
              userName.isNotEmpty ? userName[0].toUpperCase() : 'N',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Greeting
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $userName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Lvl ${gamification.level} • ${gamification.rankTitle}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF38BDF8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        // Streak Chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🔥', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 4),
              Text(
                '${gamification.streakDays} Days',
                style: const TextStyle(
                  color: Color(0xFFFBBF24),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Logout
        IconButton(
          onPressed: _logout,
          icon: const Icon(
            Icons.logout_rounded,
            color: Color(0xFF64748B),
            size: 20,
          ),
          tooltip: 'Sign Out',
        ),
      ],
    );
  }

  Widget _buildCalibrationBanner() {
    return GestureDetector(
      onTap: () => NeuralCalibrationSheet.show(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF0284C7)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0284C7).withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Calibrate Neural Baseline',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Personalize NovaMind & Claim +100 Starter XP',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }

  // --- Living Core Hero ---
  Widget _buildLivingCoreHero() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1E1B4B).withValues(alpha: 0.65),
                const Color(0xFF0F172A).withValues(alpha: 0.85),
              ],
            ),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.28),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.18),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Living Nova Core
              NovaLivingCore(
                size: 104,
                statusText: 'Nova Copilot',
                subStatus: '⚡ Ready to Assist',
                onTap: () => _goTo(2, const ChatScreen()),
              ),
              const SizedBox(height: 16),
              const Text(
                'Empowering your learning journey',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tap the Nova Core or a spark below to start thinking together.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF94A3B8).withValues(alpha: 0.9),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Spark Prompts Carousel ---
  Widget _buildSparkPrompts() {
    final sparks = [
      {'icon': '🚀', 'text': 'Build a 3-Day Sprint', 'tab': 1},
      {'icon': '🧠', 'text': 'Explain Quantum Computing', 'tab': 2},
      {'icon': '⚡', 'text': 'Rapid 3-Question Quiz', 'tab': 3},
      {'icon': '📝', 'text': 'Summarize complex notes', 'modal': true},
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: sparks.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = sparks[index];
          return GestureDetector(
            onTap: () {
              if (item['modal'] == true) {
                _pushModal(const SummarizerScreen());
              } else {
                _goTo(item['tab'] as int, const ChatScreen());
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFF141A2A).withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
              child: Row(
                children: [
                  Text(item['icon'] as String, style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 6),
                  Text(
                    item['text'] as String,
                    style: const TextStyle(
                      color: Color(0xFFE2E8F0),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // --- Cyber-Bento Grid ---
  Widget _buildBentoGrid(AsyncValue<List<dynamic>> tasksAsync) {
    final tasks = tasksAsync.value ?? [];
    final total = tasks.length;
    final done = tasks.where((t) => t.done == true).length;
    final progress = total > 0 ? (done / total) : 0.0;

    return Column(
      children: [
        // Bento Item 0: Cyber Flow Chamber (Pomodoro) Banner
        _buildFocusChamberTile(),

        const SizedBox(height: 14),

        // Bento Item 1: Wide Focus & Live Task Progress Hub
        _buildFocusCard(done: done, total: total, progress: progress),

        const SizedBox(height: 14),

        // Bento Row: Quick Arena (Quiz) & Study Studio
        Row(
          children: [
            // Left: Quick Quiz Arena
            Expanded(
              child: _buildBentoTile(
                title: 'Quiz Arena',
                subtitle: '+50 XP Challenge',
                badge: 'LIVE',
                badgeColor: const Color(0xFFFACC15),
                icon: Icons.sports_esports_rounded,
                accentColor: const Color(0xFFFACC15),
                onTap: () => _goTo(3, const QuizScreen()),
              ),
            ),
            const SizedBox(width: 14),
            // Right: Study Planner
            Expanded(
              child: _buildBentoTile(
                title: 'Study Roadmaps',
                subtitle: 'AI Milestones',
                badge: 'PRO',
                badgeColor: const Color(0xFF22C55E),
                icon: Icons.calendar_month_rounded,
                accentColor: const Color(0xFF22C55E),
                onTap: () => _pushModal(const StudyPlannerScreen()),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Bento Row: Summarizer & Deep Research
        Row(
          children: [
            // Left: Note Summarizer
            Expanded(
              child: _buildBentoTile(
                title: 'Summarizer',
                subtitle: 'Transform Notes',
                badge: 'AI',
                badgeColor: const Color(0xFFFB7185),
                icon: Icons.notes_rounded,
                accentColor: const Color(0xFFFB7185),
                onTap: () => _pushModal(const SummarizerScreen()),
              ),
            ),
            const SizedBox(width: 14),
            // Right: AI Copilot
            Expanded(
              child: _buildBentoTile(
                title: 'Nova Chat',
                subtitle: 'Ask Anything',
                badge: 'COGNITIVE',
                badgeColor: const Color(0xFF22D3EE),
                icon: Icons.chat_bubble_outline_rounded,
                accentColor: const Color(0xFF22D3EE),
                onTap: () => _goTo(2, const ChatScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Cyber Flow Chamber Tile ---
  Widget _buildFocusChamberTile() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const FocusScreen()),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            colors: [Color(0xFF1E1035), Color(0xFF13172E)],
          ),
          border: Border.all(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFF22D3EE)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF22D3EE).withValues(alpha: 0.35),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: const Icon(
                Icons.hourglass_top_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Cyber Flow Chamber',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '⚡ LIVE',
                        style: TextStyle(
                          color: Color(0xFF22D3EE),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3),
                  Text(
                    '25m Deep Work • Binaural Beats • +50 XP',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFF8B5CF6),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  // --- Wide Focus Card with Circular Ring ---
  Widget _buildFocusCard({
    required int done,
    required int total,
    required double progress,
  }) {
    return GestureDetector(
      onTap: () => _goTo(1, const TaskScreen()),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF101626).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFA78BFA).withValues(alpha: 0.22),
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                // Progress Circular Indicator
                SizedBox(
                  height: 64,
                  width: 64,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: total > 0 ? progress : 0.05,
                        strokeWidth: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF8B5CF6),
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 18),
                // Text details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text(
                            'Daily Task Velocity',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Spacer(),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: Color(0xFF94A3B8),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        total == 0
                            ? 'No active tasks. Tap to add your first goal.'
                            : '$done of $total completed • Keep the momentum!',
                        style: TextStyle(
                          color: const Color(0xFF94A3B8).withValues(alpha: 0.9),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Reusable Cyber-Bento Tile ---
  Widget _buildBentoTile({
    required String title,
    required String subtitle,
    required String badge,
    required Color badgeColor,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: 130,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF101626).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.2),
                width: 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: accentColor, size: 20),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: const Color(0xFF94A3B8).withValues(alpha: 0.85),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Daily Cognitive Wisdom Card ---
  Widget _buildDailyWisdomCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0C101D),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('✨', style: TextStyle(fontSize: 18)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'COGNITIVE FUEL',
                  style: TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '"Consistency beats intensity. 25 minutes of active recall every day outperforms a 5-hour marathon."',
                  style: TextStyle(
                    color: Color(0xFFCBD5E1),
                    fontSize: 12.5,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
