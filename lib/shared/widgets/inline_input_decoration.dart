import 'package:flutter/material.dart';

/// For text fields whose surrounding widget already draws the field frame.
/// Every border state is explicit so the app's standalone field theme cannot
/// add a second frame when the field receives focus.
class DavoInlineInputDecoration extends InputDecoration {
  const DavoInlineInputDecoration({
    super.hintText,
    super.hintStyle,
    super.contentPadding = EdgeInsets.zero,
  }) : super(
          isCollapsed: true,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
        );
}
