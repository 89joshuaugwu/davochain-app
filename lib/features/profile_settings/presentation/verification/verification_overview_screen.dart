import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/navigation/app_page_route.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/davo_success_mark.dart';
import '../profile_settings_flow.dart' show CompleteProfileV12Screen;
import 'advanced_verification_flow.dart';
import 'verification_state.dart';

class VerificationOverviewScreen extends StatelessWidget {
  const VerificationOverviewScreen({super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: VerificationSession.instance,
        builder: (context, _) {
          final session = VerificationSession.instance;
          return VerificationPage(
              title: 'Verification',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Verify at your own pace',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  const Text(
                      'Start with your profile and one identity number. Advanced verification adds your face and supporting documents.',
                      style: TextStyle(fontSize: 14, height: 1.5)),
                  const SizedBox(height: 28),
                  _LevelCard(
                      title: 'Basic verification',
                      status: session.basicSubmitted
                          ? 'Submitted · Pending review'
                          : session.profileDraft.isEmpty
                              ? 'Not started'
                              : 'In progress',
                      steps: const [
                        'Personal and contact details',
                        'Choose NIN or BVN',
                        'Enter your identity number'
                      ],
                      action: session.basicSubmitted
                          ? 'View submission'
                          : session.profileComplete
                              ? 'Continue Basic'
                              : 'Complete profile',
                      onTap: () => pushAppPage<void>(
                          context,
                          (_) => session.basicSubmitted
                              ? const BasicVerificationSubmittedScreen()
                              : session.profileComplete
                                  ? const BasicIdentityChoiceScreen()
                                  : const CompleteProfileV12Screen())),
                  const SizedBox(height: 18),
                  _LevelCard(
                      title: 'Advanced verification',
                      status: session.advancedSubmitted
                          ? 'Submitted · Pending review'
                          : !session.canStartAdvanced
                              ? 'Complete Basic first'
                              : session.faceAdded
                                  ? 'In progress'
                                  : 'Ready to start',
                      steps: const [
                        'Facial verification',
                        'Identity documents',
                        'Proof of address'
                      ],
                      action: session.advancedSubmitted
                          ? 'View submission'
                          : session.faceAdded
                              ? 'Continue Advanced'
                              : 'Start Advanced',
                      onTap: session.canStartAdvanced
                          ? () => pushAppPage<void>(context,
                              (_) => const AdvancedVerificationFlowScreen())
                          : null),
                  const SizedBox(height: 18),
                  const Text(
                      'Submission and approval are different steps. Your verification status will update after review.',
                      style: TextStyle(
                          fontSize: 12, height: 1.5, color: Color(0xFF667085))),
                ],
              ));
        },
      );
}

class VerificationPage extends StatelessWidget {
  const VerificationPage(
      {super.key, required this.title, required this.child, this.bottom});
  final String title;
  final Widget child;
  final Widget? bottom;
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            title: Text(title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            centerTitle: true,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent),
        body: SafeArea(
            child: Column(children: [
          Expanded(
              child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: child)),
          if (bottom != null)
            Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
                child: bottom!)
        ])),
      );
}

class _LevelCard extends StatelessWidget {
  const _LevelCard(
      {required this.title,
      required this.status,
      required this.steps,
      required this.action,
      this.onTap});
  final String title, status, action;
  final List<String> steps;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE7EAF1)),
            borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(status,
              style: const TextStyle(fontSize: 12, color: AppColors.primary)),
          const SizedBox(height: 18),
          for (var i = 0; i < steps.length; i++)
            Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          width: 16,
                          child: Text('${i + 1}',
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.primary))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(steps[i],
                              style: const TextStyle(fontSize: 14)))
                    ])),
          VerificationButton(action, onPressed: onTap),
        ]),
      );
}

class VerificationButton extends StatelessWidget {
  const VerificationButton(this.label, {super.key, this.onPressed});
  final String label;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
      width: double.infinity,
      child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
              minimumSize: const Size(0, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8))),
          child: Text(label,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))));
}

class BasicIdentityChoiceScreen extends StatefulWidget {
  const BasicIdentityChoiceScreen({super.key});
  @override
  State<BasicIdentityChoiceScreen> createState() => _BasicIdentityChoiceState();
}

class _BasicIdentityChoiceState extends State<BasicIdentityChoiceScreen> {
  BasicIdentityMethod? selected = VerificationSession.instance.identityMethod;
  @override
  Widget build(BuildContext context) => VerificationPage(
      title: 'Basic verification',
      bottom: VerificationButton('Continue',
          onPressed: selected == null
              ? null
              : () {
                  VerificationSession.instance.chooseIdentity(selected!);
                  pushAppPage<void>(context,
                      (_) => BasicIdentityNumberScreen(method: selected!));
                }),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Choose an identity number',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        const Text(
            'Use either your NIN or BVN to complete Basic verification. Only one is needed. No facial verification is required here.',
            style: TextStyle(fontSize: 14, height: 1.5)),
        const SizedBox(height: 28),
        for (final method in BasicIdentityMethod.values)
          Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Semantics(
                  selected: selected == method,
                  button: true,
                  child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => setState(() => selected = method),
                      child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              color: selected == method
                                  ? AppColors.primarySoft
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: selected == method
                                      ? AppColors.primary
                                      : const Color(0xFFE7EAF1))),
                          child: Row(children: [
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text(method.shortLabel,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 6),
                                  Text(method.fullLabel,
                                      style: const TextStyle(fontSize: 12))
                                ])),
                            Icon(
                                selected == method
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: AppColors.primary)
                          ]))))),
      ]));
}

class BasicIdentityNumberScreen extends StatefulWidget {
  const BasicIdentityNumberScreen({super.key, required this.method});
  final BasicIdentityMethod method;
  @override
  State<BasicIdentityNumberScreen> createState() => _BasicIdentityNumberState();
}

class _BasicIdentityNumberState extends State<BasicIdentityNumberScreen> {
  final number = TextEditingController();
  @override
  void dispose() {
    number.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => VerificationPage(
      title: 'Basic verification',
      bottom: VerificationButton('Submit Basic verification',
          onPressed: number.text.length != 11 ||
                  !VerificationSession.instance.profileComplete
              ? null
              : () {
                  VerificationSession.instance
                      .submitBasic(widget.method, number.text);
                  number.clear();
                  Navigator.of(context).pushReplacement(AppPageRoute<void>(
                      builder: (_) =>
                          const BasicVerificationSubmittedScreen()));
                }),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Enter your ${widget.method.shortLabel}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        const Text(
            'Your number should match the personal details in your profile.',
            style: TextStyle(fontSize: 14, height: 1.5)),
        const SizedBox(height: 28),
        TextField(
            controller: number,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11)
            ],
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
                labelText: widget.method.shortLabel,
                hintText: 'Enter 11-digit number',
                counterText: '${number.text.length}/11',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)))),
        const SizedBox(height: 24),
        const Text(
            'We use this number to confirm your identity. You will not need to provide both NIN and BVN.',
            style:
                TextStyle(fontSize: 12, height: 1.5, color: Color(0xFF667085))),
      ]));
}

class BasicVerificationSubmittedScreen extends StatelessWidget {
  const BasicVerificationSubmittedScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final session = VerificationSession.instance;
    return VerificationPage(
        title: 'Basic verification',
        bottom: Column(mainAxisSize: MainAxisSize.min, children: [
          VerificationButton('Continue to Advanced',
              onPressed: session.basicSubmitted
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
          TextButton(
              onPressed: () => Navigator.of(context).popUntil((route) =>
                  route.isFirst || route.settings.name == 'verification'),
              child: const Text('Done'))
        ]),
        child: Column(children: [
          const SizedBox(height: 24),
          const DavoSuccessMark(semanticLabel: 'Details submitted'),
          const SizedBox(height: 24),
          const Text('Basic verification submitted',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          const Text('Pending review',
              style: TextStyle(fontSize: 14, color: AppColors.primary)),
          const SizedBox(height: 20),
          Text(
              '${session.identityMethod?.shortLabel ?? 'Identity number'} ending in ${session.identifierLastFour ?? '—'}',
              style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 16),
          const Text(
              'Your details are ready for review. Advanced verification is available if you want to add your face, identity documents and proof of address.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.5)),
        ]));
  }
}
