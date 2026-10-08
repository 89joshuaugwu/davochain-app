import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/profile_settings/presentation/profile_settings_flow.dart';
import 'package:davochain/features/profile_settings/presentation/verification/verification_overview_screen.dart';
import 'package:davochain/features/profile_settings/presentation/verification/verification_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final session = VerificationSession.instance;
  setUp(session.reset);
  tearDown(session.reset);
  Widget app(Widget home) => MaterialApp(theme: AppTheme.light, home: home);

  testWidgets('Overview exposes Basic and gates Advanced', (tester) async {
    await tester.pumpWidget(app(const VerificationOverviewScreen()));
    expect(find.text('Basic verification'), findsOneWidget);
    expect(find.text('Advanced verification'), findsOneWidget);
    final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Start Advanced'));
    expect(button.onPressed, isNull);
    await tester.tap(find.text('Complete profile'));
    await tester.pumpAndSettle();
    expect(find.byType(CompleteProfileV12Screen), findsOneWidget);
  });
  testWidgets(
      'Either identity choice filters to eleven digits and submits without face',
      (tester) async {
    session.completeProfile();
    await tester.pumpWidget(app(const BasicIdentityChoiceScreen()));
    await tester.tap(find.text('BVN'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Enter your BVN'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '123a4567890123');
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '12345678901');
    await tester.tap(find.text('Submit Basic verification'));
    await tester.pumpAndSettle();
    expect(find.text('Pending review'), findsOneWidget);
    expect(session.identifierLastFour, '8901');
    expect(session.faceAdded, isFalse);
  });
  testWidgets('Personal draft resumes and middle name is optional',
      (tester) async {
    session
        .saveProfile({'first': 'Ada', 'last': 'Okafor', 'dob': '1998-05-12'});
    await tester.pumpWidget(app(const CompleteProfileV12Screen()));
    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('Middle name (optional)'), findsOneWidget);
    await tester.ensureVisible(find.text('Continue'));
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.byType(CompleteProfileContactV12Screen), findsOneWidget);
  });
}
