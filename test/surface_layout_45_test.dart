import 'package:davochain/features/wallets/simulation_crypto_addresses.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/auth/presentation/login_flow.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_widgets.dart';
import 'package:davochain/features/crypto/presentation/crypto_full_flow.dart';
import 'package:davochain/features/dashboard/presentation/dashboard_screen.dart';
import 'package:davochain/features/profile_settings/presentation/settings_content_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> phone(WidgetTester tester, Widget child) async {
    tester.view.physicalSize = const Size(411, 914);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: child));
    await tester.pumpAndSettle();
  }

  testWidgets('recovery password form starts at the same top edge as email', (
    tester,
  ) async {
    await phone(tester, const ForgotPasswordScreen());
    final originalTop = tester.getTopLeft(find.text('Forgot Password')).dy;
    await tester.enterText(find.byType(TextField), 'qa@example.com');
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 4; i++) {
      await tester.enterText(find.byType(TextField).at(i), '${i + 1}');
    }
    await tester.pump();
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();
    expect(
      tester.getTopLeft(find.text('Set New Password')).dy,
      closeTo(originalTop, 1),
    );
    expect(originalTop, lessThan(150));
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
    'withdrawal eye follows balance label and still hides its value',
    (tester) async {
      await phone(tester, const NairaWithdrawScreen());
      final label = tester.getRect(find.text('Davochain Naira balance'));
      final eye = tester.getCenter(find.byIcon(Icons.visibility_outlined));
      expect(eye.dx, greaterThan(label.right));
      expect(eye.dx - label.right, lessThan(24));
      expect(eye.dy, closeTo(label.center.dy, 5));
      expect(
        tester.getSize(find.byTooltip('Hide balance')).width,
        greaterThanOrEqualTo(48),
      );
      await tester.tap(find.byTooltip('Hide balance'));
      await tester.pump();
      expect(find.byTooltip('Show balance'), findsOneWidget);
      expect(find.text('Balance hidden'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('deposit address card is compact and expands its full address', (
    tester,
  ) async {
    await phone(tester, const CryptoDepositScreen(asset: CryptoAsset.bitcoin));
    expect(
      tester
          .getSize(find.byKey(const ValueKey('compact-deposit-address-card')))
          .height,
      lessThanOrEqualTo(90),
    );
    await tester.ensureVisible(find.text('Show all'));
    await tester.tap(find.text('Show all'));
    await tester.pumpAndSettle();
    expect(
      find.text(SimulationCryptoAddress.bySymbol['BTC']!.address),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'asset search uses a softer field on the sheet and filters assets',
    (tester) async {
      await phone(tester, const Scaffold(body: BuyCryptoAssetSheet()));
      final field = tester.widget<TextField>(
        find.byKey(const ValueKey('asset-search')),
      );
      expect(field.decoration!.fillColor, DavoColors.light.sheetField);
      final backgrounds = tester.widgetList<Material>(find.byType(Material));
      expect(
        backgrounds.any((m) => m.color == DavoColors.light.sheetSurface),
        isTrue,
      );
      await tester.enterText(find.byKey(const ValueKey('asset-search')), 'ETH');
      await tester.pump();
      expect(find.text('Ethereum'), findsOneWidget);
      expect(find.text('Bitcoin'), findsNothing);
    },
  );
  testWidgets('FAQs contain working answers instead of an empty sheet', (
    tester,
  ) async {
    await phone(
      tester,
      Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () => showSettingsContent(context, 'FAQs'),
            child: const Text('Open FAQs'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open FAQs'));
    await tester.pumpAndSettle();
    expect(find.text('Help with your account'), findsOneWidget);
    await tester.tap(find.text('Why is my transaction pending?'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Pending means a final outcome'),
      findsOneWidget,
    );
    expect(find.textContaining('This content is not available'), findsNothing);
  });
}
