import 'gift_evidence_picker.dart';

enum GiftCardType { physical, eCode }

/// Catalog terms travel with the selection; provider catalog adapters replace
/// these local choices rather than inferring a product from its brand name.
class GiftCatalogProduct {
  const GiftCatalogProduct(
      {required this.skuId,
      required this.brandName,
      required this.country,
      required this.cardType,
      required this.category,
      this.minimumDenomination = 50,
      this.rateNaira = 865});
  final String skuId, brandName, country, category;
  final GiftCardType cardType;
  final int minimumDenomination, rateNaira;
  String get typeLabel =>
      cardType == GiftCardType.physical ? 'Physical' : 'E-code';
  String get label =>
      '$country $brandName, $typeLabel ($minimumDenomination above)';
  String get terms => cardType == GiftCardType.physical
      ? 'Upload a clear image of your $country $brandName physical gift card. The brand, value and country must match your selection. Keep the original card until review is complete.'
      : 'Provide a clear image of your $country $brandName e-code and its purchase details. The code must be unused and match your selected value and country.';
}

class GiftDelivery {
  const GiftDelivery(
      {this.forMe = true,
      this.instant = true,
      this.email = '',
      this.phone = ''});
  final bool forMe, instant;
  final String email, phone;
  String get methodLabel => instant ? 'Instant Delivery' : 'Email Delivery';
  String? get validationError {
    if ((!forMe || !instant || email.isNotEmpty) &&
        !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'Enter a valid email address.';
    }
    if (phone.isNotEmpty &&
        !RegExp(r'^\+?[0-9]{7,15}$')
            .hasMatch(phone.replaceAll(RegExp(r'[\s()-]'), ''))) {
      return 'Enter a valid phone number.';
    }
    return null;
  }
}

class GiftOrderDraft {
  const GiftOrderDraft(
      {required this.product,
      required this.denomination,
      this.quantity = 1,
      this.evidence,
      this.delivery = const GiftDelivery()});
  final GiftCatalogProduct product;
  final double denomination;
  final int quantity;
  final GiftEvidence? evidence;
  final GiftDelivery delivery;
  GiftOrderDraft withDelivery(GiftDelivery value) => GiftOrderDraft(
      product: product,
      denomination: denomination,
      quantity: quantity,
      evidence: evidence,
      delivery: value);
}
