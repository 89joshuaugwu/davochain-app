import '../../../shared/widgets/davo_safe_selection_sheet.dart';
import '../../../core/theme/davo_colors.dart';
import '../../../shared/widgets/davo_sheet_header.dart';
import '../../../shared/widgets/solana_icon.dart';
import '../../wallets/wallet_repository.dart';
import 'package:flutter/material.dart';
import 'buy_crypto_models.dart';

class BuyCryptoAssetSheet extends StatefulWidget {
  const BuyCryptoAssetSheet({super.key});
  @override
  State<BuyCryptoAssetSheet> createState() => _BuyCryptoAssetSheetState();
}

class _BuyCryptoAssetSheetState extends State<BuyCryptoAssetSheet> {
  String _query = '';
  @override
  Widget build(BuildContext context) {
    final assets = BuyCryptoAsset.values
        .where((asset) =>
            asset.name.toLowerCase().contains(_query) ||
            asset.symbol.toLowerCase().contains(_query))
        .toList();
    return _SelectionBody(title: 'Select Cryptocurrency', children: [
      TextField(
          key: const ValueKey('asset-search'),
          onChanged: (value) =>
              setState(() => _query = value.trim().toLowerCase()),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
              filled: true,
              fillColor: DavoColors.of(context).sheetField,
              hintText: 'Search name or symbol',
              prefixIcon: const Icon(Icons.search_rounded))),
      const SizedBox(height: 12),
      if (assets.isEmpty)
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text('No matching assets. Try another name or symbol.',
                style: TextStyle(color: DavoColors.of(context).body))),
      ...assets.map((asset) => _SelectionRow(
          icon: BuyAssetIcon(asset: asset, size: 37),
          name: asset.name,
          symbol: asset.symbol,
          value: WalletAccountState.instance.balanceLabel(asset.symbol),
          quantity:
              '${WalletAccountState.instance.snapshot.available(asset.symbol).decimal} ${asset.symbol}',
          onTap: () {
            FocusScope.of(context).unfocus();
            Navigator.pop(context, asset);
          })),
    ]);
  }
}

class BuyFundingWalletSheet extends StatelessWidget {
  const BuyFundingWalletSheet({super.key});
  @override
  Widget build(BuildContext context) => _SelectionBody(
      title: 'Select wallet to buy from',
      children: BuyFundingWallet.values
          .map((wallet) => _SelectionRow(
              icon: Image.asset(wallet.iconAsset, width: 32, height: 32),
              name: wallet.name,
              symbol: wallet.symbol,
              value: wallet.formattedBalance,
              quantity: wallet.symbol,
              onTap: () => Navigator.pop(context, wallet)))
          .toList());
}

class _SelectionBody extends StatelessWidget {
  const _SelectionBody({required this.title, required this.children});
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => DavoSafeSelectionSheet(
      child: Material(
          color: DavoColors.of(context).sheetSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                    width: 85,
                    height: 4,
                    decoration: BoxDecoration(
                        color: DavoColors.of(context).bodyMuted,
                        borderRadius: BorderRadius.circular(100))),
                const SizedBox(height: 12),
                DavoSheetHeader(title: title),
                const SizedBox(height: 16),
                ...children,
              ]))));
}

class _SelectionRow extends StatelessWidget {
  const _SelectionRow(
      {required this.icon,
      required this.name,
      required this.symbol,
      required this.value,
      required this.quantity,
      required this.onTap});
  final Widget icon;
  final String name, symbol, value, quantity;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final colors = DavoColors.of(context);
    final compact = MediaQuery.textScalerOf(context).scale(14) > 20 ||
        MediaQuery.sizeOf(context).width < 350;
    final identity =
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(name,
          style:
              TextStyle(fontFamily: 'Sora', fontSize: 14, color: colors.ink)),
      const SizedBox(height: 4),
      Text(symbol, style: TextStyle(fontSize: 12, color: colors.body)),
    ]);
    final amounts = Column(
        crossAxisAlignment:
            compact ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(value, style: TextStyle(fontSize: 14, color: colors.body)),
          const SizedBox(height: 4),
          Text(quantity,
              style: TextStyle(fontSize: 12, color: colors.bodyMuted)),
        ]);
    return InkWell(
        onTap: onTap,
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              icon,
              const SizedBox(width: 12),
              Expanded(
                  child: compact
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              identity,
                              const SizedBox(height: 8),
                              amounts
                            ])
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                              Expanded(child: identity),
                              const SizedBox(width: 12),
                              Expanded(child: amounts)
                            ])),
            ])));
  }
}

class BuyAssetIcon extends StatelessWidget {
  const BuyAssetIcon({super.key, required this.asset, this.size = 40});

  final BuyCryptoAsset asset;
  final double size;

  String get _assetPath => switch (asset) {
        BuyCryptoAsset.bitcoin => 'assets/figma_exact/btc.png',
        BuyCryptoAsset.ethereum => 'assets/figma_exact/eth.png',
        BuyCryptoAsset.solana => 'assets/figma_exact/sol.png',
        BuyCryptoAsset.tether => 'assets/figma_exact/usdt.png',
      };

  @override
  Widget build(BuildContext context) {
    if (asset == BuyCryptoAsset.solana) return SolanaIcon(size: size);
    final visualSize = switch (asset) {
      BuyCryptoAsset.bitcoin => size * (36 / 37),
      BuyCryptoAsset.ethereum => size,
      BuyCryptoAsset.solana => size,
      BuyCryptoAsset.tether => size * (28 / 37),
    };
    return SizedBox(
      width: size,
      height: size,
      child: Center(
        child: Image.asset(
          _assetPath,
          width: visualSize,
          height: visualSize,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}

class NairaCoinMark extends StatelessWidget {
  const NairaCoinMark({super.key, this.width = 32});
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width,
      child: Image.asset(
        'assets/images/brand/naira_coin.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
