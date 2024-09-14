import 'dart:ui';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as path;

var logger = Logger();

class GenerateQRScreen extends StatefulWidget {
  @override
  _GenerateQRScreenState createState() => _GenerateQRScreenState();
}

class _GenerateQRScreenState extends State<GenerateQRScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  final TextEditingController _textController = TextEditingController();


  late Brightness brightness;

  String qrData = '';
  String selectedType = 'Text';
  final List<String> dataTypes = ['URL', 'Text', 'vCard', 'Wi-Fi'];

  final TextEditingController _ssidController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    brightness = Theme.of(context).brightness;

    final qrColor = brightness == Brightness.dark ? Colors.white : Colors.black;
final qrBackgroundColor = brightness == Brightness.dark ? Colors.black : Colors.white;

    return Scaffold(
      appBar: AppBar(title: const Text('Generate QR Code')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
                decoration: const InputDecoration(
                  labelText: 'Wi-Fi SSID',
                ),
              ),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Wi-Fi Password',
                ),
              ),
            ] else if (selectedType == 'vCard') ...[
              TextField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                ),
              ),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                ),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                ),
                keyboardType: TextInputType.emailAddress,
              ),
            ] else ...[
              TextField(
                controller: _textController,
                decoration: const InputDecoration(
                  hintText: 'Enter text or URL',
                ),
              ),
            ],

            const SizedBox(height: 20),

            // Generate QR Code button
            ElevatedButton(
              onPressed: () {
                _generateQRCode();
              },
              child: const Text('Generate QR Code'),
            ),

            const SizedBox(height: 20),


            if (qrData.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16.0),
                
                decoration: BoxDecoration(
                  border: Border.all(color: qrColor),
                  color: Colors.white,
                ),
                child: QrImageView(
                  data: qrData, // Correct 'data' parameter
                  version: QrVersions.auto,
                  size: 200.0,
                ),
              ),

            const SizedBox(height: 20),

         

            // Save and Share Buttons
            if (qrData.isNotEmpty) ...[
              ElevatedButton(
                onPressed: () {
                  _saveQRCode(context, qrData);
                },
                child: const Text('Save QR Code'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _shareQRCode,
                child: const Text('Share QR Code'),
              ),
            ],
          ],
        ),
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

Future<void> _saveQRCode(BuildContext context, String qrData) async {
  String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

  // If the user didn't select a directory, return early.
  if (selectedDirectory == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No directory selected'),
      ),
    );
    return;
  }
  String getUniqueFileName(String directory, String baseName, String extension) {
    int count = 1;
    String fileName = '$baseName.$extension';
    String fullPath = path.join(directory, fileName);

    // Check if file already exists, if so, increment the file name
    while (File(fullPath).existsSync()) {
      fileName = '$baseName $count.$extension';
      fullPath = path.join(directory, fileName);
      count++;
    }

    return fullPath; // Return unique file path
  }

  // Get the unique file name for saving the QR code
  final savePath = getUniqueFileName(selectedDirectory, 'qr_image', 'png');

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

    // Draw background with padding
    canvas.drawRect(
      Rect.fromLTWH(0, 0, qrSize + padding * 2, qrSize + padding * 2),
      Paint()..color =  Colors.white,
    );

    // Center the QR code within the padding
    canvas.translate(padding, padding);

    // Draw the QR code on the canvas
    painter.paint(canvas, Size(qrSize, qrSize));

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(
      (qrSize + padding * 2).toInt(),
      (qrSize + padding * 2).toInt(),
    );
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    final buffer = byteData!.buffer.asUint8List();
    final file = File(savePath);
    await file.writeAsBytes(buffer);

    // Show SnackBar after saving the file
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('QR Code saved successfully at $savePath!'),
      ),
    );
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
        const Rect.fromLTWH(0, 0, qrSize + padding * 2, qrSize + padding * 2),
        Paint()..color = Colors.white,
      );

      // Move the canvas to center the QR code within the white padding
      canvas.translate(padding, padding);

      // Draw the QR code on the canvas, now it will be centered
      painter.paint(canvas, const Size(qrSize, qrSize));

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
