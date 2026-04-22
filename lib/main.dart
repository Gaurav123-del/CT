// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:sosapp/theme.dart';
// import 'screens/login_screen.dart';
// import 'services/notification_service.dart';

// // ✅ MOVE navigatorKey OUTSIDE
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await NotificationService.init(); // ✅ init notifications

//   // Force dark status bar icons
//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       statusBarIconBrightness: Brightness.light,
//     ),
//   );

//   // Portrait only
//   SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//   ]);

//   runApp(const SelfLiveMonitoringApp());
// }

// class SelfLiveMonitoringApp extends StatelessWidget {
//   const SelfLiveMonitoringApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorKey: navigatorKey, // ✅ now works
//       title: 'Self Live Monitoring',
//       debugShowCheckedModeBanner: false,
//       theme: AppTheme.darkTheme,
//       home: const LoginScreen(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sosapp/theme.dart';
import 'screens/login_screen.dart';
import 'services/notification_service.dart';

// ✅ NEW
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

// ✅ navigatorKey
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.init();

  // 🔥 INIT FOREGROUND SERVICE
FlutterForegroundTask.init(
  androidNotificationOptions: AndroidNotificationOptions(
    channelId: 'monitoring_channel',
    channelName: 'Background Monitoring',
    channelDescription: 'Listening for emergencies',
  ),
  iosNotificationOptions: const IOSNotificationOptions(), // ✅ REQUIRED
  foregroundTaskOptions: const ForegroundTaskOptions(
    interval: 5000, // ✅ for this version
    autoRunOnBoot: false,
    allowWakeLock: true,
  ),
);

  // 🔥 Keep screen awake (important for mic)
  await WakelockPlus.enable();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

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
      navigatorKey: navigatorKey,
      title: 'Self Live Monitoring',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const LoginScreen(),
    );
  }
}  