import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/navigation/app_page_route.dart';
import 'buy_crypto_models.dart';
import 'buy_crypto_screens.dart';
import 'buy_crypto_widgets.dart';

Future<void> startBuyCryptoFlow(BuildContext context) async {
  HapticFeedback.selectionClick();
  final asset = await showModalBottomSheet<BuyCryptoAsset>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(.40),
    builder: (_) => const BuyCryptoAssetSheet(),
  );
  if (!context.mounted || asset == null) return;

  await Future<void>.delayed(const Duration(milliseconds: 110));
  if (!context.mounted) return;

  final wallet = await showModalBottomSheet<BuyFundingWallet>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(.40),
    builder: (_) => const BuyFundingWalletSheet(),
  );
  if (!context.mounted || wallet == null) return;

  await Navigator.of(context).push<void>(
    AppPageRoute<void>(
      builder: (_) => BuyAmountScreen(
        initialOrder: BuyCryptoOrder(asset: asset, wallet: wallet, ngnAmount: 0),
      ),
    ),
  );
}

