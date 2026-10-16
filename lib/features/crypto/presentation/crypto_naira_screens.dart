part of 'crypto_full_flow.dart';

class NairaWithdrawScreen extends StatefulWidget {
  const NairaWithdrawScreen({super.key});
  @override
  State<NairaWithdrawScreen> createState() => _NairaWithdrawScreenState();
}

// Local product limit; the backend must enforce cumulative daily usage.
const _nairaWithdrawalDailyLimit = 5000000;

bool _withinNairaWithdrawalLimit(String text) {
  try {
    final input = AssetAmount.parse(text.replaceAll(',', ''), 'NGN', 2);
    return input.atomicUnits > BigInt.zero &&
        input.atomicUnits <= BigInt.from(_nairaWithdrawalDailyLimit * 100);
  } on FormatException {
    return false;
  }
}

class _NairaWithdrawScreenState extends State<NairaWithdrawScreen> {
  final amount = TextEditingController();
  BankAccount? account;
  bool _reviewing = false;
  bool _balanceVisible = true;
  @override
  void dispose() {
    WalletAccountState.instance.removeListener(_walletChanged);
    amount.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WalletAccountState.instance.addListener(_walletChanged);
  }

  void _walletChanged() {
    if (mounted) setState(() {});
  }

  bool get _ready => !_reviewing && _validRequest;

  bool get _validRequest {
    try {
      final input = AssetAmount.parse(
        amount.text.replaceAll(',', ''),
        'NGN',
        2,
      );
      return _withinNairaWithdrawalLimit(amount.text) &&
          // Includes the same ₦100 fee shown in review and funding records.
          WalletAccountState.instance.snapshot
              .available('NGN')
              .covers(
                AssetAmount('NGN', input.atomicUnits + BigInt.from(10000), 2),
              ) &&
          account != null &&
          SettingsPreviewSession.instance.banks.any(
            (bank) =>
                bank.bank == account!.bank &&
                bank.number == account!.number &&
                bank.name == account!.name,
          );
    } on FormatException {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ready = _ready;
    return Scaffold(
      backgroundColor: DavoColors.of(context).canvas,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          tooltip: 'Back',
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                        ),
                        Expanded(
                          child: Text(
                            'Withdraw Davochain Naira',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: DavoColors.of(context).ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _BalanceCard(
                      visible: _balanceVisible,
                      onVisibilityToggle: () =>
                          setState(() => _balanceVisible = !_balanceVisible),
                    ),
                    const SizedBox(height: 24),
                    _ExactNairaField(
                      label: 'Amount',
                      child: TextField(
                        controller: amount,
                        inputFormatters: const [GroupedAmountInputFormatter()],
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) => setState(() {}),
                        decoration: DavoInlineInputDecoration(
                          hintText: '0',
                          hintStyle: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 16,
                            height: 1.35,
                            color: DavoColors.of(context).bodyMuted,
                          ),
                        ),
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 16,
                          height: 1.35,
                          color: DavoColors.of(context).ink,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Max daily amount - \u20a65,000,000',
                      style: TextStyle(
                        fontSize: 12,
                        color: DavoColors.of(context).bodyMuted,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _ExactNairaField(
                      label: 'Payment Method',
                      onTap: _payment,
                      trailing: Image.asset(
                        '$_exact/naira_payment_chevron_exact.png',
                        color: DavoColors.of(context).ink,
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                      ),
                      child: account == null
                          ? Text(
                              'Select a payment method',
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 16,
                                height: 1.35,
                                color: DavoColors.of(context).bodyMuted,
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Text(
                                account!.bank,
                                style: TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 14,
                                  height: 1.35,
                                  color: DavoColors.of(context).ink,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: _Button(
                label: 'Continue',
                enabled: ready,
                fontWeight: FontWeight.w700,
                onTap: ready ? _review : () {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _payment() async {
    final value = await showModalBottomSheet<BankAccount>(
      context: context,
      sheetAnimationStyle:
          (MediaQuery.disableAnimationsOf(context) ||
              MediaQuery.accessibleNavigationOf(context))
          ? AnimationStyle.noAnimation
          : const AnimationStyle(
              duration: Duration(milliseconds: 280),
              reverseDuration: Duration(milliseconds: 200),
            ),
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .32),
      builder: (_) => _PaymentSheet(current: account),
    );
    if (mounted && value != null) setState(() => account = value);
  }

  Future<void> _review() async {
    if (!_ready) return;
    final generation = WalletAccountState.instance.generation;
    setState(() => _reviewing = true);
    try {
      final ok = await showModalBottomSheet<bool>(
        context: context,
        sheetAnimationStyle:
            (MediaQuery.disableAnimationsOf(context) ||
                MediaQuery.accessibleNavigationOf(context))
            ? AnimationStyle.noAnimation
            : const AnimationStyle(
                duration: Duration(milliseconds: 280),
                reverseDuration: Duration(milliseconds: 200),
              ),
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: .32),
        builder: (_) => _NairaConfirm(amount: amount.text, account: account!),
      );
      if (!mounted || ok != true) return;
      final pin = await Navigator.push<bool>(
        context,
        AppPageRoute<bool>(builder: (_) => const CryptoPinScreen()),
      );
      if (!mounted ||
          pin != true ||
          !_validRequest ||
          generation != WalletAccountState.instance.generation) {
        return;
      }
      await Navigator.of(context).push(
        AppPageRoute<void>(
          builder: (_) => NairaWithdrawalProgressScreen(
            amount: _parseExactAmount(amount.text),
            bank: account!.bank,
            accountNumber: account!.number,
            accountName: account!.name,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _reviewing = false);
    }
  }
}

class _ExactNairaField extends StatelessWidget {
  const _ExactNairaField({
    required this.label,
    required this.child,
    this.trailing,
    this.onTap,
  });
  final String label;
  final Widget child;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Focus(
    child: Builder(
      builder: (context) => Material(
        color: DavoColors.of(context).canvas,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: BorderSide(
            color: Focus.of(context).hasFocus
                ? AppColors.primary
                : DavoColors.of(context).border,
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    color: DavoColors.of(context).body,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: child),
                    if (trailing != null) ...[
                      const SizedBox(width: 8),
                      SizedBox(width: 24, height: 24, child: trailing!),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class BankAccount {
  const BankAccount(this.bank, this.number, this.name);
  final String bank, number, name;
}

class _PaymentSheet extends StatelessWidget {
  const _PaymentSheet({this.current});
  final BankAccount? current;
  @override
  Widget build(BuildContext context) {
    final saved = <BankAccount>[
      for (final bank in SettingsPreviewSession.instance.banks)
        if (current?.bank != bank.bank || current?.number != bank.number)
          BankAccount(bank.bank, bank.number, bank.name),
    ];
    return Material(
      color: DavoColors.of(context).sheetSurface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * .6,
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 60,
                height: 4,
                decoration: BoxDecoration(
                  color: DavoColors.of(context).bodyMuted,
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 12, 0),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Select a payment method',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.add_circle_outline),
                      title: const Text(
                        'Add new payment method',
                        style: TextStyle(fontSize: 14),
                      ),
                      onTap: () async {
                        final account = await Navigator.push<BankAccount>(
                          context,
                          AppPageRoute<BankAccount>(
                            builder: (_) => const AddBankScreen(),
                          ),
                        );
                        if (context.mounted && account != null) {
                          SettingsPreviewSession.instance.acceptBank(
                            LinkedBank(
                              bank: account.bank,
                              number: account.number,
                              name: account.name,
                            ),
                          );
                          Navigator.pop(context, account);
                        }
                      },
                    ),
                    const Text(
                      'Saved accounts',
                      style: TextStyle(fontSize: 12),
                    ),
                    const SizedBox(height: 12),
                    for (final account in saved)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _PaymentMethodSavedRow(
                          account: account,
                          onTap: () => Navigator.pop(context, account),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentMethodSavedRow extends StatelessWidget {
  const _PaymentMethodSavedRow({required this.account, required this.onTap});
  final BankAccount account;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 56,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 7.5,
              width: 40,
              height: 40,
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: DavoBankLogo(bankName: account.bank, size: 40),
              ),
            ),
            Positioned(
              left: 52,
              top: 9.5,
              right: 97,
              height: 36,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 14,
                      height: 1.35,
                      color: DavoColors.of(context).body,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${account.bank} - ${account.number}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 12,
                      height: 1.25,
                      color: DavoColors.of(context).bodyMuted,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              right: 0,
              top: 19.5,
              width: 16,
              height: 16,
              child: Image.asset(
                '$_exact/crypto_ep_arrow_right_exact.png',
                color: DavoColors.of(context).ink,
                width: 16,
                height: 16,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddBankScreen extends StatefulWidget {
  const AddBankScreen({super.key});
  @override
  State<AddBankScreen> createState() => _AddBankScreenState();
}

class _AddBankScreenState extends State<AddBankScreen> {
  String? bank;
  final number = TextEditingController();
  Timer? _resolutionTimer;
  bool _checking = false;
  String? _resolvedName;

  void _resolveAccount() {
    _resolutionTimer?.cancel();
    final valid = bank != null && RegExp(r'^\d{10}$').hasMatch(number.text);
    setState(() {
      _checking = valid;
      _resolvedName = null;
    });
    if (!valid) return;
    final selectedBank = bank;
    final accountNumber = number.text;
    _resolutionTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted || bank != selectedBank || number.text != accountNumber) {
        return;
      }
      setState(() {
        _checking = false;
        _resolvedName = 'Callietus Ezeike Chinecherem';
      });
    });
  }

  @override
  void dispose() {
    _resolutionTimer?.cancel();
    number.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final valid = _resolvedName != null && !_checking;
    return TradeFormLayout(
      header: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _BankTopBar(onBack: () => Navigator.pop(context)),
      ),
      tabs: const SizedBox.shrink(),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add your bank account to receive money fast and secured easily',
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 16,
              height: 1.35,
              color: DavoColors.of(context).body,
            ),
          ),
          const SizedBox(height: 24),
          _BankFormBox(
            label: 'Bank Name',
            value: bank ?? 'Select bank name',
            muted: bank == null,
            onTap: _chooseBank,
          ),
          const SizedBox(height: 16),
          _BankFormBox(
            label: 'Account Number',
            child: TextField(
              controller: number,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              onChanged: (_) => _resolveAccount(),
              decoration: const DavoInlineInputDecoration(
                hintText: 'Enter account number',
              ),
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 12,
                height: 1.25,
                color: DavoColors.of(context).body,
              ),
            ),
          ),
          const SizedBox(height: 16),
          _BankFormBox(
            label: 'Account Name',
            value: _checking
                ? 'Checking account…'
                : (_resolvedName ?? 'Enter bank and account number'),
            muted: !valid,
            valueSize: 16,
            valueWeight: valid ? FontWeight.w400 : FontWeight.w600,
            height: 70,
          ),
        ],
      ),
      action: _Button(
        label: 'Save Account',
        enabled: valid,
        fontWeight: FontWeight.w700,
        onTap: () => Navigator.pop(
          context,
          BankAccount(bank!, number.text, 'Callietus Ezeike Chinecherem'),
        ),
      ),
    );
  }

  Future<void> _chooseBank() async {
    final b = await showModalBottomSheet<String>(
      context: context,
      sheetAnimationStyle:
          (MediaQuery.disableAnimationsOf(context) ||
              MediaQuery.accessibleNavigationOf(context))
          ? AnimationStyle.noAnimation
          : const AnimationStyle(
              duration: Duration(milliseconds: 280),
              reverseDuration: Duration(milliseconds: 200),
            ),
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .32),
      builder: (_) => const _BankSheet(),
    );
    if (mounted && b != null) {
      bank = b;
      _resolveAccount();
    }
  }
}

class _BankTopBar extends StatelessWidget {
  const _BankTopBar({required this.onBack});
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton(
        tooltip: 'Back',
        onPressed: onBack,
        icon: Icon(Icons.arrow_back_rounded, color: DavoColors.of(context).ink),
      ),
      Expanded(
        child: Text(
          'Add a Bank Account',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Sora',
            fontSize: 16,
            height: 1.35,
            color: DavoColors.of(context).ink,
          ),
        ),
      ),
      const SizedBox(width: 48),
    ],
  );
}

class _BankFormBox extends StatelessWidget {
  const _BankFormBox({
    required this.label,
    this.value,
    this.child,
    this.muted = false,
    this.onTap,
    this.valueSize = 12,
    this.valueWeight = FontWeight.w400,
    this.height = 73,
  });
  final String label;
  final String? value;
  final Widget? child;
  final bool muted;
  final VoidCallback? onTap;
  final double valueSize;
  final FontWeight valueWeight;
  final double height;

  @override
  Widget build(BuildContext context) => Focus(
    child: Builder(
      builder: (context) => Material(
        color: DavoColors.of(context).canvas,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            constraints: BoxConstraints(minHeight: height),
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 10, 10, 8),
            decoration: BoxDecoration(
              border: Border.all(
                color: Focus.of(context).hasFocus
                    ? AppColors.primary
                    : DavoColors.of(context).border,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    height: 1.35,
                    color: DavoColors.of(context).body,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child:
                          child ??
                          Text(
                            value ?? '',
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: valueSize,
                              height: valueSize == 16 ? 1.35 : 1.25,
                              fontWeight: valueWeight,
                              color: muted
                                  ? DavoColors.of(context).muted
                                  : DavoColors.of(context).ink,
                            ),
                          ),
                    ),
                    if (onTap != null)
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: DavoColors.of(context).ink,
                        size: 20,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _BankSheet extends StatefulWidget {
  const _BankSheet();
  @override
  State<_BankSheet> createState() => _BankSheetState();
}

class _BankSheetState extends State<_BankSheet> {
  static const banks = [
    'AAA Finance',
    'AB Microfinance Bank',
    'Access Bank',
    'Kuda Bank',
    'Bank Of Agriculture',
    'Carbon',
    'Ecobank Bank',
    'Fcmb',
    'Fidelity Bank',
  ];
  final search = TextEditingController();

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = search.text.trim().toLowerCase();
    final visible = banks
        .where((b) => q.isEmpty || b.toLowerCase().contains(q))
        .toList();
    final available = MediaQuery.sizeOf(context).height - 31;
    final sheetHeight = available < 640
        ? available
        : available > 813
        ? 813.0
        : available;
    return DavoSafeSelectionSheet(
      child: Container(
        height: sheetHeight,
        decoration: BoxDecoration(
          color: DavoColors.of(context).surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 11,
              child: Center(
                child: Container(
                  width: 62,
                  height: 5,
                  decoration: BoxDecoration(
                    color: DavoColors.of(context).bodyMuted,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 10,
              top: 30,
              child: _AssetButton(
                asset: '$_exact/crypto_close_exact.png',
                size: 24,
                onTap: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 37,
              child: Text(
                'Select Bank',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 16,
                  height: 1.35,
                  color: DavoColors.of(context).ink,
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              top: 76,
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: DavoColors.of(context).canvas,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      '$_exact/crypto_search_exact.png',
                      color: DavoColors.of(context).ink,
                      width: 24,
                      height: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: search,
                        onChanged: (_) => setState(() {}),
                        decoration: const DavoInlineInputDecoration(
                          hintText: 'Search for a bank',
                        ),
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 14,
                          height: 1.35,
                          color: DavoColors.of(context).ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              top: 144,
              bottom: 73,
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: visible.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, i) => InkWell(
                  onTap: () => Navigator.pop(context, visible[i]),
                  child: SizedBox(
                    height: 52,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          width: 40,
                          height: 40,
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: DavoColors.of(context).border,
                              shape: BoxShape.circle,
                            ),
                            child: DavoBankLogo(bankName: visible[i], size: 40),
                          ),
                        ),
                        Positioned(
                          left: 64,
                          top: 10.5,
                          right: 0,
                          child: Text(
                            visible[i],
                            style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 14,
                              height: 1.35,
                              color: DavoColors.of(context).ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (sheetHeight >= 790)
              Positioned(
                left: 128,
                bottom: 8,
                child: Container(
                  width: 134,
                  height: 5,
                  decoration: BoxDecoration(
                    color: DavoColors.of(context).ink,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NairaConfirm extends StatefulWidget {
  const _NairaConfirm({required this.amount, required this.account});
  final String amount;
  final BankAccount account;
  @override
  State<_NairaConfirm> createState() => _NairaConfirmState();
}

class _NairaConfirmState extends State<_NairaConfirm> {
  bool agreed = false;

  @override
  Widget build(BuildContext context) {
    final minor = AssetAmount.parse(
      widget.amount.replaceAll(',', ''),
      'NGN',
      2,
    ).atomicUnits.toInt();
    return DavoSafeSelectionSheet(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: 'Close review',
                  onPressed: () => Navigator.pop(context, false),
                  icon: const Icon(Icons.close),
                ),
                const Expanded(
                  child: Text(
                    'Review withdrawal',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DavoNairaAmount(
              minorUnits: minor,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: DavoColors.of(context).ink,
              ),
            ),
            const SizedBox(height: 8),
            const Text('From Davochain Naira', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            _ExactNairaConfirmLine('Bank', widget.account.bank),
            _ExactNairaConfirmLine('Account Number', widget.account.number),
            _ExactNairaConfirmLine('Name', widget.account.name),
            _ExactNairaConfirmLine('Amount', davochainNairaText(minor)),
            const _ExactNairaConfirmLine('Fee', '100.00 Davochain Naira'),
            _ExactNairaConfirmLine(
              'Total debit',
              davochainNairaText(minor + 10000),
              last: true,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => agreed = !agreed),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        children: [
                          Icon(
                            agreed
                                ? Icons.check_box
                                : Icons.check_box_outline_blank,
                            color: DavoColors.of(context).link,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text('I agree to the terms and condition'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Read terms and conditions',
                  onPressed: () =>
                      showSettingsContent(context, 'Terms and Condition'),
                  icon: const Icon(Icons.info_outline),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _Button(
              label: 'Confirm Withdrawal',
              enabled: agreed && _withinNairaWithdrawalLimit(widget.amount),
              fontWeight: FontWeight.w700,
              onTap: () {
                if (agreed && _withinNairaWithdrawalLimit(widget.amount)) {
                  Navigator.pop(context, true);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ExactNairaConfirmLine extends StatelessWidget {
  const _ExactNairaConfirmLine(this.label, this.value, {this.last = false});
  final String label, value;
  final bool last;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      border: last
          ? null
          : Border(
              bottom: BorderSide(
                color: DavoColors.of(context).divider,
                width: .6,
              ),
            ),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: DavoColors.of(context).bodyMuted,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 13, color: DavoColors.of(context).ink),
          ),
        ),
      ],
    ),
  );
}
