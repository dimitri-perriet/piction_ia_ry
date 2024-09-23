import 'package:flutter/material.dart';

class ChallengeInputScreen extends StatelessWidget {
  const ChallengeInputScreen({Key? key}) : super(key: key);

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
                      },
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            FloatingActionButton(
              onPressed: () {
              },
              child: const Icon(Icons.add),
              //Style l'icon
              backgroundColor: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}