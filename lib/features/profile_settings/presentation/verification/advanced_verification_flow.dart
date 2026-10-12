import 'dart:io';
import '../../verification_media/verification_media_gateway.dart';
import 'package:flutter/material.dart';
import '../../../../core/navigation/app_page_route.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/motion/davo_outcome_content.dart';
import '../../../../shared/motion/davo_step_transition.dart';
import '../../../../shared/motion/davo_working_indicator.dart';
import 'verification_components.dart';
import 'verification_state.dart';

enum _Stage {
  intro,
  overview,
  idChoice,
  idUpload,
  selfieIntro,
  photoReview,
  matching,
  identityDone,
  addressChoice,
  addressUpload,
  addressReview,
  verifyingAddress,
  complete
}

/// Local capture/upload and verification fixtures. Inject account-scoped service
/// operations and native capture/upload providers when the backend is connected.
class AdvancedVerificationFlowScreen extends StatefulWidget {
  const AdvancedVerificationFlowScreen(
      {super.key, this.verifyIdentity, this.verifyAddress});
  final Future<bool> Function()? verifyIdentity;
  final Future<bool> Function()? verifyAddress;
  @override
  State<AdvancedVerificationFlowScreen> createState() =>
      _AdvancedVerificationFlowScreenState();
}

class _AdvancedVerificationFlowScreenState
    extends State<AdvancedVerificationFlowScreen> {
  final session = VerificationSession.instance;
  late _Stage stage;
  bool backwards = false;
  bool mediaOpening = false;
  int operation = 0;
  String? error;
  @override
  void initState() {
    super.initState();
    stage = session.advancedSubmitted
        ? _Stage.complete
        : session.identityVerified
            ? _Stage.overview
            : session.identityDocumentsAdded
                ? _Stage.selfieIntro
                : _Stage.intro;
    session.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    operation++;
    session.removeListener(_refresh);
    super.dispose();
  }

  void _go(_Stage next) {
    operation++;
    setState(() {
      backwards = next.index < stage.index;
      stage = next;
      error = null;
    });
  }

  void _exit() {
    operation++;
    Navigator.maybePop(context);
  }

  void _back() {
    final previous = switch (stage) {
      _Stage.intro || _Stage.overview || _Stage.complete => null,
      _Stage.idChoice => _Stage.overview,
      _Stage.idUpload => _Stage.idChoice,
      _Stage.selfieIntro => _Stage.idUpload,
      _Stage.photoReview => _Stage.selfieIntro,
      _Stage.matching => _Stage.photoReview,
      _Stage.identityDone => _Stage.overview,
      _Stage.addressChoice => _Stage.overview,
      _Stage.addressUpload => _Stage.addressChoice,
      _Stage.addressReview || _Stage.verifyingAddress => _Stage.addressUpload,
    };
    if (previous == null) {
      _exit();
    } else {
      _go(previous);
    }
  }

  bool get busy => stage == _Stage.matching || stage == _Stage.verifyingAddress;
  Future<void> _verify({required bool identity}) async {
    _go(identity ? _Stage.matching : _Stage.verifyingAddress);
    final ticket = operation;
    final generation = session.generation;
    final document =
        identity ? session.identityDocumentType : session.addressDocumentType;
    try {
      final provider = identity ? widget.verifyIdentity : widget.verifyAddress;
      final success = provider == null
          ? await Future<bool>.delayed(
              const Duration(milliseconds: 1500), () => true)
          : await provider();
      if (!mounted || ticket != operation) return;
      if (generation != session.generation) {
        _go(_Stage.intro);
        return;
      }
      if (document !=
          (identity
              ? session.identityDocumentType
              : session.addressDocumentType)) {
        _go(_Stage.overview);
        return;
      }
      if (!success) throw StateError('Verification failed');
      if (identity) {
        session.addFace();
        session.verifyIdentity();
        _go(_Stage.identityDone);
      } else {
        session.submitAdvanced();
        _go(_Stage.complete);
      }
    } catch (_) {
      if (!mounted || ticket != operation || generation != session.generation) {
        return;
      }
      _go(identity ? _Stage.photoReview : _Stage.addressReview);
      setState(() => error =
          'Could not verify your ${identity ? 'identity' : 'address'}. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!session.canStartAdvanced) {
      return VerificationPage(
          title: 'Verify Your Account',
          onBack: _exit,
          bottom: VerificationButton('Back to overview', onPressed: _exit),
          child: const Text('Complete basic verification first',
              style: verificationHeading));
    }
    final root = stage == _Stage.intro ||
        stage == _Stage.overview ||
        stage == _Stage.complete;
    return PopScope(
        canPop: root,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) _back();
        },
        child: VerificationPage(
            title: stage == _Stage.selfieIntro
                ? 'KYC Verification'
                : stage == _Stage.photoReview
                    ? 'Face Verification'
                    : stage == _Stage.identityDone || stage == _Stage.complete
                        ? ''
                        : 'Verify Your Account',
            onBack: _back,
            bottom: _actions(),
            child: DavoStepTransition(
                backwards: backwards,
                child: Column(
                    key: ValueKey(stage),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (error != null)
                        Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(error!,
                                style: verificationCaption.copyWith(
                                    color: DavoColors.of(context).danger))),
                      ..._content(),
                    ]))));
  }

  List<Widget> _content() {
    switch (stage) {
      case _Stage.intro:
        return [
          Center(
              child: Container(
                  width: 60,
                  height: 60,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: DavoColors.of(context).primarySoft,
                      shape: BoxShape.circle),
                  child: const VerificationAsset('53681.svg', size: 28))),
          const SizedBox(height: 24),
          const Text('Advanced: ID & Address Verification',
              style: verificationHeading, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          const Text(
              'Upload a government-issued ID, proof of address and complete a final face verification.',
              style: verificationBody,
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          const VerificationRequirements(items: [
            ('e90f4.svg', 'Government-issued ID'),
            ('8bece.svg', 'Your face clearly visible'),
            ('c449a.svg', 'A valid proof of address document')
          ])
        ];
      case _Stage.overview:
        return [
          const Text('Advanced Verification', style: verificationHeading),
          const SizedBox(height: 8),
          const Text(
              'Complete the following steps to verify your identity and unlock your full account features.',
              style: verificationBody),
          const SizedBox(height: 24),
          VerificationChoiceRow(
              title: 'ID Verification',
              asset: '739f8.svg',
              selected: !session.identityVerified,
              completed: session.identityVerified,
              onTap: () => _go(session.identityVerified
                  ? _Stage.identityDone
                  : _Stage.idChoice)),
          VerificationChoiceRow(
              title: 'Address Verification',
              asset: '6b906.svg',
              selected: session.identityVerified && !session.addressVerified,
              completed: session.addressVerified,
              onTap: session.identityVerified
                  ? () => _go(_Stage.addressChoice)
                  : null)
        ];
      case _Stage.idChoice:
        return [
          const Text('Select ID Type', style: verificationHeading),
          const SizedBox(height: 8),
          const Text(
              'Verify your identity with a government-issued ID to increase your limits',
              style: verificationBody),
          const SizedBox(height: 24),
          for (final type in [
            'National ID card',
            'International passport',
            "Driver's licence"
          ])
            VerificationChoiceRow(
                title: type,
                asset: type == 'International passport'
                    ? '6b906.svg'
                    : '739f8.svg',
                radio: true,
                selected:
                    (session.identityDocumentType ?? 'National ID card') ==
                        type,
                onTap: () => session.chooseDocument(type))
        ];
      case _Stage.idUpload:
        return [
          const Text('Upload your ID', style: verificationHeading),
          const SizedBox(height: 8),
          const Text('Provide a clear photo of your government-issued ID',
              style: verificationCaption),
          const SizedBox(height: 24),
          _uploadTile('Upload ID Front', session.identityFrontAdded,
              () => _pickIdentity(front: true),
              file: 'id-front.jpg', remove: session.removeIdentityFront),
          const SizedBox(height: 12),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
                child: _uploadTile('Upload ID Back', session.identityBackAdded,
                    () => _pickIdentity(front: false),
                    small: true, file: 'id-back.jpg', optional: true)),
            const SizedBox(width: 12),
            Expanded(child: _cameraTile())
          ]),
          const SizedBox(height: 16),
          const Text('JPG, PNG or PDF (Max 5MB)', style: verificationCaption),
          if (session.identityFrontAdded) ...[
            const SizedBox(height: 12),
            const Text('Your ID is uploaded. Continue to verification.',
                style: verificationCaption)
          ]
        ];
      case _Stage.selfieIntro:
        return [
          const Text('Take a selfie', style: verificationHeading),
          const SizedBox(height: 8),
          const Text(
              'Make sure your face is well-lit and fits inside the frame for verification.',
              style: verificationBody),
          const SizedBox(height: 40),
          Center(
              child: Image.asset('assets/figma_exact/verification_95bf2.png',
                  width: 170, height: 170, fit: BoxFit.contain)),
          const SizedBox(height: 24),
          _checkLine(
              'To ensure the security of your account and comply with regulatory requirements, we need to verify your identity.'),
          _checkLine('Take a photo of your face to complete this process.')
        ];
      case _Stage.photoReview:
        return [
          const Text('Review your photo', style: verificationHeading),
          const SizedBox(height: 8),
          const Text('Make sure your face is clear before you submit.',
              style: verificationBody),
          const SizedBox(height: 40),
          Center(
              child: _attachmentPreview(session.selfie,
                  width: 171, height: 203, fallback: 'verification_901d8.png')),
          const SizedBox(height: 24),
          const Text('Check that:', style: verificationHeading),
          const SizedBox(height: 16),
          for (final text in [
            'Your whole face is inside the frame.',
            'Your photo is sharp and not blurry.',
            'Nothing covers your face (no glasses, hat, or mask).'
          ])
            _checkLine(text, checked: false)
        ];
      case _Stage.matching:
        return _loading('Matching your identity',
            "We're comparing your selfie with your ID records. This may take a few seconds.");
      case _Stage.identityDone:
        return [
          const DavoOutcomeContent(
              heading: Column(children: [
                Text('Verifications Completed', style: verificationHeading),
                SizedBox(height: 8),
                Text(
                    'Your ID and identity match have been successfully verified. You can now access higher transaction limits.',
                    style: verificationBody,
                    textAlign: TextAlign.center)
              ]),
              details: VerificationTier(
                  advanced: true,
                  description: 'ID Verified\nAddress not Verified'))
        ];
      case _Stage.addressChoice:
        return [
          const Text('Select Document Type', style: verificationHeading),
          const SizedBox(height: 8),
          const Text(
              'Choose the document you want to use for address verification',
              style: verificationBody),
          const SizedBox(height: 24),
          for (final type in [
            'Utility bill',
            'Bank statement',
            'Government document',
            'Tenancy agreement'
          ])
            VerificationChoiceRow(
                title: type,
                subtitle: switch (type) {
                  'Utility bill' => 'Electricity, water, internet, etc.',
                  'Bank statement' => 'Last 3 months',
                  'Government document' => 'For example, a tax certificate',
                  _ => null
                },
                asset: '651ea.svg',
                radio: true,
                selected:
                    (session.addressDocumentType ?? 'Utility bill') == type,
                onTap: () => session.chooseAddressDocument(type))
        ];
      case _Stage.addressUpload:
        return [
          const Text('Upload Document', style: verificationHeading),
          const SizedBox(height: 24),
          _uploadTile(
              'Upload Document', session.addressDocumentAdded, _pickAddress,
              file: _addressFilename, remove: session.removeAddressDocument),
          const SizedBox(height: 16),
          const VerificationNotice(
              'Make sure the document is clear and readable.\nAll corners must be visible.\nDocument must be recent (within 3 months).\nYour name and address must match your profile.')
        ];
      case _Stage.addressReview:
        return [
          const Text('Upload Document', style: verificationHeading),
          const SizedBox(height: 24),
          ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: _attachmentPreview(session.addressAttachment,
                  width: double.infinity,
                  height: 328,
                  fallback: 'verification_1cc51.png')),
          const SizedBox(height: 12),
          Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: DavoColors.of(context).canvas,
                  border:
                      Border.all(color: DavoColors.of(context).primaryDisabled),
                  borderRadius: BorderRadius.circular(4)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      const Expanded(
                          child:
                              Text('Address Details', style: verificationBody)),
                      TextButton(
                          onPressed: _editAddress, child: const Text('Edit'))
                    ]),
                    Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          VerificationAsset('15121.svg',
                              size: 20, color: DavoColors.of(context).body),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Text(_address, style: verificationCaption))
                        ])
                  ]))
        ];
      case _Stage.verifyingAddress:
        return _loading('Verifying your Address',
            'We are checking the document details.\nThis may take a few moments.');
      case _Stage.complete:
        return [
          const DavoOutcomeContent(
              heading: Column(children: [
            Text('Your Account is Fully Verified',
                style: verificationHeading, textAlign: TextAlign.center),
            SizedBox(height: 8),
            Text(
                'You now have access to all Davochain features and higher limits.',
                style: verificationBody,
                textAlign: TextAlign.center)
          ]))
        ];
    }
  }

  String get _address => session.profileDraft['address']?.trim().isNotEmpty ==
          true
      ? '${session.profileDraft['address']}, ${session.profileDraft['state'] ?? 'Lagos'}, Nigeria.'
      : '12, Adeola Street, Victoria Island, Lagos, Nigeria.';
  String get _addressFilename => switch (session.addressDocumentType) {
        'Bank statement' => 'bank_statement.pdf',
        'Tenancy agreement' => 'tenancy_agreement.pdf',
        'Government document' => 'government_document.pdf',
        _ => 'electricity_bill.pdf'
      };
  List<Widget> _loading(String title, String description) => [
        const SizedBox(height: 36),
        const Center(child: DavoWorkingIndicator()),
        const SizedBox(height: 24),
        Text(title, style: verificationHeading, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(description, style: verificationBody, textAlign: TextAlign.center)
      ];
  Widget? _actions() {
    if (busy || stage == _Stage.overview) return null;
    String label;
    VoidCallback? action;
    String? secondary;
    VoidCallback? alternate;
    switch (stage) {
      case _Stage.intro:
        label = 'Start';
        action = () => _go(_Stage.overview);
      case _Stage.idChoice:
        label = 'Start';
        action = () {
          session.chooseDocument(
              session.identityDocumentType ?? 'National ID card');
          _go(_Stage.idUpload);
        };
      case _Stage.idUpload:
        label = 'Continue';
        action = session.identityDocumentsAdded
            ? () => _go(_Stage.selfieIntro)
            : null;
      case _Stage.selfieIntro:
        label = 'Start live face detection';
        action = _captureFace;
        secondary = 'Later';
        alternate = _exit;
      case _Stage.photoReview:
        label = 'Submit photo';
        action = () => _verify(identity: true);
        secondary = 'Retake photo';
        alternate = _captureFace;
      case _Stage.identityDone:
        label = 'Continue to Address Verification';
        action = () => _go(_Stage.overview);
        secondary = 'Maybe Later';
        alternate = _exit;
      case _Stage.addressChoice:
        label = 'Continue';
        action = () {
          session.chooseAddressDocument(
              session.addressDocumentType ?? 'Utility bill');
          _go(_Stage.addressUpload);
        };
      case _Stage.addressUpload:
        label = 'Continue';
        action = session.addressDocumentAdded
            ? () => _go(_Stage.addressReview)
            : null;
      case _Stage.addressReview:
        label = 'Continue';
        action = () => _verify(identity: false);
      case _Stage.complete:
        label = 'Back to Home';
        action = () => Navigator.of(context).popUntil((route) => route.isFirst);
      default:
        return null;
    }
    return Column(mainAxisSize: MainAxisSize.min, children: [
      VerificationButton(mediaOpening ? 'Opening?' : label,
          onPressed: mediaOpening ? null : action),
      if (secondary != null) ...[
        const SizedBox(height: 12),
        VerificationButton(secondary, secondary: true, onPressed: alternate)
      ]
    ]);
  }

  Widget _checkLine(String text, {bool checked = true}) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        VerificationAsset(checked ? 'cc8a5.svg' : 'cd7bf.svg',
            size: 20, color: DavoColors.of(context).bodyMuted),
        const SizedBox(width: 10),
        Expanded(
            child: Text(text,
                style: verificationCaption.copyWith(
                    color: DavoColors.of(context).bodyMuted)))
      ]));
  Widget _cameraTile() => Material(
      color: DavoColors.of(context).primarySoft,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
          onTap: () => _pickIdentity(front: true, camera: true),
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
              child: Column(children: [
                VerificationAsset('98c96.svg'),
                SizedBox(height: 12),
                Text('Take Photo', style: verificationCaption),
                Text('Use camera', style: verificationCaption)
              ]))));
  Widget _uploadTile(String label, bool added, VoidCallback add,
      {required String file,
      bool small = false,
      bool optional = false,
      VoidCallback? remove}) {
    final attachment = label == 'Upload ID Front'
        ? session.identityFront
        : label == 'Upload ID Back'
            ? session.identityBack
            : session.addressAttachment;
    if (added) {
      return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: DavoColors.of(context).primarySoft,
              border: Border.all(color: DavoColors.of(context).primaryDisabled),
              borderRadius: BorderRadius.circular(8)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                  child: Text(label == 'Upload ID Front' ? 'ID Front' : label,
                      style: verificationCaption)),
              const VerificationStatus('Uploaded', uploaded: true)
            ]),
            const SizedBox(height: 16),
            Row(children: [
              if (attachment != null && attachment.kind != 'pdf')
                _attachmentPreview(attachment, width: 64, height: 64)
              else
                const VerificationAsset('e90f4.svg', size: 32),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(
                      '${attachment?.name ?? file}\n${attachment?.sizeLabel ?? '1.2 MB'}',
                      style: verificationCaption))
            ]),
            const SizedBox(height: 8),
            Wrap(spacing: 12, children: [
              TextButton(
                  onPressed: mediaOpening ? null : add,
                  child: const Text('Replace file')),
              if (remove != null)
                TextButton(onPressed: remove, child: const Text('Remove'))
            ])
          ]));
    }
    return Material(
        color: DavoColors.of(context).primarySoft,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: DavoColors.of(context).primaryDisabled)),
        child: InkWell(
            onTap: mediaOpening ? null : add,
            borderRadius: BorderRadius.circular(8),
            child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: small ? 156 : 226),
                child: Center(
                    child: Padding(
                        padding: const EdgeInsets.all(16),
                        child:
                            Column(mainAxisSize: MainAxisSize.min, children: [
                          VerificationAsset(small ? '9fba1.svg' : '172e5.svg',
                              size: 32),
                          const SizedBox(height: 16),
                          Text(label,
                              style: verificationBody.copyWith(
                                  fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center),
                          Text(
                              optional
                                  ? 'Optional'
                                  : 'JPG, PNG or PDF (Max 5MB)',
                              style: verificationCaption,
                              textAlign: TextAlign.center)
                        ]))))));
  }

  Widget _attachmentPreview(VerificationAttachment? attachment,
      {required double width, required double height, String? fallback}) {
    if (attachment == null) {
      return fallback == null
          ? SizedBox(width: width, height: height)
          : Image.asset('assets/figma_exact/$fallback',
              width: width, height: height, fit: BoxFit.contain);
    }
    if (attachment.isAsset) {
      return Image.asset(attachment.path,
          width: width, height: height, fit: BoxFit.contain);
    }
    final path =
        attachment.kind == 'pdf' ? attachment.previewPath : attachment.path;
    return path == null
        ? SizedBox(
            width: width,
            height: height,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.picture_as_pdf_outlined, size: 48),
              Text(attachment.name, maxLines: 3, overflow: TextOverflow.ellipsis, style: verificationBody),
              const Text(
                  'PDF selected. Preview is not available on this device.',
                  style: verificationCaption)
            ]))
        : Image.file(File(path),
            width: width, height: height, fit: BoxFit.contain, cacheWidth: ((width.isFinite ? width : MediaQuery.sizeOf(context).width) * MediaQuery.devicePixelRatioOf(context)).ceil());
  }

  Future<void> _pickIdentity({required bool front, bool camera = false}) =>
      _pickMedia(
          () => VerificationMediaGateway.instance.pickDocument(camera: camera),
          (attachment) => session.attachIdentity(attachment, front: front));
  Future<void> _pickAddress() => _pickMedia(
      () => VerificationMediaGateway.instance.pickDocument(),
      session.attachAddress);
  Future<void> _captureFace() =>
      _pickMedia(() => VerificationMediaGateway.instance.captureFace(context),
          (attachment) {
        session.attachSelfie(attachment);
        _go(_Stage.photoReview);
      });
  Future<void> _pickMedia(Future<VerificationAttachment?> Function() pick,
      void Function(VerificationAttachment) accept) async {
    if (mediaOpening) return;
    final ticket = operation, generation = session.generation;
    setState(() {
      mediaOpening = true;
      error = null;
    });
    try {
      final attachment = await pick();
      if (attachment == null) return;
      if (!mounted || ticket != operation || generation != session.generation) {
        attachment.release();
        return;
      }
      accept(attachment);
    } catch (failure) {
      if (mounted && ticket == operation && generation == session.generation) {
        setState(() => error = failure is FormatException
            ? failure.message
            : 'The file or camera could not be opened. Check device permissions and try again.');
      }
    } finally {
      if (mounted) setState(() => mediaOpening = false);
    }
  }

  Future<void> _editAddress() async {
    final address = await Navigator.of(context).push<String>(
        AppPageRoute<String>(
            builder: (_) => _AddressEditScreen(
                initial: session.profileDraft['address'] ??
                    '12, Adeola Street, Victoria Island')));
    if (mounted && address != null) session.saveProfile({'address': address});
  }
}

class _AddressEditScreen extends StatefulWidget {
  const _AddressEditScreen({required this.initial});
  final String initial;
  @override
  State<_AddressEditScreen> createState() => _AddressEditState();
}

class _AddressEditState extends State<_AddressEditScreen> {
  late final controller = TextEditingController(text: widget.initial);
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => VerificationPage(
      title: 'Address Details',
      bottom: VerificationButton('Save address',
          onPressed: controller.text.trim().isEmpty
              ? null
              : () => Navigator.pop(context, controller.text.trim())),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Residential address', style: verificationHeading),
        const SizedBox(height: 16),
        TextField(
            controller: controller,
            maxLines: 3,
            onChanged: (_) => setState(() {}),
            decoration:
                const InputDecoration(hintText: 'House number, street, area'))
      ]));
}
