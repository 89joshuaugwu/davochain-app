import 'package:davochain/core/device/biometric_gateway.dart';
export 'package:davochain/core/device/biometric_gateway.dart';

class FakeBiometricGateway implements BiometricGateway {
  FakeBiometricGateway({this.accept = true});
  bool accept;
  int calls = 0;
  @override
  Future<bool> authenticate({required String reason}) async {
    calls++;
    return accept;
  }

  @override
  Future<void> cancel() async {}
}
