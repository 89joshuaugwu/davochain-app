import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/preview/local_preview_profile.dart';
import '../../core/theme/app_theme.dart';
import '../../features/profile_settings/presentation/verification/verification_state.dart';
import 'davo_toast.dart';

class LocalProfileAvatar extends StatefulWidget {
  const LocalProfileAvatar(
      {super.key,
      this.size = 96,
      this.editable = false,
      this.showBadge = true});
  final double size;
  final bool editable, showBadge;
  @override
  State<LocalProfileAvatar> createState() => _LocalProfileAvatarState();
}

class _LocalProfileAvatarState extends State<LocalProfileAvatar> {
  bool selecting = false;
  Future<void> _pick() async {
    if (selecting) return;
    selecting = true;
    final profile = LocalPreviewProfile.instance;
    final generation = profile.generation;
    try {
      final selected =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (selected == null) return;
      if (await selected.length() > 5 * 1024 * 1024) {
        throw const FormatException('Choose an image smaller than 5 MB.');
      }
      final bytes = await selected.readAsBytes();
      if (bytes.isEmpty || bytes.length > 5 * 1024 * 1024) {
        throw const FormatException('Choose an image smaller than 5 MB.');
      }
      final jpeg = bytes.length >= 3 &&
          bytes[0] == 0xff &&
          bytes[1] == 0xd8 &&
          bytes[2] == 0xff;
      final png = bytes.length >= 8 &&
          bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4e &&
          bytes[3] == 0x47 &&
          bytes[4] == 13 &&
          bytes[5] == 10 &&
          bytes[6] == 26 &&
          bytes[7] == 10;
      if (!jpeg && !png) {
        throw const FormatException('Choose a JPG or PNG profile photo.');
      }
      ui.ImmutableBuffer? buffer;
      ui.ImageDescriptor? descriptor;
      try {
        buffer = await ui.ImmutableBuffer.fromUint8List(bytes);
        descriptor = await ui.ImageDescriptor.encoded(buffer);
        if (descriptor.width * descriptor.height > 24000000) {
          throw const FormatException(
              'Choose an image smaller than 24 megapixels.');
        }
      } finally {
        descriptor?.dispose();
        buffer?.dispose();
      }
      if (mounted && generation == profile.generation) profile.setPhoto(bytes);
    } catch (error) {
      if (mounted) {
        showDavoToast(
            context,
            error is FormatException
                ? error.message
                : 'This image could not be opened. Please choose another photo.');
      }
    } finally {
      selecting = false;
    }
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
      listenable: LocalPreviewProfile.instance,
      builder: (context, _) {
        final profile = LocalPreviewProfile.instance;
        final verification = VerificationSession.instance;
        final gray = DavoColors.of(context).muted;
        final level = verification.advancedSubmitted
            ? 2
            : verification.basicVerified
                ? 1
                : 0;
        final image = profile.photo != null
            ? Image.memory(profile.photo!, fit: BoxFit.cover)
            : profile.sampleAvatar
                ? Stack(children: [
                    Positioned(
                        left: -32 * widget.size / 120,
                        top: -20 * widget.size / 120,
                        width: 183 * widget.size / 120,
                        height: 184 * widget.size / 120,
                        child: Image.asset(
                            'assets/figma_exact/profile_avatar_exact.png',
                            fit: BoxFit.fill))
                  ])
                : Icon(Icons.person_outline,
                    size: widget.size * .55, color: gray);
        return Semantics(
            label: widget.editable
                ? 'Change profile photo'
                : '${profile.fullName} profile photo',
            button: widget.editable,
            child: InkWell(
                onTap: widget.editable ? _pick : null,
                customBorder: const CircleBorder(),
                child: SizedBox(
                    width: widget.size,
                    height: widget.size,
                    child: Stack(clipBehavior: Clip.none, children: [
                      Positioned.fill(
                          child: ClipOval(
                              child: ColoredBox(
                                  color: DavoColors.of(context).offWhite,
                                  child: image))),
                      if (widget.showBadge)
                        Positioned(
                            right: 0,
                            bottom: 0,
                            child: Semantics(
                                key: const ValueKey(
                                    'profile-verification-badge'),
                                label: level == 2
                                    ? 'Advanced verified'
                                    : level == 1
                                        ? 'Basic verified'
                                        : 'Not verified',
                                child: Container(
                                    key: ValueKey(
                                        'profile-verification-level-$level'),
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: level == 2
                                            ? AppColors.primary
                                            : gray,
                                        border: Border.all(
                                            color:
                                                DavoColors.of(context).surface,
                                            width: 2)),
                                    child: Center(
                                        child: Container(
                                            width: 16,
                                            height: 16,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: level > 0
                                                    ? AppColors.primary
                                                    : gray),
                                            child: const Icon(Icons.check,
                                                size: 12,
                                                color: Colors.white)))))),
                    ]))));
      });
}
