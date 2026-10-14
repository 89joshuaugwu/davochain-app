import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/profile_settings/presentation/profile_settings_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('profile date selection is an accessible button', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light, home: const CompleteProfileV12Screen()));
    final date = find.bySemanticsLabel(RegExp('Select date of birth'));
    expect(date, findsOneWidget);
    final data = tester.getSemantics(date).getSemanticsData();
    expect(data.flagsCollection.isButton, isTrue);
    expect(data.hasAction(SemanticsAction.tap), isTrue);
    semantics.dispose();
  });

  testWidgets('profile form fields grow for large text instead of clipping',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: const MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(3)),
            child: CompleteProfileV12Screen())));
    await tester.pumpAndSettle();
    expect(
        tester.getSize(find.byType(TextField).first).height, greaterThan(48));
  });

  testWidgets('profile switches settle immediately with accessible navigation',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: const MediaQuery(
            data: MediaQueryData(accessibleNavigation: true),
            child: ProfileSettingsScreen())));
    for (final widget in tester
        .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))) {
      expect(widget.duration, Duration.zero);
    }
    for (final widget
        in tester.widgetList<AnimatedAlign>(find.byType(AnimatedAlign))) {
      expect(widget.duration, Duration.zero);
    }
  });
}
