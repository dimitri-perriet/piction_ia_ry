# Pictionnary – Projet Flutter

Bienvenue dans **Pictionnary**, une application Flutter ludique qui met au défi des équipes de joueurs pour deviner des images générées à partir de prompts créatifs. Dans ce jeu, les participants s'affrontent en créant des challenges, générant des images, et en essayant de deviner le contenu des dessins pour marquer des points.

---

## Description du Projet

Pictionnary combine plusieurs éléments clés :

- **Mode multi-joueurs** : Créez ou rejoignez des sessions de jeu pour affronter d'autres joueurs.
- **Challenges créatifs** : Élaborez des phrases à dessiner en respectant des contraintes (ex. mots interdits) pour challenger vos adversaires.
- **Génération d'images** : Utilisez une API d'IA pour transformer des prompts en images illustrant les défis.
- **Système de scores** : Gagnez ou perdez des points en fonction de vos performances (génération d'images, tentatives de réponses, etc.).

---

## Prérequis

- [Flutter](https://docs.flutter.dev/get-started/install) (version stable recommandée).
- Un **émulateur Android/iOS** configuré ou un **appareil physique** connecté via USB.
- Accès à l'**API Pictionnary** pour gérer les joueurs, sessions et challenges.

---

## Installation et Lancement

1. **Cloner le dépôt :**
Se positionner dans le dossier du projet :
cd pictionnary
Installer les dépendances :
flutter pub get
Lancer l'application :
flutter run
Flutter détectera les appareils connectés ou les émulateurs configurés et vous proposera de choisir le périphérique sur lequel lancer l’application.

Pictionnary communique avec une API qui gère l'inscription, la connexion, les sessions de jeu et les challenges. Assurez-vous que l'URL de base de l'API est correctement configurée dans le code (par exemple dans un fichier de configuration ou dans les services API).

Pour les appels protégés, un token JWT est requis. Après la connexion via l’endpoint /login, le token doit être inclus dans les entêtes HTTP comme suit :

Authorization: Bearer <votre_token_JWT>