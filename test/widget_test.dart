// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:frovy_app/main.dart';
import 'package:camera/camera.dart';

// Mock Firebase Core
class MockFirebasePlatform extends FirebasePlatform {
  static final _mockApp = FakeFirebaseAppPlatform();

  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    return _mockApp;
  }

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    return _mockApp;
  }

  @override
  List<FirebaseAppPlatform> get apps {
    return [_mockApp];
  }
}

class FakeFirebaseAppPlatform extends FirebaseAppPlatform {
  FakeFirebaseAppPlatform()
      : super(defaultFirebaseAppName, const FirebaseOptions(
          apiKey: 'fake-api-key',
          appId: 'fake-app-id',
          messagingSenderId: 'fake-sender-id',
          projectId: 'fake-project-id',
        ));

  @override
  Future<void> delete() async {}

  @override
  Future<void> setAutomaticDataCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setAutomaticResourceManagementEnabled(bool enabled) async {}
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Setup Firebase mocks
    FirebasePlatform.instance = MockFirebasePlatform();

    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  testWidgets('App loads and displays welcome screen', (WidgetTester tester) async {
    // Mock cameras
    const List<CameraDescription> mockCameras = [];

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('si'), Locale('ta')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: const FrovyApp(cameras: mockCameras),
      ),
    );

    // Rebuild to allow EasyLocalization to initialize and provide the locale downstream.
    await tester.pumpAndSettle();

    // Verify that the app displays the welcome screen with FRO-VY logo
    expect(find.text('FRO-VY'), findsOneWidget);

    // Check for the get_started button/text (may be key or translated)
    final getStartedFinder = find.textContaining('get_started', findRichText: true);
    expect(getStartedFinder, findsWidgets);
  });
}