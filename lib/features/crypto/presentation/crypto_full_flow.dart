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
enum TxKind { internal, external, sell, conversion }
enum _WithdrawWallet { naira, crypto }

Future<void> startWithdrawFlow(BuildContext context) async {
  HapticFeedback.selectionClick();
  final selected = await showModalBottomSheet<_WithdrawWallet>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: .40),
    builder: (_) => const _WithdrawWalletSheet(),
  );
  if (!context.mounted || selected == null) return;
  await Navigator.of(context).push<void>(AppPageRoute<void>(
    builder: (_) => selected == _WithdrawWallet.naira ? const NairaWithdrawScreen() : const CryptoWithdrawModeScreen(),
  ));
}

Future<void> startSellCryptoFlow(BuildContext context) async {
  HapticFeedback.selectionClick();
  final asset = await showModalBottomSheet<BuyCryptoAsset>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: .40),
    builder: (_) => const BuyCryptoAssetSheet(),
  );
  if (!context.mounted || asset == null) return;
  final wallet = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: .40),
    builder: (_) => const _SellWalletSheet(),
  );
  if (!context.mounted || wallet != true) return;
  await Navigator.of(context).push<void>(AppPageRoute<void>(builder: (_) => TradeAmountScreen(mode: TradeMode.sell, asset: asset)));
}

Future<void> startConvertCryptoFlow(BuildContext context) async {
  HapticFeedback.selectionClick();
  await Navigator.of(context).push<void>(AppPageRoute<void>(builder: (_) => const TradeAmountScreen(mode: TradeMode.convert, asset: BuyCryptoAsset.bitcoin)));
}

Future<void> openDepositStatus(BuildContext context, {required bool success}) async {
  await Navigator.of(context).push<void>(AppPageRoute<void>(builder: (_) => DepositStatusScreen(success: success)));
}

class _WithdrawWalletSheet extends StatelessWidget {
  const _WithdrawWalletSheet();

  @override
  Widget build(BuildContext context) => Container(
        height: 472,
        decoration: const BoxDecoration(color: Color(0xFFF8F9FB), borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        child: Stack(
          children: [
            Positioned(left: 0, right: 0, top: 6, child: Center(child: Container(width: 85, height: 4, decoration: BoxDecoration(color: const Color(0xFF686868), borderRadius: BorderRadius.circular(100))))),
            const Positioned(left: 0, right: 0, top: 32, child: Text('Select Wallet', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Sora', fontSize: 14, height: 1.35, color: AppColors.ink))),
            Positioned(right: 16, top: 20, width: 32, height: 32, child: InkResponse(onTap: () => Navigator.pop(context), radius: 20, child: Image.asset('$_exact/crypto_close_exact.png', width: 32, height: 32))),
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
                      Container(width: 34, height: 34, alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFFD8E9FE), shape: BoxShape.circle), child: Image.asset('$_exact/crypto_plus_circle_exact.png', width: 24, height: 24)),
                      const SizedBox(width: 18),
                      const Expanded(child: Text('Add crypto asset', style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600, height: 1.35, color: AppColors.ink))),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(left: 16, right: 16, top: 125, child: _WalletSelectRow(asset: '$_f/buy_nigeria.png', title: 'Nigeria Naira', symbol: 'NGN', iconSize: 40, onTap: () => Navigator.pop(context, _WithdrawWallet.naira))),
            Positioned(left: 16, right: 16, top: 188, child: _WalletSelectRow(asset: '$_f/btc.png', title: 'Bitcoin', symbol: 'BTC', onTap: () => Navigator.pop(context, _WithdrawWallet.crypto))),
            Positioned(left: 16, right: 16, top: 251, child: _WalletSelectRow(asset: '$_f/eth.png', title: 'Ethereum', symbol: 'ETH', onTap: () => Navigator.pop(context, _WithdrawWallet.crypto))),
            Positioned(left: 16, right: 16, top: 314, child: _WalletSelectRow(asset: '$_f/sol.png', title: 'Solana', symbol: 'SOL', onTap: () => Navigator.pop(context, _WithdrawWallet.crypto))),
            Positioned(left: 16, right: 16, top: 377, child: _WalletSelectRow(asset: '$_f/usdt.png', title: 'Tether', symbol: 'USDT', onTap: () => Navigator.pop(context, _WithdrawWallet.crypto))),
          ],
        ),
      );
}

class _WalletSelectRow extends StatelessWidget {
  const _WalletSelectRow({required this.asset, required this.title, required this.symbol, required this.onTap, this.iconSize = 32});
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
                child: Center(child: Image.asset(asset, width: iconSize, height: iconSize, fit: BoxFit.contain)),
              ),
              Positioned(left: 52, top: 9, child: Text(title, style: const TextStyle(fontFamily: 'Sora', fontSize: 14, height: 1.35, color: AppColors.ink))),
              Positioned(left: 52, top: 30, child: Text(symbol, style: const TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.25, color: Color(0xFF424242)))),
            ],
          ),
        ),
      );
}

class _SellWalletSheet extends StatelessWidget {
  const _SellWalletSheet();
  @override
  Widget build(BuildContext context) => Container(
        height: 242,
        decoration: const BoxDecoration(color: Color(0xFFF8F9FB), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Stack(
          children: [
            Positioned(left: 0, right: 0, top: 6, child: Center(child: Container(width: 85, height: 4, decoration: BoxDecoration(color: const Color(0xFF686868), borderRadius: BorderRadius.circular(100))))),
            const Positioned(left: 0, right: 0, top: 32, child: Text('Select wallet to sell into', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Sora', fontSize: 14, height: 1.35, color: AppColors.ink))),
            Positioned(left: 342, top: 20, width: 24, height: 24, child: InkResponse(onTap: () => Navigator.pop(context), child: Image.asset('$_f/buy_close.png', width: 24, height: 24))),
            Positioned(
              left: 16,
              right: 16,
              top: 67,
              height: 55,
              child: InkWell(
                onTap: () => Navigator.pop(context, true),
                child: Stack(
                  children: [
                    Positioned(left: 0, top: 9, width: 32, height: 32, child: Image.asset('$_f/buy_nigeria.png', width: 32, height: 32, fit: BoxFit.contain)),
                    const Positioned(left: 44, top: 7, child: Text('Nigerian Naira', style: TextStyle(fontFamily: 'Sora', fontSize: 14, height: 1.35, color: AppColors.ink))),
                    const Positioned(left: 44, top: 28, child: Text('NGN', style: TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.25, color: AppColors.body))),
                    const Positioned(right: 0, top: 8, child: Text('0.00 USD', style: TextStyle(fontFamily: 'Sora', fontSize: 14, height: 1.35, color: AppColors.body))),
                    const Positioned(right: 0, top: 29, child: Text('0.00₦', style: TextStyle(fontFamily: 'Sora', fontSize: 10, height: 1.3, color: AppColors.bodyMuted))),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}

class NairaWithdrawScreen extends StatefulWidget {
  const NairaWithdrawScreen({super.key});
  @override State<NairaWithdrawScreen> createState() => _NairaWithdrawScreenState();
}

class _NairaWithdrawScreenState extends State<NairaWithdrawScreen> {
  final amount = TextEditingController();
  BankAccount? account;
  @override void dispose(){amount.dispose();super.dispose();}
  @override Widget build(BuildContext context){
    final ready=amount.text.isNotEmpty&&amount.text!='0'&&account!=null;
    return _Scaffold(
      child: Stack(
        children: [
          const Positioned(left: 0, right: 0, top: 4, height: 40, child: _DashboardHeader()),
          const Positioned(left: 0, right: 0, top: 60, height: 136, child: _BalanceCard()),
          Positioned(
            left: 0,
            right: 0,
            top: 220,
            height: 73,
            child: _ExactNairaField(
              label: 'Amount',
              child: TextField(
                controller: amount,
                keyboardType: TextInputType.number,
                onChanged:(_)=>setState((){}),
                decoration: const DavoInlineInputDecoration(
                  hintText:'0',
                  hintStyle: TextStyle(fontFamily:'Sora',fontSize:16,height:1.35,color:Color(0xFF686868)),
                ),
                style: const TextStyle(fontFamily:'Sora',fontSize:16,height:1.35,color:AppColors.ink),
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            top: 305,
            height: 15,
            child: Text('Max daily amount - ₦5,000,000',style:TextStyle(fontFamily:'Sora',fontSize:12,height:1.25,color:AppColors.body)),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 344,
            height: 73,
            child: _ExactNairaField(
              label: 'Payment Method',
              onTap: _payment,
              trailing: Image.asset('$_exact/naira_payment_chevron_exact.png',width:24,height:24,fit:BoxFit.contain),
              child: account == null
                  ? const Text('Select a payment method',style:TextStyle(fontFamily:'Sora',fontSize:16,height:1.35,color:Color(0xFF686868)))
                  : Padding(
                      padding: const EdgeInsets.only(left:5),
                      child: Text(account!.bank,style:const TextStyle(fontFamily:'Sora',fontSize:14,height:1.35,color:AppColors.ink)),
                    ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 690,
            height: 48,
            child: _Button(
              label:'Continue',
              enabled:true,
              fontWeight:FontWeight.w700,
              onTap: ready ? _review : () {},
            ),
          ),
        ],
      ),
    );
  }
  Future<void> _payment() async {
    final value=await showModalBottomSheet<BankAccount>(context:context,isScrollControlled:true,backgroundColor:Colors.transparent,barrierColor:Colors.black.withValues(alpha: .4),builder:(_)=>_PaymentSheet(current:account));
    if(mounted&&value!=null)setState(()=>account=value);
  }
  Future<void> _review() async {
    if(account==null)return;
    final ok=await showModalBottomSheet<bool>(context:context,isScrollControlled:true,backgroundColor:Colors.transparent,barrierColor:Colors.black.withValues(alpha: .4),builder:(_)=>_NairaConfirm(amount:amount.text,account:account!));
    if(!mounted||ok!=true)return;
    final pin=await Navigator.push<bool>(context,AppPageRoute<bool>(builder:(_)=>const CryptoPinScreen()));
    if(!mounted||pin!=true)return;
    _showTransactionToast(context, 'Submitted Successfully');
    Navigator.pop(context);
  }
}

class _ExactNairaField extends StatelessWidget {
  const _ExactNairaField({required this.label, required this.child, this.trailing, this.onTap});
  final String label;
  final Widget child;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: const Color(0xFFFBFBFD),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: Color(0xFFEEF0F5), width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              Positioned(left: 12, right: 12, top: 10, height: 19, child: Text(label, style: const TextStyle(fontFamily:'Sora',fontSize:14,height:1.35,color:AppColors.body))),
              Positioned(
                left: 12,
                right: trailing == null ? 12 : 44,
                top: 37,
                height: 24,
                child: child,
              ),
              if (trailing != null)
                Positioned(right: 12, top: 24.5, width: 24, height: 24, child: trailing!),
            ],
          ),
        ),
      );
}

void _showTransactionToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      width: 265,
      padding: EdgeInsets.zero,
      elevation: 0,
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      content: Container(
        width: 265,
        height: 62,
        decoration: BoxDecoration(color: const Color(0xFF1C1C1C), borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('$_exact/transaction_toast_check_exact.png', width: 16, height: 16),
            const SizedBox(width: 12),
            Text(message, style: const TextStyle(fontFamily: 'Sora', fontSize: 16, height: 1.35, color: Color(0xFFF8F9FB))),
          ],
        ),
      ),
    ),
  );
}

class BankAccount { const BankAccount(this.bank,this.number,this.name); final String bank,number,name; }

class _PaymentSheet extends StatelessWidget {
  const _PaymentSheet({this.current});
  final BankAccount? current;

  @override
  Widget build(BuildContext context) {
    final saved = <BankAccount>[
      if (current != null) current!,
      if (current != null) const BankAccount('Opay', '058962566726', 'Callietus Ezeike Chinecherem'),
    ];
    return Container(
      height: 384,
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
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
                decoration: BoxDecoration(color: const Color(0xFF686868), borderRadius: BorderRadius.circular(100)),
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            top: 32,
            child: Text(
              'Select a payment method',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600, height: 1.35, color: AppColors.ink),
            ),
          ),
          Positioned(
            left: 342,
            top: 20,
            width: 24,
            height: 24,
            child: InkResponse(onTap: () => Navigator.pop(context), radius: 20, child: Image.asset('$_exact/crypto_close_exact.png', width: 24, height: 24)),
          ),
          Positioned(
            left: 16,
            right: 16,
            top: 67,
            child: Column(
              children: [
                InkWell(
                  onTap: () async {
                    final a = await Navigator.push<BankAccount>(context, AppPageRoute<BankAccount>(builder: (_) => const AddBankScreen()));
                    if (context.mounted && a != null) Navigator.pop(context, a);
                  },
                  child: SizedBox(
                    height: 34,
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(color: Color(0xFFD8E9FE), shape: BoxShape.circle),
                          child: Image.asset('$_exact/crypto_plus_circle_exact.png', width: 24, height: 24),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(child: Text('Add new payment method', style: TextStyle(fontFamily: 'Sora', fontSize: 14, height: 1.35, color: Color(0xFF424242)))),
                      ],
                    ),
                  ),
                ),
                if (saved.isNotEmpty) const SizedBox(height: 16),
                for (int i = 0; i < saved.length; i++) ...[
                  _PaymentMethodSavedRow(account: saved[i], onTap: () => Navigator.pop(context, saved[i])),
                  if (i != saved.length - 1) const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ],
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
    final bankAsset = account.bank.toLowerCase().contains('opay') ? '$_exact/bank_opay_exact.png' : '$_exact/bank_access_exact.png';
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
                child: Image.asset(bankAsset, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Image.asset('$_exact/bank.png')),
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
                  Text(account.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Sora', fontSize: 14, height: 1.35, color: Color(0xFF424242))),
                  const SizedBox(height: 2),
                  Text('${account.bank} - ${account.number}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.25, color: Color(0xFF686868))),
                ],
              ),
            ),
            Positioned(right: 0, top: 19.5, width: 16, height: 16, child: Image.asset('$_exact/crypto_ep_arrow_right_exact.png', width: 16, height: 16, fit: BoxFit.contain)),
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

  @override
  void dispose() {
    number.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final valid = bank != null && number.text.length >= 10;
    return _Scaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BankTopBar(onBack: () => Navigator.pop(context)),
          const SizedBox(height: 22),
          const SizedBox(
            height: 44,
            child: Text(
              'Add your bank account to receive money fast and secured easily',
              style: TextStyle(fontFamily: 'Sora', fontSize: 16, height: 1.35, color: Color(0xFF424242)),
            ),
          ),
          const SizedBox(height: 24),
          _BankFormBox(label: 'Bank Name', value: bank ?? 'Select bank name', muted: bank == null, onTap: _chooseBank),
          const SizedBox(height: 16),
          _BankFormBox(
            label: 'Account Number',
            child: TextField(
              controller: number,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: const DavoInlineInputDecoration(hintText: 'Enter account number'),
              style: const TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.25, color: Color(0xFF424242)),
            ),
          ),
          const SizedBox(height: 16),
          _BankFormBox(
            label: 'Account Name',
            value: valid ? 'Callietus Ezeike Chinecherem' : 'auto',
            muted: !valid,
            valueSize: 16,
            valueWeight: valid ? FontWeight.w400 : FontWeight.w600,
            height: 70,
          ),
          const Spacer(),
          _Button(
            label: 'Save Account',
            enabled: valid,
            fontWeight: FontWeight.w700,
            onTap: () => Navigator.pop(context, BankAccount(bank!, number.text, 'Callietus Ezeike Chinecherem')),
          ),
        ],
      ),
    );
  }

  Future<void> _chooseBank() async {
    final b = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .4),
      builder: (_) => const _BankSheet(),
    );
    if (mounted && b != null) setState(() => bank = b);
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
            Positioned(left: -14, top: -3, child: _AssetButton(asset: '$_f/buy_back.png', size: 24, onTap: onBack)),
            const Positioned(left: 0, right: 0, top: 4, height: 22, child: IgnorePointer(child: Text('Add a Bank Account', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w600, height: 1.35, color: AppColors.ink)))),
          ],
        ),
      );
}

class _BankFormBox extends StatelessWidget {
  const _BankFormBox({required this.label, this.value, this.child, this.muted = false, this.onTap, this.valueSize = 12, this.valueWeight = FontWeight.w400, this.height = 73});
  final String label;
  final String? value;
  final Widget? child;
  final bool muted;
  final VoidCallback? onTap;
  final double valueSize;
  final FontWeight valueWeight;
  final double height;

  @override
  Widget build(BuildContext context) => Material(
        color: const Color(0xFFFBFBFD),
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Container(
            height: height,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 10, 10, 8),
            decoration: BoxDecoration(border: Border.all(color: const Color(0xFFF5F6F9)), borderRadius: BorderRadius.circular(4)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontFamily: 'Sora', fontSize: 14, height: 1.35, color: Color(0xFF424242))),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: child ?? Text(value ?? '', style: TextStyle(fontFamily: 'Sora', fontSize: valueSize, height: valueSize == 16 ? 1.35 : 1.25, fontWeight: valueWeight, color: muted ? const Color(0xFF8D8D8D) : AppColors.ink)),
                    ),
                    if (onTap != null) Image.asset('$_cf/chevron_right.png', width: 16, height: 16),
                  ],
                ),
              ],
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
  static const banks = ['AAA Finance', 'AB Microfinance Bank', 'Access Bank', 'Kuda Bank', 'Bank Of Agriculture', 'Carbon', 'Ecobank Bank', 'Fcmb', 'Fidelity Bank'];
  final search = TextEditingController();

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = search.text.trim().toLowerCase();
    final visible = banks.where((b) => q.isEmpty || b.toLowerCase().contains(q)).toList();
    final available = MediaQuery.sizeOf(context).height - 31;
    final sheetHeight = available < 640 ? available : available > 813 ? 813.0 : available;
    return Container(
      height: sheetHeight,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      child: Stack(
        children: [
          Positioned(left: 0, right: 0, top: 11, child: Center(child: Container(width: 62, height: 5, decoration: BoxDecoration(color: const Color(0xFF686868), borderRadius: BorderRadius.circular(100))))),
          Positioned(left: 10, top: 30, child: _AssetButton(asset: '$_exact/crypto_close_exact.png', size: 24, onTap: () => Navigator.pop(context))),
          const Positioned(left: 0, right: 0, top: 37, child: Text('Select Bank', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Sora', fontSize: 16, height: 1.35, color: AppColors.ink))),
          Positioned(
            left: 16,
            right: 16,
            top: 76,
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: const Color(0xFFF8F9FB), borderRadius: BorderRadius.circular(4)),
              child: Row(
                children: [
                  Image.asset('$_exact/crypto_search_exact.png', width: 24, height: 24),
                  const SizedBox(width: 16),
                  Expanded(child: TextField(controller: search, onChanged: (_) => setState(() {}), decoration: const DavoInlineInputDecoration(hintText: 'Search for a bank'), style: const TextStyle(fontFamily: 'Sora', fontSize: 14, height: 1.35, color: AppColors.ink))),
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
                      Positioned(left: 0, top: 0, width: 40, height: 40, child: Container(alignment: Alignment.center, decoration: const BoxDecoration(color: Color(0xFFEEF0F5), shape: BoxShape.circle), child: Image.asset('$_exact/crypto_bank_exact.png', width: 24, height: 24))),
                      Positioned(left: 64, top: 10.5, right: 0, child: Text(visible[i], style: const TextStyle(fontFamily: 'Sora', fontSize: 14, height: 1.35, color: AppColors.ink))),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (sheetHeight >= 790) Positioned(left: 128, bottom: 8, child: Container(width: 134, height: 5, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(100)))),
        ],
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
  Widget build(BuildContext context) => Container(
        height: 539,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Stack(
          children: [
            Positioned(
              left: 16,
              top: 32,
              width: 23,
              height: 24,
              child: InkResponse(onTap: () => Navigator.pop(context, false), radius: 20, child: Image.asset('$_exact/crypto_close_exact.png', width: 23, height: 24, fit: BoxFit.fill)),
            ),
            const Positioned(right: 14, top: 36.5, child: Text('Use Payment PIN', style: TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.25, color: AppColors.primary))),
            Positioned(
              left: 16,
              right: 14,
              top: 80,
              height: 307,
              child: Container(
                decoration: BoxDecoration(color: const Color(0xFFF8F9FB), borderRadius: BorderRadius.circular(8)),
                child: Stack(
                  children: [
                    Positioned(left: 0, right: 0, top: 28, height: 27, child: Center(child: Text('₦${widget.amount}', style: const TextStyle(fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.w600, height: 1.35, color: AppColors.ink)))),
                    Positioned(left: 15, right: 15, top: 73, child: _ExactNairaConfirmLine('Bank', widget.account.bank)),
                    Positioned(left: 15, right: 15, top: 120, child: _ExactNairaConfirmLine('Account Number', widget.account.number)),
                    Positioned(left: 15, right: 15, top: 167, child: _ExactNairaConfirmLine('Name', widget.account.name.split(' ').take(2).join(' '))),
                    Positioned(left: 15, right: 15, top: 214, child: _ExactNairaConfirmLine('Amount', '₦${widget.amount}')),
                    const Positioned(left: 15, right: 15, top: 267, child: _ExactNairaConfirmLine('Fee', '₦100.00', last: true)),
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
                    Image.asset(agreed ? '$_exact/crypto_checked_exact.png' : '$_exact/crypto_unchecked_exact.png', width: 16, height: 16),
                    const SizedBox(width: 8),
                    const Text('I agree to the terms and condition', style: TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.25, color: AppColors.primary)),
                  ],
                ),
              ),
            ),
            Positioned(left: 16, right: 14, top: 467, height: 48, child: _Button(label: 'Confirm Withdrawal', enabled: agreed, fontWeight: FontWeight.w700, onTap: () => Navigator.pop(context, true))),
          ],
        ),
      );
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
            Positioned(left: 0, top: 0, child: Text(label, style: const TextStyle(fontFamily: 'Sora', fontSize: 14, height: 1.35, color: Color(0xFF686868)))),
            Positioned(right: 0, top: 0, child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontFamily: 'Sora', fontSize: 14, height: 1.35, color: AppColors.ink))),
            if (!last) const Positioned(left: 0, right: 0, bottom: 0, child: Divider(height: 1, thickness: .6, color: Color(0xFFF2F2F2))),
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
              subtitle: 'Send Crypto to another Davochain\nuser instantly at zero fees',
              onTap: () => Navigator.push(context, AppPageRoute<void>(builder: (_) => const CryptoWithdrawEntryScreen(external: false))),
            ),
            const SizedBox(height: 16),
            _Choice(
              asset: '$_cf/qr_wallet.png',
              title: 'Wallet Address',
              subtitle: 'Send crypto to an external wallet,\nnetwork fee applies',
              onTap: () => Navigator.push(context, AppPageRoute<void>(builder: (_) => const CryptoWithdrawEntryScreen(external: true))),
            ),
          ],
        ),
      );
}

class CryptoWithdrawEntryScreen extends StatefulWidget {
  const CryptoWithdrawEntryScreen({super.key, required this.external});
  final bool external;
  @override
  State<CryptoWithdrawEntryScreen> createState() => _CryptoWithdrawEntryScreenState();
}

class _CryptoWithdrawEntryScreenState extends State<CryptoWithdrawEntryScreen> {
  final target = TextEditingController();
  final amount = TextEditingController();
  String? network;

  @override
  void dispose() {
    target.dispose();
    amount.dispose();
    super.dispose();
  }

  bool get _ready => target.text.isNotEmpty && amount.text.isNotEmpty && (!widget.external || network != null);

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (_, __) => _cancel(),
        child: widget.external ? _buildExternal(context) : _buildInternal(context),
      );

  Widget _buildInternal(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        body: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Positioned(
                left: 16,
                right: 16,
                top: 12,
                height: 32,
                child: _TopBar(title: 'Withdraw', onBack: _cancel, height: 32, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const Positioned(left: 16, right: 16, top: 60, height: 93, child: _CryptoBalance()),
              Positioned(
                left: 16,
                right: 16,
                top: 177,
                height: 71,
                child: _ExactWithdrawField(
                  label: 'Transfer To',
                  fill: Colors.white,
                  borderColor: AppColors.mutedSoft,
                  child: TextField(
                    controller: target,
                    onChanged: (_) => setState(() {}),
                    decoration: const DavoInlineInputDecoration(
                      hintText: 'Enter Davochain username',
                      hintStyle: TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.25, color: Color(0xFF686868)),
                    ),
                    style: const TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.25, color: AppColors.ink),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                top: 272,
                height: 71,
                child: _ExactWithdrawField(
                  label: 'Enter Amount',
                  fill: Colors.white,
                  borderColor: AppColors.mutedSoft,
                  rightPadding: 12,
                  child: Row(
                    children: [
                      SizedBox(width: 24, height: 24, child: Center(child: Image.asset('$_f/btc.png', width: 16, height: 17, fit: BoxFit.contain))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: amount,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          onChanged: (_) => setState(() {}),
                          decoration: const DavoInlineInputDecoration(
                            hintText: 'Enter BTC amount',
                            hintStyle: TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.25, color: Color(0xFF686868)),
                          ),
                          style: const TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.25, color: AppColors.ink),
                        ),
                      ),
                      if (amount.text.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text('${((double.tryParse(amount.text) ?? 0) * 25000).toStringAsFixed(2)} USD', style: const TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.25, color: Color(0xFF686868))),
                      ] else
                        InkWell(
                          onTap: () {
                            amount.text = '0.02';
                            setState(() {});
                          },
                          child: const SizedBox(width: 32, height: 20, child: Center(child: Text('Max', style: TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.25, color: AppColors.primary)))),
                        ),
                    ],
                  ),
                ),
              ),
              const Positioned(left: 16, right: 16, top: 355, height: 15, child: Text('Daily transfer limit - \$500', style: TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.25, color: Color(0xFF686868)))),
              Positioned(left: 16, right: 16, top: 695, height: 48, child: _Button(label: 'Continue', enabled: _ready, fontWeight: FontWeight.w700, onTap: _confirm)),
            ],
          ),
        ),
      );

  Widget _buildExternal(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(

            child: SizedBox(
              height: 901,
              child: Stack(
                children: [
                  Positioned(
                    left: 16,
                    right: 16,
                    top: 12,
                    height: 32,
                    child: _TopBar(title: 'Withdraw', onBack: _cancel, height: 32, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const Positioned(left: 16, right: 16, top: 60, height: 93, child: _CryptoBalance()),
                  Positioned(
                    left: 16,
                    right: 16,
                    top: 177,
                    height: 71,
                    child: _ExactWithdrawField(
                      label: 'Address',
                      fill: const Color(0xFFF5F6F9),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: target,
                              onChanged: (_) => setState(() {}),
                              decoration: const DavoInlineInputDecoration(
                                hintText: 'Paste the wallet address',
                                hintStyle: TextStyle(fontFamily: 'Open Sans', fontSize: 16, height: 1.35, color: Color(0xFF686868)),
                              ),
                              style: const TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.25, color: AppColors.ink),
                            ),
                          ),
                          InkResponse(onTap: _scan, radius: 18, child: Image.asset('$_exact/withdraw_address_book_exact.png', width: 20, height: 20)),
                          const SizedBox(width: 4),
                          Container(width: .5, height: 18, color: const Color(0xFFD9DCE4)),
                          const SizedBox(width: 4),
                          InkResponse(onTap: _scan, radius: 18, child: Image.asset('$_exact/withdraw_qr_exact.png', width: 20, height: 20)),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    top: 272,
                    height: 71,
                    child: _ExactWithdrawField(
                      label: 'Network',
                      fill: const Color(0xFFF5F6F9),
                      onTap: _network,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              network == null ? 'Please select withdrawal network' : (network!.startsWith('Bitcoin') ? 'BTC' : network!),
                              style: TextStyle(
                                fontFamily: network == null ? 'Open Sans' : 'Sora',
                                fontSize: network == null ? 16 : 12,
                                height: network == null ? 1.35 : 1.25,
                                color: network == null ? const Color(0xFF686868) : AppColors.ink,
                              ),
                            ),
                          ),
                          Image.asset('$_exact/withdraw_arrow_down_exact.png', width: 20, height: 20),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    top: 367,
                    height: 71,
                    child: _ExactWithdrawField(
                      label: 'Amount',
                      fill: const Color(0xFFF5F6F9),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: amount,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (_) => setState(() {}),
                              decoration: const DavoInlineInputDecoration(
                                hintText: 'Please enter the withdrawal quantity',
                                hintStyle: TextStyle(fontFamily: 'Sora', fontSize: 16, height: 1.35, color: Color(0xFF686868)),
                              ),
                              style: const TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.25, color: AppColors.ink),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              amount.text = '0.0300';
                              setState(() {});
                            },
                            child: const SizedBox(width: 28, height: 22, child: Center(child: Text('All', style: TextStyle(fontFamily: 'Open Sans', fontSize: 16, height: 1.35, color: AppColors.primary)))),
                          ),
                          const SizedBox(width: 4),
                          const Text('BTC', style: TextStyle(fontFamily: 'Open Sans', fontSize: 16, height: 1.35, color: Color(0xFF424242))),
                        ],
                      ),
                    ),
                  ),
                  const Positioned(left: 16, top: 442, width: 72, height: 22, child: Text('Available', style: TextStyle(fontFamily: 'Sora', fontSize: 16, height: 1.35, color: Color(0xFF424242)))),
                  const Positioned(right: 16, top: 442, width: 47, height: 22, child: Text('0 BTC', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Sora', fontSize: 16, height: 1.35, color: Color(0xFF424242)))),
                  const Positioned(left: 16, right: 16, top: 488, height: 15, child: Text('Withdrawal Notice', style: TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.25, color: Color(0xFF424242)))),
                  const Positioned(
                    left: 16,
                    right: 16,
                    top: 511,
                    height: 210,
                    child: Text(
                      'Minimum withdrawal: 0.00002 BTC\nMaximum per transaction: 100 BTC\n24-hour withdrawal limit:\nYou can withdraw up to 200 BTC within 24 hours.\nInternal transfers:\nWithdrawals to other Davopay users are processed instantly and incur no fees.\nUnsupported addresses:\nDo not send withdrawals directly to crowdfunding or ICO addresses, as Davopay does not support token distribution from such transactions.\nSecurity notice:\nAvoid transacting with unverified or high-risk platforms. Always ensure the destination is safe and trusted. Learn more',
                      style: TextStyle(fontFamily: 'Sora', fontSize: 10, height: 1.4, color: Color(0xFF424242)),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 761,
                    height: 114,
                    child: Container(
                      color: Colors.white.withValues(alpha: .10),
                      child: Stack(
                        children: [
                          const Positioned(left: 16, top: 10, width: 116, height: 15, child: Text('Receiving', style: TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.25, color: Color(0xFF424242)))),
                          Positioned(
                            left: 16,
                            top: 33,
                            width: 132,
                            height: 33,
                            child: Text(
                              _ready ? '0.03014 BTC (\$500.00)' : '0.0317934 BTC (\$25,040.27)',
                              style: const TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.35, color: AppColors.ink),
                            ),
                          ),
                          Positioned(left: 16, top: 70, width: 10, height: 10, child: Image.asset('$_cf/network_warning.png', width: 10, height: 10)),
                          Positioned(
                            left: 30,
                            top: 70,
                            height: 13,
                            child: Text(_ready ? 'Network Fee \$5.27 BTC' : 'Network Fee 0 BTC', style: const TextStyle(fontFamily: 'Sora', fontSize: 10, height: 1.3, color: Color(0xFF686868))),
                          ),
                          Positioned(left: 203, top: 22.5, width: 171, height: 48, child: _Button(label: 'Confirm', enabled: _ready, disabledColor: AppColors.mutedSoft, disabledTextColor: const Color(0xFF9D9EA2), onTap: _confirm)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Future<void> _cancel() async {
    final c = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .4),
      builder: (_) => const CancelReminderSheet(),
    );
    if (mounted && c == true) Navigator.pop(context);
  }

  Future<void> _scan() async {
    final a = await Navigator.push<String>(context, AppPageRoute<String>(builder: (_) => const ScanPasteAddressScreen()));
    if (mounted && a != null) setState(() => target.text = a);
  }

  Future<void> _network() async {
    final n = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .4),
      builder: (_) => const SelectNetworkSheet(),
    );
    if (!mounted || n == null) return;
    final understood = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .4),
      builder: (_) => const SanctionWarningSheet(),
    );
    if (mounted && understood == true) setState(() => network = n);
  }

  Future<void> _confirm() async {
    final n = double.tryParse(amount.text) ?? .03;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: .4),
      builder: (_) => widget.external ? _ExternalWithdrawConfirmSheet(target: target.text, amount: n) : _InternalWithdrawConfirmSheet(target: target.text, amount: n),
    );
    if (!mounted || ok != true) return;
    final pin = await Navigator.push<bool>(context, AppPageRoute<bool>(builder: (_) => const CryptoPinScreen()));
    if (!mounted || pin != true) return;
    Navigator.pushReplacement(context, AppPageRoute<void>(builder: (_) => TransactionProgressScreen(kind: widget.external ? TxKind.external : TxKind.internal, target: target.text, amount: n)));
  }
}

class _ExactWithdrawField extends StatelessWidget {
  const _ExactWithdrawField({required this.label, required this.fill, required this.child, this.onTap, this.borderColor, this.rightPadding = 16});
  final String label;
  final Color fill;
  final Widget child;
  final VoidCallback? onTap;
  final Color? borderColor;
  final double rightPadding;

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Positioned(left: 0, top: 0, height: 19, child: Text(label, style: const TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600, height: 1.35, color: AppColors.ink))),
          Positioned(
            left: 0,
            right: 0,
            top: 23,
            height: 48,
            child: Material(
              color: fill,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: borderColor == null ? BorderSide.none : BorderSide(color: borderColor!, width: 1),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(4),
                child: Padding(padding: EdgeInsets.fromLTRB(16, 12, rightPadding, 12), child: child),
              ),
            ),
          ),
        ],
      );
}

class _ExternalWithdrawConfirmSheet extends StatelessWidget {
  const _ExternalWithdrawConfirmSheet({required this.target, required this.amount});
  final String target;
  final double amount;

  @override
  Widget build(BuildContext context) => Container(
        height: 407,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 42, 15, 30),
          child: Column(
            children: [
              SizedBox(
                height: 32,
                child: Stack(
                  children: [
                    const Positioned(left: 0, top: 6.5, child: Text('Security Verification', style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600, height: 1.35, color: AppColors.ink))),
                    Positioned(right: 0, top: 0, width: 32, height: 32, child: InkResponse(onTap: () => Navigator.pop(context, false), child: Image.asset('$_exact/crypto_close_exact.png', width: 32, height: 32))),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Container(
                height: 159,
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(15, 16, 15, 10),
                decoration: BoxDecoration(color: const Color(0xFFF2F3F7), borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    const _CompactLine('On - Chain Withdrawal', 'BTC'),
                    const SizedBox(height: 12),
                    _CompactLine('Withdraw to', target),
                    const SizedBox(height: 10),
                    _CompactLine('Amount to Received', '${(amount - .00002).clamp(0, double.infinity).toStringAsFixed(5)} BTC'),
                    const SizedBox(height: 10),
                    const _CompactLine('Withdrawal Fees', '0.00002 BTC'),
                  ],
                ),
              ),
              const Spacer(),
              _Button(label: 'Confirm', onTap: () => Navigator.pop(context, true)),
            ],
          ),
        ),
      );
}

class _InternalWithdrawConfirmSheet extends StatelessWidget {
  const _InternalWithdrawConfirmSheet({required this.target, required this.amount});
  final String target;
  final double amount;

  @override
  Widget build(BuildContext context) => Container(
        height: 539,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
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
                child: Image.asset('$_exact/crypto_close_exact.png', width: 23, height: 24, fit: BoxFit.contain),
              ),
            ),
            const Positioned(
              right: 16,
              top: 36.5,
              child: Text('Use Payment PIN', style: TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.25, color: AppColors.primary)),
            ),
            Positioned(
              left: 16,
              right: 16,
              top: 80,
              height: 287,
              child: Container(
                decoration: BoxDecoration(color: const Color(0xFFF8F9FB), borderRadius: BorderRadius.circular(8)),
                child: Stack(
                  children: [
                    Positioned(left: 15, right: 15, top: 22, child: _ExactConfirmSimpleRow(label: 'Username', value: target)),
                    Positioned(left: 15, right: 15, top: 69, child: _ExactConfirmSimpleRow(label: 'Asset', value: '${amount.toStringAsFixed(2)} BTC', valueSize: 12, labelTopAdjust: 2.5)),
                    Positioned(
                      left: 15,
                      right: 15,
                      top: 121,
                      child: _ExactConfirmTwoLineRow(label: 'Amount', primary: '${amount.toStringAsFixed(4)} BTC', secondary: r'$500.00 USD'),
                    ),
                    const Positioned(left: 15, right: 15, top: 184, child: _ExactConfirmSimpleRow(label: 'Network Fee', value: 'Free', valueColor: AppColors.primary)),
                    Positioned(
                      left: 15,
                      right: 15,
                      top: 231,
                      child: _ExactConfirmTwoLineRow(label: 'Total', primary: '${amount.toStringAsFixed(4)} BTC', secondary: r'$500.00 USD'),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              top: 383,
              height: 43,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(color: const Color(0xFFF0F3FA), borderRadius: BorderRadius.circular(2)),
                child: Row(
                  children: [
                    Image.asset('$_exact/crypto_info_exact.png', width: 16, height: 16),
                    const SizedBox(width: 11),
                    const Expanded(child: Text('Double check the details before Confirming this transfer', style: TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.25, color: AppColors.body))),
                  ],
                ),
              ),
            ),
            Positioned(left: 16, right: 16, top: 466, height: 48, child: _Button(label: 'Confirm Withdrawal', fontWeight: FontWeight.w700, onTap: () => Navigator.pop(context, true))),
          ],
        ),
      );
}

class _ExactConfirmSimpleRow extends StatelessWidget {
  const _ExactConfirmSimpleRow({required this.label, required this.value, this.valueColor, this.valueSize = 14, this.labelTopAdjust = 0});
  final String label, value;
  final Color? valueColor;
  final double valueSize, labelTopAdjust;
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 35,
        child: Stack(
          children: [
            Positioned(left: 0, top: labelTopAdjust, child: Text(label, style: const TextStyle(fontFamily: 'Sora', fontSize: 14, height: 1.35, color: Color(0xFF686868)))),
            Positioned(right: 0, top: valueSize == 12 ? 2.5 : 0, child: Text(value, textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Sora', fontSize: valueSize, height: valueSize == 12 ? 1.25 : 1.35, color: valueColor ?? AppColors.ink))),
          ],
        ),
      );
}

class _ExactConfirmTwoLineRow extends StatelessWidget {
  const _ExactConfirmTwoLineRow({required this.label, required this.primary, required this.secondary});
  final String label, primary, secondary;
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 51,
        child: Stack(
          children: [
            Positioned(left: 0, top: 8, child: Text(label, style: const TextStyle(fontFamily: 'Sora', fontSize: 14, height: 1.35, color: Color(0xFF686868)))),
            Positioned(right: 0, top: 0, child: Text(primary, textAlign: TextAlign.right, style: const TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600, height: 1.35, color: AppColors.ink))),
            Positioned(right: 0, top: 20, child: Text(secondary, textAlign: TextAlign.right, style: const TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.25, color: Color(0xFF686868)))),
          ],
        ),
      );
}

class _CompactLine extends StatelessWidget{const _CompactLine(this.label,this.value);final String label,value;@override Widget build(BuildContext context)=>Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(label,style:const TextStyle(fontFamily:'Sora',fontSize:12,color:Color(0xFF686868))),const Spacer(),Flexible(child:Text(value,textAlign:TextAlign.right,style:const TextStyle(fontFamily:'Sora',fontSize:14,color:AppColors.ink))) ]);}

class TransferReviewScreen extends StatelessWidget { const TransferReviewScreen({super.key,required this.kind,required this.target,required this.amount,this.network}); final TxKind kind;final String target;final double amount;final String? network;
  @override Widget build(BuildContext context){final ext=kind==TxKind.external;return _Scaffold(child:Column(children:[
    _TopBar(title:'Withdraw',onBack:()=>Navigator.pop(context)),const SizedBox(height:20),const _CryptoBalance(),const SizedBox(height:20),
    _Summary(children:[_Row(label:ext?'Address':'Username',value:ext?_short(target):target),if(ext)_Row(label:'Network',value:network??'Bitcoin'),const _Row(label:'Asset',value:'Bitcoin (BTC)'),_Row(label:'Amount',value:'${amount.toStringAsFixed(4)} BTC'),_Row(label:'Network Fee',value:ext?'0.00002 BTC':'Free',valueColor:AppColors.primary),_Row(label:'Total',value:'${(amount+(ext ? .00002 : 0)).toStringAsFixed(5)} BTC',last:true)]),
    const Spacer(),_Button(label:'Confirm Withdrawal',onTap:()=>_pin(context)),
  ]));}
  Future<void> _pin(BuildContext context) async{final ok=await Navigator.push<bool>(context,AppPageRoute<bool>(builder:(_)=>const CryptoPinScreen()));if(!context.mounted||ok!=true)return;Navigator.pushReplacement(context,AppPageRoute<void>(builder:(_)=>TransactionProgressScreen(kind:kind,target:target,amount:amount)));}
}

class CryptoPinScreen extends StatelessWidget {
 const CryptoPinScreen({super.key});
 @override
 Widget build(BuildContext context) => TransactionPinEntryScreen(onConfirm: () => Navigator.pop(context, true));
}

class TransactionProgressScreen extends StatefulWidget {
  const TransactionProgressScreen({super.key, required this.kind, required this.target, required this.amount});
  final TxKind kind;
  final String target;
  final double amount;
  @override
  State<TransactionProgressScreen> createState() => _TransactionProgressScreenState();
}

class _TransactionProgressScreenState extends State<TransactionProgressScreen> {
  Timer? timer;
  @override
  void initState() {
    super.initState();
    timer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) Navigator.pushReplacement(context, AppPageRoute<void>(builder: (_) => TransactionSuccessScreen(kind: widget.kind, target: widget.target, amount: widget.amount)));
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transfer = widget.kind == TxKind.internal || widget.kind == TxKind.external;
    final title = transfer
        ? 'Sending ${widget.amount.toStringAsFixed(4)} BTC'
        : widget.kind == TxKind.sell
            ? 'Selling ${widget.amount.toStringAsFixed(5)} BTC'
            : 'Converting';
    final sub = switch (widget.kind) { TxKind.internal => 'to ${widget.target}', TxKind.external => 'to ${_short(widget.target)}', _ => '' };
    final subColor = widget.kind == TxKind.external ? const Color(0xFF686868) : const Color(0xFF424242);
    return _FigmaFullScaffold(
      child: Column(
        children: [
          _TopBar(title: transfer ? 'Crypto Withdraw Mode' : '', onBack: () => Navigator.pop(context), height: 32, fontSize: 14, fontWeight: FontWeight.w400),
          const SizedBox(height: 47),
          Image.asset('$_exact/dashboard_crypto_gifs__dashbardandcryptgifs_a56b5b485b8874cc26d0b3c667bfc016ba68cf23.gif', width: 150, height: 150, fit: BoxFit.contain),
          const SizedBox(height: 16),
          SizedBox(height: 22, child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w600, height: 1.35, color: AppColors.ink))),
          if (sub.isNotEmpty) ...[
            const SizedBox(height: 4),
            SizedBox(height: 19, child: Text(sub, textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Sora', fontSize: 14, height: 1.35, color: subColor))),
          ],
          SizedBox(height: sub.isNotEmpty ? 8 : 8),
          Text(
            widget.kind == TxKind.conversion || widget.kind == TxKind.sell ? 'Please wait while we process your Conversion' : 'Please wait while we process your transaction',
            textAlign: TextAlign.center,
            style: const TextStyle(fontFamily: 'Sora', fontSize: 14, height: 1.35, color: Color(0xFF424242)),
          ),
        ],
      ),
    );
  }
}

class TransactionSuccessScreen extends StatelessWidget {
  const TransactionSuccessScreen({super.key, required this.kind, required this.target, required this.amount});
  final TxKind kind;
  final String target;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final transfer = kind == TxKind.internal || kind == TxKind.external;
    final title = transfer
        ? 'Transfer Successful'
        : kind == TxKind.sell
            ? 'Sold  Successful'
            : 'Conversion  Successful';
    final twoLine = kind != TxKind.internal;
    return _FigmaFullScaffold(
      child: Column(
        children: [
          _TopBar(title: transfer ? 'Crypto Withdraw Mode' : '', onBack: () => Navigator.pop(context), height: 32, fontSize: 14, fontWeight: transfer ? FontWeight.w600 : FontWeight.w400),
          const SizedBox(height: 47),
          Image.asset('$_exact/dashboard_crypto_gifs__dashbardandcryptgifs_4d6e1474ce658d29d4eaabd043e0c07fe0db035c.gif', width: 150, height: 150, fit: BoxFit.contain),
          const SizedBox(height: 16),
          SizedBox(height: 27, child: Center(child: Text(title, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.w700, height: 1.35, color: AppColors.ink)))),
          const SizedBox(height: 8),
          SizedBox(
            width: 287,
            height: twoLine ? 38 : 19,
            child: _TransactionSuccessMessage(kind: kind, target: target, amount: amount),
          ),
          const SizedBox(height: 314),
          _Button(label: 'View Details', onTap: () => Navigator.push(context, AppPageRoute<void>(builder: (_) => TransactionDetailsScreen(kind: kind, target: target, amount: amount)))),
          const SizedBox(height: 16),
          _Secondary(label: 'Send another transfer', onTap: () => Navigator.of(context).popUntil((r) => r.isFirst)),
        ],
      ),
    );
  }
}

class _TransactionSuccessMessage extends StatelessWidget {
  const _TransactionSuccessMessage({required this.kind, required this.target, required this.amount});
  final TxKind kind;
  final String target;
  final double amount;

  @override
  Widget build(BuildContext context) {
    const muted = Color(0xFF686868);
    const ink = AppColors.ink;
    const base = TextStyle(fontFamily: 'Sora', fontSize: 14, height: 1.35, color: muted);
    const dark = TextStyle(fontFamily: 'Sora', fontSize: 14, height: 1.35, color: ink);
    const strong = TextStyle(fontFamily: 'Sora', fontSize: 14, height: 1.35, fontWeight: FontWeight.w600, color: ink);
    final amountText = (kind == TxKind.sell || kind == TxKind.conversion) ? '0.0300 BTC' : '${amount.toStringAsFixed(4)} BTC';
    final spans = switch (kind) {
      TxKind.internal => <InlineSpan>[
          const TextSpan(text: 'You have sent', style: base),
          TextSpan(text: ' $amountText ', style: dark),
          const TextSpan(text: 'to', style: base),
          TextSpan(text: ' $target', style: dark),
        ],
      TxKind.external => <InlineSpan>[
          const TextSpan(text: 'You have sent ', style: base),
          TextSpan(text: amountText, style: strong),
          const TextSpan(text: ' to ', style: base),
          TextSpan(text: _short(target), style: strong),
        ],
      TxKind.conversion => <InlineSpan>[
          const TextSpan(text: 'You have successfully converted  ', style: base),
          TextSpan(text: amountText, style: strong),
          const TextSpan(text: ' to ', style: base),
          const TextSpan(text: r'$500 USDT', style: strong),
        ],
      TxKind.sell => <InlineSpan>[
          const TextSpan(text: 'You have successfully Sell  ', style: base),
          TextSpan(text: '$amountText ', style: strong),
          const TextSpan(text: 'for ', style: base),
          const TextSpan(text: '₦731,540.00', style: strong),
        ],
    };
    return Text.rich(TextSpan(children: spans), textAlign: TextAlign.center);
  }
}

class TransactionDetailsScreen extends StatelessWidget {
  const TransactionDetailsScreen({super.key, required this.kind, required this.target, required this.amount, this.receipt = false});
  final TxKind kind;
  final String target;
  final double amount;
  final bool receipt;

  @override
  Widget build(BuildContext context) => receipt ? _buildReceipt(context) : _buildDetails(context);

  Widget _buildDetails(BuildContext context) {
    return Scaffold(
      backgroundColor:const Color(0xFFF8F9FB),
      body:SafeArea(child:Column(children:[
        _TopBar(title:'Transaction Details',onBack:()=>Navigator.pop(context),height:48,fontSize:14,fontWeight:FontWeight.w600),
        Expanded(child:SingleChildScrollView(padding:const EdgeInsets.all(16),child:Column(children:[
          const SizedBox(height:24),
          Text('${amount.toStringAsFixed(4)} BTC',style:const TextStyle(fontSize:24,fontWeight:FontWeight.w700)),
          const SizedBox(height:6),
          const Text(r'$500.00 USD',style:TextStyle(fontSize:14,color:AppColors.body)),
          const SizedBox(height:16),
          const Text('Completed',style:TextStyle(fontSize:12,color:Color(0xFF1BA44D),fontWeight:FontWeight.w600)),
          const SizedBox(height:28),
          _TransactionDetailCard(kind:kind,target:target,amount:amount,height:0),
        ]))),
        Padding(padding:const EdgeInsets.fromLTRB(16,12,16,16),child:Column(mainAxisSize:MainAxisSize.min,children:[
          _Button(label:'Done',onTap:()=>Navigator.of(context).popUntil((r)=>r.isFirst)),
          const SizedBox(height:12),
          _Secondary(label:'Share Receipt',onTap:()=>Navigator.push(context,AppPageRoute<void>(builder:(_)=>TransactionDetailsScreen(kind:kind,target:target,amount:amount,receipt:true)))),
        ])),
      ])),
    );
  }

  Widget _buildReceipt(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8F9FB),
    body: SafeArea(child: Column(children: [
      _TopBar(title: 'Transaction Receipt', onBack: () => Navigator.pop(context), height: 48, fontSize: 14, fontWeight: FontWeight.w600),
      Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        const SizedBox(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset('assets/images/brand/davochain_logo.png', width: 32, height: 32),
          const SizedBox(width: 8),
          const Flexible(child: Text('Davochain', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700))),
        ]),
        const SizedBox(height: 24),
        Text('${amount.toStringAsFixed(4)} BTC', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        const Text('Completed', style: TextStyle(color: Color(0xFF1BA44D), fontWeight: FontWeight.w600)),
        const SizedBox(height: 24),
        _TransactionDetailCard(kind: kind, target: target, amount: amount, height: 0),
        const SizedBox(height: 24),
        const Text('Thank you for using Davochain', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        const Text('Build. Trade. Belong.', style: TextStyle(fontSize: 12, color: AppColors.bodyMuted)),
      ]))),
    ])),
  );
}

class _TransactionDetailCard extends StatelessWidget {
  const _TransactionDetailCard({required this.kind, required this.target, required this.amount, required this.height});
  final TxKind kind;
  final String target;
  final double amount;
  final double height;

  @override
  Widget build(BuildContext context) {
    final trading = kind == TxKind.sell || kind == TxKind.conversion;
    Widget row(String label, String value, {bool copy = false, Widget? icon, Color? color}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: _ExactTransactionRow(label:label,value:value,copy:copy,valueLeading:icon,valueColor:color,maxLines:3),
    );
    return Container(padding: const EdgeInsets.symmetric(horizontal:16,vertical:8),
      decoration: BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(8)),
      child: Column(children:[
        if(trading) ...[
          row('From', '${amount.toStringAsFixed(5)} BTC',icon:const _TxWrappedBtc24()),
          row('To',kind==TxKind.sell ? '\u20a6731,540.00' : '500.00 USDT',icon:kind==TxKind.sell ? const _TxNigeria24() : const _TxUsdt24()),
        ] else ...[
          row('To',target,copy:kind==TxKind.external),
          row('Asset','Bitcoin (BTC)',icon:const _TxBtc24()),
        ],
        row('Date','Sep 16, 2026, 14:26'),
        row('Network Fee','Free',color:AppColors.primary),
        if(trading) const Padding(padding:EdgeInsets.symmetric(vertical:12),child:_ExactRateRow()),
        row('Transaction ID','0x3a4f...9c7d',copy:true),
        if(kind==TxKind.external) row('Transaction Hash','7c0d217aca078b46197d9283d7b818311de96eae39deddfea593303815d04c35',copy:true),
        if(kind==TxKind.external || kind==TxKind.conversion) const Padding(padding:EdgeInsets.symmetric(vertical:12),child:_BlockchainExplorerRow()),
      ]),
    );
  }
}

class _ExactTransactionRow extends StatelessWidget {
  const _ExactTransactionRow({
    required this.label,
    required this.value,
    this.copy = false,
    this.valueColor,

    this.maxLines = 1,

    this.valueLeading,
  });
  final String label, value;
  final bool copy;
  final Color? valueColor;
  final double fontSize = 14;
  final int maxLines;
  final double copyGap = 8;
  final Widget? valueLeading;

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Text(label, style: TextStyle(fontFamily: 'Sora', fontSize: fontSize, height: 1.35, color: const Color(0xFF686868)))),
          const SizedBox(width: 12),
          if (valueLeading != null) ...[
            SizedBox(
              width: 24,
              height: 19,
              child: OverflowBox(
                minHeight: 24,
                maxHeight: 24,
                alignment: Alignment.center,
                child: Transform.translate(offset: const Offset(0, -2.5), child: valueLeading!),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontFamily: 'Sora', fontSize: fontSize, height: fontSize == 12 ? 1.25 : 1.35, color: valueColor ?? AppColors.ink),
            ),
          ),
          if (copy) ...[
            SizedBox(width: copyGap),
            GestureDetector(onTap: () => Clipboard.setData(ClipboardData(text: value)), child: Image.asset('$_exact/tx_copy_16_exact.png', width: 16, height: 16)),
          ],
        ],
      );
}

class _TxBtc24 extends StatelessWidget {
  const _TxBtc24();
  @override
  Widget build(BuildContext context) => Image.asset('$_exact/tx_btc_24_exact.png', width: 24, height: 24, fit: BoxFit.contain);
}

class _TxWrappedBtc24 extends StatelessWidget {
  const _TxWrappedBtc24();
  @override
  Widget build(BuildContext context) => Image.asset('$_exact/tx_wrapped_btc_24_exact.png', width: 24, height: 24, fit: BoxFit.contain);
}

class _TxUsdt24 extends StatelessWidget {
  const _TxUsdt24();
  @override
  Widget build(BuildContext context) => Image.asset('$_exact/tx_usdt_24_exact.png', width: 24, height: 24, fit: BoxFit.contain);
}

class _TxNigeria24 extends StatelessWidget {
  const _TxNigeria24();
  @override
  Widget build(BuildContext context) => Image.asset('$_f/buy_nigeria.png', width: 24, height: 24, fit: BoxFit.contain);
}

class _ExactRateRow extends StatelessWidget {
  const _ExactRateRow();
  @override
  Widget build(BuildContext context) => const _ExactTransactionRow(
    label: 'Exchange Rate', value: '1 USDT ≈ 0.0000345 BTC', maxLines: 3);
}

class _BlockchainExplorerRow extends StatelessWidget {
  const _BlockchainExplorerRow();
  @override
  Widget build(BuildContext context) => const _ExactTransactionRow(
    label: 'View in Blockchain', value: 'Blockchain Explorer', maxLines: 2);
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
    _addressController.selection = TextSelection.collapsed(offset: value.length);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
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
                child: Image.asset('$_f/buy_back.png', width: 24, height: 24),
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              top: 8,
              height: 40,
              child: IgnorePointer(
                child: Center(
                  child: Text('Scan or Paste Address', style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600, height: 1.35, color: AppColors.ink)),
                ),
              ),
            ),
            Positioned(left: 16, top: 67, width: 170, height: 48, child: _ExactScanTab(label: 'Scan QR Code', active: mode == 0, onTap: () => setState(() => mode = 0))),
            Positioned(left: 202, top: 67, width: 172, height: 48, child: _ExactScanTab(label: 'Paste Address', active: mode == 1, onTap: () => setState(() => mode = 1))),
            if (mode == 0)
              Positioned(
                left: 16,
                top: 141,
                width: 359,
                height: 485,
                child: Container(
                  decoration: BoxDecoration(color: const Color(0xFF191919), borderRadius: BorderRadius.circular(8)),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned(left: 35, top: 12, width: 290, height: 290, child: Image.asset('$_cf/scanner_frame.png', width: 290, height: 290, fit: BoxFit.contain)),
                      Positioned(
                        left: 159,
                        top: 310,
                        width: 42,
                        height: 42,
                        child: Container(
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(color: Color(0xFF2A2A2A), shape: BoxShape.circle),
                          child: Image.asset('$_cf/flashlight.png', width: 24, height: 24, fit: BoxFit.contain),
                        ),
                      ),
                      const Positioned(
                        left: 54.5,
                        top: 363,
                        width: 251,
                        height: 19,
                        child: Text('Align the QR code within the frame', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600, height: 1.35, color: Color(0xFFF5F6F9))),
                      ),
                      Positioned(
                        left: 54.5,
                        top: 384,
                        width: 251,
                        height: 15,
                        child: InkWell(
                          onTap: () => setState(() => mode = 1),
                          child: const Text('Enter Address manually', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w600, height: 1.25, color: Color(0xFF89ADF9))),
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
                  style: const TextStyle(fontFamily: 'Open Sans', fontSize: 16, height: 1.375, color: AppColors.ink),
                  decoration: InputDecoration(
                    hintText: 'Paste the wallet address',
                    hintStyle: const TextStyle(fontFamily: 'Open Sans', fontSize: 16, height: 1.375, color: Color(0xFF686868)),
                    filled: true,
                    fillColor: const Color(0xFFF5F6F9),
                    contentPadding: const EdgeInsets.fromLTRB(16, 13, 72, 13),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: AppColors.primary, width: 1)),
                    suffixIcon: SizedBox(
                      width: 64,
                      child: TextButton(
                        onPressed: _pasteAddress,
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, foregroundColor: AppColors.primary),
                        child: const Text('Paste', style: TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w600, height: 1.25)),
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
                  onTap: () => Navigator.pop(context, _addressController.text.trim()),
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
  const _ExactScanTab({required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
        color: active ? AppColors.primary : const Color(0xFFEAF0FB),
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(4),
          child: Center(child: Text(label, style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600, height: 1.35, color: active ? Colors.white : AppColors.primary))),
        ),
      );
}

class SelectNetworkSheet extends StatelessWidget {
  const SelectNetworkSheet({super.key});
  @override
  Widget build(BuildContext context) => Container(
        height: 407,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        child: Stack(
          children: [
            const Positioned(left: 0, right: 0, top: 41, child: Text('Select Network', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Sora', fontSize: 16, height: 1.35, color: AppColors.ink))),
            Positioned(
              left: 23,
              right: 17,
              top: 73,
              child: Container(
                height: 72,
                padding: const EdgeInsets.fromLTRB(16, 14, 15, 12),
                decoration: BoxDecoration(color: const Color(0xFFE5ECFC), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset('$_cf/network_warning.png', width: 14, height: 14),
                    const SizedBox(width: 8),
                    const Expanded(child: Text('Please make sure that your withdrawal address and chain match each other, otherwise you may lose your assets!', style: TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.25, color: AppColors.ink))),
                  ],
                ),
              ),
            ),
            Positioned(left: 23, right: 118, top: 163, child: _ExactNetworkRow(asset: '$_f/btc.png', title: 'Bitcoin (BTC)', eta: '10m 14s', fee: '0.00002 BTC', usd: r'(\$1.57)', onTap: () => Navigator.pop(context, 'Bitcoin (BTC)'))),
            Positioned(left: 23, right: 118, top: 250, child: _ExactNetworkRow(asset: '$_exact/crypto_bnb_exact.png', title: 'BNB Smart Chain (BEP20)', eta: '2m 2s', fee: '0.00000025 BTC', usd: r'(\$0.019)', onTap: () => Navigator.pop(context, 'BNB Smart Chain (BEP20)'))),
          ],
        ),
      );
}

class _ExactNetworkRow extends StatelessWidget {
  const _ExactNetworkRow({required this.asset, required this.title, required this.eta, required this.fee, required this.usd, required this.onTap});
  final String asset, title, eta, fee, usd;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 62,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(asset, width: 37, height: 37, fit: BoxFit.contain),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 22, child: Text(title, style: const TextStyle(fontFamily: 'Sora', fontSize: 16, height: 1.35, color: AppColors.ink))),
                    const SizedBox(height: 8),
                    Row(children: [const Text('Expected Arrival ', style: TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.25, color: Color(0xFF686868))), Text(eta, style: const TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.25, color: Color(0xFF686868)))]),
                    const SizedBox(height: 2),
                    Row(children: [Text('Fee: $fee', style: const TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.25, color: Color(0xFF686868))), const SizedBox(width: 12), Text(usd, style: const TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.25, color: Color(0xFF686868)))]),
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
  Widget build(BuildContext context) => Container(
        height: 627,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        child: Stack(
          children: [
            Positioned(left: 149, top: 15, child: Container(width: 92, height: 5, decoration: BoxDecoration(color: const Color(0xFF686868), borderRadius: BorderRadius.circular(100)))),
            Positioned(left: 342, top: 27, width: 32, height: 32, child: InkResponse(onTap: () => Navigator.pop(context, false), radius: 20, child: Image.asset('$_exact/crypto_close_exact.png', width: 32, height: 32))),
            const Positioned(left: 17, top: 78, width: 288, height: 30, child: Text('Prohibited Transactions with Sanctioned Entities', style: TextStyle(fontFamily: 'Sora', fontSize: 12, fontWeight: FontWeight.w600, height: 1.25, color: AppColors.ink))),
            const Positioned(left: 17, right: 12, top: 124, height: 42, child: Text('To protect your account and funds, please avoid sending or receiving funds from cryptocurrency exchanges or payment platforms that are sanctioned by regulatory authorities.', style: TextStyle(fontFamily: 'Sora', fontSize: 10, fontWeight: FontWeight.w500, height: 1.4, color: Color(0xFFCC8408)))),
            const Positioned(left: 17, right: 12, top: 190, height: 14, child: Text('High-Risk Platforms (This includes, but is not limited to:)', style: TextStyle(fontFamily: 'Sora', fontSize: 10, fontWeight: FontWeight.w600, height: 1.4, color: AppColors.ink))),
            const Positioned(left: 17, top: 208, width: 100, height: 96, child: Text('Garantex\nGrinex\nNobitex\nBit24\nExcoino\nRamzinex', style: TextStyle(fontFamily: 'Sora', fontSize: 10, height: 1.6, color: Color(0xFF424242)))),
            const Positioned(left: 17, right: 12, top: 328, height: 14, child: Text('Important Guidelines', style: TextStyle(fontFamily: 'Sora', fontSize: 10, fontWeight: FontWeight.w600, height: 1.4, color: AppColors.ink))),
            const Positioned(left: 17, right: 12, top: 346, height: 126, child: Text('Transactions involving these high-risk platforms may lead to restrictions on your Davochain account.\nAlways verify the legitimacy of the recipient or platform before completing any transaction.\nDo not engage in transfers with unverified or sanctioned services to keep your funds safe.\nIf you’re unsure about a transaction, please contact Davochain support for assistance.', style: TextStyle(fontFamily: 'Sora', fontSize: 10, height: 1.4, color: Color(0xFF424242)))),
            Positioned(left: 17, right: 12, top: 530, child: _Button(label: 'I Understand', onTap: () => Navigator.pop(context, true))),
          ],
        ),
      );
}

class CancelReminderSheet extends StatelessWidget {
  const CancelReminderSheet({super.key});
  @override
  Widget build(BuildContext context) => Container(
        height: 229,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(38, 24, 38, 16),
          child: Column(
            children: [
              const SizedBox(height: 22, child: Center(child: Text('Reminder', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w400, height: 1.35, color: AppColors.ink)))),
              const SizedBox(height: 12),
              const SizedBox(height: 19, child: Center(child: Text('Do you want to cancel this payment', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w400, height: 1.35, color: Color(0xFF424242))))),
              const SizedBox(height: 24),
              _Button(label: 'Continue to Pay', fontWeight: FontWeight.w700, onTap: () => Navigator.pop(context, false)),
              const SizedBox(height: 16),
              _Secondary(label: 'Cancel', fontWeight: FontWeight.w700, background: const Color(0xFFEFF4FE), onTap: () => Navigator.pop(context, true)),
            ],
          ),
        ),
      );
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
  @override
  void dispose() { amount.dispose(); super.dispose(); }
  bool get convert => widget.mode == TradeMode.convert;
  double get balance => widget.asset == BuyCryptoAsset.bitcoin ? .33048 : 5;
  double get enteredAmount => double.tryParse(amount.text) ?? 0;

  void _switchMode(TradeMode mode) {
    FocusScope.of(context).unfocus();
    Navigator.pushReplacement(context, AppPageRoute<void>(builder: (_) =>
      TradeAmountScreen(mode: mode, asset: widget.asset)));
  }

  void _pickPercent(String label) {
    final fraction = label == 'Max' ? 1.0 : double.parse(label.replaceAll('%', '')) / 100;
    HapticFeedback.selectionClick();
    amount.text = (balance * fraction).toStringAsFixed(8).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
    amount.selection = TextSelection.collapsed(offset: amount.text.length);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final n = enteredAmount;
    final active = n > 0 && n <= balance;
    final ngn = n * widget.asset.ngnPerUnit;
    return TradeFormLayout(
      header: _ExactCryptoTradeHeader(title: convert ? 'Swap' : 'Sell', onBack: () => Navigator.pop(context)),
      tabs: _Tabs(active: convert ? 2 : 1,
        onBuy: () {
          FocusScope.of(context).unfocus();
          Navigator.pushReplacement(context, AppPageRoute<void>(builder: (_) =>
            BuyAmountScreen(initialOrder: BuyCryptoOrder(asset: widget.asset, wallet: BuyFundingWallet.ngd, ngnAmount: 0))));
        },
        onSell: () { if (convert) _switchMode(TradeMode.sell); },
        onConvert: () { if (!convert) _switchMode(TradeMode.convert); }),
      content: Column(children: [
        if (convert) ...[
          _ExactSwapBox(from: true, asset: widget.asset, balance: balance, value: n, controller: amount, onChanged: () => setState(() {})),
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Icon(Icons.arrow_downward_rounded, color: AppColors.primary)),
          _ExactSwapBox(from: false, asset: widget.asset == BuyCryptoAsset.tether ? BuyCryptoAsset.bitcoin : BuyCryptoAsset.tether, balance: widget.asset == BuyCryptoAsset.tether ? .33048 : 25040.27, value: ngn / (widget.asset == BuyCryptoAsset.tether ? BuyCryptoAsset.bitcoin.ngnPerUnit : BuyCryptoAsset.tether.ngnPerUnit)),
          const SizedBox(height: 16),
          const Align(alignment: Alignment.centerLeft, child: Text('Estimated fee: Free', style: TextStyle(fontSize: 12, color: AppColors.bodyMuted))),
        ] else ...[
          _AssetBalance(asset: widget.asset),
          const SizedBox(height: 24),
          _Amount(controller: amount, suffix: widget.asset.symbol, onChanged: () => setState(() {})),
          const SizedBox(height: 20),
          Text('₦${ngn.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.ink)),
        ],
        const SizedBox(height: 12),
        Text('1 ${widget.asset.symbol} ≈ ₦${widget.asset.ngnPerUnit.toStringAsFixed(2)}', textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: AppColors.bodyMuted)),
        const SizedBox(height: 24),
        Wrap(spacing: 12, runSpacing: 8, alignment: WrapAlignment.center,
          children: ['10%', '25%', '50%', '75%', 'Max'].map((v) => _Percent(label: v, onTap: () => _pickPercent(v))).toList()),
        if (n > balance) const Padding(padding: EdgeInsets.only(top: 16), child:
          Text('Amount exceeds your available balance.', style: TextStyle(color: AppColors.danger))),
      ]),
      action: _Button(label: convert ? 'Preview' : 'Continue', enabled: active, onTap: () {
        FocusScope.of(context).unfocus();
        Navigator.push(context, AppPageRoute<void>(builder: (_) =>
          TradeReviewScreen(kind: convert ? TxKind.conversion : TxKind.sell, amount: n)));
      }),
    );
  }
}

class TradeReviewScreen extends StatelessWidget {
  const TradeReviewScreen({super.key, required this.kind, required this.amount});
  final TxKind kind;
  final double amount;

  @override
  Widget build(BuildContext context) {
    final conv = kind == TxKind.conversion;
    final headerTop = conv ? 27.0 : 16.0;
    final pairTop = conv ? 87.0 : 76.0;
    final summaryTop = conv ? 301.0 : 290.0;
    final buttonTop = conv ? 678.0 : 661.0;
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(left: 0, right: 0, top: headerTop, height: 40, child: _ExactCryptoTradeHeader(title: conv ? 'Review Conversion' : 'Sell', onBack: () => Navigator.pop(context))),
            Positioned(
              left: 16,
              right: 16,
              top: pairTop,
              height: 193,
              child: _Pair(
                conversion: conv,
                firstLabel: conv ? 'You are converting' : 'You are Selling',
                firstPrimary: amount.toStringAsFixed(5),
                firstSecondary: r'$500.00',
                secondLabel: 'To (You will receive)',
                secondPrimary: conv ? '500.00' : '₦731,540.00',
                secondSecondary: conv ? r'$498.00' : 'Nigerian Naira',
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              top: summaryTop,
              height: 192,
              child: _ExactTradeSummary(
                conversion: conv,
                rows: conv
                    ? const [('Exchange Rate', '1 USDT   0.0000345 BTC', false), ('Network Fee', 'Free', true), ('Total Amount', '500.00\n\$498.00', false)]
                    : const [('Exchange Rate', '1 USDT   ₦1,540.00', false), ('Network Fee', 'Free', true), ('Total Received', '₦731,540.00', false)],
              ),
            ),
            Positioned(left: 16, right: 16, top: buttonTop, height: 48, child: _Button(label: conv ? 'Confirm conversion' : 'Confirm', onTap: () => Navigator.pushReplacement(context, AppPageRoute<void>(builder: (_) => TransactionProgressScreen(kind: kind, target: conv ? 'USDT' : 'NGN', amount: amount))))),
          ],
        ),
      ),
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
          Positioned(left: 6, top: 4, width: 32, height: 32, child: InkResponse(onTap: onBack, child: Image.asset('$_f/buy_back.png', width: 32, height: 32))),
          Positioned.fill(child: Center(child: Text(title, style: const TextStyle(fontFamily: 'Sora', fontSize: 20, fontWeight: FontWeight.w400, height: 1.35, color: AppColors.ink)))),
        ],
      );
}

class _ExactSwapBox extends StatelessWidget {
  const _ExactSwapBox({required this.from, required this.asset, required this.balance, required this.value, this.controller, this.onChanged});
  final bool from;
  final BuyCryptoAsset asset;
  final double balance, value;
  final TextEditingController? controller;
  final VoidCallback? onChanged;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.mutedSoft)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(from ? 'From' : 'To', style: const TextStyle(fontSize: 12, color: AppColors.bodyMuted)),
      const SizedBox(height: 8),
      Row(children: [
        Image.asset(_asset(asset), width: 24, height: 24), const SizedBox(width: 8),
        Text(asset.symbol, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(width: 16),
        Expanded(child: from ? TextField(
          controller: controller, onChanged: (_) => onChanged?.call(),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
          textAlign: TextAlign.right,
          decoration: const DavoInlineInputDecoration(hintText: '0.00'),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ) : Text(value.toStringAsFixed(2), textAlign: TextAlign.right, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600))),
      ]),
      const SizedBox(height: 8),
      Text('Available: $balance ${asset.symbol}', style: const TextStyle(fontSize: 12, color: AppColors.bodyMuted)),
    ]),
  );
}

class _ExactTradeSummary extends StatelessWidget {
  const _ExactTradeSummary({required this.rows, required this.conversion});
  final List<(String, String, bool)> rows;
  final bool conversion;
  @override
  Widget build(BuildContext context) => Container(
        height: 192,
        decoration: BoxDecoration(
          color: conversion ? const Color(0xFFFBFBFD) : Colors.white,
          borderRadius: BorderRadius.circular(conversion ? 0 : 8),
        ),
        child: Stack(
          children: List.generate(rows.length, (i) {
            final row = rows[i];
            final top = (conversion ? 24.0 : 31.5) + (i * 47.0);
            return Positioned(
              left: 15,
              right: 15,
              top: top,
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(row.$1, style: const TextStyle(fontFamily: 'Sora', fontSize: 14, height: 1.35, color: AppColors.bodyMuted)),
                      const Spacer(),
                      Flexible(child: Text(row.$2, textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Sora', fontSize: 14, height: 1.35, color: row.$3 ? AppColors.primary : AppColors.ink))),
                    ],
                  ),
                  if (i != rows.length - 1) ...[const SizedBox(height: 15), const Divider(height: 1, thickness: .5, color: Color(0xFFF2F2F2))],
                ],
              ),
            );
          }),
        ),
      );
}

class DepositStatusScreen extends StatelessWidget {
  const DepositStatusScreen({super.key, required this.success});
  final bool success;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(child: Column(children: [
      _TopBar(title: 'Deposit Details', onBack: () => Navigator.pop(context), height: 48, fontSize: 20),
      Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        const SizedBox(height: 24),
        const Text('Quantity', style: TextStyle(fontSize: 16, color: AppColors.bodyMuted)),
        const SizedBox(height: 8),
        const Text('0.0317934 BTC', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Text(success ? 'Deposit Successful' : 'Pending', style: TextStyle(color: success ? const Color(0xFF1BA44D) : const Color(0xFFCC8408))),
        const SizedBox(height: 24),
        Text(success ? 'Crypto has arrived in your Davochain account. View your wallet balance for more details.' : 'Your deposit is awaiting network confirmation.',
          textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.bodyMuted)),
        const SizedBox(height: 24),
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFF5F6F9), borderRadius: BorderRadius.circular(12)),
          child: const Column(children: [
            _ExactTransactionRow(label: 'Network', value: 'BTC'),
            SizedBox(height: 20),
            _ExactTransactionRow(label: 'Time', value: '2026-05-02 22:36:58', maxLines: 2),
            SizedBox(height: 20),
            _ExactTransactionRow(label: 'Deposit Address', value: '1ChGMXGfgy2tdoE4rVQEqouRpBQaAA6zLZ', maxLines: 4, copy: true),
            SizedBox(height: 20),
            _ExactTransactionRow(label: 'Transaction Hash', value: '7c0d217aca078b46197d9283d7b818311de96eae39deddfea593303815d04c35', maxLines: 6, copy: true),
            SizedBox(height: 20),
            _BlockchainExplorerRow(),
          ])),
      ]))),
    ])),
  );
}

class _Scaffold extends StatelessWidget {
  const _Scaffold({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        body: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 16), child: child)),
      );
}

class _FigmaFullScaffold extends StatelessWidget {
  const _FigmaFullScaffold({required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF8F9FB),
        body: SafeArea(bottom: false, child: Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 0), child: child)),
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
            Align(alignment: Alignment.centerLeft, child: IconButton(tooltip: 'Back', onPressed: onBack, icon: Image.asset('$_f/buy_back.png', width: 24, height: 24))),
            if (title.isNotEmpty) Padding(padding: const EdgeInsets.symmetric(horizontal: 48), child: Text(title, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: 'Sora', fontSize: fontSize, fontWeight: fontWeight, height: 1.35, color: AppColors.ink))),
          ],
        ),
      );
}

class _AssetButton extends StatelessWidget {
  const _AssetButton({required this.asset, required this.size, required this.onTap});
  final String asset;
  final double size;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkResponse(
        onTap: () { HapticFeedback.selectionClick(); onTap(); },
        radius: 24,
        child: SizedBox(width: 36, height: 36, child: Center(child: Image.asset(asset, width: size, height: size))),
      );
}

class _Button extends StatelessWidget {
  const _Button({required this.label, this.enabled = true, required this.onTap, this.fontWeight = FontWeight.w600, this.disabledColor = AppColors.primaryDisabled, this.disabledTextColor = Colors.white});
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  final FontWeight fontWeight;
  final Color disabledColor;
  final Color disabledTextColor;
  @override
  Widget build(BuildContext context) => Material(
        color: enabled ? AppColors.primary : disabledColor,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(
          onTap: enabled ? () { HapticFeedback.lightImpact(); onTap(); } : null,
          borderRadius: BorderRadius.circular(4),
          child: SizedBox(height: 48, width: double.infinity, child: Center(child: Text(label, style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: fontWeight, color: enabled ? Colors.white : disabledTextColor)))),
        ),
      );
}

class _Secondary extends StatelessWidget {
  const _Secondary({required this.label, required this.onTap, this.fontWeight = FontWeight.w600, this.background = const Color(0xFFEAF0FB)});
  final String label;
  final VoidCallback onTap;
  final FontWeight fontWeight;
  final Color background;
  @override
  Widget build(BuildContext context) => Material(
        color: background,
        borderRadius: BorderRadius.circular(4),
        child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(4), child: SizedBox(height: 48, width: double.infinity, child: Center(child: Text(label, style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: fontWeight, color: AppColors.primary))))),
      );
}

class _Row extends StatelessWidget{const _Row({required this.label,required this.value,this.valueColor,this.last=false}) : copy = false;final String label,value;final Color? valueColor;final bool copy,last;@override Widget build(BuildContext context)=>Container(constraints:const BoxConstraints(minHeight:47),decoration:last?null:const BoxDecoration(border:Border(bottom:BorderSide(color:Color(0xFFF2F2F2),width:.6))),child:Row(children:[Text(label,style:const TextStyle(fontFamily:'Sora',fontSize:14,color:AppColors.bodyMuted)),const Spacer(),Flexible(child:Text(value,textAlign:TextAlign.right,style:TextStyle(fontFamily:'Sora',fontSize:14,color:valueColor??AppColors.ink))),if(copy)...[const SizedBox(width:8),GestureDetector(onTap:()=>Clipboard.setData(ClipboardData(text:value)),child:Image.asset('$_f/buy_copy.png',width:16,height:16))]]));}
class _Summary extends StatelessWidget{const _Summary({required this.children});final List<Widget> children;@override Widget build(BuildContext context)=>Container(width:double.infinity,padding:const EdgeInsets.symmetric(horizontal:16,vertical:10),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(8)),child:Column(children:children));}
class _Choice extends StatelessWidget {
  const _Choice({required this.asset, required this.title, required this.subtitle, required this.onTap});
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
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFEEF0F5)), borderRadius: BorderRadius.circular(4)),
            child: Stack(
              children: [
                Positioned(
                  left: 12,
                  top: 17.5,
                  width: 40,
                  height: 40,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: const Color(0xFFF0F3FA), borderRadius: BorderRadius.circular(4)),
                    child: Image.asset(asset, width: 24, height: 24, fit: BoxFit.contain),
                  ),
                ),
                Positioned(left: 60, top: 12, child: Text(title, style: const TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600, height: 1.35, color: AppColors.ink))),
                Positioned(left: 60, right: 54, top: 33, height: 30, child: Text(subtitle, style: const TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.25, color: AppColors.bodyMuted))),
                Positioned(right: 12, top: 29.5, width: 16, height: 16, child: Image.asset('$_cf/chevron_right.png', width: 16, height: 16)),
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
            Positioned(left: 0, top: 0, width: 40, height: 40, child: ClipOval(child: Image.asset('$_f/profile_avatar.png', width: 40, height: 40, fit: BoxFit.cover))),
            const Positioned(left: 52, top: 2, width: 61, height: 15, child: Text('Welcome,', style: TextStyle(fontFamily:'Sora',fontSize:12,height:1.25,color:AppColors.muted))),
            const Positioned(left: 52, top: 19, width: 61, height: 19, child: Text('Callie', style: TextStyle(fontFamily:'Sora',fontSize:14,fontWeight:FontWeight.w600,height:1.35,color:AppColors.body))),
            Positioned(
              left: 225,
              top: 4,
              width: 89,
              height: 32,
              child: Container(
                decoration: BoxDecoration(color: AppColors.primaryDisabled.withValues(alpha: .5), borderRadius: BorderRadius.circular(1000)),
                child: Stack(
                  children: [
                    Positioned(left: 8, top: 4, width: 24, height: 24, child: Image.asset('$_exact/naira_earn_gift_exact.png', width: 24, height: 24, fit: BoxFit.contain)),
                    const Positioned(left: 36, top: 8.5, width: 45, height: 15, child: Text('Earn \$5', style: TextStyle(fontFamily:'Sora',fontSize:12,height:1.25,color:AppColors.primary))),
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
                decoration: BoxDecoration(color: AppColors.primaryDisabled.withValues(alpha: .5), borderRadius: BorderRadius.circular(1000)),
                alignment: Alignment.center,
                child: Image.asset('$_exact/icon_notifications.png', width: 24, height: 24, fit: BoxFit.contain),
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
        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            Positioned(right: 0, bottom: 0, width: 268, height: 94, child: Image.asset('$_f/balance_wave.png', fit: BoxFit.fill)),
            const Positioned(left: 16, top: 31, width: 140, height: 16, child: Text('Available Balance', style: TextStyle(fontFamily:'Sora',fontSize:10,fontWeight:FontWeight.w500,height:1.3,color:Color(0xFFEEF0F5)))),
            Positioned(left: 155, top: 32.5, width: 10, height: 10, child: Image.asset('$_exact/crypto_eye_exact.png', width: 10, height: 10, fit: BoxFit.contain)),
            const Positioned(left: 16, top: 52, width: 300, height: 36, child: Text('₦1,284,500.35', style: TextStyle(fontFamily:'Sora',fontSize:24,fontWeight:FontWeight.w700,height:1.35,color:Color(0xFFF8F9FB)))),
            const Positioned(left: 16, top: 86, width: 200, height: 22, child: Text('≈ \$842.31 USD', style: TextStyle(fontFamily:'Sora',fontSize:14,height:1.35,color:Color(0xFFF8F9FB)))),
          ],
        ),
      );
}

class _CryptoBalance extends StatelessWidget {
  const _CryptoBalance();

  @override
  Widget build(BuildContext context) => Container(
        height: 93,
        width: double.infinity,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
        child: Stack(
          children: [
            const Positioned(left: 16, top: 16, width: 75, height: 13, child: Text('Wallet Balance', style: TextStyle(fontFamily: 'Sora', fontSize: 10, fontWeight: FontWeight.w500, height: 1.3, color: AppColors.bodyMuted))),
            const Positioned(right: 31, top: 16, width: 71, height: 13, child: Text('Change Asset', style: TextStyle(fontFamily: 'Sora', fontSize: 10, height: 1.3, color: AppColors.bodyMuted))),
            Positioned(right: 16, top: 16.5, width: 12, height: 12, child: Image.asset('$_cf/chevron_right.png', width: 12, height: 12, fit: BoxFit.contain)),
            Positioned(
              left: 16,
              top: 43,
              width: 32,
              height: 32,
              child: Container(
                alignment: Alignment.center,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Image.asset('$_f/btc.png', width: 20, height: 21, fit: BoxFit.contain),
              ),
            ),
            const Positioned(left: 57, top: 41, width: 52, height: 19, child: Text('Bitcoin', style: TextStyle(fontFamily: 'Sora', fontSize: 14, height: 1.35, color: AppColors.ink))),
            const Positioned(left: 57, top: 62, width: 25, height: 15, child: Text('BTC', style: TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.25, color: AppColors.body))),
            const Positioned(right: 16, top: 41.5, width: 89, height: 19, child: Text('0.0300 BTC', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Sora', fontSize: 14, fontWeight: FontWeight.w600, height: 1.35, color: AppColors.ink))),
            const Positioned(right: 16, top: 61.5, width: 77, height: 15, child: Text('\$842.31 USD', textAlign: TextAlign.right, style: TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.25, color: AppColors.bodyMuted))),
          ],
        ),
      );
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.active, required this.onBuy, required this.onSell, required this.onConvert});
  final int active;
  final VoidCallback onBuy, onSell, onConvert;
  @override
  Widget build(BuildContext context) {
    final callbacks = [onBuy, onSell, onConvert];
    const labels = ['Buy', 'Sell', 'Swap'];
    return Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: const Color(0xFFF3F3F9), borderRadius: BorderRadius.circular(999)),
      child: Row(children: List.generate(3, (i) => Expanded(child: Semantics(selected: active == i,
        child: Material(color: active == i ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(999),
          child: InkWell(onTap: callbacks[i], borderRadius: BorderRadius.circular(999),
            child: Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Center(child: Text(labels[i],
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: active == i ? AppColors.primary : AppColors.body)))))))))));
  }
}
class _AssetBalance extends StatelessWidget {
  const _AssetBalance({required this.asset});
  final BuyCryptoAsset asset;
  @override
  Widget build(BuildContext context) => Column(children: [
    Image.asset(_asset(asset), width: 40, height: 40),
    const SizedBox(height: 12),
    const Text('Available Balance', style: TextStyle(fontSize: 12, color: AppColors.body)),
    const SizedBox(height: 4),
    Text('${asset == BuyCryptoAsset.bitcoin ? '0.33048' : '5.00'} ${asset.symbol}',
      textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
  ]);
}
class _Amount extends StatelessWidget {
  const _Amount({required this.controller, required this.suffix, required this.onChanged});
  final TextEditingController controller;
  final String suffix;
  final VoidCallback onChanged;
  @override
  Widget build(BuildContext context) => Container(
    height: 77, padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(color: Colors.white, border: Border.all(color: AppColors.mutedSoft), borderRadius: BorderRadius.circular(8)),
    child: Row(children: [
      Expanded(child: TextField(controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        onChanged: (_) => onChanged(),
        decoration: const DavoInlineInputDecoration(hintText: '0.00'),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.ink))),
      const SizedBox(width: 12),
      Text(suffix, style: const TextStyle(fontSize: 14, color: AppColors.body)),
    ]),
  );
}
class _Percent extends StatelessWidget {
  const _Percent({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(8),
    child: Container(width: 48, height: 44, alignment: Alignment.center,
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFEEF0F5)), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(fontSize: 12, color: label == 'Max' ? AppColors.primary : AppColors.body))));
}
class _Pair extends StatelessWidget {
  const _Pair({
    required this.conversion,
    required this.firstLabel,
    required this.firstPrimary,
    required this.firstSecondary,
    required this.secondLabel,
    required this.secondPrimary,
    required this.secondSecondary,
  });

  final bool conversion;
  final String firstLabel, firstPrimary, firstSecondary, secondLabel, secondPrimary, secondSecondary;

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 92,
            child: _PairBox(
              label: firstLabel,
              primary: firstPrimary,
              secondary: firstSecondary,
              asset: '$_f/btc.png',
              rightSymbol: conversion ? 'BTC' : null,
              radius: conversion ? 4 : 6,
              conversion: conversion,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 101,
            height: 92,
            child: _PairBox(
              label: secondLabel,
              primary: secondPrimary,
              secondary: secondSecondary,
              asset: conversion ? '$_f/usdt.png' : '$_f/buy_nigeria.png',
              rightSymbol: conversion ? 'USDT' : null,
              radius: conversion ? 4 : 6,
              conversion: conversion,
              nigeria: !conversion,
            ),
          ),
          Positioned(
            left: 159,
            top: 78,
            width: 40,
            height: 40,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Color(0xFFF4F7FF), shape: BoxShape.circle),
              child: Image.asset(conversion ? '$_cf/swap.png' : '$_f/buy_exchange_down.png', width: 24, height: 24, fit: BoxFit.contain),
            ),
          ),
        ],
      );
}

class _PairBox extends StatelessWidget {
  const _PairBox({
    required this.label,
    required this.primary,
    required this.secondary,
    required this.asset,
    required this.radius,
    required this.conversion,
    this.rightSymbol,
    this.nigeria = false,
  });

  final String label, primary, secondary, asset;
  final String? rightSymbol;
  final double radius;
  final bool conversion;
  final bool nigeria;

  @override
  Widget build(BuildContext context) => Container(
        height: 92,
        width: double.infinity,
        decoration: BoxDecoration(
          color: conversion ? const Color(0xFFFBFBFD) : Colors.white,
          border: Border.all(color: const Color(0xFFF5F6F9)),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: Stack(
          children: [
            Positioned(left: 16, top: 14, child: Text(label, style: const TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.25, color: AppColors.bodyMuted))),
            Positioned(
              left: nigeria ? 18 : 16,
              top: 44.5,
              width: 32,
              height: 32,
              child: nigeria
                  ? ClipOval(child: Image.asset(asset, width: 32, height: 32, fit: BoxFit.cover))
                  : Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: Image.asset(asset, width: 20, height: 20, fit: BoxFit.contain),
                    ),
            ),
            Positioned(
              left: nigeria ? 62 : 54,
              top: 41,
              child: Text(primary, style: TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w600, height: 1.35, color: conversion ? AppColors.ink : AppColors.body)),
            ),
            if (nigeria)
              Positioned(left: 62, top: 66, child: Text(secondary, style: const TextStyle(fontFamily: 'Sora', fontSize: 10, height: 1.3, color: AppColors.bodyMuted)))
            else ...[
              const Positioned(left: 54, top: 65.5, child: Text('≈', style: TextStyle(fontFamily: 'Sora', fontSize: 12, height: 1.0, color: AppColors.bodyMuted))),
              Positioned(left: 72, top: 66, child: Text(secondary, style: const TextStyle(fontFamily: 'Sora', fontSize: 10, height: 1.3, color: AppColors.bodyMuted))),
            ],
            if (rightSymbol != null)
              Positioned(right: 16, top: 35, child: Text(rightSymbol!, style: const TextStyle(fontFamily: 'Sora', fontSize: 16, fontWeight: FontWeight.w600, height: 1.35, color: AppColors.ink))),
          ],
        ),
      );
}
String _asset(BuyCryptoAsset a)=>switch(a){BuyCryptoAsset.bitcoin=>'$_f/btc.png',BuyCryptoAsset.ethereum=>'$_f/eth.png',BuyCryptoAsset.solana=>'$_f/sol.png',BuyCryptoAsset.tether=>'$_f/usdt.png'};
String _short(String v)=>v.length<=16?v:'${v.substring(0,6)}......${v.substring(v.length-6)}';
