import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../providers/profile_provider.dart';
import '../providers/gamification_provider.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/nova_background.dart';
import '../core/widgets/nova_logo.dart';
import '../core/widgets/nova_ui.dart';
import 'login_screen.dart';
import 'widgets/flex_card_sheet.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  static const _storage = FlutterSecureStorage();

  late final AnimationController _animController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  bool _reminders = false;

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
    _loadPrefs();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    final v = await _storage.read(key: 'pref_daily_reminders');
    if (!mounted) return;
    setState(() => _reminders = v == 'true');
  }

  Future<void> _toggleReminders(bool value) async {
    setState(() => _reminders = value);
    await _storage.write(key: 'pref_daily_reminders', value: value.toString());
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

  void _snack(String message, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              error
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_outline_rounded,
              color: error ? Nova.danger : Nova.success,
              size: 21,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message, style: Nova.body)),
          ],
        ),
      ),
    );
  }

  Future<void> _openEditProfile(String name, String email) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(initialName: name, initialEmail: email),
    );
    if (saved == true && mounted) _snack('Profile updated');
  }

  Future<void> _openChangePassword() async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ChangePasswordSheet(),
    );
    if (saved == true && mounted) _snack('Password updated');
  }

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'N';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  String _memberSince(String raw) {
    if (raw.isEmpty) return '';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return '';
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);
    final gamification = ref.watch(gamificationProvider);

    final name = profileAsync.maybeWhen(
      data: (p) => p.name.isNotEmpty ? p.name : 'NovaMind User',
      orElse: () => 'NovaMind User',
    );
    final email = profileAsync.maybeWhen(
      data: (p) => p.email,
      orElse: () => '',
    );

    return Scaffold(
      body: Stack(
        children: [
          const NovaBackground(),
          SafeArea(
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    Nova.s16,
                    Nova.s12,
                    Nova.s16,
                    94,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: Nova.s24),
                      profileAsync.when(
                        loading: () => const _HeroSkeleton(),
                        error: (error, stack) => _buildHero(
                          name: 'NovaMind User',
                          email: 'Could not load your profile',
                          joined: '',
                        ),
                        data: (p) => _buildHero(
                          name: name,
                          email: p.email,
                          joined: _memberSince(p.createdAt),
                        ),
                      ),
                      const SizedBox(height: Nova.s20),
                      _buildGamificationCard(gamification),
                      const SizedBox(height: Nova.s12),
                      _buildShareFlexCardButton(name, gamification),
                      const SizedBox(height: Nova.s24),
                      _buildBadgesSection(gamification),
                      const SizedBox(height: Nova.s24),
                      const NovaSectionTitle('Account'),
                      const SizedBox(height: Nova.s12),
                      _SettingsCard(
                        children: [
                          _ActionRow(
                            icon: Icons.edit_outlined,
                            color: Nova.violet,
                            title: 'Edit profile',
                            subtitle: 'Update your name or email',
                            onTap: () => _openEditProfile(
                              name == 'NovaMind User' ? '' : name,
                              email,
                            ),
                          ),
                          _InfoRow(
                            icon: Icons.mail_outline_rounded,
                            color: Nova.blue,
                            title: 'Email',
                            value: email.isNotEmpty ? email : '—',
                          ),
                        ],
                      ),
                      const SizedBox(height: Nova.s24),
                      const NovaSectionTitle('Security'),
                      const SizedBox(height: Nova.s12),
                      _SettingsCard(
                        children: [
                          _ActionRow(
                            icon: Icons.lock_outline_rounded,
                            color: Nova.success,
                            title: 'Change password',
                            subtitle: 'Update your account password',
                            onTap: _openChangePassword,
                          ),
                          _InfoRow(
                            icon: Icons.verified_user_outlined,
                            color: Nova.success,
                            title: 'Status',
                            value: profileAsync.hasValue
                                ? 'Signed in securely'
                                : 'Checking...',
                          ),
                        ],
                      ),
                      const SizedBox(height: Nova.s24),
                      const NovaSectionTitle('Preferences'),
                      const SizedBox(height: Nova.s12),
                      _SettingsCard(
                        children: [
                          _SwitchRow(
                            icon: Icons.notifications_none_rounded,
                            color: Nova.violet,
                            title: 'Daily reminders',
                            subtitle: 'Save a nudge to check your tasks',
                            value: _reminders,
                            onChanged: _toggleReminders,
                          ),
                          _InfoRow(
                            icon: Icons.dark_mode_outlined,
                            color: Nova.blue,
                            title: 'Appearance',
                            value: 'Dark',
                          ),
                        ],
                      ),
                      const SizedBox(height: Nova.s24),
                      const NovaSectionTitle('About'),
                      const SizedBox(height: Nova.s12),
                      _SettingsCard(
                        children: [
                          _ActionRow(
                            icon: Icons.info_outline_rounded,
                            color: Nova.violet,
                            title: 'About NovaMind',
                            subtitle: 'Version 1.0.0',
                            onTap: _showAboutSheet,
                          ),
                        ],
                      ),
                      const SizedBox(height: Nova.s24),
                      NovaSecondaryButton(
                        label: 'Log out',
                        icon: Icons.logout_rounded,
                        tint: Nova.danger,
                        onTap: _logout,
                      ),
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

  Widget _buildHeader() {
    return Row(
      children: [
        if (Navigator.canPop(context)) ...[
          NovaIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            tooltip: 'Back',
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: Nova.s12),
        ],
        Text('Profile & Cognitive Stats', style: Nova.h1),
      ],
    );
  }

  Widget _buildHero({
    required String name,
    required String email,
    required String joined,
  }) {
    return NovaCard(
      radius: Nova.rXl,
      child: Column(
        children: [
          Container(
            height: 88,
            width: 88,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: Nova.brandGradient,
              boxShadow: Nova.accentGlow,
            ),
            child: Text(
              _initials(name),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: Nova.s16),
          Text(name, style: Nova.h1, textAlign: TextAlign.center),
          if (email.isNotEmpty) ...[
            const SizedBox(height: Nova.s4),
            Text(email, style: Nova.bodySecondary, textAlign: TextAlign.center),
          ],
          if (joined.isNotEmpty) ...[
            const SizedBox(height: Nova.s12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Nova.violet.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(Nova.rSm),
              ),
              child: Text(
                'Member since $joined',
                style: const TextStyle(
                  color: Nova.violet,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGamificationCard(GamificationState g) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF101626),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.28),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Level ${g.level} • ${g.rankTitle}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${g.currentLevelXp} / ${g.nextLevelXp} XP to Level ${g.level + 1}',
                    style: const TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF4F6FE6)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '${g.xp} XP',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: g.levelProgress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetric('🔥 ${g.streakDays} Days', 'Daily Streak'),
              Container(width: 1, height: 26, color: Colors.white12),
              _buildMetric('⏳ ${g.focusMinutesTotal}m', 'Deep Focus'),
              Container(width: 1, height: 26, color: Colors.white12),
              _buildMetric('🏆 ${g.unlockedBadges.length}/6', 'Badges Won'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildShareFlexCardButton(String name, GamificationState g) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        FlexCardSheet.show(context, name: name, gamification: g);
      },
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF2563EB)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
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
              'Share Cognitive Flex Card (Stories/TikTok)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadgesSection(GamificationState g) {
    final badges = [
      {'id': 'night_owl', 'title': 'Night Owl', 'icon': '🦉'},
      {'id': 'speed_demon', 'title': 'Speed Demon', 'icon': '⚡'},
      {'id': 'deep_diver', 'title': 'Deep Diver', 'icon': '🚀'},
      {'id': 'perfectionist', 'title': 'Perfectionist', 'icon': '🎯'},
      {'id': 'streak_master', 'title': 'Streak Master', 'icon': '🔥'},
      {'id': 'polymath', 'title': 'Polymath', 'icon': '🧠'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const NovaSectionTitle('Holographic Badges'),
        const SizedBox(height: Nova.s12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 0.95,
          ),
          itemCount: badges.length,
          itemBuilder: (context, index) {
            final b = badges[index];
            final isUnlocked = g.unlockedBadges.contains(b['id']);

            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? const Color(0xFF141A2A)
                    : const Color(0xFF0F1524).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isUnlocked
                      ? const Color(0xFF8B5CF6).withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.05),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    b['icon']!,
                    style: const TextStyle(fontSize: 26),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    b['title']!,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color:
                          isUnlocked ? Colors.white : const Color(0xFF64748B),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isUnlocked ? 'Unlocked' : 'Locked',
                    style: TextStyle(
                      color: isUnlocked
                          ? const Color(0xFF22C55E)
                          : const Color(0xFF475569),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _showAboutSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 30),
        decoration: const BoxDecoration(
          color: Nova.surfaceHigh,
          borderRadius: BorderRadius.vertical(top: Radius.circular(Nova.rXl)),
          border: Border(top: BorderSide(color: Nova.borderStrong)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const NovaLogo(size: 84, glow: true),
            const SizedBox(height: Nova.s16),
            Text('NovaMind', style: Nova.h1),
            const SizedBox(height: Nova.s8),
            const Text(
              'A premium AI learning and productivity assistant, powered by Google Gemini and Supabase.',
              textAlign: TextAlign.center,
              style: Nova.bodySecondary,
            ),
            const SizedBox(height: Nova.s24),
            NovaPrimaryButton(
              label: 'Close',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Edit profile sheet
// ---------------------------------------------------------------------------
class _EditProfileSheet extends ConsumerStatefulWidget {
  final String initialName;
  final String initialEmail;

  const _EditProfileSheet({
    required this.initialName,
    required this.initialEmail,
  });

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late final TextEditingController _name = TextEditingController(
    text: widget.initialName,
  );
  late final TextEditingController _email = TextEditingController(
    text: widget.initialEmail,
  );

  final _service = ProfileService();
  bool _loading = false;
  String _error = '';

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final email = _email.text.trim();

    if (name.isEmpty && email.isEmpty) {
      setState(() => _error = 'Enter a name or email to save.');
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      await _service.updateProfile(name: name, email: email);
      ref.invalidate(profileProvider);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: 'Edit profile',
      children: [
        NovaTextField(
          controller: _name,
          hint: 'Full name',
          icon: Icons.person_outline_rounded,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: Nova.s12),
        NovaTextField(
          controller: _email,
          hint: 'Email address',
          icon: Icons.mail_outline_rounded,
          keyboardType: TextInputType.emailAddress,
        ),
        if (_error.isNotEmpty) ...[
          const SizedBox(height: Nova.s16),
          NovaNotice(_error),
        ],
        const SizedBox(height: Nova.s20),
        NovaPrimaryButton(
          label: 'Save changes',
          loading: _loading,
          onTap: _loading ? null : _save,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Change password sheet
// ---------------------------------------------------------------------------
class _ChangePasswordSheet extends ConsumerStatefulWidget {
  const _ChangePasswordSheet();

  @override
  ConsumerState<_ChangePasswordSheet> createState() =>
      _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends ConsumerState<_ChangePasswordSheet> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();

  final _service = ProfileService();
  bool _loading = false;
  String _error = '';

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final current = _current.text;
    final next = _next.text;
    final confirm = _confirm.text;

    if (current.isEmpty || next.isEmpty) {
      setState(() => _error = 'Fill in both password fields.');
      return;
    }
    if (next.length < 6) {
      setState(() => _error = 'New password must be at least 6 characters.');
      return;
    }
    if (next != confirm) {
      setState(() => _error = 'New passwords do not match.');
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      await _service.changePassword(
        currentPassword: current,
        newPassword: next,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SheetShell(
      title: 'Change password',
      children: [
        NovaTextField(
          controller: _current,
          hint: 'Current password',
          icon: Icons.lock_outline_rounded,
          obscure: true,
        ),
        const SizedBox(height: Nova.s12),
        NovaTextField(
          controller: _next,
          hint: 'New password',
          icon: Icons.lock_reset_rounded,
          obscure: true,
        ),
        const SizedBox(height: Nova.s12),
        NovaTextField(
          controller: _confirm,
          hint: 'Confirm new password',
          icon: Icons.check_circle_outline_rounded,
          obscure: true,
        ),
        if (_error.isNotEmpty) ...[
          const SizedBox(height: Nova.s16),
          NovaNotice(_error),
        ],
        const SizedBox(height: Nova.s20),
        NovaPrimaryButton(
          label: 'Change password',
          loading: _loading,
          onTap: _loading ? null : _save,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Sheet shell
// ---------------------------------------------------------------------------
class _SheetShell extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SheetShell({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
        decoration: const BoxDecoration(
          color: Nova.surfaceHigh,
          borderRadius: BorderRadius.vertical(top: Radius.circular(Nova.rXl)),
          border: Border(top: BorderSide(color: Nova.borderStrong)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: Nova.h2)),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Nova.textMuted),
                ),
              ],
            ),
            const SizedBox(height: Nova.s16),
            ...children,
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Settings building blocks
// ---------------------------------------------------------------------------
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Nova.surface,
        borderRadius: BorderRadius.circular(Nova.rLg),
        border: Border.all(color: Nova.border),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              const Divider(
                height: 1,
                color: Nova.border,
                indent: 16,
                endIndent: 16,
              ),
          ],
        ],
      ),
    );
  }
}

class _RowShell extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _RowShell({
    required this.icon,
    required this.color,
    required this.title,
    required this.trailing,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.all(Nova.s16),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Nova.rSm),
              color: color.withValues(alpha: 0.14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: Nova.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Nova.title.copyWith(fontSize: 15.5)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: Nova.label),
                ],
              ],
            ),
          ),
          const SizedBox(width: Nova.s12),
          trailing,
        ],
      ),
    );
    if (onTap == null) return row;
    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: row),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _RowShell(
      icon: icon,
      color: color,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        color: Nova.textMuted,
        size: 15,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return _RowShell(
      icon: icon,
      color: color,
      title: title,
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 150),
        child: Text(
          value,
          textAlign: TextAlign.right,
          overflow: TextOverflow.ellipsis,
          style: Nova.bodySecondary,
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _RowShell(
      icon: icon,
      color: color,
      title: title,
      subtitle: subtitle,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.white,
        activeTrackColor: Nova.violet,
        inactiveThumbColor: Nova.textSecondary,
        inactiveTrackColor: Nova.surfaceHigh,
      ),
    );
  }
}

class _HeroSkeleton extends StatelessWidget {
  const _HeroSkeleton();

  @override
  Widget build(BuildContext context) {
    return const NovaCard(
      radius: Nova.rXl,
      child: SizedBox(
        height: 150,
        child: Center(
          child: SizedBox(
            height: 28,
            width: 28,
            child: CircularProgressIndicator(
              color: Nova.violet,
              strokeWidth: 2.4,
            ),
          ),
        ),
      ),
    );
  }
}
