import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:davochain/core/providers/account_scope.dart';
import 'package:davochain/features/wallets/wallet_repository.dart';
import 'package:davochain/features/wallets/wallet_providers.dart';

void main() {
  test(
    'old account publication cannot update a switched account scope',
    () async {
      final engine = WalletAccountState();
      engine.startSimulation(empty: true);
      final container = ProviderContainer(
        overrides: [walletEngineProvider.overrideWithValue(engine)],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(walletSnapshotProvider, (_, _) {});
      addTearDown(subscription.close);
      final old = await container.read(walletSnapshotProvider.future);
      final generation = engine.generation;
      engine.startSimulation(empty: true);
      await Future<void>.delayed(Duration.zero);
      expect(engine.publish(old, generation: generation), isFalse);
      final current = await container.read(walletSnapshotProvider.future);
      expect(current.accountId, isNot(old.accountId));
      expect(current.assets.length, 11);
      expect(
        current.assets.every(
          (a) => current.available(a).atomicUnits == BigInt.zero,
        ),
        isTrue,
      );
      expect(
        container.read(accountSessionProvider).accountId,
        current.accountId,
      );
    },
  );
  test('provider containers can hold independent accounts', () async {
    final a = WalletAccountState()..startSimulation(empty: true);
    final b = WalletAccountState()..startSimulation(empty: false);
    final first = ProviderContainer(
      overrides: [walletEngineProvider.overrideWithValue(a)],
    );
    final second = ProviderContainer(
      overrides: [walletEngineProvider.overrideWithValue(b)],
    );
    first.listen(walletSnapshotProvider, (_, _) {});
    second.listen(walletSnapshotProvider, (_, _) {});
    addTearDown(first.dispose);
    addTearDown(second.dispose);
    expect(
      (await first.read(
        walletSnapshotProvider.future,
      )).available('NGN').atomicUnits,
      BigInt.zero,
    );
    expect(
      (await second.read(
        walletSnapshotProvider.future,
      )).available('NGN').atomicUnits,
      greaterThan(BigInt.zero),
    );
  });
  test(
    'synchronous switch never exposes retained wallet data from the old account',
    () async {
      final engine = WalletAccountState()..startSimulation(empty: false);
      final c = ProviderContainer(
        overrides: [walletEngineProvider.overrideWithValue(engine)],
      );
      addTearDown(c.dispose);
      c.listen(currentWalletProvider, (_, _) {});
      await c.read(walletSnapshotProvider.future);
      expect(
        c.read(currentWalletProvider).available('NGN').atomicUnits,
        greaterThan(BigInt.zero),
      );
      engine.startSimulation(empty: true);
      expect(
        c.read(currentWalletProvider).accountId,
        engine.snapshot.accountId,
      );
      expect(
        c.read(currentWalletProvider).available('NGN').atomicUnits,
        BigInt.zero,
      );
    },
  );
}
