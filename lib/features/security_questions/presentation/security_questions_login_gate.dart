import 'package:flutter/material.dart';
import '../../../core/navigation/app_page_route.dart';
import '../security_questions_service.dart';
import 'security_questions_screens.dart';

/// Returns acceptance only after the additional question check. No auth tokens
/// are issued by this session-only frontend demonstration.
Future<bool> checkSecurityQuestions(BuildContext context) async {
  final service = SecurityQuestionsService.instance;
  if (!service.enabled) return true;
  var completed = false;
  final accepted = await Navigator.of(context).push<bool>(AppPageRoute<bool>(
    builder: (challengeContext) => SecurityQuestionsChallengeScreen(
      service: service,
      onVerified: () {
        if (completed || !challengeContext.mounted) return;
        completed = true;
        Navigator.of(challengeContext).pop(true);
      },
      onCancel: () {
        if (completed || !challengeContext.mounted) return;
        completed = true;
        Navigator.of(challengeContext).pop(false);
      },
    ),
  ));
  return accepted == true && context.mounted;
}
