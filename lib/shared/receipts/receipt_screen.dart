import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/davo_receipt_export_frame.dart';
import 'receipt_record.dart';

class ReceiptScreen extends StatefulWidget {
  const ReceiptScreen({super.key, required this.record});
  final ReceiptRecord record;
  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  bool _showSensitive = false;
  String _note = '';
  // Other ReceiptStyle variants and their artwork remain available in the
  // shared presentation model for future work. Only standard is exposed now.
  @override
  Widget build(BuildContext context) {
    final view = ReceiptPresentation(
        record: widget.record,
        style: ReceiptStyle.standard,
        note: _note,
        showSensitive: _showSensitive);
    return DavoReceiptExportFrame(
        title: '',
        receiptType: widget.record.type,
        presentation: view,
        controls:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(
              maxLength: 240,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              maxLines: 3,
              minLines: 1,
              style: const TextStyle(fontFamily: 'Sora', fontSize: 12),
              decoration: const InputDecoration(
                  labelText: 'Personal note (optional)',
                  border: OutlineInputBorder(),
                  counterStyle: TextStyle(fontSize: 10)),
              onChanged: (value) => setState(() => _note = value)),
          if (widget.record.fields.any((field) => field.sensitive))
            SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                activeTrackColor: AppColors.primary,
                activeThumbColor: Colors.white,
                title: const Text('Show sensitive details',
                    style: TextStyle(fontFamily: 'Sora', fontSize: 12)),
                subtitle: const Text(
                    'Include full account or wallet details in exports',
                    style: TextStyle(fontFamily: 'Sora', fontSize: 10)),
                value: _showSensitive,
                onChanged: (value) => setState(() => _showSensitive = value)),
          const SizedBox(height: 12),
        ]),
        receipt: ReceiptPaper(presentation: view));
  }
}

/// This same masked presentation is used for PNG capture and selectable PDF.
class ReceiptPaper extends StatelessWidget {
  const ReceiptPaper({super.key, required this.presentation});
  final ReceiptPresentation presentation;
  @override
  Widget build(BuildContext context) {
    final record = presentation.record;
    return Container(
        color: Colors.white,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: DefaultTextStyle(
            style: const TextStyle(
                fontFamily: 'Sora',
                fontFamilyFallback: ['DavoNotoSans', 'DavoNotoEmoji'],
                fontSize: 12,
                height: 1.5,
                color: AppColors.ink),
            child: Stack(children: [
              Positioned(
                  right: 0,
                  top: 75,
                  child: Opacity(
                      opacity: .035,
                      child: Image.asset(
                          'assets/images/brand/davochain_logo.png',
                          width: 140,
                          height: 130))),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    children: [
                      Image.asset('assets/images/brand/davochain_logo.png',
                          width: 36, height: 32),
                      const Text('Davochain',
                          style: TextStyle(
                              fontSize: 22,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700)),
                    ]),
                const SizedBox(height: 14),
                if (record.preview) ...[
                  Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      color: AppColors.primarySoft,
                      child: const Text('Preview',
                          style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600))),
                  const SizedBox(height: 14),
                ],
                if (presentation.style != ReceiptStyle.standard) ...[
                  SizedBox(
                      width: double.infinity,
                      height: 80,
                      child:
                          CustomPaint(painter: _BlueMotif(presentation.style))),
                  const SizedBox(height: 12),
                ],
                Text(presentation.style.heading,
                    style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 14),
                Text(record.amount,
                    style: const TextStyle(
                        fontSize: 23, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Text(record.type),
                const SizedBox(height: 10),
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: record.status == ReceiptStatus.failed
                            ? const Color(0xFFFFF1F0)
                            : record.status == ReceiptStatus.pending
                                ? const Color(0xFFFEF9F1)
                                : AppColors.primarySoft,
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(record.status.label,
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: record.status == ReceiptStatus.failed
                                ? const Color(0xFFB42318)
                                : record.status == ReceiptStatus.pending
                                    ? const Color(0xFF986000)
                                    : AppColors.primary))),
                const SizedBox(height: 20),
                for (final field in presentation.allDisplayFields) ...[
                  Text(field.label,
                      style: const TextStyle(
                          fontSize: 10, color: AppColors.bodyMuted)),
                  const SizedBox(height: 4),
                  Text(field.value, style: const TextStyle(fontSize: 12)),
                  const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1, color: AppColors.mutedSoft)),
                ],
                if (presentation.note.trim().isNotEmpty) ...[
                  const Text('Personal note',
                      style: TextStyle(fontSize: 10, color: AppColors.primary)),
                  const SizedBox(height: 5),
                  Text(presentation.note),
                  const SizedBox(height: 16),
                ],
                const Text('Your Davochain transaction record',
                    style: TextStyle(fontSize: 10, color: AppColors.bodyMuted)),
              ]),
            ])));
  }
}

class _BlueMotif extends CustomPainter {
  const _BlueMotif(this.style);
  final ReceiptStyle style;
  @override
  void paint(Canvas canvas, Size size) {
    final ink = Paint()..color = AppColors.primary;
    final pale = Paint()..color = AppColors.primarySoft;
    canvas.drawRRect(
        RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(16)),
        pale);
    final center = Offset(size.width / 2, size.height / 2);
    if (style == ReceiptStyle.appreciation) {
      final path = Path()
        ..moveTo(center.dx, center.dy + 22)
        ..cubicTo(center.dx - 50, center.dy - 8, center.dx - 20, center.dy - 35,
            center.dx, center.dy - 12)
        ..cubicTo(center.dx + 20, center.dy - 35, center.dx + 50, center.dy - 8,
            center.dx, center.dy + 22);
      canvas.drawPath(path, ink);
    } else if (style == ReceiptStyle.birthday) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromCenter(
                  center: center.translate(0, 8), width: 54, height: 32),
              const Radius.circular(4)),
          ink);
      canvas.drawRect(
          Rect.fromCenter(center: center.translate(0, 8), width: 5, height: 32),
          Paint()..color = Colors.white);
      for (final x in [-15.0, 0.0, 15.0]) {
        canvas.drawLine(center.translate(x, -25), center.translate(x, -12),
            ink..strokeWidth = 3);
      }
    } else {
      for (var i = 0; i < 9; i++) {
        final point = Offset(20 + (size.width - 40) * i / 8, 15 + (i % 3) * 22);
        canvas.drawCircle(point, i.isEven ? 5 : 3, ink);
        if (i.isOdd) {
          canvas.drawLine(point.translate(-5, -6), point.translate(5, 6),
              ink..strokeWidth = 2);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_BlueMotif oldDelegate) => style != oldDelegate.style;
}
