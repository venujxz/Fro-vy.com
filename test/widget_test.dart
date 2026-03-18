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
import 'package:frovy_app/main.dart';

void main() {
  testWidgets('App loads and displays welcome screen', (WidgetTester tester) async {
    // Setup EasyLocalization for tests
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('si'), Locale('ta')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: const FrovyApp(cameras: [], isLoggedIn: false),
      ),
    );

    // Rebuild to allow EasyLocalization to initialize and provide the locale downstream.
    await tester.pumpAndSettle();

    // Verify that the app displays the welcome screen
    expect(find.text('FRO-VY'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}