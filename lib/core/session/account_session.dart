import 'package:flutter/foundation.dart';

@immutable
class AccountSession {
  const AccountSession(this.accountId, this.generation);
  final String accountId;
  final int generation;
  @override
  bool operator ==(Object other) =>
      other is AccountSession &&
      other.accountId == accountId &&
      other.generation == generation;
  @override
  int get hashCode => Object.hash(accountId, generation);
}
