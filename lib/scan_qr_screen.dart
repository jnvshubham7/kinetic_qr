import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';


bool isHarmfulUrl(String url) {
  List<String> harmfulKeywords = ['phishing', 'malware', 'danger', 'fake', 'scam'];
  return harmfulKeywords.any((keyword) => url.contains(keyword));
}

class ScanQRScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> with TickerProviderStateMixin {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  String qrText = '';
  bool isScanning = true;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    // Initialize the animation controller for the scanning line
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
        children: <Widget>[
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Result: $qrText'),
                      SizedBox(height: 10),
                      if (Uri.tryParse(qrText)?.hasAbsolutePath ?? false)
                        ElevatedButton(
                          onPressed: () async {
                            if (isHarmfulUrl(qrText)) {
                             
                              _showHarmfulUrlWarning(context);
                            } else if (await canLaunch(qrText)) {
                              await launch(qrText);
                            }
                          },
                          child: Text(isHarmfulUrl(qrText)
                              ? 'Warning: Harmful URL'
                              : 'Open in Browser'),
                          style: ButtonStyle(
                            backgroundColor: isHarmfulUrl(qrText)
                                ? MaterialStateProperty.all(Colors.red)
                                : MaterialStateProperty.all(Colors.blue),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (!isScanning)
            Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        isScanning = false; 
        qrText = scanData.code ?? '';
      });
    });
  }

  void _showHarmfulUrlWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Warning'),
          content: Text(
              'This QR code leads to a potentially harmful website. Proceed with caution.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Proceed'),
              onPressed: () async {
                if (await canLaunch(qrText)) {
                  await launch(qrText);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
