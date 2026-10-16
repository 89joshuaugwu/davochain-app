import 'package:flutter/material.dart';

import '../../../core/navigation/app_page_route.dart';
import 'buy_crypto_models.dart';
import 'buy_crypto_screens.dart';
import 'buy_crypto_widgets.dart';

Future<void> startBuyCryptoFlow(BuildContext context) async {
  final asset = await showModalBottomSheet<BuyCryptoAsset>(
    context: context,
    sheetAnimationStyle:
        (MediaQuery.disableAnimationsOf(context) ||
            MediaQuery.accessibleNavigationOf(context))
        ? AnimationStyle.noAnimation
        : const AnimationStyle(
            duration: Duration(milliseconds: 280),
            reverseDuration: Duration(milliseconds: 200),
          ),
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: .32),
    builder: (_) => const BuyCryptoAssetSheet(),
  );
  if (!context.mounted || asset == null) return;

  const wallet = BuyFundingWallet.ngn;

  await Navigator.of(context).push<void>(
    AppPageRoute<void>(
      builder: (_) => BuyAmountScreen(
        initialOrder: BuyCryptoOrder(
          asset: asset,
          wallet: wallet,
          ngnAmount: 0,
        ),
      ),
    ),
  );
}
