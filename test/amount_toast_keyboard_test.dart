import 'package:davochain/app.dart';
import 'package:davochain/core/navigation/app_routes.dart';
import 'package:davochain/shared/formatters/grouped_amount_formatter.dart';
import 'package:davochain/shared/widgets/davo_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('amount grouping preserves fractional precision and parsed value', () {
    expect(formatGroupedAmount('1000000.0500'), '1,000,000.0500');
    expect(formatGroupedAmount('10000.'), '10,000.');
    expect(formatGroupedAmount('.00000001'), '.00000001');
    expect(parseAmount('1,000,000.0500'), 1000000.05);
    expect(formatGroupedAmount(''), '');
  });
  test('formatter handles paste, middle edits and backspace across commas', () {
    const formatter = GroupedAmountInputFormatter();
    final pasted = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(
            text: '1000000.0500',
            selection: TextSelection.collapsed(offset: 12)));
    expect(pasted.text, '1,000,000.0500');
    expect(pasted.selection.extentOffset, pasted.text.length);
    final edited = formatter.formatEditUpdate(
        const TextEditingValue(
            text: '1,234', selection: TextSelection.collapsed(offset: 2)),
        const TextEditingValue(
            text: '1234', selection: TextSelection.collapsed(offset: 1)));
    expect(edited.text, '234');
    expect(edited.selection.extentOffset, 0);
    final middle = formatter.formatEditUpdate(
        const TextEditingValue(
            text: '12,345', selection: TextSelection.collapsed(offset: 2)),
        const TextEditingValue(
            text: '129,345', selection: TextSelection.collapsed(offset: 3)));
    expect(middle.text, '129,345');
    expect(middle.selection.extentOffset, 3);
    expect(
        formatter.formatEditUpdate(
            pasted, const TextEditingValue(text: '1.2.3')),
        pasted);
  });
  testWidgets('top toast replaces previous notice, ignores taps and expires',
      (tester) async {
    late BuildContext context;
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (c) {
      context = c;
      return const Scaffold(body: Center(child: Text('Page')));
    })));
    showDavoToast(context, 'First notice');
    showDavoToast(context, 'Second notice');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.text('First notice'), findsNothing);
    expect(find.text('Second notice'), findsOneWidget);
    expect(tester.getRect(find.text('Second notice')).bottom, lessThan(130));
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();
    expect(find.text('Second notice'), findsNothing);
    showDavoToast(context, 'Dispose notice');
    await tester.pump();
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 4));
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'touch outside input dismisses keyboard without blocking next field',
      (tester) async {
    await tester.pumpWidget(const DavochainApp());
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed(AppRoutes.login);
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.tap(fields.first);
    await tester.pump();
    expect(tester.testTextInput.isVisible, isTrue);
    await tester.tap(find.text('Welcome back!'));
    await tester.pump();
    expect(tester.testTextInput.isVisible, isFalse);
    await tester.tap(fields.first);
    await tester.pump();
    await tester.tap(fields.last);
    await tester.pump();
    expect(tester.widget<TextField>(fields.last).focusNode!.hasFocus, isTrue);
    expect(tester.testTextInput.isVisible, isTrue);
    expect(tester.takeException(), isNull);
  });
}
