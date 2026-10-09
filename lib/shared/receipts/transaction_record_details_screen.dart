import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/navigation/app_page_route.dart';
import '../../core/theme/app_theme.dart';
import '../../features/profile_settings/presentation/settings_personal_action_flows.dart';
import '../widgets/auth_widgets.dart';
import '../widgets/davo_toast.dart';
import 'receipt_record.dart';
import 'receipt_screen.dart';

/// Details and support always use the same accepted facts as the receipt.
class TransactionRecordDetailsScreen extends StatefulWidget {
  const TransactionRecordDetailsScreen({
    super.key,
    required this.record,
    this.receiptBuilder,
    this.onDone,
  });
  final ReceiptRecord record;
  final WidgetBuilder? receiptBuilder;
  final VoidCallback? onDone;

  @override
  State<TransactionRecordDetailsScreen> createState() =>
      _TransactionRecordDetailsScreenState();
}

class _TransactionRecordDetailsScreenState
    extends State<TransactionRecordDetailsScreen> {
  bool _expanded = false;
  bool _sharing = false;

  Future<void> _copy(String value, String label) async {
    try {
      await Clipboard.setData(ClipboardData(text: value));
      if (mounted) showDavoToast(context, '$label copied.');
    } catch (_) {
      if (mounted) showDavoToast(context, 'Could not copy. Please try again.');
    }
  }

  void _report() {
    final record = widget.record;
    final facts = record.fields.where((field) => !field.sensitive);
    Navigator.of(context).push(AppPageRoute<void>(
      builder: (_) => EmailSupportScreen(
        initialSubject: '${record.type} issue',
        initialOrderId: record.id,
        initialMessage: [
          'Transaction: ${record.id}',
          'Reference: ${record.reference}',
          'Type: ${record.type}',
          'Amount: ${record.amount}',
          'Status: ${_statusLabel(record.status)}',
          'Date: ${formatReceiptDate(record.occurredAt)}',
          if (record.preview) 'Preview transaction',
          for (final field in facts) '${field.label}: ${field.value}',
          '',
          'Please describe the issue:',
        ].join('\n'),
      ),
    ));
  }

  Future<void> _shareExplorer(Uri uri) async {
    if (_sharing) return;
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null && box.hasSize
        ? box.localToGlobal(Offset.zero) & box.size
        : null;
    setState(() => _sharing = true);
    try {
      await SharePlus.instance.share(ShareParams(
        text: uri.toString(),
        title: 'Transaction explorer',
        sharePositionOrigin: origin,
      ));
    } catch (_) {
      if (mounted) {
        showDavoToast(
            context, 'Could not open sharing. Copy the link instead.');
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final record = widget.record;
    final colors = DavoColors.of(context);
    final statusColor = switch (record.status) {
      ReceiptStatus.completed => colors.success,
      ReceiptStatus.failed => colors.danger,
      ReceiptStatus.pending => colors.warning,
    };
    final summary = record.fields.where((field) => const [
          'Wallet',
          'Currency',
          'Destination',
          'Bank',
          'Account',
          'Account number',
          'Network',
          'Asset',
          'Amount',
          'From',
          'To',
          'Total Received',
          'Paid from',
          'Amount paid',
        ].contains(field.label));
    final extra = record.fields.where((field) => !summary.contains(field));
    final explorer = _explorerUri(record);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('${record.type} details',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.primarySoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(children: [
                Icon(_directionIcon(record.type), color: colors.link, size: 28),
                const SizedBox(height: 12),
                Text(record.type,
                    style: TextStyle(fontSize: 12, color: colors.bodyMuted)),
                const SizedBox(height: 8),
                Text(record.amount,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: colors.ink)),
                const SizedBox(height: 10),
                Text(_statusLabel(record.status),
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: statusColor)),
                const SizedBox(height: 8),
                Text(formatReceiptDate(record.occurredAt),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11, color: colors.bodyMuted)),
                if (record.preview) ...[
                  const SizedBox(height: 12),
                  const Text('Preview only. No funds have been moved.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11)),
                ],
              ]),
            ),
            const SizedBox(height: 20),
            _group(context, 'Transaction', [
              for (final field in summary) _field(context, field),
            ]),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () => setState(() => _expanded = !_expanded),
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              label: Text(_expanded ? 'Less details' : 'More details'),
            ),
            if (_expanded)
              _group(context, 'Details', [
                _field(
                    context,
                    ReceiptField(
                        label: 'Transaction ID',
                        value: record.id,
                        copyable: true)),
                if (record.reference != record.id)
                  _field(
                      context,
                      ReceiptField(
                          label: 'Reference',
                          value: record.reference,
                          copyable: true)),
                for (final field in extra)
                  if (field.label != 'Transaction ID' &&
                      field.label != 'Reference')
                    _field(context, field),
                if (explorer != null) ...[
                  const SizedBox(height: 8),
                  const Text('Transaction explorer',
                      style: TextStyle(fontSize: 12)),
                  Wrap(spacing: 8, children: [
                    TextButton.icon(
                      onPressed: () =>
                          _copy(explorer.toString(), 'Explorer link'),
                      icon: const Icon(Icons.link, size: 16),
                      label: const Text('Copy link'),
                    ),
                    TextButton.icon(
                      onPressed:
                          _sharing ? null : () => _shareExplorer(explorer),
                      icon: const Icon(Icons.share_outlined, size: 16),
                      label: const Text('Share link'),
                    ),
                  ]),
                ],
              ]),
            if (record.events.isNotEmpty) ...[
              const SizedBox(height: 20),
              _group(context, 'Timeline', [
                for (final event in record.events) _event(context, event),
              ]),
            ],
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _report,
              icon: const Icon(Icons.help_outline, size: 18),
              label: const Text('Report Issue'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            DavoPrimaryButton(
              label: 'Share Receipt',
              onPressed: () => Navigator.of(context).push(AppPageRoute<void>(
                builder: widget.receiptBuilder ??
                    (_) => ReceiptScreen(record: record),
              )),
            ),
            TextButton(
                onPressed: widget.onDone ?? () => Navigator.maybePop(context),
                child: const Text('Done')),
          ]),
        ),
      ),
    );
  }

  Widget _group(BuildContext context, String title, List<Widget> children) {
    final colors = DavoColors.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          border: Border.all(color: colors.divider),
          borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text(title,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: colors.ink)),
        const SizedBox(height: 8),
        ...children,
      ]),
    );
  }

  Widget _field(BuildContext context, ReceiptField field) {
    final colors = DavoColors.of(context);
    final account = const ['account', 'account number', 'bank account']
        .contains(field.label.trim().toLowerCase());
    final text = field.sensitive
        ? account && field.value.length > 4
            ? '•••• ${field.value.substring(field.value.length - 4)}'
            : '••••'
        : field.value;
    final display = field.copyable && text.length > 38
        ? '${text.substring(0, 16)}…${text.substring(text.length - 12)}'
        : text;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
            flex: 2,
            child: Text(field.label,
                style: TextStyle(fontSize: 12, color: colors.bodyMuted))),
        const SizedBox(width: 12),
        Expanded(
            flex: 3,
            child: Text(display,
                textAlign: TextAlign.right,
                style:
                    TextStyle(fontSize: 12, height: 1.5, color: colors.ink))),
        if (field.copyable)
          SizedBox(
              width: 36,
              height: 36,
              child: IconButton(
                padding: EdgeInsets.zero,
                tooltip: 'Copy ${field.label}',
                onPressed: () => _copy(field.value, field.label),
                icon: Icon(Icons.copy_outlined, size: 16, color: colors.link),
              )),
      ]),
    );
  }

  Widget _event(BuildContext context, ReceiptEvent event) {
    final colors = DavoColors.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(
            switch (event.state) {
              ReceiptEventState.complete => Icons.check_circle_outline,
              ReceiptEventState.current => Icons.schedule,
              ReceiptEventState.upcoming => Icons.radio_button_unchecked,
            },
            size: 18,
            color: event.state == ReceiptEventState.upcoming
                ? colors.muted
                : colors.link),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(event.label,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(event.description,
              style: TextStyle(
                  fontSize: 11, height: 1.5, color: colors.bodyMuted)),
          if (event.occurredAt != null) ...[
            const SizedBox(height: 4),
            Text(formatReceiptDate(event.occurredAt!),
                style: TextStyle(fontSize: 10, color: colors.bodyMuted)),
          ],
        ])),
      ]),
    );
  }
}

String _statusLabel(ReceiptStatus status) => switch (status) {
      ReceiptStatus.pending => 'Pending',
      ReceiptStatus.completed => 'Completed',
      ReceiptStatus.failed => 'Failed',
    };

IconData _directionIcon(String type) {
  final value = type.toLowerCase();
  if (value.contains('deposit') ||
      value.contains('receive') ||
      value.contains('buy') ||
      value.contains('purchase')) {
    return Icons.south_west;
  }
  if (value.contains('withdraw') ||
      value.contains('send') ||
      value.contains('sell') ||
      value.contains('transfer')) {
    return Icons.north_east;
  }
  return Icons.swap_horiz;
}

Uri? _explorerUri(ReceiptRecord record) {
  String? network, hash;
  for (final field in record.fields) {
    final label = field.label.trim().toLowerCase();
    if (label == 'network') network = field.value.toLowerCase().trim();
    if (label == 'transaction hash') hash = field.value.trim();
  }
  if (hash == null || network == null) return null;
  if (network == 'bitcoin' || network == 'btc') {
    if (!RegExp(r'^[a-fA-F0-9]{64}$').hasMatch(hash)) return null;
    return Uri.https('mempool.space', '/tx/$hash');
  }
  final host = switch (network) {
    'ethereum' || 'erc20' || 'erc-20' => 'etherscan.io',
    'bsc' || 'bnb smart chain' || 'bep20' || 'bep-20' => 'bscscan.com',
    'polygon' || 'polygon pos' => 'polygonscan.com',
    _ => null,
  };
  if (host == null || !RegExp(r'^0x[a-fA-F0-9]{64}$').hasMatch(hash)) {
    return null;
  }
  return Uri.https(host, '/tx/$hash');
}
