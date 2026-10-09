import 'dart:async';

import 'package:davochain/core/preview/settings_preview_session.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/profile_settings/presentation/settings_action_flows.dart';
import 'package:davochain/shared/widgets/auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Gateway extends PreviewSettingsGateway {
  _Gateway({this.resolve, this.link});
  final Future<LinkedBank> Function(String, String)? resolve;
  final Future<void> Function(LinkedBank)? link;

  @override
  Future<LinkedBank> resolveBank(String bank, String number) =>
      resolve?.call(bank, number) ??
      Future.value(
          LinkedBank(bank: bank, number: number, name: 'Resolved name'));

  @override
  Future<void> linkBank(LinkedBank account) =>
      link?.call(account) ?? Future.value();
}

void main() {
  final session = SettingsPreviewSession.instance;
  setUp(session.reset);
  tearDown(session.reset);

  Future<void> enterNumber(WidgetTester tester, _Gateway gateway,
      {GlobalKey<NavigatorState>? navigator,
      String bank = 'Kuda Bank',
      String number = '1234567890',
      double scale = 1}) async {
    await tester.pumpWidget(MaterialApp(
      navigatorKey: navigator,
      theme: AppTheme.light,
      builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!),
      home: AddBankAccountScreen(gateway: gateway),
    ));
    await tester.enterText(find.byType(TextField), bank);
    await tester.pump();
    final bankRow =
        find.descendant(of: find.byType(ListTile), matching: find.text(bank));
    await tester.ensureVisible(bankRow);
    await tester.tap(bankRow);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), number);
    await tester.pump();
  }

  Future<void> review(WidgetTester tester, _Gateway gateway,
      {GlobalKey<NavigatorState>? navigator,
      String bank = 'Kuda Bank',
      String number = '1234567890',
      double scale = 1}) async {
    await enterNumber(tester, gateway,
        navigator: navigator, bank: bank, number: number, scale: scale);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review account'));
    await tester.pumpAndSettle();
  }

  testWidgets('late account resolution cannot replace a newer number',
      (tester) async {
    final first = Completer<LinkedBank>();
    final second = Completer<LinkedBank>();
    final requests = <String>[];
    final gateway = _Gateway(resolve: (bank, number) {
      requests.add(number);
      return requests.length == 1 ? first.future : second.future;
    });
    await enterNumber(tester, gateway);
    await tester.enterText(find.byType(TextField), '0987654321');
    await tester.pump();
    second.complete(const LinkedBank(
        bank: 'Kuda Bank', number: '0987654321', name: 'Newest account'));
    await tester.pumpAndSettle();
    first.complete(const LinkedBank(
        bank: 'Kuda Bank', number: '1234567890', name: 'Stale account'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Newest account'), findsOneWidget);
    expect(find.textContaining('Stale account'), findsNothing);
    await tester.tap(find.text('Review account'));
    await tester.pumpAndSettle();
    expect(find.text('0987654321'), findsOneWidget);
    expect(find.text('1234567890'), findsNothing);
  });

  testWidgets('link failure inserts nothing and retry can link once',
      (tester) async {
    var calls = 0;
    final initial = session.banks.length;
    final gateway = _Gateway(link: (_) async {
      calls++;
      if (calls == 1) throw StateError('offline');
    });
    await review(tester, gateway);
    await tester.tap(find.text('Link account'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Could not link this account'), findsOneWidget);
    expect(session.banks.length, initial);
    await tester.tap(find.text('Link account'));
    await tester.pumpAndSettle();
    expect(find.text('Bank account linked'), findsOneWidget);
    expect(calls, 2);
    expect(session.banks.length, initial + 1);
  });

  testWidgets('closing pending review prevents delayed insertion',
      (tester) async {
    final result = Completer<void>();
    final navigator = GlobalKey<NavigatorState>();
    final initial = session.banks.length;
    await review(tester, _Gateway(link: (_) => result.future),
        navigator: navigator);
    await tester.tap(find.text('Link account'));
    await tester.pump();
    navigator.currentState!.pop();
    await tester.pumpAndSettle();
    result.complete();
    await tester.pumpAndSettle();
    expect(find.text('Account details'), findsOneWidget);
    expect(session.banks.length, initial);
    expect(find.text('Bank account linked'), findsNothing);
  });

  testWidgets('duplicate linked account yields no extra saved row',
      (tester) async {
    final initial = session.banks.length;
    await review(tester, _Gateway(), bank: 'Access Bank', number: '0003487409');
    await tester.tap(find.text('Link account'));
    await tester.pumpAndSettle();
    expect(find.text('This bank account is already linked.'), findsOneWidget);
    expect(session.banks.length, initial);
    expect(find.text('Bank account linked'), findsNothing);
  });

  testWidgets(
      '320px number and review layouts tolerate keyboard and large text',
      (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 260);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await enterNumber(tester, _Gateway(), scale: 2);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
        tester
            .widget<DavoPrimaryButton>(find.byType(DavoPrimaryButton))
            .enabled,
        isTrue);
    await tester.tap(find.text('Review account'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.text('1234567890'));
    expect(find.text('1234567890'), findsOneWidget);
    expect(find.text('Link account').hitTestable(), findsOneWidget);
  });
}
