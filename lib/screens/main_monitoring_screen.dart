

import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:sosapp/services/notification_service.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:torch_light/torch_light.dart';
import 'package:vibration/vibration.dart';
import 'safety_timer_screen.dart';

import '../models/emergency_contact.dart';
import '../theme.dart';
import 'alert_screen.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:sensors_plus/sensors_plus.dart';

// 🔥 ADD THIS AT TOP
Timer? _debounceTimer;
DateTime? _lastEmergencyTime;
const baseUrl = "http://5.223.69.200:8000";

class MainMonitoringScreen extends StatefulWidget {
  final List<EmergencyContact> contacts;

  const MainMonitoringScreen({super.key, required this.contacts});

  @override
  State<MainMonitoringScreen> createState() => _MainMonitoringScreenState();
}

class _MainMonitoringScreenState extends State<MainMonitoringScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isMonitoring = false;
  bool _isEmergencyFlowRunning = false;
  bool _cancelWindowActive = false;

  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnim;

  final stt.SpeechToText _speech = stt.SpeechToText();
  final AudioPlayer _audioPlayer = AudioPlayer();

  Timer? _cancelTimer;
  StreamSubscription? _shakeSubscription;
  Timer? _flashTimer;

  StreamSubscription<Position>? _positionSubscription;

  String _lastHeardText = "No voice detected yet";
  double _lastConfidence = 0.0;

  Position? _currentPosition;

  final List<String> _distressKeywords = const [
    "help",
    "bachao",
    "save me",
    "emergency",
    "danger",
    "chor",
    "attack",
    "please help",
    "mujhe bachao",
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // 🔥 PRELOAD EVERYTHING (NO LAG)
    _prepareServices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pulseController.dispose();
    _waveController.dispose();
    _cancelTimer?.cancel();
    _flashTimer?.cancel();
    _positionSubscription?.cancel();
    _speech.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  List<String> getContactNumbers() {
    return widget.contacts.map((c) => _formatPhone(c.phone)).toList();
  }

  String _formatPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'\s+'), '');
    if (cleaned.startsWith('+')) return cleaned;
    if (cleaned.startsWith('0')) return "+91${cleaned.substring(1)}";
    if (cleaned.length == 10) return "+91$cleaned";
    return cleaned;
  }

  Future<void> _toggleMonitoring() async {
    if (_isMonitoring) {
      await _stopMonitoring();
    } else {
      await _startMonitoring();
    }
  }

  Future<void> _prepareServices() async {
    try {
      // 🔥 Init foreground service (only once)
      FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'monitoring_channel',
          channelName: 'Background Monitoring',
          channelDescription: 'Listening for emergencies',
        ),
        iosNotificationOptions: const IOSNotificationOptions(),
        foregroundTaskOptions: const ForegroundTaskOptions(interval: 5000),
      );

      // 🔥 Enable wakelock
      await WakelockPlus.enable();

      // 🔥 Pre-init speech (prevents lag)
      await _speech.initialize();

      // 🔥 Start location in background
      _initLocation();
    } catch (e) {
      debugPrint("Prepare services error: $e");
    }
  }

  Future<void> _startMonitoring() async {
    // ✅ STEP 1: INSTANT UI (NO LAG)
    setState(() => _isMonitoring = true);

    _pulseController.repeat(reverse: true);
    _waveController.repeat();

    // ✅ STEP 2: RUN HEAVY WORK IN BACKGROUND
    Future(() async {
      // 🔥 Start foreground service
      await FlutterForegroundTask.startService(
        notificationTitle: 'Monitoring Active',
        notificationText: 'Listening in background...',
      );

      // 🔥 Keep device awake
      await WakelockPlus.enable();

      // 🔥 Location init (non-blocking improvement)
      _initLocation();

      // 🔥 Retry location (but don’t block UI)
      int retry = 0;
      while (_currentPosition == null && retry < 5) {
        await Future.delayed(const Duration(milliseconds: 500)); // faster
        retry++;
      }

      // 🔥 Speech init (optimized)
      final available = await _speech.initialize(
        onStatus: (status) async {
          debugPrint("Speech status: $status");

          // ✅ FIXED: only restart when DONE
          if (status == "done" && _isMonitoring && !_isEmergencyFlowRunning) {
            await _restartListening();
          }
        },
        onError: (error) async {
          debugPrint("Speech error: $error");

          if (_isMonitoring && !_isEmergencyFlowRunning) {
            await Future.delayed(const Duration(milliseconds: 500));
            await _restartListening();
          }
        },
      );

      if (!available) {
        debugPrint("Speech recognition not available");

        await FlutterForegroundTask.stopService();
        await WakelockPlus.disable();
        return;
      }

      // 🔥 Notification
      await NotificationService.showNotification(
        title: "Monitoring Started",
        body: "Your safety monitoring is active 🚨",
      );

      // 🔥 Start listening + shake
      await _startListening();
      _startShakeDetection();
    });
  }

  Future<void> _stopMonitoring() async {
    setState(() {
      _isMonitoring = false;
      _cancelWindowActive = false;
    });

    // 🔥 STOP FOREGROUND SERVICE
    await FlutterForegroundTask.stopService();

    // 🔥 RELEASE WAKELOCK
    await WakelockPlus.disable();

    _pulseController.stop();
    _pulseController.reset();
    _waveController.stop();
    _waveController.reset();

    _cancelTimer?.cancel();
    _flashTimer?.cancel();
    _positionSubscription?.cancel();

    await _speech.stop();
    await _stopEmergencyEffects();

    await NotificationService.cancelNotification();
    _shakeSubscription?.cancel();
  }

  Future<void> _initLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _positionSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 5,
            ),
          ).listen((Position position) {
            _currentPosition = position;
            debugPrint(
              "LOCATION UPDATE: ${position.latitude}, ${position.longitude}",
            );
          });
    } catch (e) {
      debugPrint("Location init error: $e");
    }
  }

  void _startShakeDetection() {
    _shakeSubscription = accelerometerEvents.listen((event) async {
      double x = event.x;
      double y = event.y;
      double z = event.z;

      double gForce = (x * x + y * y + z * z) / (9.8 * 9.8);

      if (gForce > 3) {
        if (!_isEmergencyFlowRunning) {
          await _handleDistressDetected("shake detected");
        }
      }
    });
  }

  Future<void> _startListening() async {
    if (!_isMonitoring) return;

    await _speech.listen(
      listenMode: stt.ListenMode.confirmation, // 🔥 faster & stable
      partialResults: false, // 🔥 reduces noise
      cancelOnError: true,
      onResult: (result) async {
        final spoken = result.recognizedWords.trim().toLowerCase();

        setState(() {
          _lastHeardText = spoken.isEmpty ? "Listening..." : spoken;
          _lastConfidence = result.hasConfidenceRating
              ? result.confidence
              : 0.0;
        });

        // 🔥 ONLY FINAL RESULT → faster + accurate
        if (result.finalResult &&
            spoken.isNotEmpty &&
            !_isEmergencyFlowRunning) {
          if (_isSmartEmergency(spoken, _lastConfidence)) {
            await _checkEmergencyFromBackend(spoken);
          }
        }
      },
    );
  }

  Future<void> _restartListening() async {
    if (!_isMonitoring || _isEmergencyFlowRunning) return;

    await _speech.stop();
    await Future.delayed(const Duration(milliseconds: 300));

    if (_isMonitoring && !_isEmergencyFlowRunning) {
      await _startListening();
    }
  }

  bool _containsDistress(String text) {
    final keywords = [
      "help",
      "bachao",
      "save me",
      "emergency",
      "danger",
      "attack",
      "chor",
      "mujhe bachao",
      "please help",
      "help me",
      "bachao bachao",
    ];

    for (final word in keywords) {
      if (text.contains(word)) return true;
    }
    return false;
  }

  int _countOccurrences(String text, String word) {
    return text.split(word).length - 1;
  }

  bool _isSmartEmergency(String text, double confidence) {
    text = text.toLowerCase().trim();

    if (text.length < 3) return false;

    bool hasKeyword = _containsDistress(text);

    int helpCount =
        _countOccurrences(text, "help") + _countOccurrences(text, "bachao");

    bool repeated = helpCount >= 2;

    bool highConfidence = confidence > 0.6;

    bool strongPhrase =
        text.contains("save me") ||
        text.contains("mujhe bachao") ||
        text.contains("bachao bachao");

    return (hasKeyword && highConfidence && text.length > 5) ||
        repeated ||
        strongPhrase;
  }

  Future<void> _handleDistressDetected(String text) async {
    // 🔥 1. COOLDOWN FIRST (prevents duplicate triggers)
    if (_lastEmergencyTime != null &&
        DateTime.now().difference(_lastEmergencyTime!) <
            const Duration(seconds: 20)) {
      return;
    }

    _lastEmergencyTime = DateTime.now();

    // 🔥 2. SET FLAGS
    _isEmergencyFlowRunning = true;
    _cancelWindowActive = true;

    // 🔥 3. STOP SPEECH
    await _speech.stop();

    // 🔥 4. START EFFECTS (vibration, sound, torch)
    await _startEmergencyEffects();

    // 🔥 5. SHOW CANCEL DIALOG
    if (mounted) {
      _showCancelDialog();
    }

    // 🔥 6. WAIT FOR CANCEL WINDOW
    _cancelTimer = Timer(const Duration(seconds: 5), () async {
      if (!_cancelWindowActive) return;

      _cancelWindowActive = false;

      // ✅ CLOSE DIALOG
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      // 🔥 STOP EFFECTS
      await _stopEmergencyEffects();

      double lat = 0.0;
      double lng = 0.0;

      // 🔥 GET LOCATION
      if (_currentPosition != null) {
        lat = _currentPosition!.latitude;
        lng = _currentPosition!.longitude;
      } else {
        try {
          Position pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          lat = pos.latitude;
          lng = pos.longitude;
        } catch (_) {}
      }

      // 🔥 CALL BACKEND (SMS + CALL)
      await _triggerEmergencyAPI(distressText: text, lat: lat, lng: lng);

      // 🔥 NAVIGATE TO ALERT SCREEN
      if (!mounted) return;

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => AlertScreen(
            contactCount: widget.contacts.length,
            onBack: () => Navigator.of(context).pop(),
          ),
        ),
      );

      // 🔥 RESET STATE
      _isEmergencyFlowRunning = false;

      // 🔥 RESUME LISTENING
      if (_isMonitoring) {
        await _restartListening();
      }
    });
  }

  void _showCancelDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Emergency detected"),
          content: const Text(
            "Vibration started. Cancel within 5 seconds if this is not an emergency.",
          ),
          actions: [
            TextButton(
              onPressed: () async {
                _cancelTimer?.cancel();
                _cancelWindowActive = false;

                Navigator.of(ctx).pop();

                await _stopEmergencyEffects();

                _isEmergencyFlowRunning = false;

                if (_isMonitoring) {
                  await _restartListening();
                }
              },
              child: const Text("Cancel Emergency"),
            ),
          ],
        );
      },
    );
  }
  
  Future<void> _checkEmergencyFromBackend(String text) async {
    if (text.length < 4) return;

    _debounceTimer?.cancel(); // 🔥 ADD THIS

    _debounceTimer = Timer(const Duration(milliseconds: 400), () async {
      double lat = 0.0;
      double lng = 0.0;

      // ✅ FORCE LOCATION FETCH
      if (_currentPosition == null) {
        try {
          Position pos = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );
          lat = pos.latitude;
          lng = pos.longitude;
        } catch (e) {
          debugPrint("Location error: $e");
          return; // 🔥 STOP if no location
        }
      } else {
        lat = _currentPosition!.latitude;
        lng = _currentPosition!.longitude;
      }

      final url = Uri.parse("$baseUrl/detect-emergency");
      final contacts = getContactNumbers();
      debugPrint("📞 Contacts: $contacts");
      try {
        final response = await http.post(
          url,
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "user_id": "123",
            "text": text,
            "volume": 0.9,
            "repeat_count": 2,
            "latitude": lat,
            "longitude": lng,
            "contacts": contacts,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          bool isEmergency = data["emergency"] ?? false;

          if (isEmergency && !_isEmergencyFlowRunning) {
            await _handleDistressDetected(text);
          }
        } else {
          debugPrint("❌ Status Code: ${response.statusCode}");
          debugPrint("❌ Body: ${response.body}");
        }
      } catch (e) {
        debugPrint("Backend error: $e");
      }
    });
  }

  Future<void> _triggerEmergencyAPI({
    required String distressText,
    required double lat,
    required double lng,
  }) async {
    final url = Uri.parse("$baseUrl/detect-emergency");

    final contacts = getContactNumbers();
    debugPrint("📞 Contacts: $contacts");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user_id": "123",
          "text": distressText,
          "force_emergency": true,
          "volume": 0.9,
          "repeat_count": 2,
          "latitude": lat,
          "longitude": lng,
          "contacts": contacts,
        }),
      );

      debugPrint("API STATUS: ${response.statusCode}");
      debugPrint("API BODY: ${response.body}");
    } catch (e) {
      debugPrint("API Error: $e");
    }
  }

  Future<void> _startEmergencyEffects() async {
    try {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(pattern: [0, 500, 300, 500], repeat: 0);
      }
    } catch (_) {}

    try {
      await _audioPlayer.stop();
      await _audioPlayer.setVolume(0.2);
      await _audioPlayer.play(AssetSource('sounds/emergency.mp3'));
    } catch (_) {}

    _flashTimer?.cancel();

    bool on = false;
    _flashTimer = Timer.periodic(const Duration(milliseconds: 500), (_) async {
      try {
        if (on) {
          await TorchLight.disableTorch();
        } else {
          await TorchLight.enableTorch();
        }
        on = !on;
      } catch (_) {}
    });
  }

  Future<void> _stopEmergencyEffects() async {
    _flashTimer?.cancel();

    try {
      await TorchLight.disableTorch();
    } catch (_) {}

    try {
      await _audioPlayer.stop();
    } catch (_) {}

    try {
      Vibration.cancel();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Self Live Monitoring'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Monitor"),
            Tab(text: "Safety Timer"),
          ],
        ),
      ),
      body: TabBarView(
  controller: _tabController,
  children: [

    // 🟢 TAB 1 → MONITOR UI
    SafeArea(
      child: Column(
        children: [
          _StatusBanner(isMonitoring: _isMonitoring),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _MonitoringButton(
                    isMonitoring: _isMonitoring,
                    pulseAnim: _pulseAnim,
                    waveController: _waveController,
                    onPressed: _toggleMonitoring,
                  ),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _isMonitoring
                        ? _ActiveStatusText(
                            heardText: _lastHeardText,
                            confidence: _lastConfidence,
                          )
                        : const _InactiveStatusText(),
                  ),
                  const SizedBox(height: 48),

                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.people_rounded,
                          label: 'Contacts',
                          value: widget.contacts.length.toString(),
                          color: AppTheme.accentBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: _InfoCard(
                          icon: Icons.mic_rounded,
                          label: 'Voice AI',
                          value: 'Ready',
                          color: AppTheme.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // const Expanded(
                      //   child: _InfoCard(
                      //     icon: Icons.location_on_rounded,
                      //     label: 'Location',
                      //     value: 'GPS On',
                      //     color: Color(0xFFFFAB40),
                      //   ),
                      // ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _tabController.animateTo(1),
                          child: _InfoCard(
                            icon: Icons.timer_rounded,
                            label: 'Timer',
                            value: 'Set Safety Timer',
                            color: _isMonitoring
                                    ? AppTheme.textSecondary
                                    : AppTheme.textHint,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),

    // ⏱ TAB 2 → TIMER
    SafetyTimerTab(
  contacts: widget.contacts,
  onStateChanged: ({
    required bool timerRunning,
    required bool timerPaused,
    required bool isUrgent,
    required String timerDisplay,
  }) {
    // 🔥 For now do nothing (just fix error)
  },
),
  ],
),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final bool isMonitoring;
  const _StatusBanner({required this.isMonitoring});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: isMonitoring
          ? AppTheme.green.withValues(alpha: 0.1)
          : AppTheme.surfaceLight,
      child: Center(
        child: Text(
          isMonitoring ? 'Monitoring Active' : 'Monitoring OFF',
          style: TextStyle(
            color: isMonitoring ? AppTheme.green : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _MonitoringButton extends StatelessWidget {
  final bool isMonitoring;
  final Animation<double> pulseAnim;
  final AnimationController waveController;
  final VoidCallback onPressed;

  const _MonitoringButton({
    required this.isMonitoring,
    required this.pulseAnim,
    required this.waveController,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: CircleAvatar(
        radius: 90,
        backgroundColor: isMonitoring ? AppTheme.green : AppTheme.surfaceLight,
        child: Icon(
          isMonitoring ? Icons.stop : Icons.play_arrow,
          size: 50,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }
}

class _ActiveStatusText extends StatelessWidget {
  final String heardText;
  final double confidence;

  const _ActiveStatusText({required this.heardText, required this.confidence});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text("🟢 Monitoring Active"),
        const SizedBox(height: 8),
        Text("Listening: $heardText"),
        const SizedBox(height: 6),
        Text("Confidence: ${(confidence * 100).toStringAsFixed(0)}%"),
      ],
    );
  }
}

class _InactiveStatusText extends StatelessWidget {
  const _InactiveStatusText();

  @override
  Widget build(BuildContext context) {
    return const Text("Tap to Start");
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color),
        Text(value),
        Text(label),
      ],
    );
  }
}
