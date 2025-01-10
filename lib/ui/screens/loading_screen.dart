import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'game_screen.dart';
import 'guess_screen.dart';

class LoadingScreen extends StatefulWidget {
  final String sessionId;

  const LoadingScreen({Key? key, required this.sessionId}) : super(key: key);

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  Timer? _timer;
  String? jwt;
  int? userId; // Décodé à partir du JWT

  @override
  void initState() {
    super.initState();
    _loadJwt();
    _startStatusCheck();
  }

  Future<void> _loadJwt() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt');
    if (token != null) {
      setState(() {
        jwt = token;
        userId = _decodeJwtUserId(token);
      });
    }
  }

  /// Décode le JWT pour extraire l'ID de l'utilisateur
  int? _decodeJwtUserId(String token) {
    try {
      final payload = token.split('.')[1];
      final normalized = base64.normalize(payload);
      final decoded = utf8.decode(base64.decode(normalized));
      final Map<String, dynamic> payloadMap = json.decode(decoded);
      return payloadMap['id'];
    } catch (e) {
      debugPrint('Erreur de décodage JWT: $e');
      return null;
    }
  }

  void _startStatusCheck() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _checkSessionStatus();
    });
  }

  Future<void> _checkSessionStatus() async {
    if (jwt == null || userId == null) return;

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
      final status = data['status'];

      if (status == 'drawing') {
        final challenges = data['challenges'] as List<dynamic>;
        final hasPendingImages = _hasPendingImages(challenges, userId!);


        if (hasPendingImages) {
          _timer?.cancel();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => GameScreen(
                gameSessionId: widget.sessionId,
              ),
            ),
          );
        }
      } else if (status == 'guessing') {
        debugPrint('Phase de guessing. Redirection vers GuessScreen.');
        _timer?.cancel();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => GuessScreen(
              gameSessionId: widget.sessionId,
            ),
          ),
        );
      } else {
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la vérification du statut de la session.')),
      );
    }
  }

  /// Vérifie si l'utilisateur (challenger_id) a encore des images à générer
  bool _hasPendingImages(List<dynamic> challenges, int userId) {
    for (var challenge in challenges) {
      if (challenge['challenged_id'] == userId && challenge['image_path'] == null) {
        return true; // Au moins une image à générer
      }
    }
    return false; // Toutes les images sont générées
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
