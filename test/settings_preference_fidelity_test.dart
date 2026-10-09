import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/profile_settings/presentation/profile_settings_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> mount(WidgetTester tester, Widget screen, {bool dark = false, double scale = 1, double width = 390}) async {
  tester.view.physicalSize = Size(width, 844);
  tester.view.devicePixelRatio = 1;
  await tester.pumpWidget(MaterialApp(theme: dark ? AppTheme.dark : AppTheme.light,
    builder: (context, child) => MediaQuery(data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)), child: child!),
    home: screen));
  await tester.pumpAndSettle();
}
Finder toggle(String label) => find.byWidgetPredicate((widget) => widget is Semantics && widget.properties.label == label && widget.properties.toggled != null);
bool value(WidgetTester tester, String label) => tester.widget<Semantics>(toggle(label)).properties.toggled!;
void main() {
  tearDown(() => TestWidgetsFlutterBinding.instance.platformDispatcher.clearAllTestValues());
  testWidgets('crypto uses blue controls, exact supplied icons and compact typography', (tester) async {
    addTearDown(tester.view.resetPhysicalSize); addTearDown(tester.view.resetDevicePixelRatio);
    await mount(tester, const CryptoSecurityScreen());
    expect(find.byType(SvgPicture), findsNWidgets(3));
    expect(tester.widget<Text>(find.text('Crypto Security')).style!.fontSize, 16);
    expect(tester.widget<Text>(find.text('Withdrawal Confirmation')).style!.fontSize, 12);
    expect(tester.widget<Text>(find.text('Withdrawal Confirmation')).style!.fontWeight, FontWeight.w400);
    final tracks = tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer));
    expect(tracks, hasLength(3));
    for (final track in tracks) {
      expect((track.decoration! as BoxDecoration).color, AppColors.primary);
      expect(track.constraints!.maxWidth, 40);
      expect(track.constraints!.maxHeight, 22);
    }
    expect(value(tester, 'Withdrawal Confirmation'), isTrue);
    await tester.tap(toggle('Withdrawal Confirmation')); await tester.pumpAndSettle();
    expect(value(tester, 'Withdrawal Confirmation'), isFalse);
    expect(tester.takeException(), isNull);
  });
  testWidgets('notification groups and all eleven toggles work, including tips', (tester) async {
    addTearDown(tester.view.resetPhysicalSize); addTearDown(tester.view.resetDevicePixelRatio);
    await mount(tester, const NotificationsPreferencesScreen());
    expect(find.byKey(const ValueKey('settings-preference-group')), findsNWidgets(3));
    expect(find.byType(SvgPicture), findsNWidgets(11));
    for (final heading in ['Transaction Alerts', 'Account Alerts', 'Marketing & Updates']) {
      expect(tester.widget<Text>(find.text(heading)).style!.fontSize, 14);
      expect(tester.widget<Text>(find.text(heading)).style!.fontWeight, FontWeight.w400);
    }
    await tester.ensureVisible(toggle('Tips & Education'));
    await tester.pumpAndSettle();
    expect(value(tester, 'Tips & Education'), isTrue);
    await tester.tap(toggle('Tips & Education')); await tester.pumpAndSettle();
    expect(value(tester, 'Tips & Education'), isFalse);
    await tester.tap(toggle('Tips & Education')); await tester.pumpAndSettle();
    expect(value(tester, 'Tips & Education'), isTrue);
    expect(tester.takeException(), isNull);
  });
  testWidgets('privacy preserves off marketing default and actionable preview detail sheets', (tester) async {
    addTearDown(tester.view.resetPhysicalSize); addTearDown(tester.view.resetDevicePixelRatio);
    await mount(tester, const PrivacyScreen());
    expect(find.byKey(const ValueKey('settings-preference-group')), findsOneWidget);
    expect(find.byType(SvgPicture), findsNWidgets(6));
    expect(value(tester, 'Markets Communications'), isFalse);
    await tester.tap(toggle('Markets Communications')); await tester.pumpAndSettle();
    expect(value(tester, 'Markets Communications'), isTrue);
    await tester.tap(find.text('Data & Permissions')); await tester.pumpAndSettle();
    expect(find.text('These preview preferences apply only to this screen. Device permissions can be managed in your device settings.'), findsOneWidget);
    await tester.tap(find.text('Done')); await tester.pumpAndSettle();
    await tester.tap(find.text('Block Users')); await tester.pumpAndSettle();
    expect(find.text('No blocked contacts in this preview. Blocking and contact management will be available when your account is connected.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final dark in [false, true]) {
    for (final screen in <Widget>[const CryptoSecurityScreen(), const PrivacyScreen(), const NotificationsPreferencesScreen()]) {
      testWidgets('${screen.runtimeType} fits narrow ${dark ? 'dark' : 'light'} with 2x text', (tester) async {
        addTearDown(tester.view.resetPhysicalSize); addTearDown(tester.view.resetDevicePixelRatio);
        await mount(tester, screen, dark: dark, scale: 2, width: 320);
        expect(tester.takeException(), isNull);
        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -1500));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  }
}
