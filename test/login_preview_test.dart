import 'package:davochain/core/navigation/app_routes.dart';
import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/features/auth/presentation/login_flow.dart';
import 'package:davochain/shared/widgets/auth_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      routes: {
        AppRoutes.dashboard: (_) =>
            const Scaffold(body: Text('Preview dashboard'))
      },
      home: const LoginScreen(),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('preview login explains demo and rejects malformed email',
      (tester) async {
    await open(tester);
    expect(find.textContaining('sample details'), findsOneWidget);
    await tester.enterText(find.byType(TextField).at(0), 'invalid');
    await tester.enterText(find.byType(TextField).at(1), 'sample-password');
    await tester.pump();
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(find.text('Preview dashboard'), findsNothing);
  });

  testWidgets('valid mock login shows busy state and opens preview once',
      (tester) async {
    await open(tester);
    await tester.enterText(find.byType(TextField).at(0), 'preview@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'sample-password');
    await tester.pump();
    await tester.tap(find.text('Login'));
    await tester.pump();
    expect(
        tester
            .widget<DavoPrimaryButton>(find.byType(DavoPrimaryButton))
            .loading,
        isTrue);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    expect(find.text('Preview dashboard'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
