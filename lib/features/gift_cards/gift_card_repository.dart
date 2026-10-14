import 'gift_order_draft.dart';
import 'gift_evidence_picker.dart';
import '../../shared/receipts/receipt_record.dart';

/// Authenticated adapters must own upload acceptance, pricing and fulfillment.
/// Selecting local evidence never supplies an upload ID or execution verdict.
abstract interface class GiftCardRepository {
  Future<List<GiftCatalogProduct>> loadCatalog();
  Future<String> uploadEvidence(String draftId, GiftEvidence attachment);
  Future<GiftOrderQuote> quote(GiftOrderDraft draft);
  Future<ReceiptRecord> execute(GiftOrderQuote quote,
      {required String authorizationGrant, required String idempotencyKey});
  Future<ReceiptRecord> findOperation(String operationId);
}

class GiftOrderQuote {
  const GiftOrderQuote(
      {required this.id,
      required this.draft,
      required this.expiresAt,
      required this.costMinorUnits,
      required this.catalogVersion});
  final String id, catalogVersion;
  final GiftOrderDraft draft;
  final DateTime expiresAt;
  final int costMinorUnits;
  bool matches(GiftOrderDraft current, {required DateTime now}) {
    if (!now.isBefore(expiresAt)) return false;
    final previous = draft;
    return current.product.skuId == previous.product.skuId &&
        current.product.country == previous.product.country &&
        current.product.cardType == previous.product.cardType &&
        current.product.exactRateNaira
                .compareTo(previous.product.exactRateNaira) ==
            0 &&
        current.product.exactMinimumDenomination
                .compareTo(previous.product.exactMinimumDenomination) ==
            0 &&
        current.exactDenomination.compareTo(previous.exactDenomination) == 0 &&
        current.quantity == previous.quantity &&
        current.evidence?.path == previous.evidence?.path &&
        current.delivery.forMe == previous.delivery.forMe &&
        current.delivery.instant == previous.delivery.instant &&
        current.delivery.email == previous.delivery.email &&
        current.delivery.phone == previous.delivery.phone;
  }
}
