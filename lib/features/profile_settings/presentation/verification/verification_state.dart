import 'package:flutter/foundation.dart';

import '../../../../core/preview/preview_account_state.dart';

enum BasicIdentityMethod {
  nin('NIN', 'National Identification Number'),
  bvn('BVN', 'Bank Verification Number');

  const BasicIdentityMethod(this.shortLabel, this.fullLabel);
  final String shortLabel, fullLabel;
}

/// Session-only presentation progress. No identity is approved by this model.
/// Backend review and native capture/upload providers are separate integrations.
class VerificationSession extends ChangeNotifier {
  VerificationSession._();
  static final instance = VerificationSession._();

  final Map<String, String> profileDraft = {};
  bool profileComplete = false;
  BasicIdentityMethod? identityMethod;
  String? identifierLastFour;
  bool basicSubmitted = false;
  bool faceAdded = false;
  String? identityDocumentType;
  bool identityFrontAdded = false;
  bool identityBackAdded = false;
  String? addressDocumentType;
  bool addressDocumentAdded = false;
  bool advancedSubmitted = false;

  bool get canStartAdvanced => basicSubmitted;
  bool get identityDocumentsAdded =>
      identityFrontAdded &&
      (identityDocumentType == 'International passport' || identityBackAdded);
  int get advancedStep => !faceAdded
      ? 0
      : !identityDocumentsAdded
          ? 1
          : 2;

  void saveProfile(Map<String, String> values) {
    profileDraft.addAll(values);
    notifyListeners();
  }

  void completeProfile() {
    profileComplete = true;
    notifyListeners();
  }

  void chooseIdentity(BasicIdentityMethod method) {
    identityMethod = method;
    notifyListeners();
  }

  void submitBasic(BasicIdentityMethod method, String number) {
    if (!profileComplete || !RegExp(r'^\d{11}$').hasMatch(number)) {
      throw StateError('Complete your profile and enter an 11-digit number.');
    }
    identityMethod = method;
    identifierLastFour = number.substring(7);
    basicSubmitted = true;
    // Expands the dashboard after basic setup; does not grant financial access.
    PreviewAccountState.setupComplete.value = true;
    notifyListeners();
  }

  void addFace() {
    if (!basicSubmitted) throw StateError('Complete Basic verification first.');
    faceAdded = true;
    notifyListeners();
  }

  void chooseDocument(String type) {
    if (identityDocumentType != type) {
      identityDocumentType = type;
      identityFrontAdded = false;
      identityBackAdded = false;
    }
    notifyListeners();
  }

  void addIdentitySide({required bool front}) {
    if (!faceAdded || identityDocumentType == null) {
      throw StateError(
          'Complete facial verification and choose an identity document.');
    }
    if (front) {
      identityFrontAdded = true;
    } else {
      identityBackAdded = true;
    }
    notifyListeners();
  }

  void chooseAddressDocument(String type) {
    if (addressDocumentType != type) addressDocumentAdded = false;
    addressDocumentType = type;
    notifyListeners();
  }

  void addAddressDocument() {
    if (!identityDocumentsAdded || addressDocumentType == null) {
      throw StateError(
          'Complete identity documents and choose proof of address.');
    }
    addressDocumentAdded = true;
    notifyListeners();
  }

  void submitAdvanced() {
    if (!basicSubmitted ||
        !faceAdded ||
        !identityDocumentsAdded ||
        !addressDocumentAdded) {
      throw StateError('Complete the face, identity and address steps.');
    }
    advancedSubmitted = true;
    notifyListeners();
  }

  void reset() {
    profileDraft.clear();
    profileComplete = false;
    identityMethod = null;
    identifierLastFour = null;
    basicSubmitted = false;
    faceAdded = false;
    identityDocumentType = null;
    identityFrontAdded = false;
    identityBackAdded = false;
    addressDocumentType = null;
    addressDocumentAdded = false;
    advancedSubmitted = false;
    PreviewAccountState.setupComplete.value = false;
    notifyListeners();
  }
}
