import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'game_screen.dart';

class LoadingScreen extends StatefulWidget {
  final String sessionId;

  const LoadingScreen({Key? key, required this.sessionId}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  Timer? _timer;
  String? jwt;

  @override
  void initState() {
    super.initState();
    _loadJwt();
    _startStatusCheck();
  }

  Future<void> _loadJwt() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      jwt = prefs.getString('jwt');
    });
  }

  void _startStatusCheck() {
    _timer = Timer.periodic(Duration(seconds: 2), (timer) {
      _checkSessionStatus();
    });
  }

  Future<void> _checkSessionStatus() async {
    if (jwt == null) return;

    final url = Uri.parse('https://pictioniary.wevox.cloud/api/game_sessions/${widget.sessionId}');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'drawing') {
        _timer?.cancel();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => GameScreen()),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur lors de la vérification du statut de la session.')));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300], // Fond gris
      body: Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 4, // Effet d'ombre pour la carte
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Taille ajustée au contenu
              children: [
                // Icône de chargement
                const CircularProgressIndicator(
                  color: Colors.black, // Couleur du spinner
                ),
                const SizedBox(height: 20), // Espace entre le spinner et le texte
                // Texte d'attente
                Text(
                  'En attente des autres joueurs',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}