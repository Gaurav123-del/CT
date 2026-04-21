import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'setup_screen.dart';

class _T {
  static const bg = Color(0xFF080A0F);
  static const surface = Color(0xFF10141E);
  static const border = Color(0xFF1E2535);
  static const accent = Color(0xFF00F5A0);
  static const accentDim = Color(0xFF00B87A);
  static const textPrimary = Color(0xFFE8EDF5);
  static const textMuted = Color(0xFF4E5B72);
  static const textSubtle = Color(0xFF8896AA);
  // static const danger = Color(0xFFFF3B5C);
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  bool _passwordHidden = true;
  bool _isLoading = false;
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();

  late AnimationController _fadeCtrl;
  late AnimationController _gridCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _gridCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _gridCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    HapticFeedback.mediumImpact();
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, a, b) => const SetupScreen(),
        transitionsBuilder: (_, a, b, child) =>
            FadeTransition(opacity: a, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _T.bg,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            // Animated dot-grid background
            AnimatedBuilder(
              animation: _gridCtrl,
              builder: (_, __) => CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _GridPainter(_gridCtrl.value),
              ),
            ),

            // Top corner glow
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [_T.accent.withOpacity(0.08), Colors.transparent],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 48),
                      _buildHeader(),
                      const SizedBox(height: 48),
                      _buildForm(),
                      const SizedBox(height: 32),
                      _buildLoginButton(),
                      const SizedBox(height: 24),
                      _buildDivider(),
                      const SizedBox(height: 24),
                      _buildBiometric(),
                      const SizedBox(height: 40),
                      _buildSignUp(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Logo mark
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _T.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _T.border),
          ),
          child: const Icon(Icons.shield_outlined, color: _T.accent, size: 24),
        ),
        const SizedBox(height: 28),
        const Text(
          'Welcome back.',
          style: TextStyle(
            color: _T.textPrimary,
            fontSize: 34,
            fontWeight: FontWeight.w800,
            height: 1.1,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Sign in to your Sentinel account\nto continue monitoring.',
          style: TextStyle(color: _T.textSubtle, fontSize: 15, height: 1.6),
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        _SentinelField(
          controller: _emailCtrl,
          focusNode: _emailFocus,
          label: 'Email or Phone',
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
          onSubmitted: (_) => FocusScope.of(context).requestFocus(_passFocus),
        ),
        const SizedBox(height: 16),
        _SentinelField(
          controller: _passCtrl,
          focusNode: _passFocus,
          label: 'Password',
          icon: Icons.lock_outline_rounded,
          obscure: _passwordHidden,
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _passwordHidden = !_passwordHidden),
            child: Icon(
              _passwordHidden
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded,
              color: _T.textMuted,
              size: 18,
            ),
          ),
          onSubmitted: (_) => _handleLogin(),
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {},
            child: const Text(
              'Forgot password?',
              style: TextStyle(
                color: _T.accent,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _handleLogin,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: _isLoading ? _T.accentDim : _T.accent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _T.accent.withOpacity(0.25),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _isLoading
                ? const SizedBox(
                    key: ValueKey('loader'),
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.black,
                    ),
                  )
                : const Text(
                    key: ValueKey('label'),
                    'SIGN IN',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: _T.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OR',
            style: TextStyle(
              color: _T.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: _T.border)),
      ],
    );
  }

  // ── Biometric ────────────────────────────────
  Widget _buildBiometric() {
    return GestureDetector(
      onTap: () => HapticFeedback.lightImpact(),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _T.border),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.fingerprint_rounded, color: _T.textSubtle, size: 22),
            SizedBox(width: 10),
            Text(
              'Continue with Biometrics',
              style: TextStyle(
                color: _T.textSubtle,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUp() {
    return Center(
      child: RichText(
        text: TextSpan(
          text: "Don't have an account?  ",
          style: const TextStyle(color: _T.textMuted, fontSize: 14),
          children: [
            WidgetSpan(
              child: GestureDetector(
                onTap: () {},
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    color: _T.accent,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SentinelField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final IconData icon;
  final bool obscure;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final ValueChanged<String>? onSubmitted;

  const _SentinelField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.icon,
    this.obscure = false,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.onSubmitted,
  });

  @override
  State<_SentinelField> createState() => _SentinelFieldState();
}

class _SentinelFieldState extends State<_SentinelField> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      if (mounted) setState(() => _focused = widget.focusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _focused ? _T.accent.withOpacity(0.5) : _T.border,
          width: _focused ? 1.5 : 1,
        ),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: _T.accent.withOpacity(0.08),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        obscureText: widget.obscure,
        keyboardType: widget.keyboardType,
        style: const TextStyle(color: _T.textPrimary, fontSize: 15),
        onSubmitted: widget.onSubmitted,
        decoration: InputDecoration(
          prefixIcon: Icon(
            widget.icon,
            color: _focused ? _T.accent : _T.textMuted,
            size: 18,
          ),
          suffixIcon: widget.suffixIcon != null
              ? Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: widget.suffixIcon,
                )
              : null,
          hintText: widget.label,
          hintStyle: const TextStyle(color: _T.textMuted, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final double progress;
  _GridPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF1E2535).withOpacity(0.5);
    const spacing = 36.0;
    const dotR = 1.0;

    final cols = (size.width / spacing).ceil() + 1;
    final rows = (size.height / spacing).ceil() + 1;
    final shift = (progress * spacing * 2) % spacing;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final x = c * spacing - shift;
        final y = r * spacing - shift;
        // Subtle fade toward center
        final dx = (x - size.width / 2).abs() / (size.width / 2);
        final dy = (y - size.height / 2).abs() / (size.height / 2);
        final alpha = (0.3 - min(dx, dy) * 0.25).clamp(0.0, 0.3);
        canvas.drawCircle(
          Offset(x, y),
          dotR,
          paint..color = const Color(0xFF1E2535).withOpacity(alpha),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.progress != progress;
}
