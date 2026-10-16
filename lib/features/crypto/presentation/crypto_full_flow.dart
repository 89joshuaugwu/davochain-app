import '../../wallets/presentation/wallet_picker_sheet.dart';
import '../../wallets/wallet_valuation.dart';
import '../../../shared/widgets/davo_naira_amount.dart';
import '../../../shared/receipts/transaction_commands.dart';
import '../../../core/providers/reactive_builder.dart';
import '../../profile_settings/presentation/settings_content_overlay.dart';
import '../../../core/navigation/transaction_navigation.dart';
import '../../../shared/widgets/trade_amount_card.dart';
import '../../../shared/widgets/davo_blue_balance_card.dart';
import '../crypto_trade_amounts.dart';
import '../../../core/money/exact_decimal.dart';
import '../../wallets/wallet_repository.dart';
import '../../../core/money/money.dart';
import '../../../shared/widgets/davo_safe_selection_sheet.dart';
import 'wallet_address_scanner.dart';
import 'wallet_address_payload.dart';
export 'wallet_address_scanner.dart' show ScanPasteAddressScreen;
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
import '../../../shared/widgets/davo_bank_logo.dart';
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

part 'crypto_trade_screens.dart';
part 'crypto_naira_screens.dart';
part 'crypto_transaction_screens.dart';

const _f = 'assets/figma_exact';
const _cf = 'assets/figma_exact';
const _exact = 'assets/figma_exact';

enum TradeMode { sell, convert }

Future<void> startWithdrawFlow(BuildContext context) async {
  final selected = await showModalBottomSheet<String>(
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
    builder: (_) => const WalletPickerSheet(),
  );
  if (!context.mounted || selected == null) return;
  await Navigator.of(context).push<void>(
    AppPageRoute<void>(
      builder: (_) => selected == 'NGN'
          ? const NairaWithdrawScreen()
          : CryptoWithdrawModeScreen(
              asset: BuyCryptoAsset.values.firstWhere(
                (asset) => asset.symbol == selected,
              ),
            ),
    ),
  );
}

Future<void> startSellCryptoFlow(BuildContext context) async {
  final asset = await showModalBottomSheet<BuyCryptoAsset>(
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
    builder: (_) => const BuyCryptoAssetSheet(fundedOnly: true),
  );
  if (!context.mounted || asset == null) return;
  await Navigator.of(context).push<void>(
    AppPageRoute<void>(
      builder: (_) => TradeAmountScreen(mode: TradeMode.sell, asset: asset),
    ),
  );
}

Future<void> startConvertCryptoFlow(BuildContext context) async {
  await Navigator.of(context).push<void>(
    AppPageRoute<void>(
      builder: (_) => const TradeAmountScreen(
        mode: TradeMode.convert,
        asset: BuyCryptoAsset.bitcoin,
      ),
    ),
  );
}

Future<void> openDepositStatus(
  BuildContext context, {
  required bool success,
}) async {
  await Navigator.of(context).push<void>(
    AppPageRoute<void>(builder: (_) => DepositStatusScreen(success: success)),
  );
}

class CryptoWithdrawModeScreen extends StatelessWidget {
  const CryptoWithdrawModeScreen({
    super.key,
    this.asset = BuyCryptoAsset.bitcoin,
  });
  final BuyCryptoAsset asset;

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
              builder: (_) => CryptoWithdrawEntryScreen(
                external: false,
                initialAsset: asset,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _Choice(
          asset: '$_cf/qr_wallet.png',
          title: 'Wallet Address',
          subtitle: networkWalletSymbols.contains(asset.symbol)
              ? 'Send crypto to an external wallet,\nnetwork fee applies'
              : 'External withdrawals are not available yet',
          onTap: () => networkWalletSymbols.contains(asset.symbol)
              ? Navigator.push(
                  context,
                  AppPageRoute<void>(
                    builder: (_) => CryptoWithdrawEntryScreen(
                      external: true,
                      initialAsset: asset,
                    ),
                  ),
                )
              : showDialog<void>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('Withdraw ${asset.symbol}'),
                    content: const Text(
                      'External withdrawals are not available for this asset yet. You can send to a Davochain user.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Got it'),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    ),
  );
}

class CryptoWithdrawEntryScreen extends StatefulWidget {
  const CryptoWithdrawEntryScreen({
    super.key,
    required this.external,
    this.initialAsset = BuyCryptoAsset.bitcoin,
  });
  final BuyCryptoAsset initialAsset;
  final bool external;
  @override
  State<CryptoWithdrawEntryScreen> createState() =>
      _CryptoWithdrawEntryScreenState();
}

class _CryptoWithdrawEntryScreenState extends State<CryptoWithdrawEntryScreen> {
  final target = TextEditingController();
  final amount = TextEditingController();
  final amountFocus = FocusNode();
  late final int _formGeneration;
  @override
  void initState() {
    super.initState();
    _formGeneration = WalletAccountState.instance.generation;
    WalletAccountState.instance.addListener(_walletChanged);
  }

  void _walletChanged() {
    if (mounted) setState(() {});
  }

  String? network;
  late BuyCryptoAsset asset = widget.initialAsset;

  @override
  void dispose() {
    WalletAccountState.instance.removeListener(_walletChanged);
    amountFocus.dispose();
    target.dispose();
    amount.dispose();
    super.dispose();
  }

  bool get _ready =>
      _formGeneration == WalletAccountState.instance.generation &&
      (!widget.external || networkWalletSymbols.contains(asset.symbol)) &&
      target.text.trim().isNotEmpty &&
      _hasAvailableFunds &&
      (!widget.external || (network != null && _addressMatchesNetwork));

  bool get _hasAvailableFunds {
    try {
      if (!WalletAccountState.instance.snapshot.assets.contains(asset.symbol)) {
        return false;
      }
      final available = WalletAccountState.instance.snapshot.available(
        asset.symbol,
      );
      return CryptoTradeAmounts.canSpend(
        available,
        _parseExactAmount(amount.text),
        fee: widget.external
            ? ExactDecimal.parse('0.00002')
            : ExactDecimal.zero,
      );
    } on FormatException {
      return false;
    }
  }

  bool get _addressMatchesNetwork {
    try {
      walletAddressFromPayload(target.text, asset: asset, network: network);
      return true;
    } on FormatException {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (_, __) => _cancel(),
    child: widget.external ? _buildExternal(context) : _buildInternal(context),
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
                        Text(
                          'Receiving',
                          style: TextStyle(
                            fontSize: 12,
                            color: DavoColors.of(context).bodyMuted,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${formatGroupedAmount(formatCryptoQuantity(_parseExactAmount(amount.text)))} ${asset.symbol}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Network fee: ${network == null ? '—' : '0.00002 ${asset.symbol}'}',
                          style: TextStyle(
                            fontSize: 10,
                            color: DavoColors.of(context).bodyMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _Button(
                      label: 'Confirm',
                      disabledColor: DavoColors.of(context).mutedSoft,
                      disabledTextColor: DavoColors.of(context).bodyMuted,
                      enabled: _ready,
                      onTap: _confirm,
                    ),
                  ),
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
              title: widget.external ? 'Withdraw' : 'Send crypto',
              onBack: _cancel,
              height: 48,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 16),
            _CryptoBalance(asset: asset, onChange: _changeAsset),
            if (!widget.external) ...[
              const SizedBox(height: 24),
              const Text(
                'Send to a Davochain user',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Text(
                'Enter their username, then choose how much to send. Review the recipient before confirming.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: DavoColors.of(context).bodyMuted,
                ),
              ),
            ],
            const SizedBox(height: 24),
            _entryField(
              widget.external ? 'Address' : 'Recipient username',
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: target,
                      autocorrect: false,
                      enableSuggestions: false,
                      textInputAction: TextInputAction.next,
                      onSubmitted: (_) => amountFocus.requestFocus(),
                      onChanged: (_) => setState(() {}),
                      decoration: DavoInlineInputDecoration(
                        hintText: widget.external
                            ? 'Paste the wallet address'
                            : 'Enter Davochain username',
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  if (widget.external)
                    IconButton(
                      onPressed: _scan,
                      tooltip: 'Scan wallet address',
                      icon: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                ],
              ),
            ),
            if (widget.external) ...[
              const SizedBox(height: 24),
              _entryField(
                'Network',
                InkWell(
                  onTap: _network,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            network ?? 'Select withdrawal network',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            _entryField(
              widget.external ? 'Amount' : 'Enter Amount',
              Row(
                children: [
                  BuyAssetIcon(asset: asset, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: amount,
                      focusNode: amountFocus,
                      textInputAction: TextInputAction.done,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: const [GroupedAmountInputFormatter()],
                      onChanged: (_) => setState(() {}),
                      decoration: const DavoInlineInputDecoration(
                        hintText: 'Enter amount',
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(
                      () => amount.text = formatGroupedAmount(
                        WalletAccountState.instance.snapshot
                            .available(asset.symbol)
                            .decimal,
                      ),
                    ),
                    child: Text(widget.external ? 'All' : 'Max'),
                  ),
                  Text(asset.symbol, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Available',
                    style: TextStyle(
                      fontSize: 14,
                      color: DavoColors.of(context).bodyMuted,
                    ),
                  ),
                ),
                Text(
                  '${WalletAccountState.instance.snapshot.assets.contains(asset.symbol) ? WalletAccountState.instance.snapshot.available(asset.symbol).decimal : 'Unavailable'} ${asset.symbol}',
                  style: TextStyle(
                    fontSize: 14,
                    color: DavoColors.of(context).bodyMuted,
                  ),
                ),
              ],
            ),
            if (widget.external) ...[
              const SizedBox(height: 24),
              const Text(
                'Withdrawal Notice',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
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
                  color: DavoColors.of(context).bodyMuted,
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              Text(
                r'Daily transfer limit - $500',
                style: TextStyle(
                  fontSize: 12,
                  color: DavoColors.of(context).bodyMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );

  Widget _entryField(String label, Widget child) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      Focus(
        child: Builder(
          builder: (context) => Container(
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: DavoColors.of(context).surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Focus.of(context).hasFocus
                    ? AppColors.primary
                    : DavoColors.of(context).border,
              ),
            ),
            child: child,
          ),
        ),
      ),
    ],
  );

  Future<void> _changeAsset() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          WalletPickerSheet(includeCash: false, networkOnly: widget.external, unavailableLabel: 'External withdrawals unavailable'),
    );
    if (!mounted || selected == null || selected == asset.symbol) return;
    setState(() {
      asset = BuyCryptoAsset.values.firstWhere((a) => a.symbol == selected);
      network = null;
    });
  }

  Future<void> _cancel() async {
    final c = await showModalBottomSheet<bool>(
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
      builder: (_) => const CancelReminderSheet(),
    );
    if (mounted && c == true) Navigator.pop(context);
  }

  Future<void> _scan() async {
    final a = await Navigator.push<String>(
      context,
      AppPageRoute<String>(
        builder: (_) => ScanPasteAddressScreen(asset: asset, network: network),
      ),
    );
    if (mounted && a != null) setState(() => target.text = a);
  }

  Future<void> _network() async {
    final n = await showModalBottomSheet<String>(
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
      builder: (_) => asset == BuyCryptoAsset.bitcoin
          ? const SelectNetworkSheet()
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.all(20),
                color: DavoColors.of(context).surface,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Select Network'),
                    ...((asset == BuyCryptoAsset.solana)
                            ? ['Solana']
                            : (asset == BuyCryptoAsset.ethereum)
                            ? ['Ethereum (ERC20)']
                            : ['Ethereum (ERC20)', 'Tron (TRC20)'])
                        .map(
                          (name) => ListTile(
                            title: Text(name),
                            onTap: () => Navigator.pop(context, name),
                          ),
                        ),
                  ],
                ),
              ),
            ),
    );
    if (!mounted || n == null) return;
    final understood = await showModalBottomSheet<bool>(
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
      builder: (_) => const SanctionWarningSheet(),
    );
    if (mounted && understood == true) setState(() => network = n);
  }

  Future<void> _confirm() async {
    if (!_ready) return;
    final generation = WalletAccountState.instance.generation;
    if (widget.external) {
      target.text = walletAddressFromPayload(
        target.text,
        asset: asset,
        network: network,
      );
    }
    final n = _parseExactAmount(amount.text);
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
      builder: (_) => widget.external
          ? _ExternalWithdrawConfirmSheet(
              target: target.text,
              amount: n,
              asset: asset,
            )
          : _InternalWithdrawConfirmSheet(
              target: target.text,
              amount: n,
              asset: asset,
            ),
    );
    if (!mounted || ok != true) return;
    final pin = await Navigator.push<bool>(
      context,
      AppPageRoute<bool>(builder: (_) => const CryptoPinScreen()),
    );
    if (!mounted ||
        pin != true ||
        !_ready ||
        generation != WalletAccountState.instance.generation) {
      return;
    }
    Navigator.pushReplacement(
      context,
      AppPageRoute<void>(
        builder: (_) => TransactionProgressScreen(
          kind: widget.external ? TxKind.external : TxKind.internal,
          target: target.text,
          amount: n,
          asset: asset,
          network: network,
          fee: widget.external ? '0.00002' : '0',
        ),
      ),
    );
  }
}

class _ExternalWithdrawConfirmSheet extends StatelessWidget {
  const _ExternalWithdrawConfirmSheet({
    required this.target,
    required this.amount,
    this.asset = BuyCryptoAsset.bitcoin,
  });
  final String target;
  final Object amount;
  final BuyCryptoAsset asset;
  @override
  Widget build(BuildContext context) => _WithdrawReviewSheet(
    target: target,
    amount: amount,
    asset: asset,
    external: true,
  );
}

class _InternalWithdrawConfirmSheet extends StatelessWidget {
  const _InternalWithdrawConfirmSheet({
    required this.target,
    required this.amount,
    this.asset = BuyCryptoAsset.bitcoin,
  });
  final String target;
  final Object amount;
  final BuyCryptoAsset asset;
  @override
  Widget build(BuildContext context) => _WithdrawReviewSheet(
    target: target,
    amount: amount,
    asset: asset,
    external: false,
  );
}

class _WithdrawReviewSheet extends StatelessWidget {
  const _WithdrawReviewSheet({
    required this.target,
    required this.amount,
    required this.asset,
    required this.external,
  });
  final String target;
  final Object amount;
  final BuyCryptoAsset asset;
  final bool external;
  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      decoration: BoxDecoration(
        color: DavoColors.of(context).surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Review withdrawal',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context, false),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: DavoColors.of(context).canvas,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  ReceiptDetailRow(
                    label: external ? 'Withdraw to' : 'Username',
                    value: target,
                  ),
                  const SizedBox(height: 20),
                  ReceiptDetailRow(
                    label: 'Asset',
                    value: '${asset.name} (${asset.symbol})',
                    leading: BuyAssetIcon(asset: asset, size: 24),
                  ),
                  const SizedBox(height: 20),
                  ReceiptDetailRow(
                    label: 'Amount',
                    value:
                        '${formatGroupedAmount(formatCryptoQuantity(amount))} ${asset.symbol}',
                  ),
                  const SizedBox(height: 20),
                  ReceiptDetailRow(
                    label: 'Network fee',
                    value: external ? '0.00002 ${asset.symbol}' : 'Free',
                    valueColor: AppColors.primary,
                  ),
                  const SizedBox(height: 20),
                  ReceiptDetailRow(
                    label: 'Total',
                    value:
                        '${formatGroupedAmount(formatCryptoQuantity(ExactDecimal.from(amount) + ExactDecimal.parse(external ? '0.00002' : '0')))} ${asset.symbol}',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _Button(
              label: 'Confirm',
              onTap: () => Navigator.pop(context, true),
            ),
          ],
        ),
      ),
    ),
  );
}

class CryptoPinScreen extends StatelessWidget {
  const CryptoPinScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      TransactionPinEntryScreen(onConfirm: () => Navigator.pop(context, true));
}

class SelectNetworkSheet extends StatelessWidget {
  const SelectNetworkSheet({super.key});
  @override
  Widget build(BuildContext context) => DavoSafeSelectionSheet(
    child: Container(
      height: 407,
      decoration: BoxDecoration(
        color: DavoColors.of(context).surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 41,
            child: Text(
              'Select Network',
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
            left: 23,
            right: 17,
            top: 73,
            child: Container(
              height: 72,
              padding: const EdgeInsets.fromLTRB(16, 14, 15, 12),
              decoration: BoxDecoration(
                color: DavoColors.of(context).primarySoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    '$_cf/network_warning.png',
                    width: 14,
                    height: 14,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Please make sure that your withdrawal address and chain match each other, otherwise you may lose your assets!',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 12,
                        height: 1.25,
                        color: DavoColors.of(context).ink,
                      ),
                    ),
                  ),
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
              onTap: () => Navigator.pop(context, 'Bitcoin (BTC)'),
            ),
          ),
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
              onTap: () => Navigator.pop(context, 'BNB Smart Chain (BEP20)'),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ExactNetworkRow extends StatelessWidget {
  const _ExactNetworkRow({
    required this.asset,
    required this.title,
    required this.eta,
    required this.fee,
    required this.usd,
    required this.onTap,
  });
  final String asset, title, eta, fee, usd;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Image.asset(asset, width: 37, height: 37, fit: BoxFit.contain),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Expected arrival: $eta',
                  style: TextStyle(
                    fontSize: 11,
                    color: DavoColors.of(context).bodyMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fee: $fee $usd',
                  style: TextStyle(
                    fontSize: 11,
                    color: DavoColors.of(context).bodyMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class SanctionWarningSheet extends StatelessWidget {
  const SanctionWarningSheet({super.key});
  @override
  Widget build(BuildContext context) => DavoSafeSelectionSheet(
    child: Container(
      height: 627,
      decoration: BoxDecoration(
        color: DavoColors.of(context).surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
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
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 27,
            width: 32,
            height: 32,
            child: InkResponse(
              onTap: () => Navigator.pop(context, false),
              radius: 20,
              child: Image.asset(
                '$_exact/crypto_close_exact.png',
                color: DavoColors.of(context).ink,
                width: 32,
                height: 32,
              ),
            ),
          ),
          Positioned(
            left: 17,
            top: 78,
            width: 288,
            height: 30,
            child: Text(
              'Prohibited Transactions with Sanctioned Entities',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.25,
                color: DavoColors.of(context).ink,
              ),
            ),
          ),
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
                color: DavoColors.of(context).warning,
              ),
            ),
          ),
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
                color: DavoColors.of(context).ink,
              ),
            ),
          ),
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
                color: DavoColors.of(context).body,
              ),
            ),
          ),
          Positioned(
            left: 17,
            right: 12,
            top: 328,
            height: 14,
            child: Text(
              'Important Guidelines',
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                height: 1.4,
                color: DavoColors.of(context).ink,
              ),
            ),
          ),
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
                color: DavoColors.of(context).body,
              ),
            ),
          ),
          Positioned(
            left: 17,
            right: 12,
            top: 530,
            child: _Button(
              label: 'I Understand',
              onTap: () => Navigator.pop(context, true),
            ),
          ),
        ],
      ),
    ),
  );
}

class CancelReminderSheet extends StatelessWidget {
  const CancelReminderSheet({super.key});
  @override
  Widget build(BuildContext context) => DavoSafeSelectionSheet(
    child: Container(
      height: 229,
      decoration: BoxDecoration(
        color: DavoColors.of(context).surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(38, 24, 38, 16),
        child: Column(
          children: [
            SizedBox(
              height: 22,
              child: Center(
                child: Text(
                  'Reminder',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.35,
                    color: DavoColors.of(context).ink,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 19,
              child: Center(
                child: Text(
                  'Do you want to cancel this payment',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    height: 1.35,
                    color: DavoColors.of(context).body,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _Button(
              label: 'Continue to Pay',
              fontWeight: FontWeight.w700,
              onTap: () => Navigator.pop(context, false),
            ),
            const SizedBox(height: 16),
            _Secondary(
              label: 'Cancel',
              fontWeight: FontWeight.w700,
              background: DavoColors.of(context).primarySoft,
              onTap: () => Navigator.pop(context, true),
            ),
          ],
        ),
      ),
    ),
  );
}

class DepositStatusScreen extends StatelessWidget {
  const DepositStatusScreen({super.key, required this.success, this.record});
  final bool success;
  final ReceiptRecord? record;
  @override
  Widget build(BuildContext context) => TransactionRecordDetailsScreen(
    record:
        record ??
        ReceiptRecord(
          id: 'DC-20260502-9H37K2',
          reference: 'DC-20260502-9H37K2',
          type: 'Deposit',
          status: success ? ReceiptStatus.completed : ReceiptStatus.pending,
          occurredAt: DateTime(2026, 5, 2, 22, 36, 58),
          amount: '0.0317934 BTC',
          preview: true,
          fields: const [
            ReceiptField(label: 'Network', value: 'Bitcoin'),
            ReceiptField(
              label: 'Deposit Address',
              value: '1ChGMXGfgy2tdoE4rVQEqouRpBQaAA6zLZ',
              sensitive: true,
              copyable: true,
            ),
            ReceiptField(
              label: 'Transaction Hash',
              value:
                  '7c0d217aca078b46197d9283d7b818311de96eae39deddfea593303815d04c35',
              copyable: true,
            ),
          ],
          events: [
            ReceiptEvent(
              label: success
                  ? 'Deposit confirmed'
                  : 'Awaiting network confirmation',
              description: success
                  ? 'Crypto received.'
                  : 'Confirmation is pending.',
              occurredAt: success ? DateTime(2026, 5, 2, 22, 36, 58) : null,
              state: success
                  ? ReceiptEventState.complete
                  : ReceiptEventState.current,
            ),
          ],
        ),
  );
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
        child: child,
      ),
    ),
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
        child: child,
      ),
    ),
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
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: BoxConstraints(minHeight: height < 48 ? 48 : height),
    child: Row(
      children: [
        IconButton(
          tooltip: 'Back',
          onPressed: onBack,
          icon: Icon(
            Icons.arrow_back_rounded,
            color: DavoColors.of(context).ink,
          ),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: fontSize,
              fontWeight: fontWeight,
              height: 1.35,
              color: DavoColors.of(context).ink,
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    ),
  );
}

class _AssetButton extends StatelessWidget {
  const _AssetButton({
    required this.asset,
    required this.size,
    required this.onTap,
  });
  final String asset;
  final double size;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: asset.contains('back') ? 'Back' : 'Close',
    onPressed: onTap,
    icon: Icon(
      asset.contains('back') ? Icons.arrow_back_rounded : Icons.close_rounded,
      size: size,
      color: DavoColors.of(context).ink,
    ),
  );
}

class _Button extends StatelessWidget {
  const _Button({
    required this.label,
    this.enabled = true,
    required this.onTap,
    this.fontWeight = FontWeight.w600,
    this.disabledColor,
    this.disabledTextColor = Colors.white,
  });
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
              onTap();
            }
          : null,
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 48,
        width: double.infinity,
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 14,
              fontWeight: fontWeight,
              color: enabled ? Colors.white : disabledTextColor,
            ),
          ),
        ),
      ),
    ),
  );
}

class _Secondary extends StatelessWidget {
  const _Secondary({
    required this.label,
    required this.onTap,
    this.fontWeight = FontWeight.w600,
    this.background,
  });
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
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 14,
              fontWeight: fontWeight,
              color: DavoColors.of(context).link,
            ),
          ),
        ),
      ),
    ),
  );
}

class _Choice extends StatelessWidget {
  const _Choice({
    required this.asset,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
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
          borderRadius: BorderRadius.circular(4),
        ),
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
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Image.asset(
                  asset,
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                  color: AppColors.primary,
                ),
              ),
            ),
            Positioned(
              left: 60,
              top: 12,
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                  color: DavoColors.of(context).ink,
                ),
              ),
            ),
            Positioned(
              left: 60,
              right: 54,
              top: 33,
              height: 30,
              child: Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 12,
                  height: 1.25,
                  color: DavoColors.of(context).bodyMuted,
                ),
              ),
            ),
            Positioned(
              right: 12,
              top: 29.5,
              width: 16,
              height: 16,
              child: Image.asset(
                '$_cf/chevron_right.png',
                color: DavoColors.of(context).ink,
                width: 16,
                height: 16,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.visible, required this.onVisibilityToggle});
  final bool visible;
  final VoidCallback onVisibilityToggle;
  @override
  Widget build(BuildContext context) => DavoListenableBuilder(
    listenable: WalletAccountState.instance,
    builder: (context, _) => DavoBlueBalanceCard(
      label: 'Davochain Naira balance',
      artBottom: -21,
      labelAction: IconButton(
        tooltip: visible ? 'Hide balance' : 'Show balance',
        onPressed: onVisibilityToggle,
        iconSize: 16,
        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
        icon: Icon(
          visible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: Colors.white,
        ),
      ),
      amountWidget: DavoNairaAmount(
        minorUnits: WalletAccountState.instance.ngnAvailableMinorUnits,
        visible: visible,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      amount: visible
          ? WalletAccountState.instance.ngnBalanceLabel
          : '\u20a6\u2022\u2022\u2022\u2022\u2022\u2022',
      caption: visible
          ? '= ${WalletAccountState.instance.ngnBalanceLabel} naira value\n${WalletValuation.forAsset(WalletAccountState.instance.snapshot, 'NGN', quote: WalletAccountState.instance.activeQuote).usdLabel ?? 'USD estimate unavailable'}'
          : 'Balance hidden',
    ),
  );
}

class _CryptoBalance extends StatelessWidget {
  const _CryptoBalance({this.asset = BuyCryptoAsset.bitcoin, this.onChange});
  final BuyCryptoAsset asset;
  final VoidCallback? onChange;
  @override
  Widget build(BuildContext context) {
    final wallet = WalletAccountState.instance;
    final known =
        wallet.snapshot.assets.contains(asset.symbol) &&
        wallet.snapshot.priceMinorUnits(asset.symbol) != null;
    final valuation = known
        ? WalletValuation.forAsset(
            wallet.snapshot,
            asset.symbol,
            quote: wallet.activeQuote,
          )
        : null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DavoColors.of(context).surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final label = Text(
                'Wallet Balance',
                style: TextStyle(
                  fontSize: 12,
                  color: DavoColors.of(context).bodyMuted,
                ),
              );
              final change = TextButton(
                onPressed: onChange,
                style: TextButton.styleFrom(
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Change Asset'),
              );
              return constraints.maxWidth < 300 ||
                      MediaQuery.textScalerOf(context).scale(14) > 18
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        label,
                        Align(alignment: Alignment.centerRight, child: change),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: label),
                        change,
                      ],
                    );
            },
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final name = Row(
                children: [
                  BuyAssetIcon(asset: asset, size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asset.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${known ? wallet.snapshot.available(asset.symbol).decimal : 'Unavailable'} ${asset.symbol}',
                          style: TextStyle(
                            fontSize: 12,
                            color: DavoColors.of(context).bodyMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
              final values = Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (valuation != null)
                    DavoNairaAmount(
                      minorUnits: valuation.nairaMinorUnits,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    const Text('Value unavailable'),
                  if (valuation != null)
                    Text(
                      '= ${valuation.nairaLabel}\n${valuation.usdLabel ?? 'USD unavailable'}',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.5,
                        color: DavoColors.of(context).bodyMuted,
                      ),
                    ),
                ],
              );
              return constraints.maxWidth < 300 ||
                      MediaQuery.textScalerOf(context).scale(14) > 18
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        name,
                        const SizedBox(height: 16),
                        Align(alignment: Alignment.centerRight, child: values),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(child: name),
                        const SizedBox(width: 12),
                        Flexible(child: values),
                      ],
                    );
            },
          ),
        ],
      ),
    );
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({
    required this.active,
    required this.onBuy,
    required this.onSell,
    required this.onConvert,
  });
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
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: List.generate(
          3,
          (i) => Expanded(
            child: Semantics(
              selected: active == i,
              child: Material(
                color: active == i ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: callbacks[i],
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Text(
                        labels[i],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: active == i
                              ? Colors.white
                              : DavoColors.of(context).body,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String _short(String v) => v.length <= 16
    ? v
    : '${v.substring(0, 6)}......${v.substring(v.length - 6)}';

ExactDecimal _parseExactAmount(String text) {
  final raw = text.replaceAll(',', '').trim();
  if (raw.isEmpty || raw == '.') return ExactDecimal.zero;
  try {
    return ExactDecimal.parse(raw.endsWith('.') ? '${raw}0' : raw);
  } on FormatException {
    return ExactDecimal.zero;
  }
}
