import 'package:flutter/material.dart';
import 'package:kinetic_qr/generate_qr_screen.dart';
import 'package:kinetic_qr/scan_qr_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        title: const Row(
          children: [
            Icon(Icons.qr_code, size: 30), // Icon at the start
            SizedBox(
                width: 10), // Add some spacing between the icon and the title
            Text(
              'kineticQR',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  fontWeight: FontWeight.bold), // Title text
            ),
          ],
        ),
        centerTitle: false, // Align to the left
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ScanQRScreen()),
                );
              },
              icon: const Icon(Icons.qr_code_scanner, size: 24),
              label: const Text('Scan QR Code'),
            ),
            const SizedBox(height: 20), // Add some spacing between the buttons
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                textStyle: const TextStyle(fontSize: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GenerateQRScreen()),
                );
              },
              icon: const Icon(Icons.qr_code, size: 24),
              label: const Text('Generate QR Code'),
            ),
          ],
        ),
      ),
    );
  }
}
