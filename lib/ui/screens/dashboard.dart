import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'PICTION.IA.RY',
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontSize: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Bonjour',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: const Text('Nouvelle partie'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              icon: const Icon(Icons.qr_code),
              label: const Text('Rejoindre une partie'),
            ),
          ],
        ),
      ),
    );
  }
}