import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/onboarding/presentation/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Davochain onboarding changes content inside one screen shell', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const OnboardingScreen()),
    );

    expect(find.text('Trade Crypto, Your Way'), findsOneWidget);
    expect(find.text('Simple. Fast. Secure.'), findsNothing);

    await tester.tap(find.text('Next'));
    // Wait for the swipe transition and progress indicator to settle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Simple. Fast. Secure.'), findsOneWidget);
    expect(find.text('Trade Crypto, Your Way'), findsNothing);

    await tester.tap(find.text('Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Turn Gift Cards Into Cash'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
