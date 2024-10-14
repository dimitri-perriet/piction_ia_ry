import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TeamCompositionScreen extends StatefulWidget {
  final String sessionId;
  final String userName;

  const TeamCompositionScreen({Key? key, required this.sessionId, required this.userName}) : super(key: key);

  @override
  _TeamCompositionScreenState createState() => _TeamCompositionScreenState();
}

class _TeamCompositionScreenState extends State<TeamCompositionScreen> {
  List<String> blueTeam = [];
  List<String> redTeam = [];
  String? errorMessage;

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
            _buildTeamTile(blueTeam, Colors.blue),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _joinTeam('blue'),
              child: const Text('Rejoindre Équipe Bleue'),
            ),
            const SizedBox(height: 40),
            Text(
              'Equipe Rouge',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            _buildTeamTile(redTeam, Colors.red),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _joinTeam('red'),
              child: const Text('Rejoindre Équipe Rouge'),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                _showQRCodeDialog(context, widget.sessionId);
              },
              icon: const Icon(Icons.qr_code),
              label: const Text('Inviter des amis'),
            ),
            const SizedBox(height: 20),
            errorMessage != null
                ? Text(
              errorMessage!,
              style: const TextStyle(color: Colors.red),
            )
                : Container(),
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
  Widget _buildTeamTile(List<String> team, Color color) {
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
        children: team.isNotEmpty
            ? team.map((player) => Text(player, style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white))).toList()
            : [Text('<Aucun joueur>', style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white))],
      ),
    );
  }

  // Fonction pour rejoindre une équipe
  Future<void> _joinTeam(String color) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jwt = prefs.getString('jwt');

    if (jwt == null) {
      setState(() {
        errorMessage = 'Erreur : Utilisateur non authentifié';
      });
      return;
    }

    final url = Uri.parse('https://pictioniary.wevox.cloud/api/game_sessions/${widget.sessionId}/join');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $jwt',
      },
      body: jsonEncode({'color': color}),
    );

    if (response.statusCode == 200) {
      print('Objet GameSession retourné : ${response.body}');
      setState(() {
        if (color == 'blue') {
          blueTeam.add(widget.userName);
          print('utilisateur ajouté à la blueTeam');
        } else {
          redTeam.add(widget.userName);
          print('utilisateur ajouté à la redTeam');
        }
        errorMessage = null; // Réinitialiser le message d'erreur
      });
    } else {
      setState(() {
        errorMessage = 'Erreur lors de la jonction à l\'équipe';
      });
    }
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
