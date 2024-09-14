import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class GenerateQRScreen extends StatefulWidget {
  @override
  _GenerateQRScreenState createState() => _GenerateQRScreenState();
}

class _GenerateQRScreenState extends State<GenerateQRScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _textController = TextEditingController();
  String qrData = '';
  String selectedType = 'Text';
  final List<String> dataTypes = ['URL', 'Text', 'vCard', 'Wi-Fi'];

  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Generate QR Code')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Dropdown to select QR Code type
            DropdownButton<String>(
              value: selectedType,
              onChanged: (String? newValue) {
                setState(() {
                  selectedType = newValue!;
                });
              },
              items: dataTypes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),

            // Input fields based on selected type
            if (selectedType == 'Wi-Fi') ...[
              TextField(
                controller: _ssidController,
                decoration: InputDecoration(
                  labelText: 'Wi-Fi SSID',
                ),
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Wi-Fi Password',
                ),
              ),
            ] else if (selectedType == 'vCard') ...[
              // For simplicity, using a single input for vCard. In a full app, you'd have multiple inputs.

              TextField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                ),
              ),
              TextField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                ),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ] else ...[
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Enter text or URL',
                ),
              ),
            ],

            SizedBox(height: 20),

            // Generate QR Code button
            ElevatedButton(
              onPressed: () {
                _generateQRCode();
              },
              child: Text('Generate QR Code'),
            ),

            SizedBox(height: 20),

            // Display QR Code
            if (qrData.isNotEmpty)
              QrImageView(
                data: qrData, // Correct 'data' parameter
                version: QrVersions.auto,
                size: 200.0,
              ),

            // Save and Share Buttons
            if (qrData.isNotEmpty) ...[
              ElevatedButton(
                onPressed: _saveQRCode,
                child: Text('Save QR Code'),
              ),
              ElevatedButton(
                onPressed: _shareQRCode,
                child: Text('Share QR Code'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Generate QR code based on input type
  void _generateQRCode() {
    if (selectedType == 'Wi-Fi') {
      // Format Wi-Fi QR Code data
      qrData =
          'WIFI:S:${_ssidController.text};T:WPA;P:${_passwordController.text};;';
    } else if (selectedType == 'vCard') {
      // Format vCard QR Code data with user input
      qrData = '''
BEGIN:VCARD
VERSION:3.0
FN:${_fullNameController.text}
TEL:${_phoneController.text}
EMAIL:${_emailController.text}
END:VCARD
    ''';
    } else {
      // Use text or URL directly
      qrData = _textController.text;
    }
    setState(() {});
  }

  // Save QR Code as an image with white padding and centered QR code
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
      const double qrSize = 200.0;
      const double padding = 40.0; // White padding around the QR code
      final canvas = Canvas(pictureRecorder);

      // Draw white background with padding
      canvas.drawRect(
        Rect.fromLTWH(0, 0, qrSize + padding * 2, qrSize + padding * 2),
        Paint()..color = Colors.white,
      );

      // Move the canvas to the center the QR code within the white padding
      canvas.translate(padding, padding);

      // Draw the QR code on the canvas, now it will be centered
      painter.paint(canvas, Size(qrSize, qrSize));

      final picture = pictureRecorder.endRecording();
      final image = await picture.toImage(
        (qrSize + padding * 2).toInt(),
        (qrSize + padding * 2).toInt(),
      );
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();
      final file = File(path);
      await file.writeAsBytes(buffer);
    }
  }

  // Share QR Code with white padding and centered QR code
  Future<void> _shareQRCode() async {
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
      const double qrSize = 200.0;
      const double padding = 40.0; // White padding around the QR code
      final canvas = Canvas(pictureRecorder);

      // Draw white background with padding
      canvas.drawRect(
        Rect.fromLTWH(0, 0, qrSize + padding * 2, qrSize + padding * 2),
        Paint()..color = Colors.white,
      );

      // Move the canvas to center the QR code within the white padding
      canvas.translate(padding, padding);

      // Draw the QR code on the canvas, now it will be centered
      painter.paint(canvas, Size(qrSize, qrSize));

      final picture = pictureRecorder.endRecording();
      final image = await picture.toImage(
        (qrSize + padding * 2).toInt(),
        (qrSize + padding * 2).toInt(),
      );
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();
      final file = File(path);
      await file.writeAsBytes(buffer);

      // Share the file
      await Share.shareFiles([path], text: 'Here is your generated QR Code');
    }
  }
}
