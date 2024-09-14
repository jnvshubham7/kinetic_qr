import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class ScanQRScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> with TickerProviderStateMixin {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? qrText; // To hold the final result
  bool isScanning = true; // Flag to check if scanning is in progress
  bool isResultAvailable = false; // To track if a result is available
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // Animation for scanning line
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Scan QR Code')),
      body: Stack(
        children: [
          if (isScanning) ...[
            Column(
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Stack(
                    children: [
                      QRView(
                        key: qrKey,
                        onQRViewCreated: _onQRViewCreated,
                      ),
                      // Scanning animation: a red line moving up and down
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, _animationController.value * 200 - 100),
                                child: Container(
                                  height: 2,
                                  width: double.infinity,
                                  color: Colors.red,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Text(
                      'Scanning for QR code...',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (isResultAvailable) ...[
            _buildResultView(), // Show the result in a well-formatted view
          ],
        ],
      ),
    );
  }

  // Method to handle QR View creation and scanning
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!isResultAvailable) {
        // Stop the scanning and process the first result
        setState(() {
          isScanning = false;
          isResultAvailable = true;
          qrText = scanData.code;
        });

        // Stop camera preview to avoid further scanning
        controller.pauseCamera();
      }
    });
  }

  // Build the view to display QR code result
  Widget _buildResultView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scanned Result:',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                if (qrText != null && _isValidUrl(qrText!)) ...[
                  GestureDetector(
                    onTap: () async {
                      final url = Uri.parse(qrText!);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        _showSnackBar(context, "Could not open the link.");
                      }
                    },
                    child: Text(
                      qrText!,
                      style: TextStyle(fontSize: 18, color: Colors.blue, decoration: TextDecoration.underline),
                    ),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final url = Uri.parse(qrText!);
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        _showSnackBar(context, "Could not open the link.");
                      }
                    },
                    child: Text('Open Link'),
                  ),
                ] else if (qrText != null) ...[
                  Text(
                    qrText!,
                    style: TextStyle(fontSize: 18, color: Colors.black),
                    softWrap: true,
                  ),
                ],
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Restart scanning
                    setState(() {
                      isResultAvailable = false;
                      isScanning = true;
                      qrText = null;
                    });
                    controller?.resumeCamera();
                  },
                  child: Text('Scan Again'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Check if the scanned data is a valid URL
  bool _isValidUrl(String url) {
    Uri? uri = Uri.tryParse(url);
    return uri != null && uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  // Helper to show snackbar messages
  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void dispose() {
    controller?.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
