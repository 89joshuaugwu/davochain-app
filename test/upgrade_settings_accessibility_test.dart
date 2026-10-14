import 'dart:ui' show Tristate;
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/profile_settings/presentation/profile_settings_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('notification categories expose selection and a 48 pixel tap target', (tester) async {
    final semantics = tester.ensureSemantics();
    try {
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: const NotificationCenterScreen()));
    await tester.pumpAndSettle();
    final selected = find.bySemanticsLabel('All notifications');
    expect(selected, findsOneWidget);
    expect(tester.getSemantics(selected).getSemanticsData().flagsCollection.isSelected, Tristate.isTrue);
    expect(tester.getSize(selected).height, greaterThanOrEqualTo(48));
    final security = find.bySemanticsLabel('Security notifications');
    await tester.tap(security);
    await tester.pumpAndSettle();
    expect(tester.getSemantics(security).getSemanticsData().flagsCollection.isSelected, Tristate.isTrue);
    expect(find.text('Deposit Received'), findsNothing);
    expect(find.text('New Login Detected'), findsOneWidget);
    } finally { semantics.dispose(); }
  });
}
