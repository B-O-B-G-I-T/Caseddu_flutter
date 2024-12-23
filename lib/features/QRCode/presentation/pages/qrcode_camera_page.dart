import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRCodeCamera extends StatefulWidget {
  const QRCodeCamera({super.key});

  @override
  State<QRCodeCamera> createState() => _QRCodeCameraState();
}

class _QRCodeCameraState extends State<QRCodeCamera> {
  String _scannedText = "";

  // Fonction de création du QRView

  @override
  Widget build(BuildContext context) {
      // Utilisation du widget QRView pour scanner les QR codes
      return Scaffold(
        appBar: AppBar(
          title: const Text('Scanner QR Code'),
        ),
        body: MobileScanner(
          onDetect: (barcode) {
            setState(() {
              _scannedText = barcode.barcodes.firstOrNull.toString();
            });
            Fluttertoast.showToast(msg: _scannedText);
          },
        ),
      );
    
  }

  @override
  void dispose() {
    super.dispose();
  }
}
