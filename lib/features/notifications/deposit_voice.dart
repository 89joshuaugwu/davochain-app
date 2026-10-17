enum DepositVoiceStyle {
  natural('Natural', 'Original voice'),
  deep('Deep', 'Lower pitch'),
  warm('Warm', 'Gentle and relaxed'),
  bright('Bright', 'Higher pitch, playful');

  const DepositVoiceStyle(this.label, this.description);
  final String label, description;
  static DepositVoiceStyle parse(Object? value) =>
      values.where((v) => v.name == value).firstOrNull ?? natural;
}

class DepositVoiceOption {
  const DepositVoiceOption({
    required this.id,
    required this.label,
    required this.locale,
    required this.offline,
  });
  final String id, label, locale;
  final bool offline;
}
