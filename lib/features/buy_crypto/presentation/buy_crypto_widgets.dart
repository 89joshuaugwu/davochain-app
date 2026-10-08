import '../../../shared/widgets/solana_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import 'buy_crypto_models.dart';

class BuyCryptoAssetSheet extends StatelessWidget {
  const BuyCryptoAssetSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 351,
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 6,
            child: Center(
              child: Container(
                width: 85,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF686868),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            top: 32,
            child: Text(
              'Select Cryptocurrency',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 14,
                  height: 1.35,
                  color: AppColors.ink),
            ),
          ),
          Positioned(
            left: 342,
            top: 20,
            width: 24,
            height: 24,
            child: InkResponse(
              onTap: () => Navigator.pop(context),
              radius: 20,
              child: Image.asset('assets/figma_exact/buy_close.png',
                  width: 24, height: 24),
            ),
          ),
          ...List.generate(BuyCryptoAsset.values.length, (index) {
            final asset = BuyCryptoAsset.values[index];
            return Positioned(
              left: 16,
              right: 16,
              top: 67.0 + (index * 63.0),
              height: 55,
              child: _ExactAssetSheetRow(
                asset: asset,
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.pop(context, asset);
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class BuyFundingWalletSheet extends StatelessWidget {
  const BuyFundingWalletSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 242,
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 6,
            child: Center(
              child: Container(
                width: 85,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF686868),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            top: 32,
            child: Text(
              'Select wallet to buy from',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 14,
                  height: 1.35,
                  color: AppColors.ink),
            ),
          ),
          Positioned(
            left: 342,
            top: 20,
            width: 24,
            height: 24,
            child: InkResponse(
              onTap: () => Navigator.pop(context),
              radius: 20,
              child: Image.asset('assets/figma_exact/buy_close.png',
                  width: 24, height: 24),
            ),
          ),
          ...List.generate(BuyFundingWallet.values.length, (index) {
            final wallet = BuyFundingWallet.values[index];
            return Positioned(
              left: 16,
              right: 16,
              top: index == 0 ? 67 : 138,
              height: 55,
              child: _ExactWalletSheetRow(
                wallet: wallet,
                onTap: () {
                  HapticFeedback.selectionClick();
                  Navigator.pop(context, wallet);
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ExactAssetSheetRow extends StatelessWidget {
  const _ExactAssetSheetRow({required this.asset, required this.onTap});
  final BuyCryptoAsset asset;
  final VoidCallback onTap;

  String get _bottom => switch (asset) {
        BuyCryptoAsset.tether => '0.000000 USDT',
        _ => '0.00000000 ${asset.symbol}',
      };

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 55,
          child: Stack(
            children: [
              Positioned(
                  left: 0,
                  top: 7,
                  width: 37,
                  height: 37,
                  child: BuyAssetIcon(asset: asset, size: 37)),
              Positioned(
                  left: 49,
                  top: 7.5,
                  child: Text(asset.name,
                      style: const TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 14,
                          height: 1.35,
                          color: AppColors.ink))),
              Positioned(
                  left: 49,
                  top: 28.5,
                  child: Text(asset.symbol,
                      style: const TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 12,
                          height: 1.25,
                          color: AppColors.body))),
              const Positioned(
                  right: 0,
                  top: 8.5,
                  child: Text('0.00 USD',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 14,
                          height: 1.35,
                          color: AppColors.body))),
              Positioned(
                  right: 0,
                  top: 29.5,
                  child: Text(_bottom,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 10,
                          height: 1.3,
                          color: AppColors.bodyMuted))),
            ],
          ),
        ),
      );
}

class _ExactWalletSheetRow extends StatelessWidget {
  const _ExactWalletSheetRow({required this.wallet, required this.onTap});
  final BuyFundingWallet wallet;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 55,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 7,
                width: 32,
                height: 32,
                child: Image.asset(wallet.iconAsset,
                    width: 32, height: 32, fit: BoxFit.contain),
              ),
              Positioned(
                  left: 44,
                  top: 7,
                  child: Text(wallet.name,
                      style: const TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 14,
                          height: 1.35,
                          color: AppColors.ink))),
              Positioned(
                  left: 44,
                  top: 28,
                  child: Text(wallet.symbol,
                      style: const TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 12,
                          height: 1.25,
                          color: AppColors.body))),
              Positioned(
                right: 0,
                top: 8,
                child: Text(
                    wallet == BuyFundingWallet.ngn ? '0.00 USD' : '100.50 USD',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 14,
                        height: 1.35,
                        color: AppColors.body)),
              ),
              Positioned(
                right: 0,
                top: 29,
                child: Text(
                    wallet == BuyFundingWallet.ngn ? '0.00₦' : '135,000.00 ₦',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 10,
                        height: 1.3,
                        color: AppColors.bodyMuted)),
              ),
            ],
          ),
        ),
      );
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
