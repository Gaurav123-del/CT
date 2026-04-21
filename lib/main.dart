import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:/theme.dart';
import 'screens/login_screen.dart';
import 'services/notification_service.dart';

// ✅ MOVE navigatorKey OUTSIDE
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init(); // ✅ init notifications

  // Force dark status bar icons
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Portrait only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const SelfLiveMonitoringApp());
}

class SelfLiveMonitoringApp extends StatelessWidget {
  const SelfLiveMonitoringApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // ✅ now works
      title: 'Self Live Monitoring',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const LoginScreen(),
    );
  }
}