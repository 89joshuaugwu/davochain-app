import '../settings_content_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_theme.dart';

const verificationHeading = TextStyle(
    fontFamily: 'Sora',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.35);
const verificationBody =
    TextStyle(fontFamily: 'Sora', fontSize: 14, height: 1.35);
const verificationCaption =
    TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.4);

class VerificationAsset extends StatelessWidget {
  const VerificationAsset(this.file, {super.key, this.size = 24, this.color});
  final String file;
  final double size;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    final image = SvgPicture.asset('assets/figma_exact/verification_$file',
        colorFilter:
            color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn));
    return SizedBox.square(
        dimension: size,
        child: file == '31570.svg'
            ? RotatedBox(quarterTurns: 2, child: image)
            : image);
  }
}

class VerificationPage extends StatelessWidget {
  const VerificationPage(
      {super.key,
      required this.title,
      required this.child,
      this.bottom,
      this.showPrivacyLink = false,
      this.onBack});
  final String title;
  final Widget child;
  final Widget? bottom;
  final bool showPrivacyLink;
  final VoidCallback? onBack;
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: DavoColors.of(context).surface,
        appBar: AppBar(
            title: Text(title,
                style: const TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 16,
                    fontWeight: FontWeight.w400)),
            centerTitle: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: DavoColors.of(context).surface,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
                tooltip: 'Back',
                onPressed: onBack ?? () => Navigator.maybePop(context),
                icon: VerificationAsset('808d6.svg',
                    color: DavoColors.of(context).ink))),
        body: SafeArea(
            top: false,
            child: LayoutBuilder(builder: (context, constraints) {
              final sticky = constraints.maxHeight >= 460 &&
                  MediaQuery.textScalerOf(context).scale(14) <= 21;
              final action = bottom == null
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      child: bottom);
              return Column(children: [
                Expanded(
                    child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              child,
                              if (showPrivacyLink) ...[
                                const SizedBox(height: 16),
                                Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton(
                                        onPressed: () => showSettingsContent(
                                            context, 'Privacy Policy'),
                                        child:
                                            const Text('Read Privacy Policy'))),
                              ],
                              if (!sticky && bottom != null) ...[
                                const SizedBox(height: 24),
                                action
                              ]
                            ]))),
                if (sticky && bottom != null) action
              ]);
            })),
      );
}

class VerificationButton extends StatelessWidget {
  const VerificationButton(this.label,
      {super.key, this.onPressed, this.secondary = false});
  final String label;
  final VoidCallback? onPressed;
  final bool secondary;
  @override
  Widget build(BuildContext context) => SizedBox(
      width: double.infinity,
      child: FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
              minimumSize: const Size(0, 48),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              backgroundColor: secondary
                  ? DavoColors.of(context).primarySoft
                  : AppColors.primary,
              foregroundColor:
                  secondary ? DavoColors.of(context).link : Colors.white,
              disabledBackgroundColor: DavoColors.of(context).primaryDisabled,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4))),
          child: Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 14,
                  fontWeight: FontWeight.w600))));
}

class VerificationChoiceRow extends StatelessWidget {
  const VerificationChoiceRow(
      {super.key,
      required this.title,
      this.subtitle,
      this.asset,
      this.onTap,
      this.selected = false,
      this.completed = false,
      this.radio = false});
  final String title;
  final String? subtitle, asset;
  final VoidCallback? onTap;
  final bool selected, completed, radio;
  @override
  Widget build(BuildContext context) {
    final colors = DavoColors.of(context);
    return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Semantics(
            button: true,
            enabled: onTap != null,
            selected: selected,
            child: Material(
                color: selected && !radio ? colors.primarySoft : colors.canvas,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                        color: selected ? AppColors.primary : colors.divider)),
                child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 16),
                        child: Row(children: [
                          if (radio && asset == null) ...[
                            Icon(
                                selected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                size: 20,
                                color:
                                    selected ? colors.link : colors.bodyMuted),
                            const SizedBox(width: 12)
                          ],
                          if (asset != null) ...[
                            Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                    color: colors.primarySoft,
                                    borderRadius: BorderRadius.circular(5)),
                                child: VerificationAsset(asset!, size: 20)),
                            const SizedBox(width: 12)
                          ],
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(title,
                                    style: verificationBody.copyWith(
                                        fontWeight: radio
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                        color: onTap == null && !completed
                                            ? colors.muted
                                            : colors.ink)),
                                if (subtitle != null) ...[
                                  const SizedBox(height: 4),
                                  Text(subtitle!,
                                      style: verificationCaption.copyWith(
                                          color: colors.bodyMuted))
                                ]
                              ])),
                          if (completed)
                            const VerificationStatus('Completed')
                          else if (radio && asset != null)
                            VerificationAsset(
                                selected ? 'e202c.svg' : '03819.svg',
                                size: 20)
                          else if (!radio)
                            VerificationAsset('31570.svg',
                                size: 20,
                                color: onTap == null
                                    ? colors.muted
                                    : colors.bodyMuted),
                        ]))))));
  }
}

class VerificationStatus extends StatelessWidget {
  const VerificationStatus(this.text,
      {super.key, this.limited = false, this.uploaded = false});
  final String text;
  final bool limited, uploaded;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
          color: uploaded
              ? DavoColors.of(context).primaryDisabled.withValues(alpha: .45)
              : limited
                  ? DavoColors.of(context).warningSurface
                  : DavoColors.of(context).successSurface,
          borderRadius: BorderRadius.circular(uploaded ? 24 : 4)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (uploaded) ...[
          Icon(Icons.check_rounded,
              size: 12, color: DavoColors.of(context).link),
          const SizedBox(width: 4),
        ],
        Text(text,
            style: verificationCaption.copyWith(
                fontSize: 10,
                color: uploaded
                    ? DavoColors.of(context).link
                    : limited
                        ? DavoColors.of(context).warning
                        : DavoColors.of(context).success)),
      ]));
}

class VerificationRequirements extends StatelessWidget {
  const VerificationRequirements({super.key, required this.items});
  final List<(String, String)> items;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: DavoColors.of(context).offWhite,
          border: Border.all(color: DavoColors.of(context).divider),
          borderRadius: BorderRadius.circular(4)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('What you need', style: verificationHeading),
        const SizedBox(height: 20),
        for (final item in items)
          Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(children: [
                VerificationAsset(item.$1, color: DavoColors.of(context).body),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(item.$2,
                        style: verificationCaption.copyWith(
                            color: DavoColors.of(context).body)))
              ]))
      ]));
}

class VerificationNotice extends StatelessWidget {
  const VerificationNotice(this.message, {super.key, this.title});
  final String message;
  final String? title;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: DavoColors.of(context).warningSurface,
          borderRadius: BorderRadius.circular(4)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        VerificationAsset('4b750.svg',
            size: 18, color: DavoColors.of(context).body),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (title != null) ...[
            Text(title!,
                style:
                    verificationCaption.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8)
          ],
          Text(message,
              style: verificationCaption.copyWith(
                  color: DavoColors.of(context).body))
        ]))
      ]));
}

class VerificationTier extends StatelessWidget {
  const VerificationTier(
      {super.key, required this.advanced, required this.description});
  final bool advanced;
  final String description;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: DavoColors.of(context).canvas,
          border: Border.all(color: DavoColors.of(context).divider),
          borderRadius: BorderRadius.circular(4)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Your Current Tier', style: verificationCaption),
        const SizedBox(height: 12),
        Row(children: [
          VerificationAsset(advanced ? 'd72b4.svg' : 'd988f.svg', size: 32),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(advanced ? 'Advanced' : 'Basic',
                    style:
                        verificationBody.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(description, style: verificationCaption)
              ])),
          VerificationStatus(advanced ? 'Limited' : 'Verified',
              limited: advanced)
        ])
      ]));
}
