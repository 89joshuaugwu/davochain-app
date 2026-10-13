import 'package:davochain/features/profile_settings/verification_media/face_capture_reveal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('real photo scan completes once after its short reveal',
      (tester) async {
    var completions = 0;
    await tester.pumpWidget(MaterialApp(
        home: SizedBox(
            width: 300,
            height: 380,
            child: FaceCaptureReveal(
                image: const AssetImage(
                    'assets/figma_exact/verification_901d8.png'),
                onDone: () => completions++))));
    expect(find.byType(Image), findsOneWidget);
    expect(completions, 0);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 425));
    expect(completions, 0);
    await tester.pump(const Duration(milliseconds: 500));
    expect(completions, 1);
    await tester.pump(const Duration(seconds: 1));
    expect(completions, 1);
  });
  testWidgets('reduced motion completes without decorative scan delay',
      (tester) async {
    var completions = 0;
    await tester.pumpWidget(MaterialApp(
        home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: SizedBox(
                width: 300,
                height: 380,
                child: FaceCaptureReveal(
                    image: const AssetImage(
                        'assets/figma_exact/verification_901d8.png'),
                    onDone: () => completions++)))));
    expect(completions, 1);
    await tester.pump();
    expect(completions, 1);
  });
}
