```bash
wanderlens_app/
├── docs/                        # 📚 Documentation projet & livrables
│   ├── architecture.md          # Schéma d'architecture & flux de données
│   ├── api_contracts.md         # Documentation des endpoints et exemples JSON
│   ├── setup_guide.md           # Instructions pas-à-pas pour cloner et lancer
│   └── screenshots/             # Captures d'écran de l'application finie
│
├── assets/                      # 🎨 Ressources statiques
│   ├── icons/                   # Icônes vectorielles ou PNG
│   └── images/                  # Images d'illustration (onboarding, placeholder)
│
├── lib/
│   ├── main.dart                # 🚀 Point d'entrée de l'app (initialisation Firebase, Isar, runApp)
│   │
│   ├── constants/               # 🎨 Design System & Constantes globales
│   │   ├── app_colors.dart      # Palette de couleurs (Material 3)
│   │   ├── app_themes.dart      # ThemeData clair et sombre
│   │   └── api_constants.dart   # URLs de base, timeouts, clés de configuration
│   │
│   ├── models/                  # 📦 Objets métiers & DTOs (Data Transfer Objects)
│   │   ├── spot_model.dart      # Classe Spot (id, titre, image, coords, résumé IA)
│   │   └── weather_model.dart   # Parsing JSON de l'API météo (factory fromJson)
│   │
│   ├── services/                # 🌐 Clients externes & Hardware (Bas niveau)
│   │   ├── api_service.dart     # Appels HTTP bruts (Open-Meteo)
│   │   ├── gemini_service.dart  # Intégration du SDK Google Generative AI
│   │   ├── location_service.dart# Géolocalisation GPS (geolocator)
│   │   └── isar_service.dart    # Initialisation & requêtes Isar DB locales
│   │
│   ├── repositories/            # 🗄️ Source de Vérité Unique (Chef d'orchestre des données)
│   │   ├── spot_repository.dart # Décide : lit-on dans Isar (offline) ou Firebase (cloud) ?
│   │   └── weather_repository.dart # Récupère la météo et formate l'information
│   │
│   ├── providers/               # ⚡ Gestion de l'état réactif (State Management)
│   │   ├── spot_provider.dart   # Notifier gérant la liste des spots et leur état (Loading, Data, Error)
│   │   └── weather_provider.dart# Provider météo pour notifier l'UI en direct
│   │
│   ├── screens/                 # 📱 Écrans complets (Pages / Vues)
│   │   ├── home/                # Écran d'accueil (flux des spots découverts)
│   │   │   └── home_screen.dart
│   │   ├── scan/                # Écran de prise de vue caméra + prompt Gemini
│   │   │   └── scan_screen.dart
│   │   └── detail/              # Écran de détail d'un spot (météo, GPS, carte)
│   │       └── spot_detail_screen.dart
│   │
│   └── widgets/                 # 🧩 Composants UI réutilisables (Briques modulaires)
│       ├── spot_card.dart       # Carte d'un spot dans la liste
│       ├── weather_chip.dart    # Badge météo avec icône dynamique
│       └── loading_overlay.dart # Indicateur de chargement élégant
│
├── test/                        # 🧪 Tests automatisés
│   ├── unit/                    # Tests unitaires (parsing JSON, calculs)
│   └── widget/                  # Tests de widgets (interactions boutons)
│
├── .env.example                 # 🔑 Modèle de variables d'environnement (sans secrets)
├── .gitignore                   # 🙈 Fichiers à exclure de Git (.env, build/, .dart_tool)
├── pubspec.yaml                 # 📦 Dépendances et déclarations d'assets
└── README.md                    # 📖 Vitrine du projet sur GitHub
```


Une application qui permet de sélectionner n'importe quel pays du monde, d'afficher ses données officielles et de générer un itinéraire personnalisé.API gratuite : REST Countries API pour obtenir la capitale, les langues parlées, la monnaie et le drapeau sans aucune restriction.  IA de Google (Gemini) : Utilise le contexte du pays et de la capitale pour concevoir un itinéraire touristique sur 3 jours adapté aux préférences de l'utilisateur.

