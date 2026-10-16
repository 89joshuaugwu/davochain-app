/// Indicative CoinGecko market observation, not an executable exchange quote.
/// Source: /simple/price, ids with vs_currencies=ngn,usd.
abstract final class SimulationQuotes {
  static const observedAtSeconds = 1792076868;
  static const pricesMinorUnits = <String, int>{
    'NGN': 100,
    'NGD': 100,
    'BTC': 10914795500,
    'ETH': 321731900,
    'SOL': 14053800,
    'USDT': 132884,
    'USDC': 132951,
    'XRP': 177239,
    'ADA': 30468,
    'DOGE': 10691,
    'LTC': 7974600,
    'BNB': 97197900,
  };
  static const usdNgnMinorUnits = 133004;
  static const decimals = <String, int>{
    'NGN': 2,
    'NGD': 2,
    'BTC': 8,
    'ETH': 8,
    'SOL': 9,
    'USDT': 6,
    'USDC': 6,
    'XRP': 6,
    'ADA': 6,
    'DOGE': 8,
    'LTC': 8,
    'BNB': 8,
  };
}
