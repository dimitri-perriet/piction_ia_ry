import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'loading_screen.dart';

class ChallengeInputScreen extends StatefulWidget {
  final String sessionId;

  const ChallengeInputScreen({Key? key, required this.sessionId}) : super(key: key);

  @override
  _ChallengeInputScreenState createState() => _ChallengeInputScreenState();
}

class _ChallengeInputScreenState extends State<ChallengeInputScreen> {
  String? jwt;
  List<Map<String, dynamic>> challenges = [];

  @override
  void initState() {
    super.initState();
    _loadJwt();
  }

  Future<void> _loadJwt() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    jwt = prefs.getString('jwt');
    if (jwt == null) {
      _showMessage("Erreur : JWT introuvable.");
    }
  }

  Future<void> _addChallenge(Map<String, dynamic> challengeData) async {
    final url = Uri.parse('https://pictioniary.wevox.cloud/api/game_sessions/${widget.sessionId}/challenges');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $jwt',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(challengeData),
    );

    if (response.statusCode == 201) {
      setState(() {
        challenges.add(challengeData);
      });
      Navigator.of(context).pop(); // Close modal
      _showMessage("Challenge ajouté avec succès !");

      if (challenges.length == 3) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoadingScreen(sessionId: widget.sessionId)),
        );
      }
    } else {
      _showMessage("Erreur lors de l'ajout du challenge.");
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saisie des challenges'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: challenges.length,
                itemBuilder: (context, index) {
                  final challenge = challenges[index];
                  return _buildChallengeCard(challenge);
                },
              ),
            ),
            FloatingActionButton(
              onPressed: () {
                _showAddChallengeModal(context); // Show the modal to add a new challenge
              },
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard(Map<String, dynamic> challenge) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Challenge',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${challenge["first_word"]} ${challenge["second_word"]} ${challenge["third_word"]} ${challenge["fourth_word"]} ${challenge["fifth_word"]}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              children: (challenge["forbidden_words"] as List<dynamic>)
                  .map((word) => Chip(
                label: Text(word),
                backgroundColor: Colors.red,
                labelStyle: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.white),
              ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddChallengeModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16.0,
            left: 16.0,
            right: 16.0,
          ),
          child: AddChallengeForm(onSubmit: _addChallenge),
        );
      },
    );
  }
}

class AddChallengeForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const AddChallengeForm({Key? key, required this.onSubmit}) : super(key: key);

  @override
  _AddChallengeFormState createState() => _AddChallengeFormState();
}

class _AddChallengeFormState extends State<AddChallengeForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String> forbiddenWords = [];
  String firstWord = 'un';
  String secondWord = '';
  String thirdWord = 'sur';
  String fourthWord = 'un';
  String fifthWord = '';

  void _addForbiddenWord(String word) {
    setState(() {
      if (forbiddenWords.length < 3) {
        forbiddenWords.add(word);
      } else {
        _showMessage("Vous devez avoir exactement 3 mots interdits.");
      }
    });
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      if (forbiddenWords.length != 3) {
        _showMessage("Veuillez entrer exactement 3 mots interdits.");
        return;
      }

      _formKey.currentState?.save();
      final challengeData = {
        "first_word": firstWord,
        "second_word": secondWord,
        "third_word": thirdWord,
        "fourth_word": fourthWord,
        "fifth_word": fifthWord,
        "forbidden_words": forbiddenWords,
      };
      widget.onSubmit(challengeData);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Ajout d’un challenge',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildIndependentToggleButton("un", "une", firstWord, (value) {
            setState(() {
              firstWord = value;
            });
          }),
          const SizedBox(height: 16),
          _buildWordInputField("Votre premier mot", (value) => secondWord = value!),
          const SizedBox(height: 16),
          _buildIndependentToggleButton("sur", "dans", thirdWord, (value) {
            setState(() {
              thirdWord = value;
            });
          }),
          const SizedBox(height: 16),
          _buildIndependentToggleButton("un", "une", fourthWord, (value) {
            setState(() {
              fourthWord = value;
            });
          }),
          const SizedBox(height: 16),
          _buildWordInputField("Votre deuxième mot", (value) => fifthWord = value!),
          const SizedBox(height: 16),
          _buildForbiddenWordsInput(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitForm,
            child: const Text('Ajouter'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildIndependentToggleButton(String option1, String option2, String selectedValue, Function(String) onSelected) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return ToggleButtons(
          isSelected: [selectedValue == option1, selectedValue == option2],
          onPressed: (index) {
            String newValue = index == 0 ? option1 : option2;
            setState(() {
              onSelected(newValue);
            });
          },
          borderRadius: BorderRadius.circular(20),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(option1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(option2),
            ),
          ],
        );
      },
    );
  }

  Widget _buildWordInputField(String label, Function(String?) onSaved) {
    return TextFormField(
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      onSaved: onSaved,
      validator: (value) => value == null || value.isEmpty ? "Veuillez entrer un mot" : null,
    );
  }

  Widget _buildForbiddenWordsInput() {
    final TextEditingController forbiddenWordController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Mots interdits"),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: forbiddenWordController,
                decoration: const InputDecoration(
                  labelText: 'Mot interdit',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                final word = forbiddenWordController.text.trim();
                if (word.isNotEmpty && forbiddenWords.length < 3) {
                  _addForbiddenWord(word);
                  forbiddenWordController.clear();
                } else {
                  _showMessage("Vous devez avoir exactement 3 mots interdits.");
                }
              },
            ),
          ],
        ),
        Wrap(
          spacing: 8.0,
          children: forbiddenWords
              .map((word) => Chip(
            label: Text(word),
            backgroundColor: Colors.red,
            labelStyle: const TextStyle(color: Colors.white),
            onDeleted: () {
              setState(() {
                forbiddenWords.remove(word);
              });
            },
          ))
              .toList(),
        ),
      ],
    );
  }
}