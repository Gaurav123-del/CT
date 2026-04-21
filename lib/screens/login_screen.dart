import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/common_widgets.dart';
import 'setup_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SetupScreen()),
    );
  }

  void _onGoogleLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const SetupScreen()),
    );
  }

  void _onSignUp() {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const SignUpScreen(),
        transitionsBuilder: (_, animation, ___, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
              .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),

                  // ── Logo & Title ──────────────────────────────────────
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.surfaceLight,
                            border: Border.all(color: AppTheme.green.withValues(alpha: 0.4), width: 2),
                            boxShadow: [
                              BoxShadow(color: AppTheme.green.withValues(alpha: 0.2), blurRadius: 24, spreadRadius: 2),
                            ],
                          ),
                          child: const Icon(Icons.shield_rounded, color: AppTheme.green, size: 38),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Self Live\nMonitoring',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, height: 1.2, letterSpacing: -0.5),
                        ),
                        const SizedBox(height: 8),
                        const Text('Your personal safety guardian', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ── Form heading ──────────────────────────────────────
                  const Text('Welcome back', style: AppTheme.headingMedium),
                  const SizedBox(height: 6),
                  const Text('Sign in to continue', style: AppTheme.bodyText),
                  const SizedBox(height: 24),

                  // ── Email ─────────────────────────────────────────────
                  AppTextField(
                    hint: 'Email',
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.person_outline_rounded, color: AppTheme.textHint, size: 20),
                  ),
                  const SizedBox(height: 14),

                  // ── Password ──────────────────────────────────────────
                  AppTextField(
                    hint: 'Enter your password',
                    label: 'Password',
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppTheme.textHint, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppTheme.textHint, size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),

                  // ── Forgot password ───────────────────────────────────
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8)),
                      child: const Text('Forgot password?', style: TextStyle(color: AppTheme.green, fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Login button ──────────────────────────────────────
                  PrimaryButton(label: 'Login', onPressed: _onLogin, icon: Icons.arrow_forward_rounded),

                  const SizedBox(height: 16),

                  // ── OR divider ────────────────────────────────────────
                  const Row(
                    children: [
                      Expanded(child: Divider(color: AppTheme.borderColor, thickness: 1)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: Text('or', style: TextStyle(color: AppTheme.textHint, fontSize: 12)),
                      ),
                      Expanded(child: Divider(color: AppTheme.borderColor, thickness: 1)),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Google button — BELOW Login ───────────────────────
                  _GoogleSignInButton(onPressed: _onGoogleLogin),

                  const SizedBox(height: 24),

                  // ── Sign Up link ──────────────────────────────────────
                  Center(
                    child: GestureDetector(
                      onTap: _onSignUp,
                      child: RichText(
                        text: const TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                          children: [
                            TextSpan(text: 'Sign Up', style: TextStyle(color: AppTheme.green, fontWeight: FontWeight.w700, fontSize: 14)),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Google Sign-In Button ────────────────────────────────────────────────────

class _GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _GoogleSignInButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.borderColor, width: 1.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icons/google_logo.png', width: 22, height: 22),
            const SizedBox(width: 12),
            const Text(
              'Continue with Google',
              style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}