import '../../core/money/money.dart';

/// Frozen exact local-ledger instruction, separate from receipt display text.
class WalletEffect {
  WalletEffect(
      {required this.accountId,
      required this.generation,
      required Map<String, AssetAmount> debits,
      required Map<String, AssetAmount> credits})
      : debits = Map.unmodifiable(debits),
        credits = Map.unmodifiable(credits);
  final String accountId;
  final int generation;
  final Map<String, AssetAmount> debits, credits;
}
