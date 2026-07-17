# MyRawApp 🏦

**Super-application bancaire IA pour RawBank RDC**
*by Inspire × YuuStore*

---

## Vision

MyRawApp est une plateforme digitale bancaire de nouvelle génération qui place l'intelligence artificielle au cœur du traitement des dossiers de financement, de la conformité et de la relation client. Conçue pour RawBank (première banque commerciale de la RDC), l'application permet aux clients (particuliers et entreprises) de :

- Gérer leurs comptes bancaires et IllicoCash
- Soumettre des demandes de financement avec analyse IA multi-agents
- Discuter avec un système de chat IA à 5 agents spécialisés
- Compléter leur KYC par niveaux
- Effectuer des transferts et paiements

---

## Stack Technique

| Couche | Technologie | Statut |
|--------|-------------|--------|
| **Mobile** | Flutter 3.x (Material 3, Inter font) | ✅ Actif |
| **Architecture** | Feature-first (presentation/core/data) | ✅ Actif |
| **State** | StatefulWidget (pas de Riverpod/Bloc — volontairement simple) | ✅ Actif |
| **HTTP** | Dio 5.x avec interceptors (token refresh) | ✅ Configuré |
| **Storage** | SharedPreferences (session, type de compte, secteur) | ✅ Actif |
| **API IllicoCash** | Mock service simulé en Dart | ✅ Actif |
| **Backend REST** | FastAPI (Python) | ⏳ Phase 2 |
| **IA** | LangChain + Claude / OpenAI | ⏳ Phase 2 |
| **DB** | PostgreSQL + Redis | ⏳ Phase 2 |

---

## Démarrage

```bash
flutter pub get
flutter run
```

Aucune configuration externe requise pour Phase 1 — toutes les données sont mockées localement.

---

## Architecture du code

```
lib/
├── main.dart                              # Point d'entrée, routing, MaterialApp
├── core/
│   ├── constants/
│   │   └── app_constants.dart             # Constantes app, routes, types de projets, secteurs, statuts, agents IA
│   ├── services/
│   │   ├── api_service.dart               # Service HTTP Dio (login, register, projects, KYC, admin)
│   │   └── illicocash_api.dart             # API mock IllicoCash (balance, transfer, deposit, withdraw, pay, FX)
│   └── theme/
│       └── app_theme.dart                 # Thème Material 3 RawBank (rouge #CC0000), polices Inter
├── data/
│   ├── models/
│   │   ├── user_model.dart                # User (Equatable) — ClientType, KycLevel, UserRole
│   │   ├── account_model.dart             # Account + Transaction (Equatable)
│   │   ├── project_model.dart             # Project + AiRecommendation + ProjectFile (Equatable)
│   │   └── business_sector.dart           # 36 secteurs DRC avec régulateurs et documents requis
│   └── mock_data.dart                     # Données statiques (user, accounts, tx, projects, chat, notifs)
├── theme/
│   └── app_theme.dart                     # Ancien thème (gold/dark) — NON utilisé, à supprimer
└── presentation/
    ├── screens/
    │   ├── splash/splash_screen.dart       # Splash animé → vérif session → login/dashboard
    │   ├── auth/
    │   │   ├── login_screen.dart           # Login (mock — email valide + mdp 6+ caractères)
    │   │   ├── register_screen.dart        # Inscription particulier + redirection entreprise
    │   │   └── business_register_screen.dart  # Inscription entreprise 3 étapes + dropdown secteurs
    │   ├── dashboard/
    │   │   └── dashboard_screen.dart       # 4 onglets: Accueil, Projets, Comptes, Profil
    │   ├── accounts/
    │   │   └── accounts_screen.dart        # Gestion comptes IllicoCash + transferts/recharge/QR
    │   ├── transfer/
    │   │   └── transfer_screen.dart        # Écran de transfert (IllicoCash / bancaire)
    │   ├── projects/
    │   │   ├── projects_screen.dart        # Liste des projets avec filtres
    │   │   └── new_project_screen.dart     # Formulaire 4 étapes (RSE, financement, business plan)
    │   ├── chat/
    │   │   └── chat_screen.dart            # Chat IA multi-agents (5 agents, sensible au secteur)
    │   ├── kyc/
    │   │   └── kyc_screen.dart             # KYC 3 niveaux (Basique, Standard, Avancé)
    │   └── profile/
    │       └── profile_screen.dart         # Profil utilisateur + paramètres
    └── widgets/
        └── common/
            ├── raw_button.dart             # Bouton réutilisable (filled/outlined, loading)
            └── raw_text_field.dart         # Champ de texte réutilisable
```

**Total**: 25 fichiers Dart, ~8 600 lignes de code.

---

## Écrans détaillés

### 1. Splash (`/`)
Splash animé avec logo "MR" + tagline. Vérifie `SharedPreferences.is_logged_in` :
- Si `true` → Dashboard
- Si `false` → Login

### 2. Auth

#### Login (`/login`)
- Email + mot de passe (mock: email valide + 6 caractères minimum)
- Lien vers inscription
- Sauvegarde session dans SharedPreferences

#### Register (`/register`)
- Sélection type de compte: Particulier | Entreprise
- **Particulier**: formulaire direct (nom, email, téléphone, mot de passe)
- **Entreprise**: redirige vers `/business-register` (ne remplit pas le formulaire ici)

#### Business Register (`/business-register`)
Inscription entreprise en **3 étapes** :

**Étape 1** — Entreprise + Secteur
- Nom de l'entreprise
- Dropdown de **36 secteurs d'activité** avec icônes, ou option "Autre"
- Si secteur sélectionné: affiche le régulateur et la description
- Si "Autre": champ texte libre pour préciser le secteur

**Étape 2** — Documents & Contact
- Email professionnel
- Téléphone
- Numéro RCCM
- ID National / NIF (optionnel)
- Si secteur connu: affiche la liste des **documents requis** spécifiques au secteur
- Si "Autre": message indiquant que l'IA analysera le secteur pour déterminer les documents

**Étape 3** — Sécurité
- Mot de passe + confirmation
- Acceptation des conditions
- Récapitulatif (nom entreprise, secteur, email, RCCM)

Sauvegarde dans SharedPreferences:
- `account_type` = "enterprise"
- `business_sector` = ID du secteur (ex: "agriculture") ou "autre"
- `business_sector_name` = nom du secteur ou texte personnalisé
- `rccm` = numéro RCCM

### 3. Dashboard (`/dashboard`)
Bottom navigation avec 4 onglets:

**Accueil**:
- Header avec nom + notifications + avatar
- Carte IllicoCash (solde, boutons: Virement, Dépôt, QR Pay, Historique)
- Actions rapides (Nouveau projet, KYC, Chat IA, Transfert)
- Bannière KYC (niveau actuel + invitation à améliorer)
- Projets en cours (carte avec statut + progression 5 étapes)
- Dernières transactions

**Projets**:
- Liste des projets avec FAB "Nouveau projet"
- Cartes détaillées (titre, type, secteur, statut, montant, progression)

**Comptes** (voir AccountsScreen)
**Profil** (voir ProfileScreen)

### 4. Accounts (`/accounts`)
- Solde total (USD + CDF avec taux de change)
- Carte IllicoCash avec boutons actifs:
  - **Virement** → écran de transfert
  - **Recharge/Dépôt** → bottom sheet (montant + méthode)
  - **QR Pay** → placeholder (snackbar "bientôt")
  - **Historique** → liste des transactions
- Liste des transactions (avec IllicoCashApi mock)
- Bouton "Créer un compte" → bottom sheet (épargne, entreprise)
- Taux de change USD/CDF simulé (~2950)

### 5. Transfer (`/transfer`)
- Type de transfert: IllicoCash | Bancaire
- Destinataire (téléphone ou IBAN)
- Montant + devise (USD/CDF)
- Note
- Confirmation avec dialog de succès

### 6. Projects

#### Projects List (`/projects`)
- Tabs: Tous | En cours | Approuvés | Rejetés
- Cartes avec statut coloré et barre de progression
- FAB "Nouveau projet"

#### New Project (`/projects/new`)
Formulaire **4 étapes** :

**Étape 1** — Informations générales
- Titre, description, localisation, secteur (dropdown 12 secteurs)
- Promoteur, expérience, analyse de marché, concurrence

**Étape 2** — Type de financement
4 options avec champs conditionnels:
1. **Prêt** — montant, durée
2. **Prêt avec intérêt** — + taux d'intérêt, garantie/collatéral
3. **Financement de partenariat** — + revenus projetés, part banque, % ROI, conditions
4. **RSE (Responsabilité Sociétale & Environnementale)** — + impact social, impact environnemental, bénéficiaires, emplois créés

**Étape 3** — Business Plan
- Upload documents (liste de 7 types: Business Plan, RCCM, ID, relevés, devis, statuts, plan de trésorerie)
- Description du business plan

**Étape 4** — Révision & soumission
- Récapitulatif de toutes les données
- Soumission → Dashboard

### 7. Chat IA (`/projects/:id/chat`)
Système de chat avec **5 agents IA spécialisés** :

| Agent | Couleur | Rôle |
|-------|---------|------|
| **Routeur** | Rouge (#CC0000) | Coordonne et oriente vers le bon agent |
| **RSE** | Vert (#2E7D32) | Impact social et environnemental |
| **Conformité** | Bleu (#1565C0) | Vérifie les exigences réglementaires |
| **Commercial** | Orange (#E65100) | Analyse viabilité commerciale |
| **Comptabilité** | Violet (#6A1B9A) | Analyse financière et ratios |

Fonctionnalités:
- Barre d'agents en haut (sélection clickable)
- Messages avec bulles (IA à gauche, utilisateur à droite)
- Indicateur de typing animé
- Quick replies contextuels par agent
- **Sensibilité au secteur**: l'agent Conformité charge le secteur depuis SharedPreferences et affiche:
  - Le régulateur spécifique au secteur
  - Les documents requis spécifiques
  - Les notes réglementaires
- Parsing markdown léger (gras avec *)
- Si secteur "Autre": l'IA indique qu'elle analysera le secteur pour déterminer les documents

### 8. KYC (`/kyc`)
3 niveaux progressifs:

| Niveau | Requirements | Débloque |
|--------|-------------|----------|
| **Basique** | Email + téléphone vérifiés | IllicoCash, transferts ≤ $500/mois, Chat IA |
| **Standard** | Pièce d'identité vérifiée | Projets ≤ $20 000, transferts ≤ $5 000/mois, compte perso |
| **Avancé** | Biométrie + documents avancés | Projets illimités, compte entreprise, tout |

### 9. Profile (`/profile`)
- Avatar + nom + email + téléphone
- Badge KYC (niveau actuel)
- Menu: Mes projets, Mes documents, Paramètres, Aide, Déconnexion
- Déconnexion → efface SharedPreferences → Login

---

## Modèles de données

### UserModel
- `id`, `email`, `phone`, `fullName`, `avatarUrl`
- `clientType`: individual | enterprise
- `kycLevel`: none | basic | standard | advanced
- `role`: client | agent | manager | admin | superAdmin
- `isActive`, `createdAt`, `lastLoginAt`

### AccountModel + TransactionModel
- Account: `id`, `userId`, `type` (illicoCash/personal/enterprise/savings), `balance`, `currency`, `status`, `accountNumber`
- Transaction: `id`, `accountId`, `type` (credit/debit/transfer/fee/refund), `amount`, `currency`, `description`, `reference`, `status`, `createdAt`

### ProjectModel + AiRecommendation + ProjectFile
- Project: `id`, `userId`, `orgId`, `title`, `type`, `sector`, `amountRequested`, `currency`, `status`, `priorityScore`, `description`, `files`, `aiRecommendations`, `globalAiScore`, `createdAt`, `updatedAt`
- ProjectStatus: draft → submitted → analyzing → aiReview → humanReview → approved/rejected → pendingInfo
- AiRecommendation: `agentType`, `score`, `summary`, `flags`, `recommendation`, `createdAt`
- ProjectFile: `id`, `filename`, `fileUrl`, `fileType`, `size`, `virusScanStatus`

### BusinessSector (36 secteurs)
Chaque secteur contient:
- `id`, `name`, `icon`, `regulator`, `description`
- `requiredDocuments`: liste de documents obligatoires (inclut 6 documents communs + documents spécifiques)
- `optionalDocuments`: documents recommandés
- `regulatoryNotes`: notes sur la réglementation du secteur

Les 36 secteurs couvrent:
Agriculture & Agro-industrie, Mines & Carrières, Télécommunications & ICT, Finance/Banque & Microfinance, BTP & Construction, Commerce & Distribution, Import-Export & Douane, Transport & Logistique, Santé & Pharmacie, Énergie & Électricité, Éducation & Formation, Médias & Audiovisuel, Industrie & Manufacturing, Tourisme & Hôtellerie, Immobilier & Promotion, Pêche & Aquaculture, Forêt & Exploitation Forestière, Textile & Habillement, Automobile & Concession, Aviation & Aéronautique, Maritime & Portuaire, Agro-alimentaire & Boissons, Pharmaceutique, Assurance & Réassurance, ONG & Organisation Non-Profit, Sécurité & Gardiennage, Conseil & Services, Pétrole & Gaz, Technologie & Innovation, Eau & Assainissement, Artisanat & Métiers d'Art, Logistique & Supply Chain, Divertissement & Événementiel, Services Miniers, Environnement & Éco-services, Agro-business & Plantations

---

## Services

### ApiService (`api_service.dart`)
Service HTTP Dio configuré pour l'API backend RawBank:
- Base URL: `https://api.myrawapp.rawbank.cd/v1`
- Interceptors: injection automatique du token Bearer, refresh token sur 401
- Endpoints: login, register, projects (CRUD), upload files, AI report/trigger, accounts, transactions, chat messages, KYC (status + upload), admin (projects, decisions, analytics)

### IllicoCashApi (`illicocash_api.dart`)
API mock complète simulant le service IllicoCash:
- Singleton avec base de données en mémoire (Map)
- 3 comptes de démonstration préchargés
- Endpoints: getBalance, createAccount, transfer (frais 0.5%), deposit, withdraw (frais 1%), payMerchant (frais 0.5%), getTransactions, verifyRecipient, verifyPin, getExchangeRate (~2950 CDF/USD)
- Délai simulé de 800ms par requête

---

## Thème

### Thème actif: `lib/core/theme/app_theme.dart`
- **Material 3** avec ColorScheme basé sur le rouge RawBank (#CC0000)
- Police: **Inter** via google_fonts
- Composants stylisés: AppBar, ElevatedButton, OutlinedButton, InputDecoration, Card, BottomNav, Chip, Divider
- Couleurs IA spécifiques par agent (RSE vert, Conformité bleu, Commercial orange, Comptabilité violet, Routeur rouge)

### Thème legacy: `lib/theme/app_theme.dart`
Ancien thème gold/dark non utilisé. Peut être supprimé.

---

## Routing

Défini dans `main.dart` avec `onGenerateRoute`:

| Route | Écran |
|-------|-------|
| `/` | SplashScreen |
| `/login` | LoginScreen |
| `/register` | RegisterScreen |
| `/business-register` | BusinessRegisterScreen |
| `/dashboard` | DashboardScreen (4 onglets) |
| `/projects` | ProjectsScreen |
| `/projects/new` | NewProjectScreen |
| `/projects/:id` | ChatScreen (chat du projet) |
| `/accounts` | AccountsScreen |
| `/transfer` | TransferScreen |
| `/kyc` | KycScreen |
| `/profile` | ProfileScreen |

---

## SharedPreferences Keys

| Key | Type | Description |
|-----|------|-------------|
| `is_logged_in` | bool | Session active |
| `user_email` | String | Email utilisateur |
| `user_name` | String | Nom utilisateur/entreprise |
| `account_type` | String | "individual" ou "enterprise" |
| `business_sector` | String | ID du secteur (ex: "agriculture") ou "autre" |
| `business_sector_name` | String | Nom du secteur ou texte personnalisé |
| `rccm` | String | Numéro RCCM (compte entreprise) |
| `access_token` | String | Token JWT (Phase 2) |
| `refresh_token` | String | Refresh token JWT (Phase 2) |
| `kyc_level` | String | Niveau KYC (Phase 2) |

---

## Roadmap

| Phase | Contenu | Statut |
|-------|---------|--------|
| **Phase 1** | Flutter UI + données mockées + chat IA + secteurs entreprise | ✅ Terminé |
| **Phase 2** | Backend FastAPI + IA réelle (LangChain) + auth JWT | ⏳ À démarrer |
| **Phase 3** | Dashboard admin (gestion dossiers, décisions, analytics) | ⏳ |
| **Phase 4** | Intégration IllicoCash réelle + notifications push | ⏳ |
| **Phase 5** | Polish, tests, déploiement App Store / Play Store | ⏳ |

---

## Notes pour la prochaine IA / développeur

1. **L'app est 100% mockée** — aucune donnée ne persiste hors SharedPreferences. L'ApiService est configuré mais le backend n'existe pas encore.

2. **Le chat IA est simulé** — les réponses sont hardcodées par agent avec des mots-clés. La sensibilité au secteur fonctionne via `_cachedSector` chargé depuis SharedPreferences dans `chat_screen.dart`.

3. **Les 36 secteurs** sont dans `lib/data/models/business_sector.dart`. Chaque secteur a son régulateur, ses documents requis et ses notes réglementaires. L'option "Autre" permet à l'utilisateur de saisir un secteur non listé.

4. **IllicoCashApi** est un mock complet en mémoire. Les soldes, transactions et frais sont simulés. Remplacer par l'API réelle quand disponible.

5. **Le formulaire New Project** a 4 étapes avec champs conditionnels selon le type de financement (Prêt, Prêt avec intérêt, Partenariat, RSE). Les données ne sont pas persistées — ajouter l'API dans Phase 2.

6. **Le thème `lib/theme/app_theme.dart`** est obsolète (ancien design gold/dark). Le thème actif est `lib/core/theme/app_theme.dart` (rouge RawBank + Inter).

7. **Pas de state management externe** (pas de Riverpod, Bloc, Provider). Tout est en StatefulWidget. C'est volontaire pour Phase 1 — envisager Riverpod en Phase 2.

8. **Le routing** gère les routes dynamiques `/projects/:id` dans `onGenerateRoute` (main.dart).

9. **Les conventions Flutter modernes** sont respectées: `withValues()` au lieu de `withOpacity()`, `const` constructors, Material 3.

10. **GitHub**: `Yuuggyy/myrawapp` — le repo ne doit contenir que les fichiers Flutter, isolé des autres projets.

---

*Architecture conçue pour RawBank RDC — Première banque commerciale de la RDC*
*Auteur: Guy Muzongo Mvula — by Inspire × YuuStore*
