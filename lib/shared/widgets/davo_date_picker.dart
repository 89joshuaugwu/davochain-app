import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import 'auth_widgets.dart';

Future<DateTime?> showDavoDatePicker(BuildContext context, {required String title, DateTime? initialDate, required DateTime firstDate, required DateTime lastDate}) {
 FocusManager.instance.primaryFocus?.unfocus();
 final initial = initialDate ?? lastDate;
 var selected = initial.isBefore(firstDate) ? firstDate : initial.isAfter(lastDate) ? lastDate : initial;
 return showModalBottomSheet<DateTime>(context: context, isScrollControlled: true, useSafeArea: true,
  backgroundColor: Colors.white, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
  builder: (sheetContext) => SafeArea(top: false, child: Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 20), child: Column(mainAxisSize: MainAxisSize.min, children: [
   Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFD9DEEA), borderRadius: BorderRadius.circular(4))),
   Row(children: [Expanded(child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.ink))), IconButton(tooltip: 'Close date picker', onPressed: () => Navigator.pop(sheetContext), icon: const Icon(Icons.close))]),
   SizedBox(height: 216, child: CupertinoTheme(data: const CupertinoThemeData(primaryColor: AppColors.primary), child: CupertinoDatePicker(
    mode: CupertinoDatePickerMode.date, initialDateTime: selected, minimumDate: firstDate, maximumDate: lastDate,
    onDateTimeChanged: (date) => selected = date,
   ))),
   const SizedBox(height: 16),
   DavoPrimaryButton(label: 'Select date', onPressed: () => Navigator.pop(sheetContext, selected)),
  ]))),
 );
}
