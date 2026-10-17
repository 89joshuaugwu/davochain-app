import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:qr/qr.dart' as qr;

/// Encodes the actual copied address, with a four-module quiet zone.
class DavoAddressQr extends StatelessWidget {
  const DavoAddressQr({super.key, required this.data});
  final String data;
  @override
  Widget build(BuildContext context) => Semantics(
    image: true,
    label: 'Test receiving address QR code',
    child: CustomPaint(
      painter: _AddressQrPainter(data),
      child: const SizedBox.expand(),
    ),
  );
}

class _AddressQrPainter extends CustomPainter {
  _AddressQrPainter(this.data)
    : image = qr.QrImage(
        qr.QrCode.fromData(
          data: data,
          errorCorrectLevel: qr.QrErrorCorrectLevel.H,
        ),
      );
  final String data;
  final qr.QrImage image;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    final side = math.min(size.width, size.height);
    final unit = side / (image.moduleCount + 8);
    final left = (size.width - side) / 2 + 4 * unit;
    final top = (size.height - side) / 2 + 4 * unit;
    final paint = Paint()
      ..color = Colors.black
      ..isAntiAlias = false;
    for (var row = 0; row < image.moduleCount; row++) {
      for (var col = 0; col < image.moduleCount; col++) {
        if (image.isDark(row, col)) {
          canvas.drawRect(
            Rect.fromLTWH(left + col * unit, top + row * unit, unit, unit),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _AddressQrPainter oldDelegate) =>
      oldDelegate.data != data;
}
