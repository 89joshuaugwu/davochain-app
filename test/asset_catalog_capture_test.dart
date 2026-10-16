import 'package:davochain/features/buy_crypto/presentation/buy_crypto_widgets.dart';
import 'package:davochain/features/wallets/presentation/wallet_picker_sheet.dart';
import 'package:davochain/features/dashboard/presentation/dashboard_screen.dart';
import 'package:davochain/features/wallets/wallet_repository.dart';
import 'package:davochain/features/profile_settings/presentation/verification/verification_state.dart';
import 'package:davochain/features/crypto/presentation/crypto_full_flow.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_screens.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_models.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:davochain/core/preview/local_preview_profile.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final session = VerificationSession.instance;
  setUp(() {
    session.reset();
  });
  tearDown(() {
    session.reset();
  });
  testWidgets('capture currency layout58', (tester) async {
    tester.view.physicalSize = const Size(411, 914);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    LocalPreviewProfile.instance.loginSample();
    final key = GlobalKey();
    final directory = Directory('../review/evidence/currency-layout-58/widgets')
      ..createSync(recursive: true);
    await tester.runAsync(() async {
      final emojiFont = File('C:/Windows/Fonts/seguiemj.ttf');
      if (emojiFont.existsSync()) {
        await (FontLoader('Noto Color Emoji')..addFont(
              emojiFont.readAsBytes().then((b) => ByteData.sublistView(b)),
            ))
            .load();
      }
      await (FontLoader('DavochainCurrency')..addFont(
            rootBundle.load(
              'assets/fonts/davochain_currency/DavochainCurrency-Regular.ttf',
            ),
          ))
          .load();
      await (FontLoader('Ahem')
            ..addFont(rootBundle.load('assets/fonts/sora/Sora-Variable.ttf')))
          .load();
      await (FontLoader('Sora')
            ..addFont(rootBundle.load('assets/fonts/sora/Sora-Variable.ttf')))
          .load();
      await (FontLoader('DavoNotoMath')..addFont(
            rootBundle.load('assets/fonts/noto/NotoSansMath-Regular.ttf'),
          ))
          .load();
      await (FontLoader(
            'DavoNotoSans',
          )..addFont(rootBundle.load('assets/fonts/noto/NotoSans-Regular.ttf')))
          .load();
      await (FontLoader(
        'MaterialIcons',
      )..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'))).load();
    });
    Future<void> capture(String name) async {
      final images = tester.widgetList<Image>(find.byType(Image)).toList();
      await tester.runAsync(
        () => Future.wait(
          images.map(
            (image) => precacheImage(image.image, key.currentContext!),
          ),
        ),
      );
      await tester.pump();
      await tester.runAsync(() async {
        final image =
            await (key.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary)
                .toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(
          '${directory.path}/$name.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }

    Future<void> mount(Widget screen, bool dark) async {
      await tester.pumpWidget(
        MaterialApp(
          key: UniqueKey(),
          theme: dark ? AppTheme.dark : AppTheme.light,
          builder: (context, child) => RepaintBoundary(key: key, child: child!),
          home: screen,
        ),
      );
      await tester.pumpAndSettle();
    }

    for (final dark in [false, true]) {
      final theme = dark ? 'dark' : 'light';
      WalletAccountState.instance.startSimulation(empty: false);
      for (final entry in <String, Widget>{
        'dashboard': const DavochainDashboardScreen(),
        'receiving': const NairaDepositScreen(),
        'withdraw': const NairaWithdrawScreen(),
        'buy': const BuyAmountScreen(
          initialOrder: BuyCryptoOrder(
            asset: BuyCryptoAsset.bitcoin,
            wallet: BuyFundingWallet.ngn,
            ngnAmount: '1000',
          ),
        ),
        'portfolio': const PortfolioScreen(),
        'internal-transfer': const CryptoWithdrawEntryScreen(external: false),
        'external-transfer': const CryptoWithdrawEntryScreen(external: true),
        'wallet-picker': const Scaffold(body: WalletPickerSheet()),
      }.entries) {
        await mount(entry.value, dark);
        expect(tester.takeException(), isNull, reason: '$theme-${entry.key}');
        await capture('$theme-${entry.key}');
        if (entry.key == 'portfolio') {
          await tester.drag(
            find.byType(CustomScrollView),
            const Offset(0, -1000),
          );
          await tester.pumpAndSettle();
          await capture('$theme-portfolio-search-pinned');
        }
      }
      for (final sheet in <String, Widget>{'crypto-modal': const BuyCryptoAssetSheet(), 'wallet-modal': const WalletPickerSheet()}.entries) {
        await mount(Scaffold(body: Builder(builder: (context) => TextButton(onPressed: () => showModalBottomSheet<void>(context: context, isScrollControlled: true, useSafeArea: true, backgroundColor: Colors.transparent, builder: (_) => sheet.value), child: const Text('Open selector')))), dark);
        await tester.tap(find.text('Open selector'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await capture('$theme-${sheet.key}');
      }
      tester.view.physicalSize = const Size(320, 568);
      await mount(
        const MediaQuery(
          data: MediaQueryData(
            size: Size(320, 568),
            textScaler: TextScaler.linear(2),
          ),
          child: PortfolioScreen(),
        ),
        dark,
      );
      expect(tester.takeException(), isNull);
      await capture('$theme-narrow-large-portfolio');
      await mount(
        const MediaQuery(
          data: MediaQueryData(
            size: Size(320, 568),
            textScaler: TextScaler.linear(2),
            viewInsets: EdgeInsets.only(bottom: 230),
          ),
          child: CryptoWithdrawEntryScreen(external: false),
        ),
        dark,
      );
      expect(tester.takeException(), isNull);
      await capture('$theme-narrow-large-transfer');
      tester.view.physicalSize = const Size(411, 914);
    }
    await tester.pumpWidget(const SizedBox());
  }, skip: !const bool.fromEnvironment('CAPTURE_ASSET_CATALOG'));
}
