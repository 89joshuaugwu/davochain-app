import 'package:flutter/material.dart';

abstract final class DavoMotionPolicy {
  static bool reduce(BuildContext context) =>
      MediaQuery.disableAnimationsOf(context) ||
      MediaQuery.accessibleNavigationOf(context);
}
