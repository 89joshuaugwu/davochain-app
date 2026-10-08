import '../../../shared/motion/davo_outcome_content.dart';
import 'verification/verification_overview_screen.dart';
import 'verification/verification_state.dart';
import '../../../shared/widgets/davo_state_picker.dart';
import 'dart:async';
import '../../../shared/widgets/davo_bank_logo.dart';
import '../../../shared/widgets/davo_toast.dart';
import '../../../shared/widgets/davo_result_screen.dart';
import '../../../core/preview/preview_auth_state.dart';
import '../../auth/presentation/login_flow.dart';
import '../../auth/presentation/fingerprint_setup_screen.dart';
import '../../auth/presentation/returning_unlock_screen.dart';
import '../../onboarding/presentation/brand_splash_screen.dart';
import '../../../shared/widgets/davo_success_mark.dart';
import '../../../shared/widgets/davo_date_picker.dart';
import '../../../core/preview/preview_account_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/inline_input_decoration.dart';
import '../../../shared/widgets/davochain_logo_lockup.dart';

const _avatar = 'assets/figma_exact/profile_avatar_exact.png';
const _notificationEmpty = 'assets/figma_exact/notification_empty_poster.png';
const _profileIcons = 'assets/figma_exact';
const _kycAssets = 'assets/figma_exact';
const _exactAssets = 'assets/figma_exact';
const _rankPortrait = 'assets/figma_exact/leaderboard_row_portrait_exact.png';

Future<void> startProfileSettingsFlow(BuildContext context) => pushAppPage<void>(context, (_) => const ProfileSettingsScreen());
Future<void> openNotificationCenter(BuildContext context) => pushAppPage<void>(context, (_) => const NotificationCenterScreen());

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});
  @override State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  @override
  void initState() {
    super.initState();
    PreviewAuthState.biometricsEnabled.addListener(_refreshBiometrics);
  }
  void _refreshBiometrics() { if (mounted) setState(() {}); }
  @override
  void dispose() {
    PreviewAuthState.biometricsEnabled.removeListener(_refreshBiometrics);
    super.dispose();
  }
  void _setBiometrics(bool enabled) {
    if (enabled) { _push(context, const FingerprintSetupScreen()); }
    else { PreviewAuthState.biometricsEnabled.value = false; }
  }

  @override
  Widget build(BuildContext context) {
    return _Shell(
      title: 'Profile',
      titleStyle: _navInter20,
      scroll: true,
      showHeaderDivider: true,
      bodyTopPadding: 24,
      child: Column(
        children: [
          const _ProfileAvatar(),
          const SizedBox(height: 16),
          const Text('Vincent Chukwu', style: _t16b),
          const SizedBox(height: 4),
          const Text('chukwuvncnt1@gmail.com', style: _t16ProfileSub),
          const SizedBox(height: 24),
          _MenuCard(
            title: 'Accounts',
            items: [
              _MenuItem('$_exactAssets/icon_personal_information.png', 'Personal Information', () => _push(context, const PersonalInformationV12Screen())),
              _MenuItem('$_exactAssets/icon_kyc.png', 'Verification', () => Navigator.of(context).push(AppPageRoute<void>(settings: const RouteSettings(name: 'verification'), builder: (_) => const VerificationOverviewScreen()))),
              _MenuItem('$_exactAssets/icon_linked_accounts.png', 'Linked Accounts', () => _push(context, const LinkedAccountsScreen())),
            ],
          ),
          const SizedBox(height: 24),
          _MenuCard(
            title: 'Security',
            items: [
              _MenuItem(
                '$_exactAssets/icon_biometrics.png',
                'Enable Biometrics',
                () => _setBiometrics(!PreviewAuthState.biometricsEnabled.value),
                trailing: Semantics(label: 'Biometric unlock', toggled: PreviewAuthState.biometricsEnabled.value, child: _DavoSwitch(value: PreviewAuthState.biometricsEnabled.value, onChanged: _setBiometrics)),
              ),
              _MenuItem('$_exactAssets/icon_lock.png', 'Change Password', () => _push(context, const ChangePasswordScreen())),
              _MenuItem('$_exactAssets/icon_lock.png', 'Transaction Pin', () => _push(context, const ResetPinStartScreen())),
              _MenuItem('$_exactAssets/icon_lock.png', 'Crypto Security', () => _push(context, const CryptoSecurityScreen())),
            ],
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () {
              PreviewAuthState.unlocked.value = false;
              _push(context, BrandSplashScreen(destinationBuilder: (_) => const ReturningUnlockScreen()));
            },
            icon: const Icon(Icons.lock_outline_rounded, size: 18),
            label: const Text('Preview returning login'),
          ),
          _MenuCard(
            title: 'Preferences',
            items: [
              _MenuItem('$_exactAssets/icon_notifications.png', 'Notifications', () => _push(context, const NotificationsPreferencesScreen())),
              _MenuItem('$_exactAssets/icon_privacy.png', 'Privacy', () => _push(context, const PrivacyScreen())),
              _MenuItem('$_exactAssets/icon_notification_settings.png', 'Notification Settings', () => _push(context, const NotificationSettingsScreen())),
              _MenuItem('$_exactAssets/icon_appearance.png', 'Appearance', () => _push(context, const AppearanceScreen())),
            ],
          ),
          const SizedBox(height: 24),
          _MenuCard(
            title: 'GENERAL',
            items: [
              _MenuItem('$_exactAssets/icon_customer_support.png', 'Customer Support', () => _push(context, const CustomerSupportScreen())),
              _MenuItem('$_exactAssets/icon_privacy_policy.png', 'Privacy Policy', () => _simple(context, 'Privacy Policy')),
              _MenuItem('$_exactAssets/icon_faq.png', 'FAQs', () => _push(context, const HelpCentreScreen())),
              _MenuItem('$_exactAssets/icon_terms.png', 'Terms and Condition', () => _simple(context, 'Terms and Condition')),
              _MenuItem('$_exactAssets/icon_about.png', 'About Us', () => _simple(context, 'About Us')),
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

/// The supplied PNG includes a shadow and transparent canvas around the face.
/// Crop that canvas in layout so badges align with the visible portrait edge.
class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({this.edit = false});
  final bool edit;

  @override
  Widget build(BuildContext context) => SizedBox(
    key: const ValueKey('profile-avatar'),
    width: 96,
    height: 96,
    child: Stack(clipBehavior: Clip.none, children: [
      DecoratedBox(
        decoration: const BoxDecoration(shape: BoxShape.circle, boxShadow: [
          BoxShadow(color: Color(0x18000000), blurRadius: 16, offset: Offset(0, 6)),
        ]),
        child: ClipOval(
          child: FittedBox(
            fit: BoxFit.fill,
            child: SizedBox(width: 120, height: 120, child: Stack(children: [
              Positioned(left: -32, top: -20, width: 183, height: 184,
                child: Image.asset(_avatar, fit: BoxFit.fill, filterQuality: FilterQuality.high)),
            ])),
          ),
        ),
      ),
      Positioned(right: 1, bottom: 1, child: Semantics(
        label: edit ? 'Profile photo edit indicator' : 'Verified profile',
        child: Container(
          key: ValueKey(edit ? 'profile-edit-badge' : 'profile-verification-badge'),
          width: 22, height: 22,
          alignment: Alignment.center,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primary,
            border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2))),
          child: Image.asset(
            edit ? '$_exactAssets/icon_edit.png' : '$_exactAssets/profile_verified_badge_exact.png',
            width: 14, height: 14, color: edit ? Colors.white : null,
            fit: BoxFit.contain, filterQuality: FilterQuality.high,
          ),
        ),
      )),
    ]),
  );
}

class AccountInformationScreen extends StatelessWidget {
  const AccountInformationScreen({super.key});
  @override Widget build(BuildContext context) => _Shell(title:'Profile',scroll:true,child:Column(children:[
    const SizedBox(height:26),
    const _ProfileAvatar(edit: true),
    const SizedBox(height:28),
    ...const [
      ('Full name','Vincent Chukwu'),('Email','vincent.dollars@gmail.com'),('Phone Number','+234 9062185004'),('Country','Nigeria'),('Username','Admiral'),('Date of Birth','1996-08-24'),('Residential Address','Flat A2, Guzape Estate, Abuja'),
    ].map((e)=>_InfoField(label:e.$1,value:e.$2)),
    const SizedBox(height:20),
    TextButton.icon(onPressed:()=>_simple(context,'Delete Account'),icon:Image.asset('$_exactAssets/icon_trash.png',width:18,height:18,filterQuality:FilterQuality.high),label:const Text('Delete Account',style:TextStyle(color:Color(0xFFF44336),fontFamily:'Sora'))),
    const SizedBox(height:32),
  ]));
}

class KycOverviewScreen extends StatelessWidget {
  const KycOverviewScreen({super.key});
  @override Widget build(BuildContext context)=>_Shell(title:'KYC Verification',titleStyle:_navInter20,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const SizedBox(height:24),
    const Text('Identity Verification',style:_t20),const SizedBox(height:6),
    const Text('To continue, click on any incomplete stage and complete the remaining steps.',style:_t12),const SizedBox(height:28),
    _statusRow('Identity verification','Not verified',false,()=>_push(context,const KycMethodScreen())),
    _statusRow('Address verification','Not verified',false,()=>_push(context,const AddressUpgradeScreen())),
    _statusRow('Phone Verification','Verified',true,null),
    _statusRow('Email verification','Verified',true,null),
    _statusRow('Profile information','Completed',true,null),
  ]));
}

class KycMethodScreen extends StatelessWidget {
  const KycMethodScreen({super.key});
  @override Widget build(BuildContext context)=>_Shell(title:'KYC Verification',titleStyle:_navInter20,child:Column(children:[
    const SizedBox(height:30),
    _ChoiceTile(asset:'$_kycAssets/identity.png',title:'Identity',subtitle:'Government Issued ID',selected:true,onTap:()=>_push(context,const GovernmentIdScreen())),
    const SizedBox(height:14),
    _ChoiceTile(asset:'$_kycAssets/selfie.png',title:'Selfie',subtitle:'Live Check',onTap:()=>_push(context,const SelfieScreen())),
    const Spacer(),_PrimaryButton('Submit',onTap:()=>Navigator.pop(context)),const SizedBox(height:30)
  ]));
}

class GovernmentIdScreen extends StatefulWidget { const GovernmentIdScreen({super.key}); @override State<GovernmentIdScreen> createState()=>_GovernmentIdScreenState(); }
class _GovernmentIdScreenState extends State<GovernmentIdScreen>{ int selected=0; @override Widget build(BuildContext context)=>_Shell(title:'KYC Verification',titleStyle:_navInter20,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
  const SizedBox(height:24),const Text('Upload a valid government ID to ensure the safety and security of the Errandy community.',style:_t14),const SizedBox(height:28),
  _idTile('$_kycAssets/national_id.png','National ID','Tap to upload front & back',selected==0,(){setState(()=>selected=0);_uploadSheet(context,'Upload ID');}),
  _idTile('$_kycAssets/passport.png','Passport','Scan biometric page',selected==1,(){setState(()=>selected=1);_uploadSheet(context,'Upload ID');}),
  _idTile('$_kycAssets/driver.png',"Driver's License",'Scan current license',selected==2,(){setState(()=>selected=2);_uploadSheet(context,'Upload ID');}),
])); }

class SelfieScreen extends StatelessWidget { const SelfieScreen({super.key}); @override Widget build(BuildContext context)=>_Shell(title:'KYC Verification',titleStyle:_navInter20,child:Column(children:[
  const SizedBox(height:28),const Align(alignment:Alignment.centerLeft,child:Text('Take a selfie',style:_t20)),const SizedBox(height:6),const Align(alignment:Alignment.centerLeft,child:Text('Make sure your face is well-lit and fits inside the circle for verification.',style:_t12)),const SizedBox(height:24),
  ClipRRect(borderRadius:BorderRadius.circular(4),child:Image.asset('$_kycAssets/selfie_reference.jpg',width:171,height:171,fit:BoxFit.cover,filterQuality:FilterQuality.high)),
  const SizedBox(height:24),
  const _Bullet('To ensure the security of your account and comply with regulatory requirements, we need to verify your identity.'),
  const _Bullet('Please upload a photo of your ID and take a photo of your face to complete this process.'),
  const Spacer(),_PrimaryButton('Start live face detection',onTap:()=>_push(context,const FaceDetectionScreen())),const SizedBox(height:12),_SecondaryButton('Later',onTap:()=>Navigator.pop(context)),const SizedBox(height:20)
])); }

class FaceDetectionScreen extends StatefulWidget { const FaceDetectionScreen({super.key}); @override State<FaceDetectionScreen> createState()=>_FaceDetectionScreenState(); }
class _FaceDetectionScreenState extends State<FaceDetectionScreen> with SingleTickerProviderStateMixin { late final AnimationController c; @override void initState(){super.initState();c=AnimationController(vsync:this,duration:const Duration(seconds:2))..repeat(reverse:true);} @override void dispose(){c.dispose();super.dispose();} @override Widget build(BuildContext context)=>_Shell(title:'KYC Verification',titleStyle:_navInter20,child:Column(children:[
 const SizedBox(height:28),const Text('Live face detection',style:_t20),const SizedBox(height:5),const Text('Scan your face to verify your identity',style:_t12),const SizedBox(height:28),
 Container(width:300,height:300,color:Colors.black,child:Stack(children:[..._cornerFrames(),AnimatedBuilder(animation:c,builder:(_,__)=>Positioned(left:28,right:28,top:36+c.value*228,child:Container(height:1.5,color:const Color(0xFF135CF7))))])),
 const SizedBox(height:18),const Text('Place your head within the frame',style:_t12),
])); }

class TransactionLimitsScreen extends StatelessWidget { const TransactionLimitsScreen({super.key}); @override Widget build(BuildContext context)=>_Shell(title:'Transaction Limits',child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
 const SizedBox(height:24),const Text('Choose an account to view transaction limits',style:_t16b),const SizedBox(height:4),const Text('Limits may vary based on account type and verification level',style:_t12),const SizedBox(height:24),
 _AccountLimitTile(flag:'🇺🇸',title:'US Currency',subtitle:'USD Account Limits',onTap:()=>_push(context,const _LimitDetailScreen(kind:_LimitKind.usd))),
 const SizedBox(height:12),_AccountLimitTile(flag:'🇳🇬',title:'Nigeria Currency (NG)',subtitle:'NGN Account Limits',onTap:()=>_push(context,const _LimitDetailScreen(kind:_LimitKind.ngn))),
 const SizedBox(height:12),_AccountLimitTile(flag:'₿',title:'Crypto Currency',subtitle:'Manage Crypto currency Limits',onTap:()=>_push(context,const _LimitDetailScreen(kind:_LimitKind.crypto))),
])); }

enum _LimitKind{usd,ngn,crypto}
class _LimitDetailScreen extends StatefulWidget{ const _LimitDetailScreen({required this.kind}); final _LimitKind kind; @override State<_LimitDetailScreen> createState()=>_LimitDetailScreenState(); }
class _LimitDetailScreenState extends State<_LimitDetailScreen>{bool second=false; @override Widget build(BuildContext context){final isUsd=widget.kind==_LimitKind.usd,isNgn=widget.kind==_LimitKind.ngn; final title=isUsd?'USD Limits':isNgn?'NGN Limits':'Crypto Currency'; final single=isUsd?'\$2,500.00':isNgn?'₦1,000,000.00':'\$1,000,000.00'; final daily=isUsd?'\$2,500.00':isNgn?'₦3,000,000.00':'\$3,000,000.00'; final weekly=isUsd?'\$10,500.00':isNgn?'₦5,000,000.00':'\$5,000,000.00'; final monthly=isUsd?'\$50,000.00':isNgn?'₦40,000,000.00':'\$40,000,000.00'; return _Shell(title:'Transaction Limits',child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
 const SizedBox(height:22),Row(children:[Text(widget.kind==_LimitKind.ngn?'🇳🇬':widget.kind==_LimitKind.usd?'🇺🇸':'₿',style:const TextStyle(fontSize:28)),const SizedBox(width:10),Text(title,style:_t16b),const SizedBox(width:10),const _Pill('Limits')]),const SizedBox(height:20),
 _Segment(left:widget.kind==_LimitKind.crypto?'Limits on Withdrawal':'Limits on Send',right:widget.kind==_LimitKind.crypto?'Limits on Deposit':'Limits on receive',rightSelected:second,onChanged:(v)=>setState(()=>second=v)),const SizedBox(height:24),
 _limitBanner('Single Transaction Limits of $single'),const SizedBox(height:18),_ProgressLimit('Daily Limit of $daily',daily),const SizedBox(height:16),_ProgressLimit('Weekly Limit of $weekly',weekly),const SizedBox(height:16),_ProgressLimit('Monthly Limit of $monthly',monthly),
 const Spacer(),_PrimaryButton('Increase Transfer Limits',onTap:()=>Navigator.of(context).push(AppPageRoute<void>(settings:const RouteSettings(name:'verification'),builder:(_)=>const VerificationOverviewScreen()))),const SizedBox(height:28)
]));}}

class IncreaseLimitsScreen extends StatelessWidget {const IncreaseLimitsScreen({super.key});@override Widget build(BuildContext context)=>_Shell(title:'Transaction Limits',child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const SizedBox(height:20),const Text('Increase Transfer Limits',style:_t20),const SizedBox(height:4),const Text('Complete the sections below to unlock higher account limits. Approval typically takes 2–3 days.',style:_t12),const SizedBox(height:28),_ActionCard('$_exactAssets/profile_location_exact.png','Verify Address','Face to face verification at your address',()=>_push(context,const AddressUpgradeScreen())),const SizedBox(height:14),_ActionCard('$_exactAssets/profile_document_exact.png','Proof of Address','Upload electricity bill, water bill',()=>_push(context,const AddressUpgradeScreen()))]));}
class AddressUpgradeScreen extends StatelessWidget{const AddressUpgradeScreen({super.key});@override Widget build(BuildContext context)=>_Shell(title:'Transaction Limits',scroll:true,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const SizedBox(height:18),const Text('Confirm Your Address',style:_t20),const SizedBox(height:18),const _Bullet('Your document should be dated within the last 3 months and clearly show your name and address'),const _Bullet('Take a clear, full photo of your document, no cropped edges or blurry shots'),const _Bullet('Upload it as-is — no edits, filters, or photos taken from a screen'),const SizedBox(height:24),_docOption('Utility Bill','Dated within the last 3 months'),_docOption('Bank Statement','From a different bank, showing your current address, dated within the last 6 months'),_docOption('Tenancy Agreement','Renting? Upload your tenancy agreement along with a utility bill from your landlord confirming your address'),const SizedBox(height:28),_PrimaryButton('Choose document to upload',onTap:()=>_uploadSheet(context,'Upload ID')),const SizedBox(height:24)]));}

class ChangePasswordScreen extends StatefulWidget{const ChangePasswordScreen({super.key});@override State<ChangePasswordScreen> createState()=>_ChangePasswordScreenState();}
class _ChangePasswordScreenState extends State<ChangePasswordScreen>{final old=TextEditingController(),n=TextEditingController(),c=TextEditingController();@override Widget build(BuildContext context)=>_Shell(title:'Change Password',child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const SizedBox(height:28),const Text('Change your password',style:_t20),const SizedBox(height:24),_Input(label:'Old Password',hint:'Enter your old password',controller:old,obscure:true),const SizedBox(height:16),_Input(label:'New Password',hint:'Enter password',controller:n,obscure:true),const SizedBox(height:16),_Input(label:'Confirm Password',hint:'Confirm password',controller:c,obscure:true),const Spacer(),_PrimaryButton('Change your password',onTap:()=>_snack(context,'Password updated')),const SizedBox(height:28)]));}

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key, this.hasNotifications = true});
  final bool hasNotifications;
  const NotificationCenterScreen.empty({super.key}) : hasNotifications = false;

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  int tab = 0;

  @override
  Widget build(BuildContext context) {
    if (!widget.hasNotifications) {
      return _Shell(
        title: 'Notification',
        bodyTopPadding: 0,
        child: Column(
          children: [
            const SizedBox(height: 22),
            SizedBox(
              width: 358,
              height: 217,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Image.asset(
                  _notificationEmpty,
                  width: 150,
                  height: 88,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  gaplessPlayback: true,
                ),
              ),
            ),
            const SizedBox(height: 31),
            const SizedBox(
              width: 289,
              child: Text(
                'No notifications yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 20,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const SizedBox(
              width: 289,
              child: Text(
                'We’ll notify you about your orders and updates here.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 16,
                  height: 1.35,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF424242),
                ),
              ),
            ),
          ],
        ),
      );
    }

    const labels = ['All', 'Transactions', 'Security', 'Rewards'];
    const widths = [53.0, 102.0, 75.0, 77.0];
    return _Shell(
      title: 'Notification',
      scroll: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < labels.length; i++) ...[
                _NotificationFilterPill(
                  label: labels[i],
                  width: widths[i],
                  selected: tab == i,
                  onTap: () => setState(() => tab = i),
                ),
                if (i != labels.length - 1) const SizedBox(width: 12),
              ],
            ],
          ),
          const SizedBox(height: 24),
          const Text('TODAY', style: _sectionLabel14),
          const SizedBox(height: 16),
          const _NotifAssetItem('assets/figma_exact/icon_transaction.png', 'Deposit Received', 'Your monthly salary of \$4,250.00 has been…', '2m ago', Color(0xFF20C55D)),
          const SizedBox(height: 16),
          const _NotifAssetItem('assets/figma_exact/icon_security.png', 'New Login Detected', 'A login attempt was made from a new device in Nigeria, Lagos. If this…', '45m ago', Color(0xFFCC8408)),
          const SizedBox(height: 16),
          const _NotifAssetItem('assets/figma_exact/icon_transaction.png', 'Transfer Sent', "You sent \$150.00 to Chukwu Vincent\nfor 'Family Support'.", '2hr ago', AppColors.primary),
          const SizedBox(height: 24),
          const Text('YESTERDAY', style: _sectionLabel14),
          const SizedBox(height: 16),
          const _NotifAssetItem('assets/figma_exact/icon_gift.png', 'Cashback Earned!', "You've earned \$12.40 cashback from your last purchase at 'The…", '1d ago', Color(0xFF7B61FF)),
          const SizedBox(height: 16),
          const _NotifAssetItem('assets/figma_exact/icon_customer_support.png', 'Support Ticket Updated', 'Your inquiry regarding the international wire transfer has been', '1d ago', AppColors.primary),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class EmptyNotificationScreen extends StatelessWidget{const EmptyNotificationScreen({super.key});@override Widget build(BuildContext context)=>const NotificationCenterScreen.empty();}

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Notification Settings',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 17),
            const Text('Alert Preferences', style: _t16b),
            const SizedBox(height: 24),
            _settingsAssetRow('$_exactAssets/icon_transaction.png', 'Transaction Alerts', '', () => _push(context, const NotificationChannelScreen(type: 0))),
            _settingsAssetRow('$_exactAssets/icon_security.png', 'Security Alerts', '', () => _push(context, const NotificationChannelScreen(type: 1))),
            _settingsAssetRow('$_exactAssets/icon_campaign.png', 'Marketing & News', '', () => _push(context, const NotificationChannelScreen(type: 2))),
          ],
        ),
      );
}

class NotificationChannelScreen extends StatefulWidget {
  const NotificationChannelScreen({super.key, required this.type});
  final int type;
  @override
  State<NotificationChannelScreen> createState() => _NotificationChannelScreenState();
}

class _NotificationChannelScreenState extends State<NotificationChannelScreen> {
  bool push = true, email = false, sms = false;

  @override
  Widget build(BuildContext context) {
    final title = ['Transaction Alerts', 'Security Alerts', 'Marketing & News'][widget.type];
    final pushSub = widget.type == 0
        ? 'Real-Time  Alerts'
        : widget.type == 1
            ? 'Login Alerts, Password Changes, New Device Sign-in'
            : 'Promotions, New Features, Newsletter';
    final emailSub = widget.type == 0
        ? 'Detailed Statements'
        : widget.type == 1
            ? 'Secondary Channel. Audit Trail, Detailed Logs'
            : 'Promotions, New Features, Newsletter';
    return _Shell(
      title: 'Notification Settings',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 17),
          Text(title, style: _t16b),
          const SizedBox(height: 26),
          _toggleRow('Push Notification', pushSub, push, (v) => setState(() => push = v)),
          _toggleRow('Email', emailSub, email, (v) => setState(() => email = v)),
          if (widget.type == 0) _toggleRow('SMS', 'Standard Rates Apply', sms, (v) => setState(() => sms = v)),
        ],
      ),
    );
  }
}

class ResetPinStartScreen extends StatefulWidget{const ResetPinStartScreen({super.key});@override State<ResetPinStartScreen> createState()=>_ResetPinStartScreenState();}
class _ResetPinStartScreenState extends State<ResetPinStartScreen>{int method=0;@override Widget build(BuildContext context)=>_Shell(title:'Reset Transaction PIN',child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const SizedBox(height:26),const Text('To reset your transaction PIN, you’ll need to verify with a verification code sent to you.',style:_t14),const SizedBox(height:24),const Text('Choose how you want to get code',style:_t14m),const SizedBox(height:12),_radioChoice('Send via SMS',method==0,()=>setState(()=>method=0)),const SizedBox(height:12),_radioChoice('Send via Email',method==1,()=>setState(()=>method=1)),const Spacer(),_PrimaryButton('Next',onTap:()=>_push(context,VerifyPinCodeScreen(email:method==1))),const SizedBox(height:28)]));}
class VerifyPinCodeScreen extends StatefulWidget {
  const VerifyPinCodeScreen({super.key, required this.email, this.now});
  final bool email;
  final DateTime Function()? now;
  @override
  State<VerifyPinCodeScreen> createState() => _VerifyPinCodeScreenState();
}

class _VerifyPinCodeScreenState extends State<VerifyPinCodeScreen> {
  final c = TextEditingController();
  Timer? _resendTimer;
  late DateTime _resendAt;
  DateTime get _now => widget.now?.call() ?? DateTime.now();
  int get _remaining => ((_resendAt.difference(_now).inMilliseconds / 1000)
    .ceil()).clamp(0, 30);

  @override
  void initState() {
    super.initState();
    c.addListener(_refresh);
    _startCooldown();
  }

  void _startCooldown() {
    _resendTimer?.cancel();
    _resendAt = _now.add(const Duration(seconds: 30));
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() {});
      if (_remaining == 0) timer.cancel();
    });
  }

  void _refresh() => setState(() {});

  void _resend() {
    if (_remaining > 0) return;
    setState(_startCooldown);
    _snack(context, 'Code resent');
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    c.removeListener(_refresh);
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = c.text.length == 4;
    final remaining = _remaining;
    return _Shell(title: 'Reset Transaction PIN', scroll: true,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 26),
        Text('To reset your transaction PIN, you?ll need to verify with a verification code sent to your ${widget.email ? 'email' : 'phone number'}.', style: _t14),
        const SizedBox(height: 24),
        _Input(label: 'Verification code', hint: 'Enter 4-digit code',
          controller: c, keyboard: TextInputType.number, labelSize: 16,
          hintSize: 14, hintFontFamily: 'Poppins', maxLength: 4,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly]),
        const SizedBox(height: 12),
        Wrap(crossAxisAlignment: WrapCrossAlignment.center, spacing: 8,
          children: [
            const Text('Didn?t get a code?', style: _t12),
            TextButton(onPressed: remaining == 0 ? _resend : null,
              child: const Text('Resend Code')),
            if (remaining > 0)
              Text('0:${remaining.toString().padLeft(2, '0')}', style: _t12),
          ]),
        const SizedBox(height: 36),
        _PrimaryButton('Next', enabled: enabled,
          disabledBackgroundColor: const Color(0xFF89ADFB),
          onTap: () {
            _resendTimer?.cancel();
            _push(context, const NewTransactionPinScreen());
          }),
        const SizedBox(height: 28),
      ]));
  }
}
class NewTransactionPinScreen extends StatefulWidget{const NewTransactionPinScreen({super.key});@override State<NewTransactionPinScreen> createState()=>_NewTransactionPinScreenState();}
class _NewTransactionPinScreenState extends State<NewTransactionPinScreen>{
  final a=TextEditingController(),b=TextEditingController();
  @override void initState(){super.initState();a.addListener(_refresh);b.addListener(_refresh);}
  void _refresh()=>setState((){});
  @override void dispose(){a.removeListener(_refresh);b.removeListener(_refresh);a.dispose();b.dispose();super.dispose();}
  @override Widget build(BuildContext context){final av=a.text.replaceAll(RegExp(r'\D'),'');final bv=b.text.replaceAll(RegExp(r'\D'),'');final enabled=av.length==4&&bv.length==4&&av==bv;return _Shell(title:'Transaction PIN',child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const SizedBox(height:26),const Text('Your 4-digit transaction PIN secures your transactions. It is important that you do not share this PIN with anyone',style:_t14),const SizedBox(height:24),_Input(label:'New PIN',hint:'****',controller:a,obscure:true,keyboard:TextInputType.number,labelSize:16,hintSize:14,hintFontFamily:'Poppins',maxLength:4,inputFormatters:[FilteringTextInputFormatter.digitsOnly]),const SizedBox(height:16),_Input(label:'Confirm New PIN',hint:'****',controller:b,obscure:true,keyboard:TextInputType.number,labelSize:16,hintSize:14,hintFontFamily:'Poppins',maxLength:4,inputFormatters:[FilteringTextInputFormatter.digitsOnly]),const Spacer(),_PrimaryButton('Save',enabled:enabled,disabledBackgroundColor:const Color(0xFF89ADFB),onTap:()=>_push(context,const PinSuccessScreen())),const SizedBox(height:28)]));}
}
class PinSuccessScreen extends StatelessWidget {
  const PinSuccessScreen({super.key});
  @override
  Widget build(BuildContext context) => DavoResultScreen(
    tempo: DavoOutcomeTempo.compact, title: 'Success!', message: 'You’ve successfully reset your Transaction PIN',
    actions: _PrimaryButton('Okay', onTap: () => Navigator.of(context).popUntil((r) => r.isFirst)),
  );
}

// ---- Support ----
class CustomerSupportScreen extends StatelessWidget {
  const CustomerSupportScreen({super.key});

  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Customer Support',
        scroll: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 31),
            const Text('Chat', style: _t16b),
            const SizedBox(height: 16),
            _supportTile('$_exactAssets/icon_chat.png', 'Live Chat', 'Start a conversation on live chat', () => _push(context, const SupportHubScreen())),
            const SizedBox(height: 16),
            _supportTile('$_exactAssets/icon_email.png', 'Email', 'We aim to respond in a day', () => _push(context, const EmailSupportScreen())),
            const SizedBox(height: 16),
            _supportTile('$_exactAssets/icon_request.png', 'Submit a Request', 'Tell us what went wrong', () => _push(context, const EmailSupportScreen())),
            const SizedBox(height: 36),
            const Text('Social Media', style: _t16b),
            const SizedBox(height: 16),
            _supportTile('$_exactAssets/icon_instagram.png', 'Instagram', '', () => _socialDialog(context, 'Instagram')),
            const SizedBox(height: 16),
            _supportTile('$_exactAssets/icon_linkedin.png', 'Linkedln', '', () => _socialDialog(context, 'Linkedln')),
            const SizedBox(height: 16),
            _supportTile('$_exactAssets/icon_twitter.png', 'Twitter', '', () => _socialDialog(context, 'X')),
            const SizedBox(height: 28),
          ],
        ),
      );
}

class SupportHubScreen extends StatelessWidget{const SupportHubScreen({super.key});@override Widget build(BuildContext context)=>Scaffold(backgroundColor:const Color(0xFFF7F7F7),body:SafeArea(child:SingleChildScrollView(child:Column(children:[Container(width:double.infinity,padding:const EdgeInsets.fromLTRB(12,12,12,10),decoration:const BoxDecoration(gradient:LinearGradient(begin:Alignment.topCenter,end:Alignment.bottomCenter,colors:[Color(0xFF1260FF),Color(0xFF3B7CFF)]),borderRadius:BorderRadius.vertical(bottom:Radius.circular(14))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[const DavochainLogoLockup(logoColor:Colors.white,logoWidth:28,fontSize:20),const Spacer(),InkWell(onTap:()=>Navigator.pop(context),child:Container(width:24,height:24,alignment:Alignment.center,color:Colors.white12,child:Image.asset('$_exactAssets/icon_close.png',width:18,height:18)))]),const SizedBox(height:28),const Text('Hi Chukwu 👋\nHow can we help?',style:TextStyle(fontFamily:'Sora',fontSize:16,fontWeight:FontWeight.w600,color:Colors.white,height:1.35)),const SizedBox(height:22),Container(decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(7)),child:Column(children:[_HubAssetRow('Messages','$_exactAssets/icon_message.png',onTap:()=>_push(context,const SupportMessagesScreen())),const Divider(height:1),_HubAssetRow('Help','$_exactAssets/icon_help.png',onTap:()=>_push(context,const HelpCenterScreen()))])),const SizedBox(height:10),InkWell(onTap:()=>_push(context,const SupportMessagesScreen()),child:Container(height:38,padding:const EdgeInsets.symmetric(horizontal:12),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(7)),child:Row(children:[const Expanded(child:Text('Send us a messages',style:TextStyle(fontFamily:'Sora',fontSize:10,color:AppColors.body))),Image.asset('$_exactAssets/icon_send.png',width:16,height:16)]))),const SizedBox(height:10),Container(padding:const EdgeInsets.symmetric(horizontal:12,vertical:7),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(7)),child:Column(children:['Explore Rewards: Key Details You Should Know','Unlock More Earnings with Every Referral','Everything You Need to Know About Your Virtual Dollar Card','Join Our community Channel'].map((t)=>Padding(padding:const EdgeInsets.symmetric(vertical:5),child:Row(children:[Expanded(child:Text(t,style:const TextStyle(fontFamily:'Sora',fontSize:9,color:AppColors.body))),Image.asset('$_exactAssets/icon_external_link.png',width:11,height:11)]) )).toList()))])),Padding(padding:const EdgeInsets.all(12),child:Container(padding:const EdgeInsets.all(10),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(7)),child:Column(children:[Container(height:30,padding:const EdgeInsets.symmetric(horizontal:10),decoration:BoxDecoration(color:const Color(0xFFF4F5F8),borderRadius:BorderRadius.circular(4)),child:Row(children:[const Expanded(child:Text('Search for help',style:TextStyle(fontFamily:'Sora',fontSize:9))),Image.asset('$_exactAssets/icon_search.png',width:14,height:14)])),...['Receiving International Payments with Davochain','About Your USD Account','Verifying your Davochain Account: Step-by-Step Guide','Bank Accounts Deposit Charges on Davochain','How do I Buy/Sell Gift Card On Davochain','How do I Crypto Assets On Davochain'].map((t)=>Padding(padding:const EdgeInsets.symmetric(vertical:6),child:Row(children:[Expanded(child:Text(t,style:const TextStyle(fontFamily:'Sora',fontSize:9,color:AppColors.body))),Image.asset('$_exactAssets/icon_arrow_right.png',width:14,height:14)])))]))) ]))));}
Widget _supportTile(String asset, String title, String subtitle, VoidCallback tap) {
  final hasSubtitle = subtitle.isNotEmpty;
  return InkWell(
    onTap: tap,
    child: SizedBox(
      width: double.infinity,
      height: hasSubtitle ? 70 : 56,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Image.asset(asset, width: 24, height: 24, fit: BoxFit.contain, filterQuality: FilterQuality.high),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: _t14b),
                  if (hasSubtitle) ...[
                    const SizedBox(height: 4),
                    Text(subtitle, style: _t12),
                  ],
                ],
              ),
            ),
            Image.asset('$_exactAssets/icon_arrow_right.png', width: 24, height: 24, filterQuality: FilterQuality.high),
          ],
        ),
      ),
    ),
  );
}

class _HubAssetRow extends StatelessWidget{const _HubAssetRow(this.text,this.asset,{required this.onTap});final String text,asset;final VoidCallback onTap;@override Widget build(BuildContext context)=>InkWell(onTap:onTap,child:SizedBox(height:32,child:Row(children:[const SizedBox(width:10),Expanded(child:Text(text,style:const TextStyle(fontFamily:'Sora',fontSize:10,color:AppColors.body))),Image.asset(asset,width:14,height:14,filterQuality:FilterQuality.high),const SizedBox(width:10)])));}

class SupportMessagesScreen extends StatelessWidget{const SupportMessagesScreen({super.key});@override Widget build(BuildContext context)=>_Shell(title:'Messages',titleStyle:_navSora16SemiBold,child:Column(children:[const Spacer(),Image.asset('$_exactAssets/icon_message.png',width:46,height:46),const SizedBox(height:14),const Text('No Messages',style:_t16b),const SizedBox(height:6),const Text('Messages from the team will be shown here',textAlign:TextAlign.center,style:_t12),const SizedBox(height:20),SizedBox(width:150,child:_PrimaryButton('Ask a question',onTap:()=>_push(context,const SupportChatScreen()))),const Spacer()]));}
class SupportChatScreen extends StatefulWidget{const SupportChatScreen({super.key});@override State<SupportChatScreen> createState()=>_SupportChatScreenState();}
class _SupportChatScreenState extends State<SupportChatScreen>{
  String? choice;
  @override
  Widget build(BuildContext context)=>_Shell(
    title:'Callie',
    titleStyle:_navSora14SemiBold,
    scroll:true,
    child:Column(
      crossAxisAlignment:CrossAxisAlignment.start,
      children:[
        const SizedBox(height:14),
        const _AgentHeader(),
        const SizedBox(height:16),
        const _ChatBubble(text:"Hi there,\nThank you for choosing Davochain.\nWe're currently handling a high volume of requests, so responses might take a bit longer than usual.\nThanks for your patience, we'll get to you as soon as possible."),
        const SizedBox(height:12),
        const _AgentHeader(small:true),
        const SizedBox(height:8),
        const _ChatBubble(text:'Hello Chukwu, this is Bella from Davochain.\nPlease choose the option below that best matches your request.'),
        const SizedBox(height:12),
        if(choice==null)
          ...['Account Management & Verification','Virtual Cards (Creation, Funding, refundd)','Gift Cards, Crypto','Deposits and Funding','Bank Accounts (Creation & Management)','Withdrawals from Davochain to Bank Account','Account Suspension, Issues & Restrictions','Something Else'].map(
            (e)=>Padding(
              padding:const EdgeInsets.only(bottom:8),
              child:OutlinedButton(
                onPressed:()=>setState(()=>choice=e),
                style:OutlinedButton.styleFrom(
                  alignment:Alignment.centerLeft,
                  minimumSize:const Size.fromHeight(44),
                  side:const BorderSide(color:Color(0xFFEBEDF3)),
                  shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(8)),
                ),
                child:Text(e,style:_t12),
              ),
            ),
          )
        else ...[
          Align(
            alignment:Alignment.centerRight,
            child:Container(
              padding:const EdgeInsets.all(12),
              decoration:BoxDecoration(color:AppColors.primary,borderRadius:BorderRadius.circular(12)),
              child:Text(choice!,style:const TextStyle(fontFamily:'Sora',fontSize:12,color:Colors.white)),
            ),
          ),
          const SizedBox(height:14),
          const _ChatBubble(text:'To help me provide the best answer to your question, please share as much details as possible.'),
          const SizedBox(height:14),
          TextField(
            decoration:InputDecoration(
              hintText:'Ask a question....',
              suffixIcon:IconButton(onPressed:(){},icon:Image.asset('$_exactAssets/icon_send.png',width:20,height:20)),
              border:OutlineInputBorder(borderRadius:BorderRadius.circular(8)),
            ),
          ),
        ],
        const SizedBox(height:30),
      ],
    ),
  );
}
class EmailSupportScreen extends StatefulWidget {
  const EmailSupportScreen({super.key});
  @override
  State<EmailSupportScreen> createState() => _EmailSupportScreenState();
}

class _EmailSupportScreenState extends State<EmailSupportScreen> {
  final subject = TextEditingController();
  final orderId = TextEditingController();
  final message = TextEditingController();

  @override
  void dispose() {
    subject.dispose();
    orderId.dispose();
    message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Email Support',
        titleStyle: _navSora16Bold,
        scroll: true,
        bodyTopPadding: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text('Email Us', style: _t16b),
            const SizedBox(height: 4),
            const Text(
              'Have a question about your order or our services? Our team is here to help.',
              style: _t14,
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              height: 95,
              padding: const EdgeInsets.all(17),
              decoration: BoxDecoration(
                color: const Color(0xFFEDF2FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 38,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset(
                      '$_exactAssets/email_rapid_response_exact.png',
                      width: 16,
                      height: 20,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Rapid Response', style: _t16b),
                        Text(
                          'We typically respond to all email inquiries\nwithin 24 hours.',
                          style: _t14,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _SupportInputField(
              label: 'Message',
              hint: 'What can we help you with?',
              controller: subject,
            ),
            const SizedBox(height: 16),
            _SupportInputField(
              label: 'Order ID',
              badge: 'Optional',
              hint: 'e.g. #VP-8291',
              controller: orderId,
            ),
            const SizedBox(height: 16),
            _SupportInputField(
              label: 'Message',
              hint: 'Tell us more about your inquiry...',
              controller: message,
              multiline: true,
            ),
            const SizedBox(height: 40),
            _PrimaryButton('Send Email', onTap: () => _snack(context, 'Email sent')),
            const SizedBox(height: 24),
          ],
        ),
      );
}

class HelpCenterScreen extends StatefulWidget{const HelpCenterScreen({super.key});@override State<HelpCenterScreen> createState()=>_HelpCenterScreenState();}
class _HelpCenterScreenState extends State<HelpCenterScreen>{final q=TextEditingController();@override Widget build(BuildContext context){final cats=_helpCats.where((e)=>e.$1.toLowerCase().contains(q.text.toLowerCase())).toList();return _Shell(title:'Help',titleStyle:_navSora16SemiBold,scroll:true,child:Column(children:[TextField(controller:q,onChanged:(_)=>setState((){}),decoration:InputDecoration(hintText:'Search for help',prefixIcon:Padding(padding:const EdgeInsets.all(14),child:Image.asset('$_exactAssets/icon_search.png',width:16,height:16,filterQuality:FilterQuality.high)),border:OutlineInputBorder(borderRadius:BorderRadius.circular(8)))),const SizedBox(height:16),...cats.map((e)=>_HelpCategory(e.$1,e.$2,e.$3)),const SizedBox(height:30)]));}}

// ---- Rewards / Ambassador ----
class ReferralDashboardScreen extends StatelessWidget{const ReferralDashboardScreen({super.key});@override Widget build(BuildContext context)=>_Shell(title:'Rewards',titleStyle:_navSora16Medium,scroll:true,child:Column(children:[Container(width:double.infinity,padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:AppColors.primary,borderRadius:BorderRadius.circular(8)),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Referral Program',style:TextStyle(fontFamily:'Sora',fontSize:12,color:Colors.white70)),SizedBox(height:10),Text('Earn ₦2,000 For\nevery friend Referred',style:TextStyle(fontFamily:'Sora',fontSize:24,fontWeight:FontWeight.w700,color:Colors.white,height:1.25)),SizedBox(height:8),Text('Invite your friends to Davochain and get rewarded when they make their first successful transaction.',style:TextStyle(fontFamily:'Sora',fontSize:12,color:Colors.white,height:1.4))])),const SizedBox(height:18),_referralBox(),const SizedBox(height:18),_sectionLink('Manage your earnings','Referral Analytics',()=>_push(context,const ReferralAnalyticsScreen())),const SizedBox(height:18),_PrimaryButton('Davo Points',onTap:()=>_push(context,const DavoPointsScreen())),const SizedBox(height:22),const _HowItWorks(),const SizedBox(height:30)]));}
class ReferralAnalyticsScreen extends StatelessWidget{const ReferralAnalyticsScreen({super.key});@override Widget build(BuildContext context)=>_Shell(title:'',scroll:true,bodyTopPadding:12,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Performance Hub',style:TextStyle(fontFamily:'Sora',fontSize:14,fontWeight:FontWeight.w500,color:AppColors.primary,height:1.35)),const SizedBox(height:8),const Text('Referral Analytics',style:_navSora20),const SizedBox(height:18),const _StatsGrid([('My invitees','128'),('Rewarded','84'),('KYC Done','53'),('Deposited','34')]),const SizedBox(height:20),const Text('Manage your earnings:',style:_t14m),const SizedBox(height:10),_PrimaryButton('Rewards',onTap:()=>_push(context,const DavoPointsScreen())),const SizedBox(height:22),const Text('Referrals',style:_t16b),const SizedBox(height:4),const Text('Track your network and earned rewards.',style:_t12),const SizedBox(height:14),..._people.map((e)=>_PersonRow(e.$1,e.$2,e.$3)),const SizedBox(height:28)]));}
class DavoPointsScreen extends StatelessWidget{const DavoPointsScreen({super.key});@override Widget build(BuildContext context)=>_Shell(title:'',scroll:true,bodyTopPadding:7,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Davo points Dashboard',style:_navSora20),const SizedBox(height:16),const _StatsGrid([('Earned Points','Đ15.00'),('Redeemed Points','Đ0.00'),('Available Points','Đ15.00'),('Rate','Đ20.00 = NGN 1.00')]),const SizedBox(height:18),_PrimaryButton('Redeem',onTap:()=>_snack(context,'Points redeemed')),const SizedBox(height:14),const Text('Your Davo point rewards will be credited to your NGN Wallet After Redeeming it.',style:_t12),const SizedBox(height:22),const Align(alignment:Alignment.centerLeft,child:Text('Recent Activity',style:_t16b)),const SizedBox(height:10),...['Referral: Jane Doe','Cashback Reward: Milestone NGN 10','Cashback Reward: Milestone NGN 10','Referral: Elena Rodriguez'].map((e)=>_ActivityRow(e,'+Đ5.00')),const SizedBox(height:26)]));}
class StudentAmbassadorScreen extends StatefulWidget {
  const StudentAmbassadorScreen({super.key});
  @override
  State<StudentAmbassadorScreen> createState() => _StudentAmbassadorScreenState();
}

class _StudentAmbassadorScreenState extends State<StudentAmbassadorScreen> {
  final school = TextEditingController();
  final studentId = TextEditingController();
  bool uploaded = false;

  @override
  void initState() {
    super.initState();
    school.addListener(_refresh);
    studentId.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    school.removeListener(_refresh);
    studentId.removeListener(_refresh);
    school.dispose();
    studentId.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = school.text.trim().isNotEmpty && studentId.text.trim().isNotEmpty && uploaded;
    return _Shell(
      title: '',
      bodyTopPadding: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Student Ambassador Details', style: _t20),
          const SizedBox(height: 24),
          _Input(label: 'School Name', hint: 'Enter your school name', controller: school, figmaFilled: true),
          const SizedBox(height: 16),
          _Input(label: 'Student ID no', hint: 'Enter your student ID No', controller: studentId, figmaFilled: true),
          const SizedBox(height: 16),
          const Text('Upload Student ID', style: _t14m),
          const SizedBox(height: 7),
          OutlinedButton.icon(
            onPressed: () => setState(() => uploaded = true),
            icon: Image.asset(
              uploaded ? '$_exactAssets/icon_check.png' : '$_exactAssets/icon_upload.png',
              width: 20,
              height: 20,
              filterQuality: FilterQuality.high,
            ),
            label: Text(uploaded ? 'Student ID uploaded' : 'Upload Student ID'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              side: const BorderSide(color: Color(0xFFEBEDF3)),
            ),
          ),
          const Spacer(),
          _PrimaryButton(
            'Submit',
            enabled: enabled,
            onTap: () => _push(context, const AmbassadorDashboardScreen()),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class AmbassadorDashboardScreen extends StatelessWidget{const AmbassadorDashboardScreen({super.key});@override Widget build(BuildContext context)=>_Shell(title:'',scroll:true,bodyTopPadding:8,child:Column(children:[Row(children:[ClipOval(child:Image.asset('$_exactAssets/ambassador_avatar_exact.png',width:40,height:40,fit:BoxFit.cover,filterQuality:FilterQuality.high)),const SizedBox(width:10),const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Hi, Callie',style:TextStyle(fontFamily:'Sora',fontSize:14,fontWeight:FontWeight.w400,color:AppColors.primary,height:1.35)),Text('Ambassador',style:TextStyle(fontFamily:'Sora',fontSize:16,fontWeight:FontWeight.w600,color:AppColors.primary,height:1.35))])),IconButton(onPressed:(){},icon:Image.asset('$_exactAssets/icon_notification_bell.png',width:22,height:22))]),const SizedBox(height:14),Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:AppColors.primary,borderRadius:BorderRadius.circular(10)),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Ambassador Program',style:TextStyle(fontFamily:'Sora',fontSize:20,fontWeight:FontWeight.w700,color:Colors.white)),SizedBox(height:4),Text('Empower your campus. Refer friends and earn rewards for every successful signup.',style:TextStyle(fontFamily:'Sora',fontSize:11,color:Colors.white)),SizedBox(height:14),Text('Silver Ambassador                         18/25',style:TextStyle(fontFamily:'Sora',fontSize:12,color:Colors.white)),SizedBox(height:6),LinearProgressIndicator(value:.72,minHeight:7,backgroundColor:Colors.white24,valueColor:AlwaysStoppedAnimation(Colors.white)),SizedBox(height:5),Text('7 more referrals to unlock Gold Tier',style:TextStyle(fontFamily:'Sora',fontSize:10,color:Colors.white70))])),const SizedBox(height:18),_referralBox(),const SizedBox(height:18),const _StatsGrid([('Students Referred','345'),('Students Verified','205'),('Pending','140'),('Earned','Đ400.00')]),const SizedBox(height:18),Row(children:[Expanded(child:_QuickAssetAction('$_exactAssets/icon_share.png','Share Link',(){})),Expanded(child:_QuickAssetAction('$_exactAssets/icon_qr.png','QR Code',(){})),Expanded(child:_QuickAssetAction('$_exactAssets/icon_trophy.png','Rewards',()=>_push(context,const DavoPointsScreen()))),Expanded(child:_QuickAssetAction('$_exactAssets/icon_leaderboard.png','Leaderboard',()=>_push(context,const AmbassadorLeaderboardScreen())))]),const SizedBox(height:22),const Align(alignment:Alignment.centerLeft,child:Text('Referrals',style:_t16b)),const SizedBox(height:8),..._people.take(4).map((e)=>_PersonRow(e.$1,e.$2,e.$3)),const SizedBox(height:24)]));}
class AmbassadorLeaderboardScreen extends StatelessWidget {
  const AmbassadorLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Ambassador Leaderboard',
        titleStyle: _navSora16,
        scroll: true,
        child: Column(
          children: [
            const SizedBox(height: 42),
            const SizedBox(
              height: 333,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(left: 0, top: 76, child: _Podium('2', 'Sarah L.', '42 Refs', 93)),
                  Positioned(left: 120, top: 0, child: _Podium('1', 'James P.', '145 Referrals', 130)),
                  Positioned(right: 4, top: 89, child: _Podium('3', 'Mila K.', '39 Refs', 80)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Row(
              children: [
                Text('Rankings 1-10', style: _t16b),
                Spacer(),
                Text('Total 124 Active', style: _t14),
              ],
            ),
            const SizedBox(height: 16),
            ..._rankings.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _RankRow(e.key + 4, e.value.$1, e.value.$2, e.value.$3),
                )),
            const SizedBox(height: 24),
            const _CurrentRankCard(),
            const SizedBox(height: 26),
          ],
        ),
      );
}

// ---- Figma 3418:85446 exact Profile/Settings flows ----
class PersonalInformationV12Screen extends StatefulWidget {
  const PersonalInformationV12Screen({super.key});
  @override State<PersonalInformationV12Screen> createState()=>_PersonalInformationV12ScreenState();
}
class _PersonalInformationV12ScreenState extends State<PersonalInformationV12Screen>{
  bool editing=false;
  final values=<String,String>{'Full name':'Vincent Chukwu','Email':'vincent.dollars@gmail.com','Phone Number':'+234 9062185004','Country':'Nigeria','Username':'Admiral','Date of Birth':'1996-08-24','Residential Address':'Flat A2, Guzape Estate, Abuja'};
  @override Widget build(BuildContext context)=>_Shell(title:'Personal Information',titleStyle:_navInter20,scroll:true,showHeaderDivider:true,bodyTopPadding:24,child:Column(children:[
    const _ProfileAvatar(edit: true),
    const SizedBox(height:24),
    ...values.entries.map((e)=>editing?_EditableInfoField(label:e.key,value:e.value):_InfoField(label:e.key,value:e.value)),
    const SizedBox(height:21),
    _PrimaryButton(editing?'Save Changes':'Edit Information',onTap:(){if(editing){_push(context,const PersonalInformationSuccessScreen());}else{setState(()=>editing=true);}}),
    const SizedBox(height:20),
  ]));
}
class PersonalInformationSuccessScreen extends StatelessWidget {
  const PersonalInformationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(backgroundColor: Colors.white, surfaceTintColor: Colors.white, leading: const BackButton()),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
            child: Column(
              children: [
                const Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 64),
                        DavoOutcomeContent(tempo:DavoOutcomeTempo.compact,size:112,semanticLabel:'Personal information updated successfully',heading:Column(children:[Text('Information Updated',style:_t20sb,textAlign:TextAlign.center),SizedBox(height:8),Text('Your personal information has been updated successfully',style:_t14,textAlign:TextAlign.center)])),
                        SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                _PrimaryButton('Done', onTap: () => Navigator.of(context).popUntil((route) => route.isFirst)),
              ],
            ),
          ),
        ),
      );
}

class KycTierOverviewScreen extends StatelessWidget {
  const KycTierOverviewScreen({super.key, this.completedTier = 0});
  final int completedTier;

  @override
  Widget build(BuildContext context) {
    final activeTier = completedTier < 3 ? completedTier + 1 : 3;
    final gap = completedTier == 0 ? 16.0 : 26.0;
    return _Shell(
      title: 'Verify Your Account',
      titleStyle: _navSora16,
      scroll: true,
      bodyTopPadding: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text(
            'Complete verification to increase your limits and enjoy all Davochain features',
            style: _t16b,
          ),
          const SizedBox(height: 26),
          _TierCard(
            tier: 'Tier 1',
            title: 'NIN Verification',
            subtitle: 'Basic access with Standard limits',
            done: completedTier >= 1,
            active: activeTier == 1 && completedTier < 1,
            onTap: () => _push(context, const KycTierIntroScreen(tier: 1)),
          ),
          SizedBox(height: gap),
          _TierCard(
            tier: 'Tier 2',
            title: 'BVN Verification',
            subtitle: 'Higher limits and more',
            done: completedTier >= 2,
            active: activeTier == 2 && completedTier < 2,
            onTap: () => _push(context, const KycTierIntroScreen(tier: 2)),
          ),
          SizedBox(height: gap),
          _TierCard(
            tier: 'Tier 3',
            title: 'ID & Address Verification',
            subtitle: 'Full access to all features',
            done: completedTier >= 3,
            active: activeTier == 3 && completedTier < 3,
            onTap: () => _push(context, const KycTierIntroScreen(tier: 3)),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class KycTierIntroScreen extends StatelessWidget {
  const KycTierIntroScreen({super.key, required this.tier});
  final int tier;

  @override
  Widget build(BuildContext context) {
    final title = tier == 1
        ? 'Tier 1: NIN Verification'
        : tier == 2
            ? 'Tier 2: BVN Verification'
            : 'Tier 3: ID & Address Verification';
    final description = tier == 1
        ? 'Verify your National Identification Number (NIN) and complete a quick face verification to increase your limits'
        : tier == 2
            ? 'Verify your Bank Verification Number (BVN) to secure your account and increase your transaction limits'
            : 'Upload a government issue ID, proof of address and complete a final face verification';
    final requirements = tier == 1
        ? const [
            ('$_exactAssets/kyc_req_id_exact.png', 'Your 11-digit NIN'),
            ('$_exactAssets/kyc_req_id_v_exact.png', 'A well-lit environment'),
            ('$_exactAssets/kyc_req_user_exact.png', 'Your face clearly visible'),
          ]
        : tier == 2
            ? const [
                ('$_exactAssets/kyc_req_id_exact.png', 'Valid Nigerian BVN (11 digits)'),
                ('$_exactAssets/kyc_req_phone_exact.png', 'Your registered phone number'),
                ('$_exactAssets/kyc_req_user_pin_exact.png', 'Must match your personal details'),
              ]
            : const [
                ('$_exactAssets/kyc_req_id_exact.png', 'Government-issued ID'),
                ('$_exactAssets/kyc_req_document_exact.png', 'A valid proof of address document'),
                ('$_exactAssets/kyc_req_user_exact.png', 'Your face clearly visible'),
              ];

    return _Shell(
      title: 'Verify Your Account',
      titleStyle: _navSora16,
      bodyTopPadding: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: 60,
              height: 60,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xFFE8EFFF),
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                '$_exactAssets/tier_${tier}_exact.png',
                width: 40,
                height: 40,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: _t16b),
                const SizedBox(height: 8),
                Text(description, style: _t14),
              ],
            ),
          ),
          const SizedBox(height: 44),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('What you need', style: _t16b),
          ),
          const SizedBox(height: 24),
          ...requirements.asMap().entries.map(
                (entry) => Padding(
                  padding: EdgeInsets.only(bottom: entry.key == requirements.length - 1 ? 0 : 16),
                  child: _KycRequirementLine(asset: entry.value.$1, text: entry.value.$2),
                ),
              ),
          const Spacer(),
          _PrimaryButton(
            'Start',
            onTap: () => _push(
              context,
              tier == 1
                  ? const CompleteProfileV12Screen()
                  : tier == 2
                      ? const BvnEntryV12Screen()
                      : const Tier3SelectIdScreen(),
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class CompleteProfileV12Screen extends StatefulWidget{const CompleteProfileV12Screen({super.key});@override State<CompleteProfileV12Screen> createState()=>_CompleteProfileV12ScreenState();}
class _CompleteProfileV12ScreenState extends State<CompleteProfileV12Screen>{
  final first=TextEditingController(),middle=TextEditingController(),last=TextEditingController(),dob=TextEditingController();
  @override void initState(){super.initState();final draft=VerificationSession.instance.profileDraft;first.text=draft['first']??'';middle.text=draft['middle']??'';last.text=draft['last']??'';dob.text=draft['dob']??'';for(final c in [first,middle,last,dob]){c.addListener(_refresh);}}
  void _refresh(){VerificationSession.instance.saveProfile({'first':first.text,'middle':middle.text,'last':last.text,'dob':dob.text});setState((){});}
  @override void dispose(){for(final c in [first,middle,last,dob]){c.removeListener(_refresh);c.dispose();}super.dispose();}
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDavoDatePicker(context, title:'Date of birth', firstDate:DateTime(1900), lastDate:DateTime(now.year,now.month,now.day), initialDate:DateTime.tryParse(dob.text) ?? DateTime(2000,1,1));
    if(mounted && date != null) dob.text = '${date.year}-${date.month.toString().padLeft(2,"0")}-${date.day.toString().padLeft(2,"0")}';
  }
  @override Widget build(BuildContext context){final enabled=[first,last,dob].every((c)=>c.text.trim().isNotEmpty);return _Shell(title:'Basic verification',titleStyle:_navSora16,bodyTopPadding:0,scroll:true,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const SizedBox(height:39),const Text('Complete your profile',style:_t16b),const SizedBox(height:8),const Text('Fill in your personal information to get started with verification',style:_t14),const SizedBox(height:24),_Input(label:'First name',hint:'Enter first name',controller:first,figmaFilled:true,labelSize:16,hintSize:12),const SizedBox(height:24),_Input(label:'Middle name (optional)',hint:'Enter middle name',controller:middle,figmaFilled:true,labelSize:16,hintSize:12),const SizedBox(height:22),_Input(label:'Last name',hint:'Enter last name',controller:last,figmaFilled:true,labelSize:16,hintSize:12),const SizedBox(height:24),GestureDetector(onTap:_pickDate,child:AbsorbPointer(child:_Input(label:'Date of birth',hint:'Select date of birth',controller:dob,figmaFilled:true,labelSize:16,hintSize:12))),const SizedBox(height:32),_PrimaryButton('Continue',enabled:enabled,onTap:()=>_push(context,const CompleteProfileContactV12Screen())),const SizedBox(height:28)]));}
}
class CompleteProfileContactV12Screen extends StatefulWidget {
  const CompleteProfileContactV12Screen({super.key});
  @override
  State<CompleteProfileContactV12Screen> createState() => _CompleteProfileContactV12ScreenState();
}

class _CompleteProfileContactV12ScreenState extends State<CompleteProfileContactV12Screen> {
  final phone = TextEditingController();
  final address = TextEditingController();
  final state = TextEditingController();

  @override
  void initState() {
    super.initState();
    final draft = VerificationSession.instance.profileDraft;
    phone.text = draft['phone'] ?? '';
    address.text = draft['address'] ?? '';
    state.text = draft['state'] ?? '';
    for (final controller in [phone, address, state]) {
      controller.addListener(_refresh);
    }
  }

  void _refresh() { VerificationSession.instance.saveProfile({'phone': phone.text, 'address': address.text, 'state': state.text}); setState(() {}); }

  @override
  void dispose() {
    for (final controller in [phone, address, state]) {
      controller.removeListener(_refresh);
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = RegExp(r'^0?\d{10}$').hasMatch(phone.text.trim()) &&
        address.text.trim().isNotEmpty &&
        state.text.trim().isNotEmpty;
    return _Shell(
      title: 'Basic verification',
      scroll: true,
      titleStyle: _navSora16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 27),
          _ContactPhoneField(controller: phone),
          const SizedBox(height: 24),
          _ContactAddressField(controller: address),
          const SizedBox(height: 24),
          const Text('State', style: _t16),
          const SizedBox(height: 8),
          DavoStatePicker(
            value: state.text.isEmpty ? null : state.text,
            states: _nigerianStates,
            onChanged: (value) => state.text = value,
          ),
          const SizedBox(height: 24),
          const _CountryField(),
          const SizedBox(height: 28),
          _PrimaryButton(
            'Continue',
            enabled: enabled,
            onTap: () { VerificationSession.instance.completeProfile(); _push(context, const BasicIdentityChoiceScreen()); },
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class BvnEntryV12Screen extends StatefulWidget {
  const BvnEntryV12Screen({super.key});
  @override
  State<BvnEntryV12Screen> createState() => _BvnEntryV12ScreenState();
}

class _BvnEntryV12ScreenState extends State<BvnEntryV12Screen> {
  final bvn = TextEditingController();

  @override
  void initState() {
    super.initState();
    bvn.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    bvn.removeListener(_refresh);
    bvn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = bvn.text.replaceAll(RegExp(r'\D'), '').length == 11;
    return _Shell(
      title: 'Verify your identity',
      titleStyle: _navSora16,
      bodyTopPadding: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 39),
          const Text(
            'We need your Bank Verification Number\n(BVN) to secure your account.',
            style: _t16m,
          ),
          const SizedBox(height: 24),
          _Input(
            label: 'Your BVN',
            hint: 'Enter your BVN number',
            controller: bvn,
            keyboard: TextInputType.number,
            labelSize: 16,
            hintSize: 16,
            hintFontFamily: 'Open Sans',
          ),
          const SizedBox(height: 12),
          const _BvnHintPill(),
          const SizedBox(height: 32),
          const _KycInfoCard(
            height: 108,
            title: 'Why do we ask for your BVN?',
            body: 'We use your BVN to verify your identity and ensure that your account is secure. This does not mean that we will be able to access your bank account.',
          ),
          const Spacer(),
          _PrimaryButton(
            'Continue',
            enabled: enabled,
            onTap: () => _push(
              context,
              const VerificationProcessingV12Screen(
                title: 'Verifying your BVN',
                body: 'This may take a few seconds\nPlease do not leave this page',
                next: TierCompletionV12Screen(tier: 2),
              ),
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class NinEntryV12Screen extends StatefulWidget {
  const NinEntryV12Screen({super.key});
  @override
  State<NinEntryV12Screen> createState() => _NinEntryV12ScreenState();
}

class _NinEntryV12ScreenState extends State<NinEntryV12Screen> {
  final nin = TextEditingController();

  @override
  void initState() {
    super.initState();
    nin.addListener(_refresh);
  }

  void _refresh() => setState(() {});

  @override
  void dispose() {
    nin.removeListener(_refresh);
    nin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled = nin.text.replaceAll(RegExp(r'\D'), '').length == 11;
    return _Shell(
      title: 'Verify your identity',
      titleStyle: _navSora16,
      bodyTopPadding: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 31),
          const Text(
            'We need your National Identification Number (NIN) to secure your account.',
            style: _t16m,
          ),
          const SizedBox(height: 20),
          _Input(
            label: '',
            hint: 'Enter your 11-digits NIN',
            controller: nin,
            keyboard: TextInputType.number,
            hintSize: 16,
            hintFontFamily: 'Open Sans',
          ),
          const SizedBox(height: 28),
          const _KycInfoCard(
            height: 78,
            body: 'Your NIN is securely processed with the National Identity Management Commission (NIMC)',
          ),
          const Spacer(),
          _PrimaryButton(
            'Continue',
            enabled: enabled,
            onTap: () => _push(
              context,
              const VerificationProcessingV12Screen(
                title: 'Verifying your NIN',
                body: 'We’re retrieving your identity infomation\nfrom NIMC. This may take a few seconds',
                next: KycSelfieV12Screen(),
              ),
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

class VerificationProcessingV12Screen extends StatefulWidget {
  const VerificationProcessingV12Screen({
    super.key,
    required this.title,
    required this.body,
    required this.next,
  });

  final String title, body;
  final Widget next;

  @override
  State<VerificationProcessingV12Screen> createState() => _VerificationProcessingV12ScreenState();
}

class _VerificationProcessingV12ScreenState extends State<VerificationProcessingV12Screen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => widget.next),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final tier3 = widget.title == 'Verifying your ID and address';
    return _Shell(
      title: 'Verify Your Account',
      titleStyle: _navSora16,
      bodyTopPadding: 0,
      child: Column(
        children: [
          SizedBox(height: tier3 ? 24 : 59),
          Image.asset(
            '$_exactAssets/status_animation_exact.gif',
            width: 150,
            height: 150,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
          const SizedBox(height: 27),
          SizedBox(
            width: tier3 ? 328 : 327,
            child: Text(widget.title, style: _t20sb, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: tier3 ? 328 : 294,
            child: Text(widget.body, style: _t14, textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}

class TierCompletionV12Screen extends StatelessWidget {
  const TierCompletionV12Screen({super.key, required this.tier});
  final int tier;

  @override
  Widget build(BuildContext context) {
    final title = tier == 1 ? 'Tier 1 Completed' : 'Tier 2 Completed';
    final body = tier == 1
        ? 'Your NIN preview is complete. You can now explore the next verification tier.'
        : 'Your BVN preview is complete. You can now explore the next verification tier.';
    final next = tier == 1 ? 'Continue to Tier 2' : 'Continue to Tier 3';
    return DavoResultScreen(
      title: title,
      message: body,
      mark: const DavoSuccessMark(tempo: DavoOutcomeTempo.compact, size: 150, semanticLabel: 'Verification preview complete'),
      details: _CurrentTierCard(tier: tier),
      actions: Column(mainAxisSize: MainAxisSize.min, children: [
        _PrimaryButton(next, onTap: () => _push(context, KycTierOverviewScreen(completedTier: tier))),
        const SizedBox(height: 12),
        TextButton(onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst), child: const Text('Maybe Later')),
      ]),
    );
  }
}

class KycSelfieV12Screen extends StatelessWidget {
  const KycSelfieV12Screen({super.key});

  @override
  Widget build(BuildContext context) => _Shell(
        title: 'KYC Verification',
        titleStyle: _navInter20,
        bodyTopPadding: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text('Take a selfie', style: _t20sb),
            const SizedBox(height: 8),
            const Text(
              'Make sure your face is well-lit and fits inside\nthe frame for verification.',
              style: _t14,
            ),
            const SizedBox(height: 40),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  '$_exactAssets/kyc_selfie_reference_exact.png',
                  width: 171,
                  height: 171,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.only(left: 28),
              child: SizedBox(
                width: 330,
                child: Text(
                  'To ensure the security of your account and comply with regulatory requirements, we need to verify your identity.',
                  style: _t14,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.only(left: 28),
              child: SizedBox(
                width: 330,
                child: Text('take a photo of your face to complete this process.', style: _t14),
              ),
            ),
            const Spacer(),
            _PrimaryButton(
              'Start live face detection',
              onTap: () => _push(context, const FaceDetectionV12Screen()),
            ),
            const SizedBox(height: 12),
            _SecondaryButton('Later', onTap: () => Navigator.pop(context)),
            const SizedBox(height: 72),
          ],
        ),
      );
}

class FaceDetectionV12Screen extends StatefulWidget {
  const FaceDetectionV12Screen({super.key});
  @override
  State<FaceDetectionV12Screen> createState() => _FaceDetectionV12ScreenState();
}

class _FaceDetectionV12ScreenState extends State<FaceDetectionV12Screen> with SingleTickerProviderStateMixin {
  late final AnimationController c;

  @override
  void initState() {
    super.initState();
    c = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Face Verification',
        titleStyle: _navSora16,
        bodyTopPadding: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text('Live face detection', style: _t20sb),
            const SizedBox(height: 8),
            const Text('Scan your face to verify your identity', style: _t14),
            const SizedBox(height: 62),
            Center(
              child: GestureDetector(
                onTap: () => _push(context, const FaceReviewV12Screen()),
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: const Color(0xFF090909),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Stack(
                    children: [
                      ..._cornerFrames(),
                      AnimatedBuilder(
                        animation: c,
                        builder: (_, __) => Positioned(
                          left: 28,
                          right: 28,
                          top: 36 + c.value * 228,
                          child: Container(height: 1.5, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const SizedBox(
              width: double.infinity,
              child: Text('Place your head within the frame', style: _t16, textAlign: TextAlign.center),
            ),
          ],
        ),
      );
}

class FaceReviewV12Screen extends StatelessWidget {
  const FaceReviewV12Screen({super.key});

  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Face Verification',
        titleStyle: _navSora16,
        bodyTopPadding: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text('Review your photo', style: _t20sb),
            const SizedBox(height: 8),
            const Text('make sure your face is clear before you submit.', style: _t14),
            const SizedBox(height: 36),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  '$_exactAssets/kyc_face_review_exact.png',
                  width: 171,
                  height: 203,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Check that:', style: _t16b),
            const SizedBox(height: 20),
            const _FaceStepLine('Your whole face is inside the  frame.'),
            const _FaceStepLine('Your photo is sharp and not blurry.'),
            const _FaceStepLine('Nothing Covers your face (no glasses, hat,or mask)'),
            const Spacer(),
            _PrimaryButton(
              'Submit photo',
              onTap: () => _push(
                context,
                const VerificationProcessingV12Screen(
                  title: 'Matching your identity',
                  body: 'We’re comparing your live selfie with your\nNIN records. this may take a few seconds',
                  next: TierCompletionV12Screen(tier: 1),
                ),
              ),
            ),
            const SizedBox(height: 15),
            _SecondaryButton('Retake photo', onTap: () => Navigator.pop(context)),
            const SizedBox(height: 72),
          ],
        ),
      );
}

class Tier3SelectIdScreen extends StatefulWidget {
  const Tier3SelectIdScreen({super.key});
  @override
  State<Tier3SelectIdScreen> createState() => _Tier3SelectIdScreenState();
}

class _Tier3SelectIdScreenState extends State<Tier3SelectIdScreen> {
  int selected = 0;

  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Verify Your Account',
        titleStyle: _navSora16,
        bodyTopPadding: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text('Select ID Type ', style: _t16b),
            const SizedBox(height: 8),
            const Text(
              'Verify your identity with a government issued ID to increase your limits',
              style: _t14,
            ),
            const SizedBox(height: 24),
            _V12ChoiceTile(
              'National ID card ',
              selected == 0,
              () => setState(() => selected = 0),
              asset: '$_exactAssets/national_id.png',
              iconDisplaySize: 32,
            ),
            const SizedBox(height: 16),
            _V12ChoiceTile(
              'International Passport',
              selected == 1,
              () => setState(() => selected = 1),
              asset: '$_exactAssets/passport.png',
              iconDisplaySize: 32,
            ),
            const SizedBox(height: 16),
            _V12ChoiceTile(
              'International Passport',
              selected == 2,
              () => setState(() => selected = 2),
              asset: '$_exactAssets/driver.png',
              iconDisplaySize: 32,
            ),
            const Spacer(),
            _PrimaryButton('Start', onTap: () => _push(context, const Tier3UploadIdScreen())),
            const SizedBox(height: 77),
          ],
        ),
      );
}

class Tier3UploadIdScreen extends StatefulWidget {
  const Tier3UploadIdScreen({super.key});
  @override
  State<Tier3UploadIdScreen> createState() => _Tier3UploadIdScreenState();
}

class _Tier3UploadIdScreenState extends State<Tier3UploadIdScreen> {
  bool front = false, back = false;

  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Verify Your Account',
        titleStyle: _navSora16,
        bodyTopPadding: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text('Upload your ID', style: _t16b),
            const SizedBox(height: 8),
            const Text('Provide a clear photo of your government issued ID', style: _t14),
            const SizedBox(height: 24),
            _Tier3UploadLargeCard(
              title: 'Upload ID Front',
              subtitle: 'JPG, PNG or PDF (Max 5MB)',
              done: front,
              onTap: () => setState(() => front = true),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _Tier3UploadSmallCard(
                    asset: '$_exactAssets/tier3_cloud_upload_exact.png',
                    title: 'Upload ID Back',
                    subtitle: 'Optional',
                    onTap: () => setState(() => back = true),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: _Tier3UploadSmallCard(
                    asset: '$_exactAssets/tier3_camera_exact.png',
                    title: 'Take Photo',
                    subtitle: '(Use camera)',
                    onTap: () => setState(() => front = true),
                  ),
                ),
              ],
            ),
            const Spacer(),
            _PrimaryButton(
              'Continue',
              enabled: front,
              onTap: () => _push(context, const Tier3SelectDocumentScreen()),
            ),
            const SizedBox(height: 77),
          ],
        ),
      );
}

class Tier3SelectDocumentScreen extends StatefulWidget {
  const Tier3SelectDocumentScreen({super.key});
  @override
  State<Tier3SelectDocumentScreen> createState() => _Tier3SelectDocumentScreenState();
}

class _Tier3SelectDocumentScreenState extends State<Tier3SelectDocumentScreen> {
  int selected = 0;

  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Verify Your Account',
        titleStyle: _navSora16,
        bodyTopPadding: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text('Select Docment Type ', style: _t16b),
            const SizedBox(height: 8),
            const Text('Choose the document you want to use for address verifcation', style: _t14),
            const SizedBox(height: 24),
            _V12ChoiceTile(
              'Utility Bill',
              selected == 0,
              () => setState(() => selected = 0),
              subtitle: '(Electricity, Water, Internet, ETC)',
              asset: '$_exactAssets/document_edit_exact.png',
              iconDisplaySize: 30,
            ),
            const SizedBox(height: 16),
            _V12ChoiceTile(
              'Bank Statement',
              selected == 1,
              () => setState(() => selected = 1),
              subtitle: '(Last 3 months)',
              asset: '$_exactAssets/document_edit_exact.png',
              iconDisplaySize: 30,
            ),
            const SizedBox(height: 16),
            _V12ChoiceTile(
              'Government Document',
              selected == 2,
              () => setState(() => selected = 2),
              subtitle: '(e.g. tax Certificate)',
              asset: '$_exactAssets/document_edit_exact.png',
              iconDisplaySize: 30,
            ),
            const SizedBox(height: 16),
            _V12ChoiceTile(
              'Tenancy Agreement',
              selected == 3,
              () => setState(() => selected = 3),
              asset: '$_exactAssets/document_edit_exact.png',
              iconDisplaySize: 30,
            ),
            const Spacer(),
            _PrimaryButton('Continue', onTap: () => _push(context, const Tier3UploadDocumentScreen())),
            const SizedBox(height: 91),
          ],
        ),
      );
}

class Tier3UploadDocumentScreen extends StatefulWidget {
  const Tier3UploadDocumentScreen({super.key});
  @override
  State<Tier3UploadDocumentScreen> createState() => _Tier3UploadDocumentScreenState();
}

class _Tier3UploadDocumentScreenState extends State<Tier3UploadDocumentScreen> {
  bool uploaded = false;

  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Verify Your Account',
        titleStyle: _navSora16,
        bodyTopPadding: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text('Upload Document', style: _t16b),
            const SizedBox(height: 24),
            _Tier3DocumentUploadCard(
              uploaded: uploaded,
              onTap: () => setState(() => uploaded = true),
            ),
            const SizedBox(height: 16),
            if (uploaded) ...[
              _UploadedDocumentFile(onTap: () => setState(() => uploaded = false)),
              const SizedBox(height: 24),
            ],
            _Tier3DocumentNotice(uploaded: uploaded),
            const Spacer(),
            _PrimaryButton(
              'Continue',
              enabled: uploaded,
              onTap: () => _push(context, const Tier3AddressReviewScreen()),
            ),
            const SizedBox(height: 70),
          ],
        ),
      );
}

class Tier3AddressReviewScreen extends StatelessWidget {
  const Tier3AddressReviewScreen({super.key});

  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Verify Your Account',
        titleStyle: _navSora16,
        scroll: true,
        bodyTopPadding: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text('Upload Document', style: _t16b),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                '$_exactAssets/kyc_address_document_exact.png',
                width: 358,
                height: 328,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 358,
              height: 92,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Address Details', style: _t14b),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset('$_exactAssets/profile_location_exact.png', width: 20, height: 20, filterQuality: FilterQuality.high),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text('12, Adeola Street, Victoria Island, Lagos\nNigeria.', style: _t12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    'Edit',
                    style: TextStyle(fontFamily:'Sora',fontSize:12,fontWeight:FontWeight.w600,color:AppColors.primary,height:1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 142),
            _PrimaryButton('Continue', onTap: () => _push(context, const Tier3FaceSubmitScreen())),
            const SizedBox(height: 52),
          ],
        ),
      );
}

class Tier3FaceSubmitScreen extends StatelessWidget {
  const Tier3FaceSubmitScreen({super.key});

  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Face Verification',
        titleStyle: _navSora16,
        bodyTopPadding: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text('Submit face', style: _t20sb),
            const SizedBox(height: 8),
            const Text('Does this look good to you?', style: _t14),
            const SizedBox(height: 36),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  '$_exactAssets/kyc_face_review_exact.png',
                  width: 171,
                  height: 203,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Look straight at the camera', style: _t16b),
            const SizedBox(height: 20),
            const _FaceStepLine('Turn your head left', done: true),
            const _FaceStepLine('Turn your head right'),
            const _FaceStepLine('Blink your eyes'),
            const Spacer(),
            _PrimaryButton(
              'Submit face',
              onTap: () => _push(context, const Tier3VerificationProcessingScreen()),
            ),
            const SizedBox(height: 72),
          ],
        ),
      );
}

class Tier3VerificationProcessingScreen extends StatelessWidget {
  const Tier3VerificationProcessingScreen({super.key});
  @override
  Widget build(BuildContext context) => const VerificationProcessingV12Screen(
        title: 'Verifying your ID and address',
        body: 'We are checking the ID and documents details\nThis may take a few minutes',
        next: FullyVerifiedV12Screen(),
      );
}

class FullyVerifiedV12Screen extends StatelessWidget {
  const FullyVerifiedV12Screen({super.key});
  @override
  Widget build(BuildContext context) => _StatusFullScreen(
        title: 'Your Account is Fully Verified',
        body: 'You now have access to all Davochain features\nand higher limits',
        button: 'Back to Home',
        onTap: () {
          PreviewAccountState.setupComplete.value = true;
          Navigator.of(context).popUntil((r) => r.isFirst);
        },
      );
}

class LinkedAccountsScreen extends StatelessWidget{const LinkedAccountsScreen({super.key});@override Widget build(BuildContext context)=>_Shell(title:'Linked Accounts',titleStyle:_navSora16SemiBold,scroll:true,child:Column(children:[const SizedBox(height:12),const _BankAccountCard(logo:'$_exactAssets/bank_access_exact.png',name:'Jenny  V.',bank:'Access Bank',number:'......3487409'),const SizedBox(height:12),const _BankAccountCard(logo:'$_exactAssets/bank_gtbank_exact.png',name:'Jenny  V.',bank:'GTBank',number:'......3487409'),const SizedBox(height:12),const _BankAccountCard(logo:'$_exactAssets/bank_opay_exact.png',name:'Jenny  V.',bank:'Opay Bank',number:'......3487409'),const SizedBox(height:18),InkWell(onTap:()=>_push(context,const AddBankAccountScreen()),child:Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(border:Border.all(color:const Color(0xFFEBEDF3)),borderRadius:BorderRadius.circular(8)),child:Row(children:[Container(width:40,height:40,alignment:Alignment.center,decoration:const BoxDecoration(color:Color(0xFFEAF2FF),shape:BoxShape.circle),child:Image.asset('$_exactAssets/icon_plus.png',width:20,height:20,filterQuality:FilterQuality.high)),const SizedBox(width:12),const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Add Account',style:_t14b),Text('Link a new bank account',style:_t12)])),Image.asset('$_exactAssets/icon_arrow_right.png',width:16,height:16)]))),const SizedBox(height:24)]));}
class AddBankAccountScreen extends StatefulWidget{const AddBankAccountScreen({super.key});@override State<AddBankAccountScreen> createState()=>_AddBankAccountScreenState();}
class _AddBankAccountScreenState extends State<AddBankAccountScreen> {
  final q = TextEditingController();
  final banks = const ['AAA Finance', 'AB Microfinance Bank', 'Access Bank',
    'Kuda Bank', 'Bank Of Agriculture', 'Carbon', 'Ecobank Bank', 'Fcmb',
    'Fidelity Bank'];

  @override
  void dispose() {
    q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = banks.where((bank) =>
      bank.toLowerCase().contains(q.text.toLowerCase().trim())).toList();
    return _Shell(
      title: 'Add Bank Account', titleStyle: _navSora16SemiBold, scroll: true,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 18),
        const Text('Select your bank to link your account', style: _t16b),
        const SizedBox(height: 16),
        TextField(
          controller: q,
          onChanged: (_) => setState(() {}),
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          decoration: InputDecoration(
            hintText: 'Search for a bank',
            hintStyle: _t14.copyWith(color: const Color(0xFF686868)),
            prefixIcon: const Icon(Icons.search_rounded, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD9DDE5))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD9DDE5))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
          ),
        ),
        const SizedBox(height: 14),
        if (filtered.isEmpty)
          const Padding(padding: EdgeInsets.symmetric(vertical: 24),
            child: Text('No banks found. Try another name.', style: _t14)),
        ...filtered.map((bank) => ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
          leading: DavoBankLogo(bankName: bank),
          title: Text(bank == 'Fcmb' ? 'FCMB' : bank, style: _t14),
          trailing: const Icon(Icons.chevron_right_rounded,
            size: 20, color: Color(0xFF686868)),
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            Navigator.pop(context);
          },
        )),
        const SizedBox(height: 20),
      ]),
    );
  }
}

class CryptoSecurityScreen extends StatefulWidget{const CryptoSecurityScreen({super.key});@override State<CryptoSecurityScreen> createState()=>_CryptoSecurityScreenState();}
class _CryptoSecurityScreenState extends State<CryptoSecurityScreen>{bool withdraw=true,address=true,network=true;@override Widget build(BuildContext context)=>_Shell(title:'Crypto Security',child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const SizedBox(height:20),const Text('Extra protection for your digital assets',style:_t14),const SizedBox(height:18),_toggleRow('Withdrawal Confirmation','Require PIN before every withdraw',withdraw,(v)=>setState(()=>withdraw=v)),_toggleRow('New Address Verification','Require additional confirmation when sending to a new address',address,(v)=>setState(()=>address=v)),_toggleRow('Network Warning','Show network warning before every external withdrawal',network,(v)=>setState(()=>network=v))]));}
class NotificationsPreferencesScreen extends StatefulWidget{const NotificationsPreferencesScreen({super.key});@override State<NotificationsPreferencesScreen> createState()=>_NotificationsPreferencesScreenState();}
class _NotificationsPreferencesScreenState extends State<NotificationsPreferencesScreen>{final vals=List<bool>.filled(10,true);@override Widget build(BuildContext context){final items=<({String group,String title,String sub})>[(group:'Transaction Alerts',title:'Crypto purchases',sub:'Get notification When you buy crypto'),(group:'',title:'Crypto Sales',sub:'Get notified when you sell crypto'),(group:'',title:'Crypto Swaps',sub:'Get notified when you swap crypto'),(group:'',title:'Deposits',sub:'Get notified when you receive crypto'),(group:'',title:'Withdrawals',sub:'Get notified when you send crypto'),(group:'',title:'Gift card transaction',sub:'Get notified about gift card activity'),(group:'Account Alerts',title:'Security alerts',sub:'Important security notifications'),(group:'',title:'Login activity',sub:'Get notified about new logins'),(group:'Marketing & Updates',title:'Promotion & Offers',sub:'Receive special offers and discounts'),(group:'',title:'Product updates',sub:'Get the latest news and features')];return _Shell(title:'Notifications',scroll:true,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const SizedBox(height:10),...items.asMap().entries.expand((e)=><Widget>[if(e.value.group.isNotEmpty)...[if(e.key>0)const SizedBox(height:20),Text(e.value.group,style:_t16b),const SizedBox(height:6)],_toggleRow(e.value.title,e.value.sub,vals[e.key],(v)=>setState(()=>vals[e.key]=v))]),const SizedBox(height:18),_toggleRow('Tips & Education','Learn about crypto and gift cards',true,(_){ }),const SizedBox(height:20)]));}}
class PrivacyScreen extends StatefulWidget{const PrivacyScreen({super.key});@override State<PrivacyScreen> createState()=>_PrivacyScreenState();}
class _PrivacyScreenState extends State<PrivacyScreen>{bool contacts=true,personalized=true,marketing=false,analytics=true;@override Widget build(BuildContext context)=>_Shell(title:'Privacy',scroll:true,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const SizedBox(height:10),_toggleRow('Contact Access','Allow Davochain to access your contacts to help you find people you may want to transact with',contacts,(v)=>setState(()=>contacts=v)),_toggleRow('Personalized Experience','Allow personalized recommendation based on your activity',personalized,(v)=>setState(()=>personalized=v)),_toggleRow('Markets Communications','Receive promotional emails and app notification',marketing,(v)=>setState(()=>marketing=v)),const SizedBox(height:18),_settingsAssetRow('$_exactAssets/icon_analytics.png','Data & Permissions','Manage how your data is used',(){}),_settingsAssetRow('$_exactAssets/icon_user_block.png','Block Users','Manage block contacts',(){}),_toggleRow('App Analytics','Help improve Davochain by sharing anonymous usage data',analytics,(v)=>setState(()=>analytics=v)),const SizedBox(height:20)]));}
class AppearanceScreen extends StatefulWidget {
  const AppearanceScreen({super.key});
  @override
  State<AppearanceScreen> createState() => _AppearanceScreenState();
}

class _AppearanceScreenState extends State<AppearanceScreen> {
  int selected = 0;

  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Appearance',
        scroll: true,
        bodyTopPadding: 24,
        child: Column(
          children: [
            SizedBox(
              height: 180,
              child: Row(
                children: [
                  Expanded(child: _AppearanceChoice('Light', '$_exactAssets/icon_sun.png', 0, selected, () => setState(() => selected = 0))),
                  const SizedBox(width: 11),
                  Expanded(child: _AppearanceChoice('Dark', '$_exactAssets/icon_moon.png', 1, selected, () => setState(() => selected = 1))),
                  const SizedBox(width: 11),
                  Expanded(child: _AppearanceChoice('System', '$_exactAssets/appearance_system_exact.png', 2, selected, () => setState(() => selected = 2))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: AspectRatio(
                aspectRatio: 358 / 384,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset('$_exactAssets/appearance_preview_exact.png', fit: BoxFit.cover, filterQuality: FilterQuality.high),
                    Positioned.fill(
                      top: 64,
                      left: 24,
                      right: 24,
                      child: Image.asset('$_exactAssets/settings_profile_images__Davopay_and_Davochain_3__Profile_Image.png', fit: BoxFit.contain, alignment: Alignment.bottomCenter, filterQuality: FilterQuality.high),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _PrimaryButton('Next', onTap: () => Navigator.pop(context)),
            const SizedBox(height: 24),
          ],
        ),
      );
}

class HelpCentreScreen extends StatefulWidget{const HelpCentreScreen({super.key});@override State<HelpCentreScreen> createState()=>_HelpCentreScreenState();}
class _HelpCentreScreenState extends State<HelpCentreScreen>{final q=TextEditingController();int cat=0;final topics=[('$_exactAssets/icon_buy_crypto.png','Buying Crypto','Learn how to buy crypto on Davochain'),('$_exactAssets/icon_sell_crypto.png','Selling Crypto','Learn how to sell crypto'),('$_exactAssets/icon_swap_crypto.png','Swapping Crypto','How to swap between cryptocurrencies'),('$_exactAssets/icon_buy_crypto.png','Depositing Crypto','How to deposit crypto to your wallet'),('$_exactAssets/icon_sell_crypto.png','Withdrawing Crypto','How to withdraw crypto to an external wallet'),('$_exactAssets/icon_gift.png','Gift cards','How to buy and sell gift cards'),('$_exactAssets/icon_shield_check.png','Account & Security','Manage your account and stay safe')];@override Widget build(BuildContext context){final list=topics.where((t)=>t.$2.toLowerCase().contains(q.text.toLowerCase())).toList();return _Shell(title:'Help Centre',scroll:true,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const SizedBox(height:12),TextField(controller:q,onChanged:(_)=>setState((){}),decoration:InputDecoration(hintText:'Search for help articles',prefixIcon:Padding(padding:const EdgeInsets.all(14),child:Image.asset('$_exactAssets/icon_search.png',width:16,height:16)))),const SizedBox(height:16),Row(children:['All','Crypto','Gift Card','Account'].asMap().entries.map((e)=>Expanded(child:Padding(padding:EdgeInsets.only(right:e.key==3?0:8),child:ChoiceChip(label:Center(child:Text(e.value)),selected:cat==e.key,onSelected:(_)=>setState(()=>cat=e.key),showCheckmark:false,selectedColor:AppColors.primary,labelStyle:TextStyle(fontFamily:'Sora',fontSize:11,color:cat==e.key?Colors.white:AppColors.body),side:BorderSide.none)))).toList()),const SizedBox(height:24),const Text('Popular Topics',style:_t20),const SizedBox(height:12),...list.map((t)=>_HelpTopicRow(asset:t.$1,title:t.$2,subtitle:t.$3)),const SizedBox(height:24)]));}}

class _HelpTopicRow extends StatelessWidget {
  const _HelpTopicRow({required this.asset, required this.title, required this.subtitle});
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
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.asset(asset, width: 24, height: 24, fit: BoxFit.contain, filterQuality: FilterQuality.high),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: _t14b),
                  const SizedBox(height: 3),
                  Text(subtitle, style: _t12),
                ],
              ),
            ),
            Image.asset('$_exactAssets/icon_arrow_right.png', width: 22, height: 22, filterQuality: FilterQuality.high),
          ],
        ),
      );
}

class _EditableInfoField extends StatefulWidget {
  const _EditableInfoField({required this.label, required this.value});
  final String label, value;

  @override
  State<_EditableInfoField> createState() => _EditableInfoFieldState();
}

class _EditableInfoFieldState extends State<_EditableInfoField> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) => Focus(
    onFocusChange: (focused) { if (mounted) setState(() => _focused = focused); },
    child: Container(
        width: double.infinity,
        height: 78,
        margin: const EdgeInsets.only(bottom: 19),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _focused ? AppColors.primary : const Color(0xFFD9DDE5), width: _focused ? 1.5 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.label, style: _personalInfoLabel),
            const SizedBox(height: 8),
            SizedBox(
              height: 19,
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: widget.value,
                      style: _t14,
                      decoration: const DavoInlineInputDecoration(
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Image.asset(
                    widget.label == 'Username'
                        ? '$_exactAssets/profile_edit_outline_exact.png'
                        : '$_exactAssets/profile_tick_square_exact.png',
                    width: 24,
                    height: 24,
                    filterQuality: FilterQuality.high,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
}
class _BvnHintPill extends StatelessWidget {
  const _BvnHintPill();
  @override
  Widget build(BuildContext context) => Container(
        width: 154,
        height: 29,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFE8EFFE),
          borderRadius: BorderRadius.circular(1000),
        ),
        child: const Text(
          'Enter BVN above (11 digits)',
          style: TextStyle(fontFamily:'Sora',fontSize:10,fontWeight:FontWeight.w500,color:AppColors.primary),
        ),
      );
}

class _KycInfoCard extends StatelessWidget {
  const _KycInfoCard({required this.height, required this.body, this.title});
  final double height;
  final String body;
  final String? title;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        constraints: BoxConstraints(minHeight: height),
        padding: EdgeInsets.fromLTRB(21, title == null ? 24 : 20, 22, 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF7EA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('$_exactAssets/kyc_info_exact.png', width: 16, height: 16, filterQuality: FilterQuality.high),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null) ...[
                    Text(title!, style: _t14b),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    body,
                    style: const TextStyle(
                      fontFamily:'Sora',
                      fontSize:10,
                      height:1.5,
                      fontWeight:FontWeight.w400,
                      color:Color(0xFF424242),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

class _ContactPhoneField extends StatelessWidget {
  const _ContactPhoneField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Phone Number', style: TextStyle(fontFamily:'Sora',fontSize:16,fontWeight:FontWeight.w400,color:Color(0xFF424242),height:1.35)),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                constraints: const BoxConstraints(minWidth: 86),
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFD2D2D2)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('$_exactAssets/nigeria_flag_exact.png', width: 21, height: 14, fit: BoxFit.contain, filterQuality: FilterQuality.high),
                    const SizedBox(width: 3),
                    const Text('+234', style: TextStyle(fontFamily:'Sora',fontSize:12,color:Color(0xFF424242))),
                  ],
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(fontFamily:'Sora',fontSize:14,color:Color(0xFF424242)),
                    decoration: InputDecoration(
                      hintText: 'Enter your phone number',
                      hintStyle: const TextStyle(fontFamily:'Sora',fontSize:14,color:Color(0xFF686868)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0x14121212))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0x14121212))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
}

class _ContactAddressField extends StatelessWidget {
  const _ContactAddressField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Residential  address', style: TextStyle(fontFamily:'Sora',fontSize:16,fontWeight:FontWeight.w400,color:Color(0xFF424242),height:1.35)),
          const SizedBox(height: 4),
          SizedBox(
            height: 71,
            child: TextField(
              controller: controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: _t12.copyWith(color: const Color(0xFF424242)),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF8F9FB),
                hintText: 'House number, street, area',
                hintStyle: const TextStyle(fontFamily:'Sora',fontSize:12,color:Color(0xFF686868)),
                contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFEBEDF3))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFEBEDF3))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: AppColors.primary)),
              ),
            ),
          ),
        ],
      );
}

class _CountryField extends StatelessWidget {
  const _CountryField();

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Country', style: TextStyle(fontFamily:'Sora',fontSize:16,fontWeight:FontWeight.w400,color:Color(0xFF424242),height:1.35)),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FB),
              border: Border.all(color: const Color(0xFFEBEDF3)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Image.asset('$_exactAssets/nigeria_flag_exact.png', width: 21, height: 14, fit: BoxFit.contain, filterQuality: FilterQuality.high),
                const SizedBox(width: 9),
                const Text('Nigeria', style: TextStyle(fontFamily:'Sora',fontSize:12,color:Color(0xFF8D8D8D))),
              ],
            ),
          ),
        ],
      );
}

class _StatusFullScreen extends StatelessWidget {
  const _StatusFullScreen({required this.title, required this.body, required this.button, required this.onTap});
  final String title, body, button;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => DavoResultScreen(title: title, message: body, actions: _PrimaryButton(button, onTap: onTap));
}
class _KycRequirementLine extends StatelessWidget {
  const _KycRequirementLine({required this.asset, required this.text});
  final String asset, text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SizedBox(
          height: 24,
          child: Row(
            children: [
              Image.asset(asset, width: 24, height: 24, fit: BoxFit.contain, filterQuality: FilterQuality.high),
              const SizedBox(width: 12),
              Expanded(child: Text(text, style: _t12)),
            ],
          ),
        ),
      );
}

class _TierCard extends StatelessWidget {
  const _TierCard({
    required this.tier,
    required this.title,
    required this.subtitle,
    required this.done,
    required this.active,
    required this.onTap,
  });

  final String tier, title, subtitle;
  final bool done, active;
  final VoidCallback onTap;

  int get tierNumber => int.tryParse(tier.split(' ').last) ?? 1;
  String get iconAsset => '$_exactAssets/tier_${tierNumber}_exact.png';

  @override
  Widget build(BuildContext context) {
    final fill = active ? const Color(0xFFE8EFFF) : const Color(0xFFF8F9FB);
    final border = active ? const Color(0xFF3A77F8) : const Color(0xFFEBEDF3);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        height: 82,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: fill,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              height: 40,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: done ? const Color(0xFFD0DEFD) : const Color(0xFFEAF2FF),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      iconAsset,
                      width: tierNumber == 1 ? 20 : 24,
                      height: tierNumber == 1 ? 20 : 24,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  if (!done && !active)
                    Positioned(
                      right: -4,
                      bottom: 0,
                      child: Image.asset(
                        '$_exactAssets/tier_lock_exact.png',
                        width: 16,
                        height: 16,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tier, style: _t14.copyWith(color: done ? const Color(0xFF686868) : const Color(0xFF424242))),
                  Text(title, style: _t14b),
                  Text(subtitle, style: _t12),
                ],
              ),
            ),
            if (done)
              Container(
                width: 86,
                height: 25,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6FAEE),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('$_exactAssets/tier_completed_check_exact.png', width: 12, height: 12, filterQuality: FilterQuality.high),
                    const SizedBox(width: 8),
                    const Text(
                      'Completed',
                      style: TextStyle(fontFamily:'Sora',fontSize:10,fontWeight:FontWeight.w500,color:Color(0xFF1BA44D)),
                    ),
                  ],
                ),
              )
            else
              Image.asset('$_exactAssets/icon_arrow_right.png', width: 24, height: 24, filterQuality: FilterQuality.high),
          ],
        ),
      ),
    );
  }
}

class _CurrentTierCard extends StatelessWidget {
  const _CurrentTierCard({required this.tier});
  final int tier;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: const Color(0xFFF8F9FB), borderRadius: BorderRadius.circular(8)),
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Your Current Tier', style: _t14),
      const SizedBox(height: 12),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Image.asset(tier == 2 ? '$_exactAssets/tier2_medal_exact.png' : '$_exactAssets/tier1_medal_exact.png', width: 40, height: 40),
        const SizedBox(width: 12),
        Expanded(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Tier $tier', style: _t14b),
          const SizedBox(height: 4),
          const Text('NIN preview complete', style: _t12),
          if (tier == 2) const Text('BVN preview complete', style: _t12),
        ])),
        const SizedBox(width: 8),
        const _Pill('Active'),
      ]),
    ]),
  );
}

class _V12ChoiceTile extends StatelessWidget {
  const _V12ChoiceTile(
    this.title,
    this.selected,
    this.onTap, {
    this.subtitle,
    this.asset,
    this.iconDisplaySize = 32,
  });

  final String title;
  final String? subtitle, asset;
  final bool selected;
  final VoidCallback onTap;
  final double iconDisplaySize;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          height: 69,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FB),
            border: Border.all(
              color: selected ? const Color(0xFF104DCE) : const Color(0xFFEBEDF3),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              if (asset != null) ...[
                Container(
                  width: iconDisplaySize,
                  height: iconDisplaySize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EFFF),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Image.asset(
                    asset!,
                    width: iconDisplaySize == 30 ? 16 : 20,
                    height: iconDisplaySize == 30 ? 16 : 20,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: _t14b),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(subtitle!, style: _t12),
                    ],
                  ],
                ),
              ),
              Image.asset(
                selected ? '$_exactAssets/icon_check.png' : '$_exactAssets/icon_circle.png',
                width: selected ? 22 : 24,
                height: selected ? 22 : 24,
                filterQuality: FilterQuality.high,
              ),
            ],
          ),
        ),
      );
}

class _FaceStepLine extends StatelessWidget {
  const _FaceStepLine(this.text, {this.done = false});
  final String text;
  final bool done;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 22,
        child: Row(
          children: [
            Image.asset(
              done ? '$_exactAssets/face_step_done_exact.png' : '$_exactAssets/face_step_pending_exact.png',
              width: 16,
              height: 16,
              filterQuality: FilterQuality.high,
            ),
            const SizedBox(width: 16),
            Expanded(child: Text(text, style: _t12)),
          ],
        ),
      );
}

class _Tier3UploadLargeCard extends StatelessWidget {
  const _Tier3UploadLargeCard({
    required this.title,
    required this.subtitle,
    required this.done,
    required this.onTap,
  });

  final String title, subtitle;
  final bool done;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 358,
          height: 139,
          decoration: BoxDecoration(
            color: const Color(0xFFF4F7FF),
            border: Border.all(color: const Color(0xFFD0DEFD)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                done ? '$_exactAssets/tier_completed_check_exact.png' : '$_exactAssets/tier3_upload_exact.png',
                width: 24,
                height: 24,
                filterQuality: FilterQuality.high,
              ),
              const SizedBox(height: 16),
              Text(title, style: _t14b),
              Text(subtitle, style: _t12),
            ],
          ),
        ),
      );
}

class _Tier3UploadSmallCard extends StatelessWidget {
  const _Tier3UploadSmallCard({
    required this.asset,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String asset, title, subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 139,
          decoration: BoxDecoration(
            color: const Color(0xFFF4F7FF),
            border: Border.all(color: const Color(0xFFD0DEFD)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(asset, width: 16, height: 16, filterQuality: FilterQuality.high),
              const SizedBox(height: 16),
              Text(title, style: _t14b, textAlign: TextAlign.center),
              Text(subtitle, style: _t12, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}

class _Tier3DocumentUploadCard extends StatelessWidget {
  const _Tier3DocumentUploadCard({required this.uploaded, required this.onTap});
  final bool uploaded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 358,
          height: 226,
          decoration: BoxDecoration(
            color: const Color(0xFFF4F7FF),
            border: Border.all(color: const Color(0xFFD0DEFD)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              const SizedBox(height: 72),
              Image.asset(
                '$_exactAssets/tier3_upload_exact.png',
                width: 32,
                height: 32,
                filterQuality: FilterQuality.high,
              ),
              const SizedBox(height: 16),
              const Text('Upload ID Front', style: _t14b),
              const Text('JPG, PNG or PDF (Max 5MB)', style: _t12),
            ],
          ),
        ),
      );
}

class _UploadedDocumentFile extends StatelessWidget {
  const _UploadedDocumentFile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Container(
        width: 358,
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFD0DEFD)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Image.asset('$_exactAssets/profile_document_exact.png', width: 24, height: 24, filterQuality: FilterQuality.high),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('electricity_bill.pdf', style: _t14b),
                  Text('1.2 MB', style: _t12),
                ],
              ),
            ),
            GestureDetector(
              onTap: onTap,
              child: Image.asset('$_exactAssets/tier3_remove_exact.png', width: 24, height: 24, filterQuality: FilterQuality.high),
            ),
          ],
        ),
      );
}

class _Tier3DocumentNotice extends StatelessWidget {
  const _Tier3DocumentNotice({required this.uploaded});
  final bool uploaded;

  @override
  Widget build(BuildContext context) => Container(
        width: 358,
        height: 100,
        padding: const EdgeInsets.fromLTRB(9, 16, 8, 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF7EA),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('$_exactAssets/kyc_info_exact.png', width: 18, height: 18, filterQuality: FilterQuality.high),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Make sure the document is clear and readable \nAll corners must be visible \nDocument must be recent (within 3 months)\nYour name and address must match your profile',
                style: _t12,
              ),
            ),
          ],
        ),
      );
}

class _BankAccountCard extends StatelessWidget{const _BankAccountCard({required this.logo,required this.name,required this.bank,required this.number});final String logo,name,bank,number;@override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:AppColors.offWhite,borderRadius:BorderRadius.circular(8)),child:Row(children:[Image.asset(logo,width:40,height:40,fit:BoxFit.contain,filterQuality:FilterQuality.high),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(name,style:_t14b),Text(bank,style:_t12),Text(number,style:_t12)])),const _Pill('Verified')]));}
Widget _settingsAssetRow(String asset, String title, String subtitle, VoidCallback tap) =>
    ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: InkWell(
          onTap: tap,
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(asset, width: 18, height: 18, filterQuality: FilterQuality.high),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: _t14),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(subtitle, style: _t12),
                    ],
                  ],
                ),
              ),
              Image.asset(
                '$_exactAssets/profile_chevron_exact.png',
                width: 16,
                height: 16,
                filterQuality: FilterQuality.high,
              ),
            ],
          ),
        ),
      ),
    );
class _AppearanceChoice extends StatelessWidget {
  const _AppearanceChoice(this.title, this.asset, this.value, this.selected, this.onTap);
  final String title, asset;
  final int value, selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = selected == value;
    final isDark = value == 1;
    final background = value == 1
        ? const Color(0xFF1C1C1C)
        : value == 2
            ? const Color(0xFFF5F6F9)
            : const Color(0xFFF8F9FB);
    final labelColor = isDark ? const Color(0xFFD2D2D2) : const Color(0xFF424242);
    return SizedBox(
      width: 112,
      height: 180,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: background,
            border: active ? Border.all(color: AppColors.primary) : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              const SizedBox(height: 37),
              Image.asset(asset, width: 32, height: 32, fit: BoxFit.contain, filterQuality: FilterQuality.high),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 14,
                  height: 1.35,
                  fontWeight: FontWeight.w400,
                  color: labelColor,
                ),
              ),
              const SizedBox(height: 24),
              Image.asset(
                active ? '$_exactAssets/appearance_selected_exact.png' : '$_exactAssets/appearance_unselected_exact.png',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class _NotificationFilterPill extends StatelessWidget {
  const _NotificationFilterPill({
    required this.label,
    required this.width,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final double width;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        height: 30,
        child: Material(
          color: selected ? AppColors.primary : const Color(0xFFF5F6F9),
          borderRadius: BorderRadius.circular(1000),
          child: InkWell(
            borderRadius: BorderRadius.circular(1000),
            onTap: onTap,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: selected ? const Color(0xFFF8F9FB) : const Color(0xFF686868),
                ),
              ),
            ),
          ),
        ),
      );
}

class _SupportInputField extends StatelessWidget {
  const _SupportInputField({
    required this.label,
    required this.hint,
    required this.controller,
    this.badge,
    this.multiline = false,
  });

  final String label, hint;
  final TextEditingController controller;
  final String? badge;
  final bool multiline;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 19,
            child: Row(
              children: [
                Expanded(child: Text(label, style: _t14)),
                if (badge != null)
                  Container(
                    height: 24,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F6F9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 12,
                        color: Color(0xFF686868),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: multiline ? 160 : 54,
            child: TextField(
              controller: controller,
              maxLines: multiline ? null : 1,
              expands: multiline,
              textAlignVertical: multiline ? TextAlignVertical.top : TextAlignVertical.center,
              style: _t14,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF8F9FB),
                hintText: hint,
                hintStyle: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 14,
                  height: 1.35,
                  color: Color(0xFF686868),
                ),
                contentPadding: EdgeInsets.fromLTRB(14, multiline ? 17 : 0, 14, multiline ? 17 : 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(multiline ? 12 : 8),
                  borderSide: const BorderSide(color: Color(0xFFD9DDE5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(multiline ? 12 : 8),
                  borderSide: const BorderSide(color: Color(0xFFD9DDE5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(multiline ? 12 : 8),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),
        ],
      );
}

class _CurrentRankCard extends StatelessWidget {
  const _CurrentRankCard();

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        height: 81,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.fromLTRB(8, 19, 8, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF2FF),
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '#12',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0046C7),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 98,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 19,
                      child: Row(
                        children: [
                          Text('Alex M.', style: _t14b),
                          SizedBox(width: 4),
                          Text('(You)', style: _t14),
                        ],
                      ),
                    ),
                    const SizedBox(height: 9),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(9999),
                      child: const LinearProgressIndicator(
                        value: .62,
                        minHeight: 6,
                        backgroundColor: Color(0xFFEAF2FF),
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              const Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 9),
                  child: Text(
                    '3  To Next Rank',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                    maxLines: 1,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const SizedBox(
                width: 55,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '18',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 16,
                        height: 1.05,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0046C7),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text('Referrals', style: _t12),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

// ---- Shared UI ----
class _Shell extends StatelessWidget {
  const _Shell({
    required this.title,
    required this.child,
    this.scroll = false,
    this.showHeaderDivider = false,
    this.titleStyle,
    this.bodyTopPadding = 12,
  });

  final String title;
  final Widget child;
  final bool scroll;
  final bool showHeaderDivider;
  final TextStyle? titleStyle;
  final double bodyTopPadding;

  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: EdgeInsets.fromLTRB(16, bodyTopPadding, 16, 16),
      child: child,
    );
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        bottom: showHeaderDivider ? const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(key: ValueKey('profile-header-divider'), height: 1, thickness: 1, color: Color(0xFFF0F1F4)),
        ) : null,
        leading: IconButton(
          icon: Image.asset(
            '$_exactAssets/icon_arrow_left.png',
            width: 24,
            height: 24,
            filterQuality: FilterQuality.high,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: title.isEmpty ? null : Text(title, style: titleStyle ?? _navSora20),
      ),
      body: SafeArea(
        top: false,
        child: scroll
            ? SingleChildScrollView(

                child: body,
              )
            : body,
      ),
    );
  }
}
class _MenuItem{_MenuItem(this.asset,this.label,this.onTap,{this.trailing});final String asset;final String label;final VoidCallback onTap;final Widget? trailing;}
class _MenuCard extends StatelessWidget {
  const _MenuCard({this.title, required this.items});
  final String? title;
  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    final general = title == 'GENERAL';
    final top = (title == 'Preferences' || general) ? 20.0 : 16.0;
    final bottom = switch (title) {
      'Accounts' => 24.0,
      'Security' => 8.0,
      'Preferences' => 20.0,
      'GENERAL' => 11.0,
      _ => 16.0,
    };
    final exactHeight = switch (title) {
      'Accounts' => 230.0,
      'Security' => 270.0,
      'Preferences' => 286.0,
      'GENERAL' => 330.0,
      _ => null,
    };
    final titleStyle = general ? _sectionLabel14 : _t16b.copyWith(color: const Color(0xFF424242));

    return Container(
      width: double.infinity,
      height: exactHeight,
      padding: EdgeInsets.fromLTRB(12, top, 12, bottom),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title!, style: titleStyle),
            const SizedBox(height: 24),
          ],
          for (var i = 0; i < items.length; i++) ...[
            SizedBox(
              height: 32,
              child: InkWell(
                onTap: items[i].onTap,
                child: Row(
                  children: [
                    Image.asset(
                      items[i].asset,
                      width: 32,
                      height: 32,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                    const SizedBox(width: 16),
                    Expanded(child: Text(items[i].label, style: _t14)),
                    items[i].trailing ??
                        Image.asset(
                          '$_exactAssets/profile_chevron_exact.png',
                          width: 16,
                          height: 16,
                          filterQuality: FilterQuality.high,
                        ),
                  ],
                ),
              ),
            ),
            if (i != items.length - 1) const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}

class _ProfileActionRow extends StatelessWidget {
  const _ProfileActionRow({
    required this.asset,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });
  final String asset, label;
  final VoidCallback onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 32,
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              Image.asset(asset, width: 32, height: 32, filterQuality: FilterQuality.high),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 14,
                  height: 1.35,
                  fontWeight: FontWeight.w400,
                  color: destructive ? const Color(0xFFE84A4A) : const Color(0xFF424242),
                ),
              ),
            ],
          ),
        ),
      );
}
class _DavoSwitch extends StatelessWidget{const _DavoSwitch({required this.value,required this.onChanged});final bool value;final ValueChanged<bool> onChanged;@override Widget build(BuildContext context)=>GestureDetector(onTap:()=>onChanged(!value),child:AnimatedContainer(duration:const Duration(milliseconds:220),width:48,height:26,padding:const EdgeInsets.all(3),decoration:BoxDecoration(color:value?const Color(0xFF1FAF5A):const Color(0xFFF5F6F9),borderRadius:BorderRadius.circular(52)),child:AnimatedAlign(duration:const Duration(milliseconds:220),alignment:value?Alignment.centerRight:Alignment.centerLeft,child:Container(width:20,height:20,decoration:BoxDecoration(shape:BoxShape.circle,color:Colors.white,boxShadow:[BoxShadow(color:Colors.black.withValues(alpha: .12),blurRadius:3)])))));}
class _InfoField extends StatelessWidget {
  const _InfoField({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        height: 78,
        margin: const EdgeInsets.only(bottom: 19),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: _personalInfoLabel),
            const SizedBox(height: 8),
            Text(value, style: _t14),
          ],
        ),
      );
}
Widget _statusRow(String title,String status,bool good,VoidCallback? tap)=>InkWell(onTap:tap,child:Container(height:58,margin:const EdgeInsets.only(bottom:10),padding:const EdgeInsets.symmetric(horizontal:12),decoration:BoxDecoration(color:AppColors.offWhite,borderRadius:BorderRadius.circular(6)),child:Row(children:[Expanded(child:Text(title,style:_t14)),Text(status,style:TextStyle(fontFamily:'Sora',fontSize:11,color:good?const Color(0xFF1FAF5A):const Color(0xFF8D8D8D))),if(tap!=null) Padding(padding:const EdgeInsets.only(left:8),child:Image.asset('$_exactAssets/profile_chevron_exact.png',width:16,height:16,filterQuality:FilterQuality.high))])));
class _ChoiceTile extends StatelessWidget{const _ChoiceTile({required this.asset,required this.title,required this.subtitle,this.selected=false,required this.onTap});final String asset;final String title,subtitle;final bool selected;final VoidCallback onTap;@override Widget build(BuildContext context)=>InkWell(onTap:onTap,borderRadius:BorderRadius.circular(8),child:Container(height:70,padding:const EdgeInsets.symmetric(horizontal:14),decoration:BoxDecoration(border:Border.all(color:selected?AppColors.primary:const Color(0xFFEBEDF3)),borderRadius:BorderRadius.circular(8)),child:Row(children:[Image.asset(asset,width:24,height:24,fit:BoxFit.contain,filterQuality:FilterQuality.high),const SizedBox(width:14),Expanded(child:Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:_t14b),Text(subtitle,style:_t12)])),Image.asset('$_profileIcons/profile_chevron.png',width:16,height:16)])));}
Widget _idTile(String asset,String title,String sub,bool selected,VoidCallback tap)=>Padding(padding:const EdgeInsets.only(bottom:14),child:_ChoiceTile(asset:asset,title:title,subtitle:sub,selected:selected,onTap:tap));
class _Bullet extends StatelessWidget{const _Bullet(this.text);final String text;@override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.only(bottom:12),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[const Padding(padding:EdgeInsets.only(top:5),child:Icon(Icons.circle,size:6,color:AppColors.primary)),const SizedBox(width:10),Expanded(child:Text(text,style:_t12))]));}
List<Widget> _cornerFrames()=>[const Positioned(left:30,top:30,child:_Corner()),const Positioned(right:30,top:30,child:RotatedBox(quarterTurns:1,child:_Corner())),const Positioned(right:30,bottom:30,child:RotatedBox(quarterTurns:2,child:_Corner())),const Positioned(left:30,bottom:30,child:RotatedBox(quarterTurns:3,child:_Corner()))];
class _Corner extends StatelessWidget{const _Corner();@override Widget build(BuildContext context)=>Container(width:32,height:32,decoration:const BoxDecoration(border:Border(top:BorderSide(color:Colors.white,width:2),left:BorderSide(color:Colors.white,width:2))));}
class _AccountLimitTile extends StatelessWidget{const _AccountLimitTile({required this.flag,required this.title,required this.subtitle,required this.onTap});final String flag,title,subtitle;final VoidCallback onTap;@override Widget build(BuildContext context)=>InkWell(onTap:onTap,child:Container(height:70,padding:const EdgeInsets.symmetric(horizontal:14),decoration:BoxDecoration(color:AppColors.offWhite,borderRadius:BorderRadius.circular(6)),child:Row(children:[Text(flag,style:const TextStyle(fontSize:26)),const SizedBox(width:12),Expanded(child:Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:_t14b),Text(subtitle,style:_t12)])),Image.asset('$_exactAssets/profile_chevron_exact.png',width:16,height:16,filterQuality:FilterQuality.high)])));}
class _Pill extends StatelessWidget{const _Pill(this.t);final String t;@override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.symmetric(horizontal:9,vertical:4),decoration:BoxDecoration(color:const Color(0xFFE8EEFC),borderRadius:BorderRadius.circular(20)),child:Text(t,style:const TextStyle(fontFamily:'Sora',fontSize:10,color:AppColors.primary)));}
class _Segment extends StatelessWidget{const _Segment({required this.left,required this.right,required this.rightSelected,required this.onChanged});final String left,right;final bool rightSelected;final ValueChanged<bool> onChanged;@override Widget build(BuildContext context)=>Container(height:55,padding:const EdgeInsets.all(6),decoration:BoxDecoration(color:const Color(0xFFEEF0F5),borderRadius:BorderRadius.circular(8)),child:Row(children:[Expanded(child:_SegButton(left,!rightSelected,()=>onChanged(false))),Expanded(child:_SegButton(right,rightSelected,()=>onChanged(true)))]));}
class _SegButton extends StatelessWidget{const _SegButton(this.text,this.sel,this.tap);final String text;final bool sel;final VoidCallback tap;@override Widget build(BuildContext context)=>InkWell(onTap:tap,child:AnimatedContainer(duration:const Duration(milliseconds:200),alignment:Alignment.center,decoration:BoxDecoration(color:sel?Colors.white:Colors.transparent,borderRadius:BorderRadius.circular(7)),child:Text(text,style:TextStyle(fontFamily:'Sora',fontSize:12,fontWeight:sel?FontWeight.w600:FontWeight.w400,color:sel?AppColors.primary:AppColors.body))));}
Widget _limitBanner(String t)=>Container(height:51,padding:const EdgeInsets.symmetric(horizontal:16),alignment:Alignment.centerLeft,decoration:BoxDecoration(color:AppColors.offWhite,borderRadius:BorderRadius.circular(6)),child:Text(t,style:_t14));
class _ProgressLimit extends StatelessWidget{const _ProgressLimit(this.title,this.max);final String title,max;@override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:AppColors.offWhite,borderRadius:BorderRadius.circular(6)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:_t14),const SizedBox(height:14),LinearProgressIndicator(value:0,minHeight:7,borderRadius:BorderRadius.circular(8),backgroundColor:const Color(0xFFE5E8EE),valueColor:const AlwaysStoppedAnimation(AppColors.primary)),const SizedBox(height:10),Row(children:[const Text('0.00 Spent',style:_t12),const Spacer(),Text('$max Spent',style:_t12)])]));}
class _ActionCard extends StatelessWidget{const _ActionCard(this.asset,this.title,this.sub,this.tap);final String asset,title,sub;final VoidCallback tap;@override Widget build(BuildContext context)=>InkWell(onTap:tap,child:Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:AppColors.offWhite,borderRadius:BorderRadius.circular(8)),child:Row(children:[Container(width:42,height:42,alignment:Alignment.center,decoration:BoxDecoration(color:const Color(0xFFEAF2FF),borderRadius:BorderRadius.circular(8)),child:Image.asset(asset,width:22,height:22,filterQuality:FilterQuality.high)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:_t14b),Text(sub,style:_t12)])),Image.asset('$_exactAssets/profile_chevron_exact.png',width:16,height:16,filterQuality:FilterQuality.high)])));}
Widget _docOption(String a,String b)=>Container(width:double.infinity,margin:const EdgeInsets.only(bottom:12),padding:const EdgeInsets.all(14),decoration:BoxDecoration(border:Border.all(color:const Color(0xFFEBEDF3)),borderRadius:BorderRadius.circular(8)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(a,style:_t14b),const SizedBox(height:4),Text(b,style:_t12)]));
class _Input extends StatelessWidget {
  const _Input({
    required this.label,
    required this.hint,
    required this.controller,
    this.obscure = false,
    this.keyboard,
    this.figmaFilled = false,
    this.labelSize = 14,
    this.hintSize = 14,
    this.hintFontFamily = 'Sora',
    this.maxLength,
    this.inputFormatters,
  });

  final String label, hint;
  final TextEditingController controller;
  final bool obscure, figmaFilled;
  final TextInputType? keyboard;
  final double labelSize, hintSize;
  final String hintFontFamily;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: labelSize,
              height: 1.35,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF424242),
            ),
          ),
          const SizedBox(height: 4),
        ],
        SizedBox(
          height: 48,
          child: TextField(
            controller: controller,
            obscureText: obscure,
            keyboardType: keyboard,
            maxLength: maxLength,
            inputFormatters: inputFormatters,
            style: TextStyle(
              fontFamily: hintFontFamily,
              fontSize: hintSize,
              color: const Color(0xFF4E4F51),
            ),
            decoration: InputDecoration(
              isDense: true,
              filled: figmaFilled,
              fillColor: figmaFilled ? const Color(0xFFF8F9FB) : Colors.white,
              hintText: hint,
              counterText: maxLength == null ? null : '',
              hintStyle: TextStyle(
                fontFamily: hintFontFamily,
                fontSize: hintSize,
                color: const Color(0xFF686868),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              suffixIcon: obscure
                  ? Padding(
                      padding: const EdgeInsets.all(14),
                      child: Image.asset(
                        '$_exactAssets/input_eye_exact.png',
                        width: 20,
                        height: 20,
                        filterQuality: FilterQuality.high,
                      ),
                    )
                  : null,
              suffixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD9DDE5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFD9DDE5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
class _PrimaryButton extends StatelessWidget{const _PrimaryButton(this.label,{required this.onTap,this.enabled=true,this.disabledBackgroundColor=const Color(0xFFD0DEFD)});final String label;final VoidCallback onTap;final bool enabled;final Color disabledBackgroundColor;@override Widget build(BuildContext context)=>SizedBox(width:double.infinity,height:48,child:ElevatedButton(onPressed:enabled?(){HapticFeedback.lightImpact();onTap();}:null,style:ElevatedButton.styleFrom(backgroundColor:AppColors.primary,disabledBackgroundColor:disabledBackgroundColor,foregroundColor:Colors.white,disabledForegroundColor:Colors.white,elevation:0,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(4))),child:Text(label,style:const TextStyle(fontFamily:'Sora',fontSize:14,fontWeight:FontWeight.w600))));}
class _SecondaryButton extends StatelessWidget{const _SecondaryButton(this.label,{required this.onTap});final String label;final VoidCallback onTap;@override Widget build(BuildContext context)=>SizedBox(width:double.infinity,height:48,child:TextButton(onPressed:onTap,style:TextButton.styleFrom(backgroundColor:const Color(0xFFEFF4FE),foregroundColor:AppColors.primary,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(4))),child:Text(label,style:const TextStyle(fontFamily:'Sora',fontSize:14,fontWeight:FontWeight.w600))));}
class _NotifAssetItem extends StatelessWidget {
  const _NotifAssetItem(this.asset, this.title, this.sub, this.time, this.color);
  final String asset, title, sub, time;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 57,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: _t14b),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 240,
                    child: Text(
                      sub,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 12,
                        height: 1.25,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF424242),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              time,
              style: const TextStyle(
                fontFamily: 'Sora',
                fontSize: 10,
                height: 1.3,
                color: Color(0xFF434656),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      );
}
Widget _toggleRow(String t, String s, bool v, ValueChanged<bool> on) {
  return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 17),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t, style: _t14b),
                    const SizedBox(height: 8),
                    Text(s, style: _t12),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Semantics(label: t, toggled: v, child: _DavoSwitch(value: v, onChanged: on)),
              ),
            ],
          ),
  );
}
Widget _radioChoice(String t, bool sel, VoidCallback tap) => InkWell(
      onTap: tap,
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          border: Border.all(color: sel ? AppColors.primary : const Color(0xFFEBEDF3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Image.asset(
              sel ? '$_exactAssets/radio_selected_exact.png' : '$_exactAssets/radio_unselected_exact.png',
              width: 16,
              height: 16,
              filterQuality: FilterQuality.high,
            ),
            const SizedBox(width: 12),
            Text(t, style: _t14),
          ],
        ),
      ),
    );
class _AgentHeader extends StatelessWidget {
  const _AgentHeader({this.small = false});
  final bool small;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/brand/davochain_logo.png',
            width: small ? 23 : 47,
            height: small ? 15 : 30,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Callie', style: small ? _t12b : _t14b),
              if (!small) const Text('The team can also help', style: TextStyle(fontFamily:'Sora',fontSize:10,fontWeight:FontWeight.w400,color:Color(0xFF686868))),
              if (small) const Text('Ai Agent', style: _t12),
            ],
          ),
        ],
      );
}
class _ChatBubble extends StatelessWidget{const _ChatBubble({required this.text});final String text;@override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:AppColors.offWhite,borderRadius:BorderRadius.circular(12)),child:Text(text,style:_t12));}
Widget _referralBox()=>Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:AppColors.offWhite,borderRadius:BorderRadius.circular(8)),child:Column(children:[Row(children:[const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('manish1',style:_t14b),Text('Your referral code',style:_t12)])),Builder(builder:(context)=>IconButton(tooltip:'Copy referral code',onPressed:() async {await Clipboard.setData(const ClipboardData(text:'manish1'));if(context.mounted) showDavoToast(context,'Referral code copied');},icon:const Icon(Icons.copy_outlined,size:18,color:AppColors.primary)))]),const Divider(height:24),Row(children:[const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('https://davochain.com/...',style:TextStyle(fontFamily:'Sora',fontSize:12,color:AppColors.primary)),Text('Your referral link',style:_t12)])),OutlinedButton(onPressed:(){},child:const Text('Share'))]) ]));
Widget _sectionLink(String a,String b,VoidCallback tap)=>Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:AppColors.offWhite,borderRadius:BorderRadius.circular(8)),child:Row(children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(a,style:_t12),Text(b,style:_t14b)])),IconButton(onPressed:tap,icon:Image.asset('$_exactAssets/profile_chevron_exact.png',width:16,height:16,filterQuality:FilterQuality.high))]));
class _HowItWorks extends StatelessWidget{const _HowItWorks();@override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:AppColors.offWhite,borderRadius:BorderRadius.circular(8)),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('How it works',style:_t16b),SizedBox(height:14),_Step('1','Send Invite','Share your unique link or code with your friends via social media or direct message.'),_Step('2','Friend Joins','Your friend signs up and completes a successful transaction of NGN50,000'),_Step('3','Get Paid','You and your friend get credited with Đ2,000 Davo Points.') ]));}
class _Step extends StatelessWidget{const _Step(this.n,this.t,this.s);final String n,t,s;@override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.only(bottom:16),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[CircleAvatar(radius:12,backgroundColor:Colors.white,child:Text(n,style:const TextStyle(fontFamily:'Sora',fontSize:10,color:AppColors.primary))),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(t,style:_t14b),Text(s,style:_t12)]))]));}
class _StatsGrid extends StatelessWidget{const _StatsGrid(this.items);final List<(String,String)> items;@override Widget build(BuildContext context)=>GridView.count(crossAxisCount:2,shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),mainAxisSpacing:10,crossAxisSpacing:10,childAspectRatio:1.8,children:items.map((e)=>Container(padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:AppColors.offWhite,borderRadius:BorderRadius.circular(8)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(e.$1,style:_t12),const Spacer(),Text(e.$2,style:const TextStyle(fontFamily:'Sora',fontSize:17,fontWeight:FontWeight.w700,color:AppColors.primary))]))).toList());}
class _PersonRow extends StatelessWidget{const _PersonRow(this.name,this.date,this.status);final String name,date,status;@override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.symmetric(vertical:11),decoration:const BoxDecoration(border:Border(bottom:BorderSide(color:Color(0xFFF2F3F7)))),child:Row(children:[CircleAvatar(radius:18,backgroundColor:const Color(0xFFEAF2FF),child:Text(name.split(' ').map((e)=>e[0]).take(2).join(),style:const TextStyle(fontFamily:'Sora',fontSize:10,color:AppColors.primary))),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(name,style:_t14b),Text(date,style:_t12)])),_Pill(status)]));}
class _ActivityRow extends StatelessWidget{const _ActivityRow(this.t,this.v);final String t,v;@override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.symmetric(vertical:12),decoration:const BoxDecoration(border:Border(bottom:BorderSide(color:Color(0xFFF2F3F7)))),child:Row(children:[CircleAvatar(radius:18,backgroundColor:const Color(0xFFEAF2FF),child:Padding(padding:const EdgeInsets.all(9),child:Image.asset('$_exactAssets/icon_gift.png'))),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(t,style:_t14b),const Text('Oct 24, 2023 • 14:32',style:_t12)])),Row(mainAxisSize:MainAxisSize.min,children:[Image.asset('assets/images/brand/naira_coin.png',width:16,height:16),const SizedBox(width:4),Text(v.replaceAll('\u0110',''),style:const TextStyle(fontFamily:'Sora',fontSize:12,color:Color(0xFF1FAF5A),fontWeight:FontWeight.w600))])]));}

class _QuickAssetAction extends StatelessWidget{const _QuickAssetAction(this.asset,this.t,this.tap);final String asset,t;final VoidCallback tap;@override Widget build(BuildContext context)=>InkWell(onTap:tap,child:Column(children:[CircleAvatar(radius:20,backgroundColor:const Color(0xFFEAF2FF),child:Padding(padding:const EdgeInsets.all(10),child:Image.asset(asset,fit:BoxFit.contain,filterQuality:FilterQuality.high))),const SizedBox(height:6),Text(t,textAlign:TextAlign.center,style:const TextStyle(fontFamily:'Sora',fontSize:9,color:AppColors.body))]));}
class _Podium extends StatelessWidget {
  const _Podium(this.rank, this.name, this.refs, this.h);
  final String rank, name, refs;
  final double h;

  String get portrait => rank == '1'
      ? '$_exactAssets/leaderboard_podium_center_exact.png'
      : rank == '2'
          ? '$_exactAssets/leaderboard_podium_left_exact.png'
          : '$_exactAssets/leaderboard_podium_right_exact.png';

  @override
  Widget build(BuildContext context) {
    final first = rank == '1';
    final outer = first ? 110.0 : 80.0;
    final inner = first ? 96.0 : 72.0;
    final width = first ? 114.0 : 96.0;
    return SizedBox(
      width: width,
      child: Column(
        children: [
          Container(
            width: outer,
            height: outer,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: ClipOval(
              child: Image.asset(
                portrait,
                width: inner,
                height: inner,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
          SizedBox(height: first ? 18 : 17),
          Text(
            name,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: first ? 20 : 16,
              height: 1.35,
              fontWeight: first ? FontWeight.w700 : FontWeight.w600,
              color: const Color(0xFF1A1C20),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            refs,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: first ? 16 : 14,
              height: 1.35,
              fontWeight: first ? FontWeight.w700 : FontWeight.w400,
              color: first ? AppColors.primary : const Color(0xFF434656),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: width,
            height: h,
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: first ? AppColors.primary : const Color(0xFFF5F6F9),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            ),
            child: Text(
              rank,
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: first ? Colors.white : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _RankRow extends StatelessWidget {
  const _RankRow(this.rank, this.name, this.school, this.refs);
  final int rank;
  final String name, school, refs;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        height: 88,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 49,
              child: Text(
                rank.toString().padLeft(2, '0'),
                style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 16,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFC4C5CA),
                ),
              ),
            ),
            const ClipOval(
              child: Image(
                image: AssetImage(_rankPortrait),
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 16,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    school,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _t12,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 56,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(refs, style: _t16b.copyWith(color: const Color(0xFF424242))),
                  const Text('Referrals', style: _t12),
                ],
              ),
            ),
          ],
        ),
      );
}
class _HelpCategory extends StatelessWidget{const _HelpCategory(this.t,this.s,this.c);final String t,s,c;@override Widget build(BuildContext context)=>ExpansionTile(tilePadding:EdgeInsets.zero,childrenPadding:const EdgeInsets.only(bottom:12),title:Text(t,style:_t14b),subtitle:Text(s,maxLines:2,overflow:TextOverflow.ellipsis,style:_t12),trailing:Column(mainAxisAlignment:MainAxisAlignment.center,children:[Image.asset('$_exactAssets/profile_chevron_exact.png',width:16,height:16,filterQuality:FilterQuality.high),Text(c,style:const TextStyle(fontFamily:'Sora',fontSize:9,color:AppColors.primary))]),children:[Align(alignment:Alignment.centerLeft,child:Text(s,style:_t12))]);}

const _helpCats=<(String,String,String)>[
('Getting Started','Everything you need to create your Davochain account, verify your identity, and start using the app.','10 Articles'),('Wallets & Balances','Learn how your NGN Wallet, USD Wallet, and other balances work, including funding and withdrawals.','12 Articles'),('Crypto Trading','Everything about buying, selling, depositing, withdrawing, and managing cryptocurrency on Davochain.','15 Articles'),('Gift Card Trading','Learn how to sell gift cards, supported brands, trade processing times, and payment settlements.','14 Articles'),('Virtual Cards','Everything you need to know about creating, funding, freezing, and using your Davochain Virtual Card.','13 Articles'),('USD Accounts','Learn how to create your USD account, receive international payments, and manage your USD balance.','11 Articles'),('Send Money','Learn how to transfer money to Nigerian bank accounts, other Davochain users, and supported destinations.','9 Articles'),('Receive Money','Everything about receiving payments into your NGN wallet, USD account, and crypto wallets.','8 Articles'),('Bill Payments','Learn how to pay for airtime, data, electricity, cable TV, betting, and other utility bills.','9 Articles'),('Rewards & Referrals','Everything about inviting friends, earning referral rewards, campaign bonuses, and reward withdrawals.','7 Articles'),('Fees & Transaction Limits','Understand transaction fees, withdrawal fees, trading fees, spending limits, and account limits.','8 Articles'),('Verification (KYC)','Everything about identity verification, accepted documents, verification levels, and account limits.','10 Articles'),('Security & Account Protection','Learn how to secure your account, reset your password, manage your PIN, enable biometrics, and report suspicious activity.','12 Articles'),('Transactions & Receipts','Understand transaction statuses, download receipts, track transfers, and resolve failed transactions.','9 Articles'),('Promotions & Campaigns','Stay informed about cashback offers, referral campaigns, seasonal promotions, and eligibility requirements.','6 Articles'),('Troubleshooting','Solutions for common issues such as login problems, OTP delays, failed payments, app performance, and wallet errors.','15 Articles'),('Contact Support','Find out how to reach the Davochain support team through live chat, email, or by submitting a support ticket.','5 Articles'),('Legal & Compliance',"Read Davochain's Terms of Service, Privacy Policy, AML policy, prohibited transactions, and regulatory compliance information.",'8 Articles')];
const _people=<(String,String,String)>[('Jane Doe','Oct 24, 2023 • 14:32','Rewarded'),('Marcus Kane','Oct 24, 2023 • 14:32','Pending'),('Sarah Lim','Oct 24, 2023 • 14:32','Pending'),('Elena Rodriguez','Oct 24, 2023 • 14:32','Rewarded'),('Julian Smith','Oct 24, 2023 • 14:32','Pending'),('Lila Vance','Oct 24, 2023 • 14:32','Pending'),('Marcus Thorne','Oct 24, 2023 • 14:32','Rewarded')];
const _rankings=<(String,String,String)>[('Jordan Smith','University of Nigeria Nsukka','32'),('Elena Rodriguez','Obafemi Awolowo University','30'),('Confidence Malik','University of Abuja','28'),('Samuel Meshack','Enugu State University','25'),('ELite Divine','Oko Poly','22'),('Chidera Favour','Akanu Ibiam Federal Poly','20'),('Success Chidinma','Akanu Ibiam Federal Poly','18')];

Future<void> _push(BuildContext c,Widget w)=>pushAppPage<void>(c,(_)=>w);
void _snack(BuildContext c,String s)=>showDavoToast(c,s);
void _simple(BuildContext c,String title)=>_push(c,_Shell(title:title,child:Center(child:Text('$title\nDavochain',textAlign:TextAlign.center,style:_t16b))));
Future<void> _uploadSheet(BuildContext context,String title)=>showModalBottomSheet(context:context,showDragHandle:true,builder:(c)=>SafeArea(child:Padding(padding:const EdgeInsets.fromLTRB(16,0,16,20),child:Column(mainAxisSize:MainAxisSize.min,children:[Align(alignment:Alignment.centerLeft,child:Text(title,style:_t16b)),const SizedBox(height:18),_PrimaryButton('Take a Photo',onTap:()=>Navigator.pop(c)),const SizedBox(height:10),OutlinedButton(onPressed:()=>Navigator.pop(c),style:OutlinedButton.styleFrom(minimumSize:const Size.fromHeight(48),side:const BorderSide(color:AppColors.primary)),child:const Text('Choose From Gallery')),const SizedBox(height:10),TextButton(onPressed:()=>Navigator.pop(c),child:const Text('Choose a file'))]))));
Future<void> _socialDialog(BuildContext c,String s)=>showDialog(context:c,barrierColor:Colors.black.withValues(alpha: .35),builder:(d)=>Dialog(backgroundColor:Colors.white,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(16)),insetPadding:const EdgeInsets.symmetric(horizontal:77),child:SizedBox(width:236,height:123,child:Padding(padding:const EdgeInsets.all(16),child:Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.start,children:[Text('“Davochain” Wants to open “$s”',style:_t14),const SizedBox(height:19),Row(children:[Expanded(child:SizedBox(height:36,child:TextButton(onPressed:()=>Navigator.pop(d),style:TextButton.styleFrom(backgroundColor:const Color(0xFFF2F3F7),shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(4))),child:const Text('Cancel',style:TextStyle(fontFamily:'Sora',fontSize:14,color:AppColors.ink))))),const SizedBox(width:12),Expanded(child:SizedBox(height:36,child:TextButton(onPressed:()=>Navigator.pop(d),style:TextButton.styleFrom(backgroundColor:AppColors.primary,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(4))),child:const Text('Open',style:TextStyle(fontFamily:'Sora',fontSize:14,color:Colors.white)))))])])))));
Future<void> _logoutDialog(BuildContext c)=>showDialog(context:c,builder:(d)=>AlertDialog(title:const Text('Logout'),content:const Text('Are you sure you want to logout?'),actions:[TextButton(onPressed:()=>Navigator.pop(d),child:const Text('Cancel')),TextButton(onPressed:(){VerificationSession.instance.reset();PreviewAuthState.unlocked.value=false;Navigator.of(d).pushAndRemoveUntil(AppPageRoute<void>(builder:(_)=>const LoginScreen()),(_)=>false);},child:const Text('Logout',style:TextStyle(color:Color(0xFFF44336))))]));
Future<void> _deleteAccountDialog(BuildContext c)=>showDialog(context:c,builder:(d)=>AlertDialog(title:const Text('Delete Account'),content:const Text('Are you sure you want to delete your account?'),actions:[TextButton(onPressed:()=>Navigator.pop(d),child:const Text('Cancel')),TextButton(onPressed:()=>Navigator.pop(d),child:const Text('Delete Account',style:TextStyle(color:Color(0xFFF44336))))]));

const _navSora20 = TextStyle(fontFamily:'Sora',fontSize:20,fontWeight:FontWeight.w400,color:Color(0xFF424242),height:1.35);
const _navInter20 = TextStyle(fontFamily:'Sora',fontSize:20,fontWeight:FontWeight.w500,color:AppColors.ink,height:1.35);
const _navSora16 = TextStyle(fontFamily:'Sora',fontSize:16,fontWeight:FontWeight.w400,color:AppColors.ink,height:1.35);
const _navSora16Medium = TextStyle(fontFamily:'Sora',fontSize:16,fontWeight:FontWeight.w500,color:AppColors.ink,height:1.35);
const _navSora16SemiBold = TextStyle(fontFamily:'Sora',fontSize:16,fontWeight:FontWeight.w600,color:AppColors.ink,height:1.35);
const _navSora16Bold = TextStyle(fontFamily:'Sora',fontSize:16,fontWeight:FontWeight.w700,color:AppColors.ink,height:1.35);
const _navSora14SemiBold = TextStyle(fontFamily:'Sora',fontSize:14,fontWeight:FontWeight.w600,color:AppColors.ink,height:1.35);
const _t16ProfileSub = TextStyle(fontFamily:'Sora',fontSize:16,fontWeight:FontWeight.w400,color:Color(0xFF686868),height:1.35);
const _personalInfoLabel = TextStyle(fontFamily:'Sora',fontSize:14,fontWeight:FontWeight.w400,color:Color(0xFF505057),height:1.35);
const _sectionLabel14 = TextStyle(fontFamily:'Sora',fontSize:14,fontWeight:FontWeight.w600,color:Color(0xFF686868),height:1.35);
const _t20=TextStyle(fontFamily:'Sora',fontSize:20,fontWeight:FontWeight.w400,color:AppColors.ink,height:1.35);
const _t20sb=TextStyle(fontFamily:'Sora',fontSize:20,fontWeight:FontWeight.w600,color:AppColors.ink,height:1.35);
const _t16=TextStyle(fontFamily:'Sora',fontSize:16,fontWeight:FontWeight.w400,color:AppColors.ink,height:1.35);
const _t16m=TextStyle(fontFamily:'Sora',fontSize:16,fontWeight:FontWeight.w500,color:AppColors.ink,height:1.35);
const _t16b=TextStyle(fontFamily:'Sora',fontSize:16,fontWeight:FontWeight.w600,color:AppColors.ink,height:1.35);
const _t14=TextStyle(fontFamily:'Sora',fontSize:14,fontWeight:FontWeight.w400,color:AppColors.body,height:1.35);
const _t14m=TextStyle(fontFamily:'Sora',fontSize:14,fontWeight:FontWeight.w500,color:AppColors.body,height:1.35);
const _t14b=TextStyle(fontFamily:'Sora',fontSize:14,fontWeight:FontWeight.w600,color:AppColors.ink,height:1.35);
const _t12=TextStyle(fontFamily:'Sora',fontSize:12,fontWeight:FontWeight.w400,color:Color(0xFF686868),height:1.35);
const _t12b=TextStyle(fontFamily:'Sora',fontSize:12,fontWeight:FontWeight.w600,color:AppColors.ink,height:1.35);

const _nigerianStates = ['Abia','Adamawa','Akwa Ibom','Anambra','Bauchi','Bayelsa','Benue','Borno','Cross River','Delta','Ebonyi','Edo','Ekiti','Enugu','FCT','Gombe','Imo','Jigawa','Kaduna','Kano','Katsina','Kebbi','Kogi','Kwara','Lagos','Nasarawa','Niger','Ogun','Ondo','Osun','Oyo','Plateau','Rivers','Sokoto','Taraba','Yobe','Zamfara'];
