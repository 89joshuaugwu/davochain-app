import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_theme.dart';

class DavoStatePicker extends StatefulWidget {
  const DavoStatePicker(
      {super.key,
      required this.value,
      required this.states,
      required this.onChanged});
  final String? value;
  final List<String> states;
  final ValueChanged<String> onChanged;
  @override
  State<DavoStatePicker> createState() => _DavoStatePickerState();
}

class _DavoStatePickerState extends State<DavoStatePicker> {
  final _focus = FocusNode();
  late final TextEditingController _text;
  bool _opening = false;
  @override
  void initState() {
    super.initState();
    _text = TextEditingController(text: widget.value ?? '');
  }

  @override
  void didUpdateWidget(DavoStatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) _text.text = widget.value ?? '';
  }

  @override
  void dispose() {
    _focus.dispose();
    _text.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    if (_opening) return;
    _opening = true;
    FocusManager.instance.primaryFocus?.unfocus();
    final selected = await showModalBottomSheet<String>(
        context: context,
    sheetAnimationStyle: (MediaQuery.disableAnimationsOf(context) || MediaQuery.accessibleNavigationOf(context)) ? AnimationStyle.noAnimation : const AnimationStyle(duration: Duration(milliseconds: 280), reverseDuration: Duration(milliseconds: 200)),
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) =>
            _StateSheet(states: widget.states, selected: widget.value));
    if (!mounted) return;
    _opening = false;
    if (selected != null) widget.onChanged(selected);
  }

  @override
  Widget build(BuildContext context) => Focus(
        onKeyEvent: (_, event) {
          if (event is KeyDownEvent &&
              (event.logicalKey == LogicalKeyboardKey.enter ||
                  event.logicalKey == LogicalKeyboardKey.space)) {
            _open();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Semantics(
          label: 'State',
          button: true,
          value: widget.value ?? 'Select state',
          child: TextField(
            controller: _text,
            focusNode: _focus,
            readOnly: true,
            showCursor: false,
            enableInteractiveSelection: false,
            onTap: _open,
            onTapOutside: (_) => _focus.unfocus(),
            style: const TextStyle(
                fontFamily: 'Sora',
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.body),
            decoration: InputDecoration(
              hintText: 'Select state',
              hintStyle: const TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.bodyMuted),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.bodyMuted, size: 22),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5)),
            ),
          ),
        ),
      );
}

class _StateSheet extends StatefulWidget {
  const _StateSheet({required this.states, required this.selected});
  final List<String> states;
  final String? selected;
  @override
  State<_StateSheet> createState() => _StateSheetState();
}

class _StateSheetState extends State<_StateSheet> {
  final _search = TextEditingController();
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final available =
        media.size.height - media.viewInsets.bottom - media.padding.top - 70;
    final height = math.max(160.0, math.min(media.size.height * .7, available));
    final query = _search.text.trim().toLowerCase();
    final matches = widget.states
        .where((state) => state.toLowerCase().contains(query))
        .toList();
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: SafeArea(
          top: false,
          child: SizedBox(
              height: height,
              child: Column(children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 12, 8),
                    child: Row(children: [
                      const Expanded(
                          child: Text('Select state',
                              style: TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.ink))),
                      IconButton(
                          tooltip: 'Close state picker',
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded,
                              size: 22, color: AppColors.body)),
                    ])),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                      onTapOutside: (_) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                      style: const TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.body),
                      decoration: InputDecoration(
                        hintText: 'Search states',
                        hintStyle: const TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 14,
                            color: AppColors.bodyMuted),
                        prefixIcon: const Icon(Icons.search_rounded,
                            size: 20, color: AppColors.bodyMuted),
                        suffixIcon: query.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Clear state search',
                                onPressed: () =>
                                    setState(() => _search.clear()),
                                icon:
                                    const Icon(Icons.close_rounded, size: 20)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: AppColors.border)),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                                color: AppColors.primary, width: 1.5)),
                      ),
                    )),
                const SizedBox(height: 12),
                Expanded(
                    child: matches.isEmpty
                        ? const Center(
                            child: Text('No states found',
                                style: TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 14,
                                    color: AppColors.bodyMuted)))
                        : ListView.builder(
                            key: const ValueKey('state-picker-list'),
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                            itemCount: matches.length,
                            itemBuilder: (context, index) {
                              final state = matches[index];
                              final selected = state == widget.selected;
                              return Semantics(
                                  selected: selected,
                                  child: ListTile(
                                    minTileHeight: 48,
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    selected: selected,
                                    selectedTileColor: AppColors.primarySoft,
                                    title: Text(state,
                                        style: TextStyle(
                                            fontFamily: 'Sora',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: selected
                                                ? AppColors.primary
                                                : AppColors.body)),
                                    trailing: selected
                                        ? const Icon(Icons.check_rounded,
                                            color: AppColors.primary, size: 20)
                                        : null,
                                    onTap: () => Navigator.pop(context, state),
                                  ));
                            },
                          )),
              ]))),
    );
  }
}
