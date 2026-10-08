import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'auth_widgets.dart';

Future<DateTime?> showDavoDatePicker(BuildContext context, {required String title, DateTime? initialDate, required DateTime firstDate, required DateTime lastDate}) {
 FocusManager.instance.primaryFocus?.unfocus();
 final initial = initialDate ?? lastDate;
 var selected = initial.isBefore(firstDate) ? firstDate : initial.isAfter(lastDate) ? lastDate : initial;
 return showModalBottomSheet<DateTime>(context: context,
    sheetAnimationStyle: (MediaQuery.disableAnimationsOf(context) || MediaQuery.accessibleNavigationOf(context)) ? AnimationStyle.noAnimation : const AnimationStyle(duration: Duration(milliseconds: 280), reverseDuration: Duration(milliseconds: 200)), isScrollControlled: true, useSafeArea: true,
  backgroundColor: DavoColors.of(context).surface, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
  builder: (sheetContext) => SafeArea(top: false, child: Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 20), child: Column(mainAxisSize: MainAxisSize.min, children: [
   Container(width: 40, height: 4, decoration: BoxDecoration(color: DavoColors.of(context).divider, borderRadius: BorderRadius.circular(4))),
   Row(children: [Expanded(child: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: DavoColors.of(context).ink))), IconButton(tooltip: 'Close date picker', onPressed: () => Navigator.pop(sheetContext), icon: const Icon(Icons.close))]),
   SizedBox(height: 216, child: CupertinoTheme(data: CupertinoThemeData(brightness: Theme.of(context).brightness, primaryColor: DavoColors.of(context).link), child: CupertinoDatePicker(
    mode: CupertinoDatePickerMode.date, initialDateTime: selected, minimumDate: firstDate, maximumDate: lastDate,
    onDateTimeChanged: (date) => selected = date,
   ))),
   const SizedBox(height: 16),
   DavoPrimaryButton(label: 'Select date', onPressed: () => Navigator.pop(sheetContext, selected)),
  ]))),
 );
}
