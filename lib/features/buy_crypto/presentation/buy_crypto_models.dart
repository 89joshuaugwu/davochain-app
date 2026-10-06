import 'package:flutter/material.dart';

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
    '₦1,731,540.00',
    1731540,
    false,
  ),
  ngd(
    'Davochain Naira',
    'NGD',
    '₦135,000.00',
    135000,
    true,
  );

  const BuyFundingWallet(
    this.name,
    this.symbol,
    this.formattedBalance,
    this.balance,
    this.isDavochain,
  );

  final String name;
  final String symbol;
  final String formattedBalance;
  final double balance;
  final bool isDavochain;
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

