import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/task_provider.dart';
import '../providers/gamification_provider.dart';
import '../services/auth_service.dart';
import '../services/ai_service.dart';
import '../models/task.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/nova_background.dart';
import '../core/widgets/nova_logo.dart';
import '../core/widgets/nova_ui.dart';
import 'login_screen.dart';

class TaskScreen extends ConsumerStatefulWidget {
  const TaskScreen({super.key});

  @override
  ConsumerState<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends ConsumerState<TaskScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();

  late final AnimationController _animController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
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
    _controller.dispose();
    super.dispose();
  }

  Future<void> _addTask() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    await ref.read(tasksProvider.notifier).addTask(text);
    _controller.clear();
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) =>
                FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  Future<void> _getAiSuggestions(String goal) async {
    if (goal.isEmpty) return;
    try {
      final suggestions = await AiService().getSuggestions(goal);
      for (final s in suggestions) {
        await ref.read(tasksProvider.notifier).addTask(s);
      }
      if (mounted) {
        _showSnackBar(
          'AI tasks added to your list.',
          icon: Icons.check_circle_outline_rounded,
          isError: false,
        );
      }
    } catch (_) {
      if (mounted) {
        _showSnackBar(
          'NovaMind could not create tasks right now.',
          icon: Icons.error_outline_rounded,
          isError: true,
        );
      }
    }
  }

  void _showSnackBar(
    String message, {
    required IconData icon,
    required bool isError,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: isError ? Nova.danger : Nova.success, size: 21),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: Nova.body)),
          ],
        ),
      ),
    );
  }

  void _showAiDialog() {
    final goalController = TextEditingController();
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Nova.surfaceHigh,
            borderRadius: BorderRadius.circular(Nova.rXl),
            border: Border.all(color: Nova.borderStrong),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const NovaLogo(size: 40),
                  const SizedBox(width: Nova.s12),
                  Expanded(child: Text('Plan with AI', style: Nova.title)),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Nova.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Nova.s8),
              const Text(
                'Describe a goal and NovaMind will break it into tasks.',
                style: Nova.bodySecondary,
              ),
              const SizedBox(height: Nova.s20),
              NovaTextField(
                controller: goalController,
                hint: 'e.g. Learn Flutter authentication',
                minLines: 3,
                maxLines: 4,
              ),
              const SizedBox(height: Nova.s20),
              Row(
                children: [
                  Expanded(
                    child: NovaSecondaryButton(
                      label: 'Cancel',
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: Nova.s12),
                  Expanded(
                    child: NovaPrimaryButton(
                      label: 'Suggest',
                      icon: Icons.auto_awesome_rounded,
                      onTap: () async {
                        final goal = goalController.text.trim();
                        Navigator.pop(context);
                        await _getAiSuggestions(goal);
                      },
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

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      body: Stack(
        children: [
          const NovaBackground(),
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: tasksAsync.when(
                        loading: () => const _LoadingState(),
                        error: (error, stack) => _ErrorState(
                          onRetry: () => ref.refresh(tasksProvider),
                        ),
                        data: (tasks) {
                          final total = tasks.length;
                          final done = tasks.where((t) => t.done).length;
                          final pending = total - done;
                          return ListView(
                            padding: const EdgeInsets.fromLTRB(
                              Nova.s16,
                              Nova.s8,
                              Nova.s16,
                              94,
                            ),
                            children: [
                              _buildHeroCard(total, pending),
                              const SizedBox(height: Nova.s12),
                              _buildStatsRow(total, done, pending),
                              const SizedBox(height: Nova.s16),
                              _buildAddTaskBox(),
                              const SizedBox(height: Nova.s8),
                              if (tasks.isEmpty)
                                const _EmptyState()
                              else
                                ...tasks.map(
                                  (task) => _TaskCard(
                                    task: task,
                                    onTap: () {
                                      final willBeDone = !task.done;
                                      ref
                                          .read(tasksProvider.notifier)
                                          .toggleTask(task);
                                      if (willBeDone) {
                                        ref
                                            .read(gamificationProvider.notifier)
                                            .addXp(15);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor:
                                                const Color(0xFF1E1035),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              side: const BorderSide(
                                                color: Color(0xFF7C3AED),
                                              ),
                                            ),
                                            content: const Row(
                                              children: [
                                                Icon(
                                                  Icons.bolt_rounded,
                                                  color: Color(0xFF22D3EE),
                                                  size: 20,
                                                ),
                                                SizedBox(width: 8),
                                                Text(
                                                  '+15 XP! Task crushed 🔥',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            duration: const Duration(
                                              milliseconds: 1400,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    onDelete: () => ref
                                        .read(tasksProvider.notifier)
                                        .deleteTask(task),
                                  ),
                                ),
                            ],
                          );
                        },
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Nova.s16, Nova.s12, Nova.s16, Nova.s8),
      child: Row(
        children: [
          const Expanded(
            child: NovaWordmark(
              title: 'Tasks',
              subtitle: 'Your AI productivity workspace',
            ),
          ),
          NovaIconButton(
            icon: Icons.auto_awesome_rounded,
            tooltip: 'Plan with AI',
            tint: Nova.violet,
            onTap: _showAiDialog,
          ),
          const SizedBox(width: Nova.s8),
          NovaIconButton(
            icon: Icons.logout_rounded,
            tooltip: 'Log out',
            onTap: _logout,
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(int total, int pending) {
    final allDone = pending == 0 && total > 0;
    return NovaCard(
      radius: Nova.rXl,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Today's focus", style: Nova.h1),
                const SizedBox(height: Nova.s8),
                Text(
                  allDone
                      ? 'Everything is done. Nice work.'
                      : 'Break big goals into steps and finish them.',
                  style: Nova.bodySecondary,
                ),
                const SizedBox(height: Nova.s16),
                GestureDetector(
                  onTap: _showAiDialog,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Nova.violet.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(Nova.rSm),
                      border: Border.all(
                        color: Nova.violet.withValues(alpha: 0.32),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome_rounded,
                          color: Nova.violet,
                          size: 17,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Plan with AI',
                          style: TextStyle(
                            color: Nova.violet,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Nova.s16),
          const NovaLogo(size: 76),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int total, int done, int pending) {
    return Row(
      children: [
        _StatTile(label: 'Total', value: '$total', color: Nova.violet),
        const SizedBox(width: Nova.s12),
        _StatTile(label: 'Done', value: '$done', color: Nova.success),
        const SizedBox(width: Nova.s12),
        _StatTile(label: 'Pending', value: '$pending', color: Nova.blue),
      ],
    );
  }

  Widget _buildAddTaskBox() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 8, 8),
      decoration: BoxDecoration(
        color: Nova.surface,
        borderRadius: BorderRadius.circular(Nova.rLg),
        border: Border.all(color: Nova.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.add_task_rounded, color: Nova.textMuted, size: 22),
          const SizedBox(width: Nova.s12),
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _addTask(),
              style: Nova.body,
              cursorColor: Nova.violet,
              decoration: const InputDecoration(
                hintText: 'Add a new task...',
                hintStyle: TextStyle(color: Nova.textMuted, fontSize: 15),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: Nova.s8),
          GestureDetector(
            onTap: _addTask,
            child: Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Nova.rSm),
                gradient: Nova.brandGradient,
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Nova.surface,
          borderRadius: BorderRadius.circular(Nova.rMd),
          border: Border.all(color: Nova.border),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(label, style: Nova.label),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _TaskCard({
    required this.task,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(task.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(top: Nova.s12),
        decoration: BoxDecoration(
          color: Nova.danger.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(Nova.rMd),
          border: Border.all(color: Nova.danger.withValues(alpha: 0.28)),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete_outline_rounded,
          color: Nova.danger,
          size: 24,
        ),
      ),
      onDismissed: (_) => onDelete(),
      child: Padding(
        padding: const EdgeInsets.only(top: Nova.s12),
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(Nova.s16),
            decoration: BoxDecoration(
              color: Nova.surface,
              borderRadius: BorderRadius.circular(Nova.rMd),
              border: Border.all(
                color: task.done
                    ? Nova.success.withValues(alpha: 0.35)
                    : Nova.border,
              ),
            ),
            child: Row(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    task.done
                        ? Icons.check_circle_rounded
                        : Icons.circle_outlined,
                    key: ValueKey(task.done),
                    color: task.done ? Nova.success : Nova.textMuted,
                    size: 25,
                  ),
                ),
                const SizedBox(width: Nova.s12),
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      color: task.done ? Nova.textMuted : Nova.textPrimary,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                      decoration: task.done ? TextDecoration.lineThrough : null,
                      decorationColor: Nova.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          const NovaLogo(size: 84, glow: true),
          const SizedBox(height: Nova.s24),
          Text('No tasks yet', style: Nova.h1),
          const SizedBox(height: Nova.s8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Add your first task, or use Plan with AI to break a goal into steps.',
              textAlign: TextAlign.center,
              style: Nova.bodySecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 32,
        width: 32,
        child: CircularProgressIndicator(color: Nova.violet, strokeWidth: 2.6),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, color: Nova.textMuted, size: 54),
            const SizedBox(height: Nova.s16),
            Text('Could not load tasks', style: Nova.h2),
            const SizedBox(height: Nova.s8),
            const Text(
              'Check your connection and try again.',
              textAlign: TextAlign.center,
              style: Nova.bodySecondary,
            ),
            const SizedBox(height: Nova.s24),
            SizedBox(
              width: 160,
              child: NovaPrimaryButton(
                label: 'Try again',
                icon: Icons.refresh_rounded,
                onTap: onRetry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
