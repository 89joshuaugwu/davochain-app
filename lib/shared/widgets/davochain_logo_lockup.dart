import 'package:flutter/material.dart';

class DavochainLogoLockup extends StatelessWidget {
  const DavochainLogoLockup({
    super.key,
    this.logoColor,
    this.textColor = Colors.white,
    this.logoWidth = 58,
    this.fontSize = 40,
  });

  final Color? logoColor;
  final Color textColor;
  final double logoWidth;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/images/brand/davochain_logo.png',
      width: logoWidth,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        logoColor == null
            ? image
            : ColorFiltered(
                colorFilter: ColorFilter.mode(logoColor!, BlendMode.srcIn),
                child: image,
              ),
        const SizedBox(width: 10),
        Text(
          'Davochain',
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            height: 1,
            letterSpacing: 0.2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
