import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/core/money/money.dart';
import 'package:davochain/features/wallets/wallet_repository.dart';
import 'package:davochain/features/wallets/simulation_quotes.dart';
import 'package:davochain/features/wallets/asset_catalog_projection.dart';

WalletSnapshot fixture([Map<String, String> holdings = const {}]) =>
    WalletSnapshot(
      accountId: 'assets',
      version: 1,
      available: {
        for (final entry in SimulationQuotes.decimals.entries)
          entry.key: AssetAmount.parse(
            holdings[entry.key] ?? '0',
            entry.key,
            entry.value,
          ),
      },
      pricesMinorUnits: {
        ...SimulationQuotes.pricesMinorUnits,
        'BTC': 10000000,
        'ETH': 1000000,
        'ADA': 500,
        'USDT': 100,
        'USDC': 100,
      },
      usdNgnMinorUnits: 10000,
    );
void main() {
  test(
    'zero balances show all ten assets with popular then alphabetic order',
    () {
      expect(orderedCryptoAssets(fixture()).map((asset) => asset.symbol), [
        'USDT',
        'BTC',
        'ETH',
        'USDC',
        'SOL',
        'BNB',
        'ADA',
        'DOGE',
        'LTC',
        'XRP',
      ]);
    },
  );
  test(
    'funded holdings rank by exact shared-FX USD value before zero popular assets',
    () {
      final wallet = fixture({'ETH': '0.5', 'ADA': '100', 'BTC': '0.001'});
      expect(orderedCryptoAssets(wallet).take(5).map((asset) => asset.symbol), [
        'ETH',
        'ADA',
        'BTC',
        'USDT',
        'USDC',
      ]);
      expect(orderedCryptoAssets(wallet, limit: 5).length, 5);
    },
  );
  test(
    'equal funded values use popular order then deterministic name order',
    () {
      expect(
        orderedCryptoAssets(
          fixture({'BTC': '0.00001', 'USDT': '1'}),
        ).take(2).map((asset) => asset.symbol),
        ['USDT', 'BTC'],
      );
    },
  );
  test(
    'search includes zero balances by name or ticker without altering rank',
    () {
      expect(
        orderedCryptoAssets(fixture(), query: '  ethereum  ').single.symbol,
        'ETH',
      );
      expect(
        orderedCryptoAssets(
          fixture(),
          query: 'coin',
        ).map((asset) => asset.symbol),
        ['BTC', 'USDC', 'DOGE', 'LTC'],
      );
      expect(orderedCryptoAssets(fixture(), query: 'unknown'), isEmpty);
    },
  );
  test(
    'Home cap keeps the top five funded assets before every zero balance',
    () {
      final wallet = fixture({
        'BTC': '0.001',
        'ETH': '0.5',
        'ADA': '100',
        'USDT': '10',
        'USDC': '20',
        'DOGE': '100',
      });
      final top = orderedCryptoAssets(wallet, limit: 5);
      expect(top.length, 5);
      expect(
        top.every(
          (asset) => wallet.available(asset.symbol).atomicUnits > BigInt.zero,
        ),
        isTrue,
      );
    },
  );
}
