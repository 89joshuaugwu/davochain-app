import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

abstract class WalletScannerGateway extends ChangeNotifier {
  bool get torchAvailable;
  bool get torchOn;
  Widget preview(
      {required ValueChanged<String> onCode, required VoidCallback retry});
  Future<void> start();
  Future<void> stop();
  Future<void> toggleTorch();
  Future<void> close();
}

class DeviceWalletScannerGateway extends WalletScannerGateway {
  final controller = MobileScannerController(
      autoStart: false,
      facing: CameraFacing.back,
      formats: const [BarcodeFormat.qrCode],
      detectionSpeed: DetectionSpeed.noDuplicates);
  DeviceWalletScannerGateway() {
    controller.addListener(notifyListeners);
  }
  @override
  bool get torchAvailable =>
      controller.value.isInitialized &&
      controller.value.torchState != TorchState.unavailable;
  @override
  bool get torchOn => controller.value.torchState == TorchState.on;
  @override
  Widget preview(
          {required ValueChanged<String> onCode,
          required VoidCallback retry}) =>
      MobileScanner(
          controller: controller,
          tapToFocus: true,
          useAppLifecycleState: false,
          onDetect: (capture) {
            if (capture.barcodes.length != 1) return;
            final value = capture.barcodes.single.rawValue;
            if (value != null && value.isNotEmpty) onCode(value);
          },
          errorBuilder: (context, error) => Center(
              child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text(
                        'Allow camera access to scan an address, or enter it manually.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white)),
                    TextButton(
                        onPressed: retry, child: const Text('Retry camera')),
                  ]))));
  @override
  Future<void> start() => controller.start();
  @override
  Future<void> stop() => controller.stop();
  @override
  Future<void> toggleTorch() => controller.toggleTorch();
  @override
  Future<void> close() async {
    controller.removeListener(notifyListeners);
    await controller.dispose();
    dispose();
  }
}
