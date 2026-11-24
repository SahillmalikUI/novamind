import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/widgets/nova_background.dart';
import '../core/widgets/nova_header_icon_button.dart';
import '../providers/gamification_provider.dart';

class FocusScreen extends ConsumerStatefulWidget {
  const FocusScreen({super.key});

  @override
  ConsumerState<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends ConsumerState<FocusScreen>
    with TickerProviderStateMixin {
  int _selectedMinutes = 25;
  int _remainingSeconds = 25 * 60;
  Timer? _timer;
  bool _isRunning = false;

  final List<String> _soundscapes = [
    '🧠 Alpha 432Hz',
    '🌧️ Cyber Rain',
    '🌌 Deep Void',
    '⚡ Gamma 40Hz',
  ];
  String _activeSoundscape = '🧠 Alpha 432Hz';

  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;

  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _selectedMinutes * 60;

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _selectDuration(int minutes) {
    if (_isRunning) return;
    HapticFeedback.lightImpact();
    setState(() {
      _selectedMinutes = minutes;
      _remainingSeconds = minutes * 60;
    });
  }

  void _selectSoundscape(String sound) {
    HapticFeedback.lightImpact();
    setState(() => _activeSoundscape = sound);
  }

  void _toggleTimer() {
    HapticFeedback.mediumImpact();
    if (_isRunning) {
      _timer?.cancel();
      setState(() => _isRunning = false);
    } else {
      setState(() => _isRunning = true);
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() => _remainingSeconds--);
        } else {
          _timer?.cancel();
          _onSessionCompleted();
        }
      });
    }
  }

  void _resetTimer() {
    HapticFeedback.lightImpact();
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _selectedMinutes * 60;
    });
  }

  void _onSessionCompleted() {
    HapticFeedback.heavyImpact();
    ref.read(gamificationProvider.notifier).addFocusSession(_selectedMinutes);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: AlertDialog(
            backgroundColor: const Color(0xFF141A2A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
              side: const BorderSide(color: Color(0xFF22C55E), width: 1.5),
            ),
            title: const Column(
              children: [
                Text('🎉', style: TextStyle(fontSize: 48)),
                SizedBox(height: 10),
                Text(
                  'Hyperfocus Completed!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 21,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'You stayed locked in for $_selectedMinutes minutes under $_activeSoundscape.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.bolt_rounded,
                        color: Color(0xFF22C55E),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+${_selectedMinutes * 2} Cognitive XP Earned',
                        style: const TextStyle(
                          color: Color(0xFF22C55E),
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetTimer();
                },
                child: const Text(
                  'Claim & Continue',
                  style: TextStyle(
                    color: Color(0xFF8B5CF6),
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(int totalSeconds) {
    final mins = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final gamification = ref.watch(gamificationProvider);
    final totalSeconds = _selectedMinutes * 60;
    final progress = totalSeconds > 0
        ? ((totalSeconds - _remainingSeconds) / totalSeconds).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF080B16),
      body: Stack(
        children: [
          const NovaBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 1. Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                      child: Row(
                        children: [
                          NovaHeaderIconButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cyber Flow Chamber',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'Neuro-Beats & Deep Work Studio',
                                  style: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // XP Chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6)
                                  .withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF8B5CF6)
                                  .withValues(alpha: 0.35),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.bolt_rounded,
                                  color: Color(0xFF8B5CF6),
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${gamification.xp} XP',
                                  style: const TextStyle(
                                    color: Color(0xFFA78BFA),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 2. Large Animated Circular Countdown Ring
                    ScaleTransition(
                      scale: _isRunning
                          ? _pulseScale
                          : const AlwaysStoppedAnimation(1.0),
                      child: SizedBox(
                        height: 250,
                        width: 250,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Ambient Outer Halo
                            Container(
                              height: 230,
                              width: 230,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF8B5CF6).withValues(
                                        alpha: _isRunning ? 0.35 : 0.15),
                                    blurRadius: 40,
                                    spreadRadius: 4,
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFF22D3EE).withValues(
                                        alpha: _isRunning ? 0.25 : 0.08),
                                    blurRadius: 60,
                                    spreadRadius: 8,
                                  ),
                                ],
                              ),
                            ),

                            // Circular Progress Bar
                            SizedBox(
                              height: 220,
                              width: 220,
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 10,
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.08),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFF8B5CF6),
                                ),
                              ),
                            ),

                            // Center Digital Counter
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _formatTime(_remainingSeconds),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 48,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 2.0,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _isRunning
                                      ? _activeSoundscape
                                      : 'Tap to Lock In',
                                  style: TextStyle(
                                    color: _isRunning
                                        ? const Color(0xFF22D3EE)
                                        : const Color(0xFF94A3B8),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 3. Audio Equalizer Waveform Bars
                    AnimatedBuilder(
                      animation: _waveController,
                      builder: (context, _) {
                        return Container(
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(24, (index) {
                              final waveOffset =
                                  (index / 24.0) * 2 * math.pi +
                                      _waveController.value * 2 * math.pi;
                              final normalizedHeight = _isRunning
                                  ? 0.3 + 0.7 * ((math.sin(waveOffset) + 1) / 2)
                                  : 0.15;
                              return Container(
                                width: 4.5,
                                height: 38 * normalizedHeight,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: _isRunning
                                        ? [
                                            const Color(0xFF7C3AED),
                                            const Color(0xFF22D3EE),
                                          ]
                                        : [
                                            Colors.white24,
                                            Colors.white10,
                                          ],
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // 4. Soundscape Pills
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _soundscapes.map((sound) {
                            final isSelected = _activeSoundscape == sound;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => _selectSoundscape(sound),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 13, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF1E1B4B)
                                        : const Color(0xFF101626),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF22D3EE)
                                          : Colors.white.withValues(alpha: 0.1),
                                    ),
                                  ),
                                  child: Text(
                                    sound,
                                    style: TextStyle(
                                      color: isSelected
                                          ? const Color(0xFF22D3EE)
                                          : const Color(0xFF94A3B8),
                                      fontWeight: isSelected
                                          ? FontWeight.w800
                                          : FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 5. Duration Selector Pills
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [15, 25, 45, 60].map((mins) {
                          final isSelected = _selectedMinutes == mins;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: GestureDetector(
                              onTap: () => _selectDuration(mins),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF8B5CF6)
                                      : const Color(0xFF141A2A),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFA78BFA)
                                        : Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Text(
                                  '${mins}m',
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF94A3B8),
                                    fontWeight: isSelected
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 6. Action Buttons (Play / Pause & Reset)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          if (_isRunning || _remainingSeconds != totalSeconds)
                            Padding(
                              padding: const EdgeInsets.only(right: 14),
                              child: Container(
                                height: 56,
                                width: 56,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF141A2A),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.12),
                                  ),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.refresh_rounded,
                                    color: Colors.white70,
                                    size: 24,
                                  ),
                                  onPressed: _resetTimer,
                                ),
                              ),
                            ),

                          // Start / Pause Button
                          Expanded(
                            child: GestureDetector(
                              onTap: _toggleTimer,
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: _isRunning
                                        ? [
                                            const Color(0xFFEF4444),
                                            const Color(0xFFDC2626)
                                          ]
                                        : [
                                            const Color(0xFF8B5CF6),
                                            const Color(0xFF4F6FE6)
                                          ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: (_isRunning
                                              ? const Color(0xFFEF4444)
                                              : const Color(0xFF8B5CF6))
                                          .withValues(alpha: 0.4),
                                      blurRadius: 24,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _isRunning
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 26,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _isRunning
                                          ? 'Pause Flow'
                                          : 'Begin Deep Work',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
        ],
      ),
    );
  }
}
