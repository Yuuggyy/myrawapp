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

  // API
  static const String baseUrl = 'https://vesper-4d02d524.base44.app/functions';
  static const String aiChatUrl = 'https://base44.app/api/apps/6a10802fc1e2a32a74055143/functions/rawbankAiChat';
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Storage Keys
  static const String tokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';
  static const String kycLevelKey = 'kyc_level';

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
    'Agriculture & Agro-alimentaire',
    'Commerce & Distribution',
    'Construction & Immobilier',
    'Éducation & Formation',
    'Énergie & Environnement',
    'Industrie & Manufacture',
    'Santé & Bien-être',
    'Services financiers',
    'Technologie & Télécoms',
    'Transport & Logistique',
  ];

  // Routing
  static const String routeSplash = '/';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeBusinessRegister = '/business-register';
  static const String routeDashboard = '/dashboard';
  static const String routeProjects = '/projects';
  static const String routeNewProject = '/projects/new';
  static const String routeKyc = '/kyc';
  static const String routeTransfer = '/transfer';
  static const String routeAccounts = '/accounts';
  static const String routeProfile = '/profile';

  // Social Links
  static const String youtubeChannel = 'https://www.youtube.com/@Rawbank';
  static const String websiteUrl = 'https://rawbank.com';
  static const String facebookUrl = 'https://www.facebook.com/RawbankSa/';
  static const String instagramUrl = 'https://www.instagram.com/rawbank/';
  static const String twitterUrl = 'https://x.com/Rawbank_sa';
}

// Convenience alias used in some screens
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
}
