import 'package:davochain/core/preview/preview_auth_state.dart';
import 'package:davochain/core/preview/settings_preview_session.dart';
import 'package:davochain/features/notifications/notification_account_events.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'accepted security mutations notify, initial PIN and rejected bank stay quiet',
    () {
      final events = <String>[];
      NotificationAccountEvents.onAccepted = (title, body) =>
          events.add('$title $body');
      addTearDown(() {
        NotificationAccountEvents.onAccepted = null;
        PreviewAuthState.resetSession();
        SettingsPreviewSession.instance.reset();
      });
      PreviewAuthState.resetSession();
      PreviewAuthState.setTransactionPin('1234');
      expect(events, isEmpty);
      PreviewAuthState.setTransactionPin('5678');
      expect(events, hasLength(1));
      expect(events.single, isNot(contains('1234')));
      expect(events.single, isNot(contains('5678')));
      for (var i = 0; i < 6; i++) {
        PreviewAuthState.verifyTransactionPin('0000');
      }
      expect(
        events.where((event) => event.contains('temporarily locked')),
        hasLength(1),
      );
      final settings = SettingsPreviewSession.instance;
      expect(
        settings.acceptBank(
          const LinkedBank(bank: 'Test', number: 'bad', name: 'QA'),
        ),
        false,
      );
      final before = events.length;
      expect(
        settings.acceptBank(
          const LinkedBank(bank: 'Test', number: '1234567890', name: 'QA'),
        ),
        true,
      );
      expect(
        settings.acceptBank(
          const LinkedBank(bank: 'Test', number: '1234567890', name: 'QA'),
        ),
        false,
      );
      expect(events.length, before + 1);
      expect(events.last, isNot(contains('1234567890')));
      settings.markPasswordChanged();
      settings.markPasswordChanged();
      expect(
        events.where((event) => event.startsWith('Password changed')),
        hasLength(2),
      );
    },
  );
}
