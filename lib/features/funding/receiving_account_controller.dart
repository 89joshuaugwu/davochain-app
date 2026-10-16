import 'package:flutter/foundation.dart';
import 'receiving_account.dart';
import 'receiving_account_gateway.dart';

class ReceivingAccountController extends ChangeNotifier {
  ReceivingAccountController({required this.gateway, this.load, this.save});
  final ReceivingAccountGateway gateway;
  final Future<ReceivingAccount?> Function(String)? load;
  final Future<void> Function(ReceivingAccount)? save;
  ReceivingAccount current = const ReceivingAccount(
    accountId: '',
    status: ReceivingAccountStatus.unavailable,
  );
  int _epoch = 0, _generation = -1;
  String _name = '';
  Future<void>? _pending;
  bool _disposed = false;
  bool _valid(int epoch) => !_disposed && epoch == _epoch;
  Future<void> activate(
    String account,
    int generation, {
    required String accountName,
  }) {
    if (current.accountId == account &&
        _generation == generation &&
        _pending != null) {
      return _pending!;
    }
    _generation = generation;
    _name = accountName;
    final epoch = ++_epoch;
    current = ReceivingAccount(
      accountId: account,
      status: ReceivingAccountStatus.creating,
    );
    notifyListeners();
    return _pending = _provision(account, epoch);
  }

  Future<void> _provision(
    String account,
    int epoch, {
    bool retry = false,
  }) async {
    try {
      final restored = retry ? null : await load?.call(account);
      if (!_valid(epoch)) return;
      if (restored != null && restored.accountId != account) {
        throw const FormatException('Receiving account mismatch');
      }
      final result = restored?.status == ReceivingAccountStatus.ready
          ? restored!
          : await gateway.provision(
              accountId: account,
              idempotencyKey: 'receiving-v1:$account',
              accountName: _name,
            );
      if (!_valid(epoch)) return;
      if (result.accountId != account) {
        throw const FormatException('Receiving account mismatch');
      }
      if (result.status == ReceivingAccountStatus.ready) {
        await save?.call(result);
      }
      if (!_valid(epoch)) return;
      current = result;
    } catch (_) {
      if (!_valid(epoch)) return;
      current = ReceivingAccount(
        accountId: account,
        status: ReceivingAccountStatus.failed,
      );
    }
    if (_valid(epoch)) notifyListeners();
  }

  Future<void> retry() {
    if (_disposed || current.accountId.isEmpty) return Future.value();
    final account = current.accountId;
    final epoch = ++_epoch;
    current = ReceivingAccount(
      accountId: account,
      status: ReceivingAccountStatus.creating,
    );
    notifyListeners();
    return _pending = _provision(account, epoch, retry: true);
  }

  void deactivate() {
    ++_epoch;
    _generation = -1;
    _pending = null;
    current = const ReceivingAccount(
      accountId: '',
      status: ReceivingAccountStatus.unavailable,
    );
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    ++_epoch;
    super.dispose();
  }
}
