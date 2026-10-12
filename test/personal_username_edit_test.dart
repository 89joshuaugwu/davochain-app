import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/profile_settings/presentation/profile_settings_flow.dart';
import 'package:davochain/features/profile_settings/presentation/verification/verification_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(VerificationSession.instance.reset);
  tearDown(VerificationSession.instance.reset);
  testWidgets(
      'only username can be edited; fixed and verified fields stay read-only',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light, home: const PersonalInformationV12Screen()));
    await tester.ensureVisible(find.text('Edit Information'));
    await tester.tap(find.text('Edit Information'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'DavoJoshua');
    await tester.pump();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save Changes'));
    await tester.tap(find.text('Save Changes'));
    await tester.pumpAndSettle();
    expect(VerificationSession.instance.profileDraft['username'], 'DavoJoshua');
    expect(find.byType(PersonalInformationSuccessScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
