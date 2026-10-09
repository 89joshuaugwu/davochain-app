import '../../../shared/widgets/davo_safe_selection_sheet.dart';
import '../../../shared/receipts/receipt_record.dart';
import '../../../shared/receipts/receipt_activity.dart';
import '../../../shared/receipts/receipt_screen.dart';
import '../../../shared/receipts/transaction_record_details_screen.dart';
import 'crypto_receipt_records.dart';
import 'crypto_transaction_kind.dart';
export 'crypto_transaction_kind.dart';
import '../../../core/preview/settings_preview_session.dart';
import '../../funding/funding_outcomes.dart';
import '../../../core/preview/preview_transaction_operation.dart';
import '../../../shared/motion/davo_working_indicator.dart';
import '../../../shared/motion/davo_motion_spec.dart';
import '../../../shared/widgets/davo_sheet_header.dart';
import '../../../shared/widgets/davo_bank_logo.dart';
import '../../../shared/widgets/solana_icon.dart';
import '../../../shared/formatters/grouped_amount_formatter.dart';
import '../../../shared/widgets/davo_success_mark.dart';
import '../../../shared/widgets/davo_result_screen.dart';
import '../../../shared/widgets/receipt_detail_row.dart';
import '../../../shared/widgets/trade_form_layout.dart';
import '../../buy_crypto/presentation/buy_crypto_screens.dart';
import '../../../shared/widgets/transaction_pin_entry.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/inline_input_decoration.dart';
import '../../buy_crypto/presentation/buy_crypto_models.dart';
import '../../buy_crypto/presentation/buy_crypto_widgets.dart';

const _f = 'assets/figma_exact';
const _cf = 'assets/figma_exact';
const _exact = 'assets/figma_exact';

enum TradeMode { sell, convert }


enum _WithdrawWallet { naira, crypto }

Future<void> startWithdrawFlow(BuildContext context) async {
  HapticFeedback.selectionClick();
  final selected = await showModalBottomSheet<_WithdrawWallet>(
    context: context,
    sheetAnimationStyle: (MediaQuery.disableAnimationsOf(context) ||
            MediaQuery.accessibleNavigationOf(context))
        ? AnimationStyle.noAnimation
        : const AnimationStyle(
            duration: Duration(milliseconds: 280),
            reverseDuration: Duration(milliseconds: 200)),
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: .32),
    builder: (_) => const _WithdrawWalletSheet(),
  );
  if (!context.mounted || selected == null) return;
  await Navigator.of(context).push<void>(AppPageRoute<void>(
    builder: (_) => selected == _WithdrawWallet.naira
        ? const NairaWithdrawScreen()
        : const CryptoWithdrawModeScreen(),
  ));
}

Future<void> startSellCryptoFlow(BuildContext context) async {
  HapticFeedback.selectionClick();
  final asset = await showModalBottomSheet<BuyCryptoAsset>(
    context: context,
    sheetAnimationStyle: (MediaQuery.disableAnimationsOf(context) ||
            MediaQuery.accessibleNavigationOf(context))
        ? AnimationStyle.noAnimation
        : const AnimationStyle(
            duration: Duration(milliseconds: 280),
            reverseDuration: Duration(milliseconds: 200)),
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: .32),
    builder: (_) => const BuyCryptoAssetSheet(),
  );
  if (!context.mounted || asset == null) return;
  final wallet = await showModalBottomSheet<bool>(
    context: context,
    sheetAnimationStyle: (MediaQuery.disableAnimationsOf(context) ||
            MediaQuery.accessibleNavigationOf(context))
        ? AnimationStyle.noAnimation
        : const AnimationStyle(
            duration: Duration(milliseconds: 280),
            reverseDuration: Duration(milliseconds: 200)),
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: .32),
    builder: (_) => const _SellWalletSheet(),
  );
  if (!context.mounted || wallet != true) return;
  await Navigator.of(context).push<void>(AppPageRoute<void>(
      builder: (_) => TradeAmountScreen(mode: TradeMode.sell, asset: asset)));
}

Future<void> startConvertCryptoFlow(BuildContext context) async {
  HapticFeedback.selectionClick();
  await Navigator.of(context).push<void>(AppPageRoute<void>(
      builder: (_) => const TradeAmountScreen(
          mode: TradeMode.convert, asset: BuyCryptoAsset.bitcoin)));
}

Future<void> openDepositStatus(BuildContext context,
    {required bool success}) async {
  await Navigator.of(context).push<void>(AppPageRoute<void>(
      builder: (_) => DepositStatusScreen(success: success)));
}

class _WithdrawWalletSheet extends StatelessWidget {
  const _WithdrawWalletSheet();

  @override
  Widget build(BuildContext context) => DavoSafeSelectionSheet(child: Container(
        height: 472,
        decoration: BoxDecoration(
            color: DavoColors.of(context).canvas,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16))),
        child: Stack(
          children: [
            Positioned(
                left: 0,
                right: 0,
                top: 6,
                child: Center(
                    child: Container(
                        width: 85,
                        height: 4,
                        decoration: BoxDecoration(
                            color: DavoColors.of(context).bodyMuted,
                            borderRadius: BorderRadius.circular(100))))),
            const Positioned(
                left: 0,
                right: 0,
                top: 16,
                child: DavoSheetHeader(title: 'Select Wallet')),
            Positioned(
              left: 16,
              top: 67,
              right: 16,
              child: InkWell(
                onTap: () => Navigator.pop(context, _WithdrawWallet.crypto),
                child: SizedBox(
                  height: 48,
                  child: Row(
                    children: [
                      Container(
                          width: 34,
                          height: 34,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: DavoColors.of(context).primarySoft,
                              shape: BoxShape.circle),
                          child: Image.asset(
                              '$_exact/crypto_plus_circle_exact.png',
                              width: 24,
                              height: 24)),
                      const SizedBox(width: 18),
                      Expanded(
                          child: Text('Add crypto asset',
                              style: TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  height: 1.35,
                                  color: DavoColors.of(context).ink))),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
                left: 16,
                right: 16,
                top: 125,
                child: _WalletSelectRow(
                    asset: '$_f/buy_nigeria.png',
                    title: 'Nigeria Naira',
                    symbol: 'NGN',
                    iconSize: 40,
                    onTap: () =>
                        Navigator.pop(context, _WithdrawWallet.naira))),
            Positioned(
                left: 16,
                right: 16,
                top: 188,
                child: _WalletSelectRow(
                    asset: '$_f/btc.png',
                    title: 'Bitcoin',
                    symbol: 'BTC',
                    onTap: () =>
                        Navigator.pop(context, _WithdrawWallet.crypto))),
            Positioned(
                left: 16,
                right: 16,
                top: 251,
                child: _WalletSelectRow(
                    asset: '$_f/eth.png',
                    title: 'Ethereum',
                    symbol: 'ETH',
                    onTap: () =>
                        Navigator.pop(context, _WithdrawWallet.crypto))),
            Positioned(
                left: 16,
                right: 16,
                top: 314,
                child: _WalletSelectRow(
                    asset: '$_f/sol.png',
                    title: 'Solana',
                    symbol: 'SOL',
                    onTap: () =>
                        Navigator.pop(context, _WithdrawWallet.crypto))),
            Positioned(
                left: 16,
                right: 16,
                top: 377,
                child: _WalletSelectRow(
                    asset: '$_f/usdt.png',
                    title: 'Tether',
                    symbol: 'USDT',
                    onTap: () =>
                        Navigator.pop(context, _WithdrawWallet.crypto))),
          ],
        ),
      ));
}

class _WalletSelectRow extends StatelessWidget {
  const _WalletSelectRow(
      {required this.asset,
      required this.title,
      required this.symbol,
      required this.onTap,
      this.iconSize = 32});
  final String asset, title, symbol;
  final VoidCallback onTap;
  final double iconSize;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 55,
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 7,
                width: 40,
                height: 40,
                child: Center(
                    child: asset.endsWith('/sol.png')
                        ? SolanaIcon(size: iconSize)
                        : Image.asset(asset,
                            width: iconSize,
                            height: iconSize,
                            fit: BoxFit.contain)),
              ),
              Positioned(
                  left: 52,
                  top: 9,
                  child: Text(title,
                      style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 14,
                          height: 1.35,
                          color: DavoColors.of(context).ink))),
              Positioned(
                  left: 52,
                  top: 30,
                  child: Text(symbol,
                      style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 12,
                          height: 1.25,
                          color: DavoColors.of(context).body))),
            ],
          ),
        ),
      );
}

class _SellWalletSheet extends StatelessWidget {
  const _SellWalletSheet();
  @override
  Widget build(BuildContext context) => DavoSafeSelectionSheet(child: Container(
        height: 242,
        decoration: BoxDecoration(
            color: DavoColors.of(context).canvas,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20))),
        child: Stack(
          children: [
            Positioned(
                left: 0,
                right: 0,
                top: 6,
                child: Center(
                    child: Container(
                        width: 85,
                        height: 4,
                        decoration: BoxDecoration(
                            color: DavoColors.of(context).bodyMuted,
                            borderRadius: BorderRadius.circular(100))))),
            Positioned(
                left: 0,
                right: 0,
                top: 32,
                child: Text('Select wallet to sell into',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 14,
                        height: 1.35,
                        color: DavoColors.of(context).ink))),
            Positioned(
                right: 16,
                top: 20,
                width: 24,
                height: 24,
                child: InkResponse(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset('$_f/buy_close.png',
                        color: DavoColors.of(context).ink,
                        width: 24,
                        height: 24))),
            Positioned(
              left: 16,
              right: 16,
              top: 67,
              height: 55,
              child: InkWell(
                onTap: () => Navigator.pop(context, true),
                child: Stack(
                  children: [
                    Positioned(
                        left: 0,
                        top: 9,
                        width: 32,
                        height: 32,
                        child: Image.asset('$_f/buy_nigeria.png',
                            width: 32, height: 32, fit: BoxFit.contain)),
                    Positioned(
                        left: 44,
                        top: 7,
                        child: Text('Nigerian Naira',
                            style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 14,
                                height: 1.35,
                                color: DavoColors.of(context).ink))),
                    Positioned(
                        left: 44,
                        top: 28,
                        child: Text('NGN',
                            style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 12,
                                height: 1.25,
                                color: DavoColors.of(context).body))),
                    Positioned(
                        right: 0,
                        top: 8,
                        child: Text('0.00 USD',
                            style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 14,
                                height: 1.35,
                                color: DavoColors.of(context).body))),
                    Positioned(
                        right: 0,
                        top: 29,
                        child: Text('0.00₦',
                            style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 10,
                                height: 1.3,
                                color: DavoColors.of(context).bodyMuted))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ));
}

class NairaWithdrawScreen extends StatefulWidget {
  const NairaWithdrawScreen({super.key});
  @override
  State<NairaWithdrawScreen> createState() => _NairaWithdrawScreenState();
}

class _NairaWithdrawScreenState extends State<NairaWithdrawScreen> {
  final amount = TextEditingController();
  BankAccount? account;
  bool _reviewing = false;
  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ready = parseAmount(amount.text).isFinite &&
        parseAmount(amount.text) > 0 &&
        parseAmount(amount.text) <= 5000000 &&
        account != null &&
        !_reviewing;
    return _Scaffold(
      child: Stack(
        children: [
          const Positioned(
              left: 0, right: 0, top: 4, height: 40, child: _DashboardHeader()),
          const Positioned(
              left: 0, right: 0, top: 60, height: 136, child: _BalanceCard()),
          Positioned(
            left: 0,
            right: 0,
            top: 220,
            height: 73,
            child: _ExactNairaField(
              label: 'Amount',
              child: TextField(
                controller: amount,
                inputFormatters: const [GroupedAmountInputFormatter()],
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                decoration: DavoInlineInputDecoration(
                  hintText: '0',
                  hintStyle: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 16,
                      height: 1.35,
                      color: DavoColors.of(context).bodyMuted),
                ),
                style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 16,
                    height: 1.35,
                    color: DavoColors.of(context).ink),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 305,
            height: 15,
            child: Text('Max daily amount - ₦5,000,000',
                style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 12,
                    height: 1.25,
                    color: DavoColors.of(context).body)),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 344,
            height: 73,
            child: _ExactNairaField(
              label: 'Payment Method',
              onTap: _payment,
              trailing: Image.asset('$_exact/naira_payment_chevron_exact.png',
                  color: DavoColors.of(context).ink,
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain),
              child: account == null
                  ? Text('Select a payment method',
                      style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 16,
                          height: 1.35,
                          color: DavoColors.of(context).bodyMuted))
                  : Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(account!.bank,
                          style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 14,
                              height: 1.35,
                              color: DavoColors.of(context).ink)),
                    ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 690,
            height: 48,
            child: _Button(
              label: 'Continue',
              enabled: ready,
              fontWeight: FontWeight.w700,
              onTap: ready ? _review : () {},
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _payment() async {
    final value = await showModalBottomSheet<BankAccount>(
        context: context,
        sheetAnimationStyle: (MediaQuery.disableAnimationsOf(context) ||
                MediaQuery.accessibleNavigationOf(context))
            ? AnimationStyle.noAnimation
            : const AnimationStyle(
                duration: Duration(milliseconds: 280),
                reverseDuration: Duration(milliseconds: 200)),
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: .32),
        builder: (_) => _PaymentSheet(current: account));
    if (mounted && value != null) setState(() => account = value);
  }

  Future<void> _review() async {
    if (account == null || _reviewing) return;
    setState(() => _reviewing = true);
    try {
      final ok = await showModalBottomSheet<bool>(
          context: context,
          sheetAnimationStyle: (MediaQuery.disableAnimationsOf(context) ||
                  MediaQuery.accessibleNavigationOf(context))
              ? AnimationStyle.noAnimation
              : const AnimationStyle(
                  duration: Duration(milliseconds: 280),
                  reverseDuration: Duration(milliseconds: 200)),
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: Colors.transparent,
          barrierColor: Colors.black.withValues(alpha: .32),
          builder: (_) =>
              _NairaConfirm(amount: amount.text, account: account!));
      if (!mounted || ok != true) return;
      final pin = await Navigator.push<bool>(
          context, AppPageRoute<bool>(builder: (_) => const CryptoPinScreen()));
      if (!mounted || pin != true) return;
      await Navigator.of(context).push(AppPageRoute<void>(
        builder: (_) => NairaWithdrawalProgressScreen(
            amount: parseAmount(amount.text),
            bank: account!.bank,
            accountNumber: account!.number,
            accountName: account!.name),
      ));
    } finally {
      if (mounted) setState(() => _reviewing = false);
    }
  }
}

class _ExactNairaField extends StatelessWidget {
  const _ExactNairaField(
      {required this.label, required this.child, this.trailing, this.onTap});
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
                      width: 1),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(4),
                  child: Stack(
                    children: [
                      Positioned(
                          left: 12,
                          right: 12,
                          top: 10,
                          height: 19,
                          child: Text(label,
                              style: TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 14,
                                  height: 1.35,
                                  color: DavoColors.of(context).body))),
                      Positioned(
                        left: 12,
                        right: trailing == null ? 12 : 44,
                        top: 37,
                        height: 24,
                        child: child,
                      ),
                      if (trailing != null)
                        Positioned(
                            right: 12,
                            top: 24.5,
                            width: 24,
                            height: 24,
                            child: trailing!),
                    ],
                  ),
                ),
              )));
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
      if (current != null) current!,
      for (final bank in SettingsPreviewSession.instance.banks)
        if (current?.bank != bank.bank || current?.number != bank.number)
          BankAccount(bank.bank, bank.number, bank.name),
    ];
    return Material(
      color: DavoColors.of(context).canvas,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(child: SizedBox(
      height: MediaQuery.sizeOf(context).height * .6,
      child: Column(children: [
        const SizedBox(height: 8),
        Container(width: 60, height: 4, decoration: BoxDecoration(
          color: DavoColors.of(context).bodyMuted, borderRadius: BorderRadius.circular(100))),
        Padding(padding: const EdgeInsets.fromLTRB(24, 8, 12, 0), child: Row(children: [
          const Expanded(child: Text('Select a payment method', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
          IconButton(tooltip: 'Close', onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
        ])),
        Expanded(child: ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 24), children: [
          ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add new payment method', style: TextStyle(fontSize: 14)), onTap: () async {
              final account = await Navigator.push<BankAccount>(context,
                AppPageRoute<BankAccount>(builder: (_) => const AddBankScreen()));
              if (context.mounted && account != null) {
                SettingsPreviewSession.instance.acceptBank(LinkedBank(bank: account.bank,
                  number: account.number, name: account.name));
                Navigator.pop(context, account);
              }
            }),
          const Text('Preview accounts', style: TextStyle(fontSize: 12)),
          const SizedBox(height: 12),
          for (final account in saved) Padding(padding: const EdgeInsets.only(bottom: 12),
            child: _PaymentMethodSavedRow(account: account, onTap: () => Navigator.pop(context, account))),
        ])),
      ]),
    )));
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
                  Text(account.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 14,
                          height: 1.35,
                          color: DavoColors.of(context).body)),
                  const SizedBox(height: 2),
                  Text('${account.bank} - ${account.number}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 12,
                          height: 1.25,
                          color: DavoColors.of(context).bodyMuted)),
                ],
              ),
            ),
            Positioned(
                right: 0,
                top: 19.5,
                width: 16,
                height: 16,
                child: Image.asset('$_exact/crypto_ep_arrow_right_exact.png',
                    color: DavoColors.of(context).ink,
                    width: 16,
                    height: 16,
                    fit: BoxFit.contain)),
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
          SizedBox(
            height: 44,
            child: Text(
              'Add your bank account to receive money fast and secured easily',
              style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 16,
                  height: 1.35,
                  color: DavoColors.of(context).body),
            ),
          ),
          const SizedBox(height: 24),
          _BankFormBox(
              label: 'Bank Name',
              value: bank ?? 'Select bank name',
              muted: bank == null,
              onTap: _chooseBank),
          const SizedBox(height: 16),
          _BankFormBox(
            label: 'Account Number',
            child: TextField(
              controller: number,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10)
              ],
              onChanged: (_) => _resolveAccount(),
              decoration: const DavoInlineInputDecoration(
                  hintText: 'Enter account number'),
              style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 12,
                  height: 1.25,
                  color: DavoColors.of(context).body),
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
                BankAccount(
                    bank!, number.text, 'Callietus Ezeike Chinecherem')),
          ),
    );
  }

  Future<void> _chooseBank() async {
    final b = await showModalBottomSheet<String>(
      context: context,
      sheetAnimationStyle: (MediaQuery.disableAnimationsOf(context) ||
              MediaQuery.accessibleNavigationOf(context))
          ? AnimationStyle.noAnimation
          : const AnimationStyle(
              duration: Duration(milliseconds: 280),
              reverseDuration: Duration(milliseconds: 200)),
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
  Widget build(BuildContext context) => SizedBox(
        height: 32,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
                left: -14,
                top: -3,
                child: _AssetButton(
                    asset: '$_f/buy_back.png', size: 24, onTap: onBack)),
            Positioned(
                left: 0,
                right: 0,
                top: 4,
                height: 22,
                child: IgnorePointer(
                    child: Text('Add a Bank Account',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                            color: DavoColors.of(context).ink)))),
          ],
        ),
      );
}

class _BankFormBox extends StatelessWidget {
  const _BankFormBox(
      {required this.label,
      this.value,
      this.child,
      this.muted = false,
      this.onTap,
      this.valueSize = 12,
      this.valueWeight = FontWeight.w400,
      this.height = 73});
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
                                : DavoColors.of(context).border),
                        borderRadius: BorderRadius.circular(4)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label,
                            style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 14,
                                height: 1.35,
                                color: DavoColors.of(context).body)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: child ??
                                  Text(value ?? '',
                                      style: TextStyle(
                                          fontFamily: 'Sora',
                                          fontSize: valueSize,
                                          height: valueSize == 16 ? 1.35 : 1.25,
                                          fontWeight: valueWeight,
                                          color: muted
                                              ? DavoColors.of(context).muted
                                              : DavoColors.of(context).ink)),
                            ),
                            if (onTap != null)
                              Image.asset('$_cf/chevron_right.png',
                                  color: DavoColors.of(context).ink,
                                  width: 16,
                                  height: 16),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              )));
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
    'Fidelity Bank'
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
    final visible =
        banks.where((b) => q.isEmpty || b.toLowerCase().contains(q)).toList();
    final available = MediaQuery.sizeOf(context).height - 31;
    final sheetHeight = available < 640
        ? available
        : available > 813
            ? 813.0
            : available;
    return DavoSafeSelectionSheet(child: Container(
      height: sheetHeight,
      decoration: BoxDecoration(
          color: DavoColors.of(context).surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
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
                          borderRadius: BorderRadius.circular(100))))),
          Positioned(
              left: 10,
              top: 30,
              child: _AssetButton(
                  asset: '$_exact/crypto_close_exact.png',
                  size: 24,
                  onTap: () => Navigator.pop(context))),
          Positioned(
              left: 0,
              right: 0,
              top: 37,
              child: Text('Select Bank',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 16,
                      height: 1.35,
                      color: DavoColors.of(context).ink))),
          Positioned(
            left: 16,
            right: 16,
            top: 76,
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                  color: DavoColors.of(context).canvas,
                  borderRadius: BorderRadius.circular(4)),
              child: Row(
                children: [
                  Image.asset('$_exact/crypto_search_exact.png',
                      color: DavoColors.of(context).ink, width: 24, height: 24),
                  const SizedBox(width: 16),
                  Expanded(
                      child: TextField(
                          controller: search,
                          onChanged: (_) => setState(() {}),
                          decoration: const DavoInlineInputDecoration(
                              hintText: 'Search for a bank'),
                          style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 14,
                              height: 1.35,
                              color: DavoColors.of(context).ink))),
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
                                  shape: BoxShape.circle),
                              child: DavoBankLogo(
                                  bankName: visible[i], size: 40))),
                      Positioned(
                          left: 64,
                          top: 10.5,
                          right: 0,
                          child: Text(visible[i],
                              style: TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 14,
                                  height: 1.35,
                                  color: DavoColors.of(context).ink))),
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
                        borderRadius: BorderRadius.circular(100)))),
        ],
      ),
    ));
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
  Widget build(BuildContext context) => DavoSafeSelectionSheet(child: Container(
        height: 539,
        decoration: BoxDecoration(
            color: DavoColors.of(context).surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20))),
        child: Stack(
          children: [
            Positioned(
              left: 16,
              top: 32,
              width: 23,
              height: 24,
              child: InkResponse(
                  onTap: () => Navigator.pop(context, false),
                  radius: 20,
                  child: Image.asset('$_exact/crypto_close_exact.png',
                      color: DavoColors.of(context).ink,
                      width: 23,
                      height: 24,
                      fit: BoxFit.fill)),
            ),
            Positioned(
                right: 14,
                top: 36.5,
                child: Text('Use Payment PIN',
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 12,
                        height: 1.25,
                        color: DavoColors.of(context).link))),
            Positioned(
              left: 16,
              right: 14,
              top: 80,
              height: 307,
              child: Container(
                decoration: BoxDecoration(
                    color: DavoColors.of(context).canvas,
                    borderRadius: BorderRadius.circular(8)),
                child: Stack(
                  children: [
                    Positioned(
                        left: 0,
                        right: 0,
                        top: 28,
                        height: 27,
                        child: Center(
                            child: Text('₦${widget.amount}',
                                style: TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    height: 1.35,
                                    color: DavoColors.of(context).ink)))),
                    Positioned(
                        left: 15,
                        right: 15,
                        top: 73,
                        child: _ExactNairaConfirmLine(
                            'Bank', widget.account.bank)),
                    Positioned(
                        left: 15,
                        right: 15,
                        top: 120,
                        child: _ExactNairaConfirmLine(
                            'Account Number', widget.account.number)),
                    Positioned(
                        left: 15,
                        right: 15,
                        top: 167,
                        child: _ExactNairaConfirmLine('Name',
                            widget.account.name.split(' ').take(2).join(' '))),
                    Positioned(
                        left: 15,
                        right: 15,
                        top: 214,
                        child: _ExactNairaConfirmLine(
                            'Amount', '₦${widget.amount}')),
                    const Positioned(
                        left: 15,
                        right: 15,
                        top: 267,
                        child: _ExactNairaConfirmLine('Fee', '₦100.00',
                            last: true)),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              top: 411,
              height: 16,
              child: InkWell(
                onTap: () => setState(() => agreed = !agreed),
                child: Row(
                  children: [
                    Image.asset(
                        agreed
                            ? '$_exact/crypto_checked_exact.png'
                            : '$_exact/crypto_unchecked_exact.png',
                        width: 16,
                        height: 16),
                    const SizedBox(width: 8),
                    Text('I agree to the terms and condition',
                        style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 12,
                            height: 1.25,
                            color: DavoColors.of(context).link)),
                  ],
                ),
              ),
            ),
            Positioned(
                left: 16,
                right: 14,
                top: 467,
                height: 48,
                child: _Button(
                    label: 'Confirm Withdrawal',
                    enabled: agreed,
                    fontWeight: FontWeight.w700,
                    onTap: () => Navigator.pop(context, true))),
          ],
        ),
      ));
}

class _ExactNairaConfirmLine extends StatelessWidget {
  const _ExactNairaConfirmLine(this.label, this.value, {this.last = false});
  final String label, value;
  final bool last;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 35,
        child: Stack(
          children: [
            Positioned(
                left: 0,
                top: 0,
                child: Text(label,
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 14,
                        height: 1.35,
                        color: DavoColors.of(context).bodyMuted))),
            Positioned(
                right: 0,
                top: 0,
                child: Text(value,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 14,
                        height: 1.35,
                        color: DavoColors.of(context).ink))),
            if (!last)
              Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Divider(
                      height: 1,
                      thickness: .6,
                      color: DavoColors.of(context).divider)),
          ],
        ),
      );
}

class CryptoWithdrawModeScreen extends StatelessWidget {
  const CryptoWithdrawModeScreen({super.key});

  @override
  Widget build(BuildContext context) => _Scaffold(
        child: Column(
          children: [
            _TopBar(
              title: 'Crypto Withdraw Mode',
              onBack: () => Navigator.pop(context),
              height: 32,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            const SizedBox(height: 17),
            _Choice(
              asset: '$_cf/user_circle.png',
              title: 'To Davochain User',
              subtitle:
                  'Send Crypto to another Davochain\nuser instantly at zero fees',
              onTap: () => Navigator.push(
                  context,
                  AppPageRoute<void>(
                      builder: (_) =>
                          const CryptoWithdrawEntryScreen(external: false))),
            ),
            const SizedBox(height: 16),
            _Choice(
              asset: '$_cf/qr_wallet.png',
              title: 'Wallet Address',
              subtitle:
                  'Send crypto to an external wallet,\nnetwork fee applies',
              onTap: () => Navigator.push(
                  context,
                  AppPageRoute<void>(
                      builder: (_) =>
                          const CryptoWithdrawEntryScreen(external: true))),
            ),
          ],
        ),
      );
}

class CryptoWithdrawEntryScreen extends StatefulWidget {
  const CryptoWithdrawEntryScreen({super.key, required this.external});
  final bool external;
  @override
  State<CryptoWithdrawEntryScreen> createState() =>
      _CryptoWithdrawEntryScreenState();
}

class _CryptoWithdrawEntryScreenState extends State<CryptoWithdrawEntryScreen> {
  final target = TextEditingController();
  final amount = TextEditingController();
  String? network;
  BuyCryptoAsset asset = BuyCryptoAsset.bitcoin;

  @override
  void dispose() {
    target.dispose();
    amount.dispose();
    super.dispose();
  }

  bool get _ready =>
      target.text.isNotEmpty &&
      parseAmount(amount.text) > 0 &&
      (!widget.external || network != null);

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (_, __) => _cancel(),
        child:
            widget.external ? _buildExternal(context) : _buildInternal(context),
      );

  Widget _buildInternal(BuildContext context) => _buildEntry(context);
  Widget _buildExternal(BuildContext context) => _buildEntry(context);

  Widget _buildEntry(BuildContext context) => Scaffold(
        backgroundColor: DavoColors.of(context).canvas,
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: widget.external
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                          child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Receiving',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: DavoColors.of(context).bodyMuted)),
                          const SizedBox(height: 6),
                          Text(
                              '${formatGroupedAmount(parseAmount(amount.text).toStringAsFixed(5))} ${asset.symbol}',
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(
                              'Network fee: ${network == null ? '—' : '0.00002 ${asset.symbol}'}',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: DavoColors.of(context).bodyMuted)),
                        ],
                      )),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _Button(
                              label: 'Confirm',
                              disabledColor: DavoColors.of(context).mutedSoft,
                              disabledTextColor:
                                  DavoColors.of(context).bodyMuted,
                              enabled: _ready,
                              onTap: _confirm)),
                    ],
                  )
                : _Button(label: 'Continue', enabled: _ready, onTap: _confirm),
          ),
        ),
        body: SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TopBar(
                        title: 'Withdraw',
                        onBack: _cancel,
                        height: 32,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                    const SizedBox(height: 16),
                    _CryptoBalance(asset: asset, onChange: _changeAsset),
                    const SizedBox(height: 24),
                    _entryField(
                        widget.external ? 'Address' : 'Transfer To',
                        Row(children: [
                          Expanded(
                              child: TextField(
                                  controller: target,
                                  onChanged: (_) => setState(() {}),
                                  decoration: DavoInlineInputDecoration(
                                      hintText: widget.external
                                          ? 'Paste the wallet address'
                                          : 'Enter Davochain username'),
                                  style: const TextStyle(fontSize: 14))),
                          if (widget.external)
                            IconButton(
                                onPressed: _scan,
                                tooltip: 'Scan wallet address',
                                icon: const Icon(Icons.qr_code_scanner_rounded,
                                    color: AppColors.primary, size: 22)),
                        ])),
                    if (widget.external) ...[
                      const SizedBox(height: 24),
                      _entryField(
                          'Network',
                          InkWell(
                              onTap: _network,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Text(
                                            network ??
                                                'Select withdrawal network',
                                            style:
                                                const TextStyle(fontSize: 14))),
                                    const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        color: AppColors.primary)
                                  ],
                                ),
                              ))),
                    ],
                    const SizedBox(height: 24),
                    _entryField(
                        widget.external ? 'Amount' : 'Enter Amount',
                        Row(children: [
                          BuyAssetIcon(asset: asset, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                              child: TextField(
                                  controller: amount,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: const [
                                    GroupedAmountInputFormatter()
                                  ],
                                  onChanged: (_) => setState(() {}),
                                  decoration: const DavoInlineInputDecoration(
                                      hintText: 'Enter amount'),
                                  style: const TextStyle(fontSize: 14))),
                          TextButton(
                              onPressed: () => setState(() =>
                                  amount.text = formatGroupedAmount('0.0300')),
                              child: Text(widget.external ? 'All' : 'Max')),
                          Text(asset.symbol,
                              style: const TextStyle(fontSize: 12)),
                        ])),
                    const SizedBox(height: 10),
                    Row(children: [
                      Expanded(
                          child: Text('Available',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: DavoColors.of(context).bodyMuted))),
                      Text('0.0300 ${asset.symbol}',
                          style: TextStyle(
                              fontSize: 14,
                              color: DavoColors.of(context).bodyMuted))
                    ]),
                    if (widget.external) ...[
                      const SizedBox(height: 24),
                      const Text('Withdrawal Notice',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      Text(
                          '1. Withdrawal limits: minimum 0.00002 ${asset.symbol}; maximum 100 ${asset.symbol} per transaction.\n\n'
                          '2. Daily limit: withdraw up to 200 ${asset.symbol} within 24 hours.\n\n'
                          '3. Internal transfers: transfers to other Davochain users are instant and free.\n\n'
                          '4. Unsupported addresses: avoid crowdfunding or ICO addresses that require token distribution.\n\n'
                          '5. Security: confirm the address and network, and use trusted destinations.',
                          style: TextStyle(
                              fontSize: 11,
                              height: 1.5,
                              color: DavoColors.of(context).bodyMuted)),
                    ] else ...[
                      const SizedBox(height: 12),
                      Text(r'Daily transfer limit - $500',
                          style: TextStyle(
                              fontSize: 12,
                              color: DavoColors.of(context).bodyMuted)),
                    ],
                  ]),
            )),
      );

  Widget _entryField(String label, Widget child) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Focus(
              child: Builder(
                  builder: (context) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                            color: DavoColors.of(context).surface,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: Focus.of(context).hasFocus
                                    ? AppColors.primary
                                    : DavoColors.of(context).border)),
                        child: child,
                      ))),
        ],
      );

  Future<void> _changeAsset() async {
    final selected = await showModalBottomSheet<BuyCryptoAsset>(
        context: context,
        sheetAnimationStyle: (MediaQuery.disableAnimationsOf(context) ||
                MediaQuery.accessibleNavigationOf(context))
            ? AnimationStyle.noAnimation
            : const AnimationStyle(
                duration: Duration(milliseconds: 280),
                reverseDuration: Duration(milliseconds: 200)),
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const BuyCryptoAssetSheet());
    if (!mounted || selected == null || selected == asset) return;
    setState(() {
      asset = selected;
      network = null;
    });
  }

  Future<void> _cancel() async {
    final c = await showModalBottomSheet<bool>(
      context: context,
      sheetAnimationStyle: (MediaQuery.disableAnimationsOf(context) ||
              MediaQuery.accessibleNavigationOf(context))
          ? AnimationStyle.noAnimation
          : const AnimationStyle(
              duration: Duration(milliseconds: 280),
              reverseDuration: Duration(milliseconds: 200)),
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .32),
      builder: (_) => const CancelReminderSheet(),
    );
    if (mounted && c == true) Navigator.pop(context);
  }

  Future<void> _scan() async {
    final a = await Navigator.push<String>(context,
        AppPageRoute<String>(builder: (_) => const ScanPasteAddressScreen()));
    if (mounted && a != null) setState(() => target.text = a);
  }

  Future<void> _network() async {
    final n = await showModalBottomSheet<String>(
      context: context,
      sheetAnimationStyle: (MediaQuery.disableAnimationsOf(context) ||
              MediaQuery.accessibleNavigationOf(context))
          ? AnimationStyle.noAnimation
          : const AnimationStyle(
              duration: Duration(milliseconds: 280),
              reverseDuration: Duration(milliseconds: 200)),
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .32),
      builder: (_) => asset == BuyCryptoAsset.bitcoin
          ? const SelectNetworkSheet()
          : SafeArea(
              child: Container(
                  padding: const EdgeInsets.all(20),
                  color: DavoColors.of(context).surface,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('Select Network'),
                    ...((asset == BuyCryptoAsset.solana)
                            ? ['Solana']
                            : (asset == BuyCryptoAsset.ethereum)
                                ? ['Ethereum (ERC20)']
                                : ['Ethereum (ERC20)', 'Tron (TRC20)'])
                        .map((name) => ListTile(
                            title: Text(name),
                            onTap: () => Navigator.pop(context, name)))
                  ]))),
    );
    if (!mounted || n == null) return;
    final understood = await showModalBottomSheet<bool>(
      context: context,
      sheetAnimationStyle: (MediaQuery.disableAnimationsOf(context) ||
              MediaQuery.accessibleNavigationOf(context))
          ? AnimationStyle.noAnimation
          : const AnimationStyle(
              duration: Duration(milliseconds: 280),
              reverseDuration: Duration(milliseconds: 200)),
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .32),
      builder: (_) => const SanctionWarningSheet(),
    );
    if (mounted && understood == true) setState(() => network = n);
  }

  Future<void> _confirm() async {
    final n = parseAmount(amount.text);
    final ok = await showModalBottomSheet<bool>(
      context: context,
      sheetAnimationStyle: (MediaQuery.disableAnimationsOf(context) ||
              MediaQuery.accessibleNavigationOf(context))
          ? AnimationStyle.noAnimation
          : const AnimationStyle(
              duration: Duration(milliseconds: 280),
              reverseDuration: Duration(milliseconds: 200)),
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .32),
      builder: (_) => widget.external
          ? _ExternalWithdrawConfirmSheet(
              target: target.text, amount: n, asset: asset)
          : _InternalWithdrawConfirmSheet(
              target: target.text, amount: n, asset: asset),
    );
    if (!mounted || ok != true) return;
    final pin = await Navigator.push<bool>(
        context, AppPageRoute<bool>(builder: (_) => const CryptoPinScreen()));
    if (!mounted || pin != true) return;
    Navigator.pushReplacement(
        context,
        AppPageRoute<void>(
            builder: (_) => TransactionProgressScreen(
                kind: widget.external ? TxKind.external : TxKind.internal,
                target: target.text,
                amount: n,
                asset: asset, network: network, fee: widget.external ? .00002 : 0)));
  }
}

class _ExternalWithdrawConfirmSheet extends StatelessWidget {
  const _ExternalWithdrawConfirmSheet(
      {required this.target,
      required this.amount,
      this.asset = BuyCryptoAsset.bitcoin});
  final String target;
  final double amount;
  final BuyCryptoAsset asset;
  @override
  Widget build(BuildContext context) => _WithdrawReviewSheet(
      target: target, amount: amount, asset: asset, external: true);
}

class _InternalWithdrawConfirmSheet extends StatelessWidget {
  const _InternalWithdrawConfirmSheet(
      {required this.target,
      required this.amount,
      this.asset = BuyCryptoAsset.bitcoin});
  final String target;
  final double amount;
  final BuyCryptoAsset asset;
  @override
  Widget build(BuildContext context) => _WithdrawReviewSheet(
      target: target, amount: amount, asset: asset, external: false);
}

class _WithdrawReviewSheet extends StatelessWidget {
  const _WithdrawReviewSheet(
      {required this.target,
      required this.amount,
      required this.asset,
      required this.external});
  final String target;
  final double amount;
  final BuyCryptoAsset asset;
  final bool external;
  @override
  Widget build(BuildContext context) => SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        decoration: BoxDecoration(
            color: DavoColors.of(context).surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20))),
        child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(children: [
            const Expanded(
                child: Text('Review withdrawal',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
            IconButton(
                onPressed: () => Navigator.pop(context, false),
                icon: const Icon(Icons.close_rounded))
          ]),
          const SizedBox(height: 16),
          Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: DavoColors.of(context).canvas,
                  borderRadius: BorderRadius.circular(8)),
              child: Column(children: [
                ReceiptDetailRow(
                    label: external ? 'Withdraw to' : 'Username',
                    value: target),
                const SizedBox(height: 20),
                ReceiptDetailRow(
                    label: 'Asset',
                    value: '${asset.name} (${asset.symbol})',
                    leading: BuyAssetIcon(asset: asset, size: 24)),
                const SizedBox(height: 20),
                ReceiptDetailRow(
                    label: 'Amount',
                    value:
                        '${formatGroupedAmount(amount.toStringAsFixed(5))} ${asset.symbol}'),
                const SizedBox(height: 20),
                ReceiptDetailRow(
                    label: 'Network fee',
                    value: external ? '0.00002 ${asset.symbol}' : 'Free',
                    valueColor: AppColors.primary),
                const SizedBox(height: 20),
                ReceiptDetailRow(
                    label: 'Total',
                    value:
                        '${formatGroupedAmount(amount.toStringAsFixed(5))} ${asset.symbol}'),
              ])),
          const SizedBox(height: 24),
          _Button(label: 'Confirm', onTap: () => Navigator.pop(context, true)),
        ])),
      ));
}

class TransferReviewScreen extends StatelessWidget {
  const TransferReviewScreen(
      {super.key,
      required this.kind,
      required this.target,
      required this.amount,
      this.network});
  final TxKind kind;
  final String target;
  final double amount;
  final String? network;
  @override
  Widget build(BuildContext context) {
    final ext = kind == TxKind.external;
    return _Scaffold(
        child: Column(children: [
      _TopBar(title: 'Withdraw', onBack: () => Navigator.pop(context)),
      const SizedBox(height: 20),
      const _CryptoBalance(),
      const SizedBox(height: 20),
      _Summary(children: [
        _Row(
            label: ext ? 'Address' : 'Username',
            value: ext ? _short(target) : target),
        if (ext) _Row(label: 'Network', value: network ?? 'Bitcoin'),
        const _Row(label: 'Asset', value: 'Bitcoin (BTC)'),
        _Row(
            label: 'Amount',
            value: '${formatGroupedAmount(amount.toStringAsFixed(4))} BTC'),
        _Row(
            label: 'Network Fee',
            value: ext ? '0.00002 BTC' : 'Free',
            valueColor: AppColors.primary),
        _Row(
            label: 'Total',
            value:
                '${formatGroupedAmount((amount + (ext ? .00002 : 0)).toStringAsFixed(5))} BTC',
            last: true)
      ]),
      const Spacer(),
      _Button(label: 'Confirm Withdrawal', onTap: () => _pin(context)),
    ]));
  }

  Future<void> _pin(BuildContext context) async {
    final ok = await Navigator.push<bool>(
        context, AppPageRoute<bool>(builder: (_) => const CryptoPinScreen()));
    if (!context.mounted || ok != true) return;
    Navigator.pushReplacement(
        context,
        AppPageRoute<void>(
            builder: (_) => TransactionProgressScreen(
                kind: kind, target: target, amount: amount, fee: kind == TxKind.external ? .00002 : 0)));
  }
}

class CryptoPinScreen extends StatelessWidget {
  const CryptoPinScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      TransactionPinEntryScreen(onConfirm: () => Navigator.pop(context, true));
}

class TransactionProgressScreen extends StatefulWidget {
  const TransactionProgressScreen({
    super.key,
    required this.kind,
    required this.target,
    required this.amount,
    this.asset = BuyCryptoAsset.bitcoin,
    this.network,
    this.fee,
    this.operation,
  });
  final TxKind kind;
  final String target;
  final double amount;
  final BuyCryptoAsset asset;
  final Future<PreviewTransactionOutcome>? operation;
  final String? network;
  final double? fee;
  @override
  State<TransactionProgressScreen> createState() =>
      _TransactionProgressScreenState();
}

class _TransactionProgressScreenState extends State<TransactionProgressScreen> {
  bool failed = false;
  @override
  void initState() {
    super.initState();
    _process();
  }

  Future<void> _process() async {
    try {
      final accepted =
          await (widget.operation ??
              PreviewTransactionOperation.transfer(
                external: widget.kind == TxKind.external,
              ));
      if (!mounted || ModalRoute.of(context)?.isCurrent == false) return;
      if (accepted == PreviewTransactionOutcome.failed) {
        setState(() => failed = true);
        return;
      }
      Navigator.pushReplacement(
        context,
        AppPageRoute<void>(
          builder: (_) => TransactionSuccessScreen(
            kind: widget.kind,
            outcomeKind: accepted == PreviewTransactionOutcome.submitted
                ? DavoOutcomeKind.submitted
                : DavoOutcomeKind.completed,
            target: widget.target,
            amount: widget.amount,
            asset: widget.asset,
            network: widget.network,
            fee: widget.fee,
          ),
        ),
      );
    } catch (_) {
      if (mounted && ModalRoute.of(context)?.isCurrent != false) {
        setState(() => failed = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final transfer =
        widget.kind == TxKind.internal || widget.kind == TxKind.external;
    final title = transfer
        ? 'Sending ${formatGroupedAmount(widget.amount.toStringAsFixed(4))} ${widget.asset.symbol}'
        : widget.kind == TxKind.sell
        ? 'Selling ${formatGroupedAmount(widget.amount.toStringAsFixed(5))} BTC'
        : 'Converting';
    final sub = switch (widget.kind) {
      TxKind.internal => 'to ${widget.target}',
      TxKind.external => 'to ${_short(widget.target)}',
      _ => '',
    };
    final subColor = widget.kind == TxKind.external
        ? DavoColors.of(context).bodyMuted
        : DavoColors.of(context).body;
    return _FigmaFullScaffold(
      child: Column(
        children: [
          _TopBar(
            title: transfer ? 'Crypto Withdraw Mode' : '',
            onBack: () => Navigator.pop(context),
            height: 32,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          const SizedBox(height: 47),
          failed
              ? Icon(
                  Icons.error_outline_rounded,
                  size: 56,
                  color: DavoColors.of(context).danger,
                )
              : const DavoWorkingIndicator(),
          const SizedBox(height: 16),
          SizedBox(
            height: 22,
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                height: 1.35,
                color: DavoColors.of(context).ink,
              ),
            ),
          ),
          if (sub.isNotEmpty) ...[
            const SizedBox(height: 4),
            SizedBox(
              height: 19,
              child: Text(
                sub,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 14,
                  height: 1.35,
                  color: subColor,
                ),
              ),
            ),
          ],
          SizedBox(height: sub.isNotEmpty ? 8 : 8),
          Text(
            failed
                ? 'Could not complete this transaction. Go back to try again.'
                : widget.kind == TxKind.conversion || widget.kind == TxKind.sell
                ? failed
                      ? 'Could not complete this transaction. Go back to try again.'
                      : 'Please wait while we process your transaction'
                : 'Please wait while we process your transaction',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 14,
              height: 1.35,
              color: DavoColors.of(context).body,
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionSuccessScreen extends StatefulWidget {
  const TransactionSuccessScreen({
    super.key,
    required this.kind,
    required this.target,
    required this.amount,
    this.asset = BuyCryptoAsset.bitcoin,
    this.record,
    this.network,
    this.fee,
    this.outcomeKind = DavoOutcomeKind.completed,
  });
  final TxKind kind;
  final String target;
  final double amount;
  final BuyCryptoAsset asset;
  final DavoOutcomeKind outcomeKind;
  final ReceiptRecord? record;
  final String? network;
  final double? fee;
  @override
  State<TransactionSuccessScreen> createState() =>
      _TransactionSuccessScreenState();
}

class _TransactionSuccessScreenState extends State<TransactionSuccessScreen> {
  TxKind get kind => widget.kind;
  String get target => widget.target;
  double get amount => widget.amount;
  BuyCryptoAsset get asset => widget.asset;
  DavoOutcomeKind get outcomeKind => record.status == ReceiptStatus.pending
      ? DavoOutcomeKind.submitted
      : DavoOutcomeKind.completed;
  late final ReceiptRecord _fallback = buildCryptoReceiptRecord(
    kind: kind,
    target: target,
    amount: amount,
    asset: asset,
    network: widget.network,
    fee: widget.fee,
    status: widget.outcomeKind == DavoOutcomeKind.submitted
        ? ReceiptStatus.pending
        : ReceiptStatus.completed,
  );
  ReceiptRecord get record => widget.record ?? _fallback;
  @override
  void initState() {
    super.initState();
    ReceiptActivity.accept(record);
  }

  @override
  Widget build(BuildContext context) {
    final transfer = kind == TxKind.internal || kind == TxKind.external;
    return DavoResultScreen(
      kind: outcomeKind,
      mark: record.status == ReceiptStatus.failed
          ? const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFB42318),
              size: 100,
            )
          : null,
      title: record.status == ReceiptStatus.failed
          ? '${record.type} failed'
          : outcomeKind == DavoOutcomeKind.submitted
          ? 'Withdrawal submitted'
          : transfer
          ? 'Transfer successful'
          : kind == TxKind.sell
          ? 'Sale successful'
          : 'Conversion successful',
      message:
          '${record.type} ${record.status.label.toLowerCase()}: ${record.amount}.${record.preview ? ' Preview only. No funds have been moved.' : ''}',
      details: record.status == ReceiptStatus.failed || widget.record != null
          ? null
          : outcomeKind == DavoOutcomeKind.submitted
          ? Text(
              'Your withdrawal has been submitted. It will update after network confirmation.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 14,
                height: 1.35,
                color: DavoColors.of(context).body,
              ),
            )
          : _TransactionSuccessMessage(
              kind: kind,
              target: target,
              amount: amount,
              asset: asset,
            ),
      appBar: AppBar(
        backgroundColor: DavoColors.of(context).surface,
        title: transfer
            ? const Text(
                'Crypto withdrawal',
                style: TextStyle(fontFamily: 'Sora', fontSize: 16),
              )
            : null,
      ),
      actions: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Button(
            label: 'View Details',
            onTap: () => Navigator.push(
              context,
              AppPageRoute<void>(
                builder: (_) => TransactionDetailsScreen(
                  pending: outcomeKind == DavoOutcomeKind.submitted,
                  kind: kind,
                  target: target,
                  amount: amount,
                  asset: asset,
                  record: record,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _Secondary(
            label: transfer
                ? 'Send another transfer'
                : kind == TxKind.sell
                ? 'Sell more crypto'
                : 'Convert more crypto',
            onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
          ),
        ],
      ),
    );
  }
}

class _TransactionSuccessMessage extends StatelessWidget {
  const _TransactionSuccessMessage({
    required this.kind,
    required this.target,
    required this.amount,
    this.asset = BuyCryptoAsset.bitcoin,
  });
  final TxKind kind;
  final String target;
  final double amount;
  final BuyCryptoAsset asset;

  @override
  Widget build(BuildContext context) {
    final muted = DavoColors.of(context).bodyMuted;
    final ink = DavoColors.of(context).ink;
    final base = TextStyle(
      fontFamily: 'Sora',
      fontSize: 14,
      height: 1.35,
      color: muted,
    );
    final dark = TextStyle(
      fontFamily: 'Sora',
      fontSize: 14,
      height: 1.35,
      color: ink,
    );
    final strong = TextStyle(
      fontFamily: 'Sora',
      fontSize: 14,
      height: 1.35,
      fontWeight: FontWeight.w600,
      color: ink,
    );
    final amountText = '${formatCryptoQuantity(amount)} ${asset.symbol}';
    final spans = switch (kind) {
      TxKind.internal => <InlineSpan>[
        TextSpan(text: 'You have sent', style: base),
        TextSpan(text: ' $amountText ', style: dark),
        TextSpan(text: 'to', style: base),
        TextSpan(text: ' $target', style: dark),
      ],
      TxKind.external => <InlineSpan>[
        TextSpan(text: 'You have sent ', style: base),
        TextSpan(text: amountText, style: strong),
        TextSpan(text: ' to ', style: base),
        TextSpan(text: _short(target), style: strong),
      ],
      TxKind.conversion => <InlineSpan>[
        TextSpan(text: 'You have successfully converted  ', style: base),
        TextSpan(text: amountText, style: strong),
        TextSpan(text: ' to ', style: base),
        TextSpan(
          text:
              '${formatCryptoQuantity(amount * asset.ngnPerUnit / (BuyCryptoAsset.values.where((a) => a.symbol == target || a.name == target).firstOrNull ?? BuyCryptoAsset.tether).ngnPerUnit)} $target',
          style: strong,
        ),
      ],
      TxKind.sell => <InlineSpan>[
        TextSpan(text: 'You have successfully sold ', style: base),
        TextSpan(text: '$amountText ', style: strong),
        TextSpan(text: 'for ', style: base),
        TextSpan(
          text:
              '₦${formatGroupedAmount((amount * asset.ngnPerUnit).toStringAsFixed(2))}',
          style: strong,
        ),
      ],
    };
    return Text.rich(TextSpan(children: spans), textAlign: TextAlign.center);
  }
}

class TransactionDetailsScreen extends StatefulWidget {
  const TransactionDetailsScreen({
    super.key,
    required this.kind,
    required this.target,
    required this.amount,
    this.receipt = false,
    this.pending = false,
    this.asset = BuyCryptoAsset.bitcoin,
    this.record,
  });
  final TxKind kind;
  final String target;
  final double amount;
  final bool receipt, pending;
  final BuyCryptoAsset asset;
  final ReceiptRecord? record;
  @override
  State<TransactionDetailsScreen> createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  late final ReceiptRecord _fallback = buildCryptoReceiptRecord(
    kind: widget.kind,
    target: widget.target,
    amount: widget.amount,
    asset: widget.asset,
    status: widget.pending ? ReceiptStatus.pending : ReceiptStatus.completed,
  );
  ReceiptRecord get record => widget.record ?? _fallback;
  @override
  Widget build(BuildContext context) => widget.receipt
      ? ReceiptScreen(record: record)
      : TransactionRecordDetailsScreen(
          record: record,
          onDone: () => Navigator.of(context).popUntil((r) => r.isFirst),
          receiptBuilder: (_) => TransactionDetailsScreen(
            kind: widget.kind,
            target: widget.target,
            amount: widget.amount,
            asset: widget.asset,
            pending: widget.pending,
            record: record,
            receipt: true,
          ),
        );
}

class ScanPasteAddressScreen extends StatefulWidget {
  const ScanPasteAddressScreen({super.key});
  @override
  State<ScanPasteAddressScreen> createState() => _ScanPasteAddressScreenState();
}

class _ScanPasteAddressScreenState extends State<ScanPasteAddressScreen> {
  int mode = 0;
  final TextEditingController _addressController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _pasteAddress() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final value = data?.text?.trim() ?? '';
    if (!mounted || value.isEmpty) return;
    _addressController.text = value;
    _addressController.selection =
        TextSelection.collapsed(offset: value.length);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DavoColors.of(context).canvas,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              left: 8,
              top: 16,
              width: 24,
              height: 24,
              child: InkResponse(
                onTap: () => Navigator.pop(context),
                radius: 20,
                child: Image.asset('$_f/buy_back.png',
                    color: DavoColors.of(context).ink, width: 24, height: 24),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 8,
              height: 40,
              child: IgnorePointer(
                child: Center(
                  child: Text('Scan or Paste Address',
                      style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                          color: DavoColors.of(context).ink)),
                ),
              ),
            ),
            Positioned(
                left: 16,
                top: 67,
                width: 170,
                height: 48,
                child: _ExactScanTab(
                    label: 'Scan QR Code',
                    active: mode == 0,
                    onTap: () => setState(() => mode = 0))),
            Positioned(
                left: 202,
                top: 67,
                width: 172,
                height: 48,
                child: _ExactScanTab(
                    label: 'Paste Address',
                    active: mode == 1,
                    onTap: () => setState(() => mode = 1))),
            if (mode == 0)
              Positioned(
                left: 16,
                top: 141,
                width: 359,
                height: 485,
                child: Container(
                  decoration: BoxDecoration(
                      // Camera artwork uses white overlays in both appearances.
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8)),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned(
                          left: 35,
                          top: 12,
                          width: 290,
                          height: 290,
                          child: Image.asset('$_cf/scanner_frame.png',
                              width: 290, height: 290, fit: BoxFit.contain)),
                      Positioned(
                        left: 159,
                        top: 310,
                        width: 42,
                        height: 42,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                              color: Colors.black, shape: BoxShape.circle),
                          child: Image.asset('$_cf/flashlight.png',
                              width: 24, height: 24, fit: BoxFit.contain),
                        ),
                      ),
                      const Positioned(
                        left: 54.5,
                        top: 363,
                        width: 251,
                        height: 19,
                        child: Text('Align the QR code within the frame',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                                color: Colors.white)),
                      ),
                      Positioned(
                        left: 54.5,
                        top: 384,
                        width: 251,
                        height: 15,
                        child: InkWell(
                          onTap: () => setState(() => mode = 1),
                          child: const Text('Enter Address manually',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  height: 1.25,
                                  color: Color(0xFF89ADF9))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (mode == 1) ...[
              Positioned(
                left: 16,
                top: 141,
                width: 358,
                height: 48,
                child: TextField(
                  controller: _addressController,
                  onChanged: (_) => setState(() {}),
                  textInputAction: TextInputAction.done,
                  style: TextStyle(
                      fontFamily: 'Open Sans',
                      fontSize: 16,
                      height: 1.375,
                      color: DavoColors.of(context).ink),
                  decoration: InputDecoration(
                    hintText: 'Paste the wallet address',
                    hintStyle: TextStyle(
                        fontFamily: 'Open Sans',
                        fontSize: 16,
                        height: 1.375,
                        color: DavoColors.of(context).bodyMuted),
                    filled: true,
                    fillColor: DavoColors.of(context).fieldFill,
                    contentPadding: const EdgeInsets.fromLTRB(16, 13, 72, 13),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1)),
                    suffixIcon: SizedBox(
                      width: 64,
                      child: TextButton(
                        onPressed: _pasteAddress,
                        style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            foregroundColor: DavoColors.of(context).link),
                        child: const Text('Paste',
                            style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                height: 1.25)),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                top: 209,
                width: 358,
                child: _Button(
                  label: 'Use Address',
                  enabled: _addressController.text.trim().isNotEmpty,
                  onTap: () =>
                      Navigator.pop(context, _addressController.text.trim()),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ExactScanTab extends StatelessWidget {
  const _ExactScanTab(
      {required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
        color: active ? AppColors.primary : DavoColors.of(context).primarySoft,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Center(
              child: Text(label,
                  style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                      color: active
                          ? Colors.white
                          : DavoColors.of(context).link))),
        ),
      );
}

class SelectNetworkSheet extends StatelessWidget {
  const SelectNetworkSheet({super.key});
  @override
  Widget build(BuildContext context) => DavoSafeSelectionSheet(child: Container(
        height: 407,
        decoration: BoxDecoration(
            color: DavoColors.of(context).surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16))),
        child: Stack(
          children: [
            Positioned(
                left: 0,
                right: 0,
                top: 41,
                child: Text('Select Network',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 16,
                        height: 1.35,
                        color: DavoColors.of(context).ink))),
            Positioned(
              left: 23,
              right: 17,
              top: 73,
              child: Container(
                height: 72,
                padding: const EdgeInsets.fromLTRB(16, 14, 15, 12),
                decoration: BoxDecoration(
                    color: DavoColors.of(context).primarySoft,
                    borderRadius: BorderRadius.circular(8)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset('$_cf/network_warning.png',
                        width: 14, height: 14),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(
                            'Please make sure that your withdrawal address and chain match each other, otherwise you may lose your assets!',
                            style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 12,
                                height: 1.25,
                                color: DavoColors.of(context).ink))),
                  ],
                ),
              ),
            ),
            Positioned(
                left: 23,
                right: 16,
                top: 163,
                child: _ExactNetworkRow(
                    asset: '$_f/btc.png',
                    title: 'Bitcoin (BTC)',
                    eta: '10m 14s',
                    fee: '0.00002 BTC',
                    usd: r'(\$1.57)',
                    onTap: () => Navigator.pop(context, 'Bitcoin (BTC)'))),
            Positioned(
                left: 23,
                right: 16,
                top: 250,
                child: _ExactNetworkRow(
                    asset: '$_exact/crypto_bnb_exact.png',
                    title: 'BNB Smart Chain (BEP20)',
                    eta: '2m 2s',
                    fee: '0.00000025 BTC',
                    usd: r'(\$0.019)',
                    onTap: () =>
                        Navigator.pop(context, 'BNB Smart Chain (BEP20)'))),
          ],
        ),
      ));
}

class _ExactNetworkRow extends StatelessWidget {
  const _ExactNetworkRow(
      {required this.asset,
      required this.title,
      required this.eta,
      required this.fee,
      required this.usd,
      required this.onTap});
  final String asset, title, eta, fee, usd;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(children: [
          Image.asset(asset, width: 37, height: 37, fit: BoxFit.contain),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text('Expected arrival: $eta',
                    style: TextStyle(
                        fontSize: 11, color: DavoColors.of(context).bodyMuted)),
                const SizedBox(height: 4),
                Text('Fee: $fee $usd',
                    style: TextStyle(
                        fontSize: 11, color: DavoColors.of(context).bodyMuted)),
              ])),
        ]),
      ));
}

class SanctionWarningSheet extends StatelessWidget {
  const SanctionWarningSheet({super.key});
  @override
  Widget build(BuildContext context) => DavoSafeSelectionSheet(child: Container(
        height: 627,
        decoration: BoxDecoration(
            color: DavoColors.of(context).surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16))),
        child: Stack(
          children: [
            Positioned(
                left: 149,
                top: 15,
                child: Container(
                    width: 92,
                    height: 5,
                    decoration: BoxDecoration(
                        color: DavoColors.of(context).bodyMuted,
                        borderRadius: BorderRadius.circular(100)))),
            Positioned(
                right: 16,
                top: 27,
                width: 32,
                height: 32,
                child: InkResponse(
                    onTap: () => Navigator.pop(context, false),
                    radius: 20,
                    child: Image.asset('$_exact/crypto_close_exact.png',
                        color: DavoColors.of(context).ink,
                        width: 32,
                        height: 32))),
            Positioned(
                left: 17,
                top: 78,
                width: 288,
                height: 30,
                child: Text('Prohibited Transactions with Sanctioned Entities',
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                        color: DavoColors.of(context).ink))),
            Positioned(
                left: 17,
                right: 12,
                top: 124,
                height: 42,
                child: Text(
                    'To protect your account and funds, please avoid sending or receiving funds from cryptocurrency exchanges or payment platforms that are sanctioned by regulatory authorities.',
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                        color: DavoColors.of(context).warning))),
            Positioned(
                left: 17,
                right: 12,
                top: 190,
                height: 14,
                child: Text(
                    'High-Risk Platforms (This includes, but is not limited to:)',
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        color: DavoColors.of(context).ink))),
            Positioned(
                left: 17,
                top: 208,
                width: 100,
                height: 96,
                child: Text(
                    'Garantex\nGrinex\nNobitex\nBit24\nExcoino\nRamzinex',
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 10,
                        height: 1.6,
                        color: DavoColors.of(context).body))),
            Positioned(
                left: 17,
                right: 12,
                top: 328,
                height: 14,
                child: Text('Important Guidelines',
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        color: DavoColors.of(context).ink))),
            Positioned(
                left: 17,
                right: 12,
                top: 346,
                height: 126,
                child: Text(
                    'Transactions involving these high-risk platforms may lead to restrictions on your Davochain account.\nAlways verify the legitimacy of the recipient or platform before completing any transaction.\nDo not engage in transfers with unverified or sanctioned services to keep your funds safe.\nIf you’re unsure about a transaction, please contact Davochain support for assistance.',
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 10,
                        height: 1.4,
                        color: DavoColors.of(context).body))),
            Positioned(
                left: 17,
                right: 12,
                top: 530,
                child: _Button(
                    label: 'I Understand',
                    onTap: () => Navigator.pop(context, true))),
          ],
        ),
      ));
}

class CancelReminderSheet extends StatelessWidget {
  const CancelReminderSheet({super.key});
  @override
  Widget build(BuildContext context) => DavoSafeSelectionSheet(child: Container(
        height: 229,
        decoration: BoxDecoration(
            color: DavoColors.of(context).surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(16))),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(38, 24, 38, 16),
          child: Column(
            children: [
              SizedBox(
                  height: 22,
                  child: Center(
                      child: Text('Reminder',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              height: 1.35,
                              color: DavoColors.of(context).ink)))),
              const SizedBox(height: 12),
              SizedBox(
                  height: 19,
                  child: Center(
                      child: Text('Do you want to cancel this payment',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'Sora',
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              height: 1.35,
                              color: DavoColors.of(context).body)))),
              const SizedBox(height: 24),
              _Button(
                  label: 'Continue to Pay',
                  fontWeight: FontWeight.w700,
                  onTap: () => Navigator.pop(context, false)),
              const SizedBox(height: 16),
              _Secondary(
                  label: 'Cancel',
                  fontWeight: FontWeight.w700,
                  background: DavoColors.of(context).primarySoft,
                  onTap: () => Navigator.pop(context, true)),
            ],
          ),
        ),
      ));
}

class TradeAmountScreen extends StatefulWidget {
  const TradeAmountScreen({super.key, required this.mode, required this.asset});
  final TradeMode mode;
  final BuyCryptoAsset asset;
  @override
  State<TradeAmountScreen> createState() => _TradeAmountScreenState();
}

class _TradeAmountScreenState extends State<TradeAmountScreen> {
  final amount = TextEditingController();
  late BuyCryptoAsset sourceAsset;
  late BuyCryptoAsset destinationAsset;

  @override
  void initState() {
    super.initState();
    sourceAsset = widget.asset;
    destinationAsset = sourceAsset == BuyCryptoAsset.tether
        ? BuyCryptoAsset.bitcoin
        : BuyCryptoAsset.tether;
  }

  Future<void> _selectAsset({required bool source}) async {
    FocusScope.of(context).unfocus();
    final picked = await showModalBottomSheet<BuyCryptoAsset>(
        context: context,
        sheetAnimationStyle: (MediaQuery.disableAnimationsOf(context) ||
                MediaQuery.accessibleNavigationOf(context))
            ? AnimationStyle.noAnimation
            : const AnimationStyle(
                duration: Duration(milliseconds: 280),
                reverseDuration: Duration(milliseconds: 200)),
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const BuyCryptoAssetSheet());
    if (!mounted || picked == null) return;
    setState(() {
      if (source) {
        if (picked == destinationAsset) destinationAsset = sourceAsset;
        sourceAsset = picked;
      } else {
        if (picked == sourceAsset) sourceAsset = destinationAsset;
        destinationAsset = picked;
      }
    });
  }

  void _swapAssets() {
    FocusScope.of(context).unfocus();
    final received =
        enteredAmount * sourceAsset.ngnPerUnit / destinationAsset.ngnPerUnit;
    setState(() {
      final previous = sourceAsset;
      sourceAsset = destinationAsset;
      destinationAsset = previous;
      if (amount.text.isNotEmpty) {
        amount.text = formatGroupedAmount(received
            .toStringAsFixed(8)
            .replaceFirst(RegExp(r'0+$'), '')
            .replaceFirst(RegExp(r'\.$'), ''));
        amount.selection = TextSelection.collapsed(offset: amount.text.length);
      }
    });
  }

  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  bool get convert => widget.mode == TradeMode.convert;
  double get balance => sourceAsset == BuyCryptoAsset.bitcoin ? .33048 : 5;
  double get enteredAmount => parseAmount(amount.text);

  void _switchMode(TradeMode mode) {
    FocusScope.of(context).unfocus();
    Navigator.pushReplacement(
        context,
        AppPageRoute<void>(
            builder: (_) => TradeAmountScreen(mode: mode, asset: sourceAsset)));
  }

  void _pickPercent(String label) {
    final fraction =
        label == 'Max' ? 1.0 : double.parse(label.replaceAll('%', '')) / 100;
    HapticFeedback.selectionClick();
    amount.text = (balance * fraction)
        .toStringAsFixed(8)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
    amount.text = formatGroupedAmount(amount.text);
    amount.selection = TextSelection.collapsed(offset: amount.text.length);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final n = enteredAmount;
    final active = n > 0 && n <= balance;
    final ngn = n * sourceAsset.ngnPerUnit;
    return TradeFormLayout(
      header: _ExactCryptoTradeHeader(
          title: convert ? 'Swap' : 'Sell',
          onBack: () => Navigator.pop(context)),
      tabs: _Tabs(
          active: convert ? 2 : 1,
          onBuy: () {
            FocusScope.of(context).unfocus();
            Navigator.pushReplacement(
                context,
                AppPageRoute<void>(
                    builder: (_) => BuyAmountScreen(
                        initialOrder: BuyCryptoOrder(
                            asset: sourceAsset,
                            wallet: BuyFundingWallet.ngd,
                            ngnAmount: 0))));
          },
          onSell: () {
            if (convert) _switchMode(TradeMode.sell);
          },
          onConvert: () {
            if (!convert) _switchMode(TradeMode.convert);
          }),
      content: Column(children: [
        if (convert) ...[
          InkWell(
              onTap: () => _selectAsset(source: true),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                            child: Text(
                                '${formatGroupedAmount(n.toStringAsFixed(2))} ${sourceAsset.symbol}',
                                style: const TextStyle(
                                    fontSize: 26, fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center)),
                        const SizedBox(width: 4),
                        const Icon(Icons.keyboard_arrow_down_rounded,
                            color: AppColors.primary),
                      ]))),
          Text(
              '\u2248 ${formatGroupedAmount((ngn / 1463.08).toStringAsFixed(2))} USD',
              style: TextStyle(
                  fontSize: 13, color: DavoColors.of(context).bodyMuted)),
          const SizedBox(height: 24),
          _ExactSwapBox(
              from: true,
              onSelect: () => _selectAsset(source: true),
              asset: sourceAsset,
              balance: balance,
              value: n,
              controller: amount,
              onChanged: () => setState(() {})),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: IconButton(
                  onPressed: _swapAssets,
                  tooltip: 'Swap assets',
                  style: IconButton.styleFrom(
                      backgroundColor: DavoColors.of(context).primarySoft,
                      foregroundColor: DavoColors.of(context).link),
                  icon: const Icon(Icons.swap_vert_rounded, size: 28))),
          _ExactSwapBox(
              from: false,
              onSelect: () => _selectAsset(source: false),
              asset: destinationAsset,
              balance: destinationAsset == BuyCryptoAsset.bitcoin
                  ? .33048
                  : 25040.27,
              value: ngn / destinationAsset.ngnPerUnit),
          const SizedBox(height: 16),
          Align(
              alignment: Alignment.centerLeft,
              child: Text('Estimated fee: Free',
                  style: TextStyle(
                      fontSize: 12, color: DavoColors.of(context).bodyMuted))),
        ] else ...[
          _AssetBalance(asset: sourceAsset),
          const SizedBox(height: 24),
          _Amount(
              controller: amount,
              suffix: sourceAsset.symbol,
              onChanged: () => setState(() {})),
          const SizedBox(height: 20),
          Text('\u2248 \u20a6${formatGroupedAmount(ngn.toStringAsFixed(2))}',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: DavoColors.of(context).ink)),
        ],
        const SizedBox(height: 12),
        Text(
            convert
                ? '1 ${sourceAsset.symbol} \u2248 \u20a6${formatGroupedAmount(sourceAsset.ngnPerUnit.toStringAsFixed(2))}'
                : '1 USDT \u2248 (\u20a6${formatGroupedAmount(BuyCryptoAsset.tether.ngnPerUnit.toStringAsFixed(2))})',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 12, color: DavoColors.of(context).bodyMuted)),
        const SizedBox(height: 24),
        Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: ['10%', '25%', '50%', '75%', 'Max']
                .map((v) => _Percent(label: v, onTap: () => _pickPercent(v)))
                .toList()),
        if (n > balance)
          Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text('Amount exceeds your available balance.',
                  style: TextStyle(color: DavoColors.of(context).danger))),
      ]),
      action: _Button(
          label: convert ? 'Preview' : 'Continue',
          enabled: active,
          onTap: () {
            FocusScope.of(context).unfocus();
            Navigator.push(
                context,
                AppPageRoute<void>(
                    builder: (_) => TradeReviewScreen(
                        kind: convert ? TxKind.conversion : TxKind.sell,
                        amount: n,
                        sourceAsset: sourceAsset,
                        destinationAsset: destinationAsset)));
          }),
    );
  }
}

class TradeReviewScreen extends StatelessWidget {
  const TradeReviewScreen(
      {super.key,
      required this.kind,
      required this.amount,
      this.sourceAsset = BuyCryptoAsset.bitcoin,
      this.destinationAsset = BuyCryptoAsset.tether});
  final TxKind kind;
  final double amount;
  final BuyCryptoAsset sourceAsset, destinationAsset;

  Widget _reviewAsset(BuildContext context, String label, BuyCryptoAsset asset,
          String value, String secondary) =>
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: DavoColors.of(context).surface,
            borderRadius: BorderRadius.circular(8)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: TextStyle(
                  fontSize: 12, color: DavoColors.of(context).bodyMuted)),
          const SizedBox(height: 12),
          Row(children: [
            BuyAssetIcon(asset: asset, size: 32),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(value,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(secondary,
                      style: TextStyle(
                          fontSize: 12,
                          color: DavoColors.of(context).bodyMuted)),
                ])),
            Text(asset.symbol,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ]),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final conv = kind == TxKind.conversion;
    final ngn = amount * sourceAsset.ngnPerUnit;
    final received = ngn / destinationAsset.ngnPerUnit;
    final receivedText = formatGroupedAmount(received.toStringAsFixed(2));
    final usdText = formatGroupedAmount((ngn / 1463.08).toStringAsFixed(2));
    final rate =
        '1 ${destinationAsset.symbol} \u2248 ${formatGroupedAmount((destinationAsset.ngnPerUnit / sourceAsset.ngnPerUnit).toStringAsFixed(8))} ${sourceAsset.symbol}';
    return Scaffold(
      backgroundColor: DavoColors.of(context).canvas,
      bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: _Button(
                  label: conv ? 'Confirm conversion' : 'Confirm',
                  onTap: () => Navigator.pushReplacement(
                      context,
                      AppPageRoute<void>(
                          builder: (_) => TransactionProgressScreen(
                              kind: kind,
                              target: conv ? destinationAsset.symbol : 'NGN',
                              amount: amount,
                              asset: sourceAsset)))))),
      body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(children: [
                SizedBox(
                    height: 40,
                    child: _ExactCryptoTradeHeader(
                        title: conv ? 'Review Conversion' : 'Sell',
                        onBack: () => Navigator.pop(context))),
                const SizedBox(height: 24),
                _reviewAsset(
                    context,
                    conv ? 'You are converting' : 'You are Selling',
                    sourceAsset,
                    formatGroupedAmount(amount.toStringAsFixed(5)),
                    '\$$usdText'),
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                            color: DavoColors.of(context).primarySoft,
                            shape: BoxShape.circle),
                        child: Icon(
                            conv
                                ? Icons.swap_vert_rounded
                                : Icons.arrow_downward_rounded,
                            size: 22,
                            color: AppColors.primary))),
                if (conv)
                  _reviewAsset(context, 'To (You will receive)',
                      destinationAsset, receivedText, '\$$usdText')
                else
                  Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: DavoColors.of(context).surface,
                          borderRadius: BorderRadius.circular(8)),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('To (You will receive)',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: DavoColors.of(context).bodyMuted)),
                            const SizedBox(height: 12),
                            Row(children: [
                              Image.asset('$_f/buy_nigeria.png',
                                  width: 32, height: 32),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(
                                        '\u20a6${formatGroupedAmount(ngn.toStringAsFixed(2))}',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 4),
                                    Text('Nigerian Naira',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: DavoColors.of(context)
                                                .bodyMuted)),
                                  ])),
                            ]),
                          ])),
                const SizedBox(height: 24),
                _ExactTradeSummary(conversion: conv, rows: [
                  (
                    'Exchange Rate',
                    conv
                        ? rate
                        : '1 USDT \u2248 \u20a6${formatGroupedAmount(BuyCryptoAsset.tether.ngnPerUnit.toStringAsFixed(2))}',
                    false
                  ),
                  ('Network Fee', 'Free', true),
                  (
                    conv ? 'Total Amount' : 'Total Received',
                    conv
                        ? '$receivedText ${destinationAsset.symbol}\n\$$usdText'
                        : '\u20a6${formatGroupedAmount(ngn.toStringAsFixed(2))}',
                    false
                  ),
                ]),
              ]))),
    );
  }
}

class _ExactCryptoTradeHeader extends StatelessWidget {
  const _ExactCryptoTradeHeader({required this.title, required this.onBack});
  final String title;
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Positioned(
              left: 6,
              top: 4,
              width: 32,
              height: 32,
              child: InkResponse(
                  onTap: onBack,
                  child: Image.asset('$_f/buy_back.png',
                      color: DavoColors.of(context).ink,
                      width: 32,
                      height: 32))),
          Positioned.fill(
              child: Center(
                  child: Text(title,
                      style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                          height: 1.35,
                          color: DavoColors.of(context).ink)))),
        ],
      );
}

class _ExactSwapBox extends StatelessWidget {
  const _ExactSwapBox(
      {required this.from,
      required this.asset,
      required this.balance,
      required this.value,
      this.controller,
      this.onChanged,
      this.onSelect});
  final bool from;
  final BuyCryptoAsset asset;
  final double balance, value;
  final TextEditingController? controller;
  final VoidCallback? onChanged;
  final VoidCallback? onSelect;
  @override
  Widget build(BuildContext context) => Focus(
      child: Builder(
          builder: (context) => Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: DavoColors.of(context).surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Focus.of(context).hasFocus
                            ? AppColors.primary
                            : DavoColors.of(context).border)),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(from ? 'From' : 'To',
                          style: TextStyle(
                              fontSize: 12,
                              color: DavoColors.of(context).bodyMuted)),
                      const SizedBox(height: 8),
                      Row(children: [
                        InkWell(
                            onTap: onSelect,
                            borderRadius: BorderRadius.circular(6),
                            child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      BuyAssetIcon(asset: asset, size: 24),
                                      const SizedBox(width: 8),
                                      Text(asset.symbol,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.w600)),
                                      const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: AppColors.primary,
                                          size: 18),
                                    ]))),
                        const SizedBox(width: 12),
                        Expanded(
                            child: from
                                ? TextField(
                                    controller: controller,
                                    onChanged: (_) => onChanged?.call(),
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    inputFormatters: const [
                                      GroupedAmountInputFormatter()
                                    ],
                                    textAlign: TextAlign.right,
                                    decoration: const DavoInlineInputDecoration(
                                        hintText: '0.00'),
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600),
                                  )
                                : Text(
                                    formatGroupedAmount(
                                        value.toStringAsFixed(2)),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600))),
                      ]),
                      const SizedBox(height: 8),
                      Text(
                          'Available: ${formatGroupedAmount(balance.toString())} ${asset.symbol}',
                          style: TextStyle(
                              fontSize: 12,
                              color: DavoColors.of(context).bodyMuted)),
                    ]),
              )));
}

class _ExactTradeSummary extends StatelessWidget {
  const _ExactTradeSummary({required this.rows, required this.conversion});
  final List<(String, String, bool)> rows;
  final bool conversion;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
            color: DavoColors.of(context).surface,
            borderRadius: BorderRadius.circular(8)),
        child: Column(children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              Divider(
                  height: 1,
                  thickness: .5,
                  color: DavoColors.of(context).divider),
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: LayoutBuilder(
                    builder: (context, constraints) => Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                  width: constraints.maxWidth * .30,
                                  child: Text(rows[i].$1,
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: DavoColors.of(context)
                                              .bodyMuted))),
                              const SizedBox(width: 12),
                              Expanded(
                                  child: Text(rows[i].$2,
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                          fontSize: 12,
                                          height: 1.5,
                                          color: rows[i].$3
                                              ? DavoColors.of(context).link
                                              : DavoColors.of(context).ink,
                                          fontWeight: FontWeight.w500))),
                            ]))),
          ]
        ]),
      );
}

class DepositStatusScreen extends StatelessWidget {
  const DepositStatusScreen({super.key,required this.success,this.record});
  final bool success;
  final ReceiptRecord? record;
  @override Widget build(BuildContext context) => TransactionRecordDetailsScreen(record: record ?? ReceiptRecord(
    id:'DC-20260502-9H37K2',reference:'DC-20260502-9H37K2',type:'Deposit',
    status:success?ReceiptStatus.completed:ReceiptStatus.pending,occurredAt:DateTime(2026,5,2,22,36,58),amount:'0.0317934 BTC',preview:true,
    fields:const [ReceiptField(label:'Network',value:'Bitcoin'),ReceiptField(label:'Deposit Address',value:'1ChGMXGfgy2tdoE4rVQEqouRpBQaAA6zLZ',sensitive:true,copyable:true),ReceiptField(label:'Transaction Hash',value:'7c0d217aca078b46197d9283d7b818311de96eae39deddfea593303815d04c35',copyable:true)],
    events:[ReceiptEvent(label:success?'Deposit confirmed':'Awaiting network confirmation',description:success?'Crypto received.':'Confirmation is pending.',occurredAt:success?DateTime(2026,5,2,22,36,58):null,state:success?ReceiptEventState.complete:ReceiptEventState.current)]));
}

class _Scaffold extends StatelessWidget {
  const _Scaffold({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: DavoColors.of(context).canvas,
        body: SafeArea(
            child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: child)),
      );
}

class _FigmaFullScaffold extends StatelessWidget {
  const _FigmaFullScaffold({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: DavoColors.of(context).canvas,
        body: SafeArea(
            bottom: false,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: child)),
      );
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.onBack,
    this.height = 40,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w500,
  });
  final String title;
  final VoidCallback onBack;
  final double height, fontSize;
  final FontWeight fontWeight;
  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                    tooltip: 'Back',
                    onPressed: onBack,
                    icon: Image.asset('$_f/buy_back.png',
                        color: DavoColors.of(context).ink,
                        width: 24,
                        height: 24))),
            if (title.isNotEmpty)
              Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Text(title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: fontSize,
                          fontWeight: fontWeight,
                          height: 1.35,
                          color: DavoColors.of(context).ink))),
          ],
        ),
      );
}

class _AssetButton extends StatelessWidget {
  const _AssetButton(
      {required this.asset, required this.size, required this.onTap});
  final String asset;
  final double size;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkResponse(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        radius: 24,
        child: SizedBox(
            width: 36,
            height: 36,
            child:
                Center(child: Image.asset(asset, width: size, height: size))),
      );
}

class _Button extends StatelessWidget {
  const _Button(
      {required this.label,
      this.enabled = true,
      required this.onTap,
      this.fontWeight = FontWeight.w600,
      this.disabledColor,
      this.disabledTextColor = Colors.white});
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final FontWeight fontWeight;
  final Color? disabledColor;
  final Color disabledTextColor;
  @override
  Widget build(BuildContext context) => Material(
        color: enabled
            ? AppColors.primary
            : (disabledColor ?? DavoColors.of(context).primaryDisabled),
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: enabled
              ? () {
                  HapticFeedback.lightImpact();
                  onTap();
                }
              : null,
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(
              height: 48,
              width: double.infinity,
              child: Center(
                  child: Text(label,
                      style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 14,
                          fontWeight: fontWeight,
                          color: enabled ? Colors.white : disabledTextColor)))),
        ),
      );
}

class _Secondary extends StatelessWidget {
  const _Secondary(
      {required this.label,
      required this.onTap,
      this.fontWeight = FontWeight.w600,
      this.background});
  final String label;
  final VoidCallback onTap;
  final FontWeight fontWeight;
  final Color? background;
  @override
  Widget build(BuildContext context) => Material(
        color: background ?? DavoColors.of(context).primarySoft,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
                height: 48,
                width: double.infinity,
                child: Center(
                    child: Text(label,
                        style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 14,
                            fontWeight: fontWeight,
                            color: DavoColors.of(context).link))))),
      );
}

class _Row extends StatelessWidget {
  const _Row(
      {required this.label,
      required this.value,
      this.valueColor,
      this.last = false});
  final String label, value;
  final Color? valueColor;
  final bool last;
  @override
  Widget build(BuildContext context) => Container(
      constraints: const BoxConstraints(minHeight: 47),
      decoration: last
          ? null
          : BoxDecoration(
              border: Border(
                  bottom: BorderSide(
                      color: DavoColors.of(context).divider, width: .6))),
      child:
          ReceiptDetailRow(label: label, value: value, valueColor: valueColor));
}

class _Summary extends StatelessWidget {
  const _Summary({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
          color: DavoColors.of(context).surface,
          borderRadius: BorderRadius.circular(8)),
      child: Column(children: children));
}

class _Choice extends StatelessWidget {
  const _Choice(
      {required this.asset,
      required this.title,
      required this.subtitle,
      required this.onTap});
  final String asset, title, subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            height: 75,
            decoration: BoxDecoration(
                color: DavoColors.of(context).surface,
                border: Border.all(color: DavoColors.of(context).border),
                borderRadius: BorderRadius.circular(4)),
            child: Stack(
              children: [
                Positioned(
                  left: 12,
                  top: 17.5,
                  width: 40,
                  height: 40,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: DavoColors.of(context).fieldFill,
                        borderRadius: BorderRadius.circular(4)),
                    child: Image.asset(asset,
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                        color: AppColors.primary),
                  ),
                ),
                Positioned(
                    left: 60,
                    top: 12,
                    child: Text(title,
                        style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                            color: DavoColors.of(context).ink))),
                Positioned(
                    left: 60,
                    right: 54,
                    top: 33,
                    height: 30,
                    child: Text(subtitle,
                        style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 12,
                            height: 1.25,
                            color: DavoColors.of(context).bodyMuted))),
                Positioned(
                    right: 12,
                    top: 29.5,
                    width: 16,
                    height: 16,
                    child: Image.asset('$_cf/chevron_right.png',
                        color: DavoColors.of(context).ink,
                        width: 16,
                        height: 16)),
              ],
            ),
          ),
        ),
      );
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader();
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 40,
        child: Stack(
          children: [
            Positioned(
                left: 0,
                top: 0,
                width: 40,
                height: 40,
                child: ClipOval(
                    child: Image.asset('$_f/profile_avatar.png',
                        width: 40, height: 40, fit: BoxFit.cover))),
            Positioned(
                left: 52,
                top: 2,
                width: 61,
                height: 15,
                child: Text('Welcome,',
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 12,
                        height: 1.25,
                        color: DavoColors.of(context).muted))),
            Positioned(
                left: 52,
                top: 19,
                width: 61,
                height: 19,
                child: Text('Callie',
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                        color: DavoColors.of(context).body))),
            Positioned(
              left: 225,
              top: 4,
              width: 89,
              height: 32,
              child: Container(
                decoration: BoxDecoration(
                    color: DavoColors.of(context)
                        .primaryDisabled
                        .withValues(alpha: .5),
                    borderRadius: BorderRadius.circular(1000)),
                child: Stack(
                  children: [
                    Positioned(
                        left: 8,
                        top: 4,
                        width: 24,
                        height: 24,
                        child: Image.asset('$_exact/naira_earn_gift_exact.png',
                            width: 24, height: 24, fit: BoxFit.contain)),
                    Positioned(
                        left: 36,
                        top: 8.5,
                        width: 45,
                        height: 15,
                        child: Text('Earn \$5',
                            style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 12,
                                height: 1.25,
                                color: DavoColors.of(context).link))),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 326,
              top: 4,
              width: 32,
              height: 32,
              child: Container(
                decoration: BoxDecoration(
                    color: DavoColors.of(context)
                        .primaryDisabled
                        .withValues(alpha: .5),
                    borderRadius: BorderRadius.circular(1000)),
                alignment: Alignment.center,
                child: Image.asset('$_exact/icon_notifications.png',
                    width: 24, height: 24, fit: BoxFit.contain),
              ),
            ),
          ],
        ),
      );
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();
  @override
  Widget build(BuildContext context) => Container(
        height: 136,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
            color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            Positioned(
                right: 0,
                bottom: 12,
                width: 268,
                height: 94,
                child: Image.asset('$_f/balance_wave.png', fit: BoxFit.fill)),
            const Positioned(
                left: 16,
                top: 31,
                width: 140,
                height: 16,
                child: Text('Available Balance',
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                        color: Colors.white))),
            Positioned(
                left: 155,
                top: 32.5,
                width: 10,
                height: 10,
                child: Image.asset('$_exact/crypto_eye_exact.png',
                    width: 10, height: 10, fit: BoxFit.contain)),
            const Positioned(
                left: 16,
                top: 52,
                width: 300,
                height: 36,
                child: Text('₦1,284,500.35',
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                        color: Colors.white))),
            const Positioned(
                left: 16,
                top: 86,
                width: 200,
                height: 22,
                child: Text('≈ \$842.31 USD',
                    style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 14,
                        height: 1.35,
                        color: Colors.white))),
          ],
        ),
      );
}

class _CryptoBalance extends StatelessWidget {
  const _CryptoBalance({this.asset = BuyCryptoAsset.bitcoin, this.onChange});
  final BuyCryptoAsset asset;
  final VoidCallback? onChange;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: DavoColors.of(context).surface,
            borderRadius: BorderRadius.circular(8)),
        child: Column(children: [
          Row(children: [
            Expanded(
                child: Text('Wallet Balance',
                    style: TextStyle(
                        fontSize: 10,
                        color: DavoColors.of(context).bodyMuted))),
            InkWell(
                onTap: onChange,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text('Change Asset',
                      style: TextStyle(
                          fontSize: 10, color: DavoColors.of(context).link)),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded,
                      size: 16, color: AppColors.primary),
                ])),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            BuyAssetIcon(asset: asset, size: 28),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text(asset.name, style: const TextStyle(fontSize: 14)),
                  Text(asset.symbol,
                      style: TextStyle(
                          fontSize: 12,
                          color: DavoColors.of(context).bodyMuted)),
                ])),
            const SizedBox(width: 8),
            Flexible(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                  Text('0.0300 ${asset.symbol}',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  Text(r'$842.31 USD',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                          fontSize: 12,
                          color: DavoColors.of(context).bodyMuted)),
                ])),
          ]),
        ]),
      );
}

class _Tabs extends StatelessWidget {
  const _Tabs(
      {required this.active,
      required this.onBuy,
      required this.onSell,
      required this.onConvert});
  final int active;
  final VoidCallback onBuy, onSell, onConvert;
  @override
  Widget build(BuildContext context) {
    final callbacks = [onBuy, onSell, onConvert];
    const labels = ['Buy', 'Sell', 'Swap'];
    return Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
            color: DavoColors.of(context).fieldFill,
            borderRadius: BorderRadius.circular(999)),
        child: Row(
            children: List.generate(
                3,
                (i) => Expanded(
                    child: Semantics(
                        selected: active == i,
                        child: Material(
                            color: active == i
                                ? DavoColors.of(context).surface
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(999),
                            child: InkWell(
                                onTap: callbacks[i],
                                borderRadius: BorderRadius.circular(999),
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    child: Center(
                                        child: Text(labels[i],
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: active == i
                                                    ? DavoColors.of(context)
                                                        .link
                                                    : DavoColors.of(context)
                                                        .body)))))))))));
  }
}

class _AssetBalance extends StatelessWidget {
  const _AssetBalance({required this.asset});
  final BuyCryptoAsset asset;
  @override
  Widget build(BuildContext context) {
    final balance = asset == BuyCryptoAsset.bitcoin ? .33048 : 5.0;
    final balanceText = formatGroupedAmount(balance.toString());
    final usd = formatGroupedAmount(
        (balance * asset.ngnPerUnit / 1463.08).toStringAsFixed(2));
    return Column(children: [
      BuyAssetIcon(asset: asset, size: 40),
      const SizedBox(height: 12),
      Text('Available Balance',
          style: TextStyle(fontSize: 12, color: DavoColors.of(context).body)),
      const SizedBox(height: 6),
      Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 4,
          children: [
            Text('$balanceText ${asset.symbol}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            Text('\u2248 (\$$usd)',
                style: TextStyle(
                    fontSize: 12, color: DavoColors.of(context).bodyMuted)),
          ]),
    ]);
  }
}

class _Amount extends StatelessWidget {
  const _Amount(
      {required this.controller,
      required this.suffix,
      required this.onChanged});
  final TextEditingController controller;
  final String suffix;
  final VoidCallback onChanged;
  @override
  Widget build(BuildContext context) => Focus(
      child: Builder(
          builder: (context) => Container(
                height: 77,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                    color: DavoColors.of(context).surface,
                    border: Border.all(
                        color: Focus.of(context).hasFocus
                            ? AppColors.primary
                            : DavoColors.of(context).border),
                    borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  const SizedBox(width: 48),
                  Expanded(
                      child: TextField(
                          controller: controller,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: const [
                            GroupedAmountInputFormatter()
                          ],
                          onChanged: (_) => onChanged(),
                          decoration: DavoInlineInputDecoration(
                              hintText: '0.00',
                              hintStyle: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: DavoColors.of(context).bodyMuted)),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: DavoColors.of(context).ink))),
                  SizedBox(
                      width: 48,
                      child: Text(suffix,
                          textAlign: TextAlign.right,
                          style: TextStyle(
                              fontSize: 14,
                              color: DavoColors.of(context).body))),
                ]),
              )));
}

class _Percent extends StatelessWidget {
  const _Percent({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
          width: 48,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              border: Border.all(color: DavoColors.of(context).border),
              borderRadius: BorderRadius.circular(8)),
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: label == 'Max'
                      ? DavoColors.of(context).link
                      : DavoColors.of(context).body))));
}

String _short(String v) => v.length <= 16
    ? v
    : '${v.substring(0, 6)}......${v.substring(v.length - 6)}';
