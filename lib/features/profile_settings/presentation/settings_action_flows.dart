import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/navigation/app_page_route.dart';
import '../../../core/preview/settings_preview_session.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/motion/davo_motion_spec.dart';
import '../../../shared/widgets/auth_widgets.dart';
import '../../../shared/widgets/davo_bank_logo.dart';
import '../../../shared/widgets/davo_result_screen.dart';
export 'settings_personal_action_flows.dart';

class LinkedAccountsScreen extends StatelessWidget {
  const LinkedAccountsScreen(
      {super.key, this.gateway = const PreviewSettingsGateway()});
  final SettingsGateway gateway;
  @override
  Widget build(BuildContext context) => _BankPage(
      title: 'Linked Accounts',
      child: ListenableBuilder(
          listenable: SettingsPreviewSession.instance,
          builder: (context, _) =>
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Accounts saved for this preview session.',
                    style: TextStyle(fontSize: 12)),
                const SizedBox(height: 16),
                for (final bank in SettingsPreviewSession.instance.banks)
                  Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side:
                              BorderSide(color: DavoColors.of(context).border)),
                      child: ListTile(
                          leading: DavoBankLogo(bankName: bank.bank),
                          title: Text(bank.bank,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                          subtitle: Text(
                              '${bank.name}\n${bank.maskedNumber} · Preview',
                              style: const TextStyle(fontSize: 12)),
                          isThreeLine: true)),
                OutlinedButton.icon(
                    onPressed: () {
                      final parent = ModalRoute.of(context);
                      Navigator.of(context).push(AppPageRoute<void>(
                          builder: (_) => AddBankAccountScreen(
                              gateway: gateway,
                              onFinished: (resultContext) {
                                Navigator.of(resultContext)
                                    .popUntil((route) => route == parent);
                              })));
                    },
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Add Account')),
              ])));
}

class AddBankAccountScreen extends StatefulWidget {
  const AddBankAccountScreen(
      {super.key,
      this.gateway = const PreviewSettingsGateway(),
      this.onFinished});
  final SettingsGateway gateway;
  final ValueChanged<BuildContext>? onFinished;
  @override
  State<AddBankAccountScreen> createState() => _AddBankAccountScreenState();
}

class _AddBankAccountScreenState extends State<AddBankAccountScreen> {
  final query = TextEditingController();
  static const banks = [
    'AAA Finance',
    'AB Microfinance Bank',
    'Access Bank',
    'Kuda Bank',
    'Bank Of Agriculture',
    'Carbon',
    'Ecobank Bank',
    'FCMB',
    'Fidelity Bank',
    'GTBank',
    'Opay Bank'
  ];
  @override
  void dispose() {
    query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = banks.where(
        (b) => b.toLowerCase().contains(query.text.trim().toLowerCase()));
    return _BankPage(
        title: 'Add Bank Account',
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Select your bank to link your account',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          TextField(
              controller: query,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 14),
              keyboardAppearance: Theme.of(context).brightness,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              decoration: const InputDecoration(
                  hintText: 'Search for a bank',
                  prefixIcon: Icon(Icons.search, size: 20))),
          const SizedBox(height: 14),
          if (filtered.isEmpty)
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('No banks found. Try another name.',
                    style: TextStyle(fontSize: 14))),
          for (final bank in filtered)
            ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                leading: DavoBankLogo(bankName: bank),
                title: Text(bank, style: const TextStyle(fontSize: 14)),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  final parent = ModalRoute.of(context);
                  Navigator.of(context).push(AppPageRoute<void>(
                      builder: (_) => _BankNumberScreen(
                          bank: bank,
                          gateway: widget.gateway,
                          onFinished: widget.onFinished ??
                              (resultContext) => Navigator.of(resultContext)
                                  .popUntil((r) => r == parent))));
                }),
        ]));
  }
}

class _BankNumberScreen extends StatefulWidget {
  const _BankNumberScreen(
      {required this.bank, required this.gateway, required this.onFinished});
  final String bank;
  final SettingsGateway gateway;
  final ValueChanged<BuildContext> onFinished;
  @override
  State<_BankNumberScreen> createState() => _BankNumberScreenState();
}

class _BankNumberScreenState extends State<_BankNumberScreen> {
  final number = TextEditingController();
  LinkedBank? account;
  bool resolving = false;
  String? error;
  int revision = 0;
  @override
  void dispose() {
    revision++;
    number.dispose();
    super.dispose();
  }

  Future<void> resolve() async {
    final token = ++revision;
    final generation = SettingsPreviewSession.instance.generation;
    setState(() {
      account = null;
      error = null;
      resolving = number.text.length == 10;
    });
    if (!resolving) return;
    final entered = number.text;
    try {
      final result = await widget.gateway.resolveBank(widget.bank, entered);
      if (!mounted ||
          token != revision ||
          generation != SettingsPreviewSession.instance.generation) {
        return;
      }
      if (result.number != entered || result.bank != widget.bank) {
        throw const FormatException();
      }
      setState(() {
        account = result;
        resolving = false;
      });
    } catch (_) {
      if (!mounted ||
          token != revision ||
          generation != SettingsPreviewSession.instance.generation) {
        return;
      }
      setState(() {
        resolving = false;
        error = 'Could not resolve this account. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) => _BankPage(
      title: 'Account details',
      footer: DavoPrimaryButton(
          label: 'Review account',
          enabled: account != null && !resolving,
          onPressed: () {
            if (account == null) return;
            FocusManager.instance.primaryFocus?.unfocus();
            Navigator.of(context).push(AppPageRoute<void>(
                builder: (_) => _BankReviewScreen(
                    account: account!,
                    gateway: widget.gateway,
                    onFinished: widget.onFinished)));
          }),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ListTile(
            contentPadding: EdgeInsets.zero,
            leading: DavoBankLogo(bankName: widget.bank),
            title: Text(widget.bank,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600))),
        const SizedBox(height: 20),
        DavoTextField(
            label: 'Account number',
            controller: number,
            hint: 'Enter 10-digit account number',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10)
            ],
            onChanged: (_) => resolve()),
        const SizedBox(height: 16),
        if (resolving) const LinearProgressIndicator(),
        if (account != null)
          Text(
              '${account!.name}\nPreview account name — not verified with a bank.',
              style: const TextStyle(fontSize: 12, height: 1.5)),
        if (error != null) ...[
          Text(error!,
              style: TextStyle(
                  fontSize: 12, color: DavoColors.of(context).danger)),
          TextButton(onPressed: resolve, child: const Text('Try again'))
        ],
      ]));
}

class _BankReviewScreen extends StatefulWidget {
  const _BankReviewScreen(
      {required this.account, required this.gateway, required this.onFinished});
  final LinkedBank account;
  final SettingsGateway gateway;
  final ValueChanged<BuildContext> onFinished;
  @override
  State<_BankReviewScreen> createState() => _BankReviewScreenState();
}

class _BankReviewScreenState extends State<_BankReviewScreen> {
  bool busy = false, linked = false;
  String? error;
  Future<void> link() async {
    if (busy || linked) return;
    final session = SettingsPreviewSession.instance;
    final generation = session.generation;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.gateway.linkBank(widget.account);
      if (!mounted ||
          generation != session.generation ||
          ModalRoute.of(context)?.isCurrent != true) {
        return;
      }
      if (!session.acceptBank(widget.account)) {
        setState(() {
          busy = false;
          error = 'This bank account is already linked.';
        });
        return;
      }
      setState(() {
        busy = false;
        linked = true;
      });
    } catch (_) {
      if (mounted && generation == session.generation) {
        setState(() {
          busy = false;
          error = 'Could not link this account. Please try again.';
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
    if (linked) {
      return DavoResultScreen(
          title: 'Bank account linked',
          message:
              'Saved for this preview session. Live bank verification is not connected.',
          tempo: DavoOutcomeTempo.compact,
          eventKey: widget.account.number,
          actions: DavoPrimaryButton(
              label: 'Back to linked accounts',
              onPressed: () => widget.onFinished(context)));
    }
    return _BankPage(
        title: 'Review bank account',
        footer: DavoPrimaryButton(
            label: 'Link account',
            loading: busy,
            enabled: !busy,
            onPressed: link),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          DavoBankLogo(bankName: widget.account.bank),
          const SizedBox(height: 20),
          Text(widget.account.bank,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Text(widget.account.name, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 12),
          Text(widget.account.number, style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 20),
          const Text(
              'Check the account number carefully. This preview saves the account locally for this session.',
              style: TextStyle(fontSize: 12, height: 1.5)),
          if (error != null)
            Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(error!,
                    style: TextStyle(
                        fontSize: 12, color: DavoColors.of(context).danger))),
        ]));
  }
}

class _BankPage extends StatelessWidget {
  const _BankPage({required this.title, required this.child, this.footer});
  final String title;
  final Widget child;
  final Widget? footer;
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
      body: SafeArea(
          child: Column(children: [
        Expanded(
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(24), child: child)),
        if (footer != null)
          Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              child: footer),
      ])));
}
