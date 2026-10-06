import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/auth/presentation/login_flow.dart';
import 'package:davochain/features/auth/presentation/signup_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('country selection starts disabled', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const CountrySelectionScreen()),
    );
    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Select your country'), findsOneWidget);
  });

  testWidgets('login screen contains recovery action', (tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const LoginScreen()),
    );
    expect(find.text('Welcome back!'), findsOneWidget);
    expect(find.text('Forgot Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
