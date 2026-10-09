import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/core/preview/settings_preview_session.dart';
import 'package:davochain/features/profile_settings/presentation/support_conversation_screens.dart';
import 'package:davochain/features/profile_settings/presentation/settings_personal_action_flows.dart';
import 'package:davochain/shared/widgets/auth_widgets.dart';

void main() {
  setUp(SettingsPreviewSession.instance.reset);
  tearDown(SettingsPreviewSession.instance.reset);
  Future<void> screen(WidgetTester tester, Widget widget,
      {double scale = 1}) async {
    tester.view.physicalSize = const Size(320, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: MediaQuery(
            data: MediaQueryData(
                size: const Size(320, 720),
                textScaler: TextScaler.linear(scale)),
            child: widget)));
    await tester.pumpAndSettle();
  }

  testWidgets('empty messages CTA remains one line at compact width',
      (tester) async {
    await screen(tester, const SupportMessagesScreen());
    expect(find.text('No Messages'), findsOneWidget);
    final text = tester.widget<Text>(find.text('Ask a question'));
    expect(text.maxLines, 1);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Ask a question'));
    await tester.pumpAndSettle();
    expect(find.text('Callie'), findsOneWidget);
    expect(find.byKey(const ValueKey('support-composer')), findsOneWidget);
  });
  testWidgets(
      'composer is pinned and saves messages for revisit without delivery claim',
      (tester) async {
    await screen(tester, const SupportChatScreen());
    final initialY =
        tester.getTopLeft(find.byKey(const ValueKey('support-composer'))).dy;
    await tester.drag(find.byType(ListView), const Offset(0, -350));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.byKey(const ValueKey('support-composer'))).dy,
        initialY);
    await tester.enterText(
        find.byType(TextField), 'How can I track my crypto order?');
    await tester.pump();
    await tester.tap(find.byTooltip('Save message'));
    await tester.pumpAndSettle();
    expect(SettingsPreviewSession.instance.tickets, hasLength(1));
    expect(find.textContaining('Pending · PREVIEW-SUPPORT-'), findsOneWidget);
    await screen(tester, const SupportMessagesScreen());
    expect(find.text('How can I track my crypto order?'), findsOneWidget);
    await tester.tap(find.text('How can I track my crypto order?'));
    await tester.pumpAndSettle();
    expect(find.textContaining('live support and AI replies are not connected'),
        findsOneWidget);
    await tester.scrollUntilVisible(
        find.text('How can I track my crypto order?'), 180,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('How can I track my crypto order?'), findsOneWidget);
  });
  testWidgets(
      'support screens tolerate enlarged fonts and capability actions explain preview',
      (tester) async {
    await screen(tester, const SupportChatScreen(), scale: 1.5);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Attach a file'));
    await tester.pumpAndSettle();
    expect(find.text('Attachments'), findsOneWidget);
    expect(
        find.textContaining('not available in this preview'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
      'email reference form keeps validation and truthful pending result',
      (tester) async {
    await screen(tester, const EmailSupportScreen());
    expect(find.text('Email Us'), findsOneWidget);
    expect(find.text('OPTIONAL'), findsOneWidget);
    expect(find.text('e.g. #VP-8291'), findsOneWidget);
    expect(
        tester
            .widget<DavoPrimaryButton>(find.byType(DavoPrimaryButton))
            .enabled,
        isFalse);
    await tester.enterText(find.byType(TextField).at(0), 'Order question');
    await tester.enterText(
        find.byType(TextField).at(2), 'Please help me track my order.');
    await tester.pump();
    await tester.tap(find.text('Submit request'));
    await tester.pumpAndSettle();
    expect(
        find.text('Pending in this preview session. No email has been sent.'),
        findsOneWidget);
    expect(SettingsPreviewSession.instance.tickets, hasLength(1));
    expect(tester.takeException(), isNull);
  });
  testWidgets('an email subject cannot masquerade as a chat conversation',
      (tester) async {
    SettingsPreviewSession.instance.acceptTicket(SupportTicket(
        reference: 'PREVIEW-EMAIL',
        subject: 'Chat: question about my order',
        message: 'Email request',
        orderId: 'VP-123',
        createdAt: DateTime(2026)));
    await screen(tester, const SupportMessagesScreen());
    expect(find.text('No Messages'), findsOneWidget);
  });
  testWidgets('revisiting a conversation restores every accepted message',
      (tester) async {
    await screen(tester, const SupportChatScreen());
    for (final message in [
      'First conversation message',
      'Second conversation message'
    ]) {
      await tester.enterText(find.byType(TextField), message);
      await tester.pump();
      await tester.tap(find.byTooltip('Save message'));
      await tester.pumpAndSettle();
    }
    await screen(tester, const SupportMessagesScreen());
    expect(find.byType(ListTile), findsOneWidget);
    await tester.tap(find.text('Second conversation message'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
        find.text('First conversation message'), 180,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('First conversation message'), findsOneWidget);
  });
}
