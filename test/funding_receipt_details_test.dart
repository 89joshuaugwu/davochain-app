import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/funding/funding_outcomes.dart';
import 'package:davochain/features/profile_settings/presentation/settings_personal_action_flows.dart';
import 'package:davochain/shared/receipts/receipt_record.dart';
import 'package:davochain/shared/receipts/transaction_record_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final record = FundingRecord(
    id: 'accepted-withdrawal-100',
    direction: FundingDirection.withdrawal,
    status: FundingStatus.pending,
    amount: .00001234,
    currency: 'BTC',
    destination: 'bc1qprivateaddress123456789',
    network: 'Bitcoin',
    transactionHash: 'a' * 64,
    fee: .00000012,
    occurredAt: DateTime(2026, 10, 9, 14, 23),
    preview: true,
  );
  setUp(FundingActivity.reset);

  testWidgets('accepted uppercase hash field offers a validated explorer link',
      (tester) async {
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light,
      home: TransactionRecordDetailsScreen(record: ReceiptRecord(
        id: 'accepted-bitcoin-1', reference: 'provider-bitcoin-1', type: 'Deposit',
        status: ReceiptStatus.completed, occurredAt: DateTime(2026, 10, 9),
        amount: '0.01 BTC', fields: [
          const ReceiptField(label: 'Network', value: 'Bitcoin'),
          ReceiptField(label: 'Transaction Hash', value: 'a' * 64, copyable: true),
        ],
      ))));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('More details').hitTestable(), 100,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('More details'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Transaction Hash').hitTestable(), 100,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Copy link'), findsOneWidget);
    expect(find.text('Share link'), findsOneWidget);
  });

  testWidgets('sub eight decimal funding quantities stay exact in details and receipt',
      (tester) async {
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light,
      home: FundingDetailsScreen(record: FundingRecord(
        id: 'accepted-eth-precision', direction: FundingDirection.withdrawal,
        status: FundingStatus.pending, amount: 1e-9, fee: 2e-10,
        currency: 'ETH', destination: 'Private address', network: 'Ethereum',
        occurredAt: DateTime(2026, 10, 9, 14, 23), preview: true,
      ))));
    await tester.pumpAndSettle();
    expect(find.text('0.000000001 ETH'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('More details').hitTestable(), 100,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('More details'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Fee').hitTestable(), 100,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('0.0000000002 ETH'), findsOneWidget);
    await tester.tap(find.text('Share Receipt'));
    await tester.pumpAndSettle();
    expect(find.text('0.000000001 ETH'), findsWidgets);
    expect(find.text('0.0000000002 ETH'), findsWidgets);
  });

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: FundingDetailsScreen(record: record),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('pending funding routes its accepted facts to a receipt',
      (tester) async {
    await open(tester);
    expect(find.text('Pending'), findsWidgets);
    expect(find.text('0.00001234 BTC'), findsOneWidget);
    expect(find.text('Share Receipt'), findsOneWidget);
    await tester.tap(find.text('Share Receipt'));
    await tester.pumpAndSettle();
    expect(find.text('0.00001234 BTC'), findsWidgets);
    expect(find.text('Pending'), findsWidgets);
    expect(find.textContaining('Preview').hitTestable(), findsNothing);
    expect(find.text(record.destination), findsNothing);
  });

  testWidgets('report issue prefills transaction context without submitting',
      (tester) async {
    await open(tester);
    await tester.scrollUntilVisible(find.text('Report Issue').hitTestable(), 180,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Report Issue'));
    await tester.pumpAndSettle();
    expect(find.byType(EmailSupportScreen), findsOneWidget);
    final entries =
        tester.widgetList<TextField>(find.byType(TextField)).toList();
    expect(entries[0].controller!.text, contains('Withdrawal'));
    expect(entries[1].controller!.text, record.id);
    expect(entries[2].controller!.text, contains('Pending'));
    expect(entries[2].controller!.text, contains('0.00001234 BTC'));
    expect(entries[2].controller!.text, isNot(contains(record.destination)));
    expect(find.text('Request submitted'), findsNothing);
  });

  testWidgets(
      'expanded crypto fee keeps currency and timeline has no settlement promise',
      (tester) async {
    await open(tester);
    await tester.scrollUntilVisible(find.text('More details').hitTestable(), 100,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('More details'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Fee').hitTestable(), 100,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('0.00000012 BTC'), findsOneWidget);
    expect(find.text('Transaction ID'), findsOneWidget);
    expect(find.text('Completed'), findsNothing);
    expect(find.textContaining('24 hours'), findsNothing);
    await tester.scrollUntilVisible(find.text('Awaiting confirmation').hitTestable(), 100,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Awaiting confirmation'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('crypto accepted route exposes asset and counterparties before expanding',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: TransactionRecordDetailsScreen(record: ReceiptRecord(
        id: 'accepted-buy-1', reference: 'provider-reference-1',
        type: 'Buy', status: ReceiptStatus.pending,
        occurredAt: DateTime(2026, 10, 9, 14, 23), amount: '0.00001234 BTC',
        fields: const [
          ReceiptField(label: 'Asset', value: 'Bitcoin'),
          ReceiptField(label: 'From', value: 'Naira wallet'),
          ReceiptField(label: 'To', value: 'Bitcoin wallet'),
          ReceiptField(label: 'Amount paid', value: '₦10,000.00'),
        ],
      )),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Bitcoin'), findsOneWidget);
    expect(find.text('Naira wallet'), findsOneWidget);
    expect(find.text('Bitcoin wallet'), findsOneWidget);
    expect(find.text('₦10,000.00'), findsOneWidget);
  });

  testWidgets('funding acceptance updates status and recorded date together', (tester) async {
    await open(tester);
    FundingActivity.accept(FundingRecord(
      id: 'accepted-withdrawal-100', direction: FundingDirection.withdrawal,
      status: FundingStatus.completed, amount: .00001234, currency: 'BTC',
      destination: 'bc1qprivateaddress123456789', network: 'Bitcoin',
      occurredAt: DateTime(2026, 10, 9, 15, 40), preview: true,
    ));
    await tester.pumpAndSettle();
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('9 Oct 2026 · 15:40'), findsOneWidget);
    expect(find.text('9 Oct 2026 · 14:23'), findsNothing);
    await tester.tap(find.text('Share Receipt'));
    await tester.pumpAndSettle();
    expect(find.text('Completed'), findsWidgets);
    expect(find.text('9 Oct 2026 · 15:40'), findsWidgets);
    expect(find.text('Pending'), findsNothing);
  });

  for (final theme in [AppTheme.light, AppTheme.dark]) {
    testWidgets('details keeps actionable footer at 320px and double text ${theme.brightness}',
        (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(theme: theme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(2)),
          child: child!),
        home: FundingDetailsScreen(record: record)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Share Receipt').hitTestable(), findsOneWidget);
      expect(find.text('Done').hitTestable(), findsOneWidget);
      await tester.scrollUntilVisible(find.text('More details').hitTestable(), 120,
          scrollable: find.byType(Scrollable).first);
      await tester.tap(find.text('More details'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Transaction hash').hitTestable(), 120,
          scrollable: find.byType(Scrollable).first);
      expect(find.byTooltip('Copy Transaction hash'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
