import 'package:flutter/material.dart';
import '../../core/theme/davo_colors.dart';

/// Protects selection controls while letting tall sheets scroll on short views.
/// Use with showModalBottomSheet(useSafeArea: true) for the top cutout inset.
class DavoSafeSelectionSheet extends StatelessWidget {
  const DavoSafeSelectionSheet(
      {super.key, required this.child, this.backgroundColor});
  final Widget child;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) => Padding(
        padding:
            EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Material(
            color: backgroundColor ?? DavoColors.of(context).sheetSurface,
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(child: child),
            ),
          ),
        ),
      );
}
