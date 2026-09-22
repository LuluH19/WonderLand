# Services et intégrations externes

Chaque service encapsule une seule technologie. Les repositories et les
providers ne manipulent jamais directement `http`, `FirebaseAuth`,
`FirebaseFirestore`, `FirebaseAI` ou `ImagePicker`.

## 1. REST Countries (`countries_service.dart`)

| | |
|---|---|
| URL | `https://api.restcountries.com/countries/v5` |
| Authentification | En-tête `Authorization: Bearer <clé>` |
| Clé | Lue à la compilation via `String.fromEnvironment('REST_COUNTRIES_API_KEY')` |
| Pagination | 100 pays par page (plan gratuit) ; on enchaîne les `offset` tant que `meta.more` est `true` |
| Champs demandés | `names.common, codes.alpha_2, capitals.name, region, subregion, population, languages.name, currencies, calling_codes, flag.url_png` |

`fetchAll()` renvoie la liste complète triée par nom. Erreurs possibles,
toutes sous forme de `CountriesException` :

- clé vide : message expliquant comment remplir `.env` ;
- `http.ClientException` (DNS, pas de réseau) : `Pas de connexion réseau` ;
- statut HTTP différent de 200 : le statut et le corps de la réponse.

Le client `http.Client` et la clé sont injectables par le constructeur.

## 2. Firebase Auth (`auth_service.dart`)

| Méthode | Bouton de l'écran | Détail |
|---|---|---|
| `signInAsGuest()` | SKIP - CONTINUE AS GUEST | `signInAnonymously` |
| `signInWithEmail(email, password)` | CONTINUE WITH EMAIL | `signInWithEmailAndPassword` |
| `signUpWithEmail(email, password)` | Sign Up | `createUserWithEmailAndPassword` |
| `linkGuestToEmail(email, password)` | (disponible, non branché) | Transforme un invité en compte email en gardant le même uid |
| `signInWithGoogle()` | CONTINUE WITH GOOGLE | `google_sign_in` 7.x : `GoogleSignIn.instance.initialize()` une fois, puis `authenticate()`, puis `signInWithCredential` |
| `signInWithApple()` | CONTINUE WITH APPLE | `sign_in_with_apple` avec nonce SHA-256 ; iOS et macOS uniquement |
| `sendPasswordReset(email)` | Forgot Password? | `sendPasswordResetEmail` |
| `signOut()` | SIGN OUT | Déconnecte Google puis Firebase |
| `describeError(error)` | | Traduit les codes Firebase, Google et Apple en messages français |

Points d'attention :

- `FirebaseAuth.instance` est résolu paresseusement : la classe peut être
  instanciée avant `Firebase.initializeApp`.
- Google et Apple renvoient `null` quand l'utilisateur annule ; l'écran ne
  montre alors aucun message.
- Le nonce Apple est une chaîne aléatoire de 32 caractères envoyée hachée à
  Apple et en clair à Firebase, qui vérifie la correspondance.
- `LoginPage` ne navigue jamais : c'est le `redirect` de GoRouter qui réagit
  au flux `authStateChanges` (voir [architecture.md](architecture.md)).

## 3. Gemini via Firebase AI Logic (`gemini_service.dart`)

| | |
|---|---|
| Package | `firebase_ai ^4.0.0` |
| Backend | `FirebaseAI.googleAI()` (Gemini Developer API) |
| Modèle | `gemini-3.5-flash-lite` (constante `GeminiService.modelName`), texte et vision |
| Format de réponse | JSON contraint par un `Schema` (`responseMimeType: application/json`) |
| Clé API | Aucune dans l'application : Firebase AI Logic la gère côté serveur, protégée par App Check |

Pourquoi ce package et pas `google_generative_ai` vu en cours : ce dernier est
déprécié, et Firebase AI Logic évite d'embarquer une clé Gemini dans l'APK.

### `generateItinerary({countryName, capital, travelStyle})`

Schéma demandé : `{city, summary, days: [{title, description}]}`. Le prompt
impose l'anglais, exactement trois jours, un titre de la forme
`DAY 1 - Alfama & the river` et une description matin / après-midi / soir.
Le résultat est converti par `Itinerary.fromMap`, puis `countryName` et
`travelStyle` sont ajoutés.

### `analyzePhoto(Uint8List imageBytes)`

Schéma demandé : `{placeName, countryName, description}`. L'image est envoyée
en `InlineDataPart('image/jpeg', bytes)` avec un prompt qui demande le nom
anglais courant du pays (pour pouvoir le retrouver dans la liste REST
Countries) et des chaînes vides en cas de doute.

### Erreurs

Toute exception du SDK est enveloppée dans `GeminiException('Gemini est
indisponible : ...')`. Une réponse sans texte devient
`GeminiException('Gemini a renvoyé une réponse vide.')`. Les écrans affichent
`toString()` tel quel.

Si Google renvoie une erreur 503 (capacité du modèle), changer `modelName` ou
réessayer plus tard.

## 4. Firebase App Check (`main.dart`)

App Check prouve à Firebase que l'appel vient bien de l'application. Sans
jeton valide, Firebase AI Logic refuse les requêtes Gemini.

| Mode | Android | iOS |
|---|---|---|
| Debug (`kDebugMode`) | `AndroidDebugProvider` | `AppleDebugProvider` |
| Release | `AndroidPlayIntegrityProvider` | `AppleDeviceCheckProvider` |

En debug, chaque simulateur ou appareil génère un jeton à enregistrer une
fois dans la console Firebase (voir [setup.md](setup.md)).

## 5. Sélection de photo (`photo_service.dart`)

`PhotoService.pick(ImageSource)` utilise `image_picker ^1.2.3` avec
`maxWidth: 1024` et `imageQuality: 80` pour réduire la taille envoyée à
Gemini. Renvoie `null` si l'utilisateur ferme le sélecteur.

Permissions natives nécessaires :

- Android : aucune déclaration nécessaire, image_picker passe par les
  intents système (appareil photo et Photo Picker).
- iOS : `NSCameraUsageDescription` et `NSPhotoLibraryUsageDescription` dans
  `Info.plist`.

## 6. Repositories

| Repository | Services combinés | Méthodes |
|---|---|---|
| `CountryRepository` | `CountriesService` | `getAll()`, `filter(all, query)`, `findByName(all, name)` |
| `ItineraryRepository` | `GeminiService`, `LocalDbService`, `FirestoreService` | `generate(...)`, `watchSaved(uid)`, `save(itinerary, uid)`, `delete(itinerary)`, `syncFromCloud(uid)` |
| `PhotoRepository` | `PhotoService`, `GeminiService` | `pickAndAnalyze(source)` renvoie un `PhotoResult` (octets + `PhotoAnalysis`) ou `null` |

Les repositories reçoivent leurs services par le constructeur : un service
peut donc être remplacé sans modifier le repository.
