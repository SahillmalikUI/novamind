import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_service.dart';
import '../providers/task_provider.dart';
import '../providers/gamification_provider.dart';
import '../core/widgets/nova_background.dart';
import '../core/widgets/nova_header_icon_button.dart';

class StudyPlannerScreen extends ConsumerStatefulWidget {
  const StudyPlannerScreen({super.key});

  @override
  ConsumerState<StudyPlannerScreen> createState() => _StudyPlannerScreenState();
}

class RoadmapStage {
  final int stageNumber;
  final String title;
  final String timeFrame;
  final List<String> objectives;
  bool isCompleted;

  RoadmapStage({
    required this.stageNumber,
    required this.title,
    required this.timeFrame,
    required this.objectives,
    this.isCompleted = false,
  });
}

class _StudyPlannerScreenState extends ConsumerState<StudyPlannerScreen> {
  final TextEditingController _topicController = TextEditingController();
  final AiService _aiService = AiService();

  final List<String> _levels = ['Beginner', 'Intermediate', 'Advanced'];
  final List<String> _times = ['3 days', '1 week', '2 weeks', '1 month'];

  final List<String> _quickTopics = [
    'Flutter & Dart Architecture',
    'Machine Learning & Neural Nets',
    'Python Async & FastApi',
    'System Design & Microservices',
  ];

  String _level = 'Beginner';
  String _time = '1 week';

  bool _loading = false;
  String _rawPlan = '';
  List<RoadmapStage> _stages = [];
  String _error = '';

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final topic = _topicController.text.trim();

    if (topic.isEmpty) {
      setState(() => _error = 'Please enter a topic to study.');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _error = '';
      _rawPlan = '';
      _stages = [];
    });

    try {
      final plan = await _aiService.generateStudyPlan(
        topic: topic,
        level: _level,
        time: _time,
      );

      if (!mounted) return;

      setState(() {
        _rawPlan = plan.isEmpty ? 'No plan was generated.' : plan;
        _stages = _parsePlanToStages(_rawPlan, topic);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'NovaMind could not generate a plan right now. Please try again.';
        _loading = false;
      });
    }
  }

  List<RoadmapStage> _parsePlanToStages(String raw, String topic) {
    // Intelligent heuristic parser into visual roadmap stages
    final lines = raw.split('\n');
    final stages = <RoadmapStage>[];
    int currentStageNum = 1;
    String currentTitle = '';
    final currentObjectives = <String>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      if (trimmed.toLowerCase().contains('stage') ||
          trimmed.toLowerCase().contains('phase') ||
          trimmed.toLowerCase().contains('week') ||
          trimmed.toLowerCase().contains('day 1')) {
        if (currentTitle.isNotEmpty && currentObjectives.isNotEmpty) {
          stages.add(RoadmapStage(
            stageNumber: currentStageNum++,
            title: currentTitle,
            timeFrame: 'Stage $currentStageNum',
            objectives: List.from(currentObjectives),
          ));
          currentObjectives.clear();
        }
        currentTitle = trimmed
            .replaceAll(RegExp(r'^[•\-\*\#\d\.\s]+'), '')
            .replaceAll('**', '');
      } else if (trimmed.startsWith('-') ||
          trimmed.startsWith('•') ||
          trimmed.startsWith('*')) {
        final cleanObj = trimmed
            .replaceAll(RegExp(r'^[•\-\*\s]+'), '')
            .replaceAll('**', '');
        if (cleanObj.isNotEmpty) {
          currentObjectives.add(cleanObj);
        }
      } else if (currentTitle.isEmpty) {
        currentTitle = trimmed.replaceAll('**', '');
      }
    }

    if (currentTitle.isNotEmpty && currentObjectives.isNotEmpty) {
      stages.add(RoadmapStage(
        stageNumber: currentStageNum,
        title: currentTitle,
        timeFrame: 'Final Phase',
        objectives: List.from(currentObjectives),
      ));
    }

    // Fallback if parsing couldn't split: produce 3 high-yield stages
    if (stages.isEmpty) {
      stages.addAll([
        RoadmapStage(
          stageNumber: 1,
          title: 'Foundations & Architecture',
          timeFrame: 'Stage 1',
          objectives: [
            'Master core syntax, vocabulary, and primary mental models',
            'Deconstruct essential architectural components',
            'Set up your development & research environment',
          ],
        ),
        RoadmapStage(
          stageNumber: 2,
          title: 'Applied Implementation & Micro-Projects',
          timeFrame: 'Stage 2',
          objectives: [
            'Build 2 practical hands-on prototypes demonstrating key patterns',
            'Identify edge cases, performance bottlenecks, and common errors',
            'Conduct active code walkthroughs without referring to guides',
          ],
        ),
        RoadmapStage(
          stageNumber: 3,
          title: 'Synthesis, Optimization & Deployment',
          timeFrame: 'Stage 3',
          objectives: [
            'Synthesize learnings into a production-grade portfolio piece',
            'Test retention using flash recall and peer explanation',
            'Deploy or publish your verified project showcase',
          ],
        ),
      ]);
    }

    return stages;
  }

  Future<void> _deployToTasks() async {
    if (_stages.isEmpty) return;

    HapticFeedback.mediumImpact();

    int addedCount = 0;
    for (final stage in _stages) {
      for (final obj in stage.objectives) {
        await ref.read(tasksProvider.notifier).addTask(obj);
        addedCount++;
      }
    }

    ref.read(gamificationProvider.notifier).addXp(50);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1E1035),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF22D3EE), width: 1.2),
        ),
        content: Row(
          children: [
            const Icon(Icons.rocket_launch_rounded, color: Color(0xFF22D3EE), size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Deployed $addedCount roadmap tasks! +50 XP 🚀',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleStageComplete(RoadmapStage stage) {
    HapticFeedback.lightImpact();
    setState(() {
      stage.isCompleted = !stage.isCompleted;
      if (stage.isCompleted) {
        ref.read(gamificationProvider.notifier).addXp(25);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF14241A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFF22C55E)),
            ),
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 18),
                SizedBox(width: 8),
                Text(
                  '+25 XP! Roadmap milestone crushed ⚡',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            duration: const Duration(milliseconds: 1400),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080B16),
      body: Stack(
        children: [
          const NovaBackground(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),

                  const SizedBox(height: 20),

                  // Hero Intro
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1E1035).withValues(alpha: 0.9),
                          const Color(0xFF13172E).withValues(alpha: 0.9),
                        ],
                      ),
                      border: Border.all(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.alt_route_rounded,
                                color: Color(0xFF22D3EE), size: 24),
                            SizedBox(width: 8),
                            Text(
                              'Interactive Roadmap Engine',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Transform any learning goal into a timeline of verifiable checkpoints that auto-sync to your tasks.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 13.5,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Quick Topic Sparks
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _quickTopics.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final t = _quickTopics[i];
                        return GestureDetector(
                          onTap: () {
                            _topicController.text = t;
                            setState(() {});
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF13172E),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFF8B5CF6)
                                    .withValues(alpha: 0.25),
                              ),
                            ),
                            child: Text(
                              t,
                              style: const TextStyle(
                                color: Color(0xFFE2E8F0),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  _GlassField(
                    controller: _topicController,
                    hint: 'e.g. Flutter Architecture, Deep Learning',
                    icon: Icons.menu_book_rounded,
                  ),

                  const SizedBox(height: 18),

                  _label('Your Level'),
                  const SizedBox(height: 8),
                  _ChipRow(
                    options: _levels,
                    selected: _level,
                    onSelected: (v) => setState(() => _level = v),
                  ),

                  const SizedBox(height: 18),

                  _label('Timeframe'),
                  const SizedBox(height: 8),
                  _ChipRow(
                    options: _times,
                    selected: _time,
                    onSelected: (v) => setState(() => _time = v),
                  ),

                  if (_error.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _ErrorText(_error),
                  ],

                  const SizedBox(height: 24),

                  _GradientButton(
                    label: _loading ? 'Synthesizing Roadmap...' : 'Generate Neural Roadmap',
                    icon: _loading ? Icons.hourglass_top_rounded : Icons.auto_awesome_rounded,
                    loading: _loading,
                    onTap: _loading ? null : _generate,
                  ),

                  // Visual Timeline Roadmap
                  if (_stages.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Roadmap Timeline',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_stages.where((s) => s.isCompleted).length}/${_stages.length} Completed',
                            style: const TextStyle(
                              color: Color(0xFF22C55E),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Deploy all to Tasks button
                    GestureDetector(
                      onTap: _deployToTasks,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7C3AED), Color(0xFF0284C7)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0284C7).withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.playlist_add_check_rounded,
                                color: Colors.white, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Deploy Roadmap to My Tasks (+50 XP)',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Milestone Timeline Nodes
                    ...List.generate(_stages.length, (index) {
                      final stage = _stages[index];
                      final isLast = index == _stages.length - 1;
                      return _RoadmapNodeTile(
                        stage: stage,
                        isLast: isLast,
                        onToggle: () => _toggleStageComplete(stage),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        NovaHeaderIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.pop(context),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Study Roadmap Studio',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      );
}

class _RoadmapNodeTile extends StatelessWidget {
  final RoadmapStage stage;
  final bool isLast;
  final VoidCallback onToggle;

  const _RoadmapNodeTile({
    required this.stage,
    required this.isLast,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final completed = stage.isCompleted;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator with connector line
          Column(
            children: [
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: completed
                        ? const LinearGradient(
                            colors: [Color(0xFF22C55E), Color(0xFF10B981)],
                          )
                        : const LinearGradient(
                            colors: [Color(0xFF7C3AED), Color(0xFF22D3EE)],
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: (completed
                                ? const Color(0xFF22C55E)
                                : const Color(0xFF22D3EE))
                            .withValues(alpha: 0.35),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: completed
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 20)
                        : Text(
                            '${stage.stageNumber}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.5,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          completed
                              ? const Color(0xFF22C55E)
                              : const Color(0xFF7C3AED),
                          const Color(0xFF22D3EE).withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 14),

          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF101626),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: completed
                        ? const Color(0xFF22C55E).withValues(alpha: 0.4)
                        : const Color(0xFF8B5CF6).withValues(alpha: 0.28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            stage.title,
                            style: TextStyle(
                              color: completed
                                  ? const Color(0xFF86EFAC)
                                  : Colors.white,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              decoration: completed
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: onToggle,
                          child: Icon(
                            completed
                                ? Icons.check_box_rounded
                                : Icons.check_box_outline_blank_rounded,
                            color: completed
                                ? const Color(0xFF22C55E)
                                : const Color(0xFF8B5CF6),
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...stage.objectives.map(
                      (obj) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '• ',
                              style: TextStyle(
                                color: Color(0xFF22D3EE),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                obj,
                                style: TextStyle(
                                  color: Colors.white
                                      .withValues(alpha: completed ? 0.5 : 0.82),
                                  fontSize: 13,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
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

class _GlassField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;

  const _GlassField({
    required this.controller,
    required this.hint,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF13172E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
        ),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          icon: Icon(icon, color: const Color(0xFF8B5CF6)),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.35)),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _ChipRow extends StatelessWidget {
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  const _ChipRow({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: options.map((opt) {
        final isSelected = opt == selected;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: GestureDetector(
            onTap: () => onSelected(opt),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFF22D3EE)],
                      )
                    : null,
                color: isSelected ? null : Colors.white.withValues(alpha: 0.05),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : Colors.white.withValues(alpha: 0.12),
                ),
              ),
              child: Text(
                opt,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.6),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool loading;
  final VoidCallback? onTap;

  const _GradientButton({
    required this.label,
    required this.icon,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  final String message;

  const _ErrorText(this.message);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFEF4444).withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFFCA5A5), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Color(0xFFFCA5A5),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
