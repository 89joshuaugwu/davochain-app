import '../../../core/providers/reactive_builder.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/davo_sheet_header.dart';
import 'settings_articles.dart';

/// Optional published content takes precedence over the bundled editorial copy.
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
      backgroundColor: DavoColors.of(context).sheetSurface,
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
            heightFactor: .86,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                child: Column(children: [
                  DavoSheetHeader(title: title),
                  Divider(height: 24, color: DavoColors.of(context).divider),
                  Expanded(
                      child: DavoValueListenableBuilder<Map<String, String>>(
                    valueListenable: SettingsContentStore.content,
                    builder: (context, content, _) {
                      final published = content[title];
                      if (published != null && published.trim().isNotEmpty) {
                        return SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 28),
                            child: SelectableText(published,
                                textAlign: TextAlign.justify,
                                style: TextStyle(
                                    fontSize: 14,
                                    height: 1.65,
                                    color: DavoColors.of(context).body)));
                      }
                      final article = settingsArticles[title];
                      if (article == null) return const SizedBox.shrink();
                      return _ArticleReader(article: article);
                    },
                  )),
                ])),
          )),
    );

class _ArticleReader extends StatelessWidget {
  const _ArticleReader({required this.article});
  final SettingsArticle article;
  @override
  Widget build(BuildContext context) {
    final colors = DavoColors.of(context);
    return SelectionArea(
        child: ListView(
            padding: const EdgeInsets.only(top: 4, bottom: 32),
            children: [
          Semantics(
              header: true,
              child: Text(article.heading,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontSize: 22,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                      color: colors.ink))),
          const SizedBox(height: 12),
          Text(article.introduction,
              textAlign: TextAlign.justify,
              style: TextStyle(
                  fontSize: 14, height: 1.65, color: colors.bodyMuted)),
          const SizedBox(height: 28),
          ...article.sections.indexed.map((entry) {
            final section = entry.$2;
            if (article.questions) {
              return Column(children: [
                Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      key: PageStorageKey(section.heading),
                      initiallyExpanded: entry.$1 == 0,
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: const EdgeInsets.only(bottom: 20),
                      iconColor: colors.link,
                      collapsedIconColor: colors.bodyMuted,
                      title: Semantics(
                          header: true,
                          child: Text(section.heading,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  fontWeight: FontWeight.w600,
                                  color: colors.ink))),
                      children: [
                        Align(
                            alignment: Alignment.centerLeft,
                            child: Text(section.body,
                                textAlign: TextAlign.justify,
                                style: TextStyle(
                                    fontSize: 14,
                                    height: 1.65,
                                    color: colors.body)))
                      ],
                    )),
                Divider(height: 1, color: colors.divider),
              ]);
            }
            return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                          header: true,
                          child: Text(section.heading,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  fontSize: 15,
                                  height: 1.4,
                                  fontWeight: FontWeight.w600,
                                  color: colors.ink))),
                      const SizedBox(height: 8),
                      Text(section.body,
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                              fontSize: 14, height: 1.65, color: colors.body)),
                    ]));
          }),
        ]));
  }
}
