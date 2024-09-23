import 'package:flutter/material.dart';

class SummaryDetailScreen extends StatelessWidget {
  const SummaryDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Une poule sur un mur'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image principale
              ClipRRect(
                borderRadius: BorderRadius.circular(15.0),
                child: Stack(
                  children: [
                    Image.network(
                      'https://picsum.photos/200/300',
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.fullscreen, color: Colors.white),
                        onPressed: () {
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Prompt utilisé',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Le piaf ingrédient de base des menus KFC sur des briques empilées',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              const Text(
                'Propositions faites',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              _buildPropositionItem('Une bête sur un mur', -1, isHighlighted: true),
              _buildPropositionItem('Une bête sur un mur', -1),
              _buildPropositionItem('Une bête sur un mur', -1),
              _buildPropositionItem('Une poule sur un mur', 25),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPropositionItem(String proposition, int score, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              decoration: BoxDecoration(
                color: isHighlighted ? Colors.green.withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(10.0),
                border: isHighlighted
                    ? Border.all(color: Colors.green, width: 2)
                    : Border.all(color: Colors.transparent),
              ),
              child: Text(
                proposition,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$score',
            style: TextStyle(
              fontSize: 16,
              color: score > 0 ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
