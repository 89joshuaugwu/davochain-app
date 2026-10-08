import 'package:flutter/material.dart';

/// Context-owned UI colors. Brand and paper colors remain immutable AppColors.
class DavoColors extends ThemeExtension<DavoColors> {
  const DavoColors({required this.surface,required this.elevated,required this.canvas,required this.ink,required this.inkStrong,required this.body,required this.bodyMuted,required this.muted,required this.border,required this.divider,required this.fieldFill,required this.offWhite,required this.mutedSoft,required this.primarySoft,required this.primaryDisabled,required this.link,required this.success,required this.successSurface,required this.warning,required this.warningSurface,required this.warningBorder,required this.danger,required this.dangerSurface});
  final Color surface;
  final Color elevated;
  final Color canvas;
  final Color ink;
  final Color inkStrong;
  final Color body;
  final Color bodyMuted;
  final Color muted;
  final Color border;
  final Color divider;
  final Color fieldFill;
  final Color offWhite;
  final Color mutedSoft;
  final Color primarySoft;
  final Color primaryDisabled;
  final Color link;
  final Color success;
  final Color successSurface;
  final Color warning;
  final Color warningSurface;
  final Color warningBorder;
  final Color danger;
  final Color dangerSurface;
  bool get isDark => surface.computeLuminance() < 0.1;
  static DavoColors of(BuildContext context) => Theme.of(context).extension<DavoColors>() ?? (Theme.of(context).brightness == Brightness.dark ? dark : light);
  static const light = DavoColors(
    surface: Color(0xFFFFFFFF),
    elevated: Color(0xFFFFFFFF),
    canvas: Color(0xFFF8F9FB),
    ink: Color(0xFF1C1C1C),
    inkStrong: Color(0xFF1A1C20),
    body: Color(0xFF424242),
    bodyMuted: Color(0xFF686868),
    muted: Color(0xFFA7A7A7),
    border: Color(0xFFD2D2D2),
    divider: Color(0xFFEBEDF3),
    fieldFill: Color(0xFFFFFFFF),
    offWhite: Color(0xFFF8F9FB),
    mutedSoft: Color(0xFFEBEDF3),
    primarySoft: Color(0xFFEDF2FD),
    primaryDisabled: Color(0xFFD0DEFD),
    link: Color(0xFF135CF7),
    success: Color(0xFF13803D),
    successSurface: Color(0xFFF0FAF3),
    warning: Color(0xFF986000),
    warningSurface: Color(0xFFFEF9F1),
    warningBorder: Color(0xFFF5F0C5),
    danger: Color(0xFFB42318),
    dangerSurface: Color(0xFFFFF1F0),
  );
  static const dark = DavoColors(
    surface: Color(0xFF101827),
    elevated: Color(0xFF192437),
    canvas: Color(0xFF0B1220),
    ink: Color(0xFFF3F6FC),
    inkStrong: Color(0xFFF3F6FC),
    body: Color(0xFFF3F6FC),
    bodyMuted: Color(0xFFAAB6C8),
    muted: Color(0xFF96A5BC),
    border: Color(0xFF60738F),
    divider: Color(0xFF2B3B53),
    fieldFill: Color(0xFF162135),
    offWhite: Color(0xFF0B1220),
    mutedSoft: Color(0xFF192437),
    primarySoft: Color(0xFF1B2E55),
    primaryDisabled: Color(0xFF233858),
    link: Color(0xFF8EADFF),
    success: Color(0xFF66D991),
    successSurface: Color(0xFF153327),
    warning: Color(0xFFF4C46C),
    warningSurface: Color(0xFF382B17),
    warningBorder: Color(0xFF785D31),
    danger: Color(0xFFFF9A94),
    dangerSurface: Color(0xFF3B2228),
  );
  @override
  DavoColors copyWith({Color? surface,Color? elevated,Color? canvas,Color? ink,Color? inkStrong,Color? body,Color? bodyMuted,Color? muted,Color? border,Color? divider,Color? fieldFill,Color? offWhite,Color? mutedSoft,Color? primarySoft,Color? primaryDisabled,Color? link,Color? success,Color? successSurface,Color? warning,Color? warningSurface,Color? warningBorder,Color? danger,Color? dangerSurface}) => DavoColors(
    surface: surface ?? this.surface,
    elevated: elevated ?? this.elevated,
    canvas: canvas ?? this.canvas,
    ink: ink ?? this.ink,
    inkStrong: inkStrong ?? this.inkStrong,
    body: body ?? this.body,
    bodyMuted: bodyMuted ?? this.bodyMuted,
    muted: muted ?? this.muted,
    border: border ?? this.border,
    divider: divider ?? this.divider,
    fieldFill: fieldFill ?? this.fieldFill,
    offWhite: offWhite ?? this.offWhite,
    mutedSoft: mutedSoft ?? this.mutedSoft,
    primarySoft: primarySoft ?? this.primarySoft,
    primaryDisabled: primaryDisabled ?? this.primaryDisabled,
    link: link ?? this.link,
    success: success ?? this.success,
    successSurface: successSurface ?? this.successSurface,
    warning: warning ?? this.warning,
    warningSurface: warningSurface ?? this.warningSurface,
    warningBorder: warningBorder ?? this.warningBorder,
    danger: danger ?? this.danger,
    dangerSurface: dangerSurface ?? this.dangerSurface,
  );
  @override
  DavoColors lerp(covariant DavoColors? other, double t) {
    if (other == null) return this;
    return DavoColors(
      surface: Color.lerp(surface, other.surface, t)!,
      elevated: Color.lerp(elevated, other.elevated, t)!,
      canvas: Color.lerp(canvas, other.canvas, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkStrong: Color.lerp(inkStrong, other.inkStrong, t)!,
      body: Color.lerp(body, other.body, t)!,
      bodyMuted: Color.lerp(bodyMuted, other.bodyMuted, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      border: Color.lerp(border, other.border, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      fieldFill: Color.lerp(fieldFill, other.fieldFill, t)!,
      offWhite: Color.lerp(offWhite, other.offWhite, t)!,
      mutedSoft: Color.lerp(mutedSoft, other.mutedSoft, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      primaryDisabled: Color.lerp(primaryDisabled, other.primaryDisabled, t)!,
      link: Color.lerp(link, other.link, t)!,
      success: Color.lerp(success, other.success, t)!,
      successSurface: Color.lerp(successSurface, other.successSurface, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningSurface: Color.lerp(warningSurface, other.warningSurface, t)!,
      warningBorder: Color.lerp(warningBorder, other.warningBorder, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerSurface: Color.lerp(dangerSurface, other.dangerSurface, t)!,
    );
  }
}
