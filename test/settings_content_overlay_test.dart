import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/profile_settings/presentation/settings_content_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() => SettingsContentStore.content.value = {});
  testWidgets(
      'General content opens above settings and updates without navigation',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: Builder(
            builder: (context) => Scaffold(
                body: TextButton(
                    onPressed: () =>
                        showSettingsContent(context, 'Privacy Policy'),
                    child: const Text('Settings entry'))))));
    await tester.tap(find.text('Settings entry'));
    await tester.pumpAndSettle();
    expect(find.text('Your information, your choices'), findsOneWidget);
    expect(find.text('This content is not available yet.'), findsNothing);
    SettingsContentStore.update('Privacy Policy', 'Approved privacy content');
    await tester.pump();
    expect(find.text('Approved privacy content'), findsOneWidget);
    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();
    expect(find.text('Settings entry'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
