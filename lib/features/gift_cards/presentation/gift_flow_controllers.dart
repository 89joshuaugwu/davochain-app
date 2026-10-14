import '../../../core/money/exact_decimal.dart';
import '../../wallets/wallet_repository.dart';
import '../gift_order_draft.dart';
import 'package:flutter/material.dart';

/// Amount/catalog/quantity state shared by both gift card entry steps.
class GiftAmountController extends ChangeNotifier {
  GiftAmountController()
      : _generation = WalletAccountState.instance.generation {
    amount.addListener(notifyListeners);
    WalletAccountState.instance.addListener(_accountChanged);
  }
  final amount = TextEditingController();
  final int _generation;
  GiftCatalogProduct? product;
  int quantity = 1;
  bool get accountCurrent =>
      _generation == WalletAccountState.instance.generation;
  ExactDecimal get denomination {
    try {
      return ExactDecimal.parse(amount.text.replaceAll(',', '').trim());
    } on FormatException {
      return ExactDecimal.zero;
    }
  }

  bool get ready =>
      accountCurrent &&
      product != null &&
      !denomination.isNegative &&
      denomination.compareTo(product!.exactMinimumDenomination) >= 0 &&
      quantity > 0 &&
      denomination.compareTo(ExactDecimal.parse(denomination.toFixed(2))) == 0;
  GiftOrderDraft? get draft => product == null
      ? null
      : GiftOrderDraft(
          product: product!, denomination: denomination, quantity: quantity);
  ExactDecimal get cost =>
      draft?.costNaira ??
      ExactDecimal.parse(
          (denomination * ExactDecimal.from(865) * ExactDecimal.from(quantity))
              .toFixed(2));
  void _accountChanged() {
    if (!accountCurrent) {
      product = null;
      amount.clear();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    WalletAccountState.instance.removeListener(_accountChanged);
    amount.dispose();
    super.dispose();
  }
}

/// Delivery input ownership and validation travel together through the flow.
class GiftDeliveryController {
  GiftDeliveryController({GiftDelivery initial = const GiftDelivery()})
      : forMe = initial.forMe,
        instant = initial.instant,
        email = TextEditingController(text: initial.email),
        phone = TextEditingController(text: initial.phone);
  bool forMe, instant;
  final TextEditingController email, phone;
  GiftDelivery get delivery => GiftDelivery(
      forMe: forMe,
      instant: instant,
      email: email.text.trim(),
      phone: phone.text.trim());
  void dispose() {
    email.dispose();
    phone.dispose();
  }
}
