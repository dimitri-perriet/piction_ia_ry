import 'package:flutter/material.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Fond bleu pour correspondre au thème du jeu
      appBar: AppBar(
        title: const Text('Chrono 300'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Challenge actuel
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
                    Text('Votre challenge:', style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      children: const [
                        Chip(
                          label: Text('Poulet'),
                          backgroundColor: Colors.red,
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        Chip(
                          label: Text('Volaille'),
                          backgroundColor: Colors.red,
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        Chip(
                          label: Text('Oiseau'),
                          backgroundColor: Colors.red,
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Image du dessin
            Image.network('https://yourimageurl.com/image.png', height: 200), // Remplacer par une image appropriée
            const SizedBox(height: 20),
            // Boutons d'action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // Action pour régénérer l'image
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Régénérer l\'image (-50pts)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Action pour envoyer au devineur
                  },
                  icon: const Icon(Icons.send),
                  label: const Text('Envoyer au devineur'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Description de l'image
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Le piaf ingrédient de base des menus KFC sur des briques empilées',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                // Action pour le bouton en bas à droite
              },
              icon: const Icon(Icons.arrow_upward),
              label: const Text('Action supplémentaire'),
            ),
          ],
        ),
      ),
    );
  }
}
