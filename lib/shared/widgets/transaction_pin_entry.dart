import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';
import 'auth_widgets.dart';
class TransactionPinEntryScreen extends StatefulWidget {
  const TransactionPinEntryScreen({super.key, required this.onConfirm});
  final VoidCallback onConfirm;

  @override
  State<TransactionPinEntryScreen> createState() => _TransactionPinEntryScreenState();
}

class _TransactionPinEntryScreenState extends State<TransactionPinEntryScreen> {
  String pin = '';

  void key(String value) {
    HapticFeedback.selectionClick();
    setState(() {
      if (value == 'back') {
        if (pin.isNotEmpty) pin = pin.substring(0, pin.length - 1);
      } else if (pin.length < 4) {
        pin += value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    return DavoAuthScaffold(
      child: LayoutBuilder(builder: (context, constraints) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Column(children: [
            
            const SizedBox(height: 12),
            Container(
              width: 96, height: 96, alignment: Alignment.center,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white,
                boxShadow: [BoxShadow(color: Color(0x16000000), blurRadius: 12, offset: Offset(0, 3))]),
              child: Image.asset('assets/figma_exact/buy_pin_shield.png', width: 32, height: 40),
            ),
            const SizedBox(height: 26),
            const Text('Confirm Your Pin', textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, height: 1.35, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text('Please enter your 4-digit security PIN to confirm this transaction.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, height: 1.4, color: AppColors.body))),
            const SizedBox(height: 32),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(4, (index) {
              final filled = index < pin.length;
              return Semantics(label: 'PIN digit ${index + 1}, ${filled ? "entered" : "empty"}',
                child: AnimatedContainer(
                  duration: reduced ? Duration.zero : const Duration(milliseconds: 160),
                  width: 56, height: 68, margin: const EdgeInsets.symmetric(horizontal: 4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: const Color(0xFFF5F6F9), borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: filled ? AppColors.primary : const Color(0xFFEBEDF3))),
                  child: filled ? const Icon(Icons.circle, size: 14, color: AppColors.ink) : null,
                ));
            })),
            const SizedBox(height: 16),
            SizedBox(height: 52, child: Center(child: pin.length == 4
              ? DavoPrimaryButton(label: 'Confirm', onPressed: widget.onConfirm)
              : const Text('Enter Secure PIN', style: TextStyle(fontSize: 14, height: 1.4, color: AppColors.body)))),
            const SizedBox(height: 16),
            ...List.generate(4, (row) => Row(children: List.generate(3, (col) {
              const values = ['1','2','3','4','5','6','7','8','9','','0','back'];
              const letters = ['', 'ABC', 'DEF', 'GHI', 'JKL', 'MNO', 'PQRS', 'TUV', 'WXYZ', '', '', ''];
              final i = row * 3 + col;
              if (values[i].isEmpty) return const Expanded(child: SizedBox(height: 56));
              return Expanded(child: SizedBox(height: 56, child: Semantics(
                button: true, label: values[i] == 'back' ? 'Delete PIN digit' : values[i], excludeSemantics: true,
                child: InkWell(onTap: () => key(values[i]), borderRadius: BorderRadius.circular(12),
                  child: Center(child: values[i] == 'back' ? const Icon(Icons.backspace_outlined, size: 24)
                    : Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(values[i], style: const TextStyle(fontSize: 25, height: 1.1, color: Colors.black)),
                      if (letters[i].isNotEmpty) Text(letters[i], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                    ])),
                ),
              )));
            }))),
            const SizedBox(height: 40),
            const Text('Preview only. No transaction is authorized.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, height: 1.4, color: AppColors.body)),
            const SizedBox(height: 12),
          ]),
        ),
      )),
    );
  }
}

