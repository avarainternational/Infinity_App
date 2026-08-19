import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_builder_studio/main_app.dart';

void main() {
  testWidgets('shows Infinity Wellness Super App shell and tabs', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify 5 navigation tabs exist
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Feed'), findsOneWidget);
    expect(find.text('Mini-Apps'), findsOneWidget);
    expect(find.text('Wallet'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Verify Home snapshot elements
    expect(find.text('Daily Hydration'), findsOneWidget);
    expect(find.text('Active Streaks'), findsOneWidget);
    expect(find.text('Pinned Mini-Apps'), findsOneWidget);

    // Test quick water log button
    expect(find.text('+250 ml'), findsOneWidget);
    await tester.tap(find.text('+250 ml'));
    await tester.pump();
    expect(find.text('2100 / 2600 ml'), findsOneWidget);

    // Dismiss any snackbar
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Switch to Feed tab
    await tester.tap(find.byIcon(Icons.newspaper_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Wellness Feed'), findsOneWidget);

    // Switch to Mini-Apps tab
    await tester.tap(find.byIcon(Icons.grid_view_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Mini-App Store'), findsOneWidget);
    expect(find.text('Medical News & Myths'), findsOneWidget);
    expect(find.text('Smart Hydration Reminder'), findsOneWidget);

    // Switch to Profile tab
    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pumpAndSettle();
    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Health Metrics'), findsOneWidget);
    expect(find.text('Alex Morgan'), findsOneWidget);
  });
}
