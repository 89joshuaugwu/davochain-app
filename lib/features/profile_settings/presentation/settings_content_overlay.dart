import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/davo_sheet_header.dart';

/// Replace/publish content from the admin-backed settings endpoint.
/// No legal claims are invented when content has not been supplied.
abstract final class SettingsContentStore {
  static final content = ValueNotifier<Map<String, String>>({});
  static void update(String title, String body) =>
      content.value = {...content.value, title: body};
}

Future<void> showSettingsContent(BuildContext context, String title) =>
    showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: DavoColors.of(context).surface,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        sheetAnimationStyle: MediaQuery.disableAnimationsOf(context)
            ? AnimationStyle.noAnimation
            : const AnimationStyle(
                duration: Duration(milliseconds: 280),
                reverseDuration: Duration(milliseconds: 200)),
        builder: (context) => SafeArea(
            top: false,
            child: FractionallySizedBox(
                heightFactor: .75,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(children: [
                      DavoSheetHeader(title: title),
                      const SizedBox(height: 16),
                      Expanded(
                          child: ValueListenableBuilder<Map<String, String>>(
                              valueListenable: SettingsContentStore.content,
                              builder: (context, content, _) {
                                final body = content[title];
                                return body == null || body.trim().isEmpty
                                    ? Center(
                                        child: Text(
                                            'This content is not available yet.',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                fontFamily: 'Sora',
                                                fontSize: 14,
                                                color: DavoColors.of(context)
                                                    .bodyMuted)))
                                    : SingleChildScrollView(
                                        child: SelectableText(body,
                                            style: TextStyle(
                                                fontFamily: 'Sora',
                                                fontSize: 14,
                                                height: 1.5,
                                                color: DavoColors.of(context)
                                                    .body)));
                              }))
                    ])))));
