import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppPageRoute<T> extends MaterialPageRoute<T> {
  AppPageRoute({
    required WidgetBuilder builder,
    super.settings,
    super.fullscreenDialog,
  }) : super(
            builder: (context) => AnnotatedRegion<SystemUiOverlayStyle>(
                  value: const SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.dark,
                    statusBarBrightness: Brightness.light,
                    systemNavigationBarColor: Colors.white,
                    systemNavigationBarIconBrightness: Brightness.dark,
                  ),
                  child: builder(context),
                ));

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return super
        .buildTransitions(context, animation, secondaryAnimation, child);
  }
}

Future<T?> pushAppPage<T>(BuildContext context, WidgetBuilder builder) {
  return Navigator.of(context).push<T>(AppPageRoute<T>(builder: builder));
}

Future<T?> replaceWithAppPage<T, TO>(
    BuildContext context, WidgetBuilder builder) {
  return Navigator.of(context).pushReplacement<T, TO>(
    AppPageRoute<T>(builder: builder),
  );
}
