import 'package:davochain/core/theme/app_theme.dart';
import 'package:davochain/shared/widgets/auth_widgets.dart';
import 'package:davochain/shared/widgets/davo_receipt_export_frame.dart';
import 'package:davochain/shared/widgets/davo_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dark text, hint, link and status contrast against surfaces', () {
    final c = DavoColors.dark;
    double ratio(Color a, Color b) {
      final x = a.computeLuminance(), y = b.computeLuminance();
      return (x > y ? x + .05 : y + .05) / (x > y ? y + .05 : x + .05);
    }
    for (final color in [c.ink,c.bodyMuted,c.muted,c.link,c.success,c.warning,c.danger]) {
      expect(ratio(color,c.surface), greaterThanOrEqualTo(4.5));
      expect(ratio(color,c.fieldFill), greaterThanOrEqualTo(4.5));
    }
    expect(ratio(Colors.white,AppColors.primary), greaterThanOrEqualTo(4.5));
  });

  testWidgets('dark auth shell and field render without pale islands', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(MaterialApp(theme: AppTheme.dark, home: DavoAuthScaffold(
      child: DavoTextField(label:'Password', hint:'Enter password', controller:controller),
    )));
    await tester.pumpAndSettle();
    expect(tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor, DavoColors.dark.surface);
    expect(tester.widget<TextField>(find.byType(TextField)).style!.color, DavoColors.dark.bodyMuted);
    expect(tester.takeException(),isNull);
  });

  testWidgets('receipt paper and ink stay light in a dark app', (tester) async {
    DavoColors? paper;
    await tester.pumpWidget(MaterialApp(theme:AppTheme.dark, home:DavoReceiptExportFrame(
      receiptType:'Test', receipt:Builder(builder:(context) {
        paper=DavoColors.of(context);
        return Text('Receipt',style:TextStyle(color:paper!.ink));
      }),
    )));
    expect(paper!.surface,Colors.white);
    expect(paper!.ink,AppColors.ink);
    expect(tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,DavoColors.dark.canvas);
    expect(tester.takeException(),isNull);
  });

  testWidgets('dark result supports reduced motion and large text', (tester) async {
    await tester.pumpWidget(MaterialApp(theme:AppTheme.dark, builder:(context,child)=>MediaQuery(
      data:MediaQuery.of(context).copyWith(disableAnimations:true,textScaler:const TextScaler.linear(2)),child:child!),
      home:const DavoResultScreen(title:'Submitted',message:'Pending review',actions:Text('Done')),
    ));
    await tester.pumpAndSettle();
    expect(tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,DavoColors.dark.surface);
    expect(tester.takeException(),isNull);
  });
}
