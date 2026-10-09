import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_widgets.dart';
import 'package:davochain/features/crypto/presentation/crypto_full_flow.dart';
import 'package:davochain/features/auth/presentation/signup_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final size in [const Size(390, 844), const Size(640, 320)]) {
    testWidgets('country page and Nigeria picker protect insets at $size',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.view.padding =
          const FakeViewPadding(top: 44, bottom: 96, left: 24, right: 24);
      tester.view.viewPadding =
          const FakeViewPadding(top: 44, bottom: 96, left: 24, right: 24);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.view.resetViewPadding);
      await tester.pumpWidget(MaterialApp(
          theme: AppTheme.light, home: const CountrySelectionScreen()));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Select your country'));
      await tester.tap(find.text('Select your country'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Nigeria'));
      await tester.pumpAndSettle();
      final country = tester.getRect(find.text('Nigeria'));
      expect(country.bottom, lessThanOrEqualTo(size.height - 96));
      expect(country.top, greaterThanOrEqualTo(44));
      expect(country.left, greaterThanOrEqualTo(24));
      await tester.tap(find.text('Nigeria'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(tester.getRect(find.text('Continue')).bottom,
          lessThanOrEqualTo(size.height - 96));
      expect(tester.takeException(), isNull);
    });
  }
  testWidgets('bank search and selection stay above the keyboard',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 44, bottom: 34);
    tester.view.viewPadding = const FakeViewPadding(top: 44, bottom: 34);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const AddBankScreen()));
    await tester.tap(find.text('Select bank name'));
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    tester.view.padding = const FakeViewPadding(top: 44);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Access');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Access Bank'));
    await tester.pumpAndSettle();
    expect(tester.getRect(find.text('Access Bank')).bottom,
        lessThanOrEqualTo(544));
    await tester.tap(find.text('Access Bank'));
    await tester.pumpAndSettle();
    expect(find.text('Select Bank'), findsNothing);
    expect(find.text('Access Bank'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final size in [const Size(390, 844), const Size(640, 320)]) {
    testWidgets('asset selector stays reachable inside system insets at $size',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.view.padding =
          const FakeViewPadding(top: 44, bottom: 96, left: 24, right: 24);
      tester.view.viewPadding =
          const FakeViewPadding(top: 44, bottom: 96, left: 24, right: 24);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.view.resetViewPadding);
      await tester.pumpWidget(MaterialApp(
          theme: AppTheme.light,
          home: Builder(
              builder: (context) => Scaffold(
                      body: TextButton(
                    onPressed: () => showModalBottomSheet<void>(
                        context: context,
                        useSafeArea: true,
                        isScrollControlled: true,
                        builder: (_) => const BuyCryptoAssetSheet()),
                    child: const Text('Open'),
                  )))));
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Tether'));
      await tester.pumpAndSettle();
      final rect = tester.getRect(find.text('Tether'));
      expect(rect.bottom, lessThanOrEqualTo(size.height - 96));
      expect(rect.top, greaterThanOrEqualTo(44));
      expect(rect.left, greaterThanOrEqualTo(24));
      expect(tester.takeException(), isNull);
    });
  }
}
