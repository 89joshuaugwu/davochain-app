import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/navigation/app_page_route.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/motion/davo_outcome_content.dart';
import '../../../../shared/motion/davo_working_indicator.dart';
import '../profile_settings_flow.dart' show CompleteProfileV12Screen;
import 'advanced_verification_flow.dart';
import 'verification_components.dart';
import 'verification_state.dart';
export 'verification_components.dart' show VerificationPage, VerificationButton;

class VerificationOverviewScreen extends StatelessWidget {
  const VerificationOverviewScreen({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
      listenable: VerificationSession.instance,
      builder: (context, _) {
        final session = VerificationSession.instance;
        return VerificationPage(
            title: 'Verify Your Account',
            showPrivacyLink: true,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text(
                  'Complete verification to increase your limits and enjoy all Davochain features',
                  style: verificationHeading),
              const SizedBox(height: 28),
              VerificationChoiceRow(
                  title: 'Basic Verification',
                  subtitle: 'Profile information and BVN/NIN verification',
                  asset: session.basicVerified ? '4217e.svg' : '5a106.svg',
                  selected: !session.basicVerified,
                  completed: session.basicVerified,
                  onTap: () => pushAppPage<void>(
                      context,
                      (_) => session.basicVerified
                          ? const BasicVerificationSubmittedScreen(
                              animate: false)
                          : const BasicVerificationIntroScreen())),
              VerificationChoiceRow(
                  title: 'Advanced Verification',
                  subtitle: 'ID and Address Verification',
                  asset: '53681.svg',
                  selected: session.basicVerified && !session.advancedSubmitted,
                  completed: session.advancedSubmitted,
                  onTap: session.canStartAdvanced
                      ? () => pushAppPage<void>(context,
                          (_) => const AdvancedVerificationFlowScreen())
                      : null),
            ]));
      });
}

class BasicIdentityChoiceScreen extends StatefulWidget {
  const BasicIdentityChoiceScreen({super.key});
  @override
  State<BasicIdentityChoiceScreen> createState() => _BasicIdentityChoiceState();
}

class _BasicIdentityChoiceState extends State<BasicIdentityChoiceScreen> {
  BasicIdentityMethod selected =
      VerificationSession.instance.identityMethod ?? BasicIdentityMethod.bvn;
  @override
  Widget build(BuildContext context) => VerificationPage(
      title: 'Verify Your Account',
      showPrivacyLink: true,
      bottom: VerificationButton('Continue', onPressed: () {
        VerificationSession.instance.chooseIdentity(selected);
        pushAppPage<void>(
            context, (_) => BasicIdentityNumberScreen(method: selected));
      }),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Choose a verification method', style: verificationHeading),
        const SizedBox(height: 8),
        Text(
            'Select one of the options below to continue your account verification.',
            style: verificationBody.copyWith(
                color: DavoColors.of(context).bodyMuted)),
        const SizedBox(height: 24),
        for (final method in [BasicIdentityMethod.bvn, BasicIdentityMethod.nin])
          VerificationChoiceRow(
              title: '${method.shortLabel} Verification',
              subtitle: 'Verify using your ${method.fullLabel}.',
              radio: true,
              selected: selected == method,
              onTap: () => setState(() => selected = method)),
      ]));
}

class BasicVerificationIntroScreen extends StatelessWidget {
  const BasicVerificationIntroScreen({super.key});
  @override
  Widget build(BuildContext context) => VerificationPage(
      title: 'Verify Your Account',
      showPrivacyLink: true,
      bottom: VerificationButton('Start',
          onPressed: () => pushAppPage<void>(
              context, (_) => const CompleteProfileV12Screen())),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Center(
            child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: DavoColors.of(context).primarySoft),
                alignment: Alignment.center,
                child: const VerificationAsset('739f8.svg', size: 28))),
        const SizedBox(height: 24),
        const Text('Basic Verification',
            textAlign: TextAlign.center, style: verificationHeading),
        const SizedBox(height: 8),
        Text(
            'Complete your personal details and verify either your BVN or NIN to secure your account and increase your transaction limits.',
            textAlign: TextAlign.center,
            style:
                verificationBody.copyWith(color: DavoColors.of(context).body)),
        const SizedBox(height: 24),
        const VerificationRequirements(items: [
          ('e90f4.svg', 'Your BVN or NIN (11 digits)'),
          ('90d57.svg', 'Your registered phone number'),
          ('6cc71.svg', 'Personal details that match your BVN or NIN'),
        ]),
      ]));
}

class BasicIdentityNumberScreen extends StatefulWidget {
  const BasicIdentityNumberScreen(
      {super.key, required this.method, this.verify});
  final BasicIdentityMethod method;
  final Future<bool> Function(BasicIdentityMethod method, String number)?
      verify;
  @override
  State<BasicIdentityNumberScreen> createState() => _BasicIdentityNumberState();
}

class _BasicIdentityNumberState extends State<BasicIdentityNumberScreen> {
  final number = TextEditingController();
  bool verifying = false;
  String? error;
  Future<void> _submit() async {
    if (verifying ||
        number.text.length != 11 ||
        !VerificationSession.instance.profileComplete) {
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    final submittedNumber = number.text;
    final session = VerificationSession.instance;
    final generation = session.generation;
    setState(() {
      verifying = true;
      error = null;
    });
    try {
      final success = widget.verify == null
          ? await Future<bool>.delayed(
              const Duration(milliseconds: 1500), () => true)
          : await widget.verify!(widget.method, submittedNumber);
      if (!mounted) return;
      if (generation != session.generation) {
        setState(() {
          verifying = false;
          error =
              'Your session changed. Complete your profile before trying again.';
        });
        return;
      }
      if (!success) throw StateError('Verification failed');
      session.submitBasic(widget.method, submittedNumber);
      number.clear();
      Navigator.of(context).pushReplacement(AppPageRoute<void>(
          builder: (_) => const BasicVerificationSubmittedScreen()));
    } catch (_) {
      if (!mounted || generation != session.generation) return;
      setState(() {
        verifying = false;
        error =
            'Could not verify your identity. Check your details and try again.';
      });
    }
  }

  @override
  void dispose() {
    number.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => VerificationPage(
      title: verifying ? 'Verify Your Account' : 'Verify your identity',
      showPrivacyLink: !verifying,
      bottom: verifying
          ? null
          : VerificationButton('Continue',
              onPressed: number.text.length == 11 &&
                      VerificationSession.instance.profileComplete
                  ? _submit
                  : null),
      child: verifying
          ? Column(children: [
              const SizedBox(height: 36),
              const DavoWorkingIndicator(),
              const SizedBox(height: 24),
              Text('Verifying your ${widget.method.shortLabel}',
                  style: verificationHeading),
              const SizedBox(height: 8),
              const Text(
                  'This may take a few seconds.\nPlease do not leave this page.',
                  textAlign: TextAlign.center,
                  style: verificationBody)
            ])
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                  'We need your ${widget.method.fullLabel} (${widget.method.shortLabel}) to secure your account.',
                  style: verificationBody),
              const SizedBox(height: 24),
              Text('Your ${widget.method.shortLabel}', style: verificationBody),
              const SizedBox(height: 8),
              TextField(
                  controller: number,
                  keyboardAppearance: Theme.of(context).brightness,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11)
                  ],
                  onChanged: (_) => setState(() {
                        error = null;
                      }),
                  style: verificationBody,
                  decoration: InputDecoration(
                      hintText:
                          'Enter your 11-digit ${widget.method.shortLabel}',
                      hintStyle: verificationCaption.copyWith(
                          color: DavoColors.of(context).muted),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      suffixIcon: number.text.length == 11
                          ? const Padding(
                              key: Key('identity-number-complete'),
                              padding: EdgeInsets.all(14),
                              child: VerificationAsset('ddc48.svg', size: 16))
                          : null,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4)),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: BorderSide(
                              color: DavoColors.of(context).border)))),
              if (error != null)
                Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(error!,
                        style: verificationCaption.copyWith(
                            color: DavoColors.of(context).danger))),
              const SizedBox(height: 24),
              VerificationNotice(
                  widget.method == BasicIdentityMethod.bvn
                      ? 'We use your BVN to verify your identity and ensure that your account is secure. This does not give us access to your bank account.'
                      : 'Your NIN is securely processed to verify that your identity matches your personal details.',
                  title: 'Why do we ask for your ${widget.method.shortLabel}?'),
            ]));
}

class BasicVerificationSubmittedScreen extends StatelessWidget {
  const BasicVerificationSubmittedScreen({super.key, this.animate = true});
  final bool animate;
  @override
  Widget build(BuildContext context) {
    final session = VerificationSession.instance;
    return VerificationPage(
        title: '',
        bottom: Column(mainAxisSize: MainAxisSize.min, children: [
          VerificationButton('Continue to Advanced',
              onPressed: session.basicVerified
                  ? () {
                      final navigator = Navigator.of(context);
                      navigator.popUntil((route) =>
                          route.isFirst ||
                          route.settings.name == 'verification');
                      navigator.push(AppPageRoute<void>(
                          builder: (_) =>
                              const AdvancedVerificationFlowScreen()));
                    }
                  : null),
          const SizedBox(height: 12),
          VerificationButton('Maybe Later',
              secondary: true,
              onPressed: () => Navigator.of(context).popUntil((route) =>
                  route.isFirst || route.settings.name == 'verification'))
        ]),
        child: DavoOutcomeContent(
            play: animate,
            semanticLabel: 'Basic verification completed',
            heading: Column(children: [
              const Text('Basic Verifications Completed',
                  style: verificationHeading, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                  'Your ${session.identityMethod?.shortLabel ?? 'identity number'} has been successfully verified.\nYou can now access more features on Davochain',
                  style: verificationBody,
                  textAlign: TextAlign.center)
            ]),
            details: VerificationTier(
                advanced: false,
                description:
                    session.identityMethod?.shortLabel ?? 'Identity number')));
  }
}
