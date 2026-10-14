part of 'profile_settings_flow.dart';

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
            Text('Chat', style: _t16b(context)),
            const SizedBox(height: 16),
            _supportTile(
                context,
                '$_exactAssets/icon_chat.png',
                'Live Chat',
                'Start a conversation on live chat',
                () => _push(context, const SupportHubScreen())),
            const SizedBox(height: 16),
            _supportTile(
                context,
                '$_exactAssets/icon_email.png',
                'Email',
                'We aim to respond in a day',
                () => _push(context, const EmailSupportScreen())),
            const SizedBox(height: 16),
            _supportTile(
                context,
                '$_exactAssets/icon_request.png',
                'Submit a Request',
                'Tell us what went wrong',
                () => _push(context, const EmailSupportScreen())),
            const SizedBox(height: 36),
            Text('Social Media', style: _t16b(context)),
            const SizedBox(height: 16),
            _supportTile(context, '$_exactAssets/icon_instagram.png',
                'Instagram', '', () => _socialDialog(context, 'Instagram')),
            const SizedBox(height: 16),
            _supportTile(context, '$_exactAssets/icon_linkedin.png', 'Linkedln',
                '', () => _socialDialog(context, 'Linkedln')),
            const SizedBox(height: 16),
            _supportTile(context, '$_exactAssets/icon_twitter.png', 'Twitter',
                '', () => _socialDialog(context, 'X')),
            const SizedBox(height: 28),
          ],
        ),
      );
}

class SupportHubScreen extends StatelessWidget {
  const SupportHubScreen({super.key});
  @override
  Widget build(BuildContext context) => AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
          systemNavigationBarColor: DavoColors.of(context).offWhite,
          systemNavigationBarIconBrightness:
              Theme.of(context).brightness == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark),
      child: Scaffold(
          backgroundColor: DavoColors.of(context).offWhite,
          body: SafeArea(
              child: SingleChildScrollView(
                  child: Column(children: [
            Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                decoration: const BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF1260FF), Color(0xFF3B7CFF)]),
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(14))),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        const DavochainLogoLockup(
                            logoColor: Colors.white,
                            logoWidth: 28,
                            fontSize: 20),
                        const Spacer(),
                        InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                                width: 24,
                                height: 24,
                                alignment: Alignment.center,
                                color: Colors.white12,
                                child: Image.asset(
                                    '$_exactAssets/icon_close.png',
                                    color: Colors.white,
                                    width: 18,
                                    height: 18)))
                      ]),
                      const SizedBox(height: 28),
                      const _LocalProfileGreeting(
                          prefix: 'Hi ',
                          suffix: ' \u{1f44b}\nHow can we help?',
                          style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.35)),
                      const SizedBox(height: 22),
                      Container(
                          decoration: BoxDecoration(
                              color: DavoColors.of(context).surface,
                              borderRadius: BorderRadius.circular(7)),
                          child: Column(children: [
                            _HubAssetRow(
                                'Messages', '$_exactAssets/icon_message.png',
                                onTap: () => _push(
                                    context, const SupportMessagesScreen())),
                            const Divider(height: 1),
                            _HubAssetRow('Help', '$_exactAssets/icon_help.png',
                                onTap: () =>
                                    _push(context, const HelpCenterScreen()))
                          ])),
                      const SizedBox(height: 10),
                      InkWell(
                          onTap: () =>
                              _push(context, const SupportMessagesScreen()),
                          child: Container(
                              height: 38,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                  color: DavoColors.of(context).surface,
                                  borderRadius: BorderRadius.circular(7)),
                              child: Row(children: [
                                Expanded(
                                    child: Text('Send us a messages',
                                        style: TextStyle(
                                            fontFamily: 'Sora',
                                            fontSize: 10,
                                            color:
                                                DavoColors.of(context).body))),
                                Image.asset('$_exactAssets/icon_send.png',
                                    width: 16, height: 16)
                              ]))),
                      const SizedBox(height: 10),
                      Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                              color: DavoColors.of(context).surface,
                              borderRadius: BorderRadius.circular(7)),
                          child: Column(
                              children: [
                            'Explore Rewards: Key Details You Should Know',
                            'Unlock More Earnings with Every Referral',
                            'Everything You Need to Know About Your Virtual Dollar Card',
                            'Join Our community Channel'
                          ]
                                  .map((t) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 5),
                                      child: Row(children: [
                                        Expanded(
                                            child: Text(t,
                                                style: TextStyle(
                                                    fontFamily: 'Sora',
                                                    fontSize: 9,
                                                    color:
                                                        DavoColors.of(context)
                                                            .body))),
                                        Image.asset(
                                            '$_exactAssets/icon_external_link.png',
                                            color: DavoColors.of(context).body,
                                            width: 11,
                                            height: 11)
                                      ])))
                                  .toList()))
                    ])),
            Padding(
                padding: const EdgeInsets.all(12),
                child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: DavoColors.of(context).surface,
                        borderRadius: BorderRadius.circular(7)),
                    child: Column(children: [
                      Container(
                          height: 30,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              color: DavoColors.of(context).fieldFill,
                              borderRadius: BorderRadius.circular(4)),
                          child: Row(children: [
                            const Expanded(
                                child: Text('Search for help',
                                    style: TextStyle(
                                        fontFamily: 'Sora', fontSize: 9))),
                            Image.asset('$_exactAssets/icon_search.png',
                                color: DavoColors.of(context).body,
                                width: 14,
                                height: 14)
                          ])),
                      ...[
                        'Receiving International Payments with Davochain',
                        'About Your USD Account',
                        'Verifying your Davochain Account: Step-by-Step Guide',
                        'Bank Accounts Deposit Charges on Davochain',
                        'How do I Buy/Sell Gift Card On Davochain',
                        'How do I Crypto Assets On Davochain'
                      ].map((t) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(children: [
                            Expanded(
                                child: Text(t,
                                    style: TextStyle(
                                        fontFamily: 'Sora',
                                        fontSize: 9,
                                        color: DavoColors.of(context).body))),
                            Image.asset('$_exactAssets/icon_arrow_right.png',
                                color: DavoColors.of(context).body,
                                width: 14,
                                height: 14)
                          ])))
                    ])))
          ])))));
}

Widget _supportTile(BuildContext context, String asset, String title,
    String subtitle, VoidCallback tap) {
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
            Image.asset(asset,
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: _t14b(context)),
                  if (hasSubtitle) ...[
                    const SizedBox(height: 4),
                    Text(subtitle, style: _t12(context)),
                  ],
                ],
              ),
            ),
            Image.asset('$_exactAssets/icon_arrow_right.png',
                color: DavoColors.of(context).body,
                width: 24,
                height: 24,
                filterQuality: FilterQuality.high),
          ],
        ),
      ),
    ),
  );
}

class _HubAssetRow extends StatelessWidget {
  const _HubAssetRow(this.text, this.asset, {required this.onTap});
  final String text, asset;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      child: SizedBox(
          height: 32,
          child: Row(children: [
            const SizedBox(width: 10),
            Expanded(
                child: Text(text,
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 10,
                        color: DavoColors.of(context).body))),
            Image.asset(asset,
                width: 14, height: 14, filterQuality: FilterQuality.high),
            const SizedBox(width: 10)
          ])));
}

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});
  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final q = TextEditingController();
  @override
  void dispose() {
    q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cats = _helpCats
        .where((e) => e.$1.toLowerCase().contains(q.text.toLowerCase()))
        .toList();
    return _Shell(
        title: 'Help',
        titleStyle: _navSora16SemiBold(context),
        scroll: true,
        child: Column(children: [
          TextField(
              keyboardAppearance: Theme.of(context).brightness,
              controller: q,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                  hintText: 'Search for help',
                  prefixIcon: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Image.asset('$_exactAssets/icon_search.png',
                          color: DavoColors.of(context).body,
                          width: 16,
                          height: 16,
                          filterQuality: FilterQuality.high)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)))),
          const SizedBox(height: 16),
          ...cats.map((e) => _HelpCategory(e.$1, e.$2, e.$3)),
          const SizedBox(height: 30)
        ]));
  }
}

// ---- Rewards / Ambassador ----
class ReferralDashboardScreen extends StatelessWidget {
  const ReferralDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => _Shell(
      title: 'Rewards',
      titleStyle: _navSora16Medium(context),
      scroll: true,
      child: Column(children: [
        Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8)),
            child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Referral Program',
                      style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 12,
                          color: Colors.white70)),
                  SizedBox(height: 10),
                  Text('Earn ₦2,000 For\nevery friend Referred',
                      style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          height: 1.25)),
                  SizedBox(height: 8),
                  Text(
                      'Invite your friends to Davochain and get rewarded when they make their first successful transaction.',
                      style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 12,
                          color: Colors.white,
                          height: 1.4))
                ])),
        const SizedBox(height: 18),
        _referralBox(context),
        const SizedBox(height: 18),
        _sectionLink(context, 'Manage your earnings', 'Referral Analytics',
            () => _push(context, const ReferralAnalyticsScreen())),
        const SizedBox(height: 18),
        _PrimaryButton('Davo Points',
            onTap: () => _push(context, const DavoPointsScreen())),
        const SizedBox(height: 22),
        const _HowItWorks(),
        const SizedBox(height: 30)
      ]));
}

class ReferralAnalyticsScreen extends StatelessWidget {
  const ReferralAnalyticsScreen({super.key});
  @override
  Widget build(BuildContext context) => _Shell(
      title: '',
      scroll: true,
      bodyTopPadding: 12,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Performance Hub',
            style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: DavoColors.of(context).link,
                height: 1.35)),
        const SizedBox(height: 8),
        Text('Referral Analytics', style: _navSora20(context)),
        const SizedBox(height: 18),
        const _StatsGrid([
          ('My invitees', '128'),
          ('Rewarded', '84'),
          ('KYC Done', '53'),
          ('Deposited', '34')
        ]),
        const SizedBox(height: 20),
        Text('Manage your earnings:', style: _t14m(context)),
        const SizedBox(height: 10),
        _PrimaryButton('Rewards',
            onTap: () => _push(context, const DavoPointsScreen())),
        const SizedBox(height: 22),
        Text('Referrals', style: _t16b(context)),
        const SizedBox(height: 4),
        Text('Track your network and earned rewards.', style: _t12(context)),
        const SizedBox(height: 14),
        ..._people.map((e) => _PersonRow(e.$1, e.$2, e.$3)),
        const SizedBox(height: 28)
      ]));
}

class StudentAmbassadorScreen extends StatefulWidget {
  const StudentAmbassadorScreen({super.key});
  @override
  State<StudentAmbassadorScreen> createState() =>
      _StudentAmbassadorScreenState();
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
    final enabled = school.text.trim().isNotEmpty &&
        studentId.text.trim().isNotEmpty &&
        uploaded;
    return _Shell(
      title: '',
      bodyTopPadding: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Student Ambassador Details', style: _t20(context)),
          const SizedBox(height: 24),
          _Input(
              label: 'School Name',
              hint: 'Enter your school name',
              controller: school,
              figmaFilled: true),
          const SizedBox(height: 16),
          _Input(
              label: 'Student ID no',
              hint: 'Enter your student ID No',
              controller: studentId,
              figmaFilled: true),
          const SizedBox(height: 16),
          Text('Upload Student ID', style: _t14m(context)),
          const SizedBox(height: 7),
          OutlinedButton.icon(
            onPressed: () => setState(() => uploaded = true),
            icon: Image.asset(
              uploaded
                  ? '$_exactAssets/icon_check.png'
                  : '$_exactAssets/icon_upload.png',
              width: 20,
              height: 20,
              filterQuality: FilterQuality.high,
            ),
            label: Text(uploaded ? 'Student ID uploaded' : 'Upload Student ID'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              side: BorderSide(color: DavoColors.of(context).border),
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

class AmbassadorDashboardScreen extends StatelessWidget {
  const AmbassadorDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => _Shell(
      title: '',
      scroll: true,
      bodyTopPadding: 8,
      child: Column(children: [
        Row(children: [
          const LocalProfileAvatar(size: 40),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                _LocalProfileGreeting(
                    prefix: 'Hi, ',
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: DavoColors.of(context).link,
                        height: 1.35)),
                Text('Ambassador',
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: DavoColors.of(context).link,
                        height: 1.35))
              ])),
          IconButton(
              onPressed: () {},
              icon: Image.asset('$_exactAssets/icon_notification_bell.png',
                  color: DavoColors.of(context).body, width: 22, height: 22))
        ]),
        const SizedBox(height: 14),
        Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10)),
            child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ambassador Program',
                      style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  SizedBox(height: 4),
                  Text(
                      'Empower your campus. Refer friends and earn rewards for every successful signup.',
                      style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 11,
                          color: Colors.white)),
                  SizedBox(height: 14),
                  Text('Silver Ambassador                         18/25',
                      style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 12,
                          color: Colors.white)),
                  SizedBox(height: 6),
                  LinearProgressIndicator(
                      value: .72,
                      minHeight: 7,
                      backgroundColor: Colors.white24,
                      valueColor: AlwaysStoppedAnimation(Colors.white)),
                  SizedBox(height: 5),
                  Text('7 more referrals to unlock Gold Tier',
                      style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 10,
                          color: Colors.white70))
                ])),
        const SizedBox(height: 18),
        _referralBox(context),
        const SizedBox(height: 18),
        const _StatsGrid([
          ('Students Referred', '345'),
          ('Students Verified', '205'),
          ('Pending', '140'),
          ('Earned', 'Đ400.00')
        ]),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(
              child: _QuickAssetAction(
                  '$_exactAssets/icon_share.png', 'Share Link', () {})),
          Expanded(
              child: _QuickAssetAction(
                  '$_exactAssets/icon_qr.png', 'QR Code', () {})),
          Expanded(
              child: _QuickAssetAction('$_exactAssets/icon_trophy.png',
                  'Rewards', () => _push(context, const DavoPointsScreen()))),
          Expanded(
              child: _QuickAssetAction(
                  '$_exactAssets/icon_leaderboard.png',
                  'Leaderboard',
                  () => _push(context, const AmbassadorLeaderboardScreen())))
        ]),
        const SizedBox(height: 22),
        Align(
            alignment: Alignment.centerLeft,
            child: Text('Referrals', style: _t16b(context))),
        const SizedBox(height: 8),
        ..._people.take(4).map((e) => _PersonRow(e.$1, e.$2, e.$3)),
        const SizedBox(height: 24)
      ]));
}

class AmbassadorLeaderboardScreen extends StatelessWidget {
  const AmbassadorLeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Ambassador Leaderboard',
        titleStyle: _navSora16(context),
        scroll: true,
        child: Column(
          children: [
            const SizedBox(height: 42),
            const SizedBox(
              height: 333,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                      left: 0,
                      top: 76,
                      child: _Podium('2', 'Sarah L.', '42 Refs', 93)),
                  Positioned(
                      left: 120,
                      top: 0,
                      child: _Podium('1', 'James P.', '145 Referrals', 130)),
                  Positioned(
                      right: 4,
                      top: 89,
                      child: _Podium('3', 'Mila K.', '39 Refs', 80)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Text('Rankings 1-10', style: _t16b(context)),
                const Spacer(),
                Text('Total 124 Active', style: _t14(context)),
              ],
            ),
            const SizedBox(height: 16),
            ..._rankings.asMap().entries.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child:
                      _RankRow(e.key + 4, e.value.$1, e.value.$2, e.value.$3),
                )),
            const SizedBox(height: 24),
            const _CurrentRankCard(),
            const SizedBox(height: 26),
          ],
        ),
      );
}

// ---- Figma 3418:85446 exact Profile/Settings flows ----
