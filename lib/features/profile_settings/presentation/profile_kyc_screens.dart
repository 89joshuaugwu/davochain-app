part of 'profile_settings_flow.dart';

class PersonalInformationSuccessScreen extends StatelessWidget {
  const PersonalInformationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: DavoColors.of(context).surface,
        appBar: AppBar(
            backgroundColor: DavoColors.of(context).surface,
            surfaceTintColor: DavoColors.of(context).surface,
            leading: const BackButton()),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 64),
                        DavoOutcomeContent(
                            tempo: DavoOutcomeTempo.compact,
                            size: 112,
                            semanticLabel:
                                'Personal information updated successfully',
                            heading: Column(children: [
                              Text('Information Updated',
                                  style: _t20sb(context),
                                  textAlign: TextAlign.center),
                              const SizedBox(height: 8),
                              Text(
                                  'Your personal information has been updated successfully',
                                  style: _t14(context),
                                  textAlign: TextAlign.center)
                            ])),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                _PrimaryButton('Done',
                    onTap: () => Navigator.of(context)
                        .popUntil((route) => route.isFirst)),
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
      titleStyle: _navSora16(context),
      scroll: true,
      bodyTopPadding: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            'Complete verification to increase your limits and enjoy all Davochain features',
            style: _t16b(context),
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
            (
              '$_exactAssets/kyc_req_user_exact.png',
              'Your face clearly visible'
            ),
          ]
        : tier == 2
            ? const [
                (
                  '$_exactAssets/kyc_req_id_exact.png',
                  'Valid Nigerian BVN (11 digits)'
                ),
                (
                  '$_exactAssets/kyc_req_phone_exact.png',
                  'Your registered phone number'
                ),
                (
                  '$_exactAssets/kyc_req_user_pin_exact.png',
                  'Must match your personal details'
                ),
              ]
            : const [
                ('$_exactAssets/kyc_req_id_exact.png', 'Government-issued ID'),
                (
                  '$_exactAssets/kyc_req_document_exact.png',
                  'A valid proof of address document'
                ),
                (
                  '$_exactAssets/kyc_req_user_exact.png',
                  'Your face clearly visible'
                ),
              ];

    return _Shell(
      title: 'Verify Your Account',
      titleStyle: _navSora16(context),
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
              decoration: BoxDecoration(
                color: DavoColors.of(context).primarySoft,
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
                Text(title, style: _t16b(context)),
                const SizedBox(height: 8),
                Text(description, style: _t14(context)),
              ],
            ),
          ),
          const SizedBox(height: 44),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('What you need', style: _t16b(context)),
          ),
          const SizedBox(height: 24),
          ...requirements.asMap().entries.map(
                (entry) => Padding(
                  padding: EdgeInsets.only(
                      bottom: entry.key == requirements.length - 1 ? 0 : 16),
                  child: _KycRequirementLine(
                      asset: entry.value.$1, text: entry.value.$2),
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

class CompleteProfileV12Screen extends StatefulWidget {
  const CompleteProfileV12Screen({super.key});
  @override
  State<CompleteProfileV12Screen> createState() =>
      _CompleteProfileV12ScreenState();
}

class _CompleteProfileV12ScreenState extends State<CompleteProfileV12Screen> {
  final first = TextEditingController(),
      middle = TextEditingController(),
      last = TextEditingController(),
      dob = TextEditingController();
  @override
  void initState() {
    super.initState();
    final draft = VerificationSession.instance.profileDraft;
    first.text = draft['first'] ?? '';
    middle.text = draft['middle'] ?? '';
    last.text = draft['last'] ?? '';
    dob.text = draft['dob'] ?? '';
    for (final c in [first, middle, last, dob]) {
      c.addListener(_refresh);
    }
  }

  void _refresh() {
    VerificationSession.instance.saveProfile({
      'first': first.text,
      'middle': middle.text,
      'last': last.text,
      'dob': dob.text
    });
    setState(() {});
  }

  @override
  void dispose() {
    for (final c in [first, middle, last, dob]) {
      c.removeListener(_refresh);
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDavoDatePicker(context,
        title: 'Date of birth',
        firstDate: DateTime(1900),
        lastDate: DateTime(now.year, now.month, now.day),
        initialDate: DateTime.tryParse(dob.text) ?? DateTime(2000, 1, 1));
    if (mounted && date != null) {
      dob.text =
          '${date.year}-${date.month.toString().padLeft(2, "0")}-${date.day.toString().padLeft(2, "0")}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = [first, last, dob].every((c) => c.text.trim().isNotEmpty);
    return _Shell(
        title: 'Verify your Identity',
        titleStyle: _navSora16(context),
        bodyTopPadding: 0,
        scroll: true,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 39),
          Text('Complete your profile', style: _t16b(context)),
          const SizedBox(height: 8),
          Text(
              'Fill in your personal information to get started with verification',
              style: _t14(context)),
          const SizedBox(height: 24),
          _Input(
              label: 'First name',
              hint: 'Enter first name',
              controller: first,
              figmaFilled: true,
              labelSize: 16,
              hintSize: 12),
          const SizedBox(height: 24),
          _Input(
              label: 'Middle name (optional)',
              hint: 'Enter middle name',
              controller: middle,
              figmaFilled: true,
              labelSize: 16,
              hintSize: 12),
          const SizedBox(height: 22),
          _Input(
              label: 'Last name',
              hint: 'Enter last name',
              controller: last,
              figmaFilled: true,
              labelSize: 16,
              hintSize: 12),
          const SizedBox(height: 24),
          Semantics(
              label: dob.text.isEmpty
                  ? 'Select date of birth'
                  : 'Date of birth, ${dob.text}',
              button: true,
              excludeSemantics: true,
              onTap: _pickDate,
              child: InkWell(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                      child: _Input(
                          label: 'Date of birth',
                          hint: 'Select date of birth',
                          controller: dob,
                          figmaFilled: true,
                          labelSize: 16,
                          hintSize: 12)))),
          const SizedBox(height: 32),
          TextButton(
              onPressed: () => showSettingsContent(context, 'Privacy Policy'),
              child: const Text('Read Privacy Policy')),
          _PrimaryButton('Continue',
              enabled: enabled,
              onTap: () =>
                  _push(context, const CompleteProfileContactV12Screen())),
          const SizedBox(height: 28)
        ]));
  }
}

class CompleteProfileContactV12Screen extends StatefulWidget {
  const CompleteProfileContactV12Screen({super.key});
  @override
  State<CompleteProfileContactV12Screen> createState() =>
      _CompleteProfileContactV12ScreenState();
}

class _CompleteProfileContactV12ScreenState
    extends State<CompleteProfileContactV12Screen> {
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

  void _refresh() {
    VerificationSession.instance.saveProfile(
        {'phone': phone.text, 'address': address.text, 'state': state.text});
    setState(() {});
  }

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
    final enabled = RegExp(r'^[1-9]\d{9}$').hasMatch(phone.text.trim()) &&
        address.text.trim().isNotEmpty &&
        state.text.trim().isNotEmpty;
    return _Shell(
      title: 'Verify your Identity',
      scroll: true,
      titleStyle: _navSora16(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 27),
          _ContactPhoneField(controller: phone),
          const SizedBox(height: 24),
          _ContactAddressField(controller: address),
          const SizedBox(height: 24),
          Text('State', style: _t16(context)),
          const SizedBox(height: 8),
          DavoStatePicker(
            value: state.text.isEmpty ? null : state.text,
            states: _nigerianStates,
            onChanged: (value) => state.text = value,
          ),
          const SizedBox(height: 24),
          const _CountryField(),
          const SizedBox(height: 28),
          TextButton(
              onPressed: () => showSettingsContent(context, 'Privacy Policy'),
              child: const Text('Read Privacy Policy')),
          _PrimaryButton(
            'Continue',
            enabled: enabled,
            onTap: () {
              VerificationSession.instance.completeProfile();
              _push(context, const BasicIdentityChoiceScreen());
            },
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
      titleStyle: _navSora16(context),
      bodyTopPadding: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 39),
          Text(
            'We need your Bank Verification Number\n(BVN) to secure your account.',
            style: _t16m(context),
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
            body:
                'We use your BVN to verify your identity and ensure that your account is secure. This does not mean that we will be able to access your bank account.',
          ),
          const Spacer(),
          _PrimaryButton(
            'Continue',
            enabled: enabled,
            onTap: () => _push(
              context,
              const VerificationProcessingV12Screen(
                title: 'Verifying your BVN',
                body:
                    'This may take a few seconds\nPlease do not leave this page',
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
      titleStyle: _navSora16(context),
      bodyTopPadding: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 31),
          Text(
            'We need your National Identification Number (NIN) to secure your account.',
            style: _t16m(context),
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
            body:
                'Your NIN is securely processed with the National Identity Management Commission (NIMC)',
          ),
          const Spacer(),
          _PrimaryButton(
            'Continue',
            enabled: enabled,
            onTap: () => _push(
              context,
              const VerificationProcessingV12Screen(
                title: 'Verifying your NIN',
                body:
                    'We’re retrieving your identity infomation\nfrom NIMC. This may take a few seconds',
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
  State<VerificationProcessingV12Screen> createState() =>
      _VerificationProcessingV12ScreenState();
}

class _VerificationProcessingV12ScreenState
    extends State<VerificationProcessingV12Screen> {
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
      titleStyle: _navSora16(context),
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
            child: Text(widget.title,
                style: _t20sb(context), textAlign: TextAlign.center),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: tier3 ? 328 : 294,
            child: Text(widget.body,
                style: _t14(context), textAlign: TextAlign.center),
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
        ? 'Your NIN verification is complete. Continue to the next verification tier.'
        : 'Your BVN verification is complete. Continue to the next verification tier.';
    final next = tier == 1 ? 'Continue to Tier 2' : 'Continue to Tier 3';
    return DavoResultScreen(
      title: title,
      message: body,
      mark: const DavoSuccessMark(
          tempo: DavoOutcomeTempo.compact,
          size: 150,
          semanticLabel: 'Verification complete'),
      details: _CurrentTierCard(tier: tier),
      actions: Column(mainAxisSize: MainAxisSize.min, children: [
        _PrimaryButton(next,
            onTap: () =>
                _push(context, KycTierOverviewScreen(completedTier: tier))),
        const SizedBox(height: 12),
        TextButton(
            onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            child: const Text('Maybe Later')),
      ]),
    );
  }
}

class KycSelfieV12Screen extends StatelessWidget {
  const KycSelfieV12Screen({super.key});

  @override
  Widget build(BuildContext context) => _Shell(
        title: 'KYC Verification',
        titleStyle: _navSora20Medium(context),
        bodyTopPadding: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text('Take a selfie', style: _t20sb(context)),
            const SizedBox(height: 8),
            Text(
              'Make sure your face is well-lit and fits inside\nthe frame for verification.',
              style: _t14(context),
            ),
            const SizedBox(height: 40),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(
                  'assets/figma_exact/verification_95bf2.png',
                  width: 171,
                  height: 171,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: SizedBox(
                width: 330,
                child: Text(
                  'To ensure the security of your account and comply with regulatory requirements, we need to verify your identity.',
                  style: _t14(context),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 28),
              child: SizedBox(
                width: 330,
                child: Text(
                    'take a photo of your face to complete this process.',
                    style: _t14(context)),
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

class _FaceDetectionV12ScreenState extends State<FaceDetectionV12Screen>
    with SingleTickerProviderStateMixin {
  late final AnimationController c;

  @override
  void initState() {
    super.initState();
    c = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Face Verification',
        titleStyle: _navSora16(context),
        bodyTopPadding: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text('Live face detection', style: _t20sb(context)),
            const SizedBox(height: 8),
            Text('Scan your face to verify your identity',
                style: _t14(context)),
            const SizedBox(height: 62),
            Center(
              child: GestureDetector(
                onTap: () => _push(context, const FaceReviewV12Screen()),
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    color: DavoColors.of(context).ink,
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
                          child:
                              Container(height: 1.5, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: Text('Place your head within the frame',
                  style: _t16(context), textAlign: TextAlign.center),
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
        titleStyle: _navSora16(context),
        bodyTopPadding: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text('Review your photo', style: _t20sb(context)),
            const SizedBox(height: 8),
            Text('make sure your face is clear before you submit.',
                style: _t14(context)),
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
            Text('Check that:', style: _t16b(context)),
            const SizedBox(height: 20),
            const _FaceStepLine('Your whole face is inside the  frame.'),
            const _FaceStepLine('Your photo is sharp and not blurry.'),
            const _FaceStepLine(
                'Nothing Covers your face (no glasses, hat,or mask)'),
            const Spacer(),
            _PrimaryButton(
              'Submit photo',
              onTap: () => _push(
                context,
                const VerificationProcessingV12Screen(
                  title: 'Matching your identity',
                  body:
                      'We’re comparing your live selfie with your\nNIN records. this may take a few seconds',
                  next: TierCompletionV12Screen(tier: 1),
                ),
              ),
            ),
            const SizedBox(height: 15),
            _SecondaryButton('Retake photo',
                onTap: () => Navigator.pop(context)),
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
        titleStyle: _navSora16(context),
        bodyTopPadding: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text('Select ID Type ', style: _t16b(context)),
            const SizedBox(height: 8),
            Text(
              'Verify your identity with a government issued ID to increase your limits',
              style: _t14(context),
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
            _PrimaryButton('Start',
                onTap: () => _push(context, const Tier3UploadIdScreen())),
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
        titleStyle: _navSora16(context),
        bodyTopPadding: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text('Upload your ID', style: _t16b(context)),
            const SizedBox(height: 8),
            Text('Provide a clear photo of your government issued ID',
                style: _t14(context)),
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
  State<Tier3SelectDocumentScreen> createState() =>
      _Tier3SelectDocumentScreenState();
}

class _Tier3SelectDocumentScreenState extends State<Tier3SelectDocumentScreen> {
  int selected = 0;

  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Verify Your Account',
        titleStyle: _navSora16(context),
        bodyTopPadding: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text('Select Docment Type ', style: _t16b(context)),
            const SizedBox(height: 8),
            Text('Choose the document you want to use for address verifcation',
                style: _t14(context)),
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
            _PrimaryButton('Continue',
                onTap: () => _push(context, const Tier3UploadDocumentScreen())),
            const SizedBox(height: 91),
          ],
        ),
      );
}

class Tier3UploadDocumentScreen extends StatefulWidget {
  const Tier3UploadDocumentScreen({super.key});
  @override
  State<Tier3UploadDocumentScreen> createState() =>
      _Tier3UploadDocumentScreenState();
}

class _Tier3UploadDocumentScreenState extends State<Tier3UploadDocumentScreen> {
  bool uploaded = false;

  @override
  Widget build(BuildContext context) => _Shell(
        title: 'Verify Your Account',
        titleStyle: _navSora16(context),
        bodyTopPadding: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text('Upload Document', style: _t16b(context)),
            const SizedBox(height: 24),
            _Tier3DocumentUploadCard(
              uploaded: uploaded,
              onTap: () => setState(() => uploaded = true),
            ),
            const SizedBox(height: 16),
            if (uploaded) ...[
              _UploadedDocumentFile(
                  onTap: () => setState(() => uploaded = false)),
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
        titleStyle: _navSora16(context),
        scroll: true,
        bodyTopPadding: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text('Upload Document', style: _t16b(context)),
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
                color: DavoColors.of(context).offWhite,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Address Details', style: _t14b(context)),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                                '$_exactAssets/profile_location_exact.png',
                                width: 20,
                                height: 20,
                                filterQuality: FilterQuality.high),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                  '12, Adeola Street, Victoria Island, Lagos\nNigeria.',
                                  style: _t12(context)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'Edit',
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: DavoColors.of(context).link,
                        height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 142),
            _PrimaryButton('Continue',
                onTap: () => _push(context, const Tier3FaceSubmitScreen())),
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
        titleStyle: _navSora16(context),
        bodyTopPadding: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text('Submit face', style: _t20sb(context)),
            const SizedBox(height: 8),
            Text('Does this look good to you?', style: _t14(context)),
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
            Text('Look straight at the camera', style: _t16b(context)),
            const SizedBox(height: 20),
            const _FaceStepLine('Turn your head left', done: true),
            const _FaceStepLine('Turn your head right'),
            const _FaceStepLine('Blink your eyes'),
            const Spacer(),
            _PrimaryButton(
              'Submit face',
              onTap: () =>
                  _push(context, const Tier3VerificationProcessingScreen()),
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
        body:
            'We are checking the ID and documents details\nThis may take a few minutes',
        next: FullyVerifiedV12Screen(),
      );
}

class FullyVerifiedV12Screen extends StatelessWidget {
  const FullyVerifiedV12Screen({super.key});
  @override
  Widget build(BuildContext context) => _StatusFullScreen(
        title: 'Your Account is Fully Verified',
        body:
            'You now have access to all Davochain features\nand higher limits',
        button: 'Back to Home',
        onTap: () {
          PreviewAccountState.setupComplete.value = true;
          Navigator.of(context).popUntil((r) => r.isFirst);
        },
      );
}
