import 'dart:async';

import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/shared/widgets/bank_details_share_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dev.fluttercommunity.plus/share');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
    messenger.setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Future<void> mount(WidgetTester tester) => tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
            body: BankDetailsShareButton(details: BankDepositDetails.preview)),
      ));

  testWidgets('dismissal has no success message and pending share is guarded',
      (tester) async {
    final result = Completer<String>();
    var calls = 0;
    MethodCall? request;
    messenger.setMockMethodCallHandler(channel, (call) {
      calls++;
      request = call;
      return result.future;
    });
    await mount(tester);
    await tester.tap(find.text('Share Details'));
    await tester.pump();
    expect(calls, 1);
    expect(request!.method, 'share');
    expect(request!.arguments['text'], BankDepositDetails.preview.shareText);
    expect(request!.arguments['originWidth'], greaterThan(0));
    expect(request!.arguments['originHeight'], greaterThan(0));
    await tester.tap(find.byType(BankDetailsShareButton));
    await tester.pump();
    expect(calls, 1);
    result.complete('dev.fluttercommunity.plus/share/dismissed');
    await tester.pumpAndSettle();
    expect(find.text('Share Details'), findsOneWidget);
    expect(find.textContaining('copied'), findsNothing);
    expect(find.textContaining('sent'), findsNothing);
    expect(find.text('Copy Details'), findsNothing);
  });

  testWidgets('native failure offers real clipboard fallback', (tester) async {
    messenger.setMockMethodCallHandler(channel, (_) async {
      throw PlatformException(code: 'unavailable');
    });
    String? clipboard;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') {
        clipboard = call.arguments['text'] as String;
      }
      return null;
    });
    await mount(tester);
    await tester.tap(find.text('Share Details'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Could not open sharing'), findsOneWidget);
    expect(clipboard, isNull);
    await tester.tap(find.text('Copy Details'));
    await tester.pumpAndSettle();
    expect(clipboard, BankDepositDetails.preview.shareText);
    expect(find.text('Bank details copied.'), findsOneWidget);
  });
}
