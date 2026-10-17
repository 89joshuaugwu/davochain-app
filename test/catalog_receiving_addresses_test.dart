import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/buy_crypto/presentation/buy_crypto_models.dart';
import 'package:davochain/features/dashboard/presentation/dashboard_screen.dart';
import 'package:davochain/features/wallets/simulation_crypto_addresses.dart';
import 'package:davochain/shared/widgets/davo_address_qr.dart';

void main() {
  test('every catalog asset has a unique test receiving destination', () {
    final destinations = SimulationCryptoAddress.bySymbol;
    expect(
      destinations.keys.toSet(),
      BuyCryptoAsset.values.map((a) => a.symbol).toSet(),
    );
    expect(
      CryptoAsset.values.map((a) => a.symbol).toSet(),
      destinations.keys.toSet(),
    );
    expect(
      destinations.values.map((d) => d.address).toSet().length,
      destinations.length,
    );
    expect(destinations['XRP']!.destinationTag, isNotNull);
  });
  for (final asset in CryptoAsset.values) {
    testWidgets('${asset.symbol} QR and clipboard use the same test address', (
      tester,
    ) async {
      final destination = SimulationCryptoAddress.bySymbol[asset.symbol]!;
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: CryptoDepositScreen(asset: asset),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Network: ${destination.network}'), findsOneWidget);
      expect(
        find.text('Test address only. Do not send real funds.'),
        findsOneWidget,
      );
      expect(
        tester.widget<DavoAddressQr>(find.byType(DavoAddressQr)).data,
        destination.address,
      );
      await tester.tap(find.text('Copy Address'));
      await tester.pump();
      expect(copied, destination.address);
      if (destination.destinationTag != null) {
        await tester.ensureVisible(find.byTooltip('Copy destination tag'));
        await tester.tap(find.byTooltip('Copy destination tag'));
        await tester.pump();
        expect(copied, destination.destinationTag);
      }
      expect(tester.takeException(), isNull);
    });
  }
}
