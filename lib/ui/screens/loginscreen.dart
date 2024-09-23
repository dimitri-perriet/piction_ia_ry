import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart'; // Importez l'écran Dashboard

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _pseudoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true; // Pour masquer le mot de passe

  @override
  void dispose() {
    _pseudoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Soumettre le formulaire de connexion
  Future<void> _submitLoginForm() async {
    if (_formKey.currentState!.validate()) {
      final response = await _loginUser(
        _pseudoController.text,
        _passwordController.text,
      );

      // Vérification si la réponse contient bien un token
      if (response != null && response['token'] != null) {
        // Enregistrer le token localement
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt', response['token']);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connexion réussie')),
        );

        // Naviguer vers DashboardScreen après la connexion
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        // Si le token n'est pas présent ou si la réponse est incorrecte
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur de connexion : token non reçu')),
        );
      }
    }
  }

  // Appel API pour la connexion
  Future<Map<String, dynamic>?> _loginUser(String name, String password) async {
    final url = Uri.parse('https://pictioniary.wevox.cloud/api/login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); // Le token est retourné dans la réponse
    } else {
      return null; // Erreur ou statut incorrect
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'PICTION.IA.RY',
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    fontSize: 36,
                  ),
                ),
                const SizedBox(height: 60),
                // Champ identifiant (pseudo)
                TextFormField(
                  controller: _pseudoController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Identifiant',
                    labelStyle: Theme.of(context).textTheme.bodyMedium,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez saisir un identifiant';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Champ mot de passe
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscureText, // Masquer le mot de passe
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Mot de passe',
                    labelStyle: Theme.of(context).textTheme.bodyMedium,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez saisir un mot de passe';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Bouton de connexion
                ElevatedButton(
                  onPressed: _submitLoginForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: const Text('Se connecter'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
