import 'package:davochain/core/theme/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:davochain/shared/widgets/davo_resend_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await (FontLoader('Sora')
          ..addFont(rootBundle.load('assets/fonts/sora/Sora-Variable.ttf')))
        .load();
  });
  Future<void> open(WidgetTester tester, double width, double scale) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: Center(
            child: SizedBox(
              width: width,
              child: DavoResendRow(
                prompt: const Text('Didn\u2019t get a code?'),
                resend: TextButton(
                  onPressed: () {},
                  child: const Text('Resend Code'),
                ),
                countdown: const Text('0:30'),
              ),
            ),
          ),
        ),
      ),
    ));
  }

  testWidgets(
      'resend follows the prompt while only countdown sits at the right edge',
      (tester) async {
    await open(tester, 360, 1);
    final row = tester.getRect(find.byType(DavoResendRow));
    final timer = tester.getRect(find.text('0:30'));
    final prompt = tester.getRect(find.text('Didn\u2019t get a code?'));
    expect(timer.right, closeTo(row.right, 0.1));
    expect(timer.center.dy, closeTo(prompt.center.dy, 0.1));
    final resend = tester.getRect(find.text('Resend Code'));
    expect(resend.right, lessThan(timer.left));
    expect(resend.left - prompt.right, lessThan(32));
    expect(tester.takeException(), isNull);
  });

  testWidgets('large text wraps actions while keeping countdown at right edge',
      (tester) async {
    await open(tester, 240, 2);
    final row = tester.getRect(find.byType(DavoResendRow));
    final timer = tester.getRect(find.text('0:30'));
    final prompt = tester.getRect(find.text('Didn\u2019t get a code?'));
    expect(prompt.left, closeTo(row.left, 0.1));
    expect(timer.right, closeTo(row.right, 0.1));
    expect(timer.top, greaterThan(prompt.bottom));
    expect(tester.takeException(), isNull);
  });
}
