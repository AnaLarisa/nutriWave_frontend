// ===== DEBUG VERSION OF BARCODE_SCANNER_PAGE.DART =====
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  late MobileScannerController _cameraController;
  bool _isScanned = false;
  bool _isTorchOn = false;
  String? _lastDetectedBarcode;

  @override
  void initState() {
    super.initState();
    _cameraController = MobileScannerController();
    print('📱 BarcodeScannerPage initialized');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            color: Colors.white,
            icon: Icon(
              _isTorchOn ? Icons.flash_on : Icons.flash_off,
              color: _isTorchOn ? Colors.yellow : Colors.grey,
            ),
            iconSize: 32.0,
            onPressed: () async {
              await _cameraController.toggleTorch();
              setState(() {
                _isTorchOn = !_isTorchOn;
              });
              print('📱 Torch toggled: $_isTorchOn');
            },
          ),
          IconButton(
            color: Colors.white,
            icon: const Icon(Icons.flip_camera_ios),
            iconSize: 32.0,
            onPressed: () {
              _cameraController.switchCamera();
              print('📱 Camera switched');
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _cameraController,
            onDetect: _onBarcodeDetected,
          ),
          // Debug overlay showing detected barcode
          if (_lastDetectedBarcode != null)
            Positioned(
              top: 100,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Detected: $_lastDetectedBarcode',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          // Scan area overlay (simplified for debugging)
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red, width: 2),
            ),
            margin: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.1,
              vertical: MediaQuery.of(context).size.height * 0.3,
            ),
          ),
          // Instructions
          Positioned(
            bottom: 150,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text(
                    'Point your camera at a barcode to scan it',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (_lastDetectedBarcode != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Last detected: $_lastDetectedBarcode',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Manual return button for testing
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _lastDetectedBarcode != null
                  ? () {
                      print('📱 Manual return with barcode: $_lastDetectedBarcode');
                      Navigator.pop(context, _lastDetectedBarcode);
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text(
                _lastDetectedBarcode != null
                    ? 'Use Detected Barcode'
                    : 'No Barcode Detected',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onBarcodeDetected(BarcodeCapture barcodeCapture) {
    print('📱 _onBarcodeDetected called');
    print('📱 Number of barcodes detected: ${barcodeCapture.barcodes.length}');
    
    for (int i = 0; i < barcodeCapture.barcodes.length; i++) {
      final barcode = barcodeCapture.barcodes[i];
      print('📱 Barcode $i:');
      print('   - Raw value: ${barcode.rawValue}');
      print('   - Display value: ${barcode.displayValue}');
      print('   - Type: ${barcode.type}');
      print('   - Format: ${barcode.format}');
      
      if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
        setState(() {
          _lastDetectedBarcode = barcode.rawValue;
        });
        
        // Auto-return after detecting a valid barcode (but add a small delay)
        if (!_isScanned) {
          _isScanned = true;
          print('📱 Auto-returning with barcode: ${barcode.rawValue}');
          
          // Add a small delay to ensure the UI updates
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              Navigator.pop(context, barcode.rawValue);
            }
          });
          break;
        }
      }
    }
  }

  @override
  void dispose() {
    print('📱 BarcodeScannerPage disposing');
    _cameraController.dispose();
    super.dispose();
  }
}