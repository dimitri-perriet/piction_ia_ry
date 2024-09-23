import 'package:flutter/material.dart';

class ChallengeInputScreen extends StatefulWidget {
  const ChallengeInputScreen({Key? key}) : super(key: key);

  @override
  _ChallengeInputScreenState createState() => _ChallengeInputScreenState();
}

class _ChallengeInputScreenState extends State<ChallengeInputScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Saisie des challenges'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Carte de challenge (déjà existante)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Challenge #1',
                            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Une poule sur un mur',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8.0,
                            children: [
                              Chip(
                                label: const Text('Poulet'),
                                backgroundColor: Colors.red,
                                labelStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Chip(
                                label: const Text('Volaille'),
                                backgroundColor: Colors.red,
                                labelStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              Chip(
                                label: const Text('Oiseau'),
                                backgroundColor: Colors.red,
                                labelStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        // Ajouter la logique de suppression ici
                      },
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            FloatingActionButton(
              onPressed: () {
                _showAddChallengeModal(context); // Afficher la modal
              },
              child: const Icon(Icons.add),
            ),
          ],
        ),
      ),
    );
  }

  // Fonction pour afficher la modal
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
          child: _buildAddChallengeForm(),
        );
      },
    );
  }

  // Formulaire pour ajouter un nouveau challenge
  Widget _buildAddChallengeForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Ajout d’un challenge',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ToggleButtons(
          isSelected: [true, false],
          borderRadius: BorderRadius.circular(20),
          children: const [
            Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("UN")),
            Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("UNE")),
          ],
          onPressed: (index) {
            // Gestion de l'état des boutons
          },
        ),
        const SizedBox(height: 16),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Votre premier mot',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        ToggleButtons(
          isSelected: [true, false],
          borderRadius: BorderRadius.circular(20),
          children: const [
            Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("SUR")),
            Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("DANS")),
          ],
          onPressed: (index) {
            // Gestion de l'état des boutons
          },
        ),
        const SizedBox(height: 16),
        ToggleButtons(
          isSelected: [true, false],
          borderRadius: BorderRadius.circular(20),
          children: const [
            Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("UN")),
            Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("UNE")),
          ],
          onPressed: (index) {
            // Gestion de l'état des boutons
          },
        ),
        const SizedBox(height: 16),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Votre deuxième mot',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Logique pour ajouter le challenge
          },
          child: const Text('Ajouter'),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
