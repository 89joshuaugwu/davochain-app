import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/theme/app_theme.dart';
import '../../buy_crypto/presentation/buy_crypto_models.dart';
import '../../buy_crypto/presentation/buy_crypto_widgets.dart';

const _f = 'assets/images/figma';
const _cf = 'assets/images/figma/crypto_full';

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
  Widget build(BuildContext context) => _Sheet(
    title: 'Select Wallet', height: 476,
    child: Column(children: [
      _SheetRow(asset: '$_cf/plus_circle.png', title: 'Add crypto asset', bold: true, onTap: () => Navigator.pop(context, _WithdrawWallet.crypto)),
      _SheetRow(leading: ClipOval(child: Image.asset('$_f/buy_nigeria.png', width: 32, height: 32)), title: 'Nigeria Naira', subtitle: 'NGN', onTap: () => Navigator.pop(context, _WithdrawWallet.naira)),
      _SheetRow(asset: '$_f/btc.png', title: 'Bitcoin', subtitle: 'BTC', onTap: () => Navigator.pop(context, _WithdrawWallet.crypto)),
      _SheetRow(asset: '$_f/eth.png', title: 'Ethereum', subtitle: 'ETH', onTap: () => Navigator.pop(context, _WithdrawWallet.crypto)),
      _SheetRow(asset: '$_f/sol.png', title: 'Solana', subtitle: 'SOL', onTap: () => Navigator.pop(context, _WithdrawWallet.crypto)),
      _SheetRow(asset: '$_f/usdt.png', title: 'Tether', subtitle: 'USDT', onTap: () => Navigator.pop(context, _WithdrawWallet.crypto)),
    ]),
  );
}

class _SellWalletSheet extends StatelessWidget {
  const _SellWalletSheet();
  @override
  Widget build(BuildContext context) => _Sheet(
    title: 'Select wallet to sell into', height: 220,
    child: _SheetRow(
      leading: ClipOval(child: Image.asset('$_f/buy_nigeria.png', width: 32, height: 32)),
      title: 'Nigerian Naira', subtitle: 'NGN', trailing: const _BalanceText(top: '0.00 USD', bottom: '0.00₦'),
      onTap: () => Navigator.pop(context, true),
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
    return _Scaffold(child: Column(children:[
      const _DashboardHeader(), const SizedBox(height:16), const _BalanceCard(), const SizedBox(height:24),
      _Field(label:'Amount', child:TextField(controller:amount,keyboardType:TextInputType.number,onChanged:(_)=>setState((){}),decoration:const InputDecoration.collapsed(hintText:'0'),style:const TextStyle(fontFamily:'Sora',fontSize:16))),
      const SizedBox(height:10), const Align(alignment:Alignment.centerLeft,child:Text('Max daily amount - ₦5,000,000',style:TextStyle(fontFamily:'Sora',fontSize:12,color:AppColors.body))),
      const SizedBox(height:24),
      _Field(label:'Payment Method',onTap:_payment,trailing:Image.asset('$_cf/chevron_right.png',width:16),child:Text(account?.bank??'Select a payment method',style:TextStyle(fontFamily:'Sora',fontSize:16,color:account==null?AppColors.muted:AppColors.ink))),
      const Spacer(), _Button(label:'Continue',enabled:ready,onTap:_review),
    ]));
  }
  Future<void> _payment() async {
    final value=await showModalBottomSheet<BankAccount>(context:context,isScrollControlled:true,backgroundColor:Colors.transparent,builder:(_)=>_PaymentSheet(current:account));
    if(mounted&&value!=null)setState(()=>account=value);
  }
  Future<void> _review() async {
    if(account==null)return;
    final ok=await showModalBottomSheet<bool>(context:context,isScrollControlled:true,backgroundColor:Colors.transparent,barrierColor:Colors.black.withValues(alpha: .4),builder:(_)=>_NairaConfirm(amount:amount.text,account:account!));
    if(!mounted||ok!=true)return;
    final pin=await Navigator.push<bool>(context,AppPageRoute<bool>(builder:(_)=>const CryptoPinScreen()));
    if(!mounted||pin!=true)return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Submitted Successfully'),behavior:SnackBarBehavior.floating));
    Navigator.pop(context);
  }
}

class BankAccount { const BankAccount(this.bank,this.number,this.name); final String bank,number,name; }

class _PaymentSheet extends StatelessWidget {
  const _PaymentSheet({this.current}); final BankAccount? current;
  @override Widget build(BuildContext context)=>_Sheet(title:'Select a payment method',height:300,child:Column(children:[
    _SheetRow(asset:'$_cf/plus_circle.png',title:'Add new payment method',bold:true,trailing:Image.asset('$_cf/chevron_right.png',width:16),onTap:()async{final a=await Navigator.push<BankAccount>(context,AppPageRoute<BankAccount>(builder:(_)=>const AddBankScreen()));if(context.mounted&&a!=null)Navigator.pop(context,a);}),
    _SheetRow(asset:'$_cf/bank.png',title:current?.bank??'Access Bank',subtitle:current==null?'•••• 6675':'•••• ${current!.number.substring(current!.number.length-4)}',trailing:Image.asset('$_cf/chevron_right.png',width:16),onTap:()=>Navigator.pop(context,current??const BankAccount('Access Bank','0589626675','Callietus Ezeike Chinecherem'))),
  ]));
}

class AddBankScreen extends StatefulWidget { const AddBankScreen({super.key}); @override State<AddBankScreen> createState()=>_AddBankScreenState(); }
class _AddBankScreenState extends State<AddBankScreen>{
  String? bank; final number=TextEditingController();
  @override void dispose(){number.dispose();super.dispose();}
  @override Widget build(BuildContext context){final valid=bank!=null&&number.text.length>=10;return _Scaffold(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    _TopBar(title:'Add a Bank Account',onBack:()=>Navigator.pop(context)), const SizedBox(height:24),
    const Text('Add your bank account to receive money fast\nand secured easily',style:TextStyle(fontFamily:'Sora',fontSize:14,height:1.35,color:AppColors.body)), const SizedBox(height:28),
    _ValueField(label:'Bank Name',value:bank??'Select bank name',muted:bank==null,onTap:_chooseBank), const SizedBox(height:16),
    _Field(label:'Account Number',child:TextField(controller:number,keyboardType:TextInputType.number,onChanged:(_)=>setState((){}),decoration:const InputDecoration.collapsed(hintText:'Enter account number'),style:const TextStyle(fontFamily:'Sora',fontSize:14))), const SizedBox(height:16),
    _ValueField(label:'Account Name',value:valid?'Callietus Ezeike Chinecherem':'auto',muted:!valid), const Spacer(),
    _Button(label:'Save Account',enabled:valid,onTap:()=>Navigator.pop(context,BankAccount(bank!,number.text,'Callietus Ezeike Chinecherem'))),
  ]));}
  Future<void> _chooseBank() async {final b=await showModalBottomSheet<String>(context:context,isScrollControlled:true,backgroundColor:Colors.transparent,builder:(_)=>const _BankSheet());if(mounted&&b!=null)setState(()=>bank=b);}
}

class _BankSheet extends StatelessWidget { const _BankSheet(); static const banks=['AAA Finance','AB Microfinance Bank','Access Bank','Fidelity Bank','First Bank','GTBank','Kuda Bank','Moniepoint','Opay'];
  @override Widget build(BuildContext context)=>_Sheet(title:'Select Bank',height:MediaQuery.sizeOf(context).height*.78,child:Column(children:[
    Container(height:48,padding:const EdgeInsets.symmetric(horizontal:14),decoration:BoxDecoration(color:Colors.white,border:Border.all(color:AppColors.mutedSoft),borderRadius:BorderRadius.circular(6)),child:const Row(children:[Text('⌕',style:TextStyle(fontSize:22,color:AppColors.bodyMuted)),SizedBox(width:10),Text('Search for a bank',style:TextStyle(fontFamily:'Sora',fontSize:14,color:AppColors.muted))])),const SizedBox(height:10),
    Expanded(child:ListView(children:banks.map((b)=>_SheetRow(asset:'$_cf/bank.png',title:b,onTap:()=>Navigator.pop(context,b))).toList())),
  ]));
}

class _NairaConfirm extends StatelessWidget { const _NairaConfirm({required this.amount,required this.account}); final String amount; final BankAccount account;
  @override Widget build(BuildContext context)=>_Sheet(title:'Confirm Withdrawal',height:390,child:Column(children:[
    _Row(label:'Amount',value:'₦$amount'),_Row(label:'Bank',value:account.bank),_Row(label:'Account Number',value:account.number),_Row(label:'Name',value:account.name),const _Row(label:'Fee',value:'₦100.00',valueColor:AppColors.primary,last:true),const Spacer(),_Button(label:'Confirm Withdrawal',onTap:()=>Navigator.pop(context,true)),
  ]));
}

class CryptoWithdrawModeScreen extends StatelessWidget { const CryptoWithdrawModeScreen({super.key});
  @override Widget build(BuildContext context)=>_Scaffold(child:Column(children:[
    _TopBar(title:'Crypto Withdraw Mode',onBack:()=>Navigator.pop(context)),const SizedBox(height:22),
    _Choice(asset:'$_cf/user_circle.png',title:'To Davochain User',subtitle:'Send Crypto to another Davochain\nuser instantly at zero fees',onTap:()=>Navigator.push(context,AppPageRoute<void>(builder:(_)=>const CryptoWithdrawEntryScreen(external:false)))),const SizedBox(height:16),
    _Choice(asset:'$_cf/qr_wallet.png',title:'Wallet Address',subtitle:'Send crypto to an external wallet,\nnetwork fee applies',onTap:()=>Navigator.push(context,AppPageRoute<void>(builder:(_)=>const CryptoWithdrawEntryScreen(external:true)))),
  ]));
}

class CryptoWithdrawEntryScreen extends StatefulWidget { const CryptoWithdrawEntryScreen({super.key,required this.external}); final bool external; @override State<CryptoWithdrawEntryScreen> createState()=>_CryptoWithdrawEntryScreenState(); }
class _CryptoWithdrawEntryScreenState extends State<CryptoWithdrawEntryScreen>{
  final target=TextEditingController(), amount=TextEditingController(); String? network;
  @override void dispose(){target.dispose();amount.dispose();super.dispose();}
  @override Widget build(BuildContext context){final ready=target.text.isNotEmpty&&amount.text.isNotEmpty&&(!widget.external||network!=null);return PopScope(canPop:false,onPopInvokedWithResult:(_,__)=>_cancel(),child:_Scaffold(child:Column(children:[
    _TopBar(title:'Withdraw',onBack:_cancel),const SizedBox(height:20),const _CryptoBalance(),const SizedBox(height:24),
    _Field(label:widget.external?'Address':'Transfer To',trailing:widget.external?GestureDetector(onTap:_scan,child:Image.asset('$_cf/qr_wallet.png',width:20)):null,child:TextField(controller:target,onChanged:(_)=>setState((){}),decoration:InputDecoration.collapsed(hintText:widget.external?'Paste the wallet address':'Enter Davochain username'),style:const TextStyle(fontFamily:'Sora',fontSize:12))),
    if(widget.external)...[const SizedBox(height:16),_ValueField(label:'Network',value:network??'Select network',muted:network==null,onTap:_network)],
    const SizedBox(height:16),_Field(label:'Amount',child:TextField(controller:amount,keyboardType:const TextInputType.numberWithOptions(decimal:true),onChanged:(_)=>setState((){}),decoration:const InputDecoration.collapsed(hintText:'Enter BTC amount'),style:const TextStyle(fontFamily:'Sora',fontSize:14))),
    const SizedBox(height:10),const Align(alignment:Alignment.centerLeft,child:Text('Available  0.0300 BTC',style:TextStyle(fontFamily:'Sora',fontSize:10,color:AppColors.bodyMuted))),const Spacer(),_Button(label:'Confirm',enabled:ready,onTap:_confirm),
  ])));}
  Future<void> _cancel() async{final c=await showDialog<bool>(context:context,builder:(_)=>const CancelReminderDialog());if(mounted&&c==true)Navigator.pop(context);}
  Future<void> _scan() async{final a=await Navigator.push<String>(context,AppPageRoute<String>(builder:(_)=>const ScanPasteAddressScreen()));if(mounted&&a!=null)setState(()=>target.text=a);}
  Future<void> _network() async{final n=await showModalBottomSheet<String>(context:context,isScrollControlled:true,backgroundColor:Colors.transparent,builder:(_)=>const SelectNetworkSheet());if(!mounted||n==null)return;final understood=await showModalBottomSheet<bool>(context:context,isScrollControlled:true,backgroundColor:Colors.transparent,builder:(_)=>const SanctionWarningSheet());if(mounted&&understood==true)setState(()=>network=n);}
  void _confirm()=>Navigator.push(context,AppPageRoute<void>(builder:(_)=>TransferReviewScreen(kind:widget.external?TxKind.external:TxKind.internal,target:target.text,amount:double.tryParse(amount.text)??.03,network:network)));
}

class TransferReviewScreen extends StatelessWidget { const TransferReviewScreen({super.key,required this.kind,required this.target,required this.amount,this.network}); final TxKind kind;final String target;final double amount;final String? network;
  @override Widget build(BuildContext context){final ext=kind==TxKind.external;return _Scaffold(child:Column(children:[
    _TopBar(title:'Withdraw',onBack:()=>Navigator.pop(context)),const SizedBox(height:20),const _CryptoBalance(),const SizedBox(height:20),
    _Summary(children:[_Row(label:ext?'Address':'Username',value:ext?_short(target):target),if(ext)_Row(label:'Network',value:network??'Bitcoin'),const _Row(label:'Asset',value:'Bitcoin (BTC)'),_Row(label:'Amount',value:'${amount.toStringAsFixed(4)} BTC'),_Row(label:'Network Fee',value:ext?'0.00002 BTC':'Free',valueColor:AppColors.primary),_Row(label:'Total',value:'${(amount+(ext ? .00002 : 0)).toStringAsFixed(5)} BTC',last:true)]),
    const Spacer(),_Button(label:'Confirm Withdrawal',onTap:()=>_pin(context)),
  ]));}
  Future<void> _pin(BuildContext context) async{final ok=await Navigator.push<bool>(context,AppPageRoute<bool>(builder:(_)=>const CryptoPinScreen()));if(!context.mounted||ok!=true)return;Navigator.pushReplacement(context,AppPageRoute<void>(builder:(_)=>TransactionProgressScreen(kind:kind,target:target,amount:amount)));}
}

class CryptoPinScreen extends StatefulWidget{const CryptoPinScreen({super.key});@override State<CryptoPinScreen> createState()=>_CryptoPinScreenState();}
class _CryptoPinScreenState extends State<CryptoPinScreen>{String pin='';void key(String v){HapticFeedback.selectionClick();if(v=='⌫'){if(pin.isNotEmpty){setState(()=>pin=pin.substring(0,pin.length-1));}}else if(pin.length<4){setState(()=>pin+=v);}}
  @override Widget build(BuildContext context)=>Scaffold(backgroundColor:Colors.white,body:SafeArea(child:Column(children:[
    Padding(padding:const EdgeInsets.fromLTRB(8,10,8,0),child:Align(alignment:Alignment.centerLeft,child:_AssetButton(asset:'$_f/buy_back.png',size:24,onTap:()=>Navigator.pop(context)))),const SizedBox(height:16),
    Container(width:96,height:96,alignment:Alignment.center,decoration:BoxDecoration(shape:BoxShape.circle,border:Border.all(color:const Color(0x4DC4C6CF))),child:Image.asset('$_f/buy_pin_shield.png',width:32,height:40)),const SizedBox(height:24),
    const Text('Confirm Your Pin',style:TextStyle(fontFamily:'Sora',fontSize:24,fontWeight:FontWeight.w600,color:AppColors.ink)),const SizedBox(height:12),const Text('Please enter your 4-digit security PIN to\nauthorize this transaction securely.',textAlign:TextAlign.center,style:TextStyle(fontFamily:'Sora',fontSize:14,height:1.35,color:AppColors.body)),const SizedBox(height:40),
    Row(mainAxisAlignment:MainAxisAlignment.center,children:List.generate(4,(i){final f=i<pin.length;return AnimatedContainer(duration:const Duration(milliseconds:160),margin:const EdgeInsets.symmetric(horizontal:4),width:60,height:70,alignment:Alignment.center,decoration:BoxDecoration(color:f?Colors.white:const Color(0xFFF5F6F9),border:Border.all(color:f?AppColors.primary:AppColors.mutedSoft),borderRadius:BorderRadius.circular(8),boxShadow:f?const[BoxShadow(color:Color(0x44135CF7),blurRadius:4)]:null),child:f?Text(pin[i],style:const TextStyle(fontSize:36,color:Color(0xFF555555))):null);})),const SizedBox(height:18),
    AnimatedSwitcher(duration:const Duration(milliseconds:180),child:pin.length==4?Padding(padding:const EdgeInsets.symmetric(horizontal:16),child:_Button(label:'Confirm',onTap:()=>Navigator.pop(context,true))):const Text('Enter Secure PIN',style:TextStyle(fontFamily:'Sora',fontSize:14,color:AppColors.body))),const Spacer(),_Keypad(onKey:key),const SizedBox(height:10),const Text('Authentication is required',style:TextStyle(fontFamily:'Sora',fontSize:12,color:AppColors.muted)),const SizedBox(height:8),
    Row(mainAxisAlignment:MainAxisAlignment.center,children:[Image.asset('$_f/buy_lock.png',width:11,height:14),const SizedBox(width:8),const Text('ENCRYPTED END-TO-END',style:TextStyle(fontFamily:'Sora',fontSize:11,fontWeight:FontWeight.w700,letterSpacing:1.1,color:AppColors.body))]),const SizedBox(height:12),
  ])));
}

class TransactionProgressScreen extends StatefulWidget{const TransactionProgressScreen({super.key,required this.kind,required this.target,required this.amount});final TxKind kind;final String target;final double amount;@override State<TransactionProgressScreen> createState()=>_TransactionProgressScreenState();}
class _TransactionProgressScreenState extends State<TransactionProgressScreen> with SingleTickerProviderStateMixin{late final AnimationController c;Timer? timer;@override void initState(){super.initState();c=AnimationController(vsync:this,duration:const Duration(milliseconds:900))..repeat(reverse:true);timer=Timer(const Duration(milliseconds:1500),(){if(mounted)Navigator.pushReplacement(context,AppPageRoute<void>(builder:(_)=>TransactionSuccessScreen(kind:widget.kind,target:widget.target,amount:widget.amount)));});}@override void dispose(){timer?.cancel();c.dispose();super.dispose();}
  @override Widget build(BuildContext context){final title = (widget.kind == TxKind.internal || widget.kind == TxKind.external) ? 'Sending ${widget.amount.toStringAsFixed(4)} BTC' : (widget.kind == TxKind.sell ? 'Selling ${widget.amount.toStringAsFixed(5)} BTC' : 'Converting');final sub=switch(widget.kind){TxKind.internal=>'to ${widget.target}',TxKind.external=>'to ${_short(widget.target)}',_=>''};return _Scaffold(child:Column(children:[_TopBar(title:widget.kind==TxKind.conversion?'':'Crypto Withdraw Mode',onBack:()=>Navigator.pop(context)),const SizedBox(height:50),ScaleTransition(scale:Tween<double>(begin:.94,end:1.05).animate(CurvedAnimation(parent:c,curve:Curves.easeInOut)),child:Image.asset('$_f/buy_process.png',width:150,height:150)),const SizedBox(height:16),Text(title,style:const TextStyle(fontFamily:'Sora',fontSize:16,fontWeight:FontWeight.w600)),if(sub.isNotEmpty)...[const SizedBox(height:4),Text(sub,style:const TextStyle(fontFamily:'Sora',fontSize:12,color:AppColors.bodyMuted))],const SizedBox(height:8),Text(widget.kind==TxKind.conversion?'Please wait while we process your Conversion':'Please wait while we process your transaction',textAlign:TextAlign.center,style:const TextStyle(fontFamily:'Sora',fontSize:14,color:AppColors.body))]));}
}

class TransactionSuccessScreen extends StatefulWidget{const TransactionSuccessScreen({super.key,required this.kind,required this.target,required this.amount});final TxKind kind;final String target;final double amount;@override State<TransactionSuccessScreen> createState()=>_TransactionSuccessScreenState();}
class _TransactionSuccessScreenState extends State<TransactionSuccessScreen> with SingleTickerProviderStateMixin{late final AnimationController c;@override void initState(){super.initState();c=AnimationController(vsync:this,duration:const Duration(milliseconds:600))..forward();}@override void dispose(){c.dispose();super.dispose();}
  @override Widget build(BuildContext context){final data=switch(widget.kind){TxKind.internal=>('Transfer Successful','You have sent ${widget.amount.toStringAsFixed(4)} BTC to ${widget.target}'),TxKind.external=>('Transfer Successful','You have sent ${widget.amount.toStringAsFixed(4)} BTC to ${_short(widget.target)}'),TxKind.sell=>('Sold Successful','You have successfully Sell ${widget.amount.toStringAsFixed(4)} BTC for ₦731,540.00'),TxKind.conversion=>('Conversion Successful','You have successfully converted ${widget.amount.toStringAsFixed(4)} BTC to 500 USDT')};return _Scaffold(child:Column(children:[_TopBar(title:'',onBack:()=>Navigator.pop(context)),const Spacer(),FadeTransition(opacity:c,child:ScaleTransition(scale:Tween<double>(begin:.9,end:1.0).animate(CurvedAnimation(parent:c,curve:Curves.easeOutBack)),child:Column(children:[Text(data.$1,textAlign:TextAlign.center,style:const TextStyle(fontFamily:'Sora',fontSize:20,fontWeight:FontWeight.w700)),const SizedBox(height:8),Text(data.$2,textAlign:TextAlign.center,style:const TextStyle(fontFamily:'Sora',fontSize:14,height:1.35,color:AppColors.bodyMuted))]))),const Spacer(),_Button(label:'View Details',onTap:()=>Navigator.push(context,AppPageRoute<void>(builder:(_)=>TransactionDetailsScreen(kind:widget.kind,target:widget.target,amount:widget.amount)))),const SizedBox(height:16),_Secondary(label:'Send another transfer',onTap:()=>Navigator.of(context).popUntil((r)=>r.isFirst))]));}
}

class TransactionDetailsScreen extends StatelessWidget{const TransactionDetailsScreen({super.key,required this.kind,required this.target,required this.amount,this.receipt=false});final TxKind kind;final String target;final double amount;final bool receipt;
  @override Widget build(BuildContext context){final ext=kind==TxKind.external,conv=kind==TxKind.conversion,sell=kind==TxKind.sell;final rows=conv?const[_Row(label:'From',value:'0.03048 BTC'),_Row(label:'To',value:'500.00 USDT'),_Row(label:'Date',value:'Sep 16, 2026, 14:26'),_Row(label:'Network Fee',value:'Free',valueColor:AppColors.primary),_Row(label:'Exchange Rate',value:'1 USDT ≈ 0.0000345 BTC'),_Row(label:'Transaction ID',value:'0x3a4f...9c7d',copy:true,last:true)]:sell?const[_Row(label:'From',value:'0.0304800 BTC'),_Row(label:'To',value:'₦731,540.00'),_Row(label:'Asset',value:'BTC'),_Row(label:'Date',value:'Sep 16, 2026, 14:26'),_Row(label:'Network Fee',value:'Free',valueColor:AppColors.primary),_Row(label:'Total Received',value:'₦731,540.00'),_Row(label:'Transaction ID',value:'0x3a4f...9c7d',copy:true,last:true)]:<Widget>[_Row(label:ext?'To':'Username',value:ext?_short(target):target),const _Row(label:'Asset',value:'Bitcoin (BTC)'),const _Row(label:'Date',value:'Sep 16, 2026, 14:26'),_Row(label:'Network Fee',value:ext?'0.00002 BTC':'Free',valueColor:AppColors.primary),const _Row(label:'Transaction ID',value:'0x3a4f...9c7d',copy:true),if(ext)const _Row(label:'Transaction Hash',value:'7c0d217a...15d04c35',copy:true,last:true)];return _Scaffold(child:Column(children:[_TopBar(title:'Transaction Details',onBack:()=>Navigator.pop(context)),const SizedBox(height:32),if(receipt)...[Row(mainAxisAlignment:MainAxisAlignment.center,children:[Image.asset('assets/images/brand/davochain_logo.png',width:22),const SizedBox(width:6),const Text('Davochain',style:TextStyle(fontFamily:'Sora',fontSize:14,fontWeight:FontWeight.w700))]),const SizedBox(height:6),Text(conv?'Conversion Receipt':'Transfer Receipt',style:const TextStyle(fontFamily:'Sora',fontSize:12,color:AppColors.bodyMuted)),const SizedBox(height:20)],Text('${amount.toStringAsFixed(4)} BTC',style:const TextStyle(fontFamily:'Sora',fontSize:24,fontWeight:FontWeight.w700)),const Text(r'$500.00 USD',style:TextStyle(fontFamily:'Sora',fontSize:14,color:AppColors.body)),const SizedBox(height:8),Container(padding:const EdgeInsets.symmetric(horizontal:14,vertical:8),decoration:BoxDecoration(color:const Color(0xFFE5F9ED),borderRadius:BorderRadius.circular(100)),child:const Text('Completed',style:TextStyle(fontFamily:'Sora',fontSize:12,fontWeight:FontWeight.w600,color:Color(0xFF1BA44D)))),const SizedBox(height:28),_Summary(children:rows),const Spacer(),_Button(label:'Done',onTap:()=>Navigator.of(context).popUntil((r)=>r.isFirst)),if(!sell)...[const SizedBox(height:13),_Secondary(label:'Share Receipt',onTap:()=>Navigator.push(context,AppPageRoute<void>(builder:(_)=>TransactionDetailsScreen(kind:kind,target:target,amount:amount,receipt:true))))]]));}
}

class ScanPasteAddressScreen extends StatefulWidget {
  const ScanPasteAddressScreen({super.key});
  @override
  State<ScanPasteAddressScreen> createState() => _ScanPasteAddressScreenState();
}

class _ScanPasteAddressScreenState extends State<ScanPasteAddressScreen> {
  int mode = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: _TopBar(title: 'Scan or Paste Address', onBack: () => Navigator.pop(context)),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(child: _Segment(label: 'Scan QR Code', active: mode == 0, onTap: () => setState(() => mode = 0))),
                  const SizedBox(width: 8),
                  Expanded(child: _Segment(label: 'Paste Address', active: mode == 1, onTap: () => setState(() => mode = 1))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: mode == 0
                    ? Container(
                        key: const ValueKey(0),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        color: const Color(0xFF222222),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset('$_cf/scanner_frame.png', width: 290, height: 290),
                            Positioned(
                              bottom: 84,
                              child: Column(
                                children: [
                                  Image.asset('$_cf/flashlight.png', width: 24, height: 24),
                                  const SizedBox(height: 8),
                                  const Text('Align the QR code within the frame', style: TextStyle(fontFamily: 'Sora', fontSize: 10, color: Color(0xFFEEF0F5))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    : Padding(
                        key: const ValueKey(1),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            const SizedBox(height: 24),
                            const _Field(
                              label: 'Wallet Address',
                              child: Text('bc1qctsh702f0vsh76juj2whathjyt74dffc0nj6t9', style: TextStyle(fontFamily: 'Sora', fontSize: 12)),
                            ),
                            const SizedBox(height: 20),
                            _Button(label: 'Use Address', onTap: () => Navigator.pop(context, 'bc1qctsh702f0vsh76juj2whathjyt74dffc0nj6t9')),
                          ],
                        ),
                      ),
              ),
            ),
            if (mode == 0)
              Padding(
                padding: const EdgeInsets.all(16),
                child: _Secondary(label: 'Enter Address manually', onTap: () => setState(() => mode = 1)),
              ),
          ],
        ),
      ),
    );
  }
}

class SelectNetworkSheet extends StatelessWidget{const SelectNetworkSheet({super.key});@override Widget build(BuildContext context)=>_Sheet(title:'Select Network',height:407,child:Column(children:[Row(crossAxisAlignment:CrossAxisAlignment.start,children:[Image.asset('$_cf/network_warning.png',width:14),const SizedBox(width:8),const Expanded(child:Text('Please make sure that your withdrawal address and chain match each other, otherwise you may lose your assets.',style:TextStyle(fontFamily:'Sora',fontSize:10,height:1.35,color:AppColors.body)))]),const SizedBox(height:12),_Network(title:'Bitcoin (BTC)',eta:'10m 14s',fee:r'0.00002 BTC  ($1.57)',onTap:()=>Navigator.pop(context,'Bitcoin (BTC)')),_Network(title:'BNB Smart Chain (BEP20)',eta:'2m 2s',fee:r'0.00000025 BTC  ($0.019)',onTap:()=>Navigator.pop(context,'BNB Smart Chain (BEP20)'))]));}

class SanctionWarningSheet extends StatelessWidget{const SanctionWarningSheet({super.key});@override Widget build(BuildContext context)=>_Sheet(title:'Prohibited Transactions with Sanctioned Entities',height:620,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('To protect your account and funds, please avoid sending or receiving funds from cryptocurrency platforms or entities that are sanctioned or considered high risk.',style:TextStyle(fontFamily:'Sora',fontSize:11,height:1.45,color:AppColors.body)),const SizedBox(height:20),const Text('High-Risk Platforms',style:TextStyle(fontFamily:'Sora',fontSize:12,fontWeight:FontWeight.w600)),const SizedBox(height:8),const Text('Garantex • Grinex • Nobitex • Bit24 • Excoino • Ramzinex',style:TextStyle(fontFamily:'Sora',fontSize:11,height:1.5,color:AppColors.body)),const SizedBox(height:20),const Text('Important Guidelines',style:TextStyle(fontFamily:'Sora',fontSize:12,fontWeight:FontWeight.w600)),const SizedBox(height:8),const Text('Transactions involving high-risk platforms may lead to restrictions on your Davochain account. Always verify the destination before continuing.',style:TextStyle(fontFamily:'Sora',fontSize:11,height:1.45,color:AppColors.body)),const Spacer(),_Button(label:'I Understand',onTap:()=>Navigator.pop(context,true))]));}

class CancelReminderDialog extends StatelessWidget{const CancelReminderDialog({super.key});@override Widget build(BuildContext context)=>Dialog(shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(12)),child:Padding(padding:const EdgeInsets.all(20),child:Column(mainAxisSize:MainAxisSize.min,children:[const Text('Reminder',style:TextStyle(fontFamily:'Sora',fontSize:16,fontWeight:FontWeight.w600)),const SizedBox(height:8),const Text('Do you want to cancel this payment?',style:TextStyle(fontFamily:'Sora',fontSize:12,color:AppColors.body)),const SizedBox(height:20),_Button(label:'Continue to Pay',onTap:()=>Navigator.pop(context,false)),const SizedBox(height:8),TextButton(onPressed:()=>Navigator.pop(context,true),child:const Text('Cancel',style:TextStyle(fontFamily:'Sora',color:AppColors.primary))) ])));
}

class TradeAmountScreen extends StatefulWidget{const TradeAmountScreen({super.key,required this.mode,required this.asset});final TradeMode mode;final BuyCryptoAsset asset;@override State<TradeAmountScreen> createState()=>_TradeAmountScreenState();}
class _TradeAmountScreenState extends State<TradeAmountScreen>{final amount=TextEditingController();@override void dispose(){amount.dispose();super.dispose();}bool get convert=>widget.mode==TradeMode.convert;@override Widget build(BuildContext context){final active=amount.text.isNotEmpty&&amount.text!='0.00';final n=double.tryParse(amount.text)??0;return _Scaffold(child:Column(children:[_TopBar(title:convert?'Swap':'Sell',onBack:()=>Navigator.pop(context)),const SizedBox(height:18),_Tabs(active:convert?2:1,onBuy:()=>Navigator.pop(context),onSell:(){},onConvert:(){if(!convert)Navigator.pushReplacement(context,AppPageRoute<void>(builder:(_)=>const TradeAmountScreen(mode:TradeMode.convert,asset:BuyCryptoAsset.bitcoin)));}),const SizedBox(height:18),if(!convert)...[_AssetBalance(asset:widget.asset),const SizedBox(height:24),_Amount(controller:amount,suffix:widget.asset.symbol,onChanged:()=>setState((){})),const SizedBox(height:20),Text(active?'≈ ₦731,540.00':'≈ ₦0.00',style:const TextStyle(fontFamily:'Sora',fontSize:14,fontWeight:FontWeight.w600,color:AppColors.body))]else...[_SwapEntry(label:'From',asset:widget.asset,controller:amount,onChanged:()=>setState((){})),const SizedBox(height:12),Image.asset('$_cf/swap.png',width:24,height:24),const SizedBox(height:12),_SwapReceive(active:active)],const SizedBox(height:18),Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:['10%','25%','50%','75%','Max'].map((v)=>_Percent(label:v,onTap:(){amount.text='.03048';setState((){});})).toList()),const Spacer(),_Button(label:convert?'Preview':'Continue',enabled:active,onTap:()=>Navigator.push(context,AppPageRoute<void>(builder:(_)=>TradeReviewScreen(kind:convert?TxKind.conversion:TxKind.sell,amount: n == 0 ? .03048 : n))))]));}}

class TradeReviewScreen extends StatelessWidget{const TradeReviewScreen({super.key,required this.kind,required this.amount});final TxKind kind;final double amount;@override Widget build(BuildContext context){final conv=kind==TxKind.conversion;return _Scaffold(child:Column(children:[_TopBar(title:conv?'Review Conversion':'Sell',onBack:()=>Navigator.pop(context)),const SizedBox(height:24),_Pair(firstLabel:conv?'You are converting':'You are Selling',firstAmount:'${amount.toStringAsFixed(5)} BTC',secondLabel:'To (You will receive)',secondAmount:conv?'500.00 USDT':'₦731,540.00'),const SizedBox(height:20),_Summary(children:[_Row(label:'Exchange Rate',value:conv?'1 USDT ≈ 0.0000345 BTC':'1 USDT ≈ ₦1,540.00'),const _Row(label:'Network Fee',value:'Free',valueColor:AppColors.primary),_Row(label:conv?'Total Amount':'Total Received',value:conv?'500.00 USDT':'₦731,540.00',last:true)]),const Spacer(),_Button(label:conv?'Confirm conversion':'Confirm',onTap:()=>Navigator.pushReplacement(context,AppPageRoute<void>(builder:(_)=>TransactionProgressScreen(kind:kind,target:conv?'USDT':'NGN',amount:amount))))]));}}

class DepositStatusScreen extends StatelessWidget{const DepositStatusScreen({super.key,required this.success});final bool success;@override Widget build(BuildContext context)=>_Scaffold(child:Column(children:[_TopBar(title:'Deposit Details',onBack:()=>Navigator.pop(context)),const SizedBox(height:50),const Text('Quantity',style:TextStyle(fontFamily:'Sora',fontSize:12,color:AppColors.bodyMuted)),const SizedBox(height:5),const Text('0.0317934 BTC',style:TextStyle(fontFamily:'Sora',fontSize:18,fontWeight:FontWeight.w600)),const SizedBox(height:8),Container(padding:const EdgeInsets.symmetric(horizontal:12,vertical:6),decoration:BoxDecoration(color:success?const Color(0xFFE5F9ED):const Color(0xFFFFF4DB),borderRadius:BorderRadius.circular(100)),child:Text(success?'Deposit Successful':'Pending',style:TextStyle(fontFamily:'Sora',fontSize:11,fontWeight:FontWeight.w600,color:success?const Color(0xFF1BA44D):const Color(0xFFCC8408)))),const SizedBox(height:12),const Text('Crypto has arrived in your Davochain account. View your wallet account balance for more details.',textAlign:TextAlign.center,style:TextStyle(fontFamily:'Sora',fontSize:10,height:1.4,color:AppColors.bodyMuted)),const SizedBox(height:28),const _Summary(children:[_Row(label:'Network',value:'BTC'),_Row(label:'Time',value:'2026-05-02 22:36:58'),_Row(label:'Deposit Address',value:'1ChGMX...AA6zLZ',copy:true),_Row(label:'Transaction Hash',value:'7c0d217a...15d04c35',copy:true),_Row(label:'Transaction type',value:'Received from External',last:true)])]));}

// Reusable visual primitives ----------------------------------------------------
class _Scaffold extends StatelessWidget{const _Scaffold({required this.child});final Widget child;@override Widget build(BuildContext context)=>Scaffold(backgroundColor:const Color(0xFFF8F9FB),body:SafeArea(child:Padding(padding:const EdgeInsets.fromLTRB(16,12,16,16),child:child)));}
class _TopBar extends StatelessWidget{const _TopBar({required this.title,required this.onBack});final String title;final VoidCallback onBack;@override Widget build(BuildContext context)=>SizedBox(height:40,child:Stack(alignment:Alignment.center,children:[Align(alignment:Alignment.centerLeft,child:_AssetButton(asset:'$_f/buy_back.png',size:24,onTap:onBack)),if(title.isNotEmpty)Text(title,style:const TextStyle(fontFamily:'Sora',fontSize:16,fontWeight:FontWeight.w500,color:AppColors.ink))]));}
class _AssetButton extends StatelessWidget{const _AssetButton({required this.asset,required this.size,required this.onTap});final String asset;final double size;final VoidCallback onTap;@override Widget build(BuildContext context)=>InkResponse(onTap:(){HapticFeedback.selectionClick();onTap();},radius:24,child:SizedBox(width:36,height:36,child:Center(child:Image.asset(asset,width:size,height:size))));}
class _Sheet extends StatelessWidget{const _Sheet({required this.title,required this.height,required this.child});final String title;final double height;final Widget child;@override Widget build(BuildContext context)=>Container(height:height,decoration:const BoxDecoration(color:Color(0xFFF8F9FB),borderRadius:BorderRadius.vertical(top:Radius.circular(20))),child:SafeArea(top:false,child:Padding(padding:const EdgeInsets.fromLTRB(16,8,16,16),child:Column(children:[Container(width:85,height:4,decoration:BoxDecoration(color:const Color(0xFF686868),borderRadius:BorderRadius.circular(100))),const SizedBox(height:10),SizedBox(height:38,child:Stack(alignment:Alignment.center,children:[Padding(padding:const EdgeInsets.symmetric(horizontal:40),child:Text(title,textAlign:TextAlign.center,style:const TextStyle(fontFamily:'Sora',fontSize:14,color:AppColors.ink))),Align(alignment:Alignment.centerRight,child:_AssetButton(asset:'$_f/buy_close.png',size:24,onTap:()=>Navigator.pop(context)))])),const SizedBox(height:8),Expanded(child:child)]))));}
class _SheetRow extends StatelessWidget{const _SheetRow({this.leading,this.asset,required this.title,this.subtitle,this.trailing,this.bold=false,required this.onTap});final Widget? leading;final String? asset;final String title;final String? subtitle;final Widget? trailing;final bool bold;final VoidCallback onTap;@override Widget build(BuildContext context)=>InkWell(onTap:(){HapticFeedback.selectionClick();onTap();},child:Container(height:63,decoration:const BoxDecoration(border:Border(bottom:BorderSide(color:Color(0xFFEBEDF3),width:.4))),child:Row(children:[leading??Image.asset(asset!,width:32,height:32,fit:BoxFit.contain),const SizedBox(width:12),Expanded(child:Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:TextStyle(fontFamily:'Sora',fontSize:14,fontWeight:bold?FontWeight.w600:FontWeight.w400,color:AppColors.ink)),if(subtitle!=null)...[const SizedBox(height:2),Text(subtitle!,style:const TextStyle(fontFamily:'Sora',fontSize:12,color:AppColors.body))]])),if(trailing!=null)trailing!])));}
class _BalanceText extends StatelessWidget{const _BalanceText({required this.top,required this.bottom});final String top,bottom;@override Widget build(BuildContext context)=>Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.end,children:[Text(top,style:const TextStyle(fontFamily:'Sora',fontSize:14,color:AppColors.body)),Text(bottom,style:const TextStyle(fontFamily:'Sora',fontSize:10,color:AppColors.bodyMuted))]);}
class _Button extends StatelessWidget{const _Button({required this.label,this.enabled=true,required this.onTap});final String label;final bool enabled;final VoidCallback onTap;@override Widget build(BuildContext context)=>AnimatedOpacity(opacity:enabled?1:.45,duration:const Duration(milliseconds:180),child:Material(color:enabled?AppColors.primary:AppColors.primaryDisabled,borderRadius:BorderRadius.circular(4),child:InkWell(onTap:enabled?(){HapticFeedback.lightImpact();onTap();}:null,borderRadius:BorderRadius.circular(4),child:SizedBox(height:48,width:double.infinity,child:Center(child:Text(label,style:const TextStyle(fontFamily:'Sora',fontSize:14,fontWeight:FontWeight.w600,color:Colors.white)))))));}
class _Secondary extends StatelessWidget{const _Secondary({required this.label,required this.onTap});final String label;final VoidCallback onTap;@override Widget build(BuildContext context)=>Material(color:const Color(0xFFEAF0FB),borderRadius:BorderRadius.circular(4),child:InkWell(onTap:onTap,borderRadius:BorderRadius.circular(4),child:SizedBox(height:48,width:double.infinity,child:Center(child:Text(label,style:const TextStyle(fontFamily:'Sora',fontSize:14,fontWeight:FontWeight.w600,color:AppColors.primary))))));}
class _Field extends StatelessWidget{const _Field({required this.label,required this.child,this.trailing,this.onTap});final String label;final Widget child;final Widget? trailing;final VoidCallback? onTap;@override Widget build(BuildContext context)=>Material(color:Colors.white,borderRadius:BorderRadius.circular(4),child:InkWell(onTap:onTap,borderRadius:BorderRadius.circular(4),child:Container(width:double.infinity,constraints:const BoxConstraints(minHeight:74),padding:const EdgeInsets.symmetric(horizontal:12,vertical:10),decoration:BoxDecoration(border:Border.all(color:AppColors.mutedSoft),borderRadius:BorderRadius.circular(4)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(label,style:const TextStyle(fontFamily:'Sora',fontSize:14,color:AppColors.body)),const SizedBox(height:8),Row(children:[Expanded(child:child),if(trailing!=null)trailing!])]))));}
class _ValueField extends StatelessWidget{const _ValueField({required this.label,required this.value,this.muted=false,this.onTap});final String label,value;final bool muted;final VoidCallback? onTap;@override Widget build(BuildContext context)=>_Field(label:label,onTap:onTap,trailing:onTap!=null?Image.asset('$_cf/chevron_right.png',width:16):null,child:Text(value,style:TextStyle(fontFamily:'Sora',fontSize:14,color:muted?AppColors.muted:AppColors.ink)));}
class _Row extends StatelessWidget{const _Row({required this.label,required this.value,this.valueColor,this.copy=false,this.last=false});final String label,value;final Color? valueColor;final bool copy,last;@override Widget build(BuildContext context)=>Container(constraints:const BoxConstraints(minHeight:47),decoration:last?null:const BoxDecoration(border:Border(bottom:BorderSide(color:Color(0xFFF2F2F2),width:.6))),child:Row(children:[Text(label,style:const TextStyle(fontFamily:'Sora',fontSize:14,color:AppColors.bodyMuted)),const Spacer(),Flexible(child:Text(value,textAlign:TextAlign.right,style:TextStyle(fontFamily:'Sora',fontSize:14,color:valueColor??AppColors.ink))),if(copy)...[const SizedBox(width:8),GestureDetector(onTap:()=>Clipboard.setData(ClipboardData(text:value)),child:Image.asset('$_f/buy_copy.png',width:16,height:16))]]));}
class _Summary extends StatelessWidget{const _Summary({required this.children});final List<Widget> children;@override Widget build(BuildContext context)=>Container(width:double.infinity,padding:const EdgeInsets.symmetric(horizontal:16,vertical:10),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(8)),child:Column(children:children));}
class _Choice extends StatelessWidget{const _Choice({required this.asset,required this.title,required this.subtitle,required this.onTap});final String asset,title,subtitle;final VoidCallback onTap;@override Widget build(BuildContext context)=>Material(color:Colors.transparent,child:InkWell(onTap:onTap,borderRadius:BorderRadius.circular(4),child:Container(height:76,padding:const EdgeInsets.symmetric(horizontal:16),decoration:BoxDecoration(border:Border.all(color:AppColors.mutedSoft),borderRadius:BorderRadius.circular(4)),child:Row(children:[Container(width:40,height:40,alignment:Alignment.center,decoration:BoxDecoration(color:const Color(0xFFF4F7FF),borderRadius:BorderRadius.circular(4)),child:Image.asset(asset,width:24,height:24)),const SizedBox(width:12),Expanded(child:Column(mainAxisAlignment:MainAxisAlignment.center,crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontFamily:'Sora',fontSize:14,fontWeight:FontWeight.w600)),Text(subtitle,style:const TextStyle(fontFamily:'Sora',fontSize:12,height:1.2,color:AppColors.bodyMuted))])),Image.asset('$_cf/chevron_right.png',width:16)]))));}
class _DashboardHeader extends StatelessWidget{const _DashboardHeader();@override Widget build(BuildContext context)=>Row(children:[ClipOval(child:Image.asset('$_f/profile_avatar.png',width:40,height:40,fit:BoxFit.cover)),const SizedBox(width:12),const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Welcome,',style:TextStyle(fontFamily:'Sora',fontSize:12,color:AppColors.muted)),Text('Callie',style:TextStyle(fontFamily:'Sora',fontSize:14,fontWeight:FontWeight.w600,color:AppColors.body))]),const Spacer(),Container(padding:const EdgeInsets.symmetric(horizontal:12,vertical:7),decoration:BoxDecoration(color:const Color(0x80D0DEFD),borderRadius:BorderRadius.circular(100)),child:Row(children:[Image.asset('assets/icons/figma/earn_gift.png',width:20,height:20),const SizedBox(width:4),const Text(r'Earn $5',style:TextStyle(fontFamily:'Sora',fontSize:12,color:AppColors.primary))]))]);}
class _BalanceCard extends StatelessWidget{const _BalanceCard();@override Widget build(BuildContext context)=>Container(height:136,width:double.infinity,clipBehavior:Clip.antiAlias,decoration:BoxDecoration(color:AppColors.primary,borderRadius:BorderRadius.circular(16)),child:Stack(children:[Positioned(right:0,bottom:0,width:268,height:94,child:Image.asset('$_f/balance_wave.png',fit:BoxFit.fill)),const Positioned(left:16,top:28,child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Available Balance',style:TextStyle(fontFamily:'Sora',fontSize:10,color:Color(0xFFEEF0F5))),SizedBox(height:8),Text('₦1,284,500.35',style:TextStyle(fontFamily:'Sora',fontSize:24,fontWeight:FontWeight.w700,color:Colors.white)),Text(r'≈ $842.31 USD',style:TextStyle(fontFamily:'Sora',fontSize:14,color:Colors.white))]))]));}
class _CryptoBalance extends StatelessWidget{const _CryptoBalance();@override Widget build(BuildContext context)=>Container(width:double.infinity,padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(6)),child:Row(children:[Image.asset('$_f/btc.png',width:36,height:36),const SizedBox(width:12),const Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Wallet Balance',style:TextStyle(fontFamily:'Sora',fontSize:10,color:AppColors.bodyMuted)),Text('Bitcoin',style:TextStyle(fontFamily:'Sora',fontSize:14,fontWeight:FontWeight.w600)),Text(r'0.0300 BTC  •  $842.31 USD',style:TextStyle(fontFamily:'Sora',fontSize:10,color:AppColors.bodyMuted))]),const Spacer(),const Text('Change Asset',style:TextStyle(fontFamily:'Sora',fontSize:10,color:AppColors.primary))]));}
class _Keypad extends StatelessWidget{const _Keypad({required this.onKey});final ValueChanged<String> onKey;@override Widget build(BuildContext context){const keys=['1','2','3','4','5','6','7','8','9','','0','⌫'];return Container(height:222,margin:const EdgeInsets.symmetric(horizontal:16),padding:const EdgeInsets.all(6),color:const Color(0xFFF5F6F9),child:GridView.builder(physics:const NeverScrollableScrollPhysics(),gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount:3,mainAxisSpacing:6,crossAxisSpacing:5,childAspectRatio:2.4),itemCount:keys.length,itemBuilder:(_,i){final k=keys[i];if(k.isEmpty)return const SizedBox();if(k=='⌫')return InkWell(onTap:()=>onKey(k),child:Center(child:Image.asset('$_f/buy_backspace.png',width:28,height:20)));return Material(color:Colors.white,borderRadius:BorderRadius.circular(4.6),elevation:.7,child:InkWell(onTap:()=>onKey(k),child:Center(child:Text(k,style:const TextStyle(fontSize:25))))); }));}}
class _Network extends StatelessWidget{const _Network({required this.title,required this.eta,required this.fee,required this.onTap});final String title,eta,fee;final VoidCallback onTap;@override Widget build(BuildContext context)=>InkWell(onTap:onTap,child:Container(padding:const EdgeInsets.symmetric(vertical:14),decoration:const BoxDecoration(border:Border(bottom:BorderSide(color:AppColors.mutedSoft,width:.5))),child:Row(children:[Image.asset('$_f/btc.png',width:36,height:36),const SizedBox(width:12),Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(title,style:const TextStyle(fontFamily:'Sora',fontSize:12,fontWeight:FontWeight.w600)),Text('Expected Arrival  $eta',style:const TextStyle(fontFamily:'Sora',fontSize:9,color:AppColors.bodyMuted)),Text('Fee: $fee',style:const TextStyle(fontFamily:'Sora',fontSize:9,color:AppColors.bodyMuted))]))])));}
class _Segment extends StatelessWidget{const _Segment({required this.label,required this.active,required this.onTap});final String label;final bool active;final VoidCallback onTap;@override Widget build(BuildContext context)=>Material(color:active?AppColors.primary:const Color(0xFFEAF0FB),borderRadius:BorderRadius.circular(4),child:InkWell(onTap:onTap,child:SizedBox(height:42,child:Center(child:Text(label,style:TextStyle(fontFamily:'Sora',fontSize:12,fontWeight:FontWeight.w600,color:active?Colors.white:AppColors.primary))))));}
class _Tabs extends StatelessWidget{const _Tabs({required this.active,required this.onBuy,required this.onSell,required this.onConvert});final int active;final VoidCallback onBuy,onSell,onConvert;@override Widget build(BuildContext context){final c=[onBuy,onSell,onConvert];return Container(height:55,padding:const EdgeInsets.all(6),decoration:BoxDecoration(color:const Color(0xFFF3F3F9),borderRadius:BorderRadius.circular(999)),child:Row(children:List.generate(3,(i)=>Expanded(child:Material(color:active==i?Colors.white:Colors.transparent,borderRadius:BorderRadius.circular(999),child:InkWell(onTap:c[i],borderRadius:BorderRadius.circular(999),child:Center(child:Text(['Buy','Sell','Convert'][i],style:TextStyle(fontFamily:'Sora',fontSize:14,fontWeight:FontWeight.w600,color:active==i?AppColors.primary:AppColors.body)))))))));}}
class _AssetBalance extends StatelessWidget{const _AssetBalance({required this.asset});final BuyCryptoAsset asset;@override Widget build(BuildContext context)=>Column(children:[Image.asset(_asset(asset),width:32,height:32),const SizedBox(height:12),const Text('Available Balance',style:TextStyle(fontFamily:'Sora',fontSize:12,fontWeight:FontWeight.w600,color:AppColors.body)),Text(asset==BuyCryptoAsset.bitcoin?'0.33048 BTC':'5.00 ${asset.symbol}',style:const TextStyle(fontFamily:'Sora',fontSize:14,fontWeight:FontWeight.w600)),const Text(r'($5,000.00)',style:TextStyle(fontFamily:'Sora',fontSize:10,color:AppColors.bodyMuted))]);}
class _Amount extends StatelessWidget{const _Amount({required this.controller,required this.suffix,required this.onChanged});final TextEditingController controller;final String suffix;final VoidCallback onChanged;@override Widget build(BuildContext context)=>Container(height:77,padding:const EdgeInsets.symmetric(horizontal:16),decoration:BoxDecoration(color:Colors.white,border:Border.all(color:AppColors.mutedSoft),borderRadius:BorderRadius.circular(4)),child:Row(children:[Expanded(child:TextField(controller:controller,keyboardType:const TextInputType.numberWithOptions(decimal:true),onChanged:(_)=>onChanged(),decoration:const InputDecoration.collapsed(hintText:'0.00'),textAlign:TextAlign.center,style:const TextStyle(fontFamily:'Sora',fontSize:20,fontWeight:FontWeight.w600))),Text(suffix,style:const TextStyle(fontFamily:'Sora',fontSize:14,color:AppColors.body))]));}
class _SwapEntry extends StatelessWidget{const _SwapEntry({required this.label,required this.asset,required this.controller,required this.onChanged});final String label;final BuyCryptoAsset asset;final TextEditingController controller;final VoidCallback onChanged;@override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(8)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(label,style:const TextStyle(fontFamily:'Sora',fontSize:12,color:AppColors.bodyMuted)),const SizedBox(height:10),Row(children:[Image.asset(_asset(asset),width:24,height:24),const SizedBox(width:8),Text(asset.symbol,style:const TextStyle(fontFamily:'Sora',fontSize:14,fontWeight:FontWeight.w600)),const Spacer(),SizedBox(width:120,child:TextField(controller:controller,onChanged:(_)=>onChanged(),keyboardType:const TextInputType.numberWithOptions(decimal:true),textAlign:TextAlign.right,decoration:const InputDecoration.collapsed(hintText:'0.00'),style:const TextStyle(fontFamily:'Sora',fontSize:16,fontWeight:FontWeight.w600)))]) ]));}
class _SwapReceive extends StatelessWidget{const _SwapReceive({required this.active});final bool active;@override Widget build(BuildContext context)=>Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:Colors.white,borderRadius:BorderRadius.circular(8)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[const Text('To',style:TextStyle(fontFamily:'Sora',fontSize:12,color:AppColors.bodyMuted)),const SizedBox(height:10),Row(children:[Image.asset('$_f/usdt.png',width:24,height:24),const SizedBox(width:8),const Text('USDT',style:TextStyle(fontFamily:'Sora',fontSize:14,fontWeight:FontWeight.w600)),const Spacer(),Text(active?'500.00':'0.00',style:const TextStyle(fontFamily:'Sora',fontSize:16,fontWeight:FontWeight.w600))]) ]));}
class _Percent extends StatelessWidget{const _Percent({required this.label,required this.onTap});final String label;final VoidCallback onTap;@override Widget build(BuildContext context)=>InkWell(onTap:onTap,child:Container(width:46,height:25,alignment:Alignment.center,decoration:BoxDecoration(border:Border.all(color:const Color(0xFFEEF0F5)),borderRadius:BorderRadius.circular(4)),child:Text(label,style:TextStyle(fontFamily:'Sora',fontSize:12,color:label=='Max'?AppColors.primary:AppColors.body))));}
class _Pair extends StatelessWidget{const _Pair({required this.firstLabel,required this.firstAmount,required this.secondLabel,required this.secondAmount});final String firstLabel,firstAmount,secondLabel,secondAmount;@override Widget build(BuildContext context)=>Stack(alignment:Alignment.center,children:[Column(children:[_PairBox(label:firstLabel,amount:firstAmount,asset:'$_f/btc.png'),const SizedBox(height:9),_PairBox(label:secondLabel,amount:secondAmount,asset:secondAmount.contains('USDT')?'$_f/usdt.png':'$_f/buy_nigeria.png')]),Container(width:40,height:40,padding:const EdgeInsets.all(8),decoration:const BoxDecoration(color:Color(0xFFF4F7FF),shape:BoxShape.circle),child:Image.asset('$_f/buy_exchange_down.png'))]);}
class _PairBox extends StatelessWidget{const _PairBox({required this.label,required this.amount,required this.asset});final String label,amount,asset;@override Widget build(BuildContext context)=>Container(height:92,width:double.infinity,padding:const EdgeInsets.all(15),decoration:BoxDecoration(color:Colors.white,border:Border.all(color:const Color(0xFFF5F6F9)),borderRadius:BorderRadius.circular(6)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text(label,style:const TextStyle(fontFamily:'Sora',fontSize:12,color:AppColors.bodyMuted)),const SizedBox(height:12),Row(children:[Image.asset(asset,width:32,height:32),const SizedBox(width:8),Text(amount,style:const TextStyle(fontFamily:'Sora',fontSize:16,fontWeight:FontWeight.w600,color:AppColors.body))]) ]));}
String _asset(BuyCryptoAsset a)=>switch(a){BuyCryptoAsset.bitcoin=>'$_f/btc.png',BuyCryptoAsset.ethereum=>'$_f/eth.png',BuyCryptoAsset.solana=>'$_f/sol.png',BuyCryptoAsset.tether=>'$_f/usdt.png'};
String _short(String v)=>v.length<=16?v:'${v.substring(0,6)}......${v.substring(v.length-6)}';
