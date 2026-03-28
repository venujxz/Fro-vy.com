import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'views/theme_notifier.dart';
import 'util/app_colors.dart';
import 'views/welcome_screen.dart';
import 'views/home_screen.dart';
import 'services/payment_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Stripe
  await PaymentService.initialize();

  // Try to find cameras
  List<CameraDescription> cameras = [];
  try {
    cameras = await availableCameras();
  } catch (e) {
    debugPrint('Camera Error: $e');
  }

  // Determine auth state from Firebase (not SharedPreferences).
  // A user is considered "logged in" only if they have a verified email.
  final User? firebaseUser = FirebaseAuth.instance.currentUser;
  bool isLoggedIn = false;
  if (firebaseUser != null) {
    // Reload to get latest emailVerified status from the server
    try {
      await firebaseUser.reload();
      isLoggedIn =
          FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    } catch (_) {
      isLoggedIn = false;
    }
    // If the user exists but hasn't verified, sign them out so the welcome
    // screen is shown cleanly on next launch.
    if (!isLoggedIn) {
      await FirebaseAuth.instance.signOut();
    }
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('si'),
        Locale('ta'),
      ],
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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Fro-vy',
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          themeMode: currentMode,
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme:
                ColorScheme.fromSeed(seedColor: AppColors.frovyGreen),
            scaffoldBackgroundColor: AppColors.frovyLightBg,
            useMaterial3: true,
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.frovyGreen,
              foregroundColor: Colors.white,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.frovyGreen,
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
          home: isLoggedIn
              ? HomeScreen(cameras: cameras)
              : WelcomeScreen(cameras: cameras),
        );
      },
    );
  }
}