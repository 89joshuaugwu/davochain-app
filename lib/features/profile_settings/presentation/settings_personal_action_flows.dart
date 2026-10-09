import '../../../shared/widgets/davo_points_coin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/preview/settings_preview_session.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/password_strength_palette.dart';
import '../../../shared/motion/davo_motion_spec.dart';
import '../../../shared/widgets/auth_widgets.dart';
import '../../../shared/widgets/davo_result_screen.dart';
import '../../../shared/widgets/davo_toast.dart';

TextStyle _copy(BuildContext context, {Color? color, bool bold = false}) =>
    TextStyle(
        fontFamily: 'Sora',
        fontSize: 12,
        height: 1.6,
        color: color ?? DavoColors.of(context).body,
        fontWeight: bold ? FontWeight.w600 : FontWeight.w400);

class _FormPage extends StatelessWidget {
  const _FormPage(
      {required this.title,
      required this.children,
      required this.action,
      this.busy = false});
  final String title;
  final List<Widget> children;
  final Widget action;
  final bool busy;
  @override
  Widget build(BuildContext context) => PopScope(
      canPop: !busy,
      child: DavoAuthScaffold(
        onBack: () {
          if (!busy) Navigator.maybePop(context);
        },
        bottom: action,
        child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.only(bottom: 24),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: DavoColors.of(context).ink)),
              const SizedBox(height: 12),
              Divider(color: DavoColors.of(context).divider),
              const SizedBox(height: 12),
              ...children,
            ])),
      ));
}

class _Entry extends StatefulWidget {
  const _Entry(
      {required this.label,
      required this.controller,
      required this.onChanged,
      this.secret = false,
      this.lines = 1,
      this.enabled = true,
      this.number = false});
  final String label;
  final TextEditingController controller;
  final VoidCallback onChanged;
  final bool secret, enabled, number;
  final int lines;
  @override
  State<_Entry> createState() => _EntryState();
}

class _EntryState extends State<_Entry> {
  bool visible = false;
  @override
  Widget build(BuildContext context) => Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.label,
            style: _copy(context).copyWith(fontSize: 14, height: 1.35)),
        const SizedBox(height: 8),
        TextField(
            keyboardAppearance: Theme.of(context).brightness,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            controller: widget.controller,
            enabled: widget.enabled,
            onChanged: (_) => widget.onChanged(),
            obscureText: widget.secret && !visible,
            maxLines: widget.lines,
            keyboardType: widget.number
                ? TextInputType.number
                : widget.lines > 1
                    ? TextInputType.multiline
                    : TextInputType.text,
            inputFormatters:
                widget.number ? [FilteringTextInputFormatter.digitsOnly] : null,
            enableSuggestions: !widget.secret,
            autocorrect: !widget.secret,
            style: _copy(context).copyWith(fontSize: 14),
            decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: widget.secret
                    ? IconButton(
                        tooltip: visible
                            ? 'Hide ${widget.label.toLowerCase()}'
                            : 'Show ${widget.label.toLowerCase()}',
                        onPressed: widget.enabled
                            ? () => setState(() => visible = !visible)
                            : null,
                        icon: Icon(
                            visible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20))
                    : null)),
      ]));
}

Widget _error(BuildContext context, String? error) => error == null
    ? const SizedBox.shrink()
    : Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Semantics(
            liveRegion: true,
            child: Text(error,
                style: _copy(context, color: DavoColors.of(context).danger))));
Widget _done(BuildContext context, String label) => DavoPrimaryButton(
    label: label, onPressed: () => Navigator.maybePop(context));

class _RewardStats extends StatelessWidget {
  const _RewardStats({required this.session});
  final SettingsPreviewSession session;
  @override
  Widget build(BuildContext context) =>
      LayoutBuilder(builder: (context, constraints) {
        final twoColumns = constraints.maxWidth >= 280 &&
            MediaQuery.textScalerOf(context).scale(14) <= 21;
        final tileWidth =
            twoColumns ? (constraints.maxWidth - 10) / 2 : constraints.maxWidth;
        final items = <(String, String)>[
          ('Earned Points', session.earnedPoints.toStringAsFixed(2)),
          ('Redeemed Points', session.redeemedPoints.toStringAsFixed(2)),
          ('Available Points', session.availablePoints.toStringAsFixed(2)),
          ('Rate', '20.00 = NGN 1.00'),
        ];
        return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: items
                .map((item) => Container(
                      width: tileWidth,
                      constraints: const BoxConstraints(minHeight: 96),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: DavoColors.of(context).offWhite,
                          borderRadius: BorderRadius.circular(8)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.$1, style: _copy(context)),
                            const SizedBox(height: 12),
                            DavoPointsAmount(
                                text: item.$2,
                                style: _copy(context,
                                        color: DavoColors.of(context).link,
                                        bold: true)
                                    .copyWith(fontSize: 14)),
                          ]),
                    ))
                .toList());
      });
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen(
      {super.key, this.gateway = const PreviewSettingsGateway()});
  final SettingsGateway gateway;
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final old = TextEditingController(),
      next = TextEditingController(),
      confirm = TextEditingController();
  bool busy = false, accepted = false;
  String? error;
  bool get lengthOk => next.text.length >= 8;
  bool get capital => RegExp(r'[A-Z]').hasMatch(next.text);
  bool get numberOrSymbol =>
      RegExp(r'[0-9!@#$%^&*(),.?":{}|<>_+\-=\[\]\\;/]').hasMatch(next.text);
  int get score =>
      (lengthOk ? 1 : 0) + (capital ? 1 : 0) + (numberOrSymbol ? 1 : 0);
  bool get valid =>
      old.text.isNotEmpty &&
      score == 3 &&
      next.text != old.text &&
      confirm.text == next.text;
  @override
  void dispose() {
    old.dispose();
    next.dispose();
    confirm.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (busy || !valid) return;
    final session = SettingsPreviewSession.instance,
        generation = SettingsPreviewSession.instance.generation;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.gateway.changePassword(old.text, next.text);
      if (!mounted ||
          session.generation != generation ||
          !(ModalRoute.of(context)?.isCurrent ?? true)) {
        return;
      }
      session.markPasswordChanged();
      old.clear();
      next.clear();
      confirm.clear();
      setState(() {
        busy = false;
        accepted = true;
      });
    } catch (_) {
      if (mounted && session.generation == generation) {
        setState(() {
          busy = false;
          error = 'Could not change your password. Please try again.';
        });
      }
    } finally {
      if (mounted && busy) {
        setState(() => busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (accepted) {
      return DavoResultScreen(
          title: 'Password changed',
          message: 'Your password change is recorded for this preview session.',
          tempo: DavoOutcomeTempo.compact,
          actions: _done(context, 'Back to security'));
    }
    return _FormPage(
        title: 'Change Password',
        busy: busy,
        action: DavoPrimaryButton(
            label: 'Change your password',
            enabled: valid,
            loading: busy,
            onPressed: submit),
        children: [
          Text(
              'Use at least 8 characters, an uppercase letter and a number or symbol. Your new password must differ from the current one.',
              style: _copy(context)),
          const SizedBox(height: 22),
          _Entry(
              label: 'Current password',
              controller: old,
              secret: true,
              enabled: !busy,
              onChanged: () => setState(() {})),
          _Entry(
              label: 'New password',
              controller: next,
              secret: true,
              enabled: !busy,
              onChanged: () => setState(() {})),
          if (next.text.isNotEmpty) ...[
            Row(
                children: List.generate(
                    3,
                    (index) => Expanded(
                            child: Padding(
                          padding: EdgeInsets.only(right: index == 2 ? 0 : 5),
                          child: Container(
                              height: 4,
                              color: index < score
                                  ? PasswordStrengthPalette.forScore(score,
                                      context: context)
                                  : DavoColors.of(context).divider),
                        )))),
            const SizedBox(height: 6),
            Text(
                score <= 1
                    ? 'Low Strength'
                    : score == 2
                        ? 'Medium Strength'
                        : 'Strong Password',
                style: _copy(context,
                    color: PasswordStrengthPalette.forScore(score,
                        context: context))),
            const SizedBox(height: 18),
          ],
          _Entry(
              label: 'Confirm password',
              controller: confirm,
              secret: true,
              enabled: !busy,
              onChanged: () => setState(() {})),
          if (confirm.text.isNotEmpty && confirm.text != next.text)
            Text('Passwords do not match.',
                style: _copy(context, color: DavoColors.of(context).danger)),
          _error(context, error),
        ]);
  }
}

class EmailSupportScreen extends StatefulWidget {
  const EmailSupportScreen(
      {super.key, this.gateway = const PreviewSettingsGateway()});
  final SettingsGateway gateway;
  @override
  State<EmailSupportScreen> createState() => _EmailSupportScreenState();
}

class _EmailSupportScreenState extends State<EmailSupportScreen> {
  final subject = TextEditingController(),
      order = TextEditingController(),
      message = TextEditingController();
  bool busy = false;
  String? error;
  SupportTicket? ticket;
  bool viewingSaved = false;
  bool get valid =>
      subject.text.trim().isNotEmpty && message.text.trim().isNotEmpty;
  @override
  void dispose() {
    subject.dispose();
    order.dispose();
    message.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (busy || !valid) return;
    final session = SettingsPreviewSession.instance,
        generation = SettingsPreviewSession.instance.generation;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final result = await widget.gateway.submitSupport(
          subject.text.trim(), message.text.trim(), order.text.trim());
      if (!mounted ||
          generation != session.generation ||
          !(ModalRoute.of(context)?.isCurrent ?? true)) {
        return;
      }
      session.acceptTicket(result);
      setState(() {
        ticket = result;
        busy = false;
      });
    } catch (_) {
      if (mounted && generation == session.generation) {
        setState(() {
          busy = false;
          error = 'Could not submit your request. Please try again.';
        });
      }
    } finally {
      if (mounted && busy) {
        setState(() => busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = ticket;
    if (result != null) {
      return DavoResultScreen(
          title: viewingSaved ? 'Request details' : 'Request submitted',
          kind: DavoOutcomeKind.submitted,
          message: 'Pending in this preview session. No email has been sent.',
          details:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Pending', style: _copy(context, bold: true)),
            Text(result.reference, style: _copy(context, bold: true)),
            IconButton(
                tooltip: 'Copy reference',
                icon: const Icon(Icons.copy_outlined, size: 20),
                onPressed: () async {
                  try {
                    await Clipboard.setData(
                        ClipboardData(text: result.reference));
                    if (context.mounted) {
                      showDavoToast(context, 'Reference copied.');
                    }
                  } catch (_) {
                    if (context.mounted) {
                      showDavoToast(context,
                          'Could not copy the reference. Please try again.');
                    }
                  }
                }),
            const SizedBox(height: 10),
            Text(result.subject, style: _copy(context, bold: true)),
            if (result.orderId.isNotEmpty)
              Text('Order ID: ${result.orderId}', style: _copy(context)),
            Text(result.message, style: _copy(context))
          ]),
          actions: viewingSaved
              ? DavoPrimaryButton(
                  label: 'Back to requests',
                  onPressed: () => setState(() {
                        ticket = null;
                        viewingSaved = false;
                      }))
              : _done(context, 'Back to support'));
    }
    final colors = DavoColors.of(context);
    return PopScope(
      canPop: !busy,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Email Support',
              style: _copy(context, bold: true).copyWith(fontSize: 16)),
          leading: IconButton(
              tooltip: 'Back',
              onPressed: busy ? null : () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back_ios_new, size: 18)),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Email Us',
                style: _copy(context, bold: true).copyWith(fontSize: 14)),
            const SizedBox(height: 8),
            Text(
                'Have a question about your order or our services? Our team is here to help.',
                style: _copy(context)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: colors.primarySoft,
                  border: Border.all(color: colors.link.withValues(alpha: .4)),
                  borderRadius: BorderRadius.circular(8)),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(6)),
                  child: const Icon(Icons.bolt, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('Rapid Response',
                          style: _copy(context, color: colors.link, bold: true)
                              .copyWith(fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('We typically respond to emails within 24 hours.',
                          style: _copy(context).copyWith(fontSize: 10)),
                    ])),
              ]),
            ),
            const SizedBox(height: 22),
            _EmailEntry(
                label: 'Subject',
                hint: 'What can we help you with?',
                controller: subject,
                enabled: !busy,
                onChanged: () => setState(() {})),
            _EmailEntry(
                label: 'Order ID',
                hint: 'e.g. #VP-8291',
                optional: true,
                controller: order,
                enabled: !busy,
                onChanged: () => setState(() {})),
            _EmailEntry(
                label: 'Message',
                hint: 'Tell us more about your question...',
                controller: message,
                lines: 5,
                enabled: !busy,
                onChanged: () => setState(() {})),
            _error(context, error),
            Text(
                'Requests are saved locally in this preview. No email is sent.',
                style: _copy(context).copyWith(fontSize: 10)),
            const SizedBox(height: 12),
            if (SettingsPreviewSession.instance.tickets
                .any((t) => t.channel == SupportChannel.email)) ...[
              Text('Your requests', style: _copy(context, bold: true)),
              ...SettingsPreviewSession.instance.tickets
                  .where((t) => t.channel == SupportChannel.email)
                  .map((saved) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(saved.subject,
                            style: _copy(context, bold: true)),
                        subtitle: Text('Pending ? ${saved.reference}',
                            style: _copy(context)),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: busy
                            ? null
                            : () => setState(() {
                                  ticket = saved;
                                  viewingSaved = true;
                                }),
                      )),
            ],
          ]),
        )),
        bottomNavigationBar: SafeArea(
            child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: DavoPrimaryButton(
              label: 'Submit request',
              enabled: valid,
              loading: busy,
              onPressed: submit),
        )),
      ),
    );
  }
}

class _EmailEntry extends StatelessWidget {
  const _EmailEntry(
      {required this.label,
      required this.hint,
      required this.controller,
      required this.onChanged,
      this.enabled = true,
      this.optional = false,
      this.lines = 1});
  final String label, hint;
  final TextEditingController controller;
  final VoidCallback onChanged;
  final bool enabled, optional;
  final int lines;
  @override
  Widget build(BuildContext context) {
    final colors = DavoColors.of(context);
    return Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              children: [
                Text(label, style: _copy(context, bold: true)),
                if (optional)
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                          color: colors.offWhite,
                          borderRadius: BorderRadius.circular(4)),
                      child: Text('OPTIONAL',
                          style: _copy(context).copyWith(fontSize: 8))),
              ]),
          const SizedBox(height: 8),
          TextField(
              controller: controller,
              enabled: enabled,
              maxLines: lines,
              keyboardAppearance: Theme.of(context).brightness,
              keyboardType:
                  lines > 1 ? TextInputType.multiline : TextInputType.text,
              onChanged: (_) => onChanged(),
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              style: _copy(context),
              decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: _copy(context, color: colors.bodyMuted),
                  filled: true,
                  fillColor: colors.offWhite,
                  contentPadding: const EdgeInsets.all(14),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colors.border)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colors.link)))),
        ]));
  }
}

class DavoPointsScreen extends StatefulWidget {
  const DavoPointsScreen(
      {super.key, this.gateway = const PreviewSettingsGateway()});
  final SettingsGateway gateway;
  @override
  State<DavoPointsScreen> createState() => _DavoPointsScreenState();
}

class _DavoPointsScreenState extends State<DavoPointsScreen> {
  final amount = TextEditingController();
  bool busy = false, review = false;
  String? error;
  RewardRedemption? redemption;
  final session = SettingsPreviewSession.instance;
  int get points => int.tryParse(amount.text) ?? 0;
  bool get valid => points > 0 && points <= session.availablePoints;
  @override
  void initState() {
    super.initState();
    session.addListener(changed);
  }

  void changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    session.removeListener(changed);
    amount.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (busy || !valid || !review) return;
    final generation = session.generation;
    final submittedPoints = points;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final result = await widget.gateway.redeemPoints(submittedPoints);
      if (!mounted ||
          generation != session.generation ||
          !(ModalRoute.of(context)?.isCurrent ?? true)) {
        return;
      }
      if (result.points != submittedPoints ||
          !session.acceptRedemption(result)) {
        setState(() {
          busy = false;
          review = false;
          error =
              'Your points balance changed. Please review the amount again.';
        });
        return;
      }
      setState(() {
        busy = false;
        redemption = result;
      });
    } catch (_) {
      if (mounted && generation == session.generation) {
        setState(() {
          busy = false;
          error = 'Could not redeem your points. Please try again.';
        });
      }
    } finally {
      if (mounted && busy) {
        setState(() {
          busy = false;
          review = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = redemption;
    if (result != null) {
      return DavoResultScreen(
          title: 'Points redeemed',
          message:
              '${result.points} points added NGN ${(result.creditKobo / 100).toStringAsFixed(2)} to your preview reward balance.',
          details: Text(result.reference, style: _copy(context)),
          actions: DavoPrimaryButton(
              label: 'Back to points',
              onPressed: () => setState(() {
                    redemption = null;
                    review = false;
                    amount.clear();
                  })));
    }
    if (review) {
      return _FormPage(
          title: 'Review redemption',
          busy: busy,
          action: DavoPrimaryButton(
              label: 'Redeem points',
              enabled: valid,
              loading: busy,
              onPressed: submit),
          children: [
            DavoPointsAmount(
                text: '$points points', style: _copy(context, bold: true)),
            Text('Preview credit: NGN ${(points * 5 / 100).toStringAsFixed(2)}',
                style: _copy(context)),
            Text(
                '20 points = NGN 1.00. This updates only your preview balance.',
                style: _copy(context)),
            const SizedBox(height: 20),
            TextButton(
                onPressed: busy
                    ? null
                    : () => setState(() {
                          review = false;
                          error = null;
                        }),
                child: const Text('Edit amount')),
            _error(context, error)
          ]);
    }
    return _FormPage(
        title: 'Davo points Dashboard',
        action: DavoPrimaryButton(
            label: 'Review redemption',
            enabled: valid,
            onPressed: () {
              FocusManager.instance.primaryFocus?.unfocus();
              setState(() {
                review = true;
                error = null;
              });
            }),
        children: [
          _RewardStats(session: session),
          const SizedBox(height: 14),
          Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: DavoColors.of(context).primarySoft,
                  borderRadius: BorderRadius.circular(8)),
              child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    Text('Preview reward balance', style: _copy(context)),
                    Text(
                        'NGN ${(session.rewardCreditKobo / 100).toStringAsFixed(2)}',
                        style: _copy(context,
                                color: DavoColors.of(context).link, bold: true)
                            .copyWith(fontSize: 14)),
                  ])),
          const SizedBox(height: 22),
          _Entry(
              label: 'Points to redeem',
              controller: amount,
              number: true,
              onChanged: () => setState(() {})),
          if (amount.text.isNotEmpty && !valid)
            Text(
                'Enter an amount between 1 and ${session.availablePoints} points.',
                style: _copy(context, color: DavoColors.of(context).danger)),
          _error(context, error),
          const SizedBox(height: 12),
          Text('Recent Activity', style: _copy(context, bold: true)),
          if (session.redemptions.isEmpty)
            Text('No redemptions in this preview session.',
                style: _copy(context)),
          ...session.redemptions.map((r) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(children: [
                const DavoPointsCoin(size: 24),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(
                        '${r.points} points redeemed · NGN ${(r.creditKobo / 100).toStringAsFixed(2)}\n${r.reference}',
                        style: _copy(context))),
              ]))),
        ]);
  }
}

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen(
      {super.key,
      required this.onSignOut,
      this.gateway = const PreviewSettingsGateway()});
  final VoidCallback onSignOut;
  final SettingsGateway gateway;
  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final reason = TextEditingController(),
      confirmation = TextEditingController();
  bool checked = false, busy = false, exited = false;
  String? error;
  DeletionRequest? request;
  bool get valid => checked && confirmation.text == 'DELETE';
  void signOut() {
    if (exited) return;
    exited = true;
    widget.onSignOut();
  }

  @override
  void dispose() {
    reason.dispose();
    confirmation.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (busy || !valid) return;
    final session = SettingsPreviewSession.instance,
        generation = SettingsPreviewSession.instance.generation;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final result = await widget.gateway.requestDeletion(reason.text.trim());
      if (!mounted ||
          generation != session.generation ||
          !(ModalRoute.of(context)?.isCurrent ?? true)) {
        return;
      }
      session.acceptDeletion(result);
      setState(() {
        request = result;
        busy = false;
      });
    } catch (_) {
      if (mounted && generation == session.generation) {
        setState(() {
          busy = false;
          error = 'Could not request deletion. Please try again.';
        });
      }
    } finally {
      if (mounted && busy) {
        setState(() => busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = request;
    if (result != null) {
      return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) signOut();
          },
          child: DavoResultScreen(
              title: 'Deletion requested',
              kind: DavoOutcomeKind.submitted,
              message:
                  'Pending in this preview session. Your real account has not been deleted.',
              details: Text(result.reference, style: _copy(context)),
              actions: DavoPrimaryButton(
                  label: 'Back to login', onPressed: signOut)));
    }
    return _FormPage(
        title: 'Delete Account',
        busy: busy,
        action: DavoPrimaryButton(
            label: 'Request account deletion',
            enabled: valid,
            loading: busy,
            onPressed: submit),
        children: [
          Text(
              'This preview records a pending deletion request. You can cancel before submitting by going back.',
              style: _copy(context)),
          const SizedBox(height: 22),
          _Entry(
              label: 'Reason (optional)',
              controller: reason,
              lines: 3,
              enabled: !busy,
              onChanged: () => setState(() {})),
          _Entry(
              label: 'Type DELETE to confirm',
              controller: confirmation,
              enabled: !busy,
              onChanged: () => setState(() {})),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Checkbox(
                value: checked,
                onChanged: busy
                    ? null
                    : (value) => setState(() => checked = value ?? false)),
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                        'I understand this requests account deletion and will return me to login after I acknowledge the result.',
                        style: _copy(context))))
          ]),
          _error(context, error),
        ]);
  }
}
