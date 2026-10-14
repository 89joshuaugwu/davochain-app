import '../../wallets/wallet_repository.dart';
import 'package:flutter/material.dart';
import '../../../core/money/exact_decimal.dart';
import '../../../shared/formatters/grouped_amount_formatter.dart';

enum BuyCryptoAsset {
  bitcoin('Bitcoin', 'BTC', '₿', Color(0xFFF7931A), '24000000'),
  ethereum('Ethereum', 'ETH', '◆', Color(0xFF627EEA), '5200000'),
  solana('Solana', 'SOL', '≋', Color(0xFF090909), '265000'),
  tether('Tether', 'USDT', '₮', Color(0xFF009393), '1540');

  const BuyCryptoAsset(
    this.name,
    this.symbol,
    this.glyph,
    this.color,
    this._ngnPrice,
  );

  final String name;
  final String symbol;
  final String glyph;
  final Color color;
  final String _ngnPrice;
  ExactDecimal get ngnPrice => ExactDecimal.parse(_ngnPrice);
  double get ngnPerUnit => ngnPrice.toDouble();
  int get quantityDecimals => switch (this) {
        BuyCryptoAsset.solana => 9,
        BuyCryptoAsset.tether => 6,
        _ => 8,
      };
}

enum BuyFundingWallet {
  ngn(
    'Nigerian Naira',
    'NGN',
    false,
  ),
  ngd(
    'Davochain Naira',
    'NGD',
    true,
  );

  const BuyFundingWallet(
    this.name,
    this.symbol,
    this.isDavochain,
  );

  final String name;
  final String symbol;
  String get formattedBalance =>
      WalletAccountState.instance.balanceLabel(symbol);
  ExactDecimal get exactBalance => ExactDecimal.parse(
      WalletAccountState.instance.snapshot.available(symbol).decimal);
  double get balance => exactBalance.toDouble();
  final bool isDavochain;

  String get iconAsset => isDavochain
      ? 'assets/images/brand/naira_coin.png'
      : 'assets/figma_exact/buy_nigeria.png';
}

class BuyCryptoOrder {
  const BuyCryptoOrder(
      {required this.asset,
      required this.wallet,
      required Object ngnAmount,
      this.quantityDecimals})
      : _ngnAmount = ngnAmount;
  final BuyCryptoAsset asset;
  final BuyFundingWallet wallet;
  final Object _ngnAmount;
  final int? quantityDecimals;
  ExactDecimal get exactNgnAmount => ExactDecimal.from(_ngnAmount);
  // Compatibility presentation adapters for existing numeric callers.
  double get ngnAmount => exactNgnAmount.toDouble();
  ExactDecimal get exactCryptoAmount => exactNgnAmount.divide(asset.ngnPrice,
      scale: quantityDecimals ?? asset.quantityDecimals,
      rounding: DecimalRounding.floor);
  double get cryptoAmount => exactCryptoAmount.toDouble();
  String get formattedCryptoAmount =>
      formatGroupedAmount(exactCryptoAmount.toString());

  String get formattedExchangeRate =>
      '1 ${asset.symbol} \u2248 \u20a6${formatGroupedAmount(asset.ngnPrice.toFixed(2))}';
  ExactDecimal get exactUsdAmount =>
      exactNgnAmount.divide(ExactDecimal.parse('1463.08'));
  double get usdAmount => exactUsdAmount.toDouble();
  static const double usdtNgnRate = 1540;
  BuyCryptoOrder copyWith(
          {BuyCryptoAsset? asset,
          BuyFundingWallet? wallet,
          Object? ngnAmount,
          int? quantityDecimals}) =>
      BuyCryptoOrder(
          asset: asset ?? this.asset,
          wallet: wallet ?? this.wallet,
          ngnAmount: ngnAmount ?? exactNgnAmount,
          quantityDecimals: quantityDecimals ??
              (asset != null && asset != this.asset
                  ? null
                  : this.quantityDecimals));
}
