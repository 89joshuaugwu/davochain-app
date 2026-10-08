import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Official, unaltered Solana logomark with clear space on a dark token disc.
class SolanaIcon extends StatelessWidget {
  const SolanaIcon({super.key, this.size = 37});
  final double size;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * .2),
        decoration:
            const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
        child: SvgPicture.asset('assets/images/brand/solana_mark.svg',
            fit: BoxFit.contain),
      );
}
