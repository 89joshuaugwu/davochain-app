import 'package:flutter/foundation.dart';

import '../../../../core/preview/preview_account_state.dart';
import '../../verification_media/verification_attachment.dart';

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
  int _generation = 0;
  int get generation => _generation;

  final Map<String, String> profileDraft = {};
  bool profileComplete = false;
  BasicIdentityMethod? identityMethod;
  String? identifierLastFour;
  bool basicSubmitted = false;
  bool get basicVerified => basicSubmitted;
  bool faceAdded = false;
  bool identityVerified = false;
  bool addressVerified = false;
  String? identityDocumentType;
  bool identityFrontAdded = false;
  bool identityBackAdded = false;
  String? addressDocumentType;
  bool addressDocumentAdded = false;
  bool advancedSubmitted = false;
  VerificationAttachment? identityFront,
      identityBack,
      addressAttachment,
      selfie;

  void attachIdentity(VerificationAttachment attachment,
      {required bool front}) {
    if (front) {
      identityFront?.release();
      identityFront = attachment;
    } else {
      identityBack?.release();
      identityBack = attachment;
    }
    addIdentitySide(front: front);
  }

  void attachSelfie(VerificationAttachment attachment) {
    selfie?.release();
    selfie = attachment;
    faceAdded = false;
    identityVerified = false;
    notifyListeners();
  }

  void attachAddress(VerificationAttachment attachment) {
    addressAttachment?.release();
    addressAttachment = attachment;
    addAddressDocument();
  }

  bool get canStartAdvanced => basicSubmitted;
  bool get identityDocumentsAdded => identityFrontAdded;
  int get advancedStep => !identityDocumentsAdded
      ? 0
      : !identityVerified
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
    if (!basicVerified || !identityDocumentsAdded) {
      throw StateError('Complete Basic verification and upload your ID first.');
    }
    faceAdded = true;
    notifyListeners();
  }

  void chooseDocument(String type) {
    if (identityDocumentType != type) {
      identityFront?.release();
      identityBack?.release();
      selfie?.release();
      identityFront = null;
      identityBack = null;
      selfie = null;
      identityDocumentType = type;
      identityFrontAdded = false;
      identityBackAdded = false;
      faceAdded = false;
      identityVerified = false;
      addressVerified = false;
      advancedSubmitted = false;
    }
    notifyListeners();
  }

  void addIdentitySide({required bool front}) {
    if (!basicVerified || identityDocumentType == null) {
      throw StateError(
          'Complete Basic verification and choose an identity document.');
    }
    if (front) {
      identityFrontAdded = true;
    } else {
      identityBackAdded = true;
    }
    notifyListeners();
  }

  void verifyIdentity() {
    if (!basicVerified || !identityDocumentsAdded || !faceAdded) {
      throw StateError('Upload your ID and complete facial verification.');
    }
    identityVerified = true;
    notifyListeners();
  }

  void removeIdentityFront() {
    identityFront?.release();
    selfie?.release();
    identityFront = null;
    selfie = null;
    identityFrontAdded = false;
    faceAdded = false;
    identityVerified = false;
    addressVerified = false;
    advancedSubmitted = false;
    notifyListeners();
  }

  void chooseAddressDocument(String type) {
    if (addressDocumentType != type) {
      addressAttachment?.release();
      addressAttachment = null;
      addressDocumentAdded = false;
      addressVerified = false;
      advancedSubmitted = false;
    }
    addressDocumentType = type;
    notifyListeners();
  }

  void addAddressDocument() {
    if (!identityVerified || addressDocumentType == null) {
      throw StateError(
          'Complete identity documents and choose proof of address.');
    }
    addressDocumentAdded = true;
    notifyListeners();
  }

  void removeAddressDocument() {
    addressAttachment?.release();
    addressAttachment = null;
    addressDocumentAdded = false;
    addressVerified = false;
    advancedSubmitted = false;
    notifyListeners();
  }

  void submitAdvanced() {
    if (!basicSubmitted ||
        !faceAdded ||
        !identityDocumentsAdded ||
        !identityVerified ||
        !addressDocumentAdded) {
      throw StateError('Complete the face, identity and address steps.');
    }
    advancedSubmitted = true;
    addressVerified = true;
    notifyListeners();
  }

  void reset() {
    for (final attachment in [
      identityFront,
      identityBack,
      addressAttachment,
      selfie
    ]) {
      attachment?.release();
    }
    identityFront = null;
    identityBack = null;
    addressAttachment = null;
    selfie = null;
    _generation++;
    profileDraft.clear();
    profileComplete = false;
    identityMethod = null;
    identifierLastFour = null;
    basicSubmitted = false;
    faceAdded = false;
    identityVerified = false;
    addressVerified = false;
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
