import 'package:flutter/material.dart';

class EndGameScreen extends StatelessWidget {
  const EndGameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: const [
                    Icon(Icons.star, size: 40, color: Colors.black),
                    SizedBox(height: 8),
                    Text(
                      'Victoire de l\'équipe ROUGE',
                      style: TextStyle(fontSize: 24, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Résumé des rouges
                    const Text(
                      'Résumé de la partie des rouges',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    _buildGameSummaryItem(context, 'Une poule sur un mur', 'Poulet', 'Volaille', 'Oiseau', '+25', '-8'),
                    _buildGameSummaryItem(context, 'Une poule sur un mur', 'Mots manquants', '', '', '+25', '-8'),
                    _buildGameSummaryItem(context, 'Une poule sur un mur', 'Mots manquants', '', '', '+25', '-8'),
                    const SizedBox(height: 20),
                    // Résumé des bleus
                    const Text(
                      'Résumé de la partie des bleus',
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    _buildGameSummaryItem(context, 'Une poule sur un mur', 'Poulet', 'Volaille', 'Oiseau', '+25', '-8'),
                    _buildGameSummaryItem(context, 'Une poule sur un mur', 'Mots manquants', '', '', '+25', '-8'),
                    _buildGameSummaryItem(context, 'Une poule sur un mur', 'Mots manquants', '', '', '+25', '-8'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameSummaryItem(BuildContext context, String description, String chip1, String chip2, String chip3, String pointsWon, String pointsLost) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: Image.network(
                'https://picsum.photos/200/300',
                height: 60,
                width: 60,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(description, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 8.0,
                    children: [
                      if (chip1.isNotEmpty) _buildChip(chip1),
                      if (chip2.isNotEmpty) _buildChip(chip2),
                      if (chip3.isNotEmpty) _buildChip(chip3),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text(pointsWon, style: const TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),
                Text(pointsLost, style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(width: 10),
            // Icône de détail (flèche)
            const Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.red,
      labelStyle: const TextStyle(color: Colors.white),
    );
  }
}
