import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../wallets/wallet_providers.dart';
import '../../wallets/wallet_repository.dart';

class AssetAllocation {
  const AssetAllocation(this.asset, this.minorUnits, this.percent);
  final String asset;
  final int minorUnits;
  final double percent;
}

class PortfolioViewState {
  PortfolioViewState.fromSnapshot(WalletSnapshot snapshot)
    : totalMinorUnits = snapshot.portfolioMinorUnits,
      allocation = List.unmodifiable(
        snapshot.assets
            .where(
              (a) =>
                  a != 'NGN' &&
                  a != 'NGD' &&
                  snapshot.available(a).atomicUnits > BigInt.zero,
            )
            .map(
              (a) => AssetAllocation(
                a,
                snapshot.valuationMinorUnits(a),
                snapshot.portfolioMinorUnits == 0
                    ? 0
                    : snapshot.valuationMinorUnits(a) *
                          100 /
                          snapshot.portfolioMinorUnits,
              ),
            ),
      );
  final int totalMinorUnits;
  final List<AssetAllocation> allocation;
}

final portfolioViewProvider = Provider<PortfolioViewState>(
  (ref) => PortfolioViewState.fromSnapshot(ref.watch(currentWalletProvider)),
);
