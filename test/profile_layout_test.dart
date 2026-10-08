import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/profile_settings/presentation/profile_settings_flow.dart';

void main() {
  testWidgets('profile badge overlaps portrait and header spacing is compact',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light, home: const ProfileSettingsScreen()));
    final portrait = find.byKey(const ValueKey('profile-avatar'));
    final badge = find.byKey(const ValueKey('profile-verification-badge'));
    expect(portrait, findsOneWidget);
    final portraitRect = tester.getRect(portrait);
    final badgeRect = tester.getRect(badge);
    expect(portraitRect.overlaps(badgeRect), isTrue);
    expect(badgeRect.center.dx, greaterThan(portraitRect.center.dx));
    expect(badgeRect.center.dy, greaterThan(portraitRect.center.dy));
    expect(badgeRect.right, lessThanOrEqualTo(portraitRect.right + 2));
    expect(badgeRect.bottom, lessThanOrEqualTo(portraitRect.bottom + 2));
    expect(
        tester.getRect(find.text('Vincent Chukwu')).top - portraitRect.bottom,
        lessThanOrEqualTo(20));
    expect(
        find.byKey(const ValueKey('profile-header-divider')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'privacy descriptions remain visible with large text on narrow phones',
      (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: const TextScaler.linear(1.5)),
        child: child!,
      ),
      home: const PrivacyScreen(),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('App Analytics'));
    final analyticsToggle = find.byWidgetPredicate((widget) =>
        widget is Semantics && widget.properties.label == 'App Analytics');
    await tester.ensureVisible(analyticsToggle);
    await tester.tap(analyticsToggle);
    await tester.pump();
    expect(
        tester.widget<Semantics>(analyticsToggle).properties.toggled, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('appearance preview responds to the selected theme',
      (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const AppearanceScreen()));
    await tester.pump();
    final preview = find.byKey(const ValueKey('appearance-live-preview'));
    expect(preview, findsOneWidget);
    expect((tester.widget<Container>(preview).decoration as BoxDecoration).color, DavoColors.light.canvas);
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();
    expect((tester.widget<Container>(preview).decoration as BoxDecoration).color, DavoColors.dark.canvas);
    await tester.ensureVisible(preview);
    expect(tester.getSize(preview).height, greaterThan(150));
    expect(tester.takeException(), isNull);
  });

  testWidgets('information updated provides the design back action',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                builder: (_) => const PersonalInformationSuccessScreen())),
            child: const Text('Open confirmation'),
          ),
        )));
    await tester.tap(find.text('Open confirmation'));
    await tester.pumpAndSettle();
    expect(find.text('Information Updated'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Open confirmation'), findsOneWidget);
  });
}
