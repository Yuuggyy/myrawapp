class AppConstants {
  // App Info
  static const String appName = 'RawBank';
  static const String appTagline = "Au-delà d'une banque, la puissance du changement";
  static const String bankName = 'RawBank';
  static const String bankFullName = 'RawBank SA';
  static const String version = '2.0.0';

  // Bank Info
  static const String bankFoundedYear = '2002';
  static const String bankBranches = '100+';
  static const String bankATMs = '274';
  static const String bankCountry = 'République Démocratique du Congo';
  static const String bankCEO = 'Mustafa Rawji';
  static const String bankTagline = 'Beyond a bank, the power of change';
  static const String bankValues = 'Ambition, Initiative, Collaboration, Innovation, Performance';

  // Services
  static const List<String> services = [
    'RawbankOnline',
    'IllicoCash',
    'Visa Direct',
    'Kimia Diaspora',
    'Lady\'s First',
    'We Act',
  ];

  // API — Base44 backend functions
  static const String baseUrl = 'https://base44.app/api/apps/6a10802fc1e2a32a74055143/functions';
  static const String aiChatUrl = '$baseUrl/rawbankAiChat';
  static const String adminUrl = '$baseUrl/rawbankAdmin';
  static const String ragUploadUrl = '$baseUrl/rawbankRagUpload';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Storage Keys
  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String kycLevelKey = 'kyc_level';
  static const String isAdminKey = 'is_admin';

  // KYC Levels
  static const String kycBasic = 'basic';
  static const String kycStandard = 'standard';
  static const String kycAdvanced = 'advanced';

  // Project Types
  static const List<String> projectTypes = [
    'PME',
    'Agriculture',
    'Immobilier',
    'Lady\'s First',
    'Exportation',
    'Commerce',
    'Industrie',
    'Services',
    'RSE / ESG',
    'Prêt à intérêt',
  ];

  // Project Sectors
  static const List<String> projectSectors = [
    'Agriculture & Agro-industrie',
    'Mines & Énergie',
    'Commerce & Distribution',
    'BTP & Immobilier',
    'Transport & Logistique',
    'Technologie & Télécoms',
    'Santé & Pharmacie',
    'Éducation & Formation',
    'Tourisme & Hôtellerie',
    'Industrie Manufacturière',
    'Services Financiers',
    'Environnement & Énergies Renouvelables',
  ];

  // Project Status
  static const String statusSubmitted = 'submitted';
  static const String statusPending = 'pending';
  static const String statusUnderReview = 'under_review';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';

  // Funding Types
  static const List<String> fundingTypes = [
    'Prêt',
    'Prêt avec intérêt',
    'Financement de partenariat',
    'RSE / ESG',
  ];

  // AI Agents
  static const String agentRouteur = 'routeur';
  static const String agentRse = 'rse';
  static const String agentConformite = 'conformite';
  static const String agentCommercial = 'commercial';
  static const String agentComptabilite = 'comptabilite';

  static const List<String> agentKeys = [
    agentRouteur,
    agentRse,
    agentConformite,
    agentCommercial,
    agentComptabilite,
  ];

  static const Map<String, String> agentNames = {
    'routeur': 'Routeur IA',
    'rse': 'Agent RSE',
    'conformite': 'Agent Conformité',
    'commercial': 'Agent Commercial',
    'comptabilite': 'Agent Comptabilité',
  };

  static const Map<String, String> agentDescriptions = {
    'routeur': 'Synthèse & orientation des demandes',
    'rse': 'Impact social & environnemental',
    'conformite': 'Conformité réglementaire & juridique',
    'commercial': 'Viabilité commerciale & marché',
    'comptabilite': 'Analyse financière & comptable',
  };

  // Admin credentials (demo)
  static const String adminEmail = 'admin@rawbank.cd';
  static const String adminPassword = 'rawbank2024';
}

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String businessRegister = '/business-register';
  static const String dashboard = '/dashboard';
  static const String projects = '/projects';
  static const String newProject = '/projects/new';
  static const String kyc = '/kyc';
  static const String transfer = '/transfer';
  static const String accounts = '/accounts';
  static const String profile = '/profile';
  static const String admin = '/admin';
  static const String chat = '/chat';
}
