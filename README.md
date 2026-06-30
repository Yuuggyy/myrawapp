# MyRawApp 🏦

**Super-application bancaire IA pour RawBank RDC**
*by Inspire × YuuStore*

## Vision
MyRawApp est une plateforme digitale bancaire de nouvelle génération qui place l'intelligence artificielle au cœur du traitement des dossiers de financement, de la conformité et de la relation client.

## Stack Technique
- **Mobile** : Flutter 3.x (iOS + Android)
- **Backend** : FastAPI (Python) — *Phase 2*
- **IA** : LangChain + Claude 3.5 Sonnet — *Phase 2*
- **DB** : PostgreSQL + Redis — *Phase 2*
- **Paiements** : IllicoCash API — *Phase 4*

## Fonctionnalités Phase 1 (Données statiques)
- ✅ Splash Screen animé
- ✅ Onboarding 3 slides
- ✅ Login / Register (2 étapes)
- ✅ Dashboard avec solde IllicoCash, projets, transactions
- ✅ Module Projets avec scores IA
- ✅ Chat IA contextuel
- ✅ Gestion des comptes
- ✅ Profil utilisateur + KYC niveaux

## Lancer le projet
```bash
flutter pub get
flutter run
```

## Architecture
```
lib/
├── main.dart
├── theme/          # AppTheme, AppColors
├── data/           # mock_data.dart (Phase 1)
├── screens/
│   ├── auth/       # Login, Register
│   ├── onboarding/
│   ├── dashboard/
│   ├── projects/
│   ├── chat/
│   ├── accounts/
│   └── profile/
└── widgets/        # Composants réutilisables
```

## Roadmap
| Phase | Durée | Statut |
|-------|-------|--------|
| Phase 1 — Flutter UI statique | Semaines 1-4 | ✅ En cours |
| Phase 2 — Backend FastAPI + IA | Semaines 5-10 | ⏳ |
| Phase 3 — Admin Dashboard | Semaines 11-16 | ⏳ |
| Phase 4 — IllicoCash + Notifications | Semaines 17-20 | ⏳ |
| Phase 5 — Polish & Lancement | Semaines 21-24 | ⏳ |

---
*Architecture conçue pour RawBank RDC — Première banque commerciale de la RDC*
