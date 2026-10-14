import '../../wallets/wallet_repository.dart';
import 'package:flutter/material.dart';
import '../../../shared/formatters/crypto_quantity_formatter.dart';
import '../../../shared/formatters/grouped_amount_formatter.dart';

enum BuyCryptoAsset {
  bitcoin('Bitcoin', 'BTC', '₿', Color(0xFFF7931A), 24000000),
  ethereum('Ethereum', 'ETH', '◆', Color(0xFF627EEA), 5200000),
  solana('Solana', 'SOL', '≋', Color(0xFF090909), 265000),
  tether('Tether', 'USDT', '₮', Color(0xFF009393), 1540);

  const BuyCryptoAsset(
    this.name,
    this.symbol,
    this.glyph,
    this.color,
    this.ngnPerUnit,
  );

  final String name;
  final String symbol;
  final String glyph;
  final Color color;
  final double ngnPerUnit;
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
  double get balance =>
      WalletAccountState.instance.snapshot
          .available(symbol)
          .atomicUnits
          .toDouble() /
      100;
  final bool isDavochain;

  String get iconAsset => isDavochain
      ? 'assets/images/brand/naira_coin.png'
      : 'assets/figma_exact/buy_nigeria.png';
}

class BuyCryptoOrder {
  const BuyCryptoOrder({
    required this.asset,
    required this.wallet,
    required this.ngnAmount,
  });

  final BuyCryptoAsset asset;
  final BuyFundingWallet wallet;
  final double ngnAmount;

  double get cryptoAmount => ngnAmount / asset.ngnPerUnit;
  String get formattedCryptoAmount {
    final rounded = cryptoAmount
        .toStringAsFixed(8)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
    final quantity = cryptoAmount != 0 && double.tryParse(rounded) == 0
        ? formatCryptoQuantity(cryptoAmount)
        : rounded;
    return formatGroupedAmount(quantity);
  }

  String get formattedExchangeRate =>
      '1 ${asset.symbol} \u2248 \u20a6${formatGroupedAmount(asset.ngnPerUnit.toStringAsFixed(2))}';
  double get usdAmount => ngnAmount / 1463.08;

  static const double usdtNgnRate = 1540;

  BuyCryptoOrder copyWith({
    BuyCryptoAsset? asset,
    BuyFundingWallet? wallet,
    double? ngnAmount,
  }) {
    return BuyCryptoOrder(
      asset: asset ?? this.asset,
      wallet: wallet ?? this.wallet,
      ngnAmount: ngnAmount ?? this.ngnAmount,
    );
  }
}
