import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'alert_screen.dart';


class _T {
  static const bg = Color(0xFF080A0F);
  static const surface = Color(0xFF10141E);
  static const border = Color(0xFF1E2535);
  static const accent = Color(0xFF00F5A0);
  static const danger = Color(0xFFFF3B5C);
  static const textPrimary = Color(0xFFE8EDF5);
  static const textMuted = Color(0xFF4E5B72);
  static const textSubtle = Color(0xFF8896AA);
}


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  bool _isMonitoring = false;
  int _seconds = 0;
  Timer? _timer;

  late AnimationController _pulseCtrl;
  late AnimationController _ringCtrl;
  late AnimationController _scanCtrl;
  late AnimationController _waveCtrl;
  late Animation<double> _pulseAnim;
  late Animation<double> _ringAnim;
  late Animation<double> _scanAnim;

  final List<double> _waveData = List.generate(30, (_) => 0.1);
  Timer? _waveTimer;

  final List<_LogEntry> _log = [];
  int _alertCount = 0;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _waveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _pulseAnim = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _ringAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ringCtrl, curve: Curves.easeOut),
    );

    _scanAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanCtrl, curve: Curves.linear),
    );
  }

  void _toggleMonitoring() {
    HapticFeedback.mediumImpact();
    setState(() => _isMonitoring = !_isMonitoring);

    if (_isMonitoring) {
      _startMonitoring();
    } else {
      _stopMonitoring();
    }
  }

  void _startMonitoring() {
    _seconds = 0;
    _log.clear();
    _alertCount = 0;

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });

    _ringCtrl.repeat();
    _scanCtrl.repeat();
    _startWave();

    _addLog('System initialised', isAlert: false);
    _addLog('Microphone active', isAlert: false);

    // Demo: trigger alert after 5 s
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _isMonitoring) {
        HapticFeedback.heavyImpact();
        _addLog('⚠  Emergency keyword detected!', isAlert: true);
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, a, b) => const AlertScreen(),
            transitionsBuilder: (_, a, b, child) =>
                FadeTransition(opacity: a, child: child),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        );
      }
    });
  }

  void _stopMonitoring() {
    _timer?.cancel();
    _waveTimer?.cancel();
    _ringCtrl.stop();
    _ringCtrl.reset();
    _scanCtrl.stop();
    _scanCtrl.reset();
    _addLog('Monitoring stopped', isAlert: false);
    setState(() => _waveData.fillRange(0, _waveData.length, 0.1));
  }

  void _startWave() {
    final rng = Random();
    _waveTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (!mounted) return;
      setState(() {
        _waveData.removeAt(0);
        _waveData.add(_isMonitoring ? rng.nextDouble() : 0.1);
      });
    });
  }

  void _addLog(String msg, {required bool isAlert}) {
    setState(() {
      if (isAlert) _alertCount++;
      _log.insert(0, _LogEntry(msg, isAlert, _formatTime(_seconds)));
      if (_log.length > 6) _log.removeLast();
    });
  }

  String _formatTime(int sec) {
    final m = (sec ~/ 60).toString().padLeft(2, '0');
    final s = (sec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _waveTimer?.cancel();
    _pulseCtrl.dispose();
    _ringCtrl.dispose();
    _scanCtrl.dispose();
    _waveCtrl.dispose();
    super.dispose();
  }

  
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _T.bg,
        body: SafeArea(
          child: Column(
            children: [
              _buildTopBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      _buildOrb(),
                      const SizedBox(height: 28),
                      _buildWaveform(),
                      const SizedBox(height: 20),
                      _buildStatRow(),
                      const SizedBox(height: 20),
                      _buildLog(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: _T.border, width: 1)),
      ),
      child: Row(
        children: [
          // Logo mark
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _T.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _T.border),
            ),
            child: const Icon(Icons.shield_outlined,
                color: _T.accent, size: 18),
          ),
          const SizedBox(width: 12),
          const Text(
            'SENTINEL',
            style: TextStyle(
              color: _T.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 3,
            ),
          ),
          const Spacer(),
          // Alert badge
          if (_alertCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _T.danger.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _T.danger.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: _T.danger, size: 13),
                  const SizedBox(width: 5),
                  Text(
                    '$_alertCount Alert${_alertCount > 1 ? 's' : ''}',
                    style: const TextStyle(
                      color: _T.danger,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune_rounded,
                color: _T.textSubtle, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildOrb() {
    final activeColor = _isMonitoring ? _T.accent : _T.textMuted;
    final glowColor = _isMonitoring ? _T.accent : Colors.transparent;

    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Expanding ring animation
          if (_isMonitoring)
            AnimatedBuilder(
              animation: _ringAnim,
              builder: (_, __) {
                final v = _ringAnim.value;
                return Container(
                  width: 200 + v * 60,
                  height: 200 + v * 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _T.accent.withOpacity((1 - v) * 0.35),
                      width: 1.5,
                    ),
                  ),
                );
              },
            ),

          if (_isMonitoring)
            AnimatedBuilder(
              animation: _ringAnim,
              builder: (_, __) {
                final v = (_ringAnim.value + 0.5) % 1.0;
                return Container(
                  width: 200 + v * 60,
                  height: 200 + v * 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _T.accent.withOpacity((1 - v) * 0.2),
                      width: 1,
                    ),
                  ),
                );
              },
            ),

          Container(
            width: 210,
            height: 210,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _T.border, width: 1.5),
            ),
          ),

          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: glowColor.withOpacity(0.25),
                  blurRadius: 60,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),

          AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, child) {
              return Transform.scale(
                scale: _isMonitoring ? _pulseAnim.value : 1.0,
                child: child,
              );
            },
            child: GestureDetector(
              onTap: _toggleMonitoring,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _T.surface,
                  border: Border.all(
                    color: activeColor.withOpacity(0.6),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: glowColor.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        _isMonitoring
                            ? Icons.mic_rounded
                            : Icons.mic_off_rounded,
                        key: ValueKey(_isMonitoring),
                        color: activeColor,
                        size: 36,
                      ),
                    ),
                    const SizedBox(height: 10),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _isMonitoring ? 'ACTIVE' : 'STANDBY',
                        key: ValueKey(_isMonitoring),
                        style: TextStyle(
                          color: activeColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isMonitoring
                          ? _formatTime(_seconds)
                          : '00:00',
                      style: const TextStyle(
                        color: _T.textSubtle,
                        fontSize: 13,
                        fontFamily: 'monospace',
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          if (_isMonitoring)
            AnimatedBuilder(
              animation: _scanAnim,
              builder: (_, __) {
                return Transform.rotate(
                  angle: _scanAnim.value * 2 * pi,
                  child: CustomPaint(
                    size: const Size(210, 210),
                    painter: _ScanPainter(),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildWaveform() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _T.border),
      ),
      child: Row(
        children: [
          Icon(
            Icons.graphic_eq_rounded,
            color: _isMonitoring ? _T.accent : _T.textMuted,
            size: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRect(
              child: CustomPaint(
                painter: _WaveformPainter(
                  data: _waveData,
                  color: _isMonitoring ? _T.accent : _T.textMuted,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _isMonitoring ? 'LIVE' : '  —  ',
            style: TextStyle(
              color: _isMonitoring ? _T.accent : _T.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow() {
    return Row(
      children: [
        _StatCard(
          label: 'MICROPHONE',
          value: _isMonitoring ? 'ACTIVE' : 'OFF',
          icon: Icons.mic_rounded,
          active: _isMonitoring,
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: 'AI ENGINE',
          value: _isMonitoring ? 'RUNNING' : 'IDLE',
          icon: Icons.memory_rounded,
          active: _isMonitoring,
        ),
        const SizedBox(width: 12),
        _StatCard(
          label: 'ALERTS',
          value: _alertCount > 0 ? '$_alertCount' : '—',
          icon: Icons.notifications_rounded,
          active: _alertCount > 0,
          danger: _alertCount > 0,
        ),
      ],
    );
  }

  Widget _buildLog() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'ACTIVITY LOG',
              style: TextStyle(
                color: _T.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            const Spacer(),
            if (_log.isNotEmpty)
              GestureDetector(
                onTap: () => setState(() {
                  _log.clear();
                  _alertCount = 0;
                }),
                child: const Text(
                  'CLEAR',
                  style: TextStyle(
                    color: _T.textMuted,
                    fontSize: 10,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: _T.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _T.border),
          ),
          child: _log.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No events yet. Start monitoring to begin.',
                      style: TextStyle(
                          color: _T.textMuted, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _log.length,
                  separatorBuilder: (_, __) => const Divider(
                    height: 1,
                    color: _T.border,
                  ),
                  itemBuilder: (_, i) {
                    final e = _log[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: e.isAlert
                                  ? _T.danger
                                  : _T.accent,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              e.message,
                              style: TextStyle(
                                color: e.isAlert
                                    ? _T.danger
                                    : _T.textSubtle,
                                fontSize: 12.5,
                                fontWeight: e.isAlert
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                          Text(
                            e.time,
                            style: const TextStyle(
                              color: _T.textMuted,
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
      decoration: const BoxDecoration(
        color: _T.surface,
        border: Border(top: BorderSide(color: _T.border, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavItem(icon: Icons.home_rounded, label: 'Home', active: true),
          _NavItem(
              icon: Icons.location_on_rounded, label: 'Location'),
          _NavItem(icon: Icons.history_rounded, label: 'History'),
          _NavItem(icon: Icons.settings_rounded, label: 'Settings'),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool active;
  final bool danger;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    this.active = false,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? _T.danger : (active ? _T.accent : _T.textMuted);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: _T.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: active ? color.withOpacity(0.3) : _T.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(
                color: _T.textMuted,
                fontSize: 9,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;

  const _NavItem({
    required this.icon,
    required this.label,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: active ? _T.accent : _T.textMuted,
          size: 22,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: active ? _T.accent : _T.textMuted,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}


class _LogEntry {
  final String message;
  final bool isAlert;
  final String time;
  _LogEntry(this.message, this.isAlert, this.time);
}


class _WaveformPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  _WaveformPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final barW = (size.width / data.length) * 0.6;
    final gap = (size.width / data.length) * 0.4;
    final centerY = size.height / 2;

    for (int i = 0; i < data.length; i++) {
      final x = i * (barW + gap) + barW / 2;
      final h = data[i] * size.height * 0.9;
      canvas.drawLine(
        Offset(x, centerY - h / 2),
        Offset(x, centerY + h / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WaveformPainter old) => old.data != data;
}

class _ScanPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.transparent,
          _T.accent.withOpacity(0.05),
          _T.accent.withOpacity(0.25),
        ],
        stops: const [0.7, 0.9, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, paint);

    final linePaint = Paint()
      ..color = _T.accent.withOpacity(0.6)
      ..strokeWidth = 1.5;

    canvas.drawLine(
      center,
      Offset(center.dx, center.dy - radius),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(_ScanPainter old) => false;
}
