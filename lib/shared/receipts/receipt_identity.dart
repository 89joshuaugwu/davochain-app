import 'package:flutter/material.dart';
import 'receipt_record.dart';

enum ReceiptAction {
  purchase('purchase', Icons.add_circle_outline, '+'),
  sale('sale', Icons.remove_circle_outline, '−'),
  deposit('deposit', Icons.south_west, '↙'),
  withdrawal('withdrawal', Icons.north_east, '↗'),
  swap('swap', Icons.swap_horiz, '⇄'),
  transfer('transfer', Icons.north_east, '↗');

  const ReceiptAction(this.label, this.icon, this.glyph);
  final String label, glyph;
  final IconData icon;
}

class ReceiptIdentity {
  ReceiptIdentity(this.record);
  final ReceiptRecord record;
  ReceiptAction get action {
    final type = record.type.toLowerCase();
    if (type.contains('conversion') || type.contains('swap')) {
      return ReceiptAction.swap;
    }
    if (type.contains('withdraw') || type.contains('external')) {
      return ReceiptAction.withdrawal;
    }
    if (type.contains('deposit') || type.contains('receive')) {
      return ReceiptAction.deposit;
    }
    if (type.contains('sell') || type.contains('sale')) {
      return ReceiptAction.sale;
    }
    if (type.contains('buy') || type.contains('purchase')) {
      return ReceiptAction.purchase;
    }
    return ReceiptAction.transfer;
  }

  bool get isGift => record.type.toLowerCase().contains('gift');
  String? get brand => record.fields
      .where((f) =>
          !f.sensitive &&
          f.label.toLowerCase() == 'brand' &&
          f.value.trim().isNotEmpty)
      .firstOrNull
      ?.value
      .trim();
  String? get brandImage => isGift
      ? switch (brand?.toLowerCase()) {
          'amazon' => 'assets/figma_exact/gift_amazon_37_exact.png',
          'apple' || 'itunes' => 'assets/figma_exact/gift_apple_37_exact.png',
          'steam' => 'assets/figma_exact/gift_steam_37_exact.png',
          'razer' ||
          'razer gold' =>
            'assets/figma_exact/gift_razer_37_exact.png',
          'google play' => 'assets/figma_exact/gift_google_play_37_exact.png',
          'walmart' => 'assets/figma_exact/gift_walmart_exact.png',
          'ebay' => 'assets/figma_exact/gift_ebay_exact.png',
          'amex' ||
          'american express' =>
            'assets/figma_exact/gift_amex_exact.png',
          _ => null,
        }
      : null;
  static String _name(ReceiptAsset asset) => switch (asset) {
        ReceiptAsset.btc => 'Bitcoin',
        ReceiptAsset.eth => 'Ethereum',
        ReceiptAsset.sol => 'Solana',
        ReceiptAsset.usdt => 'Tether',
        ReceiptAsset.ngn => 'Naira',
        ReceiptAsset.ngd => 'Davochain Naira',
        ReceiptAsset.usd => 'Dollar',
        ReceiptAsset.giftCard => 'Gift card',
      };
  String get headline {
    if (isGift) {
      return '${brand == null ? 'Gift card' : '$brand gift card'} ${action.label}';
    }
    final assets =
        record.assets.where((a) => a != ReceiptAsset.giftCard).toList();
    if (action == ReceiptAction.swap && assets.length > 1) {
      return '${_name(assets.first)} to ${_name(assets[1])} swap';
    }
    return '${assets.isEmpty ? 'Transaction' : _name(assets.first)} ${action.label}';
  }
}
