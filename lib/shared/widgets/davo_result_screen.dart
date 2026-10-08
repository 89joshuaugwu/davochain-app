import 'package:flutter/material.dart';

import 'davo_success_mark.dart';

/// Result presentation with immediately available actions and scrollable copy.
/// Callers own outcome wording, navigation and action behavior.
class DavoResultScreen extends StatelessWidget {
  const DavoResultScreen({
    super.key,
    required this.title,
    required this.message,
    required this.actions,
    this.details,
    this.mark = const DavoSuccessMark(),
    this.appBar,
  });

  final String title;
  final String message;
  final Widget actions;
  final Widget? details;
  final Widget mark;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.white,
        appBar: appBar,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: (constraints.maxHeight - 60)
                            .clamp(0, double.infinity),
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              mark,
                              const SizedBox(height: 24),
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Sora',
                                  fontSize: 24,
                                  height: 1.3,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF101828),
                                ),
                              ),
                              if (message.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text(
                                  message,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Sora',
                                    fontSize: 14,
                                    height: 1.6,
                                    color: Color(0xFF475467),
                                  ),
                                ),
                              ],
                              if (details != null) ...[
                                const SizedBox(height: 24),
                                details!,
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: SizedBox(width: double.infinity, child: actions),
                ),
              ),
            ],
          ),
        ),
      );
}
