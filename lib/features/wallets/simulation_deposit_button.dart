import 'package:flutter/material.dart';
import '../../core/money/money.dart';
import '../../core/money/exact_decimal.dart';
import '../../core/navigation/app_page_route.dart';
import '../../shared/receipts/receipt_record.dart';
import '../funding/funding_outcomes.dart';
import 'wallet_repository.dart';

/// Explicit local funding control; copying receiving details never credits funds.
class SimulationDepositButton extends StatelessWidget {
  const SimulationDepositButton({super.key, required this.currency});
  final String currency;
  @override
  Widget build(BuildContext context) {
    if (!WalletAccountState.instance.simulationEnabled ||
        const String.fromEnvironment('DAVOCHAIN_ENV',
                defaultValue: 'development') ==
            'production') {
      return const SizedBox.shrink();
    }
    return TextButton.icon(
        key: ValueKey('simulate-deposit-$currency'),
        icon: const Icon(Icons.add_circle_outline, size: 18),
        label: const Text('Add funds'),
        onPressed: () async {
          final generation = WalletAccountState.instance.generation;
          final result = await showDialog<(String, String)>(
              context: context,
              builder: (_) => _DepositDialog(currency: currency));
          if (result == null ||
              !context.mounted ||
              generation != WalletAccountState.instance.generation) {
            return;
          }
          final record = FundingRecord(
              id: receiptDemoId(DateTime.now()),
              direction: FundingDirection.deposit,
              status: FundingStatus.pending,
              amount: result.$2,
              currency: result.$1,
              destination: '${result.$1} wallet',
              occurredAt: DateTime.now(),
              preview: true);
          FundingActivity.submitPreview(record);
          if (context.mounted) {
            Navigator.of(context).push(AppPageRoute<void>(
                builder: (_) => FundingOutcomeScreen(
                    record: record, returnToWallet: true)));
          }
        });
  }
}

class _DepositDialog extends StatefulWidget {
  const _DepositDialog({required this.currency});
  final String currency;
  @override
  State<_DepositDialog> createState() => _DepositDialogState();
}

class _DepositDialogState extends State<_DepositDialog> {
  late String currency = widget.currency;
  late final controller = TextEditingController(
      text: ['NGN', 'NGD'].contains(currency) ? '100000' : '0.01');
  String? error;
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
          title: const Text('Add funds'),
          content: SingleChildScrollView(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                const Text('Choose a wallet and enter your deposit amount.'),
                const SizedBox(height: 16),
                if (['NGN', 'NGD'].contains(widget.currency))
                  DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: currency,
                      items: const [
                        DropdownMenuItem(
                            value: 'NGN', child: Text('Naira (NGN)')),
                        DropdownMenuItem(
                            value: 'NGD',
                            child: Text('Davochain (NGD)',
                                maxLines: 1, overflow: TextOverflow.ellipsis))
                      ],
                      onChanged: (value) => setState(() => currency = value!)),
                const SizedBox(height: 12),
                TextField(
                    key: const ValueKey('simulation-deposit-amount'),
                    controller: controller,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                        labelText: 'Amount ($currency)', errorText: error)),
              ])),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            FilledButton(
                onPressed: () {
                  try {
                    final amount = AssetAmount.parse(
                        controller.text.trim(),
                        currency,
                        WalletAccountState.instance.snapshot
                            .available(currency)
                            .decimals);
                    if (amount.atomicUnits <= BigInt.zero ||
                        ExactDecimal.parse(amount.decimal)
                                .compareTo(ExactDecimal.parse('1000000000')) >
                            0) {
                      throw const FormatException();
                    }
                    Navigator.pop(context, (currency, amount.decimal));
                  } on FormatException {
                    setState(() => error =
                        'Enter a positive amount with valid precision.');
                  }
                },
                child: const Text('Confirm deposit'))
          ]);
}
