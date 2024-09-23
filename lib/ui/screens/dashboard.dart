import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'PICTION.IA.RY',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontSize: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Bonjour',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                // Logique pour démarrer une nouvelle partie
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text('Nouvelle partie'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                _openQRScanner(context); // Ouvrir le scanner QR
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              icon: const Icon(Icons.qr_code),
              label: const Text('Rejoindre une partie'),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour ouvrir la modal du scanner QR
  void _openQRScanner(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const QRScannerModal();
      },
    );
  }
}

class QRScannerModal extends StatefulWidget {
  const QRScannerModal({Key? key}) : super(key: key);

  @override
  _QRScannerModalState createState() => _QRScannerModalState();
}

class _QRScannerModalState extends State<QRScannerModal> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8, // Hauteur de la modal
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Scannez le code QR pour rejoindre la partie',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.blue,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ),
          const SizedBox(height: 20),
          result != null
              ? Text('Code QR détecté: ${result!.code}')
              : const Text('Aucun code détecté'),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Fonction appelée lors de la création du scanner QR
  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });

      // Vous pouvez fermer le scanner une fois le QR code scanné
      if (result != null) {
        Navigator.pop(context);  // Fermer la modal
        // Logique pour rejoindre la partie avec le code QR détecté
      }
    });
  }
}
