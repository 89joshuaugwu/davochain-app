enum GiftCardMode { buy, sell }

enum GiftCardCategory { all, shopping, gaming, streaming, food }

class GiftCardBrand {
  const GiftCardBrand({
    required this.name,
    required this.asset,
    this.subtitle,
    this.rate,
    this.hot = false,
    this.category = GiftCardCategory.shopping,
  });

  final String name;
  final String asset;
  final String? subtitle;
  final String? rate;
  final bool hot;
  final GiftCardCategory category;
}
