import '../../../core/money/exact_decimal.dart';
import '../../../shared/formatters/grouped_amount_formatter.dart';
import '../../wallets/wallet_repository.dart';
import 'package:flutter/material.dart';
import 'buy_crypto_models.dart';

/// Owns input, wallet validation and draft edits for the amount step.
class BuyAmountController extends ChangeNotifier {
  BuyAmountController(BuyCryptoOrder initialOrder)
    : order = initialOrder.copyWith(
        wallet: BuyFundingWallet.ngn,
        quantityDecimals: WalletAccountState.instance.snapshot
            .available(initialOrder.asset.symbol)
            .decimals,
      ),
      _generation = WalletAccountState.instance.generation {
    input.addListener(notifyListeners);
    WalletAccountState.instance.addListener(_accountChanged);
  }
  BuyCryptoOrder order;
  final input = TextEditingController();
  final int _generation;
  bool get accountCurrent =>
      _generation == WalletAccountState.instance.generation;
  ExactDecimal get amount {
    try {
      return ExactDecimal.parse(
        input.text.replaceAll(',', '').replaceAll('₦', '').trim(),
      );
    } on FormatException {
      return ExactDecimal.zero;
    }
  }

  bool get canContinue =>
      accountCurrent &&
      !amount.isZero &&
      !amount.isNegative &&
      amount.compareTo(order.wallet.exactBalance) <= 0 &&
      ExactDecimal.parse(amount.toFixed(2)).compareTo(amount) == 0 &&
      !draft.exactCryptoAmount.isZero;
  BuyCryptoOrder get draft => order.copyWith(ngnAmount: amount);
  void selectAsset(BuyCryptoAsset asset) {
    if (!accountCurrent) return;
    order = order.copyWith(
      asset: asset,
      quantityDecimals: WalletAccountState.instance.snapshot
          .available(asset.symbol)
          .decimals,
    );
    notifyListeners();
  }

  void selectWallet(BuyFundingWallet wallet) {
    if (!accountCurrent) return;
    order = order.copyWith(wallet: wallet);
    if (amount.compareTo(wallet.exactBalance) > 0) {
      setAmount(wallet.exactBalance);
    }
    notifyListeners();
  }

  void setAmount(ExactDecimal value) {
    if (!accountCurrent) return;
    final safe = value.isNegative
        ? ExactDecimal.zero
        : value.compareTo(order.wallet.exactBalance) > 0
        ? order.wallet.exactBalance
        : value;
    input.text = formatGroupedAmount(
      safe.toFixed(2).replaceFirst(RegExp(r'\.00$'), ''),
    );
    input.selection = TextSelection.collapsed(offset: input.text.length);
  }

  void pickPercentage(int percent) => setAmount(
    ExactDecimal.parse(
      (order.wallet.exactBalance * ExactDecimal.from(percent))
          .divide(ExactDecimal.from(100))
          .toFixed(2),
    ),
  );
  void _accountChanged() {
    if (!accountCurrent) input.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    WalletAccountState.instance.removeListener(_accountChanged);
    input.dispose();
    super.dispose();
  }
}
