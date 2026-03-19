// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:frovy_app/main.dart';

void main() {
  testWidgets('App loads and shows login screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FrovyApp(cameras: []));

    // Verify that the app displays the login screen with FRO-VY title
    expect(find.text('FRO-VY'), findsOneWidget);
    expect(find.text("Let's start by getting to know you"), findsOneWidget);
  });
}
