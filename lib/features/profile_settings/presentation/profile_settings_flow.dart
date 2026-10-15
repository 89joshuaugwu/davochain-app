import '../../../shared/motion/davo_motion_policy.dart';
import '../../../shared/widgets/davo_refresh_region.dart';
import '../../notifications/notification_inbox.dart';
import '../../transactions/presentation/transaction_history_screen.dart';
import 'notification_detail_screen.dart';
import '../../../shared/motion/davo_empty_bell.dart';
import '../../../shared/widgets/davo_main_shell.dart';
import '../../../core/preview/local_preview_profile.dart';
import '../../../shared/widgets/local_profile_avatar.dart';
import 'settings_content_overlay.dart';
import '../../../shared/formatters/nigerian_phone_formatter.dart';
import '../../security_questions/presentation/security_questions_screens.dart';
import '../../security_questions/security_questions_service.dart';
import '../../../shared/receipts/receipt_activity.dart';
import 'appearance_screen.dart';
export 'appearance_screen.dart';
import 'support_conversation_screens.dart';
export 'support_conversation_screens.dart';
import '../../../shared/widgets/davo_points_coin.dart';
import 'settings_action_flows.dart';
export 'settings_action_flows.dart';
import '../../../core/preview/settings_preview_session.dart';
import '../../funding/funding_outcomes.dart';
import '../../../shared/motion/davo_outcome_content.dart';
import 'verification/verification_overview_screen.dart';
import 'verification/verification_state.dart';
import '../../../shared/widgets/davo_state_picker.dart';
import '../../../shared/widgets/davo_resend_row.dart';
import 'dart:async';
import '../../../shared/widgets/davo_toast.dart';
import '../../../shared/widgets/davo_result_screen.dart';
import '../../../core/preview/preview_auth_state.dart';
import '../../auth/presentation/login_flow.dart';
import '../../../core/device/biometric_gateway.dart';
import '../../auth/presentation/returning_unlock_screen.dart';
import '../../onboarding/presentation/brand_splash_screen.dart';
import '../../../shared/widgets/davo_success_mark.dart';
import '../../../shared/widgets/davo_date_picker.dart';
import '../../../core/preview/preview_account_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/services.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/inline_input_decoration.dart';
import '../../../shared/widgets/davochain_logo_lockup.dart';

part 'profile_components.dart';
part 'profile_notification_screens.dart';
part 'profile_pin_screens.dart';
part 'fingerprint_settings_screen.dart';
part 'profile_kyc_screens.dart';
part 'profile_support_rewards_screens.dart';

const _notificationEmpty = 'assets/figma_exact/notification_empty_poster.png';
const _exactAssets = 'assets/figma_exact';
const _rankPortrait = 'assets/figma_exact/leaderboard_row_portrait_exact.png';

Future<void> startProfileSettingsFlow(BuildContext context) =>
    selectDavoMainTab(context, 3);
Future<void> openNotificationCenter(BuildContext context) =>
    pushAppPage<void>(context, (_) => const NotificationCenterScreen());

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen(
      {super.key, this.onBack, this.embeddedMain = false});
  final VoidCallback? onBack;
  final bool embeddedMain;
  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  @override
  void initState() {
    super.initState();
    PreviewAuthState.biometricsEnabled.addListener(_refreshBiometrics);
    LocalPreviewProfile.instance.addListener(_refreshBiometrics);
  }

  void _refreshBiometrics() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    PreviewAuthState.biometricsEnabled.removeListener(_refreshBiometrics);
    LocalPreviewProfile.instance.removeListener(_refreshBiometrics);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _Shell(
      title: 'Profile',
      onBack: widget.onBack,
      showBack: !widget.embeddedMain || widget.onBack != null,
      titleStyle: _navSora20Medium(context),
      scroll: true,
      showHeaderDivider: true,
      bodyTopPadding: 24,
      child: Column(
        children: [
          const _ProfileAvatar(),
          const SizedBox(height: 16),
          Text(LocalPreviewProfile.instance.fullName, style: _t16b(context)),
          const SizedBox(height: 4),
          Text(LocalPreviewProfile.instance.email,
              style: _t16ProfileSub(context)),
          const SizedBox(height: 24),
          _MenuCard(
            title: 'Accounts',
            items: [
              _MenuItem(
                  '$_exactAssets/icon_personal_information.png',
                  'Personal Information',
                  () => _push(context, const PersonalInformationV12Screen())),
              _MenuItem(
                  '$_exactAssets/icon_kyc.png',
                  'KYC Verification',
                  () => Navigator.of(context).push(AppPageRoute<void>(
                      settings: const RouteSettings(name: 'verification'),
                      builder: (_) => const VerificationOverviewScreen()))),
              _MenuItem(
                  '$_exactAssets/icon_linked_accounts.png',
                  'Linked Accounts',
                  () => _push(context, const LinkedAccountsScreen())),
            ],
          ),
          const SizedBox(height: 24),
          _MenuCard(
            title: 'Security',
            items: [
              _MenuItem(
                '$_exactAssets/icon_biometrics.png',
                'Fingerprint',
                () => _push(context, const FingerprintSettingsScreen()),
              ),
              _MenuItem('$_exactAssets/icon_lock.png', 'Change Password',
                  () => _push(context, const ChangePasswordScreen())),
              _MenuItem('$_exactAssets/icon_lock.png', 'Transaction Pin',
                  () => _push(context, const ResetPinStartScreen())),
              _MenuItem(
                  '$_exactAssets/icon_lock.png',
                  'Security questions',
                  () =>
                      _push(context, const SecurityQuestionsSettingsScreen())),
              _MenuItem('$_exactAssets/icon_lock.png', 'Crypto Security',
                  () => _push(context, const CryptoSecurityScreen())),
            ],
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () {
              PreviewAuthState.unlocked.value = false;
              _push(
                  context,
                  BrandSplashScreen(
                      destinationBuilder: (_) =>
                          const ReturningUnlockScreen()));
            },
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.lock_outline_rounded, size: 18),
              SizedBox(width: 8),
              Flexible(child: Text('Lock app')),
            ]),
          ),
          _MenuCard(
            title: 'Preferences',
            items: [
              _MenuItem('$_exactAssets/icon_notifications.png', 'Notifications',
                  () => _push(context, const NotificationsPreferencesScreen())),
              _MenuItem('$_exactAssets/icon_privacy.png', 'Privacy',
                  () => _push(context, const PrivacyScreen())),
              _MenuItem(
                  '$_exactAssets/icon_notification_settings.png',
                  'Notification Settings',
                  () => _push(context, const NotificationSettingsScreen())),
              _MenuItem('$_exactAssets/icon_appearance.png', 'Appearance',
                  () => _push(context, const AppearanceScreen())),
            ],
          ),
          const SizedBox(height: 24),
          _MenuCard(
            title: 'GENERAL',
            items: [
              _MenuItem(
                  '$_exactAssets/icon_customer_support.png',
                  'Customer Support',
                  () => _push(context, const CustomerSupportScreen())),
              _MenuItem(
                  '$_exactAssets/icon_privacy_policy.png',
                  'Privacy Policy',
                  () => showSettingsContent(context, 'Privacy Policy')),
              _MenuItem('$_exactAssets/icon_faq.png', 'FAQs',
                  () => showSettingsContent(context, 'FAQs')),
              _MenuItem('$_exactAssets/icon_terms.png', 'Terms and Condition',
                  () => showSettingsContent(context, 'Terms and Condition')),
              _MenuItem('$_exactAssets/icon_about.png', 'About Us',
                  () => showSettingsContent(context, 'About Us')),
            ],
          ),
          const SizedBox(height: 16),
          _ProfileActionRow(
            asset: '$_exactAssets/icon_logout.png',
            label: 'Logout',
            onTap: () => _logoutDialog(context),
          ),
          const SizedBox(height: 16),
          _ProfileActionRow(
            asset: '$_exactAssets/icon_trash.png',
            label: 'Delete Account',
            destructive: true,
            onTap: () => _deleteAccountDialog(context),
          ),
          const SizedBox(height: 16),
          const SizedBox(height: 34),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar();
  @override
  Widget build(BuildContext context) =>
      const LocalProfileAvatar(key: ValueKey('profile-avatar'));
}

class AccountInformationScreen extends StatelessWidget {
  const AccountInformationScreen({super.key});
  @override
  Widget build(BuildContext context) => const PersonalInformationV12Screen();
}

class TransactionLimitsScreen extends StatelessWidget {
  const TransactionLimitsScreen({super.key});
  @override
  Widget build(BuildContext context) => _Shell(
      title: 'Transaction Limits',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 24),
        Text('Choose an account to view transaction limits',
            style: _t16b(context)),
        const SizedBox(height: 4),
        Text('Limits may vary based on account type and verification level',
            style: _t12(context)),
        const SizedBox(height: 24),
        _AccountLimitTile(
            flag: '🇺🇸',
            title: 'US Currency',
            subtitle: 'USD Account Limits',
            onTap: () =>
                _push(context, const _LimitDetailScreen(kind: _LimitKind.usd))),
        const SizedBox(height: 12),
        _AccountLimitTile(
            flag: '🇳🇬',
            title: 'Nigeria Currency (NG)',
            subtitle: 'NGN Account Limits',
            onTap: () =>
                _push(context, const _LimitDetailScreen(kind: _LimitKind.ngn))),
        const SizedBox(height: 12),
        _AccountLimitTile(
            flag: '₿',
            title: 'Crypto Currency',
            subtitle: 'Manage Crypto currency Limits',
            onTap: () => _push(
                context, const _LimitDetailScreen(kind: _LimitKind.crypto))),
      ]));
}

enum _LimitKind { usd, ngn, crypto }

class _LimitDetailScreen extends StatefulWidget {
  const _LimitDetailScreen({required this.kind});
  final _LimitKind kind;
  @override
  State<_LimitDetailScreen> createState() => _LimitDetailScreenState();
}

class _LimitDetailScreenState extends State<_LimitDetailScreen> {
  bool second = false;
  @override
  Widget build(BuildContext context) {
    final isUsd = widget.kind == _LimitKind.usd,
        isNgn = widget.kind == _LimitKind.ngn;
    final title = isUsd
        ? 'USD Limits'
        : isNgn
            ? 'NGN Limits'
            : 'Crypto Currency';
    final single = isUsd
        ? '\$2,500.00'
        : isNgn
            ? '₦1,000,000.00'
            : '\$1,000,000.00';
    final daily = isUsd
        ? '\$2,500.00'
        : isNgn
            ? '₦3,000,000.00'
            : '\$3,000,000.00';
    final weekly = isUsd
        ? '\$10,500.00'
        : isNgn
            ? '₦5,000,000.00'
            : '\$5,000,000.00';
    final monthly = isUsd
        ? '\$50,000.00'
        : isNgn
            ? '₦40,000,000.00'
            : '\$40,000,000.00';
    return _Shell(
        title: 'Transaction Limits',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 22),
          Row(children: [
            Text(
                widget.kind == _LimitKind.ngn
                    ? '🇳🇬'
                    : widget.kind == _LimitKind.usd
                        ? '🇺🇸'
                        : '₿',
                style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 10),
            Text(title, style: _t16b(context)),
            const SizedBox(width: 10),
            const _Pill('Limits')
          ]),
          const SizedBox(height: 20),
          _Segment(
              left: widget.kind == _LimitKind.crypto
                  ? 'Limits on Withdrawal'
                  : 'Limits on Send',
              right: widget.kind == _LimitKind.crypto
                  ? 'Limits on Deposit'
                  : 'Limits on receive',
              rightSelected: second,
              onChanged: (v) => setState(() => second = v)),
          const SizedBox(height: 24),
          _limitBanner(context, 'Single Transaction Limits of $single'),
          const SizedBox(height: 18),
          _ProgressLimit('Daily Limit of $daily', daily),
          const SizedBox(height: 16),
          _ProgressLimit('Weekly Limit of $weekly', weekly),
          const SizedBox(height: 16),
          _ProgressLimit('Monthly Limit of $monthly', monthly),
          const Spacer(),
          _PrimaryButton('Increase Transfer Limits',
              onTap: () => Navigator.of(context).push(AppPageRoute<void>(
                  settings: const RouteSettings(name: 'verification'),
                  builder: (_) => const VerificationOverviewScreen()))),
          const SizedBox(height: 28)
        ]));
  }
}

class IncreaseLimitsScreen extends StatelessWidget {
  const IncreaseLimitsScreen({super.key});
  @override
  Widget build(BuildContext context) => _Shell(
      title: 'Transaction Limits',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 20),
        Text('Increase Transfer Limits', style: _t20(context)),
        const SizedBox(height: 4),
        Text(
            'Complete the sections below to unlock higher account limits. Approval typically takes 2–3 days.',
            style: _t12(context)),
        const SizedBox(height: 28),
        _ActionCard(
            '$_exactAssets/profile_location_exact.png',
            'Verify Address',
            'Face to face verification at your address',
            () => _push(context, const AddressUpgradeScreen())),
        const SizedBox(height: 14),
        _ActionCard(
            '$_exactAssets/profile_document_exact.png',
            'Proof of Address',
            'Upload electricity bill, water bill',
            () => _push(context, const AddressUpgradeScreen()))
      ]));
}

class AddressUpgradeScreen extends StatelessWidget {
  const AddressUpgradeScreen({super.key});
  @override
  Widget build(BuildContext context) => _Shell(
      title: 'Transaction Limits',
      scroll: true,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 18),
        Text('Confirm Your Address', style: _t20(context)),
        const SizedBox(height: 18),
        const _Bullet(
            'Your document should be dated within the last 3 months and clearly show your name and address'),
        const _Bullet(
            'Take a clear, full photo of your document, no cropped edges or blurry shots'),
        const _Bullet(
            'Upload it as-is — no edits, filters, or photos taken from a screen'),
        const SizedBox(height: 24),
        _docOption(context, 'Utility Bill', 'Dated within the last 3 months'),
        _docOption(context, 'Bank Statement',
            'From a different bank, showing your current address, dated within the last 6 months'),
        _docOption(context, 'Tenancy Agreement',
            'Renting? Upload your tenancy agreement along with a utility bill from your landlord confirming your address'),
        const SizedBox(height: 28),
        _PrimaryButton('Choose document to upload',
            onTap: () => _uploadSheet(context, 'Upload ID')),
        const SizedBox(height: 24)
      ]));
}

class PersonalInformationV12Screen extends StatefulWidget {
  const PersonalInformationV12Screen({super.key});
  @override
  State<PersonalInformationV12Screen> createState() =>
      _PersonalInformationV12ScreenState();
}

class _PersonalInformationV12ScreenState
    extends State<PersonalInformationV12Screen> {
  bool editing = false;
  Uint8List? _photoDraft;
  int _profileGeneration = LocalPreviewProfile.instance.generation;
  late final username =
      TextEditingController(text: LocalPreviewProfile.instance.username);
  Map<String, String> get values => LocalPreviewProfile.instance.personalFields;
  @override
  void initState() {
    super.initState();
    LocalPreviewProfile.instance.addListener(_refreshProfile);
  }

  void _refreshProfile() {
    final profile = LocalPreviewProfile.instance;
    if (_profileGeneration != profile.generation) {
      _profileGeneration = profile.generation;
      _photoDraft = null;
      editing = false;
      username.text = profile.username;
    }
    if (mounted) setState(() {});
  }

  bool get valid =>
      RegExp(r'^[a-zA-Z0-9_]{3,24}$').hasMatch(username.text.trim()) ||
      (_photoDraft != null &&
          username.text.trim() == LocalPreviewProfile.instance.username);
  @override
  void dispose() {
    LocalPreviewProfile.instance.removeListener(_refreshProfile);
    username.dispose();
    super.dispose();
  }

  void _edit() => setState(() => editing = true);
  void _save() {
    if (!valid) return;
    FocusManager.instance.primaryFocus?.unfocus();
    final value = username.text.trim();
    if (value != LocalPreviewProfile.instance.username) {
      LocalPreviewProfile.instance.setUsername(value);
    }
    if (_photoDraft != null) {
      LocalPreviewProfile.instance.setPhoto(_photoDraft!);
      _photoDraft = null;
    }
    setState(() {
      editing = false;
    });
    _push(context, const PersonalInformationSuccessScreen());
  }

  @override
  Widget build(BuildContext context) => _Shell(
      title: 'Personal Information',
      titleStyle: _navSora20Medium(context),
      scroll: true,
      showHeaderDivider: true,
      bodyTopPadding: 24,
      child: Column(children: [
        LocalProfileAvatar(
            key: const ValueKey('personal-profile-avatar'),
            editable: true,
            previewPhoto: _photoDraft,
            onPhotoSelected: (bytes) => setState(() {
                  _photoDraft = bytes;
                  editing = true;
                })),
        const SizedBox(height: 24),
        for (final entry in values.entries)
          if (entry.key == 'Username' && editing)
            Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 19),
                decoration: BoxDecoration(
                    color: DavoColors.of(context).offWhite,
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Username', style: _personalInfoLabel(context)),
                      const SizedBox(height: 8),
                      TextField(
                          key: const Key('personal-username-input'),
                          controller: username,
                          onChanged: (_) => setState(() {}),
                          style: _t14(context),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(24)
                          ],
                          decoration: const DavoInlineInputDecoration(
                              hintText: 'Choose a username')),
                      if (!valid)
                        Text('Use 3-24 letters, numbers or underscores.',
                            style: TextStyle(
                                fontSize: 12,
                                color: DavoColors.of(context).danger))
                    ]))
          else
            _InfoField(
                label: entry.key,
                value: entry.key == 'Username' ? username.text : entry.value,
                trailing: entry.key == 'Username'
                    ? IconButton(
                        tooltip: 'Edit username',
                        onPressed: _edit,
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(minWidth: 32, minHeight: 32),
                        icon: Image.asset(
                            '$_exactAssets/profile_edit_outline_exact.png',
                            width: 24,
                            height: 24,
                            color: DavoColors.of(context).body))
                    : VerificationSession.instance.basicVerified &&
                            const {
                              'Email',
                              'Phone Number',
                              'Country',
                              'Residential Address'
                            }.contains(entry.key)
                        ? Semantics(
                            label: '${entry.key}, verified details, read only',
                            child: Image.asset(
                                '$_exactAssets/profile_tick_square_exact.png',
                                width: 24,
                                height: 24,
                                color: DavoColors.of(context).body))
                        : null),
        const SizedBox(height: 21),
        _PrimaryButton(editing ? 'Save Changes' : 'Edit Information',
            enabled: !editing || valid, onTap: editing ? _save : _edit),
        const SizedBox(height: 20),
        TextButton.icon(
            onPressed: () => _deleteAccountDialog(context),
            icon: Icon(Icons.delete_outline,
                size: 24, color: DavoColors.of(context).danger),
            label: Text('Delete Account',
                style: TextStyle(
                    color: DavoColors.of(context).danger, fontFamily: 'Sora'))),
        const SizedBox(height: 20)
      ]));
}

class CryptoSecurityScreen extends StatefulWidget {
  const CryptoSecurityScreen({super.key});
  @override
  State<CryptoSecurityScreen> createState() => _CryptoSecurityScreenState();
}

class _CryptoSecurityScreenState extends State<CryptoSecurityScreen> {
  bool withdraw = true, address = true, network = true;
  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Crypto Security',
        titleStyle: _navSora16(context),
        scroll: true,
        bodyTopPadding: 24,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Extra protection for your digital assets',
              style: _t12(context)),
          const SizedBox(height: 24),
          _PreferenceRow(
              asset: 'withdrawal_confirmation',
              title: 'Withdrawal Confirmation',
              subtitle: 'Require PIN before every withdraw',
              value: withdraw,
              onChanged: (v) => setState(() => withdraw = v)),
          const SizedBox(height: 20),
          _PreferenceRow(
              asset: 'address_verification',
              title: 'New Address Verification',
              subtitle:
                  'Require additional confirmation when sending to a new address',
              value: address,
              onChanged: (v) => setState(() => address = v)),
          const SizedBox(height: 20),
          _PreferenceRow(
              asset: 'network_warning',
              title: 'Network Warning',
              subtitle: 'Show network warning before every external withdrawal',
              value: network,
              onChanged: (v) => setState(() => network = v)),
        ]),
      );
}

class NotificationsPreferencesScreen extends StatefulWidget {
  const NotificationsPreferencesScreen({super.key});
  @override
  State<NotificationsPreferencesScreen> createState() =>
      _NotificationsPreferencesScreenState();
}

class _NotificationsPreferencesScreenState
    extends State<NotificationsPreferencesScreen> {
  final vals = PreviewAccountState.notificationPreferences;
  static const items = <({String asset, String title, String sub})>[
    (
      asset: 'crypto_purchases',
      title: 'Crypto purchases',
      sub: 'Get notification When you buy crypto'
    ),
    (
      asset: 'crypto_sales',
      title: 'Crypto Sales',
      sub: 'Get notified when you sell crypto'
    ),
    (
      asset: 'crypto_swaps',
      title: 'Crypto Swaps',
      sub: 'Get notified when you swap crypto'
    ),
    (
      asset: 'deposits',
      title: 'Deposits',
      sub: 'Get notified when you receive crypto'
    ),
    (
      asset: 'withdrawals',
      title: 'Withdrawals',
      sub: 'Get notified when you send crypto'
    ),
    (
      asset: 'gift_cards',
      title: 'Gift card transaction',
      sub: 'Get notified about gift card activity'
    ),
    (
      asset: 'security_alerts',
      title: 'Security alerts',
      sub: 'Important security notifications'
    ),
    (
      asset: 'login_activity',
      title: 'Login activity',
      sub: 'Get notified about new logins'
    ),
    (
      asset: 'promotions',
      title: 'Promotion & Offers',
      sub: 'Receive special offers and discounts'
    ),
    (
      asset: 'product_updates',
      title: 'Product updates',
      sub: 'Get the latest news and features'
    ),
    (
      asset: 'tips_education',
      title: 'Tips & Education',
      sub: 'Learn about crypto and gift cards'
    ),
  ];
  Widget group(String title, int start, int end) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: _t14(context)),
        const SizedBox(height: 12),
        _PreferenceGroup(children: [
          for (var i = start; i < end; i++)
            _PreferenceRow(
                asset: items[i].asset,
                title: items[i].title,
                subtitle: items[i].sub,
                value: vals[i],
                onChanged: (v) => setState(() => vals[i] = v)),
        ]),
      ]);
  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Notifications',
        titleStyle: _navSora16(context),
        scroll: true,
        bodyTopPadding: 24,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          group('Transaction Alerts', 0, 6),
          const SizedBox(height: 24),
          group('Account Alerts', 6, 8),
          const SizedBox(height: 24),
          group('Marketing & Updates', 8, 11),
        ]),
      );
}

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});
  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool contacts = true,
      personalized = true,
      marketing = false,
      analytics = true;
  void _details(String title, String text) => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => SafeArea(
            child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _navSora16(sheetContext)),
                const SizedBox(height: 12),
                Text(text, style: _t12(sheetContext)),
                const SizedBox(height: 16),
                Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        child: const Text('Done'))),
              ]),
        )),
      );
  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Privacy',
        titleStyle: _navSora16(context),
        scroll: true,
        bodyTopPadding: 24,
        child: _PreferenceGroup(children: [
          _PreferenceRow(
              asset: 'contact_access',
              title: 'Contact Access',
              subtitle:
                  'Allow Davochain to access your contacts to help you find people you may want to transact with',
              value: contacts,
              onChanged: (v) => setState(() => contacts = v)),
          _PreferenceRow(
              asset: 'personalized_experience',
              title: 'Personalized Experience',
              subtitle:
                  'Allow personalized recommendation based on your activity',
              value: personalized,
              onChanged: (v) => setState(() => personalized = v)),
          _PreferenceRow(
              asset: 'marketing_communications',
              title: 'Markets Communications',
              subtitle: 'Receive promotional emails and app notification',
              iconColor: DavoColors.of(context).danger,
              value: marketing,
              onChanged: (v) => setState(() => marketing = v)),
          _PreferenceRow(
              asset: 'data_permissions',
              title: 'Data & Permissions',
              subtitle: 'Manage how your data is used',
              onTap: () => _details('Data & Permissions',
                  'Manage device permissions in your device settings.')),
          Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                  onPressed: () =>
                      showSettingsContent(context, 'Privacy Policy'),
                  child: const Text('Read Privacy Policy'))),
          _PreferenceRow(
              asset: 'block_users',
              title: 'Block Users',
              subtitle: 'Manage block contacts',
              onTap: () =>
                  _details('Block Users', 'You have no blocked contacts.')),
          _PreferenceRow(
              asset: 'app_analytics',
              title: 'App Analytics',
              subtitle:
                  'Help improve Davochain by sharing anonymous usage data',
              value: analytics,
              onChanged: (v) => setState(() => analytics = v)),
        ]),
      );
}

class _PreferenceGroup extends StatelessWidget {
  const _PreferenceGroup({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
        key: const ValueKey('settings-preference-group'),
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: DavoColors.of(context).offWhite,
            borderRadius: BorderRadius.circular(4)),
        child: Column(children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 20),
            children[i],
          ]
        ]),
      );
}

class _PreferenceRow extends StatelessWidget {
  const _PreferenceRow(
      {required this.asset,
      required this.title,
      required this.subtitle,
      this.value,
      this.onChanged,
      this.onTap,
      this.iconColor});
  final String asset, title, subtitle;
  final bool? value;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onTap;
  final Color? iconColor;
  @override
  Widget build(BuildContext context) {
    final row = Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: DavoColors.of(context).primarySoft,
            borderRadius: BorderRadius.circular(4)),
        child: SvgPicture.asset('assets/figma_exact/settings_pref_$asset.svg',
            key: ValueKey('settings-preference-icon-$asset'),
            width: 24,
            height: 24,
            excludeFromSemantics: true,
            colorFilter: ColorFilter.mode(
                iconColor ?? AppColors.primary, BlendMode.srcIn)),
      ),
      const SizedBox(width: 12),
      Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: _t12(context).copyWith(color: DavoColors.of(context).ink)),
        const SizedBox(height: 4),
        Text(subtitle, style: _t12(context).copyWith(fontSize: 10)),
      ])),
      const SizedBox(width: 8),
      if (onChanged != null)
        Semantics(
            label: title,
            toggled: value,
            child: _DavoSwitch(
                value: value!, onChanged: onChanged!, compact: true))
      else
        Image.asset('$_exactAssets/profile_chevron_exact.png',
            width: 16,
            height: 16,
            color: DavoColors.of(context).bodyMuted,
            excludeFromSemantics: true),
    ]);
    return ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: onTap == null ? row : InkWell(onTap: onTap, child: row));
  }
}

class HelpCentreScreen extends StatefulWidget {
  const HelpCentreScreen({super.key});
  @override
  State<HelpCentreScreen> createState() => _HelpCentreScreenState();
}

class _HelpCentreScreenState extends State<HelpCentreScreen> {
  final q = TextEditingController();
  @override
  void dispose() {
    q.dispose();
    super.dispose();
  }

  int cat = 0;
  final topics = [
    (
      '$_exactAssets/icon_buy_crypto.png',
      'Buying Crypto',
      'Learn how to buy crypto on Davochain'
    ),
    (
      '$_exactAssets/icon_sell_crypto.png',
      'Selling Crypto',
      'Learn how to sell crypto'
    ),
    (
      '$_exactAssets/icon_swap_crypto.png',
      'Swapping Crypto',
      'How to swap between cryptocurrencies'
    ),
    (
      '$_exactAssets/icon_buy_crypto.png',
      'Depositing Crypto',
      'How to deposit crypto to your wallet'
    ),
    (
      '$_exactAssets/icon_sell_crypto.png',
      'Withdrawing Crypto',
      'How to withdraw crypto to an external wallet'
    ),
    (
      '$_exactAssets/icon_gift.png',
      'Gift cards',
      'How to buy and sell gift cards'
    ),
    (
      '$_exactAssets/icon_shield_check.png',
      'Account & Security',
      'Manage your account and stay safe'
    )
  ];
  @override
  Widget build(BuildContext context) {
    final list = topics
        .where((t) => t.$2.toLowerCase().contains(q.text.toLowerCase()))
        .toList();
    return _Shell(
        title: 'Help Centre',
        scroll: true,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 12),
          TextField(
              keyboardAppearance: Theme.of(context).brightness,
              controller: q,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                  hintText: 'Search for help articles',
                  prefixIcon: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Image.asset('$_exactAssets/icon_search.png',
                          color: DavoColors.of(context).body,
                          width: 16,
                          height: 16)))),
          const SizedBox(height: 16),
          Row(
              children: ['All', 'Crypto', 'Gift Card', 'Account']
                  .asMap()
                  .entries
                  .map((e) => Expanded(
                      child: Padding(
                          padding: EdgeInsets.only(right: e.key == 3 ? 0 : 8),
                          child: ChoiceChip(
                              label: Center(child: Text(e.value)),
                              selected: cat == e.key,
                              onSelected: (_) => setState(() => cat = e.key),
                              showCheckmark: false,
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 11,
                                  color: cat == e.key
                                      ? Colors.white
                                      : DavoColors.of(context).body),
                              side: BorderSide.none))))
                  .toList()),
          const SizedBox(height: 24),
          Text('Popular Topics', style: _t20(context)),
          const SizedBox(height: 12),
          ...list.map(
              (t) => _HelpTopicRow(asset: t.$1, title: t.$2, subtitle: t.$3)),
          const SizedBox(height: 24)
        ]));
  }
}

class _HelpTopicRow extends StatelessWidget {
  const _HelpTopicRow(
      {required this.asset, required this.title, required this.subtitle});
  final String asset, title, subtitle;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 67),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: DavoColors.of(context).primarySoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(asset,
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: _t14b(context)),
                  const SizedBox(height: 3),
                  Text(subtitle, style: _t12(context)),
                ],
              ),
            ),
            Image.asset('$_exactAssets/icon_arrow_right.png',
                color: DavoColors.of(context).body,
                width: 22,
                height: 22,
                filterQuality: FilterQuality.high),
          ],
        ),
      );
}
