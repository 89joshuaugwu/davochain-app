import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../shared/motion/davo_motion_policy.dart';
import '../../shared/motion/davo_motion_spec.dart';
import '../theme/app_theme.dart';

class AuthHandoff {
  const AuthHandoff();
}

class AppPageRoute<T> extends MaterialPageRoute<T> {
  AppPageRoute({
    required WidgetBuilder builder,
    super.settings,
    super.fullscreenDialog,
    this.authHandoff = false,
  }) : super(
            builder: (context) => AnnotatedRegion<SystemUiOverlayStyle>(
                  value: SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Theme.of(context).brightness == Brightness.dark ? Brightness.light : Brightness.dark,
                    statusBarBrightness: Theme.of(context).brightness,
                    systemNavigationBarColor: DavoColors.of(context).surface,
                    systemNavigationBarIconBrightness: Theme.of(context).brightness == Brightness.dark ? Brightness.light : Brightness.dark,
                  ),
                  child: builder(context),
                ));

  final bool authHandoff;
  @override
  Duration get transitionDuration => authHandoff
      ? const Duration(milliseconds: 160)
      : super.transitionDuration;
  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (DavoMotionPolicy.reduce(context)) return child;
    if (authHandoff) {
      return FadeTransition(
          opacity: animation.drive(CurveTween(curve: DavoMotionSpec.settle)),
          child: child);
    }
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
