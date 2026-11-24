import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/gamification_provider.dart';
import '../../core/widgets/nova_living_core.dart';

class NeuralCalibrationSheet extends ConsumerStatefulWidget {
  const NeuralCalibrationSheet({super.key});

  static Future<void> show(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NeuralCalibrationSheet(),
    );
  }

  @override
  ConsumerState<NeuralCalibrationSheet> createState() =>
      _NeuralCalibrationSheetState();
}

class _NeuralCalibrationSheetState
    extends ConsumerState<NeuralCalibrationSheet> {
  int _currentStep = 0;

  final List<Map<String, String>> _domains = [
    {
      'title': 'Software & System Architecture',
      'icon': '💻',
      'desc': 'Deep coding, algorithms, and technical mastery',
    },
    {
      'title': 'Academic & Scientific Research',
      'icon': '📚',
      'desc': 'High-yield studying, exam prep, and synthesis',
    },
    {
      'title': 'Hyper-Productivity & Work Execution',
      'icon': '⚡',
      'desc': 'Deep work flow, task crushing, and momentum',
    },
    {
      'title': 'Rapid Skill Acquisition',
      'icon': '🧠',
      'desc': 'Accelerated learning and mental model retention',
    },
  ];

  int _selectedDomain = 0;
  int _selectedFocusTime = 25;

  void _nextStep() {
    HapticFeedback.mediumImpact();
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      if (_currentStep == 2) {
        // Complete calibration
        ref.read(gamificationProvider.notifier).completeCalibration(
              goal: _domains[_selectedDomain]['title']!,
              focusMinutes: _selectedFocusTime,
            );
      }
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        22,
        16,
        22,
        MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF0F1424),
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
          const SizedBox(height: 18),

          // Step Progress Dots
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) {
              final active = i == _currentStep;
              final passed = i < _currentStep;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                height: 6,
                width: active ? 28 : 12,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: passed || active
                      ? const Color(0xFF22D3EE)
                      : Colors.white12,
                ),
              );
            }),
          ),
          const SizedBox(height: 20),

          if (_currentStep == 0) _buildStep0(),
          if (_currentStep == 1) _buildStep1(),
          if (_currentStep == 2) _buildStep2(),

          const SizedBox(height: 24),

          // Primary Continue Button
          GestureDetector(
            onTap: _nextStep,
            child: Container(
              height: 52,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF22D3EE)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF22D3EE).withValues(alpha: 0.3),
                    blurRadius: 18,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _currentStep == 2 ? 'Enter NovaMind Hub 🚀' : 'Continue',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep0() {
    return Column(
      children: [
        const Text(
          'Neural Calibration • Step 1/3',
          style: TextStyle(
            color: Color(0xFF22D3EE),
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Select Your Core Cognitive Objective',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 18),
        ...List.generate(_domains.length, (i) {
          final isSelected = _selectedDomain == i;
          final item = _domains[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _selectedDomain = i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1E1B4B)
                      : const Color(0xFF13172E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF22D3EE)
                        : Colors.white.withValues(alpha: 0.08),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    Text(item['icon']!, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title']!,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFFCBD5E1),
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['desc']!,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle_rounded,
                          color: Color(0xFF22D3EE), size: 20),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStep1() {
    final times = [15, 25, 45, 60];
    return Column(
      children: [
        const Text(
          'Neural Calibration • Step 2/3',
          style: TextStyle(
            color: Color(0xFF22D3EE),
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Daily Hyperfocus Target',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Choose your comfortable deep-work block duration.',
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: times.map((t) {
            final isSelected = _selectedFocusTime == t;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedFocusTime = t);
                },
                child: Container(
                  height: 68,
                  width: 68,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF7C3AED)
                        : const Color(0xFF13172E),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF22D3EE)
                          : Colors.white.withValues(alpha: 0.1),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$t',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Text(
                        'mins',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1035),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.bolt_rounded,
                  color: Color(0xFF22D3EE), size: 18),
              const SizedBox(width: 6),
              Text(
                '+${_selectedFocusTime * 2} XP achievable daily in Flow Chamber',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        const SizedBox(height: 10),
        const SizedBox(
          height: 90,
          width: 90,
          child: NovaLivingCore(size: 90),
        ),
        const SizedBox(height: 16),
        const Text(
          'Neural Link Synchronized!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Your personalized cognitive assistant is calibrated and ready.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF22C55E).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF22C55E).withValues(alpha: 0.4),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.emoji_events_rounded,
                  color: Color(0xFF22C55E), size: 22),
              SizedBox(width: 10),
              Text(
                '+100 Starter XP Awarded • "Neural Initiate" Unlocked',
                style: TextStyle(
                  color: Color(0xFF86EFAC),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
