import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    facing: CameraFacing.back,
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  /// Stops the scanner when the widget is deactivated
  String? _scannedCode;
  bool _hasScanned = false;
  @override
  void deactivate() {
    _controller.stop();
    super.deactivate();
  }

  /// Releases the [MobileScannerController] and its underlying camera resources
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Triggered when QR is detected
  void _onDetect(BarcodeCapture capture) {
    if (!mounted || _hasScanned) return;

    final Barcode? barcode =
        capture.barcodes.isNotEmpty ? capture.barcodes.first : null;

    if (barcode?.rawValue == null) return;

    setState(() {
      _hasScanned = true;
      _scannedCode = barcode!.rawValue;
    });
    _controller.stop();
  }

  /// Restart scanner
  void _scanAgain() {
    setState(() {
      _hasScanned = false;
      _scannedCode = null;
    });

    _controller.start();
  }

  /// Copy scanned text
  void _copyToClipboard() {
    if (_scannedCode == null) return;

    Clipboard.setData(ClipboardData(text: _scannedCode!));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Copied to clipboard")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("QR Scanner"),
        actions: [
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: _controller,
            builder: (context, state, child) {
              return IconButton(
                icon: switch (state.torchState) {
                  TorchState.off =>
                    const Icon(Icons.flash_off, color: Colors.grey),
                  TorchState.on =>
                    const Icon(Icons.flash_on, color: Colors.yellow),
                  TorchState.unavailable =>
                    const Icon(Icons.flash_off, color: Colors.red),
                  TorchState.auto =>
                    const Icon(Icons.flash_auto, color: Colors.amber),
                },
                onPressed: state.torchState == TorchState.unavailable
                    ? null
                    : _controller.toggleTorch,
              );
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _scannedCode == null ? _buildScanner() : _buildResult(),
      ),
    );
  }

  /// Scanner UI
  Widget _buildScanner() {
    return MobileScanner(
      controller: _controller,
      onDetect: _onDetect,
      errorBuilder: (context, error, child) {
        return Center(
          child: Text(
            "Camera error: ${error.errorCode}",
            style: const TextStyle(color: Colors.red),
          ),
        );
      },
    );
  }

  /// Result UI
  Widget _buildResult() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 40),
          const Icon(
            Icons.qr_code_scanner,
            size: 80,
            color: Colors.blue,
          ),
          const SizedBox(height: 20),
          const Text(
            "Scanned Result",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                _scannedCode ?? "",
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _copyToClipboard,
                icon: const Icon(Icons.copy),
                label: const Text("Copy"),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: _scanAgain,
                icon: const Icon(Icons.refresh),
                label: const Text("Scan Again"),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
