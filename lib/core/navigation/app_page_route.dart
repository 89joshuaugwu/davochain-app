import 'package:flutter/material.dart';

class AppPageRoute<T> extends PageRouteBuilder<T> {
  AppPageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool fullscreenDialog = false,
  }) : super(
          settings: settings,
          fullscreenDialog: fullscreenDialog,
          transitionDuration: const Duration(milliseconds: 440),
          reverseTransitionDuration: const Duration(milliseconds: 330),
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );
            final slide = Tween<Offset>(
              begin: const Offset(.035, .008),
              end: Offset.zero,
            ).animate(curved);
            final scale = Tween<double>(begin: .992, end: 1).animate(curved);
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: slide,
                child: ScaleTransition(scale: scale, child: child),
              ),
            );
          },
        );
}

Future<T?> pushAppPage<T>(BuildContext context, WidgetBuilder builder) {
  return Navigator.of(context).push<T>(AppPageRoute<T>(builder: builder));
}

Future<T?> replaceWithAppPage<T, TO>(BuildContext context, WidgetBuilder builder) {
  return Navigator.of(context).pushReplacement<T, TO>(
    AppPageRoute<T>(builder: builder),
  );
}
