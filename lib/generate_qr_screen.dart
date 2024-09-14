import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';


class GenerateQRScreen extends StatefulWidget {
  @override
  _GenerateQRScreenState createState() => _GenerateQRScreenState();
}

class _GenerateQRScreenState extends State<GenerateQRScreen> {
  final TextEditingController _textController = TextEditingController();
  String qrData = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Generate QR Code')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Enter data to generate QR code',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                qrData = _textController.text;
              });
            },
            child: Text('Generate QR Code'),
          ),
          if (qrData.isNotEmpty)
            QrImageView(
              data: qrData, // Here is the correct 'data' parameter
              version: QrVersions.auto,
              size: 200.0,
            ),
          if (qrData.isNotEmpty)
            ElevatedButton(
              onPressed: () => _saveQRCode(),
              child: Text('Save QR Code'),
            ),
        ],
      ),
    );
  }

  Future<void> _saveQRCode() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/qr_code.png';
    final qrValidationResult = QrValidator.validate(
      data: qrData,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.L,
    );

    if (qrValidationResult.status == QrValidationStatus.valid) {
      final painter = QrPainter.withQr(
        qr: qrValidationResult.qrCode!,
        color: const Color(0xFF000000),
        emptyColor: const Color(0xFFFFFFFF),
        gapless: true,
      );
      final pictureRecorder = PictureRecorder();
      final canvas = Canvas(pictureRecorder);
      painter.paint(canvas, const Size(200, 200));
      final picture = pictureRecorder.endRecording();
      final image = await picture.toImage(200, 200);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();
      final file = File(path);
      await file.writeAsBytes(buffer);
    }
  }
}
