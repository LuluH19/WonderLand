```bash
projet/
├── docs/                        # 📚 Documentation projet & livrables
│   ├── readme.md                # Ce fichier
│   └── Image-Design/            # Maquettes du design (signin, parcours, saved)
│
├── assets/                      # 🎨 Ressources statiques
│   ├── icons/                   # Icônes vectorielles ou PNG
│   └── images/                  # Images d'illustration (onboarding, placeholder)
│
├── lib/
│   ├── main.dart                # 🚀 Point d'entrée de l'app (initialisation Firebase, runApp)
│   ├── firebase_options.dart    # 🔥 Config Firebase générée par flutterfire configure
│   │
│   ├── constants/               # 🎨 Design System & constantes globales (couleurs, thèmes, URLs)
│   ├── models/                  # 📦 Objets métiers (Country, Itinerary @collection Isar, PhotoAnalysis)
│   ├── services/                # 🌐 Clients externes (bas niveau)
│   │   ├── countries_service.dart   # Appels HTTP REST Countries API
│   │   ├── auth_service.dart        # Firebase Auth (email, Google, Apple, invité)
│   │   ├── firestore_service.dart   # Lecture / écriture Cloud Firestore
│   │   ├── gemini_service.dart      # Gemini texte + vision (Firebase AI Logic)
│   │   ├── local_db_service.dart    # Isar : favoris hors-ligne
│   │   └── photo_service.dart       # image_picker : caméra / galerie
│   ├── repositories/            # 🗄️ Logique métier (country, itinerary, photo)
│   ├── providers/               # ⚡ Riverpod 2.x (FutureProvider, StreamProvider, StateProvider, AsyncNotifier)
│   ├── screens/                 # 📱 Écrans (login, search, country, itinerary, photo, saved)
│   └── widgets/                 # 🧩 AuthGate, AppShell, DayCard, MessageView
│
├── test/                        # 🧪 Tests automatisés (flutter test)
│   ├── unit/                    # country, itinerary, country_repository
│   └── widget/                  # search_page, saved_page (providers remplacés par des fakes)
│
├── .env.example                 # 🔑 Modèle de variables d'environnement (REST Countries ; Gemini utilise Firebase)
├── .gitignore                   # 🙈 Fichiers exclus de Git (.env, build/, .dart_tool)
├── firebase.json                # 🔥 Config FlutterFire (apps Android / iOS)
├── pubspec.yaml                 # 📦 Dépendances et déclarations d'assets
└── README.md                    # 📖 Vitrine du projet sur GitHub
```
