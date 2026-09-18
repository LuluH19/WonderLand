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
│   ├── models/                  # 📦 Objets métiers & DTOs (Country, Itinerary)
│   ├── services/                # 🌐 Clients externes (bas niveau)
│   │   ├── countries_service.dart   # Appels HTTP REST Countries API
│   │   ├── auth_service.dart        # Firebase Auth (connexion anonyme)
│   │   └── firestore_service.dart   # Lecture / écriture Cloud Firestore
│   ├── repositories/            # 🗄️ Source de vérité unique (orchestration des services)
│   ├── providers/               # ⚡ Gestion de l'état réactif (State Management)
│   ├── screens/                 # 📱 Écrans complets (recherche, pays, itinéraire, favoris)
│   └── widgets/                 # 🧩 Composants UI réutilisables
│
├── test/                        # 🧪 Tests automatisés
│   ├── unit/                    # Tests unitaires (parsing JSON, services)
│   └── widget/                  # Tests de widgets (interactions)
│
├── .env.example                 # 🔑 Modèle de variables d'environnement (REST Countries ; Gemini utilise Firebase)
├── .gitignore                   # 🙈 Fichiers exclus de Git (.env, build/, .dart_tool)
├── firebase.json                # 🔥 Config FlutterFire (apps Android / iOS)
├── pubspec.yaml                 # 📦 Dépendances et déclarations d'assets
└── README.md                    # 📖 Vitrine du projet sur GitHub
```
