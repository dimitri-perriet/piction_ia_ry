import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'loading_screen.dart';

class GameScreen extends StatefulWidget {
  final String gameSessionId;

  const GameScreen({Key? key, required this.gameSessionId}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late List<dynamic> challenges = [];
  int currentChallengeIndex = 0;
  String? jwt;
  final TextEditingController _answerController = TextEditingController();
  String? generatedImagePath; // URL de l'image générée
  bool isLoading = false; // Indicateur de chargement

  @override
  void initState() {
    super.initState();
    _loadJwtAndFetchChallenges();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _loadJwtAndFetchChallenges() async {
    await _loadJwt(); // Charge le token
    if (jwt != null) {
      await _fetchChallenges();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur : Token introuvable.')),
      );
    }
  }

  Future<void> _loadJwt() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      jwt = prefs.getString('jwt');
    });
  }

  Future<void> _fetchChallenges() async {
    final url = Uri.parse(
        'https://pictioniary.wevox.cloud/api/game_sessions/${widget.gameSessionId}/myChallenges');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        challenges = json.decode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des défis')),
      );
    }
  }

  Future<void> _generateOrRegenerateImage() async {
    final userInput = _answerController.text.trim();
    final forbiddenWords =
    (json.decode(challenges[currentChallengeIndex]['forbidden_words']) as List<dynamic>)
        .cast<String>();

    if (userInput.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer une réponse avant de générer l\'image.')),
      );
      return;
    }

    // Vérification des mots interdits
    final containsForbiddenWord = forbiddenWords.any(
            (word) => userInput.toLowerCase().contains(word.toLowerCase()));

    if (containsForbiddenWord) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Votre réponse contient un mot interdit.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final challengeId = challenges[currentChallengeIndex]['id'];
    final url = Uri.parse(
        'https://pictioniary.wevox.cloud/api/game_sessions/${widget.gameSessionId}/challenges/$challengeId/draw');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({"prompt": userInput}),
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        generatedImagePath = data['image_path']; // Récupérer le chemin de l'image
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image générée avec succès !')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la génération de l\'image.')),
      );
    }
  }

  void _nextChallenge() {
    if (currentChallengeIndex < challenges.length - 1) {
      setState(() {
        currentChallengeIndex++;
        generatedImagePath = null; // Réinitialiser l'image pour le défi suivant
        _answerController.clear(); // Réinitialiser l'input pour le défi suivant
      });
    } else {
      // Redirige vers LoadingScreen une fois tous les défis terminés
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => LoadingScreen(sessionId: widget.gameSessionId),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (jwt == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chargement...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (challenges.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chargement...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentChallenge = challenges[currentChallengeIndex];
    final forbiddenWords =
    (json.decode(currentChallenge['forbidden_words']) as List<dynamic>)
        .cast<String>();

    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Défi en cours'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Votre challenge:',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${currentChallenge['first_word']} ${currentChallenge['second_word']} ${currentChallenge['third_word']} ${currentChallenge['fourth_word']} ${currentChallenge['fifth_word']}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Mots interdits :',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      spacing: 8.0,
                      children: forbiddenWords
                          .map(
                            (word) => Chip(
                          label: Text(word),
                          backgroundColor: Colors.red,
                          labelStyle:
                          const TextStyle(color: Colors.white),
                        ),
                      )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : generatedImagePath != null
                ? Image.network(generatedImagePath!, height: 200)
                : const Text(
              'Aucune image générée.',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _answerController,
              decoration: const InputDecoration(
                labelText: 'Votre réponse',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            if (generatedImagePath == null) ...[
              ElevatedButton.icon(
                onPressed: _generateOrRegenerateImage,
                icon: const Icon(Icons.image),
                label: const Text('Générer l\'image'),
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: _generateOrRegenerateImage,
                icon: const Icon(Icons.refresh),
                label: const Text('Régénérer l\'image (-50pts)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _nextChallenge,
                icon: const Icon(Icons.send),
                label: const Text('Envoyer au devineur'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
