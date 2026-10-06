import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/theme/app_theme.dart';

const _avatar = 'assets/images/figma/profile.png';

Future<void> startProfileSettingsFlow(BuildContext context) => pushAppPage<void>(context, (_) => const ProfileSettingsScreen());
Future<void> openNotificationCenter(BuildContext context) => pushAppPage<void>(context, (_) => const NotificationCenterScreen());

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});
  @override State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  bool biometrics = true;
  @override Widget build(BuildContext context) {
    return _Shell(title: 'Profile', scroll: true, child: Column(children: [
      const SizedBox(height: 34),
      Stack(alignment: Alignment.bottomRight, children: [
        Container(width:120,height:120,decoration:BoxDecoration(shape:BoxShape.circle,boxShadow:[BoxShadow(color:Colors.black.withValues(alpha: .12),blurRadius:24,offset:const Offset(0,10))]),child:ClipOval(child:Image.asset(_avatar,fit:BoxFit.cover))),
        Container(width:24,height:24,decoration:const BoxDecoration(shape:BoxShape.circle,color:AppColors.primary,border:Border.fromBorderSide(BorderSide(color:Colors.white))),child:const Icon(Icons.check_rounded,color:Colors.white,size:15)),
      ]),
      const SizedBox(height:24),
      const Text('Vincent Chukwu',style:_t16b),
      const SizedBox(height:4),
      const Text('chukwuvncnt1@gmail.com',style:_t14m),
      const SizedBox(height:42),
      _MenuCard(title:'Profile',items:[
        _MenuItem(Icons.manage_accounts_outlined,'Account information',()=>_push(context,const AccountInformationScreen())),
        _MenuItem(Icons.badge_outlined,'KYC Verification',()=>_push(context,const KycOverviewScreen())),
        _MenuItem(Icons.swap_horiz_rounded,'Transaction limits',()=>_push(context,const TransactionLimitsScreen())),
      ]),
      const SizedBox(height:24),
      _MenuCard(title:'Security',items:[
        _MenuItem(Icons.center_focus_strong_outlined,'Enable Biometrics',(){setState(()=>biometrics=!biometrics);},trailing:_DavoSwitch(value:biometrics,onChanged:(v)=>setState(()=>biometrics=v))),
        _MenuItem(Icons.lock_outline_rounded,'Change Password',()=>_push(context,const ChangePasswordScreen())),
        _MenuItem(Icons.lock_outline_rounded,'Transaction Pin',()=>_push(context,const ResetPinStartScreen())),
      ]),
      const SizedBox(height:24),
      _MenuCard(title:'Preferences',items:[
        _MenuItem(Icons.notifications_none_rounded,'Notifications',()=>openNotificationCenter(context)),
        _MenuItem(Icons.groups_outlined,'Reward center',()=>_push(context,const ReferralDashboardScreen())),
        _MenuItem(Icons.school_outlined,'Student Ambassador',()=>_push(context,const StudentAmbassadorScreen())),
        _MenuItem(Icons.tune_rounded,'Notification Settings',()=>_push(context,const NotificationSettingsScreen())),
        _MenuItem(Icons.dark_mode_outlined,'Theme',()=>_themeSheet(context)),
      ]),
      const SizedBox(height:24),
      const Align(alignment:Alignment.centerLeft,child:Text('GENERAL',style:TextStyle(fontFamily:'Sora',fontSize:12,color:Color(0xFF686868),fontWeight:FontWeight.w600))),
      const SizedBox(height:12),
      _MenuCard(items:[
        _MenuItem(Icons.support_agent_rounded,'Customer Support',()=>_push(context,const CustomerSupportScreen())),
        _MenuItem(Icons.privacy_tip_outlined,'Privacy Policy',()=>_simple(context,'Privacy Policy')),
        _MenuItem(Icons.help_outline_rounded,'FAQs',()=>_push(context,const HelpCenterScreen())),
        _MenuItem(Icons.description_outlined,'Terms and Condition',()=>_simple(context,'Terms and Condition')),
        _MenuItem(Icons.info_outline_rounded,'About Us',()=>_simple(context,'About Us')),
      ]),
      const SizedBox(height:20),
      InkWell(onTap:()=>_logoutDialog(context),borderRadius:BorderRadius.circular(6),child:Container(height:54,padding:const EdgeInsets.symmetric(horizontal:14),decoration:BoxDecoration(color:const Color(0xFFFFF5F5),borderRadius:BorderRadius.circular(6)),child:const Row(children:[Icon(Icons.logout_rounded,color:Color(0xFFF44336),size:20),SizedBox(width:14),Text('Logout',style:TextStyle(fontFamily:'Sora',fontSize:14,color:Color(0xFFF44336)))]))),
      const SizedBox(height:34),
    ]));
  }
}

class AccountInformationScreen extends StatelessWidget {
  const AccountInformationScreen({super.key});
  @override Widget build(BuildContext context) => _Shell(title:'Profile',scroll:true,child:Column(children:[
    const SizedBox(height:26),
    Stack(alignment:Alignment.bottomRight,children:[Container(width:104,height:104,decoration:const BoxDecoration(shape:BoxShape.circle),child:ClipOval(child:Image.asset(_avatar,fit:BoxFit.cover))),Container(width:22,height:22,decoration:const BoxDecoration(shape:BoxShape.circle,color:AppColors.primary),child:const Icon(Icons.edit_rounded,size:12,color:Colors.white))]),
    const SizedBox(height:28),
    ...const [
      ('Full name','Vincent Chukwu'),('Email','vincent.dollars@gmail.com'),('Phone Number','+234 9062185004'),('Country','Nigeria'),('Username','Admiral'),('Date of Birth','1996-08-24'),('Residential Address','Flat A2, Guzape Estate, Abuja'),
    ].map((e)=>_InfoField(label:e.$1,value:e.$2)),
    const SizedBox(height:20),
    TextButton.icon(onPressed:()=>_simple(context,'Delete Account'),icon:const Icon(Icons.delete_outline,color:Color(0xFFF44336),size:18),label:const Text('Delete Account',style:TextStyle(color:Color(0xFFF44336),fontFamily:'Sora'))),
    const SizedBox(height:32),
  ]));
}

class KycOverviewScreen extends StatelessWidget {
  const KycOverviewScreen({super.key});
  @override Widget build(BuildContext context)=>_Shell(title:'KYC Verification',child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    const SizedBox(height:24),
    const Text('Identity Verification',style:_t20),const SizedBox(height:6),
    const Text('To continue, click on any incomplete stage and complete the remaining steps.',style:_t12),const SizedBox(height:28),
    _StatusRow('Identity verification','Not verified',false,()=>_push(context,const KycMethodScreen())),
    _StatusRow('Address verification','Not verified',false,()=>_push(context,const AddressUpgradeScreen())),
    const _StatusRow('Phone Verification','Verified',true,null),
    const _StatusRow('Email verification','Verified',true,null),
    const _StatusRow('Profile information','Completed',true,null),
  ]));
}

class KycMethodScreen extends StatelessWidget {
  const KycMethodScreen({super.key});
  @override Widget build(BuildContext context)=>_Shell(title:'KYC Verification',child:Column(children:[
    const SizedBox(height:30),
    _ChoiceTile(icon:Icons.badge_outlined,title:'Identity',subtitle:'Government Issued ID',selected:true,onTap:()=>_push(context,const GovernmentIdScreen())),
    const SizedBox(height:14),
    _ChoiceTile(icon:Icons.face_retouching_natural,title:'Selfie',subtitle:'Live Check',onTap:()=>_push(context,const SelfieScreen())),
    const Spacer(),_PrimaryButton('Submit',onTap:()=>Navigator.pop(context)),const SizedBox(height:30)
  ]));
}

class GovernmentIdScreen extends StatefulWidget { const GovernmentIdScreen({super.key}); @override State<GovernmentIdScreen> createState()=>_GovernmentIdScreenState(); }
class _GovernmentIdScreenState extends State<GovernmentIdScreen>{ int selected=0; @override Widget build(BuildContext context)=>_Shell(title:'KYC Verification',child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
  const SizedBox(height:24),const Text('Upload a valid government ID to ensure the safety and security of the Errandy community.',style:_t14),const SizedBox(height:28),
  _IdTile(Icons.credit_card,'National ID','Tap to upload front & back',selected==0,(){setState(()=>selected=0);_uploadSheet(context,'Upload ID');}),
  _IdTile(Icons.menu_book_outlined,'Passport','Scan biometric page',selected==1,(){setState(()=>selected=1);_uploadSheet(context,'Upload ID');}),
  _IdTile(Icons.badge_outlined,"Driver's License",'Scan current license',selected==2,(){setState(()=>selected=2);_uploadSheet(context,'Upload ID');}),
])); }

class SelfieScreen extends StatelessWidget { const SelfieScreen({super.key}); @override Widget build(BuildContext context)=>_Shell(title:'KYC Verification',child:Column(children:[
  const SizedBox(height:28),const Text('Take a selfie',style:_t20),const SizedBox(height:6),const Text('Make sure your face is well-lit and fits inside\nthe circle for verification.',textAlign:TextAlign.center,style:_t12),const SizedBox(height:24),
  Container(width:171,height:171,padding:const EdgeInsets.all(8),decoration:BoxDecoration(border:Border.all(color:const Color(0xFFEBEDF3)),borderRadius:BorderRadius.circular(8)),child:ClipRRect(borderRadius:BorderRadius.circular(6),child:Image.asset(_avatar,fit:BoxFit.cover))),
  const SizedBox(height:24),
  const _Bullet('To ensure the security of your account and comply with regulatory requirements, we need to verify your identity.'),
  const _Bullet('Please upload a photo of your ID and take a photo of your face to complete this process.'),
  const Spacer(),_PrimaryButton('Start live face detection',onTap:()=>_push(context,const FaceDetectionScreen())),TextButton(onPressed:()=>Navigator.pop(context),child:const Text('Later')),const SizedBox(height:20)
])); }

class FaceDetectionScreen extends StatefulWidget { const FaceDetectionScreen({super.key}); @override State<FaceDetectionScreen> createState()=>_FaceDetectionScreenState(); }
class _FaceDetectionScreenState extends State<FaceDetectionScreen> with SingleTickerProviderStateMixin { late final AnimationController c; @override void initState(){super.initState();c=AnimationController(vsync:this,duration:const Duration(seconds:2))..repeat(reverse:true);} @override void dispose(){c.dispose();super.dispose();} @override Widget build(BuildContext context)=>_Shell(title:'KYC Verification',child:Column(children:[
 const SizedBox(height:28),const Text('Live face detection',style:_t20),const SizedBox(height:5),const Text('Scan your face to verify your identity',style:_t12),const SizedBox(height:28),
 Container(width:250,height:270,color:Colors.black,child:Stack(children:[const Positioned.fill(child:Icon(Icons.face_rounded,color:Color(0xFF1F1F1F),size:160)),..._cornerFrames(),AnimatedBuilder(animation:c,builder:(_,__)=>Positioned(left:30,right:30,top:35+c.value*180,child:Container(height:2,color:const Color(0xFF135CF7))))])),
 const SizedBox(height:18),const Text('Place your head within the frame',style:_t12),
])); }

class TransactionLimitsScreen extends StatelessWidget { const TransactionLimitsScreen({super.key}); @override Widget build(BuildContext context)=>_Shell(title:'Transaction Limits',child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
 const SizedBox(height:24),const Text('Choose an account to view transaction limits',style:_t16b),const SizedBox(height:4),const Text('Limits may vary based on account type and verification level',style:_t12),const SizedBox(height:24),
 _AccountLimitTile(flag:'🇺🇸',title:'US Currency',subtitle:'USD Account Limits',onTap:()=>_push(context,const LimitDetailScreen(kind:LimitKind.usd))),
 const SizedBox(height:12),_AccountLimitTile(flag:'🇳🇬',title:'Nigeria Currency (NG)',subtitle:'NGN Account Limits',onTap:()=>_push(context,const LimitDetailScreen(kind:LimitKind.ngn))),
 const SizedBox(height:12),_AccountLimitTile(flag:'₿',title:'Crypto Currency',subtitle:'Manage Crypto currency Limits',onTap:()=>_push(context,const LimitDetailScreen(kind:LimitKind.crypto))),
])); }

enum LimitKind{usd,ngn,crypto}
class LimitDetailScreen extends StatefulWidget{ const LimitDetailScreen({super.key,required this.kind}); final LimitKind kind; @override State<LimitDetailScreen> createState()=>_LimitDetailScreenState(); }
class _LimitDetailScreenState extends State<LimitDetailScreen>{bool second=false; @override Widget build(BuildContext context){final isUsd=widget.kind==LimitKind.usd,isNgn=widget.kind==LimitKind.ngn; final title=isUsd?'USD Limits':isNgn?'NGN Limits':'Crypto Currency'; final single=isUsd?r'$2,500.00':isNgn?'₦1,000,000.00':r'$1,000,000.00'; final daily=isUsd?r'$2,500.00':isNgn?'₦3,000,000.00':r'$3,000,000.00'; final weekly=isUsd?r'$10,500.00':isNgn?'₦5,000,000.00':r'$5,000,000.00'; final monthly=isUsd?r'$50,000.00':isNgn?'₦40,000,000.00':r'$40,000,000.00'; return _Shell(title:'Transaction Limits',child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
 const SizedBox(height:22),Row(children:[Text(widget.kind==LimitKind.ngn?'🇳🇬':widget.kind==LimitKind.usd?'🇺🇸':'₿',style:const TextStyle(fontSize:28)),const SizedBox(width:10),Text(title,style:_t16b),const SizedBox(width:10),const _Pill('Tier 1')]),const SizedBox(height:20),
 _Segment(left:widget.kind==LimitKind.crypto?'Limits on Withdrawal':'Limits on Send',right:widget.kind==LimitKind.crypto?'Limits on Deposit':'Limits on receive',rightSelected:second,onChanged:(v)=>setState(()=>second=v)),const SizedBox(height:24),
 _LimitBanner('Single Transaction Limits of $single'),const SizedBox(height:18),_ProgressLimit('Daily Limit of $daily',daily),const SizedBox(height:16),_ProgressLimit('Weekly Limit of $weekly',weekly),const SizedBox(height:16),_ProgressLimit('Monthly Limit of $monthly',monthly),
 const Spacer(),_PrimaryButton('Increase Transfer Limits',onTap:()=>_push(context,const IncreaseLimitsScreen())),const SizedBox(height:28)
]));}}

class IncreaseLimitsScreen extends StatelessWidget {const IncreaseLimitsScreen({super.key});@override Widget build(BuildContext context)=>_Shell(title:'Transaction Limits',child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const SizedBox(height:20),const Text('Increase Transfer Limits',style:_t20),const SizedBox(height:4),const Text('Complete the sections below to unlock higher account limits. Approval typically takes 2–3 days.',style:_t12),const SizedBox(height:28),_ActionCard(Icons.location_on_outlined,'Verify Address','Face to face verification at your address',()=>_push(context,const AddressUpgradeScreen())),const SizedBox(height:14),_ActionCard(Icons.description_outlined,'Proof of Address','Upload electricity bill, water bill',()=>_push(context,const AddressUpgradeScreen()))]));}
class AddressUpgradeScreen extends StatelessWidget{const AddressUpgradeScreen({super.key});@override Widget build(BuildContext context)=>_Shell(title:'Transaction Limits',scroll:true,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const SizedBox(height:18),const Text('Confirm Your Address',style:_t20),const SizedBox(height:18),const _Bullet('Your document should be dated within the last 3 months and clearly show your name and address'),const _Bullet('Take a clear, full photo of your document, no cropped edges or blurry shots'),const _Bullet('Upload it as-is — no edits, filters, or photos taken from a screen'),const SizedBox(height:24),const _DocOption('Utility Bill','Dated within the last 3 months'),const _DocOption('Bank Statement','From a different bank, showing your current address, dated within the last 6 months'),const _DocOption('Tenancy Agreement','Renting? Upload your tenancy agreement along with a utility bill from your landlord confirming your address'),const SizedBox(height:28),_PrimaryButton('Choose document to upload',onTap:()=>_uploadSheet(context,'Upload ID')),const SizedBox(height:24)]));}

class ChangePasswordScreen extends StatefulWidget{const ChangePasswordScreen({super.key});@override State<ChangePasswordScreen> createState()=>_ChangePasswordScreenState();}
class _ChangePasswordScreenState extends State<ChangePasswordScreen>{final old=TextEditingController(),n=TextEditingController(),c=TextEditingController();@override Widget build(BuildContext context)=>_Shell(title:'Change Password',child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const SizedBox(height:28),const Text('Change your password',style:_t20),const SizedBox(height:24),_Input(label:'Old Password',hint:'Enter your old password',controller:old,obscure:true),const SizedBox(height:16),_Input(label:'New Password',hint:'Enter password',controller:n,obscure:true),const SizedBox(height:16),_Input(label:'Confirm Password',hint:'Confirm password',controller:c,obscure:true),const Spacer(),_PrimaryButton('Change your password',onTap:()=>_snack(context,'Password updated')),const SizedBox(height:28)]));}

class NotificationCenterScreen extends StatefulWidget{const NotificationCenterScreen({super.key});@override State<NotificationCenterScreen> createState()=>_NotificationCenterScreenState();}
class _NotificationCenterScreenState extends State<NotificationCenterScreen>{int tab=0; @override Widget build(BuildContext context)=>_Shell(title:'Notification',scroll:true,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const SizedBox(height:12),Wrap(spacing:8,children:['All','Transactions','Security','Rewards'].asMap().entries.map((e)=>ChoiceChip(label:Text(e.value),selected:tab==e.key,onSelected:(_)=>setState(()=>tab=e.key),selectedColor:AppColors.primary,labelStyle:TextStyle(fontFamily:'Sora',fontSize:11,color:tab==e.key?Colors.white:AppColors.body),side:BorderSide.none,showCheckmark:false)).toList()),const SizedBox(height:22),if(tab==3)...[const SizedBox(height:100),Center(child:Column(children:[Container(width:86,height:86,decoration:const BoxDecoration(color:Color(0xFFF5F7FB),shape:BoxShape.circle),child:const Icon(Icons.notifications_none_rounded,size:42,color:Color(0xFF99A6BF))),const SizedBox(height:16),const Text('No notifications yet',style:_t16b),const SizedBox(height:6),const SizedBox(width:260,child:Text('We’ll notify you about your orders and updates here.',textAlign:TextAlign.center,style:_t12))])),const SizedBox(height:100)]else...[const Text('TODAY',style:_cap),const SizedBox(height:10),const _NotifItem(Icons.south_west,'Deposit Received',r'Your monthly salary of $4,250.00 has been…','2m ago',Color(0xFF20C55D)),const _NotifItem(Icons.shield_outlined,'New Login Detected','A login attempt was made from a new device in Nigeria, Lagos. If this…','45m ago',Color(0xFFCC8408)),const _NotifItem(Icons.north_east,'Transfer Sent',r"You sent $150.00 to Chukwu Vincent for 'Family Support'.",'2hr ago',AppColors.primary),const SizedBox(height:18),const Text('YESTERDAY',style:_cap),const SizedBox(height:10),const _NotifItem(Icons.card_giftcard,'Cashback Earned!',r"You've earned $12.40 cashback from your last purchase.",'1d ago',Color(0xFF7B61FF)),const _NotifItem(Icons.support_agent,'Support Ticket Updated','Your inquiry regarding the international wire transfer has been updated.','1d ago',AppColors.primary),const SizedBox(height:30)]]));}

class NotificationSettingsScreen extends StatelessWidget{const NotificationSettingsScreen({super.key});@override Widget build(BuildContext context)=>_Shell(title:'Notification Settings',child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const SizedBox(height:22),const Text('Alert Preferences',style:_t16b),const SizedBox(height:16),_SettingsRow(Icons.swap_horiz,'Transaction Alerts',()=>_push(context,const NotificationChannelScreen(type:0))),_SettingsRow(Icons.shield_outlined,'Security Alerts',()=>_push(context,const NotificationChannelScreen(type:1))),_SettingsRow(Icons.campaign_outlined,'Marketing & News',()=>_push(context,const NotificationChannelScreen(type:2)))]));}
class NotificationChannelScreen extends StatefulWidget{const NotificationChannelScreen({super.key,required this.type});final int type;@override State<NotificationChannelScreen> createState()=>_NotificationChannelScreenState();}
class _NotificationChannelScreenState extends State<NotificationChannelScreen>{bool push=true,email=false,sms=false;@override Widget build(BuildContext context){final title=['Transaction Alerts','Security Alerts','Marketing & News'][widget.type];final p=widget.type==0?'Real-Time Alerts':widget.type==1?'Login Alerts, Password Changes, New Device Sign-in':'Promotions, New Features,Newsletter';final e=widget.type==0?'Detailed Statements':widget.type==1?'Secondary Channel. Audit Trail, Detailed Logs':'Promotions, New Features,Newsletter';return _Shell(title:'Notification Settings',child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const SizedBox(height:20),Text(title,style:_t16b),const SizedBox(height:22),_ToggleRow('Push Notification',p,push,(v)=>setState(()=>push=v)),_ToggleRow('Email',e,email,(v)=>setState(()=>email=v)),if(widget.type==0)_ToggleRow('SMS','Standard Rates Apply',sms,(v)=>setState(()=>sms=v))]));}}

class ResetPinStartScreen extends StatefulWidget{const ResetPinStartScreen({super.key});@override State<ResetPinStartScreen> createState()=>_ResetPinStartScreenState();}
class _ResetPinStartScreenState extends State<ResetPinStartScreen>{int method=0;@override Widget build(BuildContext context)=>_Shell(title:'Reset Transaction PIN',child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const SizedBox(height:26),const Text('To reset your transaction PIN, you’ll need to verify with a verification code sent to you.',style:_t14),const SizedBox(height:24),const Text('Choose how you want to get code',style:_t14m),const SizedBox(height:12),_RadioChoice('Send via SMS',method==0,()=>setState(()=>method=0)),const SizedBox(height:12),_RadioChoice('Send via Email',method==1,()=>setState(()=>method=1)),const Spacer(),_PrimaryButton('Next',onTap:()=>_push(context,VerifyPinCodeScreen(email:method==1))),const SizedBox(height:28)]));}
class VerifyPinCodeScreen extends StatefulWidget{const VerifyPinCodeScreen({super.key,required this.email});final bool email;@override State<VerifyPinCodeScreen> createState()=>_VerifyPinCodeScreenState();}
class _VerifyPinCodeScreenState extends State<VerifyPinCodeScreen>{final c=TextEditingController();@override Widget build(BuildContext context)=>_Shell(title:'Reset Transaction PIN',child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const SizedBox(height:26),Text('To reset your transaction PIN, you’ll need to verify with a verification code sent to your ${widget.email?'email':'phone number'}.',style:_t14),const SizedBox(height:24),_Input(label:'Verification code',hint:'*********',controller:c,keyboard:TextInputType.number),const SizedBox(height:12),Row(children:[const Text('Didn’t get a code?',style:_t12),TextButton(onPressed:()=>_snack(context,'Code resent'),child:const Text('Resend Code')),const Spacer(),const Text('0:34',style:_t12)]),const Spacer(),_PrimaryButton('Next',onTap:()=>_push(context,const NewTransactionPinScreen())),const SizedBox(height:28)]));}
class NewTransactionPinScreen extends StatefulWidget{const NewTransactionPinScreen({super.key});@override State<NewTransactionPinScreen> createState()=>_NewTransactionPinScreenState();}
class _NewTransactionPinScreenState extends State<NewTransactionPinScreen>{final a=TextEditingController(),b=TextEditingController();@override Widget build(BuildContext context)=>_Shell(title:'Transaction PIN',child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const SizedBox(height:26),const Text('Your 4-digit transaction PIN secures your transactions. It is important that you do not share this PIN with anyone',style:_t14),const SizedBox(height:24),_Input(label:'New PIN',hint:'****',controller:a,obscure:true,keyboard:TextInputType.number),const SizedBox(height:16),_Input(label:'Confirm New PIN',hint:'****',controller:b,obscure:true,keyboard:TextInputType.number),const Spacer(),_PrimaryButton('Save',onTap:()=>_push(context,const PinSuccessScreen())),const SizedBox(height:28)]));}
class PinSuccessScreen extends StatefulWidget{const PinSuccessScreen({super.key});@override State<PinSuccessScreen> createState()=>_PinSuccessScreenState();}
class _PinSuccessScreenState extends State<PinSuccessScreen> with SingleTickerProviderStateMixin{late final AnimationController c;@override void initState(){super.initState();c=AnimationController(vsync:this,duration:const Duration(milliseconds:700))..forward();}@override void dispose(){c.dispose();super.dispose();}@override Widget build(BuildContext context)=>Scaffold(backgroundColor:Colors.white,body:SafeArea(child:Padding(padding:const EdgeInsets.fromLTRB(16,70,16,28),child:Column(children:[ScaleTransition(scale:CurvedAnimation(parent:c,curve:Curves.elasticOut),child:Container(width:150,height:150,decoration:const BoxDecoration(shape:BoxShape.circle,color:Color(0xFFEAF2FF)),child:const Icon(Icons.check_circle_rounded,size:96,color:AppColors.primary))),const SizedBox(height:16),const Text('Success!',style:_t24b),const SizedBox(height:4),const Text('You’ve successfully reset your Transaction PIN',textAlign:TextAlign.center,style:_t14),const Spacer(),_PrimaryButton('Okay',onTap:()=>Navigator.of(context).popUntil((r)=>r.isFirst))]))));}

// ---- Support ----
class CustomerSupportScreen extends StatelessWidget{const CustomerSupportScreen({super.key});@override Widget build(BuildContext context)=>_Shell(title:'Customer Support',scroll:true,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const SizedBox(height:18),const Text('Chat',style:_cap),const SizedBox(height:8),_SupportTile(Icons.chat_bubble_outline,'Live Chat','Start a conversation on live chat',()=>_push(context,const SupportHubScreen())),const SizedBox(height:12),_SupportTile(Icons.mail_outline,'Email','We aim to respond in a day',()=>_push(context,const EmailSupportScreen())),const SizedBox(height:24),const Text('Social Media',style:_cap),const SizedBox(height:8),_SupportTile(Icons.camera_alt_outlined,'Instagram','',()=>_socialDialog(context,'Instagram')),_SupportTile(Icons.work_outline,'Linkedln','',()=>_socialDialog(context,'Linkedln')),_SupportTile(Icons.alternate_email,'Twitter','',()=>_socialDialog(context,'X')),const SizedBox(height:28)]));}
class SupportHubScreen extends StatelessWidget{const SupportHubScreen({super.key});@override Widget build(BuildContext context)=>_Shell(title:'Customer Support',scroll:true,child:Column(children:[Container(width:double.infinity,padding:const EdgeInsets.all(20),decoration:BoxDecoration(color:AppColors.primary,borderRadius:BorderRadius.circular(12)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Davopay',style:TextStyle(fontFamily:'Sora',fontSize:18,fontWeight:FontWeight.w700,color:Colors.white)),const SizedBox(height:20),const Text('Hi Chukwu 👋\nHow can we help?',style:TextStyle(fontFamily:'Sora',fontSize:24,fontWeight:FontWeight.w700,color:Colors.white,height:1.3)),const SizedBox(height:18),_HubAction('Messages','Send us a messages',()=>_push(context,const SupportMessagesScreen())),_HubAction('Help','Search for help',()=>_push(context,const HelpCenterScreen()))])),const SizedBox(height:18),...['Explore Rewards: Key Details You Should Know','Unlock More Earnings with Every Referral','Everything You Need to Know About Your Virtual Dollar Card','Join Our community Channel'].map((t)=>_ArticleLink(t)),const SizedBox(height:22)]));}
class SupportMessagesScreen extends StatelessWidget{const SupportMessagesScreen({super.key});@override Widget build(BuildContext context)=>_Shell(title:'Messages',child:Column(children:[const Spacer(),const Icon(Icons.chat_bubble_outline_rounded,size:46,color:AppColors.primary),const SizedBox(height:14),const Text('No Messages',style:_t16b),const SizedBox(height:6),const Text('Messages from the team will be shown here',textAlign:TextAlign.center,style:_t12),const SizedBox(height:20),SizedBox(width:150,child:_PrimaryButton('Ask a question',onTap:()=>_push(context,const SupportChatScreen()))),const Spacer()]));}
class SupportChatScreen extends StatefulWidget{const SupportChatScreen({super.key});@override State<SupportChatScreen> createState()=>_SupportChatScreenState();}
class _SupportChatScreenState extends State<SupportChatScreen>{
  String? choice;
  @override
  Widget build(BuildContext context)=>_Shell(
    title:'Callie',
    scroll:true,
    child:Column(
      crossAxisAlignment:CrossAxisAlignment.start,
      children:[
        const SizedBox(height:14),
        const _AgentHeader(),
        const SizedBox(height:16),
        const _ChatBubble(text:"Hi there,\nThank you for choosing Davopay.\nWe're currently handling a high volume of requests, so responses might take a bit longer than usual.\nThanks for your patience, we'll get to you as soon as possible."),
        const SizedBox(height:12),
        const _AgentHeader(small:true),
        const SizedBox(height:8),
        const _ChatBubble(text:'Hello Chukwu, this is Bella from Davopay.\nPlease choose the option below that best matches your request.'),
        const SizedBox(height:12),
        if(choice==null)
          ...['Account Management & Verification','Virtual Cards (Creation, Funding, refundd)','Gift Cards, Crypto','Deposits and Funding','Bank Accounts (Creation & Management)','Withdrawals from Davopay to Bank Account','Account Suspension, Issues & Restrictions','Something Else'].map(
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
              suffixIcon:IconButton(onPressed:(){},icon:const Icon(Icons.send_rounded,color:AppColors.primary)),
              border:OutlineInputBorder(borderRadius:BorderRadius.circular(8)),
            ),
          ),
        ],
        const SizedBox(height:30),
      ],
    ),
  );
}
class EmailSupportScreen extends StatefulWidget{const EmailSupportScreen({super.key});@override State<EmailSupportScreen> createState()=>_EmailSupportScreenState();}
class _EmailSupportScreenState extends State<EmailSupportScreen>{final a=TextEditingController(),b=TextEditingController(),c=TextEditingController();@override Widget build(BuildContext context)=>_Shell(title:'Email Support',scroll:true,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const SizedBox(height:20),const Text('Email Us',style:_t20),const SizedBox(height:4),const Text('Have a question about your order or our services? Our team is here to help.',style:_t12),const SizedBox(height:18),Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:const Color(0xFFEAF2FF),borderRadius:BorderRadius.circular(8)),child:const Row(children:[Icon(Icons.bolt_rounded,color:AppColors.primary),SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Rapid Response',style:_t14b),Text('We typically respond to all email inquiries within 24 hours.',style:_t12)]))])),const SizedBox(height:20),_Input(label:'Message',hint:'What can we help you with?',controller:a),const SizedBox(height:14),_Input(label:'Order ID',hint:'e.g. #VP-8291',controller:b),const SizedBox(height:14),const Text('Message',style:_t14m),const SizedBox(height:6),TextField(controller:c,maxLines:6,decoration:InputDecoration(hintText:'Tell us more about your inquiry...',border:OutlineInputBorder(borderRadius:BorderRadius.circular(4)))),const SizedBox(height:22),_PrimaryButton('Send Email',onTap:()=>_snack(context,'Email sent')),const SizedBox(height:24)]));}
class HelpCenterScreen extends StatefulWidget{const HelpCenterScreen({super.key});@override State<HelpCenterScreen> createState()=>_HelpCenterScreenState();}
class _HelpCenterScreenState extends State<HelpCenterScreen>{final q=TextEditingController();@override Widget build(BuildContext context){final cats=_helpCats.where((e)=>e.$1.toLowerCase().contains(q.text.toLowerCase())).toList();return _Shell(title:'Help',scroll:true,child:Column(children:[TextField(controller:q,onChanged:(_)=>setState((){}),decoration:InputDecoration(hintText:'Search for help',prefixIcon:const Icon(Icons.search_rounded),border:OutlineInputBorder(borderRadius:BorderRadius.circular(8)))),const SizedBox(height:16),...cats.map((e)=>_HelpCategory(e.$1,e.$2,e.$3)),const SizedBox(height:30)]));}}

// ---- Rewards / Ambassador ----
class ReferralDashboardScreen extends StatelessWidget{const ReferralDashboardScreen({super.key});@override Widget build(BuildContext context)=>_Shell(title:'Rewards',scroll:true,child:Column(children:[Container(width:double.infinity,padding:const EdgeInsets.all(18),decoration:BoxDecoration(color:AppColors.primary,borderRadius:BorderRadius.circular(8)),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Referral Program',style:TextStyle(fontFamily:'Sora',fontSize:12,color:Colors.white70)),SizedBox(height:10),Text('Earn ₦2,000 For\nevery friend Referred',style:TextStyle(fontFamily:'Sora',fontSize:24,fontWeight:FontWeight.w700,color:Colors.white,height:1.25)),SizedBox(height:8),Text('Invite your friends to Davopay and get rewarded when they make their first successful transaction.',style:TextStyle(fontFamily:'Sora',fontSize:12,color:Colors.white,height:1.4))])),const SizedBox(height:18),const _ReferralBox(),const SizedBox(height:18),_SectionLink('Manage your earnings','Referral Analytics',()=>_push(context,const ReferralAnalyticsScreen())),const SizedBox(height:18),_PrimaryButton('Davo Points',onTap:()=>_push(context,const DavoPointsScreen())),const SizedBox(height:22),const _HowItWorks(),const SizedBox(height:30)]));}
class ReferralAnalyticsScreen extends StatelessWidget{const ReferralAnalyticsScreen({super.key});@override Widget build(BuildContext context)=>_Shell(title:'Referral Analytics',scroll:true,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Performance Hub',style:TextStyle(fontFamily:'Sora',fontSize:11,color:AppColors.primary)),const SizedBox(height:6),const Text('Referral Analytics',style:_t20),const SizedBox(height:18),const _StatsGrid([('My invitees','128'),('Rewarded','84'),('KYC Done','53'),('Deposited','34')]),const SizedBox(height:20),const Text('Manage your earnings:',style:_t14m),const SizedBox(height:10),_PrimaryButton('Rewards',onTap:()=>_push(context,const DavoPointsScreen())),const SizedBox(height:22),const Text('Referrals',style:_t16b),const SizedBox(height:4),const Text('Track your network and earned rewards.',style:_t12),const SizedBox(height:14),..._people.map((e)=>_PersonRow(e.$1,e.$2,e.$3)),const SizedBox(height:28)]));}
class DavoPointsScreen extends StatelessWidget{const DavoPointsScreen({super.key});@override Widget build(BuildContext context)=>_Shell(title:'Davo points Dashboard',scroll:true,child:Column(children:[const _StatsGrid([('Earned Points','Đ15.00'),('Redeemed Points','Đ0.00'),('Available Points','Đ15.00'),('Rate','Đ20.00 = NGN 1.00')]),const SizedBox(height:18),_PrimaryButton('Redeem',onTap:()=>_snack(context,'Points redeemed')),const SizedBox(height:14),const Text('Your Davo point rewards will be credited to your NGN Wallet After Redeeming it.',style:_t12),const SizedBox(height:22),const Align(alignment:Alignment.centerLeft,child:Text('Recent Activity',style:_t16b)),const SizedBox(height:10),...['Referral: Jane Doe','Cashback Reward: Milestone NGN 10','Cashback Reward: Milestone NGN 10','Referral: Elena Rodriguez'].map((e)=>_ActivityRow(e,'+Đ5.00')),const SizedBox(height:26)]));}
class StudentAmbassadorScreen extends StatefulWidget{const StudentAmbassadorScreen({super.key});@override State<StudentAmbassadorScreen> createState()=>_StudentAmbassadorScreenState();}
class _StudentAmbassadorScreenState extends State<StudentAmbassadorScreen>{final s=TextEditingController(),id=TextEditingController();bool uploaded=false;@override Widget build(BuildContext context)=>_Shell(title:'Student Ambassador Details',child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const SizedBox(height:16),_Input(label:'School Name',hint:'Enter your school name',controller:s),const SizedBox(height:16),_Input(label:'Student ID no',hint:'Enter your student ID No',controller:id),const SizedBox(height:16),const Text('Upload Student ID',style:_t14m),const SizedBox(height:7),OutlinedButton.icon(onPressed:()=>setState(()=>uploaded=true),icon:Icon(uploaded?Icons.check_circle:Icons.upload_file_rounded,color:AppColors.primary),label:Text(uploaded?'Student ID uploaded':'Upload Student ID'),style:OutlinedButton.styleFrom(minimumSize:const Size.fromHeight(52),side:const BorderSide(color:Color(0xFFEBEDF3)))),const Spacer(),_PrimaryButton('Submit',onTap:()=>_push(context,const AmbassadorDashboardScreen())),const SizedBox(height:28)]));}
class AmbassadorDashboardScreen extends StatelessWidget{const AmbassadorDashboardScreen({super.key});@override Widget build(BuildContext context)=>_Shell(title:'Davo points Dashboard',scroll:true,child:Column(children:[Row(children:[ClipOval(child:Image.asset(_avatar,width:40,height:40,fit:BoxFit.cover)),const SizedBox(width:10),const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Hi, Callie',style:_t14b),Text('Ambassador',style:TextStyle(fontFamily:'Sora',fontSize:11,color:AppColors.primary))])),IconButton(onPressed:(){},icon:const Icon(Icons.notifications_none))]),const SizedBox(height:14),Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:AppColors.primary,borderRadius:BorderRadius.circular(10)),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Ambassador Program',style:TextStyle(fontFamily:'Sora',fontSize:20,fontWeight:FontWeight.w700,color:Colors.white)),SizedBox(height:4),Text('Empower your campus. Refer friends and earn rewards for every successful signup.',style:TextStyle(fontFamily:'Sora',fontSize:11,color:Colors.white)),SizedBox(height:14),Text('Silver Ambassador                         18/25',style:TextStyle(fontFamily:'Sora',fontSize:12,color:Colors.white)),SizedBox(height:6),LinearProgressIndicator(value:.72,minHeight:7,backgroundColor:Colors.white24,valueColor:AlwaysStoppedAnimation(Colors.white)),SizedBox(height:5),Text('7 more referrals to unlock Gold Tier',style:TextStyle(fontFamily:'Sora',fontSize:10,color:Colors.white70))])),const SizedBox(height:18),const _ReferralBox(),const SizedBox(height:18),const _StatsGrid([('Students Referred','345'),('Students Verified','205'),('Pending','140'),('Earned','Đ400.00')]),const SizedBox(height:18),Row(children:[Expanded(child:_QuickAction(Icons.share,'Share Link',(){})),Expanded(child:_QuickAction(Icons.qr_code,'QR Code',(){})),Expanded(child:_QuickAction(Icons.emoji_events_outlined,'Rewards',()=>_push(context,const DavoPointsScreen()))),Expanded(child:_QuickAction(Icons.bar_chart,'Leaderboard',()=>_push(context,const AmbassadorLeaderboardScreen())))]),const SizedBox(height:22),const Align(alignment:Alignment.centerLeft,child:Text('Referrals',style:_t16b)),const SizedBox(height:8),..._people.take(4).map((e)=>_PersonRow(e.$1,e.$2,e.$3)),const SizedBox(height:24)]));}
class AmbassadorLeaderboardScreen extends StatelessWidget{const AmbassadorLeaderboardScreen({super.key});@override Widget build(BuildContext context)=>_Shell(title:'Ambassador Leaderboard',scroll:true,child:Column(children:[const SizedBox(height:12),const Row(crossAxisAlignment:CrossAxisAlignment.end,mainAxisAlignment:MainAxisAlignment.spaceEvenly,children:[_Podium('2','Sarah L.','42 Refs',96),_Podium('1','James P.','145 Referrals',128),_Podium('3','Mila K.','39 Refs',90)]),const SizedBox(height:24),const Row(children:[Text('Rankings 1-10',style:_t16b),Spacer(),Text('Total 124 Active',style:_t12)]),const SizedBox(height:10),..._rankings.asMap().entries.map((e)=>_RankRow(e.key+4,e.value.$1,e.value.$2,e.value.$3)),const SizedBox(height:18),Container(padding:const EdgeInsets.all(12),decoration:BoxDecoration(border:Border.all(color:AppColors.primary,width:2),borderRadius:BorderRadius.circular(8)),child:const Row(children:[Text('#12',style:_t14b),SizedBox(width:10),CircleAvatar(backgroundImage:AssetImage(_avatar)),SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Alex M. (You)',style:_t14b),Text('3 To Next Rank',style:_t12)])),Text('18\nReferrals',textAlign:TextAlign.right,style:_t12)])),const SizedBox(height:26)]));}

// ---- Shared UI ----
class _Shell extends StatelessWidget{const _Shell({required this.title,required this.child,this.scroll=false});final String title;final Widget child;final bool scroll;@override Widget build(BuildContext context){final body=Padding(padding:const EdgeInsets.fromLTRB(16,12,16,16),child:child);return Scaffold(backgroundColor:Colors.white,appBar:AppBar(backgroundColor:Colors.white,surfaceTintColor:Colors.white,centerTitle:true,leading:IconButton(icon:const Icon(Icons.arrow_back_ios_new_rounded,size:18),onPressed:()=>Navigator.pop(context)),title:Text(title,style:const TextStyle(fontFamily:'Sora',fontSize:20,fontWeight:FontWeight.w400,color:AppColors.ink))),body:SafeArea(top:false,child:scroll?SingleChildScrollView(physics:const BouncingScrollPhysics(),child:body):body));}}
class _MenuItem{_MenuItem(this.icon,this.label,this.onTap,{this.trailing});final IconData icon;final String label;final VoidCallback onTap;final Widget? trailing;}
class _MenuCard extends StatelessWidget{const _MenuCard({this.title,required this.items});final String? title;final List<_MenuItem> items;@override Widget build(BuildContext context)=>Container(width:double.infinity,padding:const EdgeInsets.fromLTRB(12,16,12,16),decoration:BoxDecoration(color:AppColors.offWhite,borderRadius:BorderRadius.circular(4)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[if(title!=null)...[Text(title!,style:_t16b),const SizedBox(height:24)],...items.asMap().entries.map((e)=>Padding(padding:EdgeInsets.only(bottom:e.key==items.length-1?0:22),child:InkWell(onTap:e.value.onTap,child:Row(children:[Container(width:32,height:32,decoration:BoxDecoration(color:const Color(0xFFEAEef6),borderRadius:BorderRadius.circular(8)),child:Icon(e.value.icon,size:17,color:AppColors.primary)),const SizedBox(width:16),Expanded(child:Text(e.value.label,style:_t14)),e.value.trailing??const Icon(Icons.chevron_right_rounded,size:18,color:Color(0xFF8D8D8D))]))))]));}
class _DavoSwitch extends StatelessWidget{const _DavoSwitch({required this.value,required this.onChanged});final bool value;final ValueChanged<bool> onChanged;@override Widget build(BuildContext context)=>GestureDetector(onTap:()=>onChanged(!value),child:AnimatedContainer(duration:const Duration(milliseconds:220),width:48,height:26,padding:const EdgeInsets.all(3),decoration:BoxDecoration(color:value?const Color(0xFF1FAF5A):const Color(0xFFF2F3F7),borderRadius:BorderRadius.circular(52)),child:AnimatedAlign(duration:const Duration(milliseconds:220),alignment:value?Alignment.centerRight:Alignment.centerLeft,child:Container(width:20,height:20,decoration:BoxDecoration(shape:BoxShape.circle,color:Colors.white,boxShadow:[BoxShadow(color:Colors.black.withValues(alpha: .12),blurRadius:3)])))));}
class _InfoField extends StatelessWidget{const _InfoField({required this.label,required this.value});final String label,value;@override Widget build(BuildContext context)=>Container(width:double.infinity,margin:const EdgeInsets.only(bottom:12),padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:AppColors.offWhite,borderRadius:BorderRadius.circular(4)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(label,style:const TextStyle(fontFamily:'Sora',fontSize:11,color:Color(0xFF8D8D8D))),const SizedBox(height:4),Text(value,style:_t14)]));}
class _StatusRow extends StatelessWidget {
  const _StatusRow(this.title, this.status, this.good, this.tap);
  final String title;
  final String status;
  final bool good;
  final VoidCallback? tap;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: tap,
        child: Container(
          height: 58,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.offWhite,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Expanded(child: Text(title, style: _t14)),
              Text(
                status,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 11,
                  color: good ? const Color(0xFF1FAF5A) : const Color(0xFF8D8D8D),
                ),
              ),
              if (tap != null)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.chevron_right, size: 18, color: Color(0xFF8D8D8D)),
                ),
            ],
          ),
        ),
      );
}

class _ChoiceTile extends StatelessWidget{const _ChoiceTile({required this.icon,required this.title,required this.subtitle,this.selected=false,required this.onTap});final IconData icon;final String title,subtitle;final bool selected;final VoidCallback onTap;@override Widget build(BuildContext context)=>InkWell(onTap:onTap,borderRadius:BorderRadius.circular(8),child:Container(height:70,padding:const EdgeInsets.symmetric(horizontal:14),decoration:BoxDecoration(border:Border.all(color:selected?AppColors.primary:const Color(0xFFEBEDF3)),borderRadius:BorderRadius.circular(8)),child:Row(children:[Icon(icon,color:AppColors.primary),const SizedBox(width:14),Expanded(child:Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:_t14b),Text(subtitle,style:_t12)])),const Icon(Icons.chevron_right_rounded,size:18)])));}

class _IdTile extends StatelessWidget {
  const _IdTile(this.icon, this.title, this.sub, this.selected, this.tap);
  final IconData icon;
  final String title, sub;
  final bool selected;
  final VoidCallback tap;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: _ChoiceTile(
          icon: icon,
          title: title,
          subtitle: sub,
          selected: selected,
          onTap: tap,
        ),
      );
}

class _Bullet extends StatelessWidget{const _Bullet(this.text);final String text;@override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.only(bottom:12),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[const Padding(padding:EdgeInsets.only(top:5),child:Icon(Icons.circle,size:6,color:AppColors.primary)),const SizedBox(width:10),Expanded(child:Text(text,style:_t12))]));}
List<Widget> _cornerFrames()=>[const Positioned(left:28,top:28,child:_Corner()),const Positioned(right:28,top:28,child:RotatedBox(quarterTurns:1,child:_Corner())),const Positioned(right:28,bottom:28,child:RotatedBox(quarterTurns:2,child:_Corner())),const Positioned(left:28,bottom:28,child:RotatedBox(quarterTurns:3,child:_Corner()))];
class _Corner extends StatelessWidget{const _Corner();@override Widget build(BuildContext context)=>Container(width:32,height:32,decoration:const BoxDecoration(border:Border(top:BorderSide(color:Colors.white,width:2),left:BorderSide(color:Colors.white,width:2))));}
class _AccountLimitTile extends StatelessWidget{const _AccountLimitTile({required this.flag,required this.title,required this.subtitle,required this.onTap});final String flag,title,subtitle;final VoidCallback onTap;@override Widget build(BuildContext context)=>InkWell(onTap:onTap,child:Container(height:70,padding:const EdgeInsets.symmetric(horizontal:14),decoration:BoxDecoration(color:AppColors.offWhite,borderRadius:BorderRadius.circular(6)),child:Row(children:[Text(flag,style:const TextStyle(fontSize:26)),const SizedBox(width:12),Expanded(child:Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:_t14b),Text(subtitle,style:_t12)])),const Icon(Icons.chevron_right_rounded,size:18)])));}
class _Pill extends StatelessWidget{const _Pill(this.t);final String t;@override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.symmetric(horizontal:9,vertical:4),decoration:BoxDecoration(color:const Color(0xFFE8EEFC),borderRadius:BorderRadius.circular(20)),child:Text(t,style:const TextStyle(fontFamily:'Sora',fontSize:10,color:AppColors.primary)));}
class _Segment extends StatelessWidget{const _Segment({required this.left,required this.right,required this.rightSelected,required this.onChanged});final String left,right;final bool rightSelected;final ValueChanged<bool> onChanged;@override Widget build(BuildContext context)=>Container(height:55,padding:const EdgeInsets.all(6),decoration:BoxDecoration(color:const Color(0xFFEEF0F5),borderRadius:BorderRadius.circular(8)),child:Row(children:[Expanded(child:_SegButton(left,!rightSelected,()=>onChanged(false))),Expanded(child:_SegButton(right,rightSelected,()=>onChanged(true)))]));}
class _SegButton extends StatelessWidget{const _SegButton(this.text,this.sel,this.tap);final String text;final bool sel;final VoidCallback tap;@override Widget build(BuildContext context)=>InkWell(onTap:tap,child:AnimatedContainer(duration:const Duration(milliseconds:200),alignment:Alignment.center,decoration:BoxDecoration(color:sel?Colors.white:Colors.transparent,borderRadius:BorderRadius.circular(7)),child:Text(text,style:TextStyle(fontFamily:'Sora',fontSize:12,fontWeight:sel?FontWeight.w600:FontWeight.w400,color:sel?AppColors.primary:AppColors.body))));}

class _LimitBanner extends StatelessWidget {
  const _LimitBanner(this.t);
  final String t;
  @override
  Widget build(BuildContext context) => Container(
        height: 51,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: AppColors.offWhite,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(t, style: _t14),
      );
}

class _ProgressLimit extends StatelessWidget{const _ProgressLimit(this.title,this.max);final String title,max;@override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:AppColors.offWhite,borderRadius:BorderRadius.circular(6)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:_t14),const SizedBox(height:14),TweenAnimationBuilder<double>(duration:const Duration(milliseconds:600),tween:Tween(begin:0,end:.06),builder:(_,v,__)=>LinearProgressIndicator(value:v,minHeight:7,borderRadius:BorderRadius.circular(8),backgroundColor:const Color(0xFFE5E8EE),valueColor:const AlwaysStoppedAnimation(AppColors.primary))),const SizedBox(height:10),Row(children:[const Text('0.00 Spent',style:_t12),const Spacer(),Text('$max Spent',style:_t12)])]));}
class _ActionCard extends StatelessWidget{const _ActionCard(this.icon,this.title,this.sub,this.tap);final IconData icon;final String title,sub;final VoidCallback tap;@override Widget build(BuildContext context)=>InkWell(onTap:tap,child:Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:AppColors.offWhite,borderRadius:BorderRadius.circular(8)),child:Row(children:[Container(width:42,height:42,decoration:BoxDecoration(color:const Color(0xFFEAF2FF),borderRadius:BorderRadius.circular(8)),child:Icon(icon,color:AppColors.primary)),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:_t14b),Text(sub,style:_t12)])),const Icon(Icons.chevron_right)])));}

class _DocOption extends StatelessWidget {
  const _DocOption(this.a, this.b);
  final String a, b;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFEBEDF3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(a, style: _t14b),
            const SizedBox(height: 4),
            Text(b, style: _t12),
          ],
        ),
      );
}

class _Input extends StatelessWidget{const _Input({required this.label,required this.hint,required this.controller,this.obscure=false,this.keyboard});final String label,hint;final TextEditingController controller;final bool obscure;final TextInputType? keyboard;@override Widget build(BuildContext context)=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(label,style:_t14m),const SizedBox(height:6),TextField(controller:controller,obscureText:obscure,keyboardType:keyboard,decoration:InputDecoration(hintText:hint,suffixIcon:obscure?const Icon(Icons.visibility_off_outlined,size:18):null,border:OutlineInputBorder(borderRadius:BorderRadius.circular(4))) )]);}
class _PrimaryButton extends StatelessWidget{const _PrimaryButton(this.label,{required this.onTap});final String label;final VoidCallback onTap;@override Widget build(BuildContext context)=>SizedBox(width:double.infinity,height:48,child:ElevatedButton(onPressed:(){HapticFeedback.lightImpact();onTap();},style:ElevatedButton.styleFrom(backgroundColor:AppColors.primary,foregroundColor:Colors.white,elevation:0,shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(4))),child:Text(label,style:const TextStyle(fontFamily:'Sora',fontSize:14,fontWeight:FontWeight.w600))));}
class _NotifItem extends StatelessWidget{const _NotifItem(this.icon,this.title,this.sub,this.time,this.color);final IconData icon;final String title,sub,time;final Color color;@override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.symmetric(vertical:12),decoration:const BoxDecoration(border:Border(bottom:BorderSide(color:Color(0xFFF2F3F7)))),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Container(width:34,height:34,decoration:BoxDecoration(color:color.withValues(alpha: .12),borderRadius:BorderRadius.circular(8)),child:Icon(icon,color:color,size:18)),const SizedBox(width:11),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:_t14b),const SizedBox(height:3),Text(sub,style:_t12)])),const SizedBox(width:8),Text(time,style:const TextStyle(fontFamily:'Sora',fontSize:10,color:Color(0xFF8D8D8D)))]));}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow(this.i, this.t, this.tap);
  final IconData i;
  final String t;
  final VoidCallback tap;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: tap,
        child: Container(
          height: 58,
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFF2F3F7))),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(i, color: AppColors.primary, size: 17),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(t, style: _t14)),
              const Icon(Icons.chevron_right, size: 18),
            ],
          ),
        ),
      );
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow(this.t, this.s, this.v, this.on);
  final String t, s;
  final bool v;
  final ValueChanged<bool> on;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xFFF2F3F7))),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t, style: _t14b),
                  const SizedBox(height: 3),
                  Text(s, style: _t12),
                ],
              ),
            ),
            _DavoSwitch(value: v, onChanged: on),
          ],
        ),
      );
}

class _RadioChoice extends StatelessWidget {
  const _RadioChoice(this.t, this.sel, this.tap);
  final String t;
  final bool sel;
  final VoidCallback tap;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: tap,
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            border: Border.all(
              color: sel ? AppColors.primary : const Color(0xFFEBEDF3),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                sel ? Icons.radio_button_checked : Icons.radio_button_off,
                color: sel ? AppColors.primary : const Color(0xFF8D8D8D),
              ),
              const SizedBox(width: 12),
              Text(t, style: _t14),
            ],
          ),
        ),
      );
}

class _SupportTile extends StatelessWidget {
  const _SupportTile(this.i, this.t, this.s, this.tap);
  final IconData i;
  final String t, s;
  final VoidCallback tap;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: tap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 62),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFF2F3F7))),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(i, color: AppColors.primary, size: 19),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t, style: _t14b),
                    if (s.isNotEmpty) Text(s, style: _t12),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 18),
            ],
          ),
        ),
      );
}

class _HubAction extends StatelessWidget{const _HubAction(this.t,this.s,this.tap);final String t,s;final VoidCallback tap;@override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.only(bottom:10),child:InkWell(onTap:tap,child:Container(padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(8)),child:Row(children:[Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(t,style:_t14b),Text(s,style:_t12)])),const Icon(Icons.chevron_right,color:AppColors.primary)]))));}
class _ArticleLink extends StatelessWidget{const _ArticleLink(this.t);final String t;@override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.symmetric(vertical:13),decoration:const BoxDecoration(border:Border(bottom:BorderSide(color:Color(0xFFF2F3F7)))),child:Row(children:[Expanded(child:Text(t,style:_t14)),const Icon(Icons.chevron_right,size:18)]));}
class _AgentHeader extends StatelessWidget{const _AgentHeader({this.small=false});final bool small;@override Widget build(BuildContext context)=>Row(children:[Container(width:small?28:42,height:small?28:42,decoration:const BoxDecoration(color:AppColors.primary,shape:BoxShape.circle),child:const Icon(Icons.auto_awesome,color:Colors.white,size:18)),const SizedBox(width:10),Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Callie',style:small?_t12b:_t14b),if(!small)const Text('The team can also help',style:_t12),if(small)const Text('Ai Agent',style:_t12)])]);}
class _ChatBubble extends StatelessWidget{const _ChatBubble({required this.text});final String text;@override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:AppColors.offWhite,borderRadius:BorderRadius.circular(12)),child:Text(text,style:_t12));}

class _ReferralBox extends StatelessWidget {
  const _ReferralBox();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.offWhite,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('manish1', style: _t14b),
                      Text('Your referral code', style: _t12),
                    ],
                  ),
                ),
                Icon(Icons.copy, size: 18, color: AppColors.primary),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'https://davopay.com/...',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 12,
                          color: AppColors.primary,
                        ),
                      ),
                      Text('Your referral link', style: _t12),
                    ],
                  ),
                ),
                OutlinedButton(onPressed: () {}, child: const Text('Share')),
              ],
            ),
          ],
        ),
      );
}

class _SectionLink extends StatelessWidget {
  const _SectionLink(this.a, this.b, this.tap);
  final String a, b;
  final VoidCallback tap;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.offWhite,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(a, style: _t12),
                  Text(b, style: _t14b),
                ],
              ),
            ),
            IconButton(onPressed: tap, icon: const Icon(Icons.chevron_right)),
          ],
        ),
      );
}
class _HowItWorks extends StatelessWidget{const _HowItWorks();@override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:AppColors.offWhite,borderRadius:BorderRadius.circular(8)),child:const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('How it works',style:_t16b),SizedBox(height:14),_Step('1','Send Invite','Share your unique link or code with your friends via social media or direct message.'),_Step('2','Friend Joins','Your friend signs up and completes a successful transaction of NGN50,000'),_Step('3','Get Paid','You and your friend get credited with Đ2,000 Davo Points.') ]));}
class _Step extends StatelessWidget{const _Step(this.n,this.t,this.s);final String n,t,s;@override Widget build(BuildContext context)=>Padding(padding:const EdgeInsets.only(bottom:16),child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[CircleAvatar(radius:12,backgroundColor:Colors.white,child:Text(n,style:const TextStyle(fontFamily:'Sora',fontSize:10,color:AppColors.primary))),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(t,style:_t14b),Text(s,style:_t12)]))]));}
class _StatsGrid extends StatelessWidget{const _StatsGrid(this.items);final List<(String,String)> items;@override Widget build(BuildContext context)=>GridView.count(crossAxisCount:2,shrinkWrap:true,physics:const NeverScrollableScrollPhysics(),mainAxisSpacing:10,crossAxisSpacing:10,childAspectRatio:2.15,children:items.map((e)=>Container(padding:const EdgeInsets.all(12),decoration:BoxDecoration(color:AppColors.offWhite,borderRadius:BorderRadius.circular(8)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(e.$1,style:_t12),const Spacer(),Text(e.$2,style:const TextStyle(fontFamily:'Sora',fontSize:17,fontWeight:FontWeight.w700,color:AppColors.primary))]))).toList());}
class _PersonRow extends StatelessWidget{const _PersonRow(this.name,this.date,this.status);final String name,date,status;@override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.symmetric(vertical:11),decoration:const BoxDecoration(border:Border(bottom:BorderSide(color:Color(0xFFF2F3F7)))),child:Row(children:[CircleAvatar(radius:18,backgroundColor:const Color(0xFFEAF2FF),child:Text(name.split(' ').map((e)=>e[0]).take(2).join(),style:const TextStyle(fontFamily:'Sora',fontSize:10,color:AppColors.primary))),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(name,style:_t14b),Text(date,style:_t12)])),_Pill(status)]));}
class _ActivityRow extends StatelessWidget{const _ActivityRow(this.t,this.v);final String t,v;@override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.symmetric(vertical:12),decoration:const BoxDecoration(border:Border(bottom:BorderSide(color:Color(0xFFF2F3F7)))),child:Row(children:[const CircleAvatar(radius:18,backgroundColor:Color(0xFFEAF2FF),child:Icon(Icons.card_giftcard,size:17,color:AppColors.primary)),const SizedBox(width:10),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(t,style:_t14b),const Text('Oct 24, 2023 • 14:32',style:_t12)])),Text(v,style:const TextStyle(fontFamily:'Sora',fontSize:12,color:Color(0xFF1FAF5A),fontWeight:FontWeight.w600))]));}
class _QuickAction extends StatelessWidget{const _QuickAction(this.i,this.t,this.tap);final IconData i;final String t;final VoidCallback tap;@override Widget build(BuildContext context)=>InkWell(onTap:tap,child:Column(children:[CircleAvatar(radius:20,backgroundColor:const Color(0xFFEAF2FF),child:Icon(i,size:18,color:AppColors.primary)),const SizedBox(height:6),Text(t,textAlign:TextAlign.center,style:const TextStyle(fontFamily:'Sora',fontSize:9,color:AppColors.body))]));}
class _Podium extends StatelessWidget{const _Podium(this.rank,this.name,this.refs,this.h);final String rank,name,refs;final double h;@override Widget build(BuildContext context)=>Column(children:[CircleAvatar(radius:rank=='1'?40:32,backgroundImage:const AssetImage(_avatar)),const SizedBox(height:6),Text(name,style:_t12b),Text(refs,style:const TextStyle(fontFamily:'Sora',fontSize:9,color:AppColors.primary)),const SizedBox(height:7),Container(width:84,height:h,alignment:Alignment.topCenter,padding:const EdgeInsets.only(top:10),decoration:BoxDecoration(color:rank=='1'?AppColors.primary:const Color(0xFFEAF2FF),borderRadius:const BorderRadius.vertical(top:Radius.circular(6))),child:Text(rank,style:TextStyle(fontFamily:'Sora',fontSize:18,fontWeight:FontWeight.w700,color:rank=='1'?Colors.white:AppColors.primary))) ]);}
class _RankRow extends StatelessWidget{const _RankRow(this.rank,this.name,this.school,this.refs);final int rank;final String name,school,refs;@override Widget build(BuildContext context)=>Container(height:66,decoration:const BoxDecoration(border:Border(bottom:BorderSide(color:Color(0xFFF2F3F7)))),child:Row(children:[SizedBox(width:34,child:Text(rank.toString().padLeft(2,'0'),style:_t12)),const CircleAvatar(radius:18,backgroundImage:AssetImage(_avatar)),const SizedBox(width:10),Expanded(child:Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.start,children:[Text(name,style:_t12b),Text(school,overflow:TextOverflow.ellipsis,style:const TextStyle(fontFamily:'Sora',fontSize:9,color:Color(0xFF8D8D8D)))])),Text('$refs\nReferrals',textAlign:TextAlign.right,style:const TextStyle(fontFamily:'Sora',fontSize:9,color:AppColors.body))]));}
class _HelpCategory extends StatelessWidget{const _HelpCategory(this.t,this.s,this.c);final String t,s,c;@override Widget build(BuildContext context)=>ExpansionTile(tilePadding:EdgeInsets.zero,childrenPadding:const EdgeInsets.only(bottom:12),title:Text(t,style:_t14b),subtitle:Text(s,maxLines:2,overflow:TextOverflow.ellipsis,style:_t12),trailing:Column(mainAxisAlignment:MainAxisAlignment.center,children:[const Icon(Icons.chevron_right,size:18),Text(c,style:const TextStyle(fontFamily:'Sora',fontSize:9,color:AppColors.primary))]),children:[Align(alignment:Alignment.centerLeft,child:Text(s,style:_t12))]);}

const _helpCats=<(String,String,String)>[
('Getting Started','Everything you need to create your Davopay account, verify your identity, and start using the app.','10 Articles'),('Wallets & Balances','Learn how your NGN Wallet, USD Wallet, and other balances work, including funding and withdrawals.','12 Articles'),('Crypto Trading','Everything about buying, selling, depositing, withdrawing, and managing cryptocurrency on Davopay.','15 Articles'),('Gift Card Trading','Learn how to sell gift cards, supported brands, trade processing times, and payment settlements.','14 Articles'),('Virtual Cards','Everything you need to know about creating, funding, freezing, and using your Davopay Virtual Card.','13 Articles'),('USD Accounts','Learn how to create your USD account, receive international payments, and manage your USD balance.','11 Articles'),('Send Money','Learn how to transfer money to Nigerian bank accounts, other Davopay users, and supported destinations.','9 Articles'),('Receive Money','Everything about receiving payments into your NGN wallet, USD account, and crypto wallets.','8 Articles'),('Bill Payments','Learn how to pay for airtime, data, electricity, cable TV, betting, and other utility bills.','9 Articles'),('Rewards & Referrals','Everything about inviting friends, earning referral rewards, campaign bonuses, and reward withdrawals.','7 Articles'),('Fees & Transaction Limits','Understand transaction fees, withdrawal fees, trading fees, spending limits, and account limits.','8 Articles'),('Verification (KYC)','Everything about identity verification, accepted documents, verification levels, and account limits.','10 Articles'),('Security & Account Protection','Learn how to secure your account, reset your password, manage your PIN, enable biometrics, and report suspicious activity.','12 Articles'),('Transactions & Receipts','Understand transaction statuses, download receipts, track transfers, and resolve failed transactions.','9 Articles'),('Promotions & Campaigns','Stay informed about cashback offers, referral campaigns, seasonal promotions, and eligibility requirements.','6 Articles'),('Troubleshooting','Solutions for common issues such as login problems, OTP delays, failed payments, app performance, and wallet errors.','15 Articles'),('Contact Support','Find out how to reach the Davopay support team through live chat, email, or by submitting a support ticket.','5 Articles'),('Legal & Compliance',"Read Davopay's Terms of Service, Privacy Policy, AML policy, prohibited transactions, and regulatory compliance information.",'8 Articles')];
const _people=<(String,String,String)>[('Jane Doe','Oct 24, 2023 • 14:32','Rewarded'),('Marcus Kane','Oct 24, 2023 • 14:32','Pending'),('Sarah Lim','Oct 24, 2023 • 14:32','Pending'),('Elena Rodriguez','Oct 24, 2023 • 14:32','Rewarded'),('Julian Smith','Oct 24, 2023 • 14:32','Pending'),('Lila Vance','Oct 24, 2023 • 14:32','Pending'),('Marcus Thorne','Oct 24, 2023 • 14:32','Rewarded')];
const _rankings=<(String,String,String)>[('Jordan Smith','University of Nigeria Nsukka','32'),('Elena Rodriguez','Obafemi Awolowo University','30'),('Confidence Malik','University of Abuja','28'),('Samuel Meshack','Enugu State University','25'),('ELite Divine','Oko Poly','22'),('Chidera Favour','Akanu Ibiam Federal Poly','20'),('Success Chidinma','Akanu Ibiam Federal Poly','18')];

Future<void> _push(BuildContext c,Widget w)=>pushAppPage<void>(c,(_)=>w);
void _snack(BuildContext c,String s)=>ScaffoldMessenger.of(c).showSnackBar(SnackBar(content:Text(s),behavior:SnackBarBehavior.floating));
void _simple(BuildContext c,String title)=>_push(c,_Shell(title:title,child:Center(child:Text('$title\nDavochain',textAlign:TextAlign.center,style:_t16b))));
Future<void> _uploadSheet(BuildContext context,String title)=>showModalBottomSheet(context:context,showDragHandle:true,builder:(c)=>SafeArea(child:Padding(padding:const EdgeInsets.fromLTRB(16,0,16,20),child:Column(mainAxisSize:MainAxisSize.min,children:[Align(alignment:Alignment.centerLeft,child:Text(title,style:_t16b)),const SizedBox(height:18),_PrimaryButton('Take a Photo',onTap:()=>Navigator.pop(c)),const SizedBox(height:10),OutlinedButton(onPressed:()=>Navigator.pop(c),style:OutlinedButton.styleFrom(minimumSize:const Size.fromHeight(48),side:const BorderSide(color:AppColors.primary)),child:const Text('Choose From Gallery'))]))));
Future<void> _socialDialog(BuildContext c,String s)=>showDialog(context:c,builder:(d)=>AlertDialog(content:Text('“Davopay” Wants to open “$s”',textAlign:TextAlign.center,style:_t14),actionsAlignment:MainAxisAlignment.spaceEvenly,actions:[TextButton(onPressed:()=>Navigator.pop(d),child:const Text('Cancel')),TextButton(onPressed:()=>Navigator.pop(d),child:const Text('Open'))]));
Future<void> _logoutDialog(BuildContext c)=>showDialog(context:c,builder:(d)=>AlertDialog(title:const Text('Logout'),content:const Text('Are you sure you want to logout?'),actions:[TextButton(onPressed:()=>Navigator.pop(d),child:const Text('Cancel')),TextButton(onPressed:()=>Navigator.pop(d),child:const Text('Logout',style:TextStyle(color:Color(0xFFF44336))))]));
Future<void> _themeSheet(BuildContext c)=>showModalBottomSheet(context:c,builder:(x)=>SafeArea(child:Padding(padding:const EdgeInsets.all(18),child:Column(mainAxisSize:MainAxisSize.min,crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('Theme',style:_t20),const SizedBox(height:12),ListTile(leading:const Icon(Icons.light_mode_outlined),title:const Text('Light'),trailing:const Icon(Icons.check,color:AppColors.primary),onTap:()=>Navigator.pop(x)),ListTile(leading:const Icon(Icons.dark_mode_outlined),title:const Text('Dark'),onTap:()=>Navigator.pop(x))]))));

const _t24b=TextStyle(fontFamily:'Sora',fontSize:24,fontWeight:FontWeight.w700,color:AppColors.ink,height:1.35);
const _t20=TextStyle(fontFamily:'Sora',fontSize:20,fontWeight:FontWeight.w400,color:AppColors.ink,height:1.35);
const _t16b=TextStyle(fontFamily:'Sora',fontSize:16,fontWeight:FontWeight.w600,color:AppColors.ink,height:1.35);
const _t14=TextStyle(fontFamily:'Sora',fontSize:14,fontWeight:FontWeight.w400,color:AppColors.body,height:1.35);
const _t14m=TextStyle(fontFamily:'Sora',fontSize:14,fontWeight:FontWeight.w500,color:AppColors.body,height:1.35);
const _t14b=TextStyle(fontFamily:'Sora',fontSize:14,fontWeight:FontWeight.w600,color:AppColors.ink,height:1.35);
const _t12=TextStyle(fontFamily:'Sora',fontSize:12,fontWeight:FontWeight.w400,color:Color(0xFF686868),height:1.35);
const _t12b=TextStyle(fontFamily:'Sora',fontSize:12,fontWeight:FontWeight.w600,color:AppColors.ink,height:1.35);
const _cap=TextStyle(fontFamily:'Sora',fontSize:11,fontWeight:FontWeight.w600,color:Color(0xFF686868),letterSpacing:.4);
