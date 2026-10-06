import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import 'buy_crypto_models.dart';

class BuyCryptoAssetSheet extends StatelessWidget {
  const BuyCryptoAssetSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return _BuySheetShell(
      title: 'Select Cryptocurrency',
      heightFactor: .46,
      child: Column(
        children: BuyCryptoAsset.values
            .map(
              (asset) => _SheetRow(
                leading: BuyAssetIcon(asset: asset, size: 37),
                title: asset.name,
                subtitle: asset.symbol,
                trailingTop: '0.00 USD',
                trailingBottom: '0.000000 ${asset.symbol}',
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.pop(context, asset);
                },
              ),
            )
            .toList(),
      ),
    );
  }
}

class BuyFundingWalletSheet extends StatelessWidget {
  const BuyFundingWalletSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return _BuySheetShell(
      title: 'Select wallet to buy from',
      heightFactor: .31,
      child: Column(
        children: BuyFundingWallet.values.map((wallet) {
          final leading = wallet.isDavochain
              ? Container(
                  width: 32,
                  height: 32,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                    child: Image.asset(
                      'assets/images/brand/davochain_logo.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              : const NigeriaFlagMark(width: 32);
          return _SheetRow(
            leading: leading,
            title: wallet.name,
            subtitle: wallet.symbol,
            trailingTop: wallet == BuyFundingWallet.ngn ? '1,124.38 USD' : '100.50 USD',
            trailingBottom: wallet == BuyFundingWallet.ngn ? wallet.formattedBalance : '135,000.00 ₦',
            onTap: () {
              HapticFeedback.selectionClick();
              Navigator.pop(context, wallet);
            },
          );
        }).toList(),
      ),
    );
  }
}

class _BuySheetShell extends StatelessWidget {
  const _BuySheetShell({
    required this.title,
    required this.heightFactor,
    required this.child,
  });

  final String title;
  final double heightFactor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: heightFactor,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFF8F9FB),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Column(
              children: [
                const SizedBox(height: 7),
                Container(
                  width: 85,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF686868),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                const SizedBox(height: 9),
                SizedBox(
                  height: 43,
                  child: Row(
                    children: [
                      const SizedBox(width: 40),
                      Expanded(
                        child: Center(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 14,
                              height: 1.35,
                              color: AppColors.ink,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, size: 25),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: child,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.trailingTop,
    required this.trailingBottom,
    required this.onTap,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final String trailingTop;
  final String trailingBottom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 63,
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFEBEDF3), width: .4)),
        ),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 14,
                      height: 1.35,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 12,
                      color: AppColors.body,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  trailingTop,
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    height: 1.35,
                    color: AppColors.body,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  trailingBottom,
                  style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 10,
                    color: AppColors.bodyMuted,
                  ),
                ),
              ],
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

  String get _assetPath => switch (asset) {
        BuyCryptoAsset.bitcoin => 'assets/images/figma/btc.png',
        BuyCryptoAsset.ethereum => 'assets/images/figma/eth.png',
        BuyCryptoAsset.solana => 'assets/images/figma/sol.png',
        BuyCryptoAsset.tether => 'assets/images/figma/usdt.png',
      };

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        _assetPath,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class NigeriaFlagMark extends StatelessWidget {
  const NigeriaFlagMark({super.key, this.width = 32});
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width * .56,
      child: Image.asset(
        'assets/icons/auth/ng_flag.png',
        fit: BoxFit.fill,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
