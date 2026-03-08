import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'views/home_screen.dart';
import 'views/theme_notifier.dart'; // Import the new notifier

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Try to find cameras
  List<CameraDescription> cameras = [];
  try {
    cameras = await availableCameras();
  } catch (e) {
  debugPrint("Camera Error: $e");
}

  // 2. Start the app
  runApp(FrovyApp(cameras: cameras));
}

class FrovyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const FrovyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    // Wrap the entire app in a ValueListenableBuilder
    // This listens to 'themeNotifier' and rebuilds when it changes
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Fro-vy',
          
          // --- THEME CONFIGURATION ---
          themeMode: currentMode, // This is the magic line that switches modes

          // 1. LIGHT THEME DEFINITION
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

          // 2. DARK THEME DEFINITION
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6AA15E),
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF121212), // Dark grey background
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1F1F1F), // Darker header
              foregroundColor: Colors.white,
            ),
            cardTheme: const CardThemeData(
              color: Color(0xFF2C2C2C), // Dark cards
            ),
          ),
          
          home: HomeScreen(cameras: cameras),
        );
      },
    );
  }
}
