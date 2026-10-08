import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/auth_widgets.dart';
import '../../../../shared/widgets/davo_success_mark.dart';
import 'verification_state.dart';

const _body = TextStyle(
    fontFamily: 'Sora', fontSize: 14, height: 1.5, color: Color(0xFF667085));
const _caption = TextStyle(
    fontFamily: 'Sora', fontSize: 12, height: 1.5, color: Color(0xFF667085));
const _heading = TextStyle(
    fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.w600, height: 1.4);

/// Session-only presentation flow. Native camera and upload providers, and
/// server submission/review, must replace the local fixture actions below.
class AdvancedVerificationFlowScreen extends StatefulWidget {
  const AdvancedVerificationFlowScreen({super.key});

  @override
  State<AdvancedVerificationFlowScreen> createState() =>
      _AdvancedVerificationFlowScreenState();
}

class _AdvancedVerificationFlowScreenState
    extends State<AdvancedVerificationFlowScreen> {
  final _session = VerificationSession.instance;
  final _scroll = ScrollController();
  late int _step;
  bool _photoReview = false;
  bool _retaking = false;

  @override
  void initState() {
    super.initState();
    _step = _session.advancedSubmitted ? 4 : _session.advancedStep;
    _session.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _session.removeListener(_refresh);
    _scroll.dispose();
    super.dispose();
  }

  void _go(int step) {
    setState(() {
      _step = step;
      _photoReview = false;
      _retaking = false;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _exit() => Navigator.of(context).pop();
  void _back() {
    if (_photoReview) {
      setState(() => _photoReview = false);
    } else if (_step > 0 && _step < 4) {
      _go(_step - 1);
    } else {
      _exit();
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.accessibleNavigationOf(context);
    final eligible = _session.canStartAdvanced;
    final contents = eligible ? _contents() : _gate();
    final actions = eligible
        ? _actions()
        : [DavoPrimaryButton(label: 'Back to overview', onPressed: _exit)];
    return PopScope(
      canPop: !eligible || (!_photoReview && (_step == 0 || _step == 4)),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _back();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          leading: IconButton(
              tooltip: 'Back to overview',
              onPressed: _exit,
              icon: const Icon(Icons.arrow_back, size: 22)),
          title: const Text('Advanced verification',
              style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 16,
                  fontWeight: FontWeight.w600)),
        ),
        body: SafeArea(
          top: false,
          child: LayoutBuilder(builder: (context, constraints) {
            // Large accessibility text keeps actions in the same scroll region.
            final sticky = constraints.maxHeight >= 520 &&
                MediaQuery.textScalerOf(context).scale(14) <= 21;
            final actionBlock = Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child:
                    Column(mainAxisSize: MainAxisSize.min, children: actions));
            final page = SingleChildScrollView(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (eligible && _step < 4) ...[
                      _progress(),
                      const SizedBox(height: 24)
                    ],
                    AnimatedSwitcher(
                      duration: reduce
                          ? Duration.zero
                          : const Duration(milliseconds: 220),
                      reverseDuration: reduce
                          ? Duration.zero
                          : const Duration(milliseconds: 180),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeOutCubic,
                      child: Column(
                          key: ValueKey('$eligible-$_step-$_photoReview'),
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: contents),
                    ),
                    if (!sticky) ...[const SizedBox(height: 24), ...actions],
                  ]),
            );
            return Column(
                children: [Expanded(child: page), if (sticky) actionBlock]);
          }),
        ),
      ),
    );
  }

  Widget _progress() =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_step == 3 ? 'Review your details' : 'Step ${_step + 1} of 3',
            style: _caption),
        const SizedBox(height: 10),
        Row(
            children: List.generate(
                3,
                (index) => Expanded(
                        child: Padding(
                      padding: EdgeInsets.only(right: index == 2 ? 0 : 6),
                      child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                              color: index <= _step
                                  ? AppColors.primary
                                  : const Color(0xFFEAECF0),
                              borderRadius: BorderRadius.circular(2))),
                    )))),
      ]);

  List<Widget> _gate() => const [
        SizedBox(height: 32),
        Icon(Icons.lock_outline, color: AppColors.primary, size: 48),
        SizedBox(height: 24),
        Text('Complete basic verification first',
            style: _heading, textAlign: TextAlign.center),
        SizedBox(height: 12),
        Text(
            'Submit your profile and NIN or BVN before starting advanced verification.',
            style: _body,
            textAlign: TextAlign.center),
      ];

  List<Widget> _contents() {
    if (_step == 4) {
      return [
        const SizedBox(height: 24),
        const Center(
            child: DavoSuccessMark(semanticLabel: 'Details submitted')),
        const SizedBox(height: 24),
        const Text('Advanced verification submitted',
            style: _heading, textAlign: TextAlign.center),
        const SizedBox(height: 12),
        const Text('Pending review',
            style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary),
            textAlign: TextAlign.center),
        const SizedBox(height: 12),
        const Text(
            'Your face photo, identity document and proof of address have been submitted for review.',
            style: _body,
            textAlign: TextAlign.center),
        const SizedBox(height: 28),
        ..._summary(),
      ];
    }
    if (_step == 3) {
      return [
        const Text('Review and submit', style: _heading),
        const SizedBox(height: 8),
        const Text('Check your documents before submitting them for review.',
            style: _body),
        const SizedBox(height: 24),
        ..._summary(editable: true),
        const SizedBox(height: 20),
        const Text(
            'Submitting your details starts the review. Your verification status will remain pending until the review is complete.',
            style: _caption),
      ];
    }
    if (_step == 0) {
      return [
        Text(_photoReview ? 'Review your face photo' : 'Take a face photo',
            style: _heading),
        const SizedBox(height: 8),
        Text(
            _photoReview
                ? 'Make sure your whole face is clear and inside the frame.'
                : 'Use good lighting and keep your face inside the frame.',
            style: _body),
        const SizedBox(height: 28),
        Center(
            child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  _photoReview || (_session.faceAdded && !_retaking)
                      ? 'assets/figma_exact/kyc_face_review_exact.png'
                      : 'assets/figma_exact/kyc_selfie_reference_exact.png',
                  width: 171,
                  height: _photoReview || (_session.faceAdded && !_retaking)
                      ? 203
                      : 171,
                  fit: BoxFit.cover,
                ))),
        const SizedBox(height: 24),
        if (_session.faceAdded && !_photoReview && !_retaking)
          _added('Photo added'),
        const SizedBox(height: 12),
        const Text(
            'Keep your face uncovered. Remove glasses, hats or masks, and hold still for a sharp photo.',
            style: _body,
            textAlign: TextAlign.center),
      ];
    }
    if (_step == 1) {
      return [
        const Text('Choose your identity document', style: _heading),
        const SizedBox(height: 8),
        const Text(
            'Use a valid government-issued document. Your name and document details must be easy to read.',
            style: _body),
        const SizedBox(height: 20),
        for (final type in [
          'National ID',
          'International passport',
          'Driver licence'
        ])
          _choice(type, _session.identityDocumentType == type,
              () => _session.chooseDocument(type)),
        if (_session.identityDocumentType != null) ...[
          const SizedBox(height: 20),
          const Text(
              'Show the entire document, with no cropped edges, glare or blur.',
              style: _caption),
          const SizedBox(height: 12),
          _upload(
              _session.identityDocumentType == 'International passport'
                  ? 'Biodata page'
                  : 'Front of document',
              _session.identityFrontAdded,
              () => _session.addIdentitySide(front: true)),
          if (_session.identityDocumentType != 'International passport')
            _upload('Back of document', _session.identityBackAdded,
                () => _session.addIdentitySide(front: false)),
        ],
      ];
    }
    return [
      const Text('Add proof of address', style: _heading),
      const SizedBox(height: 8),
      const Text(
          'Choose a document that clearly shows your name and current address.',
          style: _body),
      const SizedBox(height: 20),
      _choice('Utility bill', _session.addressDocumentType == 'Utility bill',
          () => _session.chooseAddressDocument('Utility bill'),
          detail: 'Dated within the last 3 months'),
      _choice(
          'Bank statement',
          _session.addressDocumentType == 'Bank statement',
          () => _session.chooseAddressDocument('Bank statement'),
          detail: 'From another bank, dated within the last 6 months'),
      _choice(
          'Tenancy agreement',
          _session.addressDocumentType == 'Tenancy agreement',
          () => _session.chooseAddressDocument('Tenancy agreement'),
          detail:
              'Include your landlord’s utility bill confirming the address'),
      if (_session.addressDocumentType != null) ...[
        const SizedBox(height: 20),
        _upload('Proof of address', _session.addressDocumentAdded,
            _session.addAddressDocument),
      ],
    ];
  }

  List<Widget> _actions() {
    if (_step == 4) {
      return [DavoPrimaryButton(label: 'Back to overview', onPressed: _exit)];
    }
    late final String label;
    late final VoidCallback proceed;
    var enabled = true;
    if (_step == 0) {
      label = _photoReview
          ? 'Use photo'
          : _session.faceAdded && !_retaking
              ? 'Continue'
              : 'Take photo';
      proceed = () {
        if (_photoReview) {
          _session.addFace();
          _go(1);
        } else if (_session.faceAdded && !_retaking) {
          _go(1);
        } else {
          setState(() => _photoReview = true);
        }
      };
    } else if (_step == 1) {
      label = 'Continue';
      enabled = _session.identityDocumentType != null &&
          _session.identityDocumentsAdded;
      proceed = () => _go(2);
    } else if (_step == 2) {
      label = 'Review details';
      enabled =
          _session.addressDocumentType != null && _session.addressDocumentAdded;
      proceed = () => _go(3);
    } else {
      label = 'Submit for review';
      enabled = _session.canStartAdvanced &&
          _session.faceAdded &&
          _session.identityDocumentType != null &&
          _session.identityDocumentsAdded &&
          _session.addressDocumentType != null &&
          _session.addressDocumentAdded;
      proceed = () {
        _session.submitAdvanced();
        _go(4);
      };
    }
    return [
      DavoPrimaryButton(label: label, enabled: enabled, onPressed: proceed),
      if (_step == 0 && (_photoReview || _session.faceAdded))
        TextButton(
            onPressed: () => setState(() {
                  _photoReview = false;
                  _retaking = true;
                }),
            child: const Text('Retake photo', style: _body)),
      if (_step > 0)
        TextButton(
            onPressed: _back, child: const Text('Previous step', style: _body)),
      TextButton(
          onPressed: _exit, child: const Text('Return later', style: _body)),
    ];
  }

  Widget _choice(String title, bool selected, VoidCallback onTap,
          {String? detail}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Semantics(
            selected: selected,
            button: true,
            child: Material(
              color: selected ? const Color(0xFFF2F6FF) : Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                      color: selected
                          ? AppColors.primary
                          : const Color(0xFFEAECF0))),
              child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(children: [
                      Icon(
                          selected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: selected
                              ? AppColors.primary
                              : const Color(0xFF98A2B3),
                          size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(title,
                                style: _body.copyWith(
                                    color: const Color(0xFF101828),
                                    fontWeight: FontWeight.w600)),
                            if (detail != null) ...[
                              const SizedBox(height: 4),
                              Text(detail, style: _caption)
                            ],
                          ])),
                    ]),
                  )),
            )),
      );

  Widget _upload(String title, bool added, VoidCallback onAdd) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: OutlinedButton(
          onPressed: onAdd,
          style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              side: const BorderSide(color: Color(0xFFD0D5DD)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8))),
          child: Row(children: [
            Icon(added ? Icons.check_circle_outline : Icons.upload_file,
                size: 24, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(title,
                      style: _body.copyWith(color: const Color(0xFF101828))),
                  Text(
                      added
                          ? 'Document added · Tap to replace'
                          : 'Tap to add document',
                      style: _caption),
                ]))
          ]),
        ),
      );

  Widget _added(String title) =>
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.check_circle_outline,
            size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(title, style: _body)
      ]);

  List<Widget> _summary({bool editable = false}) => [
        _summaryRow(
            'Face photo', 'Photo added', editable ? () => _go(0) : null),
        _summaryRow('Identity document', _session.identityDocumentType ?? '',
            editable ? () => _go(1) : null),
        _summaryRow('Proof of address', _session.addressDocumentType ?? '',
            editable ? () => _go(2) : null),
      ];

  Widget _summaryRow(String label, String value, VoidCallback? edit) =>
      Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Color(0xFFEAECF0)))),
        child: Row(children: [
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(label, style: _caption),
                const SizedBox(height: 4),
                Text(value,
                    style: _body.copyWith(color: const Color(0xFF101828)))
              ])),
          if (edit != null)
            TextButton(
                onPressed: edit,
                child: const Text('Edit',
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 12,
                        color: AppColors.primary)))
        ]),
      );
}
