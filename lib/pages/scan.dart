import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../entities/code.dart';
import '../i18n.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("scanner.title".i18n()),
      ),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      controller.pauseCamera();
      if (scanData.format != BarcodeFormat.qrcode) {
        controller.resumeCamera();
        return;
      }

      try {
        final code = parseQR(Uri.parse(scanData.code!));
        Navigator.pop(context, code);
      } on Exception catch (e) {
        final matLoc = MaterialLocalizations.of(context);
        SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("scanner.error".i18n()),
              content: Text("$e"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    controller.resumeCamera();
                  },
                  child: Text(matLoc.okButtonLabel),
                ),
              ],
            ),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
