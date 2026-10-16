import 'package:davochain/features/auth/presentation/verification_flow.dart';
import 'package:davochain/shared/motion/davo_verification_mark.dart';
import 'package:davochain/shared/motion/davo_outcome_artwork.dart';
import 'package:davochain/shared/motion/davo_working_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('verification acknowledgement settles and never holds Continue', (tester) async {
    var continued = 0;
    await tester.pumpWidget(MaterialApp(home: VerificationSuccessScreen(
      kind: VerificationKind.email, onContinue: () => continued++)));
    expect(find.byType(DavoWorkingArtwork), findsOneWidget);
    await tester.tap(find.text('Continue'));
    expect(continued, 1);
    await tester.pump(const Duration(milliseconds: 1600));
    await tester.pumpAndSettle();
    expect(find.byType(DavoWorkingArtwork), findsNothing);
    expect(find.byType(DavoOutcomeArtwork), findsOneWidget);
    expect(tester.widget<DavoOutcomeArtwork>(find.byType(DavoOutcomeArtwork)).progress, 1);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });
  testWidgets('reduced motion shows the final verification mark immediately', (tester) async {
    await tester.pumpWidget(MaterialApp(builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: true), child: child!),
      home: const Scaffold(body: DavoVerificationMark())));
    expect(find.byType(DavoWorkingArtwork), findsNothing);
    expect(tester.widget<DavoOutcomeArtwork>(find.byType(DavoOutcomeArtwork)).progress, 1);
  });
}
