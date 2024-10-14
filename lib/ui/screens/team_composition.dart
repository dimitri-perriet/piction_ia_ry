import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TeamCompositionScreen extends StatelessWidget {
  final String sessionId; // Ajout de l'ID de session comme paramètre

  const TeamCompositionScreen({Key? key, required this.sessionId}) : super(key: key);

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
        title: const Text('Composition des équipes'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Equipe Bleue',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            _buildTeamTile(context, color: Colors.blue),
            const SizedBox(height: 40),
            Text(
              'Equipe Rouge',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            _buildTeamTile(context, color: Colors.red),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                _showQRCodeDialog(context, sessionId); // Appel à la méthode pour afficher le QR code
              },
              icon: const Icon(Icons.qr_code),
              label: const Text('Inviter des amis'),
            ),
            const SizedBox(height: 20),
            Text(
              'La partie sera lancée automatiquement une fois les joueurs au complet',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour construire la tuile d'équipe
  Widget _buildTeamTile(BuildContext context, {required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '<en attente>',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '<en attente>',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Méthode pour afficher le QR code dans un Dialog
  void _showQRCodeDialog(BuildContext context, String sessionId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Invitez vos amis en partageant ce QR code !',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                QrImageView(
                  data: sessionId,
                  version: QrVersions.auto,
                  size: 200.0,
                  backgroundColor: Colors.white,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Ferme le Dialog
                  },
                  child: const Text('Fermer'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
