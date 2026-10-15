import 'package:flutter/material.dart';
import '../../shared/widgets/davo_main_shell.dart';
import '../../features/gift_cards/presentation/gift_card_models.dart';
import 'app_page_route.dart';
import 'app_routes.dart';

/// Discards completed transaction forms without changing accepted wallet data.
/// An optional new flow sits above a clean hub, so Back never restores a draft.
void finishDavoTransaction(BuildContext context,
    {int tab = 0, GiftCardMode? giftMode, WidgetBuilder? start}) {
  final navigator = Navigator.of(context);
  navigator.pushAndRemoveUntil<void>(
      AppPageRoute<void>(
          settings: const RouteSettings(name: AppRoutes.dashboard),
          builder: (_) => DavoMainShell(initialIndex: tab, giftMode: giftMode)),
      (route) => false);
  if (start != null) navigator.push<void>(AppPageRoute<void>(builder: start));
}
