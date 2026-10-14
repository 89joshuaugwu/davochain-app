class SessionToken {
  const SessionToken(this.accountId, this.generation);
  final String accountId;
  final int generation;
}

/// Every accepted asynchronous response belongs to the initiating session.
class SessionContext {
  SessionContext(this.accountId);
  String accountId;
  int generation = 0;
  SessionToken capture() => SessionToken(accountId, generation);
  bool accepts(SessionToken token) =>
      token.accountId == accountId && token.generation == generation;
  void switchAccount(String id) {
    accountId = id;
    generation++;
  }

  void revoke() {
    accountId = '';
    generation++;
  }
}
