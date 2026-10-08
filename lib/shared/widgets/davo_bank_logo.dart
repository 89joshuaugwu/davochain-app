import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Bank artwork supplied by the design or downloaded from the bank itself.
/// Unavailable logos use an initial, without imitating a bank's branding.
class DavoBankLogo extends StatelessWidget {
  const DavoBankLogo({super.key, required this.bankName, this.size = 36});

  final String bankName;
  final double size;

  String? get _asset => switch (bankName.toLowerCase().trim()) {
    'access bank' || 'access' => 'assets/figma_exact/bank_access_exact.png',
    'gtbank' || 'gt bank' || 'guaranty trust bank' =>
      'assets/figma_exact/bank_gtbank_exact.png',
    'opay' || 'opay bank' => 'assets/figma_exact/bank_opay_exact.png',
    'kuda' || 'kuda bank' || 'kuda microfinance bank' =>
      'assets/images/banks/kuda.png',
    _ => null,
  };

  @override
  Widget build(BuildContext context) {
    final asset = _asset;
    final fallback = Center(
      child: Text(
        bankName.trim().isEmpty ? '?' : bankName.trim()[0].toUpperCase(),
        style: TextStyle(
          fontFamily: 'Sora', fontSize: size * .42,
          fontWeight: FontWeight.w600, color: DavoColors.of(context).bodyMuted,
        ),
      ),
    );
    return ExcludeSemantics(
      child: Container(
        width: size, height: size,
        padding: EdgeInsets.all(asset == null ? 0 : 4),
        decoration: BoxDecoration(
          color: asset == null ? DavoColors.of(context).mutedSoft : Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: asset == null ? fallback : Image.asset(
          asset, fit: BoxFit.contain,
          errorBuilder: (_, error, stack) => fallback,
        ),
      ),
    );
  }
}
