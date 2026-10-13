import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:davochain/features/funding/funding_outcomes.dart';
import 'package:davochain/shared/receipts/receipt_activity.dart';

/// Preview timers deliberately outlive receipt pages in the app. Tests close
/// the local session before Flutter verifies that their fake clock is empty.
void receiptTestWidgets(String description, WidgetTesterCallback callback) {
  testWidgets(description, (tester) async {
    FundingActivity.reset();
    ReceiptActivity.reset();
    try {
      await callback(tester);
    } finally {
      await tester.pumpWidget(const SizedBox.shrink());
      FundingActivity.reset();
      ReceiptActivity.reset();
    }
  });
}
