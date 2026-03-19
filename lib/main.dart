import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'views/theme_notifier.dart'; // Import the new notifier
import 'util/app_colors.dart';
import 'views/welcome_screen.dart';
import 'views/home_screen.dart';
import 'services/payment_service.dart';
import 'services/prefs_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Stripe
  await PaymentService.initialize();

  // 1. Try to find cameras
  List<CameraDescription> cameras = [];
  try {
    cameras = await availableCameras();
  } catch (e) {
    debugPrint("Camera Error: $e");
  }

  // 2. Check if user is already registered
  final userProfile = await PrefsService.getUserProfile();
  final isLoggedIn = userProfile.name.isNotEmpty;

  // 3. Start the app
  runApp(
    EasyLocalization(
      // --- ADDED NEW LOCALES HERE ---
      supportedLocales: const [
        Locale('en'), // English
        Locale('si'), // Sinhala
        Locale('ta'), // Tamil
      ],
      // Make sure this path exactly matches where your JSON files are saved!
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: FrovyApp(cameras: cameras, isLoggedIn: isLoggedIn),
    ),
  );
}

class FrovyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  final bool isLoggedIn;

  const FrovyApp({super.key, required this.cameras, required this.isLoggedIn});

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

          // --- LOCALIZATION HOOKS ---
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,

          // --- THEME CONFIGURATION ---
          themeMode: currentMode, // This is the magic line that switches modes
          // 1. LIGHT THEME DEFINITION
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.frovyGreen),
            scaffoldBackgroundColor: AppColors.frovyLightBg,
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.frovyGreen,
              foregroundColor: Colors.white,
            ),
          ),

          // 2. DARK THEME DEFINITION
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.frovyGreen,
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(
              0xFF121212,
            ), // Dark grey background
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF1F1F1F), // Darker header
              foregroundColor: Colors.white,
            ),
            cardTheme: const CardThemeData(
              color: Color(0xFF2C2C2C), // Dark cards
            ),
          ),

          home: isLoggedIn
              ? HomeScreen(cameras: cameras)
              : WelcomeScreen(cameras: cameras),
        );
      },
    );
  }
}
