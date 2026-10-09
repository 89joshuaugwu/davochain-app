import 'package:flutter/material.dart';
import '../../../core/preview/settings_preview_session.dart';
import '../../../core/theme/app_theme.dart';

TextStyle _supportText(BuildContext context,
        {double size = 12, bool bold = false, Color? color}) =>
    TextStyle(
        fontFamily: 'Sora',
        fontSize: size,
        height: 1.5,
        fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
        color: color ?? DavoColors.of(context).body);
const _brand = 'assets/figma_exact/support_agent_logo_small_exact.png';

class SupportMessagesScreen extends StatelessWidget {
  const SupportMessagesScreen({super.key});
  void _compose(BuildContext context) => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => const SupportChatScreen()));
  @override
  Widget build(BuildContext context) => ListenableBuilder(
      listenable: SettingsPreviewSession.instance,
      builder: (context, _) {
        final colors = DavoColors.of(context);
        final conversations = <String, SupportTicket>{};
        for (final ticket in SettingsPreviewSession.instance.tickets) {
          if (ticket.channel == SupportChannel.chat) {
            conversations.putIfAbsent(
                ticket.conversationId ?? ticket.reference, () => ticket);
          }
        }
        final messages = conversations.values.toList();
        return Scaffold(
          appBar: AppBar(
              centerTitle: true,
              title: Text('Messages',
                  style: _supportText(context, size: 16, bold: true)),
              leading: IconButton(
                  tooltip: 'Back',
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18)),
              actions: [
                Container(
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                        color: colors.offWhite,
                        borderRadius: BorderRadius.circular(24)),
                    child: Row(children: [
                      IconButton(
                          tooltip: 'Compose message',
                          onPressed: () => _compose(context),
                          icon: const Icon(Icons.edit_outlined, size: 18)),
                      IconButton(
                          tooltip: 'Close messages',
                          onPressed: () => Navigator.maybePop(context),
                          icon: const Icon(Icons.close, size: 18))
                    ])),
              ]),
          body: SafeArea(
              child: messages.isEmpty
                  ? Center(
                      child: Padding(
                          padding: const EdgeInsets.all(24),
                          child:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.chat_bubble_outline,
                                size: 24, color: colors.link),
                            const SizedBox(height: 14),
                            Text('No Messages',
                                style: _supportText(context,
                                    size: 14, bold: true)),
                            const SizedBox(height: 6),
                            Text('Messages from the team will be shown here',
                                textAlign: TextAlign.center,
                                style: _supportText(context)),
                            const SizedBox(height: 20),
                            FilledButton.icon(
                                onPressed: () => _compose(context),
                                icon: const Icon(Icons.help_outline, size: 16),
                                label: Text('Ask a question',
                                    maxLines: 1,
                                    style: _supportText(context,
                                        color: Colors.white)),
                                style: FilledButton.styleFrom(
                                    minimumSize: const Size(0, 48),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8)))),
                          ])))
                  : ListView(padding: const EdgeInsets.all(16), children: [
                      Text(
                          'Pending in this preview session. No messages have been delivered.',
                          style: _supportText(context, size: 10)),
                      const SizedBox(height: 12),
                      ...messages.map((ticket) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(Icons.chat_bubble_outline,
                              color: colors.link),
                          title: Text(ticket.message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: _supportText(context)),
                          subtitle: Text('Pending · ${ticket.reference}',
                              style: _supportText(context, size: 10)),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                  builder: (_) =>
                                      SupportChatScreen(ticket: ticket))))),
                    ])),
        );
      });
}

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen(
      {super.key, this.gateway = const PreviewSettingsGateway(), this.ticket});
  final SettingsGateway gateway;
  final SupportTicket? ticket;
  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final draft = TextEditingController();
  final scroll = ScrollController();
  final sent = <SupportTicket>[];
  late final String conversationId;
  String? category, error;
  bool busy = false;
  @override
  void initState() {
    super.initState();
    final session = SettingsPreviewSession.instance;
    conversationId =
        widget.ticket?.conversationId ?? session.newConversationId();
    if (widget.ticket != null) {
      sent.addAll(session.tickets
          .where((t) =>
              t.channel == SupportChannel.chat &&
              t.conversationId == conversationId)
          .toList()
          .reversed);
      if (!sent.any((t) => t.reference == widget.ticket!.reference)) {
        sent.add(widget.ticket!);
      }
      category = widget.ticket!.subject;
    }
  }

  @override
  void dispose() {
    draft.dispose();
    scroll.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (busy || draft.text.trim().isEmpty) return;
    final session = SettingsPreviewSession.instance,
        generation = SettingsPreviewSession.instance.generation;
    final message = draft.text.trim();
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final result = await widget.gateway
          .submitChat(category ?? 'Something Else', message, conversationId);
      if (!mounted ||
          generation != session.generation ||
          !(ModalRoute.of(context)?.isCurrent ?? true)) {
        return;
      }
      session.acceptTicket(result);
      setState(() {
        sent.add(result);
        draft.clear();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && scroll.hasClients) {
          scroll.jumpTo(scroll.position.maxScrollExtent);
        }
      });
    } catch (_) {
      if (mounted && generation == session.generation) {
        setState(
            () => error = 'Could not save your message. Please try again.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void capability(String title, String description) =>
      showModalBottomSheet<void>(
          context: context,
          showDragHandle: true,
          builder: (context) => SafeArea(
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: _supportText(context, size: 14, bold: true)),
                        const SizedBox(height: 12),
                        Text(description, style: _supportText(context)),
                        const SizedBox(height: 16),
                        TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Continue with text'))
                      ]))));
  Widget bubble(String text, {bool user = false}) {
    final colors = DavoColors.of(context);
    return Align(
        alignment: user ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: user ? AppColors.primary : colors.offWhite,
                borderRadius: BorderRadius.circular(16)),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!user) ...[
                    Row(children: [
                      Image.asset(_brand, width: 20, height: 20),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text('Callie • AI Agent',
                              style: _supportText(context, bold: true)))
                    ]),
                    const SizedBox(height: 10)
                  ],
                  Text(text,
                      style: _supportText(context,
                          color: user ? Colors.white : colors.body)),
                ])));
  }

  @override
  Widget build(BuildContext context) {
    final colors = DavoColors.of(context);
    return PopScope(
        canPop: !busy,
        child: Scaffold(
          appBar: AppBar(
              leading: IconButton(
                  tooltip: 'Back',
                  onPressed: busy ? null : () => Navigator.maybePop(context),
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18)),
              title: Row(children: [
                Image.asset(_brand, width: 26, height: 26),
                const SizedBox(width: 9),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text('Callie',
                          style: _supportText(context, size: 14, bold: true)),
                      Text('Davochain support',
                          style: _supportText(context, size: 10))
                    ]))
              ]),
              actions: [
                IconButton(
                    tooltip: 'Close chat',
                    onPressed: busy ? null : () => Navigator.maybePop(context),
                    icon: const Icon(Icons.close, size: 18))
              ]),
          body: SafeArea(
              child: Column(children: [
            Expanded(
                child: ListView(
                    controller: scroll,
                    padding: const EdgeInsets.all(16),
                    children: [
                  Center(
                      child: Text('Your global money partner',
                          style: _supportText(context, size: 10))),
                  const SizedBox(height: 18),
                  Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                          border: Border.all(color: colors.border),
                          borderRadius: BorderRadius.circular(12)),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline,
                                size: 14, color: colors.bodyMuted),
                            const SizedBox(width: 8),
                            Expanded(
                                child: Text(
                                    'This is a support preview. Messages are saved locally; live support and AI replies are not connected.',
                                    style: _supportText(context, size: 10)))
                          ])),
                  bubble(
                      'Hi there,\nThank you for choosing Davochain.\nChoose a topic and tell us how we can help.'),
                  bubble(
                      'Hello, this is Callie from Davochain. Please choose the option below that best matches your request.'),
                  if (category == null)
                    ...[
                      'Account Management & Verification',
                      'Gift Cards, Crypto',
                      'Deposits and Funding',
                      'Bank Accounts',
                      'Withdrawals',
                      'Account Issues & Restrictions',
                      'Something Else'
                    ].map((label) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: OutlinedButton(
                            onPressed: busy
                                ? null
                                : () => setState(() => category = label),
                            style: OutlinedButton.styleFrom(
                                alignment: Alignment.centerLeft,
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8))),
                            child: Text(label, style: _supportText(context)))))
                  else ...[
                    bubble(category!, user: true),
                    bubble(
                        'Please share as much detail as possible about your question. Avoid sharing passwords or PINs.')
                  ],
                  ...sent.map((ticket) => Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            bubble(ticket.message, user: true),
                            Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text('Pending · ${ticket.reference}',
                                    style: _supportText(context, size: 10)))
                          ])),
                ])),
            if (error != null)
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Semantics(
                      liveRegion: true,
                      child: Text(error!,
                          style: _supportText(context, color: colors.danger)))),
            Container(
                key: const ValueKey('support-composer'),
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                padding: const EdgeInsets.fromLTRB(12, 8, 8, 4),
                decoration: BoxDecoration(
                    border: Border.all(color: colors.border),
                    borderRadius: BorderRadius.circular(16)),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                      controller: draft,
                      enabled: !busy,
                      minLines: 1,
                      maxLines: 3,
                      keyboardAppearance: Theme.of(context).brightness,
                      onChanged: (_) => setState(() {}),
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      style: _supportText(context),
                      decoration: InputDecoration(
                          hintText: 'Ask a question...',
                          hintStyle:
                              _supportText(context, color: colors.bodyMuted),
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 8))),
                  Row(children: [
                    IconButton(
                        tooltip: 'Attach a file',
                        onPressed: busy
                            ? null
                            : () => capability('Attachments',
                                'File attachments are not available in this preview. Describe the issue in your message instead.'),
                        icon: const Icon(Icons.attach_file, size: 20)),
                    IconButton(
                        tooltip: 'Add GIF',
                        onPressed: busy
                            ? null
                            : () => capability('GIF messages',
                                'GIF messages need a connected media service. You can send a text request in this preview.'),
                        icon: const Icon(Icons.gif_box_outlined, size: 22)),
                    IconButton(
                        tooltip: 'Voice message',
                        onPressed: busy
                            ? null
                            : () => capability('Voice messages',
                                'Voice recording is not available in this preview. Type your question below.'),
                        icon: const Icon(Icons.mic_none, size: 20)),
                    const Spacer(),
                    IconButton.filled(
                        tooltip: error == null
                            ? 'Save message'
                            : 'Retry saving message',
                        onPressed:
                            busy || draft.text.trim().isEmpty ? null : submit,
                        icon: busy
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.arrow_upward, size: 20)),
                  ]),
                ])),
          ])),
        ));
  }
}
