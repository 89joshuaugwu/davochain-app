import '../../core/session/session_context.dart';

class AuthChallenge {
  const AuthChallenge(
      {required this.id,
      required this.channel,
      required this.maskedDestination,
      required this.expiresAt,
      required this.resendAt});
  final String id, channel, maskedDestination;
  final DateTime expiresAt, resendAt;
}

/// Provider implementation must enforce ownership, expiry and throttling.
abstract interface class AuthRepository {
  Future<AuthChallenge> register(
      {required String name,
      required String email,
      required String phone,
      required String password});
  Future<SessionToken> login({required String email, required String password});
  Future<AuthChallenge> resend(String challengeId);
  Future<void> verify({required String challengeId, required String code});
  Future<void> revokeSession();
  Future<String> authorizeTransaction(
      {required String quoteId, required String pin});
}
