# Installation et configuration

## 1. Prérequis

| Outil | Version | Vérification |
|---|---|---|
| Flutter | 3.47.4 (canal stable) | `flutter --version` |
| Dart | inclus dans Flutter, SDK `^3.13.3` | |
| Xcode + simulateur iOS | pour iOS | `flutter doctor` |
| Android Studio + émulateur | pour Android | `flutter doctor` |
| Firebase CLI et FlutterFire CLI | pour régénérer la config Firebase | `firebase --version`, `dart pub global activate flutterfire_cli` |

Comptes nécessaires :

- un projet Firebase (le projet du dépôt s'appelle `wanderlens-app`) ;
- une clé REST Countries, plan gratuit : https://restcountries.com/sign-up

## 2. Récupérer le projet

```sh
git clone <url-du-depot>
cd projet
flutter pub get
```

## 3. Variables d'environnement

Le fichier `.env` n'est pas versionné (`.gitignore`). Le modèle est
`.env.example` :

```sh
cp .env.example .env
```

Contenu attendu :

```
REST_COUNTRIES_API_KEY=<votre clé>
```

La clé est injectée à la compilation avec `--dart-define-from-file=.env` et
lue dans le code par `String.fromEnvironment('REST_COUNTRIES_API_KEY')`.
Il n'y a pas de clé Gemini : Firebase AI Logic la gère côté serveur.

## 4. Configuration Firebase

Le dépôt contient déjà `lib/firebase_options.dart`, `firebase.json` et
`firestore.rules` pour le projet `wanderlens-app`. Pour utiliser un autre
projet Firebase, suivre ces étapes.

### 4.1 Créer le projet et les applications

1. Console Firebase > Ajouter un projet.
2. Ajouter une application Android (package `com.example.finalprojet`, voir
   `android/app/build.gradle.kts` > `applicationId`) et une application iOS
   (bundle id dans Xcode > Runner > Signing & Capabilities).
3. Depuis le dossier du projet :

   ```sh
   flutterfire configure
   ```

   Cette commande régénère `lib/firebase_options.dart`,
   `android/app/google-services.json` et
   `ios/Runner/GoogleService-Info.plist`.

### 4.2 Activer les produits

| Produit | Où | Réglage |
|---|---|---|
| Authentication | Build > Authentication > Sign-in method | Activer Email/Password, Anonymous, Google, Apple (iOS) |
| Cloud Firestore | Build > Firestore Database | Créer la base, puis déployer les règles : `firebase deploy --only firestore:rules` |
| AI Logic | Build > AI Logic | Activer avec le fournisseur Gemini Developer API |
| App Check | Build > App Check | Enregistrer les applications Android (Play Integrity) et iOS (DeviceCheck) |

### 4.3 Google Sign-In

- Android : ajouter l'empreinte SHA-1 de la clé de débogage dans la console
  (Paramètres du projet > Vos applications > Android > Ajouter une
  empreinte). Obtenir l'empreinte :

  ```sh
  cd android && ./gradlew signingReport
  ```

  Puis retélécharger `google-services.json` ou relancer `flutterfire configure`.
- iOS : `ios/Runner/Info.plist` doit contenir le `CFBundleURLSchemes` avec
  le `REVERSED_CLIENT_ID` présent dans `GoogleService-Info.plist`.

Sans ces réglages, l'application affiche `Google Sign-In mal configuré
(SHA-1 ou google-services.json).`

### 4.4 Sign in with Apple

Nécessite un compte développeur Apple, la capability "Sign in with Apple"
dans Xcode (Runner > Signing & Capabilities) et l'activation du fournisseur
Apple dans Firebase Authentication. Le bouton n'apparaît que sur iOS et
macOS.

### 4.5 Jeton de débogage App Check

En debug, App Check utilise un jeton généré par le SDK. Il faut l'autoriser
une fois par simulateur ou appareil, sinon Gemini répond avec une erreur de
permission.

1. Lancer l'application en debug.
2. Récupérer le jeton dans les logs. Sur le simulateur iOS :

   ```sh
   xcrun simctl spawn booted log show --predicate 'eventMessage CONTAINS "App Check"' --last 5m
   ```

   Sur Android, chercher `App Check debug token` dans `flutter run` ou
   `adb logcat`.
3. Console Firebase > App Check > Applications > menu de l'application >
   Gérer les jetons de débogage > Ajouter un jeton.

## 5. Génération de code (Isar)

`lib/models/itinerary.g.dart` est versionné. Le régénérer après toute
modification de `Itinerary` ou `ItineraryDay` :

```sh
dart run build_runner build --delete-conflicting-outputs
```

## 6. Lancer l'application

```sh
flutter devices
flutter run -d <id-de-l-appareil> --dart-define-from-file=.env
```

Sans `--dart-define-from-file=.env`, l'écran Search affiche le message
`Clé REST_COUNTRIES_API_KEY manquante`.

Dans Android Studio ou VS Code, ajouter `--dart-define-from-file=.env` dans
les "Additional run args" de la configuration de lancement.

## 7. Vérifications

```sh
flutter analyze     # attendu : No issues found!
```

## 8. Dépannage

| Symptôme | Cause probable | Solution |
|---|---|---|
| `Clé REST_COUNTRIES_API_KEY manquante` | `.env` absent ou option `--dart-define-from-file` oubliée | Voir sections 3 et 6 |
| `REST Countries a répondu 401` | Clé invalide | Vérifier la clé sur restcountries.com |
| `Gemini est indisponible : ... App Check ...` ou `PERMISSION_DENIED` | Jeton de débogage non enregistré | Section 4.5 |
| `Gemini est indisponible : ... 503` | Modèle saturé | Réessayer ou changer `GeminiService.modelName` |
| `Google Sign-In mal configuré` | SHA-1 absent ou `google-services.json` obsolète | Section 4.3 |
| `Ce mode de connexion n'est pas activé dans la console Firebase.` | Fournisseur désactivé | Section 4.2 |
| Erreur de compilation sur `itinerary.g.dart` | Modèle modifié sans régénération | Section 5 |
| Build Android : conflit `build/` | Build lancé depuis `android/` | `flutter clean` puis relancer depuis la racine |
