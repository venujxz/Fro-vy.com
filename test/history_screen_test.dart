import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frovy_app/views/history_screen.dart';
import 'package:frovy_app/views/result_screen.dart';
import 'package:frovy_app/views/verification_sent_screen.dart';

void main() {
  group('HistoryScreen widget tests', () {
    testWidgets('displays initial history items', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: HistoryScreen()));

      // initial sample data contains at least the first two products.
      expect(find.text('Almond Breeze Original'), findsOneWidget);
      expect(find.text('Skippy Peanut Butter'), findsOneWidget);

      // the third item may be off-screen, scroll to reveal it first
      await tester.fling(find.byType(ListView), const Offset(0, -300), 1000);
      await tester.pumpAndSettle();
      expect(find.text('Coca-Cola Classic'), findsOneWidget);
    });

    testWidgets('tapping a card pushes ResultScreen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: HistoryScreen()));

      // tap the Skippy card (text inside the card is tappable)
      await tester.tap(find.text('Skippy Peanut Butter'));
      await tester.pumpAndSettle();

      // should navigate to ResultScreen and show the same product name
      expect(find.byType(ResultScreen), findsOneWidget);
      expect(
        find.text('Skippy Peanut Butter'),
        findsWidgets,
      ); // appears in AppBar/title
    });

    testWidgets('deleting an item shows snack bar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: HistoryScreen()));

      // make sure we have at least one delete icon available
      final initialIcons = find.byIcon(Icons.delete_outline);
      expect(initialIcons, findsAtLeastNWidgets(1));

      // tap the first delete icon and pump
      await tester.tap(initialIcons.first);
      await tester.pumpAndSettle();

      // snack bar should be shown
      expect(find.text('Item deleted from history'), findsOneWidget);
    });

    testWidgets('clear all button shows confirmation and clears list', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: HistoryScreen()));

      // open the dialog
      await tester.tap(find.text('Clear All History'));
      await tester.pumpAndSettle();

      expect(find.text('Clear History?'), findsOneWidget);

      // confirm clear
      await tester.tap(find.text('Clear All'));
      await tester.pumpAndSettle();

      // no items should remain
      expect(find.text('Almond Breeze Original'), findsNothing);
      expect(find.text('Skippy Peanut Butter'), findsNothing);
      expect(find.text('Coca-Cola Classic'), findsNothing);
    });

    testWidgets('verification screen redirects to history after delay', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: VerificationSentScreen(email: 'foo@bar.com')),
      );

      expect(find.text('Verification Email Sent!'), findsOneWidget);

      // advance time by the timer duration
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      expect(find.byType(HistoryScreen), findsOneWidget);
    });
  });
}
