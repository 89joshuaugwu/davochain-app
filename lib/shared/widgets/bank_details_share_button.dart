import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_theme.dart';
import 'auth_widgets.dart';

@immutable
class BankDepositDetails {
  const BankDepositDetails({
    required this.accountName,
    required this.bankName,
    required this.accountNumber,
    required this.wallet,
    this.isPreview = false,
  });

  static const preview = BankDepositDetails(
    accountName: 'Ogbonnia Chukwu Vincent (DVC)',
    bankName: 'Paystack-Titan',
    accountNumber: '542100896436',
    wallet: 'NGD',
    isPreview: true,
  );

  final String accountName;
  final String bankName;
  final String accountNumber;
  final String wallet;
  final bool isPreview;

  String get shareText => [
        'Davochain $wallet deposit details${isPreview ? ' (preview)' : ''}',
        'Account name: $accountName',
        'Bank name: $bankName',
        'Account number: $accountNumber',
      ].join('\n');
}

class BankDetailsShareButton extends StatefulWidget {
  const BankDetailsShareButton({super.key, required this.details});

  final BankDepositDetails details;

  @override
  State<BankDetailsShareButton> createState() => _BankDetailsShareButtonState();
}

class _BankDetailsShareButtonState extends State<BankDetailsShareButton> {
  final _buttonKey = GlobalKey();
  bool _busy = false;
  String? _message;
  bool _offerCopy = false;

  Future<void> _share() async {
    if (_busy) return;
    final box = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    final origin = box != null && box.hasSize
        ? box.localToGlobal(Offset.zero) & box.size
        : null;
    setState(() {
      _busy = true;
      _message = null;
      _offerCopy = false;
    });
    try {
      await SharePlus.instance.share(ShareParams(
        text: widget.details.shareText,
        title: 'Davochain bank details',
        sharePositionOrigin: origin,
      ));
      // A composer result cannot confirm that a recipient received the details.
    } catch (_) {
      if (mounted) {
        setState(() {
          _message =
              'Could not open sharing. You can copy the details instead.';
          _offerCopy = true;
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _copy() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await Clipboard.setData(ClipboardData(text: widget.details.shareText));
      if (mounted) setState(() => _message = 'Bank details copied.');
    } catch (_) {
      if (mounted) {
        setState(() => _message = 'Could not copy details. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          DavoPrimaryButton(
            key: _buttonKey,
            label: 'Share Details',
            loading: _busy,
            onPressed: _share,
          ),
          if (_message != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Semantics(
                liveRegion: true,
                child: Text(_message!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: DavoColors.of(context).body,
                        )),
              ),
            ),
          if (_offerCopy)
            TextButton(
              onPressed: _busy ? null : _copy,
              child: const Text('Copy Details'),
            ),
        ],
      );
}
