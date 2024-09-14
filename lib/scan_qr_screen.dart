import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScanQRScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> with TickerProviderStateMixin {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String? qrText;
  bool isScanning = true;
  bool isResultAvailable = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final boxDecoration = BoxDecoration(
      border: Border.all(
          color: isDarkMode ? Colors.tealAccent : Colors.blueAccent, width: 4),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: isDarkMode
              ? Colors.tealAccent.withOpacity(0.5)
              : Colors.blueAccent.withOpacity(0.5),
          spreadRadius: 2,
          blurRadius: 10,
        ),
      ],
    );
    final scanningLineColor = isDarkMode ? Colors.tealAccent : Colors.blueAccent;
    final textStyle = TextStyle(
      fontSize: 18,
      color: isDarkMode ? Colors.tealAccent.shade400 : Colors.blueAccent.shade400,
    );
    final appBarColor = isDarkMode ? Colors.black : Colors.blue;

    return Scaffold(
      appBar: AppBar(
        title: Text('Scan QR Code'),
        backgroundColor: appBarColor,
      ),
      body: Stack(
        children: [
          if (isScanning) ...[
            Column(
              children: <Widget>[
                Expanded(
                  flex: 5,
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          alignment: Alignment.center,
                          width: 300,
                          height: 500,
                          decoration: boxDecoration,
                          child: QRView(
                            key: qrKey,
                            onQRViewCreated: _onQRViewCreated,
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(
                                    0, _animationController.value * 300 - 150),
                                child: Container(
                                  height: 4,
                                  width: 300,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        scanningLineColor.withOpacity(0),
                                        scanningLineColor,
                                        scanningLineColor.withOpacity(0),
                                      ],
                                      stops: [0.1, 0.5, 0.9],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: scanningLineColor,
                                        blurRadius: 15,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
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
                      'Align the QR code within the frame',
                      style: textStyle,
                    ),
                  ),
                ),
              ],
            ),
          ] else if (isResultAvailable) ...[
            _buildResultView(isDarkMode),
          ],
        ],
      ),
    );
  }

void _onQRViewCreated(QRViewController controller) {
  this.controller = controller;
  controller.scannedDataStream.listen((scanData) async {
    if (!isResultAvailable) {
      setState(() {
        isScanning = false;
        isResultAvailable = true;
       qrText = scanData.code ?? scanData.rawBytes?.toString();

      });
      controller.pauseCamera();

      // Call the validation method to check if the URL is harmful
      bool isSafe = await _isValidUrl(qrText!);
      if (!isSafe) {
        _showSnackBar(context, "Warning: The scanned URL is potentially harmful!");
      }
    }
  });
}


  Widget _buildResultView(bool isDarkMode) {
    final cardColor = isDarkMode ? Colors.black54 : Colors.white;
    final textColor = isDarkMode ? Colors.teal : Colors.blue;
    final buttonColor = isDarkMode ? Colors.teal : Colors.blue;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          color: cardColor,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Scanned Result:',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 10),
                if (qrText != null) ...[
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
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.blue),
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
                    child: Text('Open Link', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                    ),
                  ),
                ] else if (qrText != null) ...[
                  Text(
                    qrText!,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.blue,
                    ),
                    softWrap: true,
                  ),
                ],
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      isResultAvailable = false;
                      isScanning = true;
                      qrText = null;
                    });
                    controller?.resumeCamera();
                  },
                  child: Text('Scan Again', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

Future<bool> _isValidUrl(String url) async {
  Uri? uri = Uri.tryParse(url);
  if (uri == null || !uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
    return false;
  }

  try {
    // Replace this with a valid API to check URLs or use OpenPhish data
    final response = await http.get(Uri.parse('https://openphish.com/getphi.php'));
    if (response.statusCode == 200) {
      final jsonDecoded = jsonDecode(response.body);
      // Assuming 'phish' key is 1 for phishing URLs in OpenPhish API
      final isPhishing = jsonDecoded['phish'] == '1';
      return !isPhishing;
    }
  } catch (e) {
    print("Error checking URL: $e");
  }

  return true; // If no issues, assume the URL is safe
}


  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message), duration: Duration(seconds: 3));
   
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void dispose() {
    controller?.dispose();
    _animationController.dispose();
    super.dispose();
  }
}