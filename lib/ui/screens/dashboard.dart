import 'package:flutter/material.dart';
import 'package:pictionnary/ui/screens/team_composition.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? userName;
  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt');

    if (token != null) {
      try {
        final jwt = JWT.decode(token);
        setState(() {
          userName = jwt.payload['name'];
        });
      } catch (e) {
        print('Erreur lors du décodage du JWT : $e');
      }
    }
  }

  Future<void> _createGameSession() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jwt = prefs.getString('jwt');

    if (jwt == null) {
      setState(() {
        _errorMessage = 'Erreur : Utilisateur non authentifié';
        _loading = false;
      });
      return;
    }

    final url = Uri.parse('https://pictioniary.wevox.cloud/api/game_sessions');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final String sessionId = data['id'].toString();
      setState(() {
        _loading = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TeamCompositionScreen(
            sessionId: sessionId,
            userName: userName ?? 'Anonymousse',
          ),
        ),
      );
    } else {
      setState(() {
        _errorMessage = 'Erreur lors de la création de la session' +
            ' (${response.body})';
        _loading = false;
      });
    }
  }

  Future<void> _joinGameSession(String sessionId) async {
    Navigator.pop(context); // Close the QR scanner modal
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jwt = prefs.getString('jwt');

    if (jwt == null) {
      setState(() {
        _errorMessage = 'Erreur : Utilisateur non authentifié';
      });
      return;
    }

    // Navigate directly to TeamCompositionScreen and let it handle team assignment
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TeamCompositionScreen(sessionId: sessionId),
      ),
    );
  }

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
              'Bonjour ${userName ?? ''}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 40),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _createGameSession,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 50, vertical: 15),
              ),
              child: const Text('Nouvelle partie'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                _openQRScanner(context);
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 30, vertical: 15),
              ),
              icon: const Icon(Icons.qr_code),
              label: const Text('Rejoindre une partie'),
            ),
            const SizedBox(height: 20),
            _errorMessage != null
                ? Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            )
                : Container(),
          ],
        ),
      ),
    );
  }

  void _openQRScanner(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return QRScannerModal(onScanComplete: _joinGameSession);
      },
    );
  }
}

class QRScannerModal extends StatefulWidget {
  final Function(String sessionId) onScanComplete;

  const QRScannerModal({Key? key, required this.onScanComplete}) : super(key: key);

  @override
  _QRScannerModalState createState() => _QRScannerModalState();
}

class _QRScannerModalState extends State<QRScannerModal> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
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
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      controller.pauseCamera();
      final sessionId = scanData.code;

      if (sessionId != null && sessionId.isNotEmpty) {
        widget.onScanComplete(sessionId);
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Code QR invalide')),
        );
      }
    });
  }
}