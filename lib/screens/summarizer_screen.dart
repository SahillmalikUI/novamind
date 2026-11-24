import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/ai_service.dart';
import '../providers/task_provider.dart';
import '../providers/gamification_provider.dart';
import '../core/widgets/nova_background.dart';
import '../core/widgets/nova_header_icon_button.dart';

class SummarizerScreen extends ConsumerStatefulWidget {
  const SummarizerScreen({super.key});

  @override
  ConsumerState<SummarizerScreen> createState() => _SummarizerScreenState();
}

class _SummarizerScreenState extends ConsumerState<SummarizerScreen> {
  final TextEditingController _textController = TextEditingController();
  final AiService _aiService = AiService();

  final List<String> _styles = ['Brief', 'Bullets', 'Action Items', 'Simple'];
  String _style = 'Brief';

  bool _loading = false;
  String _summary = '';
  List<String> _actionItems = [];
  String _error = '';

  final Map<String, String> _samples = {
    '📄 AI Agents':
        'Autonomous AI agents operate using perception, planning, tool usage, and memory loops. '
        'Instead of simple prompt-response interactions, multi-agent frameworks divide complex '
        'tasks into distinct subagents. Key components include sandboxed execution, memory indexing, '
        'and reactive event handling to avoid polling.',
    '💻 Architecture':
        'We decided to migrate the backend to a serverless architecture using Supabase for PostgreSQL '
        'storage and authentication, alongside Google Gemini Flash Lite for high-velocity cognitive AI. '
        'The mobile client runs Flutter 3 with Riverpod async state management to ensure offline resiliency.',
    '📅 Sprint Notes':
        'Sprint Review Notes: 1. Deploy the new living core animation to main. 2. Verify Supabase '
        'task schema cache. 3. Finish testing the 25-minute Pomodoro flow chamber. 4. Release '
        'v1.0.0 build on the Google Play Store by Friday afternoon.',
  };

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _loadSample(String text) {
    HapticFeedback.lightImpact();
    setState(() {
      _textController.text = text;
      _error = '';
    });
  }

  Future<void> _summarize() async {
    final text = _textController.text.trim();

    if (text.length < 30) {
      setState(() => _error = 'Please enter or paste at least 30 characters to scan.');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _error = '';
      _summary = '';
      _actionItems = [];
    });

    try {
      final summary = await _aiService.summarize(text: text, style: _style);

      if (!mounted) return;

      // Detect bullet points or action items
      final detectedItems = <String>[];
      for (final line in summary.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.startsWith('-') ||
            trimmed.startsWith('•') ||
            trimmed.startsWith('*') ||
            RegExp(r'^\d+\.').hasMatch(trimmed)) {
          final clean = trimmed.replaceAll(RegExp(r'^[•\-\*\d\.\s]+'), '').trim();
          if (clean.isNotEmpty) {
            detectedItems.add(clean);
          }
        }
      }

      setState(() {
        _summary = summary.isEmpty ? 'No summary generated.' : summary;
        _actionItems = detectedItems;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'NovaMind could not scan this text right now. Please try again.';
        _loading = false;
      });
    }
  }

  Future<void> _deployActionItemsToTasks() async {
    if (_actionItems.isEmpty) return;
    HapticFeedback.mediumImpact();

    for (final item in _actionItems) {
      await ref.read(tasksProvider.notifier).addTask(item);
    }
    ref.read(gamificationProvider.notifier).addXp(30);

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
            const Icon(Icons.bolt_rounded, color: Color(0xFF22D3EE), size: 22),
            const SizedBox(width: 10),
            Text(
              'Added ${_actionItems.length} tasks from summary! +30 XP ⚡',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wordCount = _textController.text.trim().isEmpty
        ? 0
        : _textController.text.trim().split(RegExp(r'\s+')).length;

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
                        color: const Color(0xFFEC4899).withValues(alpha: 0.35),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.psychology_rounded,
                                color: Color(0xFFEC4899), size: 24),
                            SizedBox(width: 8),
                            Text(
                              'Smart Cognitive Scanner',
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
                          'Distill research papers, lecture notes, or meeting logs into ultra-high-yield executive takeaways.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 13.5,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Quick Sample Pills
                  Row(
                    children: [
                      const Text(
                        'Quick Samples:',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _samples.entries.map((e) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: GestureDetector(
                                  onTap: () => _loadSample(e.value),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF13172E),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFEC4899)
                                            .withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Text(
                                      e.key,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  _GlassTextArea(
                    controller: _textController,
                    hint: 'Paste notes, articles, or transcripts here...',
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        wordCount > 0
                            ? 'Estimated read: ~${(wordCount / 180).ceil()} min'
                            : '',
                        style: const TextStyle(
                          color: Color(0xFF22D3EE),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '$wordCount words',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _label('Scanner Mode'),
                  const SizedBox(height: 8),
                  _ChipRow(
                    options: _styles,
                    selected: _style,
                    onSelected: (v) => setState(() => _style = v),
                  ),

                  if (_error.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _ErrorText(_error),
                  ],

                  const SizedBox(height: 24),

                  _GradientButton(
                    label: _loading ? 'Scanning & Distilling...' : 'Scan & Extract Insights',
                    icon: _loading ? Icons.hourglass_top_rounded : Icons.auto_awesome_rounded,
                    loading: _loading,
                    onTap: _loading ? null : _summarize,
                  ),

                  // Cognitive Output Card
                  if (_summary.isNotEmpty) ...[
                    const SizedBox(height: 28),
                    _ResultCard(
                      summary: _summary,
                      wordCount: wordCount,
                      actionItems: _actionItems,
                      onDeployActionItems: _deployActionItemsToTasks,
                      onCopy: () {
                        Clipboard.setData(ClipboardData(text: _summary));
                        HapticFeedback.lightImpact();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Color(0xFF7C3AED),
                            content: Text('Insights copied to clipboard'),
                          ),
                        );
                      },
                    ),
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
            'Cognitive Scanner',
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

class _ResultCard extends StatelessWidget {
  final String summary;
  final int wordCount;
  final List<String> actionItems;
  final VoidCallback onDeployActionItems;
  final VoidCallback onCopy;

  const _ResultCard({
    required this.summary,
    required this.wordCount,
    required this.actionItems,
    required this.onDeployActionItems,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final summaryWords = summary.split(RegExp(r'\s+')).length;
    final reductionPct = wordCount > 0
        ? (((wordCount - summaryWords) / wordCount) * 100).clamp(10, 95).toInt()
        : 65;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF101626),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFEC4899).withValues(alpha: 0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEC4899).withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar with Compression Tag
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.bolt_rounded, color: Color(0xFF22D3EE), size: 20),
                      SizedBox(width: 6),
                      Text(
                        'Extracted Intelligence',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '📉 $reductionPct% Compression',
                      style: const TextStyle(
                        color: Color(0xFF22C55E),
                        fontWeight: FontWeight.w800,
                        fontSize: 11.5,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Summary Text
              Text(
                summary,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14.5,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),

              if (actionItems.isNotEmpty) ...[
                const SizedBox(height: 18),
                GestureDetector(
                  onTap: onDeployActionItems,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF7C3AED), Color(0xFF0284C7)],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.playlist_add_check_rounded,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Deploy ${actionItems.length} Action Items to Tasks (+30 XP)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: onCopy,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.copy_rounded,
                              color: Colors.white, size: 15),
                          SizedBox(width: 6),
                          Text(
                            'Copy Takeaways',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassTextArea extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  const _GlassTextArea({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF13172E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFEC4899).withValues(alpha: 0.3),
        ),
      ),
      child: TextField(
        controller: controller,
        minLines: 4,
        maxLines: 8,
        onChanged: onChanged,
        style: const TextStyle(color: Colors.white, fontSize: 14.5, height: 1.4),
        decoration: InputDecoration(
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
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onSelected(opt),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
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
                  fontSize: 12.5,
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
            colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEC4899).withValues(alpha: 0.3),
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
