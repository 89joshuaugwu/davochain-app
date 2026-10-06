import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:davochain/features/dashboard/presentation/dashboard_screen.dart';

void main() {
  testWidgets('dashboard exposes primary Davochain actions', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: DavochainDashboardScreen()));
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.text('Available Balance'), findsOneWidget);
    expect(find.text('Deposit'), findsOneWidget);
    expect(find.text('View Portfolio'), findsOneWidget);
    expect(find.text('Assets'), findsOneWidget);
  });
}
