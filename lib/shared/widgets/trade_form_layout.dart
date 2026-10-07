import 'package:flutter/material.dart';

/// Keeps the trade controls usable on short screens and above the keyboard.
class TradeFormLayout extends StatelessWidget {
  const TradeFormLayout({super.key, required this.header, required this.tabs,
    required this.content, required this.action});

  final Widget header, tabs, content, action;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF8F9FB),
    body: SafeArea(child: Column(children: [
      SizedBox(height: 56, child: header),
      Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: tabs),
      Expanded(child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 24), child: content)),
      Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 16), child: action),
    ])),
  );
}
