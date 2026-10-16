import '../../wallets/simulation_quotes.dart';
import '../../wallets/wallet_repository.dart';
import 'package:flutter/material.dart';
import '../../../core/money/exact_decimal.dart';
import '../../../shared/formatters/grouped_amount_formatter.dart';

enum BuyCryptoAsset {
  bitcoin('Bitcoin', 'BTC', '₿', Color(0xFFF7931A), '24000000'),
  ethereum('Ethereum', 'ETH', '◆', Color(0xFF627EEA), '5200000'),
  solana('Solana', 'SOL', '≋', Color(0xFF090909), '265000'),
  tether('Tether', 'USDT', '₮', Color(0xFF009393), '1540'),
  usdCoin('USD Coin', 'USDC', r'$', Color(0xFF2775CA), '1540'),
  xrp('XRP', 'XRP', '', Color(0xFF23292F), null),
  cardano('Cardano', 'ADA', '', Color(0xFF0033AD), null),
  dogecoin('Dogecoin', 'DOGE', '', Color(0xFFC2A633), null),
  litecoin('Litecoin', 'LTC', '', Color(0xFF345D9D), null),
  bnb('BNB', 'BNB', '', Color(0xFFF3BA2F), null);

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
  final String? _ngnPrice;
  bool get hasQuote => WalletAccountState.instance.simulationEnabled
      ? WalletAccountState.instance.snapshot.priceMinorUnits(symbol) != null
      : _ngnPrice != null;
  ExactDecimal get ngnPrice => WalletAccountState.instance.simulationEnabled
      ? ExactDecimal.from(
          WalletAccountState.instance.snapshot.priceMinorUnits(symbol)!,
        ).divide(ExactDecimal.from(100))
      : ExactDecimal.parse(
          _ngnPrice ?? (throw StateError('No quote available for $symbol')),
        );
  double get ngnPerUnit => ngnPrice.toDouble();
  int get quantityDecimals => switch (this) {
    BuyCryptoAsset.solana => 9,
    BuyCryptoAsset.tether ||
    BuyCryptoAsset.usdCoin ||
    BuyCryptoAsset.xrp ||
    BuyCryptoAsset.cardano => 6,
    _ => 8,
  };
}

enum BuyFundingWallet {
  ngn,
  ngd;

  // Both legacy values resolve to the one customer wallet. New UI offers ngn only.
  String get name => 'Davochain Naira';
  String get symbol => 'NGN';
  bool get isDavochain => true;
  String get formattedBalance =>
      WalletAccountState.instance.balanceLabel(symbol);
  ExactDecimal get exactBalance => ExactDecimal.parse(
    WalletAccountState.instance.snapshot.available(symbol).decimal,
  );
  double get balance => exactBalance.toDouble();
  String get iconAsset => 'assets/images/brand/davochain_currency_mark.svg';
}

class BuyCryptoOrder {
  const BuyCryptoOrder({
    required this.asset,
    required this.wallet,
    required this._ngnAmount,
    this.quantityDecimals,
    this.lockedPriceMinorUnits,
    this.lockedUsdNgnMinorUnits,
    this.quoteId,
    this.quoteExpiresAt,
    this.accountId,
    this.accountGeneration,
  });
  final BuyCryptoAsset asset;
  final BuyFundingWallet wallet;
  final Object _ngnAmount;
  final int? quantityDecimals;
  final int? lockedPriceMinorUnits, lockedUsdNgnMinorUnits;
  final String? quoteId;
  final DateTime? quoteExpiresAt;
  final String? accountId;
  final int? accountGeneration;
  ExactDecimal get assetNgnPrice => lockedPriceMinorUnits == null
      ? asset.ngnPrice
      : ExactDecimal.from(
          lockedPriceMinorUnits!,
        ).divide(ExactDecimal.from(100));
  bool get quoteCurrent =>
      (accountId == null ||
          (accountId == WalletAccountState.instance.snapshot.accountId &&
              accountGeneration == WalletAccountState.instance.generation)) &&
      (quoteId == null ||
          ((WalletAccountState.instance.quoteId ??
                      'coingecko-${SimulationQuotes.observedAtSeconds}') ==
                  quoteId &&
              (quoteExpiresAt == null ||
                  DateTime.now().isBefore(quoteExpiresAt!))));
  BuyCryptoOrder freezeQuote() => BuyCryptoOrder(
    asset: asset,
    wallet: wallet,
    ngnAmount: exactNgnAmount,
    quantityDecimals: quantityDecimals,
    lockedPriceMinorUnits: WalletAccountState.instance.snapshot.priceMinorUnits(
      asset.symbol,
    ),
    lockedUsdNgnMinorUnits:
        WalletAccountState.instance.snapshot.usdNgnMinorUnits,
    quoteId:
        WalletAccountState.instance.quoteId ??
        'coingecko-${SimulationQuotes.observedAtSeconds}',
    quoteExpiresAt: WalletAccountState.instance.activeQuote?.expiresAt,
    accountId: WalletAccountState.instance.snapshot.accountId,
    accountGeneration: WalletAccountState.instance.generation,
  );

  ExactDecimal get exactNgnAmount => ExactDecimal.from(_ngnAmount);
  // Compatibility presentation adapters for existing numeric callers.
  double get ngnAmount => exactNgnAmount.toDouble();
  ExactDecimal get exactCryptoAmount => exactNgnAmount.divide(
    assetNgnPrice,
    scale: quantityDecimals ?? asset.quantityDecimals,
    rounding: DecimalRounding.floor,
  );
  double get cryptoAmount => exactCryptoAmount.toDouble();
  String get formattedCryptoAmount =>
      formatGroupedAmount(exactCryptoAmount.toString());

  String get formattedExchangeRate =>
      '1 ${asset.symbol} \u2248 \u20a6${formatGroupedAmount(assetNgnPrice.toFixed(2))}';
  ExactDecimal get exactUsdAmount => lockedUsdNgnMinorUnits == null
      ? usdEquivalentForNgn(exactNgnAmount)
      : exactNgnAmount.divide(
          ExactDecimal.from(
            lockedUsdNgnMinorUnits!,
          ).divide(ExactDecimal.from(100)),
        );
  double get usdAmount => exactUsdAmount.toDouble();
  static const double usdtNgnRate = 1540;
  BuyCryptoOrder copyWith({
    BuyCryptoAsset? asset,
    BuyFundingWallet? wallet,
    Object? ngnAmount,
    int? quantityDecimals,
  }) => BuyCryptoOrder(
    asset: asset ?? this.asset,
    wallet: wallet ?? this.wallet,
    lockedPriceMinorUnits: asset != null && asset != this.asset
        ? null
        : lockedPriceMinorUnits,
    lockedUsdNgnMinorUnits: lockedUsdNgnMinorUnits,
    quoteId: asset != null && asset != this.asset ? null : quoteId,
    quoteExpiresAt: quoteExpiresAt,
    accountId: accountId,
    accountGeneration: accountGeneration,
    ngnAmount: ngnAmount ?? exactNgnAmount,
    quantityDecimals:
        quantityDecimals ??
        (asset != null && asset != this.asset ? null : this.quantityDecimals),
  );
}

/// Shared indicative FX conversion for buy, sell and swap review.
ExactDecimal usdEquivalentForNgn(ExactDecimal amount) => amount.divide(
  WalletAccountState.instance.simulationEnabled
      ? ExactDecimal.from(
          WalletAccountState.instance.snapshot.usdNgnMinorUnits ??
              SimulationQuotes.usdNgnMinorUnits,
        ).divide(ExactDecimal.from(100))
      : ExactDecimal.parse('1463.08'),
);
