import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/shared/widgets/auth_widgets.dart';
import 'package:davochain/shared/widgets/davo_sheet_header.dart';
import 'package:davochain/shared/widgets/transaction_pin_entry.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('auth and sheet back controls provide 48 pixel targets',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: const DavoAuthScaffold(child: SizedBox())));
    expect(tester.getSize(find.byTooltip('Back')).height,
        greaterThanOrEqualTo(48));
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: DavoSheetHeader(title: 'Choose'))));
    expect(tester.getSize(find.byTooltip('Close')).height,
        greaterThanOrEqualTo(48));
  });

  testWidgets(
      'auth field exposes its label and feedback to assistive technology',
      (tester) async {
    final semantics = tester.ensureSemantics();
    final controller = TextEditingController();
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
            body: DavoTextField(
                label: 'Email address',
                controller: controller,
                errorText: 'Enter a valid email'))));
    final field =
        tester.getSemantics(find.byType(TextField)).getSemanticsData();
    expect(field.label, contains('Email address'));
    final feedback = tester
        .getSemantics(find.text('Enter a valid email'))
        .getSemanticsData();
    expect(feedback.flagsCollection.isLiveRegion, isTrue);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
    semantics.dispose();
  });

  testWidgets('auth feedback animation respects accessible navigation',
      (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
            data: const MediaQueryData(accessibleNavigation: true),
            child: Scaffold(
                body: DavoTextField(
                    label: 'Password',
                    controller: controller,
                    errorText: 'Try again')))));
    expect(
        tester
            .widget<AnimatedContainer>(find.byType(AnimatedContainer))
            .duration,
        Duration.zero);
    expect(tester.widget<AnimatedSize>(find.byType(AnimatedSize)).duration,
        Duration.zero);
    await tester.pumpWidget(const SizedBox());
    controller.dispose();
  });

  testWidgets('PIN keypad semantic actions enter and remove hidden digits',
      (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(MaterialApp(
        theme: AppTheme.light,
        home: TransactionPinEntryScreen(onConfirm: () {})));
    await tester.pumpAndSettle();
    final digit = tester.getSemantics(find.bySemanticsLabel('1'));
    expect(digit.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    // ignore: deprecated_member_use
    tester.binding.pipelineOwner.semanticsOwner!
        .performAction(digit.id, SemanticsAction.tap);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('PIN digit 1, entered'), findsOneWidget);
    final remove =
        tester.getSemantics(find.bySemanticsLabel('Delete PIN digit'));
    // ignore: deprecated_member_use
    tester.binding.pipelineOwner.semanticsOwner!
        .performAction(remove.id, SemanticsAction.tap);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('PIN digit 1, empty'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets(
      'auth buttons and links remain usable with large text on narrow screens',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
      data: const MediaQueryData(textScaler: TextScaler.linear(3)),
      child: Scaffold(
          body: SingleChildScrollView(
              child: Column(children: [
        DavoPrimaryButton(label: 'Continue securely', onPressed: () {}),
        DavoSecondaryButton(label: 'Choose another method', onPressed: () {}),
        LinkText(
            prefix: 'Already have an account?',
            action: 'Sign in',
            onTap: () {}),
      ]))),
    )));

    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(
        tester.getSize(find.byType(DavoPrimaryButton)).height, greaterThan(48));
  });
}
