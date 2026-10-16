import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/features/wallets/wallet_repository.dart';
import 'package:davochain/shared/receipts/transaction_repository.dart';
import 'package:davochain/shared/receipts/receipt_record.dart';
import 'package:davochain/shared/widgets/davo_result_screen.dart';

void main() {
  testWidgets(
    'unsaved financial result shows pending update and retry instead of success',
    (tester) async {
      final ledger = WalletAccountState.instance..startSimulation(empty: true);
      final repo = LocalTransactionRepository.instance;
      repo.checkpoint = (_) => Future.error(StateError('disk full'));
      addTearDown(() {
        repo.checkpoint = null;
        repo.reset();
        ledger.reset();
      });
      final record = ReceiptRecord(
        id: 'save-ui',
        reference: 'save-ui',
        type: 'Deposit',
        status: ReceiptStatus.completed,
        occurredAt: DateTime.now(),
        amount: '100',
        fields: const [],
        walletEffect: ledger.effect(credits: {'NGN': '100'}),
      );
      await repo.submitDurable(record);
      await tester.pumpWidget(
        const MaterialApp(
          home: DavoResultScreen(
            title: 'Deposit received',
            message: 'Funds credited',
            refreshRecordId: 'save-ui',
            actions: Text('Close'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Account update pending'), findsOneWidget);
      expect(find.text('Retry account update'), findsOneWidget);
      expect(find.text('Deposit received'), findsNothing);
      expect(ledger.ngnAvailableMinorUnits, 0);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
