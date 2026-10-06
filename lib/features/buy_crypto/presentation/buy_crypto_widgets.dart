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
              : const NigeriaFlagCircle(size: 32);
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: asset.color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: asset.color.withValues(alpha: .18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: switch (asset) {
        BuyCryptoAsset.ethereum => CustomPaint(
            size: Size(size * .48, size * .57),
            painter: const _EthereumPainter(),
          ),
        BuyCryptoAsset.solana => CustomPaint(
            size: Size(size * .55, size * .45),
            painter: const _SolanaPainter(),
          ),
        _ => Text(
            asset.glyph,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: size * .52,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              height: 1,
            ),
          ),
      },
    );
  }
}

class NigeriaFlagCircle extends StatelessWidget {
  const NigeriaFlagCircle({super.key, this.size = 32});
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: const Row(
          children: [
            Expanded(child: ColoredBox(color: Color(0xFF008751))),
            Expanded(child: ColoredBox(color: Colors.white)),
            Expanded(child: ColoredBox(color: Color(0xFF008751))),
          ],
        ),
      ),
    );
  }
}

class _EthereumPainter extends CustomPainter {
  const _EthereumPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final center = Offset(size.width / 2, size.height / 2);
    final top = Offset(center.dx, 0);
    final left = Offset(0, center.dy * .94);
    final right = Offset(size.width, center.dy * .94);
    final mid = Offset(center.dx, center.dy * 1.08);
    final bottom = Offset(center.dx, size.height);
    canvas.drawPath(Path()..moveTo(top.dx, top.dy)..lineTo(left.dx, left.dy)..lineTo(mid.dx, mid.dy)..close(), paint..color = Colors.white.withValues(alpha: .88));
    canvas.drawPath(Path()..moveTo(top.dx, top.dy)..lineTo(right.dx, right.dy)..lineTo(mid.dx, mid.dy)..close(), paint..color = Colors.white);
    canvas.drawPath(Path()..moveTo(left.dx, center.dy * 1.05)..lineTo(mid.dx, center.dy * 1.20)..lineTo(bottom.dx, bottom.dy)..close(), paint..color = Colors.white.withValues(alpha: .75));
    canvas.drawPath(Path()..moveTo(right.dx, center.dy * 1.05)..lineTo(mid.dx, center.dy * 1.20)..lineTo(bottom.dx, bottom.dy)..close(), paint..color = Colors.white.withValues(alpha: .95));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SolanaPainter extends CustomPainter {
  const _SolanaPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF6CFFDF);
    final h = size.height / 5;
    for (var i = 0; i < 3; i++) {
      final y = i * h * 1.65;
      final path = Path()
        ..moveTo(size.width * .16, y)
        ..lineTo(size.width, y)
        ..lineTo(size.width * .84, y + h)
        ..lineTo(0, y + h)
        ..close();
      canvas.drawPath(path, paint..color = i == 1 ? const Color(0xFF7C5CFF) : const Color(0xFF6CFFDF));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
