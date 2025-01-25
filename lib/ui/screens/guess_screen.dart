import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'summary_detail_screen.dart';


class GuessScreen extends StatefulWidget {
  final String gameSessionId;

  const GuessScreen({Key? key, required this.gameSessionId}) : super(key: key);

  @override
  State<GuessScreen> createState() => _GuessScreenState();
}

class _GuessScreenState extends State<GuessScreen> {
  late List<dynamic> challenges = [];
  int currentChallengeIndex = 0;
  Timer? _timer;
  Timer? _statusCheckTimer;
  int _globalTimeLeft = 300; // Timer global pour tous les défis
  String? jwt;
  bool isWaitingForOthers = false;
  bool isAnswering = false;
  final TextEditingController _secondWordController = TextEditingController();
  final TextEditingController _fifthWordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadJwtAndFetchChallenges();
    _startStatusCheck(); // Vérification régulière du statut
  }

  @override
  void dispose() {
    _timer?.cancel();
    _statusCheckTimer?.cancel();
    _secondWordController.dispose();
    _fifthWordController.dispose();
    super.dispose();
  }

  Future<void> _loadJwtAndFetchChallenges() async {
    await _loadJwt();
    if (jwt != null) {
      await _fetchChallenges();
      _startGlobalTimer();
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
        'https://pictioniary.wevox.cloud/api/game_sessions/${widget.gameSessionId}/myChallengesToGuess');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        challenges = jsonDecode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des défis')),
      );
    }
  }

  void _startGlobalTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_globalTimeLeft > 0) {
        setState(() {
          _globalTimeLeft--;
        });
      } else {
        timer.cancel();
        _sendEmptyAnswer(); // Temps écoulé, envoie une réponse vide
      }
    });
  }

  void _startStatusCheck() {
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      final url = Uri.parse('https://pictioniary.wevox.cloud/api/game_sessions/${widget.gameSessionId}/status');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $jwt',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final status = jsonDecode(response.body)['status'];
        if (status == 'finished') {
          timer.cancel();
          _navigateToSummaryScreen();
        }
      }
    });
  }

  Future<void> _sendAnswer() async {
    if (isAnswering) return; // Empêche les multiples réponses simultanées
    setState(() {
      isAnswering = true;
    });

    final currentChallenge = challenges[currentChallengeIndex];
    final challengeId = currentChallenge['id'];

    final firstWord = currentChallenge['first_word'];
    final secondWord = _secondWordController.text.trim();
    final thirdWord = currentChallenge['third_word'];
    final fourthWord = currentChallenge['fourth_word'];
    final fifthWord = _fifthWordController.text.trim();

    final answer = '$firstWord $secondWord $thirdWord $fourthWord $fifthWord';

    final isResolved = secondWord.toLowerCase() == currentChallenge['second_word'].toLowerCase() &&
        fifthWord.toLowerCase() == currentChallenge['fifth_word'].toLowerCase();

    await _postAnswer(challengeId, answer, isResolved);
    if (isResolved) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bonne réponse !')));
      _nextChallenge();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mauvaise réponse !')));
    }

    setState(() {
      isAnswering = false;
    });
  }

  Future<void> _sendEmptyAnswer() async {
    final currentChallenge = challenges[currentChallengeIndex];
    final challengeId = currentChallenge['id'];

    await _postAnswer(challengeId, "", false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Défi abandonné.')));
    _nextChallenge();
  }

  Future<void> _postAnswer(int challengeId, String answer, bool isResolved) async {
    final url = Uri.parse(
        'https://pictioniary.wevox.cloud/api/game_sessions/${widget.gameSessionId}/challenges/$challengeId/answer');

    await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        "answer": answer,
        "is_resolved": isResolved,
      }),
    );
  }

  void _nextChallenge() {
    if (currentChallengeIndex < challenges.length - 1) {
      setState(() {
        currentChallengeIndex++;
        _secondWordController.clear();
        _fifthWordController.clear();
      });
    } else {
      setState(() {
        isWaitingForOthers = true;
      });
    }
  }

  void _navigateToSummaryScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SummaryDetailScreen(gameSessionId: '${widget.gameSessionId}'),
      ),
    );
  }


  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (isWaitingForOthers) {
      return Scaffold(
        appBar: AppBar(title: const Text('En attente des autres joueurs...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (jwt == null || challenges.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Chargement...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final currentChallenge = challenges[currentChallengeIndex];
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: Text('Chrono ${_formatTime(_globalTimeLeft)}'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (currentChallenge['image_path'] != null)
              Image.network(currentChallenge['image_path'], height: 200)
            else
              const Text('Aucune image disponible.', style: TextStyle(color: Colors.white)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${currentChallenge['first_word']}',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _secondWordController,
                    decoration: const InputDecoration(
                      hintText: 'Mot 2',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${currentChallenge['third_word']}',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  '${currentChallenge['fourth_word']}',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _fifthWordController,
                    decoration: const InputDecoration(
                      hintText: 'Mot 5',
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _sendAnswer,
              icon: const Icon(Icons.send),
              label: const Text('Envoyer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _sendEmptyAnswer,
              child: const Text('Abandonner'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
