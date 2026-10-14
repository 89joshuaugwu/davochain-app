/// Decimal arithmetic for amounts and quotes. Convert to double only for charts.
enum DecimalRounding { halfUp, floor, ceil }

class ExactDecimal implements Comparable<ExactDecimal> {
  ExactDecimal._(this._coefficient, this._scale);
  final BigInt _coefficient;
  final int _scale;
  static final zero = ExactDecimal._(BigInt.zero, 0);

  static ExactDecimal _normalized(BigInt value, int scale) {
    if (value == BigInt.zero) return zero;
    while (scale > 0 && value.remainder(BigInt.from(10)) == BigInt.zero) {
      value ~/= BigInt.from(10);
      scale--;
    }
    return ExactDecimal._(value, scale);
  }

  factory ExactDecimal.parse(String text) {
    final value = text.trim();
    if (!RegExp(r'^-?\d+(\.\d+)?$').hasMatch(value)) {
      throw FormatException('Invalid decimal', text);
    }
    final parts = value.split('.');
    return _normalized(
        BigInt.parse(parts.join()), parts.length == 1 ? 0 : parts[1].length);
  }

  /// Compatibility ingress; new amount entry paths should pass decimal strings.
  factory ExactDecimal.from(Object value) {
    if (value is ExactDecimal) return value;
    if (value is num && !value.isFinite) {
      throw const FormatException('Nonfinite amount');
    }
    var text = value.toString();
    if (value is num && text.toLowerCase().contains('e')) {
      final parts = text.toLowerCase().split('e');
      final exponent = int.parse(parts[1]);
      final negative = parts[0].startsWith('-');
      final mantissa = negative ? parts[0].substring(1) : parts[0];
      final dot = mantissa.indexOf('.');
      final digits = mantissa.replaceAll('.', '');
      final point = (dot < 0 ? mantissa.length : dot) + exponent;
      text = point <= 0
          ? '0.${'0' * -point}$digits'
          : point >= digits.length
              ? '$digits${'0' * (point - digits.length)}'
              : '${digits.substring(0, point)}.${digits.substring(point)}';
      if (negative) text = '-$text';
    }
    return ExactDecimal.parse(text);
  }

  static BigInt _power(int scale) => BigInt.from(10).pow(scale);
  BigInt _at(int scale) => _coefficient * _power(scale - _scale);
  ExactDecimal operator +(ExactDecimal other) {
    final scale = _scale > other._scale ? _scale : other._scale;
    return _normalized(_at(scale) + other._at(scale), scale);
  }

  ExactDecimal operator -(ExactDecimal other) {
    final scale = _scale > other._scale ? _scale : other._scale;
    return _normalized(_at(scale) - other._at(scale), scale);
  }

  ExactDecimal operator *(ExactDecimal other) =>
      _normalized(_coefficient * other._coefficient, _scale + other._scale);

  static BigInt _rounded(
      BigInt numerator, BigInt denominator, DecimalRounding rounding) {
    if (denominator.isNegative) {
      numerator = -numerator;
      denominator = -denominator;
    }
    final quotient = numerator ~/ denominator;
    final remainder = numerator.remainder(denominator);
    if (remainder == BigInt.zero) return quotient;
    final direction = numerator.isNegative ? -BigInt.one : BigInt.one;
    return switch (rounding) {
      DecimalRounding.floor =>
        numerator.isNegative ? quotient - BigInt.one : quotient,
      DecimalRounding.ceil =>
        numerator.isNegative ? quotient : quotient + BigInt.one,
      DecimalRounding.halfUp => remainder.abs() * BigInt.two >= denominator
          ? quotient + direction
          : quotient,
    };
  }

  ExactDecimal divide(ExactDecimal other,
      {int scale = 18, DecimalRounding rounding = DecimalRounding.halfUp}) {
    if (other.isZero) throw ArgumentError('Division by zero');
    if (scale < 0 || scale > 100) throw RangeError.range(scale, 0, 100);
    final exponent = scale + other._scale - _scale;
    final numerator =
        exponent >= 0 ? _coefficient * _power(exponent) : _coefficient;
    final denominator = exponent >= 0
        ? other._coefficient
        : other._coefficient * _power(-exponent);
    return _normalized(_rounded(numerator, denominator, rounding), scale);
  }

  String toFixed(int scale,
      {DecimalRounding rounding = DecimalRounding.halfUp}) {
    if (scale < 0 || scale > 100) throw RangeError.range(scale, 0, 100);
    final value = scale >= _scale
        ? _at(scale)
        : _rounded(_coefficient, _power(_scale - scale), rounding);
    final digits = value.abs().toString().padLeft(scale + 1, '0');
    final body = scale == 0
        ? digits
        : '${digits.substring(0, digits.length - scale)}.${digits.substring(digits.length - scale)}';
    return '${value.isNegative ? '-' : ''}$body';
  }

  bool get isZero => _coefficient == BigInt.zero;
  bool get isNegative => _coefficient.isNegative;
  ExactDecimal abs() => _normalized(_coefficient.abs(), _scale);
  double toDouble() => double.parse(toString());
  @override
  int compareTo(ExactDecimal other) {
    final scale = _scale > other._scale ? _scale : other._scale;
    return _at(scale).compareTo(other._at(scale));
  }

  @override
  String toString() => toFixed(_scale);
}
