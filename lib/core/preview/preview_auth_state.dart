import 'package:flutter/foundation.dart';

/// Session-only preview gate. Production PIN checks and retry limits must be
/// enforced by the backend; device authentication cannot authorize a payment.
class PreviewAuthState {
  PreviewAuthState._();
  static String? accountEmail;
  static final biometricsEnabled = ValueNotifier<bool>(false);
  static final unlocked = ValueNotifier<bool>(false);
  static final paymentBiometricsEnabled = ValueNotifier<bool>(false);
  static int generation = 0;
  static String? _transactionPin =
      '1234'; // Sample account only, never persisted.
  static int paymentPinFailures = 0;
  static DateTime? _paymentLockUntil;

  static void resetSession({bool samplePin = false}) {
    generation++;
    _transactionPin = samplePin ? '1234' : null;
    paymentPinFailures = 0;
    _paymentLockUntil = null;
    biometricsEnabled.value = false;
    paymentBiometricsEnabled.value = false;
    unlocked.value = false;
  }

  static void setTransactionPin(String pin) {
    if (!RegExp(r'^\d{4}$').hasMatch(pin)) return;
    final locked = paymentsLocked();
    _transactionPin = pin;
    if (!locked) {
      paymentPinFailures = 0;
      _paymentLockUntil = null;
    }
  }

  static bool paymentsLocked({DateTime? now}) {
    if (_paymentLockUntil == null) return false;
    if ((now ?? DateTime.now()).isBefore(_paymentLockUntil!)) return true;
    paymentPinFailures = 0;
    _paymentLockUntil = null;
    return false;
  }

  static bool verifyTransactionPin(String pin,
      {DateTime? now, bool payment = true}) {
    if (payment && paymentsLocked(now: now)) return false;
    if (_transactionPin != null && pin == _transactionPin) {
      if (payment) paymentPinFailures = 0;
      return true;
    }
    if (payment && RegExp(r'^\d{4}$').hasMatch(pin)) {
      paymentPinFailures++;
      if (paymentPinFailures >= 5) {
        _paymentLockUntil =
            (now ?? DateTime.now()).add(const Duration(hours: 1));
      }
    }
    return false;
  }
}
