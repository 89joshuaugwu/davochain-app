import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/davo_sheet_header.dart';
import '../../../shared/widgets/davo_naira_amount.dart';
import '../../buy_crypto/presentation/buy_crypto_models.dart';
import '../../buy_crypto/presentation/buy_crypto_widgets.dart'
    show BuyAssetIcon;
import '../asset_catalog_projection.dart';
import '../wallet_repository.dart';

const networkWalletSymbols = {'BTC', 'ETH', 'SOL', 'USDT', 'USDC'};

/// Returns a symbol. Catalog availability does not imply an issued network wallet.
class WalletPickerSheet extends StatefulWidget {
  const WalletPickerSheet({
    super.key,
    this.includeCash = true,
    this.networkOnly = false,
    this.title = 'Select Wallet',
    this.unavailableLabel = 'Network receiving unavailable',
  });
  final bool includeCash, networkOnly;
  final String title, unavailableLabel;
  @override
  State<WalletPickerSheet> createState() => _WalletPickerSheetState();
}

class _WalletPickerSheetState extends State<WalletPickerSheet> {
  String query = '';
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: WalletAccountState.instance,
    builder: (context, _) => _buildPicker(context),
  );

  Widget _buildPicker(BuildContext context) {
    final wallet = WalletAccountState.instance;
    final assets = orderedCryptoAssets(wallet.snapshot, query: query);
    final cash =
        widget.includeCash &&
        'davochain naira ngn'.contains(query.trim().toLowerCase());
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: 540,
        child: Material(
          color: DavoColors.of(context).sheetSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: DavoColors.of(context).border,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                DavoSheetHeader(title: widget.title),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: TextField(
                    key: const ValueKey('wallet-search'),
                    onChanged: (value) => setState(() => query = value),
                    textInputAction: TextInputAction.search,
                    decoration: const InputDecoration(
                      hintText: 'Search wallets',
                      prefixIcon: Icon(Icons.search_rounded),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      if (cash) _row(context, 'NGN', 'Davochain Naira', null),
                      for (final asset in assets)
                        _row(context, asset.symbol, asset.name, asset),
                      if (!cash && assets.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'No matching wallets. Try another name or symbol.',
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    String symbol,
    String name,
    BuyCryptoAsset? asset,
  ) {
    final wallet = WalletAccountState.instance;
    final supported =
        !widget.networkOnly ||
        asset == null ||
        networkWalletSymbols.contains(symbol);
    final quantity = wallet.snapshot.assets.contains(symbol)
        ? wallet.snapshot.available(symbol).decimal
        : '0';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey('wallet-option-$symbol'),
        onTap: supported
            ? () {
                FocusScope.of(context).unfocus();
                Navigator.pop(context, symbol);
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  asset == null
                      ? DavoCurrencyMark(
                          size: 36,
                          color: DavoColors.of(context).link,
                        )
                      : BuyAssetIcon(asset: asset, size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          asset == null ? 'Cash wallet' : symbol,
                          style: TextStyle(
                            fontSize: 12,
                            color: DavoColors.of(context).bodyMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    flex: 4,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: asset == null
                          ? DavoNairaAmount(
                              minorUnits: wallet.ngnAvailableMinorUnits,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          : Text(
                              '$quantity $symbol',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: DavoColors.of(context).bodyMuted,
                  ),
                ],
              ),
              if (!supported)
                Padding(
                  padding: const EdgeInsets.only(left: 48, top: 8),
                  child: Text(
                    widget.unavailableLabel,
                    style: TextStyle(
                      fontSize: 11,
                      color: DavoColors.of(context).bodyMuted,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
