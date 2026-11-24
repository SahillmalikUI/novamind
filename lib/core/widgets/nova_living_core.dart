import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A living, breathing interactive AI energy core with rotating orbital rings,
/// pulsating aura glow, and reactive touch animations.
class NovaLivingCore extends StatefulWidget {
  final double size;
  final VoidCallback? onTap;
  final String statusText;
  final String subStatus;

  const NovaLivingCore({
    super.key,
    this.size = 110,
    this.onTap,
    this.statusText = 'Nova AI Active',
    this.subStatus = '⚡ 94% Brain Energy',
  });

  @override
  State<NovaLivingCore> createState() => _NovaLivingCoreState();
}

class _NovaLivingCoreState extends State<NovaLivingCore>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _orbitController;
  late final Animation<double> _pulseScale;
  late final Animation<double> _haloGlow;

  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _pulseScale = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );

    _haloGlow = Tween<double>(begin: 0.35, end: 0.65).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _orbitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutBack,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: widget.size * 1.25,
              width: widget.size * 1.25,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 1. Ambient outer aura glow
                  AnimatedBuilder(
                    animation: _haloGlow,
                    builder: (context, child) {
                      return Container(
                        height: widget.size * 1.15,
                        width: widget.size * 1.15,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF8B5CF6)
                                  .withValues(alpha: _haloGlow.value * 0.7),
                              blurRadius: 40,
                              spreadRadius: 6,
                            ),
                            BoxShadow(
                              color: const Color(0xFF22D3EE)
                                  .withValues(alpha: _haloGlow.value * 0.45),
                              blurRadius: 55,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // 2. Rotating orbital rings
                  AnimatedBuilder(
                    animation: _orbitController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _orbitController.value * 2 * math.pi,
                        child: CustomPaint(
                          size: Size(widget.size * 1.2, widget.size * 1.2),
                          painter: _OrbitalRingPainter(),
                        ),
                      );
                    },
                  ),

                  // 3. Counter-rotating inner dashed orbit
                  AnimatedBuilder(
                    animation: _orbitController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: -_orbitController.value * 2 * math.pi * 1.4,
                        child: Container(
                          height: widget.size * 0.88,
                          width: widget.size * 0.88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF22D3EE)
                                  .withValues(alpha: 0.35),
                              width: 1.2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // 4. Central breathing core ball
                  AnimatedBuilder(
                    animation: _pulseScale,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseScale.value,
                        child: Container(
                          height: widget.size * 0.70,
                          width: widget.size * 0.70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              center: Alignment(-0.25, -0.25),
                              radius: 0.9,
                              colors: [
                                Color(0xFFFFFFFF),
                                Color(0xFFA78BFA),
                                Color(0xFF8B5CF6),
                                Color(0xFF4F6FE6),
                                Color(0xFF0F172A),
                              ],
                              stops: [0.05, 0.28, 0.58, 0.85, 1.0],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF8B5CF6)
                                    .withValues(alpha: 0.65),
                                blurRadius: 28,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Glass shine reflection
                              Positioned(
                                top: widget.size * 0.12,
                                left: widget.size * 0.15,
                                child: Container(
                                  height: widget.size * 0.18,
                                  width: widget.size * 0.24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white
                                        .withValues(alpha: 0.45),
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.auto_awesome_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Status chip badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF141A2A).withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                  width: 1.1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF22C55E),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0xFF22C55E),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.statusText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 1,
                    height: 12,
                    color: Colors.white24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.subStatus,
                    style: const TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrbitalRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    final paint = Paint()
      ..color = const Color(0xFF8B5CF6).withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;

    // Draw orbital ellipse
    canvas.drawCircle(center, radius, paint);

    // Draw orbital satellites (energy beads)
    final satellitePaint = Paint()
      ..color = const Color(0xFF22D3EE)
      ..style = PaintingStyle.fill;

    const angle1 = 0.0;
    const angle2 = math.pi;

    canvas.drawCircle(
      Offset(
        center.dx + radius * math.cos(angle1),
        center.dy + radius * math.sin(angle1),
      ),
      3.5,
      satellitePaint,
    );

    canvas.drawCircle(
      Offset(
        center.dx + radius * math.cos(angle2),
        center.dy + radius * math.sin(angle2),
      ),
      2.5,
      satellitePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
