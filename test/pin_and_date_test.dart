import 'package:davochain/shared/widgets/transaction_pin_entry.dart';
import 'package:davochain/shared/widgets/davo_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
void main() {
 testWidgets('fourth PIN digit enables confirm without moving heading or keypad', (tester) async {
  await tester.pumpWidget(MaterialApp(home: TransactionPinEntryScreen(onConfirm: () {})));
  final heading = tester.getTopLeft(find.text('Confirm Your Pin'));
  final key = tester.getTopLeft(find.text('2'));
  for(final digit in ['1','2','3','4']) { await tester.tap(find.text(digit)); await tester.pump(); }
  expect(find.text('Confirm'), findsOneWidget);
  expect(tester.getTopLeft(find.text('Confirm Your Pin')), heading);
  expect(tester.getTopLeft(find.text('2')), key);
 });
 testWidgets('shared date picker returns selection and supports cancel', (tester) async {
  DateTime? selected;
  await tester.pumpWidget(MaterialApp(home: Builder(builder:(context)=>Scaffold(body:TextButton(onPressed:() async {
    selected=await showDavoDatePicker(context,title:'Date of birth',initialDate:DateTime(2000,1,1),firstDate:DateTime(1900),lastDate:DateTime(2026));
  },child:const Text('Open date'))))));
  await tester.tap(find.text('Open date'));await tester.pumpAndSettle();
  await tester.tap(find.text('Select date'));await tester.pumpAndSettle();
  expect(selected,DateTime(2000,1,1));
  await tester.tap(find.text('Open date'));await tester.pumpAndSettle();
  await tester.tap(find.byTooltip('Close date picker'));await tester.pumpAndSettle();
  expect(selected,isNull);
 });
}
