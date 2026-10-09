import 'package:flutter/foundation.dart';

@immutable
class LinkedBank {
  const LinkedBank(
      {required this.bank, required this.number, required this.name});
  final String bank, number, name;
  String get maskedNumber => '•••• ${number.substring(number.length - 4)}';
}

@immutable
class SupportTicket {
  const SupportTicket(
      {required this.reference,
      required this.subject,
      required this.message,
      required this.orderId,
      required this.createdAt});
  final String reference, subject, message, orderId;
  final DateTime createdAt;
}

@immutable
class RewardRedemption {
  const RewardRedemption(
      {required this.reference,
      required this.points,
      required this.creditKobo,
      required this.createdAt});
  final String reference;
  final int points, creditKobo;
  final DateTime createdAt;
}

@immutable
class DeletionRequest {
  const DeletionRequest(
      {required this.reference, required this.reason, required this.createdAt});
  final String reference, reason;
  final DateTime createdAt;
}

/// Frontend fixtures only. Replace the gateway with authenticated services.
abstract class SettingsGateway {
  const SettingsGateway();
  Future<LinkedBank> resolveBank(String bank, String number);
  Future<void> linkBank(LinkedBank account);
  Future<void> changePassword(String current, String next);
  Future<SupportTicket> submitSupport(
      String subject, String message, String orderId);
  Future<RewardRedemption> redeemPoints(int points);
  Future<DeletionRequest> requestDeletion(String reason);
}

class PreviewSettingsGateway extends SettingsGateway {
  const PreviewSettingsGateway();
  static int _sequence = 0;
  Future<void> _wait() =>
      Future<void>.delayed(const Duration(milliseconds: 350));
  String _reference(String type) => 'PREVIEW-$type-${++_sequence}';
  @override
  Future<LinkedBank> resolveBank(String bank, String number) async {
    await _wait();
    if (!RegExp(r'^\d{10}$').hasMatch(number)) {
      throw const FormatException('Enter a 10-digit account number.');
    }
    return LinkedBank(
        bank: bank, number: number, name: 'Callietus Ezeike Chinecherem');
  }

  @override
  Future<void> linkBank(LinkedBank account) => _wait();
  @override
  Future<void> changePassword(String current, String next) => _wait();
  @override
  Future<SupportTicket> submitSupport(
      String subject, String message, String orderId) async {
    await _wait();
    return SupportTicket(
        reference: _reference('SUPPORT'),
        subject: subject,
        message: message,
        orderId: orderId,
        createdAt: DateTime.now());
  }

  @override
  Future<RewardRedemption> redeemPoints(int points) async {
    await _wait();
    return RewardRedemption(
        reference: _reference('REWARD'),
        points: points,
        creditKobo: points * 5,
        createdAt: DateTime.now());
  }

  @override
  Future<DeletionRequest> requestDeletion(String reason) async {
    await _wait();
    return DeletionRequest(
        reference: _reference('DELETE'),
        reason: reason,
        createdAt: DateTime.now());
  }
}

class SettingsPreviewSession extends ChangeNotifier {
  SettingsPreviewSession._();
  static final instance = SettingsPreviewSession._();
  static const _samples = [
    LinkedBank(bank: 'Access Bank', number: '0003487409', name: 'Jenny V.'),
    LinkedBank(bank: 'GTBank', number: '0003487409', name: 'Jenny V.'),
    LinkedBank(bank: 'Opay Bank', number: '0003487409', name: 'Jenny V.'),
  ];
  final List<LinkedBank> _banks = [..._samples];
  final List<SupportTicket> _tickets = [];
  final List<RewardRedemption> _redemptions = [];
  List<LinkedBank> get banks => List.unmodifiable(_banks);
  List<SupportTicket> get tickets => List.unmodifiable(_tickets);
  List<RewardRedemption> get redemptions => List.unmodifiable(_redemptions);
  int generation = 0;
  int get earnedPoints => 15;
  int get redeemedPoints => _redemptions.fold(0, (sum, r) => sum + r.points);
  int get availablePoints => earnedPoints - redeemedPoints;
  int get rewardCreditKobo =>
      _redemptions.fold(0, (sum, r) => sum + r.creditKobo);
  bool passwordChanged = false;
  DeletionRequest? deletionRequest;

  bool acceptBank(LinkedBank bank) {
    if (!RegExp(r'^\d{10}$').hasMatch(bank.number) ||
        _banks.any((b) => b.bank == bank.bank && b.number == bank.number)) {
      return false;
    }
    _banks.add(bank);
    notifyListeners();
    return true;
  }

  void acceptTicket(SupportTicket ticket) {
    if (_tickets.any((t) => t.reference == ticket.reference)) return;
    _tickets.insert(0, ticket);
    notifyListeners();
  }

  bool acceptRedemption(RewardRedemption redemption) {
    if (redemption.points <= 0 ||
        redemption.points > availablePoints ||
        redemption.creditKobo != redemption.points * 5 ||
        _redemptions.any((r) => r.reference == redemption.reference)) {
      return false;
    }
    _redemptions.insert(0, redemption);
    notifyListeners();
    return true;
  }

  void markPasswordChanged() {
    passwordChanged = true;
    notifyListeners();
  }

  void acceptDeletion(DeletionRequest request) {
    deletionRequest = request;
    notifyListeners();
  }

  void reset() {
    generation++;
    _banks
      ..clear()
      ..addAll(_samples);
    _tickets.clear();
    _redemptions.clear();
    passwordChanged = false;
    deletionRequest = null;
    notifyListeners();
  }
}
