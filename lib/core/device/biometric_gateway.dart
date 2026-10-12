import 'package:local_auth/local_auth.dart';

abstract class BiometricGateway {
  static BiometricGateway instance = DeviceBiometricGateway();
  Future<bool> authenticate({required String reason});
  Future<void> cancel();
}

class DeviceBiometricGateway implements BiometricGateway {
  final auth = LocalAuthentication();
  @override
  Future<bool> authenticate({required String reason}) async {
    if (!await auth.canCheckBiometrics ||
        (await auth.getAvailableBiometrics()).isEmpty) {
      return false;
    }
    return auth.authenticate(
        localizedReason: reason,
        biometricOnly: true,
        persistAcrossBackgrounding: false);
  }

  @override
  Future<void> cancel() async {
    try {
      await auth.stopAuthentication();
    } catch (_) {/* Device prompt already dismissed. */}
  }
}
