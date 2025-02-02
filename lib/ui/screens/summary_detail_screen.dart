import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class SummaryDetailScreen extends StatefulWidget {
  final String gameSessionId;

  const SummaryDetailScreen({Key? key, required this.gameSessionId}) : super(key: key);

  @override
  State<SummaryDetailScreen> createState() => _SummaryDetailScreenState();
}

class _SummaryDetailScreenState extends State<SummaryDetailScreen> {
  Map<String, dynamic> sessionDetails = {};
  Map<int, String> playerNames = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSessionDetails();
  }

  Future<void> _fetchSessionDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt');

    if (jwt == null || jwt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur : Token introuvable.')),
      );
      return;
    }

    final url = Uri.parse(
        'https://pictioniary.wevox.cloud/api/game_sessions/${widget.gameSessionId}');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          sessionDetails = jsonDecode(response.body);
        });
        await _fetchPlayerNames();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur ${response.statusCode} : Impossible de charger les détails.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur réseau : $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchPlayerNames() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt');

    if (jwt == null || jwt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur : Token introuvable.')),
      );
      return;
    }

    final playerIds = [
      ...sessionDetails['blue_team'],
      ...sessionDetails['red_team']
    ].toSet();

    for (var playerId in playerIds) {
      try {
        final response = await http.get(
          Uri.parse('https://pictioniary.wevox.cloud/api/players/$playerId'),
          headers: {
            'Authorization': 'Bearer $jwt',
            'Content-Type': 'application/json',
          },
        );
        if (response.statusCode == 200) {
          final player = jsonDecode(response.body);
          setState(() {
            playerNames[playerId] = player['name'];
          });
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur réseau pour le joueur $playerId : $e')),
        );
      }
    }
  }

  Map<String, int> _calculatePoints(Map<String, dynamic> challenge) {
    // Récupération des propositions
    final List<dynamic> proposals = challenge['proposals'] != null
        ? jsonDecode(challenge['proposals'])
        : [];

    // Nombre d’images générées
    // - `previous_images` contient les URLs ou chemins d’images générées
    // - Par défaut, on considère qu’il y a au moins 1 image (la première génération)
    final int imagesGenerated = challenge['previous_images'] != null
        ? jsonDecode(challenge['previous_images']).length
        : 1;

    // Joueurs
    // - "challenger" = Devineur
    // - "challenged" = Dessinateur
    int challengerPoints = 0;
    int challengedPoints = 0;

    // --- Calcul pour le Dessinateur (challenged) ---
    // Pénalité de 10 points pour chaque regénération au-delà de la première.
    int regenerations = (imagesGenerated > 1) ? (imagesGenerated - 1) : 0;
    challengedPoints -= (regenerations * 10);

    // --- Calcul pour le Devineur (challenger) ---
    if (challenge['is_resolved'] == 1) {
      // S’il a fini par trouver la bonne réponse :
      // - +50 points (2 mots x 25 points chacun, simplifié)
      // - -1 point pour chaque tentative incorrecte
      //   => Les tentatives incorrectes sont (proposals.length - 1)
      //      si la dernière proposition est la bonne
      challengerPoints += 50;
      challengerPoints -= (proposals.length - 1);
    } else {
      // S’il n’a jamais trouvé la bonne réponse :
      // - Chaque proposition est une tentative ratée => -1 par proposition
      challengerPoints -= proposals.length;
    }

    return {
      'challenger': challengerPoints,
      'challenged': challengedPoints,
    };
  }

  Widget _buildChallengeItem(Map<String, dynamic> challenge) {
    final points = _calculatePoints(challenge);
    final challengerName = playerNames[challenge['challenger_id']] ?? 'Inconnu';
    final challengedName = playerNames[challenge['challenged_id']] ?? 'Inconnu';
    final List<dynamic> proposals = challenge['proposals'] != null
        ? jsonDecode(challenge['proposals'])
        : [];
    final int imagesGenerated = challenge['previous_images'] != null
        ? jsonDecode(challenge['previous_images']).length
        : 1;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image principale
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                challenge['image_path'] ?? '',
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 10),
            // Détails du défi
            Text(
              'Prompt : ${challenge['prompt']}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text('Challenger : $challengerName (${points['challenger']} points)'),
            Text('Dessinateur : $challengedName (${points['challenged']} points)'),
            Text('Propositions (${proposals.length}) : ${proposals.join(", ")}'),
            const SizedBox(height: 10),
            Text('Images générées : $imagesGenerated'),
          ],
        ),
      ),
    );
  }

  String _determineWinner(int redScore, int blueScore) {
    if (redScore > blueScore) {
      return 'Équipe Rouge gagne avec $redScore points!';
    } else if (blueScore > redScore) {
      return 'Équipe Bleue gagne avec $blueScore points!';
    } else {
      return 'Égalité parfaite avec $redScore points!';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Calcul des scores
    int redScore = 0;
    int blueScore = 0;

    for (var challenge in sessionDetails['challenges']) {
      final points = _calculatePoints(challenge);

      // Challenger points
      if (sessionDetails['red_team'].contains(challenge['challenger_id'])) {
        redScore += (points['challenger'] ?? 0); // Ajoute 0 si null
      } else {
        blueScore += (points['challenger'] ?? 0);
      }

      // Challenged points
      if (sessionDetails['red_team'].contains(challenge['challenged_id'])) {
        redScore += (points['challenged'] ?? 0);
      } else {
        blueScore += (points['challenged'] ?? 0);
      }
    }


    final winnerMessage = _determineWinner(redScore, blueScore);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Résumé de la partie'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Score Équipe Rouge : $redScore points',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            Text(
              'Score Équipe Bleue : $blueScore points',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            const SizedBox(height: 20),
            Text(
              winnerMessage,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: sessionDetails['challenges'].length,
                itemBuilder: (context, index) {
                  return _buildChallengeItem(sessionDetails['challenges'][index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
