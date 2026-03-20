import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'views/home_screen.dart';
import 'views/welcome_screen.dart';
import 'views/theme_notifier.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAuth.instance.signOut(); // Remove this line before production

  List<CameraDescription> cameras = [];
  try {
    cameras = await availableCameras();
  } catch (e) {
    debugPrint('Camera Error: $e');
  }

  runApp(FrovyApp(cameras: cameras));
}

class FrovyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const FrovyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Fro-vy',
          themeMode: currentMode,
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6AA15E)),
            scaffoldBackgroundColor: const Color(0xFFF8F9FA),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF6AA15E),
              foregroundColor: Colors.white,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6AA15E),
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF121212),
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1F1F1F),
              foregroundColor: Colors.white,
            ),
            cardTheme: const CardThemeData(color: Color(0xFF2C2C2C)),
          ),
          home: _buildHome(),
        );
      },
    );
  }

  Widget _buildHome() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null || !user.emailVerified) {
      if (user != null && !user.emailVerified) {
        FirebaseAuth.instance.signOut();
      }
      return const WelcomeScreen();
    }
    return HomeScreen(cameras: cameras);
  }
}
