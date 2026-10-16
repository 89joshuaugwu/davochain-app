import 'wallet_repository.dart';

/// A customer wallet identity, denominated in NGN rather than a second token.
class DavochainNairaWallet {
  const DavochainNairaWallet(this.snapshot);
  static const id = 'davochain_naira';
  static const currency = 'NGN';
  static const name = 'Davochain Naira';
  final WalletSnapshot snapshot;
  int get availableMinorUnits =>
      snapshot.available(currency).atomicUnits.toInt();
  String get formattedBalance =>
      WalletAccountState.formatFiat(availableMinorUnits);
}

String canonicalWalletAsset(String asset) =>
    asset == 'NGD' ? DavochainNairaWallet.currency : asset;
