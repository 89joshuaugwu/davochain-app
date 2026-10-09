import '../motion/davo_working_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../core/theme/app_theme.dart';
import '../services/receipt_export_service.dart';
import 'davo_toast.dart';
import '../receipts/receipt_record.dart';
import '../receipts/receipt_pdf.dart';

class DavoReceiptExportFrame extends StatefulWidget {
  const DavoReceiptExportFrame(
      {super.key,
      required this.receipt,
      required this.receiptType,
      this.title = 'Transaction Receipt',
      this.service,
      this.presentation,
      this.controls,
      this.beforeCapture});
  final Widget receipt;
  final String receiptType, title;
  final ReceiptExportService? service;
  final ReceiptPresentation? presentation;
  final Widget? controls;
  final Future<void> Function()? beforeCapture;

  @override
  State<DavoReceiptExportFrame> createState() => _DavoReceiptExportFrameState();
}

class _DavoReceiptExportFrameState extends State<DavoReceiptExportFrame> {
  final _receiptKey = GlobalKey();
  late final ReceiptExportService _service =
      widget.service ?? ReceiptExportService();
  bool _busy = false;
  Widget? _captureReceipt;

  Future<void> _export(ReceiptExportFormat format) async {
    if (_busy) return;
    final presentation = widget.presentation;
    final receipt = widget.receipt;
    final receiptType = widget.receiptType;
    final beforeCapture = widget.beforeCapture;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _busy = true;
      _captureReceipt = receipt;
    });
    try {
      await beforeCapture?.call();
      if (!mounted) return;
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
      final boundary = _receiptKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) throw StateError('Receipt is unavailable.');
      final file = presentation == null
          ? await _service.export(boundary, format, receiptType)
          : await _service.exportRecord(boundary, format, presentation);
      if (!mounted) return;
      setState(() {
        _busy = false;
        _captureReceipt = null;
      });
      await showModalBottomSheet<void>(
        context: context,
        sheetAnimationStyle: (MediaQuery.disableAnimationsOf(context) ||
                MediaQuery.accessibleNavigationOf(context))
            ? AnimationStyle.noAnimation
            : const AnimationStyle(
                duration: Duration(milliseconds: 280),
                reverseDuration: Duration(milliseconds: 200)),
        showDragHandle: true,
        isScrollControlled: true,
        backgroundColor: DavoColors.of(context).elevated,
        builder: (_) => _ReceiptShareSheet(receipt: file, service: _service),
      );
    } on ReceiptPdfTextException catch (error) {
      if (mounted) showDavoToast(context, error.message);
    } catch (_) {
      if (mounted) {
        showDavoToast(
            context, 'Could not prepare your receipt. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _captureReceipt = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: DavoColors.of(context).canvas,
        appBar: AppBar(
            backgroundColor: DavoColors.of(context).surface,
            surfaceTintColor: Colors.transparent,
            centerTitle: true,
            title: widget.title.isEmpty
                ? null
                : Text(widget.title,
                    style: const TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 18,
                        fontWeight: FontWeight.w500))),
        body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.controls != null)
                      AbsorbPointer(absorbing: _busy, child: widget.controls!),
                    RepaintBoundary(
                        key: _receiptKey,
                        child: Theme(
                            data: AppTheme.light,
                            child: ColoredBox(
                                color: Colors.white,
                                child: _captureReceipt ?? widget.receipt))),
                  ]),
            )),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(children: [
                Expanded(
                    child: _ExportButton(
                        label: 'Share as image',
                        icon: Icons.image_outlined,
                        busy: _busy,
                        onPressed: () => _export(ReceiptExportFormat.image))),
                const SizedBox(width: 12),
                Expanded(
                    child: _ExportButton(
                        label: 'Share as PDF',
                        icon: Icons.picture_as_pdf_outlined,
                        busy: _busy,
                        onPressed: () => _export(ReceiptExportFormat.pdf))),
              ])),
        ),
      );
}

class _ExportButton extends StatelessWidget {
  const _ExportButton(
      {required this.label,
      required this.icon,
      required this.busy,
      required this.onPressed});
  final String label;
  final IconData icon;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton(
        onPressed: busy ? null : onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          foregroundColor: DavoColors.of(context).link,
          side: BorderSide(color: DavoColors.of(context).border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          busy ? const DavoWorkingIndicator(size: 16) : Icon(icon, size: 20),
          const SizedBox(height: 6),
          Text(busy ? 'Preparing…' : label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ]),
      );
}

class _ReceiptShareSheet extends StatefulWidget {
  const _ReceiptShareSheet({required this.receipt, required this.service});
  final ReceiptExportFile receipt;
  final ReceiptExportService service;

  @override
  State<_ReceiptShareSheet> createState() => _ReceiptShareSheetState();
}

class _ReceiptShareSheetState extends State<_ReceiptShareSheet> {
  bool _busy = false;

  Future<void> _act(BuildContext actionContext, String action) async {
    if (_busy) return;
    final box = actionContext.findRenderObject() as RenderBox?;
    final origin = box == null
        ? const Rect.fromLTWH(0, 0, 1, 1)
        : box.localToGlobal(Offset.zero) & box.size;
    setState(() => _busy = true);
    try {
      switch (action) {
        case 'Download':
          final saved = await widget.service.download(widget.receipt, origin);
          if (mounted && saved != null) {
            showDavoToast(context, 'Receipt saved to $saved');
          }
        case 'X':
          await widget.service
              .shareTo(widget.receipt, 'com.twitter.android', origin);
        case 'Telegram':
          await widget.service
              .shareTo(widget.receipt, 'org.telegram.messenger', origin);
        case 'More':
          await widget.service.shareMore(widget.receipt, origin);
      }
    } catch (_) {
      if (mounted) {
        showDavoToast(context, 'Could not open this action. Please try More.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _action(BuildContext actionContext, String action) => TextButton(
      onPressed: _busy ? null : () => _act(actionContext, action),
      style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 6),
          foregroundColor: DavoColors.of(actionContext).ink),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: action == 'X'
                    ? const Color(0xFF1C1C1C)
                    : action == 'Telegram'
                        ? const Color(0xFF29A9EA)
                        : action == 'More'
                            ? DavoColors.of(actionContext).mutedSoft
                            : AppColors.primary),
            child: Center(
                child: action == 'X' || action == 'Telegram'
                    ? Image.asset(
                        action == 'X'
                            ? 'assets/figma_exact/share_x_native_exact.png'
                            : 'assets/figma_exact/share_telegram_native_exact.png',
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high)
                    : Icon(
                        action == 'Download'
                            ? Icons.download_rounded
                            : Icons.more_horiz_rounded,
                        size: 24,
                        color: action == 'More'
                            ? DavoColors.of(actionContext).ink
                            : Colors.white))),
        const SizedBox(height: 6),
        Text(action,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 10, height: 1.3, fontWeight: FontWeight.w500)),
      ]));

  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        child: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 28),
          child: LayoutBuilder(
              builder: (context, constraints) =>
                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Container(
                        width: constraints.maxWidth >= 360 ? 84 : 64,
                        height: 124,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFFB3B3B3)),
                            borderRadius: BorderRadius.circular(4)),
                        child: Image.memory(widget.receipt.previewPng,
                            fit: BoxFit.contain)),
                    const SizedBox(width: 14),
                    Expanded(
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          const Text('Share',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text(
                              'Share your ${widget.receipt.receiptType.toLowerCase()} receipt as ${widget.receipt.format == ReceiptExportFormat.pdf ? 'PDF' : 'an image'} or save it for later.',
                              style: TextStyle(
                                  fontSize: 12,
                                  height: 1.4,
                                  color: DavoColors.of(context).body)),
                          const SizedBox(height: 10),
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (final action in const [
                                  'Download',
                                  'X',
                                  'Telegram',
                                  'More'
                                ])
                                  Expanded(
                                      child: Builder(
                                          builder: (context) =>
                                              _action(context, action))),
                              ]),
                          if (_busy)
                            const Text('Opening\u2026',
                                style: TextStyle(fontSize: 12)),
                        ])),
                  ])),
        )),
      );
}
