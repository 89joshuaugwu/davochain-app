import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/profile_settings/presentation/profile_settings_flow.dart';
import 'package:davochain/shared/widgets/davo_bank_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('PIN verification resend waits 30 seconds and resets after resend',
      (tester) async {
    var now = DateTime(2026, 10, 8);
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light,
      home: VerifyPinCodeScreen(email: true, now: () => now)));
    final resend = find.widgetWithText(TextButton, 'Resend Code');
    expect(tester.widget<TextButton>(resend).onPressed, isNull);
    expect(find.text('0:30'), findsOneWidget);
    now = now.add(const Duration(seconds: 29));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('0:01'), findsOneWidget);
    expect(tester.widget<TextButton>(resend).onPressed, isNull);
    now = now.add(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(tester.widget<TextButton>(resend).onPressed, isNotNull);
    await tester.tap(resend);
    await tester.pump();
    expect(find.text('0:30'), findsOneWidget);
    expect(tester.widget<TextButton>(resend).onPressed, isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 31));
    expect(tester.takeException(), isNull);
  });

  testWidgets('bank search filters and offers recovery on narrow keyboard layout',
      (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(viewInsets: const EdgeInsets.only(bottom: 260)),
        child: child!,
      ),
      home: const AddBankAccountScreen(),
    ));
    await tester.enterText(find.byType(TextField), '  kuda  ');
    await tester.pump();
    expect(find.text('Kuda Bank'), findsOneWidget);
    expect(find.text('Access Bank'), findsNothing);
    expect(find.byType(DavoBankLogo), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'missing');
    await tester.pump();
    expect(find.text('No banks found. Try another name.'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });

  testWidgets('unavailable bank artwork uses a neutral single initial', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Scaffold(
      body: DavoBankLogo(bankName: 'AAA Finance'),
    )));
    expect(find.text('A'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });
}
