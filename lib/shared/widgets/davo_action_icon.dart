import 'package:flutter/material.dart';

/// Resolution independent action glyphs. Asset and brand marks remain images.
enum DavoActionGlyph {
  gift,
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
  Widget build(BuildContext context) => Icon(
      switch (glyph) {
        DavoActionGlyph.gift => Icons.card_giftcard_outlined,
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
