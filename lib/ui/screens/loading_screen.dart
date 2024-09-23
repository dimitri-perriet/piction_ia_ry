import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300], // Fond gris
      body: Center(
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          elevation: 4,  // Effet d'ombre pour la carte
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,  // Taille ajustée au contenu
              children: [
                // Icône de chargement
                const CircularProgressIndicator(
                  color: Colors.black, // Couleur du spinner
                ),
                const SizedBox(height: 20),  // Espace entre le spinner et le texte
                // Texte d'attente
                Text(
                  'En attente des autres joueurs',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
