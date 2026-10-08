import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/features/profile_settings/presentation/verification/verification_state.dart';

void main() {
  final session = VerificationSession.instance;
  setUp(session.reset);
  tearDown(session.reset);
  test('Basic requires a completed profile and an exact identity number', () {
    expect(() => session.submitBasic(BasicIdentityMethod.nin, '12345678901'),
        throwsStateError);
    session.completeProfile();
    for (final number in ['123', '123456789012', '1234567890a']) {
      expect(() => session.submitBasic(BasicIdentityMethod.bvn, number),
          throwsStateError);
    }
    session.submitBasic(BasicIdentityMethod.bvn, '12345678901');
    expect(session.identifierLastFour, '8901');
    expect(session.basicSubmitted, isTrue);
    expect(session.faceAdded, isFalse);
  });
  test('Advanced enforces face, identity and address in order', () {
    expect(session.canStartAdvanced, isFalse);
    expect(session.addFace, throwsStateError);
    session.completeProfile();
    session.submitBasic(BasicIdentityMethod.nin, '12345678901');
    expect(() => session.addIdentitySide(front: true), throwsStateError);
    session.addFace();
    session.chooseDocument('National ID');
    session.addIdentitySide(front: true);
    expect(session.identityDocumentsAdded, isFalse);
    expect(session.addAddressDocument, throwsStateError);
    session.addIdentitySide(front: false);
    session.chooseAddressDocument('Utility bill');
    session.addAddressDocument();
    session.submitAdvanced();
    expect(session.advancedSubmitted, isTrue);
  });
  test('Changing document types clears corresponding progress', () {
    session.completeProfile();
    session.submitBasic(BasicIdentityMethod.nin, '12345678901');
    session.addFace();
    session.chooseDocument('International passport');
    session.addIdentitySide(front: true);
    expect(session.identityDocumentsAdded, isTrue);
    session.chooseAddressDocument('Utility bill');
    session.addAddressDocument();
    session.chooseAddressDocument('Bank statement');
    expect(session.addressDocumentAdded, isFalse);
    session.chooseDocument('National ID');
    expect(session.identityFrontAdded, isFalse);
    expect(session.identityBackAdded, isFalse);
  });
  test('Reset removes all personal drafts and progress', () {
    session.saveProfile({'first': 'Ada', 'phone': '08012345678'});
    session.completeProfile();
    session.submitBasic(BasicIdentityMethod.nin, '12345678901');
    session.reset();
    expect(session.profileDraft, isEmpty);
    expect(session.identifierLastFour, isNull);
    expect(session.canStartAdvanced, isFalse);
  });
}
