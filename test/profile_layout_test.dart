import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/profile_settings/presentation/profile_settings_flow.dart';

void main() {
  testWidgets('privacy descriptions remain visible with large text on narrow phones', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.5)),
        child: child!,
      ),
      home: const PrivacyScreen(),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('App Analytics'));
    final analyticsToggle = find.byWidgetPredicate((widget) => widget is Semantics && widget.properties.label == 'App Analytics');
    await tester.ensureVisible(analyticsToggle);
    await tester.tap(analyticsToggle);
    await tester.pump();
    expect(tester.widget<Semantics>(analyticsToggle).properties.toggled, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('appearance preview includes the supplied phone artwork', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: const AppearanceScreen()));
    await tester.pump();
    final phones = find.byWidgetPredicate((widget) => widget is Image &&
        widget.image is AssetImage &&
        (widget.image as AssetImage).assetName.endsWith('_3__Profile_Image.png'));
    expect(phones, findsOneWidget);
    await tester.ensureVisible(phones);
    expect(tester.getSize(phones).height, greaterThan(150));
    expect(tester.takeException(), isNull);
  });

  testWidgets('information updated provides the design back action', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: Builder(
      builder: (context) => TextButton(
        onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const PersonalInformationSuccessScreen())),
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
