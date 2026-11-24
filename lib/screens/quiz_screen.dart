import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_service.dart';
import '../core/widgets/nova_background.dart';
import '../core/widgets/nova_orb.dart';
import '../core/widgets/nova_header_icon_button.dart';
import '../providers/gamification_provider.dart';
import 'widgets/flex_card_sheet.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key});

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

enum _QuizPhase { setup, playing, result }

class _QuizScreenState extends ConsumerState<QuizScreen> {
  final TextEditingController _topicController = TextEditingController();
  final AiService _aiService = AiService();

  final List<String> _counts = ['3', '5', '8'];
  final List<String> _difficulties = ['Easy', 'Medium', 'Hard'];

  String _count = '5';
  String _difficulty = 'Medium';

  _QuizPhase _phase = _QuizPhase.setup;
  bool _loading = false;
  String _error = '';

  List<QuizQuestion> _questions = [];
  int _current = 0;
  int _score = 0;
  int? _selected;
  bool _answered = false;

  // Arcade gamification
  int _streak = 0;
  int _totalXpEarned = 0;
  String? _recentFloatingXp;

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  Future<void> _startQuiz() async {
    final topic = _topicController.text.trim();

    if (topic.isEmpty) {
      setState(() => _error = 'Please enter a topic for your quiz.');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final questions = await _aiService.generateQuiz(
        topic: topic,
        count: int.tryParse(_count) ?? 5,
        difficulty: _difficulty,
      );

      if (!mounted) return;

      if (questions.isEmpty) {
        setState(() {
          _error = 'No questions were generated. Try a different topic.';
          _loading = false;
        });
        return;
      }

      setState(() {
        _questions = questions;
        _current = 0;
        _score = 0;
        _streak = 0;
        _totalXpEarned = 0;
        _recentFloatingXp = null;
        _selected = null;
        _answered = false;
        _phase = _QuizPhase.playing;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'NovaMind could not build a quiz right now. Please try again.';
        _loading = false;
      });
    }
  }

  void _selectOption(int index) {
    if (_answered) return;

    final isCorrect = index == _questions[_current].correctIndex;

    setState(() {
      _selected = index;
      _answered = true;
      if (isCorrect) {
        HapticFeedback.mediumImpact();
        _score++;
        _streak++;
        final bonus = _streak >= 3 ? 25 : (_streak == 2 ? 15 : 10);
        _totalXpEarned += bonus;
        _recentFloatingXp = '+$bonus XP 🔥';
        ref.read(gamificationProvider.notifier).addXp(bonus);
      } else {
        HapticFeedback.lightImpact();
        _streak = 0;
        _recentFloatingXp = null;
      }
    });
  }

  void _next() {
    if (_current < _questions.length - 1) {
      setState(() {
        _current++;
        _selected = null;
        _answered = false;
        _recentFloatingXp = null;
      });
    } else {
      setState(() => _phase = _QuizPhase.result);
    }
  }

  void _restart() {
    setState(() {
      _phase = _QuizPhase.setup;
      _questions = [];
      _current = 0;
      _score = 0;
      _streak = 0;
      _totalXpEarned = 0;
      _selected = null;
      _answered = false;
      _error = '';
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
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 86),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 10),
                  Expanded(child: _buildBody()),
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
          icon: Navigator.canPop(context)
              ? Icons.arrow_back_ios_new_rounded
              : Icons.refresh_rounded,
          onTap: () {
            if (_phase == _QuizPhase.playing) {
              _restart();
            } else if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              _restart();
            }
          },
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Quiz Arena',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        if (_phase == _QuizPhase.playing && _streak > 1)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF97316), Color(0xFFE11D48)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${_streak}x STREAK',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBody() {
    switch (_phase) {
      case _QuizPhase.setup:
        return _buildSetup();
      case _QuizPhase.playing:
        return _buildQuestion();
      case _QuizPhase.result:
        return _buildResult();
    }
  }

  Widget _buildSetup() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Center(child: NovaMiniOrb(icon: Icons.quiz_rounded)),
          const SizedBox(height: 16),
          const Text(
            'Cognitive Arena',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Enter any subject. NovaMind AI generates live multiple-choice battles with XP streaks.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 14.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 22),
          _GlassField(
            controller: _topicController,
            hint: 'e.g. Flutter Architecture, Python, World History',
            icon: Icons.lightbulb_outline_rounded,
          ),
          const SizedBox(height: 20),
          _label('Questions'),
          const SizedBox(height: 10),
          _ChipRow(
            options: _counts,
            selected: _count,
            onSelected: (v) => setState(() => _count = v),
          ),
          const SizedBox(height: 20),
          _label('Difficulty'),
          const SizedBox(height: 10),
          _ChipRow(
            options: _difficulties,
            selected: _difficulty,
            onSelected: (v) => setState(() => _difficulty = v),
          ),
          if (_error.isNotEmpty) ...[
            const SizedBox(height: 16),
            _ErrorText(_error),
          ],
          const SizedBox(height: 24),
          _GradientButton(
            label: _loading ? 'Generating battle...' : 'Launch Quiz Arena',
            icon: _loading ? Icons.hourglass_top_rounded : Icons.flash_on_rounded,
            loading: _loading,
            onTap: _loading ? null : _startQuiz,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion() {
    final q = _questions[_current];
    final progress = (_current + 1) / _questions.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Question ${_current + 1} of ${_questions.length}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (_recentFloatingXp != null)
              Text(
                _recentFloatingXp!,
                style: const TextStyle(
                  color: Color(0xFF22D3EE),
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            const SizedBox(width: 10),
            Text(
              'Score $_score',
              style: const TextStyle(
                color: Color(0xFFA78BFA),
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: Colors.white.withValues(alpha: 0.09),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF7C3AED)),
          ),
        ),
        const SizedBox(height: 22),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  q.question,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                ...List.generate(q.options.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _OptionTile(
                      text: q.options[i],
                      state: _optionState(i, q.correctIndex),
                      onTap: () => _selectOption(i),
                    ),
                  );
                }),
                if (_answered && q.explanation.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  _ExplanationCard(explanation: q.explanation),
                ],
              ],
            ),
          ),
        ),
        if (_answered) ...[
          const SizedBox(height: 12),
          _GradientButton(
            label: _current < _questions.length - 1 ? 'Next Question' : 'Claim Victory',
            icon: Icons.arrow_forward_rounded,
            loading: false,
            onTap: _next,
          ),
        ],
      ],
    );
  }

  _OptionState _optionState(int i, int correct) {
    if (!_answered) return _OptionState.idle;
    if (i == correct) return _OptionState.correct;
    if (i == _selected) return _OptionState.wrong;
    return _OptionState.dimmed;
  }

  Widget _buildResult() {
    final total = _questions.length;
    final pct = total == 0 ? 0 : (_score / total * 100).round();

    String rankTitle;
    Color color;
    if (pct == 100) {
      rankTitle = 'S-Tier Neural Titan 💎';
      color = const Color(0xFF22D3EE);
    } else if (pct >= 80) {
      rankTitle = 'A-Tier Cyber Scholar ⚡';
      color = const Color(0xFF22C55E);
    } else if (pct >= 50) {
      rankTitle = 'B-Tier Synapse Runner 🚀';
      color = const Color(0xFFFACC15);
    } else {
      rankTitle = 'C-Tier Neural Initiate 🛡️';
      color = const Color(0xFFFB7185);
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Center(child: NovaMiniOrb(icon: Icons.emoji_events_rounded)),
          const SizedBox(height: 16),
          Text(
            rankTitle,
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$_score / $total',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 52,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            '$pct% Accuracy • +$_totalXpEarned XP Earned',
            style: const TextStyle(
              color: Color(0xFF22D3EE),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 26),

          // Cognitive Flex Card Share Button
          GestureDetector(
            onTap: () => FlexCardSheet.show(context),
            child: Container(
              height: 52,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEC4899).withValues(alpha: 0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.share_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Share Cognitive Flex Card',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 14),
          _GradientButton(
            label: 'Battle Again',
            icon: Icons.refresh_rounded,
            loading: false,
            onTap: _restart,
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 50,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.white.withValues(alpha: 0.06),
                border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: const Center(
                child: Text(
                  'Back to Hub',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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

enum _OptionState { idle, correct, wrong, dimmed }

class _OptionTile extends StatelessWidget {
  final String text;
  final _OptionState state;
  final VoidCallback onTap;

  const _OptionTile({
    required this.text,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color border;
    Color fill;
    Color textColor = Colors.white;
    IconData? trailing;
    Color trailingColor = Colors.white;

    switch (state) {
      case _OptionState.correct:
        border = const Color(0xFF22C55E);
        fill = const Color(0xFF22C55E).withValues(alpha: 0.18);
        trailing = Icons.check_circle_rounded;
        trailingColor = const Color(0xFF22C55E);
        break;
      case _OptionState.wrong:
        border = const Color(0xFFEF4444);
        fill = const Color(0xFFEF4444).withValues(alpha: 0.18);
        trailing = Icons.cancel_rounded;
        trailingColor = const Color(0xFFFCA5A5);
        break;
      case _OptionState.dimmed:
        border = Colors.white.withValues(alpha: 0.05);
        fill = Colors.white.withValues(alpha: 0.02);
        textColor = Colors.white.withValues(alpha: 0.35);
        break;
      case _OptionState.idle:
        border = const Color(0xFF8B5CF6).withValues(alpha: 0.25);
        fill = const Color(0xFF13172E).withValues(alpha: 0.7);
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 10),
              Icon(trailing, color: trailingColor, size: 22),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExplanationCard extends StatelessWidget {
  final String explanation;

  const _ExplanationCard({required this.explanation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF13172E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFF22D3EE), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              explanation,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 13.5,
                height: 1.4,
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
                  color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.6),
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
          const Icon(Icons.error_outline_rounded, color: Color(0xFFFCA5A5), size: 18),
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
