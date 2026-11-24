import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'main_nav_screen.dart';
import 'login_screen.dart';
import '../core/widgets/nova_living_core.dart';
import '../core/widgets/nova_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _fadeAnimation;
  String _statusText = 'INITIALIZING COGNITIVE CORE...';
  double _progress = 0.15;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _runStartupSequence();
  }

  Future<void> _runStartupSequence() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() {
      _statusText = 'SYNAPSE LINK ESTABLISHED...';
      _progress = 0.55;
    });

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {
      _statusText = 'NEURAL ENGINE READY';
      _progress = 1.0;
    });

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final isLoggedIn = await AuthService().isLoggedIn();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            isLoggedIn ? const MainNavScreen() : const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080B16),
      body: Stack(
        children: [
          const NovaBackground(),
          SafeArea(
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Pulsating Orbital Living Core
                    const SizedBox(
                      height: 160,
                      width: 160,
                      child: NovaLivingCore(size: 160),
                    ),

                    const SizedBox(height: 36),

                    const Text(
                      'NOVAMIND',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4.0,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'AI Learning & Cognitive Operating System',
                      style: TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Status Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF13172E),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            height: 10,
                            width: 10,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF22D3EE),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _statusText,
                            style: const TextStyle(
                              color: Color(0xFF22D3EE),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Progress Line
                    SizedBox(
                      width: 160,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0.0, end: _progress),
                          duration: const Duration(milliseconds: 400),
                          builder: (context, val, _) {
                            return LinearProgressIndicator(
                              value: val,
                              minHeight: 4,
                              backgroundColor: Colors.white10,
                              valueColor: const AlwaysStoppedAnimation(
                                Color(0xFF7C3AED),
                              ),
                            );
                          },
                        ),
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
