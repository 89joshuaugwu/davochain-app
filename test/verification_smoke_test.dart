import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/features/auth/presentation/verification_flow.dart';

void main() {
  testWidgets('email verification renders four OTP inputs', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: VerificationScreen(kind: VerificationKind.email)));
    expect(find.text('Check your inbox'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(4));
    expect(find.text('Submit'), findsOneWidget);
  });

  testWidgets('transaction pin renders secure PIN flow', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TransactionPinScreen()));
    expect(find.text('Great job! Now, secure your account.'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(4));
  });
}
