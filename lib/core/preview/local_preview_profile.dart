import '../../features/wallets/wallet_repository.dart';
import 'package:flutter/foundation.dart';
import '../../features/profile_settings/presentation/verification/verification_state.dart';
import '../../features/funding/funding_outcomes.dart';
import '../../shared/receipts/receipt_activity.dart';
import 'settings_preview_session.dart';
import 'preview_account_state.dart';
import 'preview_auth_state.dart';

/// Local display identity only; never an authenticated or backend KYC record.
class LocalPreviewProfile extends ChangeNotifier {
  LocalPreviewProfile._() {
    VerificationSession.instance.addListener(_verificationChanged);
  }
  static final instance = LocalPreviewProfile._();
  String fullName = 'Vincent Chukwu',
      email = 'chukwuvncnt1@gmail.com',
      phone = '+234 9062185004',
      country = 'Nigeria',
      username = 'Admiral',
      dateOfBirth = '1996-08-24',
      address = 'Flat A2, Guzape Estate, Abuja';
  bool sampleAvatar = true;
  Uint8List? photo;
  int generation = 0;
  void _resetSession() {
    WalletAccountState.instance.reset();
    ReceiptActivity.reset();
    FundingActivity.reset();
    SettingsPreviewSession.instance.reset();
    PreviewAccountState.notificationInbox.reset();
    PreviewAccountState.notificationPreferences.fillRange(0, 11, true);
    for (final channels in PreviewAccountState.notificationChannels) {
      channels.setAll(0, [true, false, false]);
    }
    VerificationSession.instance.reset();
  }

  String get firstName => fullName.split(' ').first;
  Map<String, String> get personalFields => {
        'Full name': fullName,
        'Email': email,
        'Phone Number': phone,
        'Country': country,
        'Username': username,
        'Date of Birth': dateOfBirth,
        'Residential Address': address,
      };
  void register(
      {required String name, required String email, required String phone}) {
    generation++;
    _resetSession();
    PreviewAuthState.resetSession();
    fullName = name.trim();
    this.email = email.trim();
    this.phone = phone;
    username = '';
    dateOfBirth = '';
    address = '';
    country = 'Nigeria';
    sampleAvatar = false;
    photo = null;
    final parts = fullName.split(RegExp(r'\s+'));
    VerificationSession.instance.saveProfile({
      'first': parts.first,
      'last': parts.length > 1 ? parts.skip(1).join(' ') : '',
      'phone':
          phone.replaceAll(RegExp(r'\D'), '').replaceFirst(RegExp(r'^234'), '')
    });
    notifyListeners();
  }

  void loginSample() {
    generation++;
    _resetSession();
    PreviewAuthState.resetSession(samplePin: true);
    fullName = 'Vincent Chukwu';
    email = 'chukwuvncnt1@gmail.com';
    phone = '+234 9062185004';
    country = 'Nigeria';
    username = 'Admiral';
    dateOfBirth = '1996-08-24';
    address = 'Flat A2, Guzape Estate, Abuja';
    sampleAvatar = true;
    photo = null;
    notifyListeners();
  }

  void setUsername(String value) {
    username = value;
    VerificationSession.instance.saveProfile({'username': value});
  }

  void setPhoto(Uint8List bytes) {
    photo = bytes;
    sampleAvatar = false;
    notifyListeners();
  }

  void _verificationChanged() {
    final session = VerificationSession.instance;
    if (session.basicVerified) {
      final draft = session.profileDraft;
      final name = ['first', 'middle', 'last']
          .map((key) => draft[key] ?? '')
          .where((v) => v.trim().isNotEmpty)
          .join(' ');
      if (name.isNotEmpty) fullName = name;
      if (draft['dob']?.isNotEmpty == true) dateOfBirth = draft['dob']!;
      if (draft['address']?.isNotEmpty == true) address = draft['address']!;
      if (draft['phone']?.isNotEmpty == true) {
        phone = '+234 ${draft['phone']!.replaceFirst(RegExp(r'^0'), '')}';
      }
    }
    notifyListeners();
  }
}
