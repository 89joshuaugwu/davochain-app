import 'package:davochain/features/profile_settings/presentation/verification/verification_state.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/auth/presentation/signup_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final session = VerificationSession.instance;
  setUp(() {
    session.reset();
  });
  tearDown(() {
    session.reset();
  });
  testWidgets(
      'signup policies open without accepting consent or leaving signup',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light, home: const CountrySelectionScreen()));
    await tester.pumpAndSettle();
    for (final entry in {
      'Terms and conditions': 'Using Davochain',
      'Privacy policy': 'Your information, your choices'
    }.entries) {
      await tester.tapOnText(find.textRange.ofSubstring(entry.key));
      await tester.pumpAndSettle();
      expect(find.text(entry.value), findsOneWidget);
      await tester.tap(find.byTooltip('Close'));
      await tester.pumpAndSettle();
      expect(find.byType(CountrySelectionScreen), findsOneWidget);
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
    }
    expect(tester.takeException(), isNull);
  });
}
