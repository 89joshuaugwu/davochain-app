import 'package:flutter/material.dart';
import '../../core/navigation/app_page_route.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/formatters/grouped_amount_formatter.dart';
import '../../shared/formatters/crypto_quantity_formatter.dart';
import '../../shared/receipts/receipt_record.dart';
import '../../shared/receipts/transaction_record_details_screen.dart';
import '../../shared/motion/davo_motion_spec.dart';
import '../../shared/motion/davo_working_indicator.dart';
import '../../shared/widgets/auth_widgets.dart';
import '../../shared/widgets/davo_result_screen.dart';

enum FundingDirection { deposit, withdrawal }

enum FundingStatus { pending, completed, failed }

/// Accepted operation data. No receiving-address action creates this record.
@immutable
class FundingRecord {
  const FundingRecord(
      {required this.id,
      required this.direction,
      required this.status,
      required this.amount,
      required this.currency,
      required this.destination,
      required this.occurredAt,
      this.network,
      this.reference,
      this.transactionHash,
      this.bank,
      this.accountNumber,
      this.accountName,
      this.fee = 0,
      this.preview = false});
  final String id, currency, destination;
  final FundingDirection direction;
  final FundingStatus status;
  final double amount, fee;
  final DateTime occurredAt;
  final String? network,
      reference,
      transactionHash,
      bank,
      accountNumber,
      accountName;
  final bool preview;
  bool get deposit => direction == FundingDirection.deposit;
  String get amountLabel =>
      '${currency == 'NGN' || currency == 'NGD' ? '₦' : ''}'
      '${formatGroupedAmount(currency == 'NGN' || currency == 'NGD' ? amount.toStringAsFixed(2) : formatCryptoQuantity(amount))}'
      '${currency == 'NGN' || currency == 'NGD' ? '' : ' $currency'}';
  String get title => status == FundingStatus.failed
      ? (deposit ? 'Deposit unsuccessful' : 'Withdrawal unsuccessful')
      : deposit
          ? (status == FundingStatus.completed
              ? 'Deposit received'
              : 'Deposit pending')
          : (status == FundingStatus.completed
              ? 'Withdrawal successful'
              : 'Withdrawal submitted');
  String get statusLabel => switch (status) {
        FundingStatus.pending => 'Pending',
        FundingStatus.completed => 'Completed',
        FundingStatus.failed => 'Failed',
      };
}

/// Session activity feed, ready for accepted provider events. It does not poll,
/// persist funds, invent deposit events, or represent a server-side ledger.
abstract final class FundingActivity {
  static final records = ValueNotifier<List<FundingRecord>>(const []);
  static final Set<String> _presented = {};
  static bool claimPresentation(FundingRecord record) =>
      _presented.add('${record.id}-${record.status.name}');
  static void reset() {
    _presented.clear();
    records.value = const [];
  }

  static void accept(FundingRecord record) {
    if (record.id.isEmpty || !record.amount.isFinite || record.amount <= 0) {
      return;
    }
    final previous = records.value.where((r) => r.id == record.id);
    if (previous.isNotEmpty &&
        previous.first.status == FundingStatus.completed &&
        record.status != FundingStatus.completed) {
      return;
    }
    records.value = List.unmodifiable(
        [record, ...records.value.where((r) => r.id != record.id)]);
  }
}

/// Receiving pages stay quiet until an accepted deposit exists in the feed.
class DepositActivityBanner extends StatelessWidget {
  const DepositActivityBanner({super.key, this.currency});
  final String? currency;
  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<List<FundingRecord>>(
          valueListenable: FundingActivity.records,
          builder: (context, records, _) {
            final matching = records.where((r) =>
                r.deposit && (currency == null || r.currency == currency));
            if (matching.isEmpty) return const SizedBox.shrink();
            final record = matching.first;
            final colors = DavoColors.of(context);
            return Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: colors.primarySoft,
                    borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  Icon(
                      record.status == FundingStatus.completed
                          ? Icons.check_circle_outline
                          : record.status == FundingStatus.failed
                              ? Icons.error_outline
                              : Icons.schedule,
                      color: colors.link,
                      size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(record.title,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: colors.ink)),
                        Text(record.amountLabel,
                            style: TextStyle(fontSize: 12, color: colors.body)),
                      ])),
                  TextButton(
                      onPressed: () {
                        final animate =
                            FundingActivity.claimPresentation(record);
                        Navigator.of(context).push(AppPageRoute<void>(
                            builder: (_) => FundingOutcomeScreen(
                                record: record, animate: animate)));
                      },
                      child: const Text('View details')),
                ]));
          });
}

class NairaWithdrawalProgressScreen extends StatefulWidget {
  const NairaWithdrawalProgressScreen(
      {super.key,
      required this.amount,
      required this.bank,
      required this.accountNumber,
      required this.accountName,
      this.operation});
  final double amount;
  final String bank, accountNumber, accountName;
  final Future<FundingStatus> Function()? operation;
  @override
  State<NairaWithdrawalProgressScreen> createState() =>
      _NairaWithdrawalProgressScreenState();
}

class _NairaWithdrawalProgressScreenState
    extends State<NairaWithdrawalProgressScreen> {
  bool _failed = false;
  bool _running = false;
  @override
  void initState() {
    super.initState();
    _submit();
  }

  Future<void> _submit() async {
    if (_running) return;
    _running = true;
    if (_failed) setState(() => _failed = false);
    try {
      // Matches the app's existing session-only financial preview boundary.
      // An accepted submission remains pending; elapsed time never means paid.
      final status = widget.operation == null
          ? await Future<FundingStatus>.delayed(
              const Duration(milliseconds: 1500), () => FundingStatus.pending)
          : await widget.operation!();
      if (!mounted || ModalRoute.of(context)?.isCurrent == false) return;
      if (status == FundingStatus.failed) {
        setState(() => _failed = true);
        return;
      }
      final now = DateTime.now();
      final record = FundingRecord(
          id: receiptDemoId(now),
          direction: FundingDirection.withdrawal,
          status: status,
          amount: widget.amount,
          currency: 'NGN',
          destination: widget.bank,
          bank: widget.bank,
          accountNumber: widget.accountNumber,
          accountName: widget.accountName,
          occurredAt: now,
          fee: 100,
          preview: true);
      FundingActivity.accept(record);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(AppPageRoute<void>(
          builder: (_) =>
              FundingOutcomeScreen(record: record, returnToWallet: true)));
    } catch (_) {
      if (mounted && ModalRoute.of(context)?.isCurrent != false) {
        setState(() => _failed = true);
      }
    } finally {
      _running = false;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Withdrawal')),
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(children: [
                Expanded(
                    child: Center(
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                  if (_failed)
                    Icon(Icons.error_outline,
                        size: 64, color: DavoColors.of(context).danger)
                  else
                    const DavoWorkingIndicator(),
                  const SizedBox(height: 24),
                  Text(
                      _failed
                          ? 'Could not submit withdrawal'
                          : 'Submitting your withdrawal',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Text(
                      _failed
                          ? 'Your request was not confirmed. Please try again.'
                          : 'Waiting for your request to be accepted.',
                      textAlign: TextAlign.center),
                ]))),
                if (_failed)
                  DavoPrimaryButton(label: 'Try again', onPressed: _submit),
              ]))));
}

class FundingOutcomeScreen extends StatelessWidget {
  const FundingOutcomeScreen(
      {super.key,
      required this.record,
      this.returnToWallet = false,
      this.animate = true});
  final FundingRecord record;
  final bool returnToWallet, animate;
  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<List<FundingRecord>>(
          valueListenable: FundingActivity.records,
          builder: (context, records, _) {
            final current = records.where((r) => r.id == record.id);
            final value = current.isEmpty ? record : current.first;
            final child = DavoResultScreen(
                eventKey: '${value.id}-${value.status.name}',
                kind: value.status == FundingStatus.completed
                    ? DavoOutcomeKind.completed
                    : DavoOutcomeKind.submitted,
                mark: value.status == FundingStatus.failed
                    ? Icon(Icons.error_outline,
                        size: 96, color: DavoColors.of(context).danger)
                    : null,
                title: value.title,
                message: value.deposit
                    ? (value.status == FundingStatus.completed
                        ? '${value.amountLabel} has been credited to your ${value.destination}.'
                        : value.status == FundingStatus.failed
                            ? 'The deposit could not be confirmed.'
                            : 'Your ${value.amountLabel} deposit is awaiting confirmation.')
                    : value.status == FundingStatus.completed
                        ? 'Your ${value.amountLabel} payout is confirmed.'
                        : value.status == FundingStatus.failed
                            ? 'Your withdrawal was not confirmed.'
                            : 'Your ${value.amountLabel} withdrawal is awaiting payout confirmation.',
                details: Column(children: [
                  Text(value.statusLabel,
                      style: TextStyle(
                          fontSize: 14,
                          color: value.status == FundingStatus.completed
                              ? DavoColors.of(context).success
                              : value.status == FundingStatus.failed
                                  ? DavoColors.of(context).danger
                                  : DavoColors.of(context).warning)),
                  if (value.preview) ...[
                    const SizedBox(height: 12),
                    const Text('Preview only. No funds have been moved.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12))
                  ],
                ]),
                actions: Column(children: [
                  DavoPrimaryButton(
                      label: 'View details',
                      onPressed: () => Navigator.of(context).push(
                          AppPageRoute<void>(
                              builder: (_) =>
                                  FundingDetailsScreen(record: value)))),
                  TextButton(
                      onPressed: () {
                        if (returnToWallet) {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Back to wallet')),
                ]));
            final presentation = animate
                ? child
                : MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(disableAnimations: true),
                    child: child);
            return PopScope(
              canPop: !returnToWallet,
              onPopInvokedWithResult: (didPop, result) {
                if (!didPop && returnToWallet) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                }
              },
              child: presentation,
            );
          });
}

class FundingDetailsScreen extends StatelessWidget {
  const FundingDetailsScreen({super.key, required this.record});
  final FundingRecord record;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<List<FundingRecord>>(
      valueListenable: FundingActivity.records,
      builder: (context, records, _) {
        final matches = records.where((r) => r.id == record.id);
        final value = matches.isEmpty ? record : matches.first;
        return TransactionRecordDetailsScreen(record: _receipt(value));
      });

  ReceiptRecord _receipt(FundingRecord value) {
    final status = switch (value.status) {
      FundingStatus.pending => ReceiptStatus.pending,
      FundingStatus.completed => ReceiptStatus.completed,
      FundingStatus.failed => ReceiptStatus.failed,
    };
    final fiat = value.currency == 'NGN' || value.currency == 'NGD';
    final fee = '${fiat ? '₦' : ''}'
        '${formatGroupedAmount(fiat ? value.fee.toStringAsFixed(2) : formatCryptoQuantity(value.fee))}'
        '${fiat ? '' : ' ${value.currency}'}';
    return ReceiptRecord(
      id: value.id,
      reference: value.reference ?? value.id,
      type: value.deposit ? 'Deposit' : 'Withdrawal',
      status: status,
      occurredAt: value.occurredAt,
      amount: value.amountLabel,
      preview: value.preview,
      fields: [
        ReceiptField(label: 'Wallet', value: value.currency),
        ReceiptField(label: 'Destination', value: value.destination,
            sensitive: !fiat || value.destination == value.accountNumber),
        if (value.bank != null) ReceiptField(label: 'Bank', value: value.bank!),
        if (value.accountNumber != null)
          ReceiptField(label: 'Account', value: value.accountNumber!, sensitive: true),
        if (value.accountName != null)
          ReceiptField(label: 'Account name', value: value.accountName!, sensitive: true),
        if (!value.deposit || value.fee > 0) ReceiptField(label: 'Fee', value: fee),
        if (value.network != null) ReceiptField(label: 'Network', value: value.network!),
        if (value.transactionHash != null)
          ReceiptField(label: 'Transaction hash', value: value.transactionHash!, copyable: true),
      ],
      events: [
        ReceiptEvent(
          label: switch (status) {
            ReceiptStatus.pending => 'Request accepted',
            ReceiptStatus.completed => value.deposit ? 'Deposit received' : 'Withdrawal confirmed',
            ReceiptStatus.failed => value.deposit ? 'Deposit unsuccessful' : 'Withdrawal unsuccessful',
          },
          description: switch (status) {
            ReceiptStatus.pending => 'This request is pending confirmation.',
            ReceiptStatus.completed => 'This transaction is recorded as completed.',
            ReceiptStatus.failed => 'This transaction is recorded as failed.',
          },
          occurredAt: value.occurredAt,
          state: status == ReceiptStatus.failed
              ? ReceiptEventState.current
              : ReceiptEventState.complete,
        ),
        if (status == ReceiptStatus.pending)
          const ReceiptEvent(label: 'Awaiting confirmation',
              description: 'Confirmation has not been received.',
              state: ReceiptEventState.current),
      ],
    );
  }
}
