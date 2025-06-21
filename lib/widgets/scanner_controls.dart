import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerControls extends StatelessWidget {
  final MobileScannerController controller;
  final bool isTorchOn;
  final VoidCallback onTorchToggle;

  const ScannerControls({
    super.key,
    required this.controller,
    required this.isTorchOn,
    required this.onTorchToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          color: Colors.white,
          icon: Icon(
            isTorchOn ? Icons.flash_on : Icons.flash_off,
            color: isTorchOn ? Colors.yellow : Colors.grey,
          ),
          iconSize: 32.0,
          onPressed: () async {
            await controller.toggleTorch();
            onTorchToggle();
          },
        ),
        IconButton(
          color: Colors.white,
          icon: const Icon(Icons.flip_camera_ios),
          iconSize: 32.0,
          onPressed: () => controller.switchCamera(),
        ),
      ],
    );
  }
}