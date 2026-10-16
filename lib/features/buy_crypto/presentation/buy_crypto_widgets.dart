import '../../wallets/asset_catalog_projection.dart';
import '../../../shared/widgets/davo_naira_amount.dart';
import 'dart:math' as math;
import 'package:flutter_svg/flutter_svg.dart';
import '../../../shared/widgets/davo_safe_selection_sheet.dart';
import '../../../core/theme/davo_colors.dart';
import '../../../shared/widgets/davo_sheet_header.dart';
import '../../../shared/widgets/solana_icon.dart';
import '../../wallets/wallet_repository.dart';
import 'package:flutter/material.dart';
import 'buy_crypto_models.dart';

class BuyCryptoAssetSheet extends StatefulWidget {
  const BuyCryptoAssetSheet({
    super.key,
    this.fundedOnly = false,
    this.excluded,
  });
  final bool fundedOnly;
  final BuyCryptoAsset? excluded;
  @override
  State<BuyCryptoAssetSheet> createState() => _BuyCryptoAssetSheetState();
}

class _BuyCryptoAssetSheetState extends State<BuyCryptoAssetSheet> {
  String _query = '';
  @override
  Widget build(BuildContext context) {
    final assets = orderedCryptoAssets(
      WalletAccountState.instance.snapshot,
      query: _query,
      fundedOnly: widget.fundedOnly,
      excluded: widget.excluded,
    );
    return _SelectionBody(
      title: 'Select Cryptocurrency',
      stableHeight: true,
      children: [
        TextField(
          key: const ValueKey('asset-search'),
          onChanged: (value) =>
              setState(() => _query = value.trim().toLowerCase()),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            filled: true,
            fillColor: DavoColors.of(context).sheetField,
            hintText: 'Search name or symbol',
            prefixIcon: const Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 12),
        if (assets.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              widget.fundedOnly && _query.isEmpty
                  ? 'No funded crypto yet. Buy crypto with Davochain Naira to get started.'
                  : 'No matching assets. Try another name or symbol.',
              style: TextStyle(color: DavoColors.of(context).body),
            ),
          ),
        ...assets.map(
          (asset) => _SelectionRow(
            icon: BuyAssetIcon(asset: asset, size: 37),
            name: asset.name,
            symbol: asset.symbol,
            value:
                WalletAccountState.instance.snapshot.assets.contains(
                  asset.symbol,
                )
                ? '${WalletAccountState.instance.snapshot.available(asset.symbol).decimal} ${asset.symbol}'
                : '0 ${asset.symbol}',
            quantity: '',
            onTap:
                !asset.hasQuote ||
                    !WalletAccountState.instance.snapshot.assets.contains(
                      asset.symbol,
                    )
                ? null
                : () {
                    FocusScope.of(context).unfocus();
                    Navigator.pop(context, asset);
                  },
          ),
        ),
      ],
    );
  }
}

class BuyFundingWalletSheet extends StatelessWidget {
  const BuyFundingWalletSheet({super.key});
  @override
  Widget build(BuildContext context) => _SelectionBody(
    title: 'Select wallet to buy from',
    children: const [BuyFundingWallet.ngn]
        .map(
          (wallet) => _SelectionRow(
            icon: wallet.isDavochain
                ? DavoCurrencyMark(size: 32, color: DavoColors.of(context).link)
                : Image.asset(wallet.iconAsset, width: 32, height: 32),
            name: wallet.name,
            symbol: wallet.symbol,
            value: wallet.formattedBalance,
            valueWidget: wallet.isDavochain
                ? DavoNairaAmount(
                    minorUnits: WalletAccountState.instance.snapshot
                        .available(wallet.symbol)
                        .atomicUnits
                        .toInt(),
                    style: TextStyle(
                      fontSize: 14,
                      color: DavoColors.of(context).body,
                    ),
                  )
                : null,
            quantity: wallet.symbol,
            onTap: () => Navigator.pop(context, wallet),
          ),
        )
        .toList(),
  );
}

class _SelectionBody extends StatelessWidget {
  const _SelectionBody({
    required this.title,
    required this.children,
    this.stableHeight = false,
  });
  final bool stableHeight;
  final String title;
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final content = Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          mainAxisSize: stableHeight ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Container(
              width: 85,
              height: 4,
              decoration: BoxDecoration(
                color: DavoColors.of(context).bodyMuted,
                borderRadius: BorderRadius.circular(100),
              ),
            ),
            const SizedBox(height: 12),
            DavoSheetHeader(title: title),
            const SizedBox(height: 16),
            if (stableHeight)
              Expanded(
                child: ListView(padding: EdgeInsets.zero, children: children),
              )
            else
              ...children,
          ],
        ),
      );
      final available = math.max(
        0.0,
        constraints.maxHeight -
            MediaQuery.viewInsetsOf(context).bottom -
            MediaQuery.paddingOf(context).bottom,
      );
      return DavoSafeSelectionSheet(
        child: Material(
          color: DavoColors.of(context).sheetSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: stableHeight
              ? SizedBox(
                  key: const ValueKey('asset-sheet-body'),
                  height: math.min(540.0, available),
                  child: content,
                )
              : content,
        ),
      );
    },
  );
}

class _SelectionRow extends StatelessWidget {
  const _SelectionRow({
    required this.icon,
    required this.name,
    required this.symbol,
    required this.value,
    required this.quantity,
    this.valueWidget,
    required this.onTap,
  });
  final Widget icon;
  final Widget? valueWidget;
  final String name, symbol, value, quantity;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final colors = DavoColors.of(context);
    final compact =
        MediaQuery.textScalerOf(context).scale(14) > 20 ||
        MediaQuery.sizeOf(context).width < 350;
    final identity = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: TextStyle(fontFamily: 'Sora', fontSize: 14, color: colors.ink),
        ),
        const SizedBox(height: 4),
        Text(symbol, style: TextStyle(fontSize: 12, color: colors.body)),
      ],
    );
    final amounts = Column(
      crossAxisAlignment: compact
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.end,
      children: [
        valueWidget ??
            Text(value, style: TextStyle(fontSize: 14, color: colors.body)),
        if (quantity.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            quantity,
            style: TextStyle(fontSize: 12, color: colors.bodyMuted),
          ),
        ],
      ],
    );
    return InkWell(
      key: ValueKey('crypto-option-$symbol'),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Expanded(
              child: compact
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [identity, const SizedBox(height: 8), amounts],
                    )
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: identity),
                        const SizedBox(width: 12),
                        Expanded(child: amounts),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class BuyAssetIcon extends StatelessWidget {
  const BuyAssetIcon({super.key, required this.asset, this.size = 40});

  final BuyCryptoAsset asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (asset == BuyCryptoAsset.solana) return SolanaIcon(size: size);
    return SvgPicture.asset(
      'assets/icons/crypto/${asset.symbol.toLowerCase()}.svg',
      width: size,
      height: size,
    );
  }
}

class NairaCoinMark extends StatelessWidget {
  const NairaCoinMark({super.key, this.width = 32});
  final double width;
  @override
  Widget build(BuildContext context) =>
      DavoCurrencyMark(size: width, color: DavoColors.of(context).link);
}
