/// Expand the supplied double's shortest decimal representation without
/// introducing rounding to four places or artificial binary tail digits.
String formatCryptoQuantity(double value) {
  final raw = value.toString();
  if (!raw.contains('e')) {
    return raw.endsWith('.0') ? raw.substring(0, raw.length - 2) : raw;
  }
  final parts = raw.split('e');
  final exponent = int.parse(parts[1]);
  final mantissa = parts[0];
  final negative = mantissa.startsWith('-');
  final absolute = negative ? mantissa.substring(1) : mantissa;
  final dot = absolute.indexOf('.');
  final digits = absolute.replaceAll('.', '');
  final point = (dot < 0 ? absolute.length : dot) + exponent;
  final expanded = point <= 0
      ? '0.${'0' * -point}$digits'
      : point >= digits.length
          ? '$digits${'0' * (point - digits.length)}'
          : '${digits.substring(0, point)}.${digits.substring(point)}';
  return '${negative ? '-' : ''}$expanded';
}

