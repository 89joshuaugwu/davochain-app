import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:davochain/core/providers/account_scope.dart';
import 'package:davochain/core/providers/reactive_builder.dart';
import 'package:davochain/features/wallets/wallet_repository.dart';
import 'package:davochain/features/wallets/wallet_providers.dart';
import 'package:davochain/features/dashboard/presentation/dashboard_screen.dart';

class _ObservedWallet extends WalletAccountState {
  bool get listening => hasListeners;
}

class _ObservedValue extends ValueNotifier<int> {
  _ObservedValue() : super(0);
  bool get listening => hasListeners;
}

void main() {
  testWidgets(
    'Riverpod consumers publish wallet changes and detach on disposal',
    (tester) async {
      final engine = _ObservedWallet()..startSimulation(empty: true);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [walletEngineProvider.overrideWithValue(engine)],
          child: MaterialApp(
            home: AccountConsumer(
              builder: (context, ref) => Text(
                ref.watch(currentWalletProvider).available('NGN').decimal,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('0'), findsOneWidget);
      engine.applyEffect(
        'fund',
        engine.effect(credits: {'NGN': '1000'}),
        completed: true,
        failed: false,
      );
      await tester.pumpAndSettle();
      expect(find.text('1000'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(engine.listening, isFalse);
    },
  );
  testWidgets(
    'device settings use Riverpod subscriptions without requiring a route-specific scope',
    (tester) async {
      final value = _ObservedValue();
      await tester.pumpWidget(
        MaterialApp(
          home: DavoValueListenableBuilder<int>(
            valueListenable: value,
            builder: (_, n, _) => Text('$n'),
          ),
        ),
      );
      value.value = 1;
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(value.listening, isFalse);
    },
  );
  testWidgets('portfolio follows actual shared balance settlement', (
    tester,
  ) async {
    final engine = WalletAccountState.instance..startSimulation(empty: true);
    await tester.pumpWidget(const MaterialApp(home: PortfolioScreen()));
    await tester.pumpAndSettle();
    expect(find.text('0 Coins'), findsOneWidget);
    engine.applyEffect(
      'btc',
      engine.effect(credits: {'BTC': '0.01'}),
      completed: true,
      failed: false,
    );
    await tester.pumpAndSettle();
    expect(find.text('0.01 BTC'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    engine.reset();
  });
}
