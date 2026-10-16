import 'package:davochain/features/crypto/presentation/crypto_full_flow.dart';
import 'package:davochain/features/dashboard/presentation/dashboard_screen.dart';
import 'package:davochain/features/wallets/wallet_repository.dart';
import 'package:davochain/shared/widgets/davo_naira_amount.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('bank withdrawal is branded and uses the custom amount mark', (
    tester,
  ) async {
    final wallet = WalletAccountState.instance..startSimulation(empty: true);
    await tester.pumpWidget(const MaterialApp(home: NairaWithdrawScreen()));
    await tester.pumpAndSettle();
    expect(find.text('Withdraw Davochain Naira'), findsOneWidget);
    expect(find.text('Davochain Naira balance'), findsOneWidget);
    expect(find.byType(DavoNairaAmount), findsOneWidget);
    expect(find.textContaining('= \u20a60.00'), findsOneWidget);
    expect(find.text('Available NGN balance'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    wallet.reset();
  });
  testWidgets(
    'withdrawal source chooser has Davochain wallet instead of Nigerian currency',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => startWithdrawFlow(context),
                child: const Text('Withdraw'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Withdraw'));
      await tester.pumpAndSettle();
      expect(find.text('Davochain Naira'), findsOneWidget);
      expect(find.text('Nigeria Naira'), findsNothing);
    },
  );
  testWidgets(
    'receiving screen contains no old global bank identity or withdrawal restriction',
    (tester) async {
      final wallet = WalletAccountState.instance..startSimulation(empty: true);
      await tester.pumpWidget(const MaterialApp(home: NairaDepositScreen()));
      await tester.pumpAndSettle();
      expect(find.textContaining('542100896436'), findsNothing);
      expect(find.textContaining('cannot be withdrawn'), findsNothing);
      expect(find.textContaining('test account reference'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      wallet.reset();
    },
  );
}
