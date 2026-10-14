import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Resolution independent action glyphs. Asset and brand marks remain images.
enum DavoActionGlyph {
  gift,
  giftAction,
  notifications,
  visible,
  hidden,
  deposit,
  withdraw,
  buy,
  sell,
  history,
  copy,
  back,
  forward,
  add,
  information,
  home,
  trade,
  settings,
}

class DavoActionIcon extends StatelessWidget {
  const DavoActionIcon(this.glyph, {super.key, this.size = 24, this.color});
  final DavoActionGlyph glyph;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final vector = switch (glyph) {
      DavoActionGlyph.home => 'davo_home.svg',
      DavoActionGlyph.gift => 'davo_gift_outline.svg',
      DavoActionGlyph.giftAction => 'davo_gift_action.svg',
      DavoActionGlyph.visible => 'davo_eye.svg',
      DavoActionGlyph.buy => 'davo_buy.svg',
      DavoActionGlyph.sell => 'davo_sell.svg',
      _ => null,
    };
    if (vector != null) {
      return SvgPicture.asset('assets/figma_exact/$vector',
          width: size,
          height: size,
          colorFilter: ColorFilter.mode(
              color ?? IconTheme.of(context).color ?? Colors.black,
              BlendMode.srcIn),
          excludeFromSemantics: true);
    }
    return Icon(
        switch (glyph) {
          DavoActionGlyph.gift => Icons.card_giftcard_outlined,
          DavoActionGlyph.giftAction => Icons.card_giftcard_outlined,
          DavoActionGlyph.notifications => Icons.notifications_none_rounded,
          DavoActionGlyph.visible => Icons.visibility_outlined,
          DavoActionGlyph.hidden => Icons.visibility_off_outlined,
          DavoActionGlyph.deposit => Icons.add_circle_outline_rounded,
          DavoActionGlyph.withdraw => Icons.arrow_outward_rounded,
          DavoActionGlyph.buy => Icons.south_west_rounded,
          DavoActionGlyph.sell => Icons.north_east_rounded,
          DavoActionGlyph.history => Icons.history_rounded,
          DavoActionGlyph.copy => Icons.copy_outlined,
          DavoActionGlyph.back => Icons.arrow_back_rounded,
          DavoActionGlyph.forward => Icons.chevron_right_rounded,
          DavoActionGlyph.add => Icons.add_circle_outline_rounded,
          DavoActionGlyph.information => Icons.info_outline_rounded,
          DavoActionGlyph.home => Icons.home_outlined,
          DavoActionGlyph.trade => Icons.swap_horiz_rounded,
          DavoActionGlyph.settings => Icons.settings_outlined,
        },
        applyTextScaling: false,
        size: size,
        color: color);
  }
}
