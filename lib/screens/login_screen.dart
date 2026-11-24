import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/nova_background.dart';
import '../core/widgets/nova_living_core.dart';
import '../core/widgets/nova_ui.dart';
import 'main_nav_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  String _error = '';

  late final AnimationController _animationController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Enter your email and password to continue.');
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
    });

    final success = await _authService.login(email, password);
    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const MainNavScreen(),
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) =>
                  FadeTransition(opacity: animation, child: child),
        ),
      );
    } else {
      setState(() {
        _loading = false;
        _error = _authService.lastError ??
            "That didn't work. Check your email and password.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const NovaBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: Nova.s24),
                child: FadeTransition(
                  opacity: _fade,
                  child: SlideTransition(
                    position: _slide,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 110,
                          width: 110,
                          child: NovaLivingCore(size: 110),
                        ),
                        const SizedBox(height: Nova.s24),
                        Text(
                          'NovaMind',
                          style: Nova.display.copyWith(fontSize: 34),
                        ),
                        const SizedBox(height: Nova.s8),
                        const Text(
                          'Think clearer. Learn faster.',
                          style: Nova.bodySecondary,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: Nova.s32),
                        _buildCard(),
                        const SizedBox(height: Nova.s24),
                        _buildSignupLink(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return NovaCard(
      radius: Nova.rXl,
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome back', style: Nova.h1),
          const SizedBox(height: Nova.s4),
          const Text(
            'Sign in to continue to your workspace.',
            style: Nova.bodySecondary,
          ),
          const SizedBox(height: Nova.s24),
          NovaTextField(
            controller: _emailController,
            hint: 'Email address',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: Nova.s12),
          NovaTextField(
            controller: _passwordController,
            hint: 'Password',
            icon: Icons.lock_outline_rounded,
            obscure: _obscurePassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _login(),
            suffix: IconButton(
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Nova.textMuted,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text(
                'Forgot password?',
                style: TextStyle(color: Nova.blue, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: _error.isEmpty
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.only(bottom: Nova.s16),
                    child: NovaNotice(_error),
                  ),
          ),
          NovaPrimaryButton(
            label: 'Sign in',
            loading: _loading,
            onTap: _loading ? null : _login,
          ),
          const SizedBox(height: Nova.s16),
          const Row(
            children: [
              Expanded(child: Divider(color: Colors.white12)),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'OR',
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(child: Divider(color: Colors.white12)),
            ],
          ),
          const SizedBox(height: Nova.s16),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const MainNavScreen()),
              );
            },
            child: Container(
              height: 48,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: const Color(0xFF13172E),
                border: Border.all(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.35),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bolt_rounded, color: Color(0xFF22D3EE), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Instant Demo (Explore as Guest)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignupLink() {
    return TextButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SignupScreen()),
      ),
      child: RichText(
        text: const TextSpan(
          style: TextStyle(fontSize: 15, color: Nova.textSecondary),
          children: [
            TextSpan(text: 'New to NovaMind?  '),
            TextSpan(
              text: 'Create account',
              style: TextStyle(color: Nova.blue, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
