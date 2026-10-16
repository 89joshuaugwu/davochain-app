import 'package:davochain/features/funding/funding_outcomes.dart';
import 'package:davochain/features/transactions/presentation/transaction_history_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

FundingRecord deposit(FundingStatus status) => FundingRecord(
  id: 'quiet-deposit',
  direction: FundingDirection.deposit,
  status: status,
  amount: 1000,
  currency: 'NGN',
  destination: 'Wallet',
  occurredAt: DateTime(2026, 10, 16),
);

void main() {
  tearDown(FundingActivity.reset);
  testWidgets('pending deposit stays internal until its outcome', (
    tester,
  ) async {
    FundingActivity.accept(deposit(FundingStatus.pending));
    await tester.pumpWidget(
      const MaterialApp(home: TransactionHistoryScreen()),
    );
    expect(find.text('Deposit pending'), findsNothing);
    expect(FundingActivity.records.value.single.status, FundingStatus.pending);
    FundingActivity.accept(deposit(FundingStatus.completed));
    await tester.pump();
    expect(find.text('Deposit received'), findsOneWidget);
  });
  testWidgets('received banner can close without deleting transaction', (
    tester,
  ) async {
    FundingActivity.accept(deposit(FundingStatus.completed));
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: DepositActivityBanner())),
    );
    await tester.tap(find.byTooltip('Dismiss deposit alert'));
    await tester.pumpAndSettle();
    expect(find.text('Deposit received'), findsNothing);
    expect(FundingActivity.records.value, hasLength(1));
    FundingActivity.accept(deposit(FundingStatus.completed));
    await tester.pump();
    expect(find.text('Deposit received'), findsNothing);
  });
  testWidgets('received banner swipes away and history retains the deposit', (tester) async {
    FundingActivity.accept(deposit(FundingStatus.completed));
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: DepositActivityBanner())));
    await tester.drag(find.byType(Dismissible), const Offset(-700, 0));
    await tester.pumpAndSettle();
    expect(find.text('Deposit received'), findsNothing);
    await tester.pumpWidget(const MaterialApp(home: TransactionHistoryScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Deposit received'), findsOneWidget);
  });
}
