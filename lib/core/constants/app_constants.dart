class AppConstants {
  // App Info
  static const String appName = 'MyRawApp';
  static const String appTagline = 'Votre banque, réinventée';
  static const String bankName = 'RawBank';
  static const String version = '1.0.0';

  // API
  static const String baseUrl = 'https://vesper-4d02d524.base44.app/functions';
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
    "Lady's First",
    'Exportation',
    'Commerce',
    'Industrie',
    'Services',
  ];

  // Project Sectors
  static const List<String> projectSectors = [
    'Agriculture & Agro-alimentaire',
    'Commerce & Distribution',
    'Construction & Immobilier',
    'Éducation & Formation',
    'Énergie & Environnement',
    'Industrie & Manufacture',
    'Mines & Ressources',
    'Santé & Pharmacie',
    'Services & Consulting',
    'Technologies & Numérique',
    'Transport & Logistique',
    'Tourisme & Hôtellerie',
  ];

  // Project Status
  static const String statusDraft = 'draft';
  static const String statusSubmitted = 'submitted';
  static const String statusAnalyzing = 'analyzing';
  static const String statusAiReview = 'ai_review';
  static const String statusHumanReview = 'human_review';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';
  static const String statusPendingInfo = 'pending_info';

  // AI Agent Types
  static const String agentRouter = 'router';
  static const String agentRSE = 'rse';
  static const String agentCompliance = 'compliance';
  static const String agentCommercial = 'commercial';
  static const String agentAccounting = 'accounting';

  // IllicoCash
  static const String currencyUSD = 'USD';
  static const String currencyCDF = 'CDF';

  // Pagination
  static const int pageSize = 20;
}

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String dashboard = '/dashboard';
  static const String projects = '/projects';
  static const String projectDetail = '/projects/:id';
  static const String newProject = '/projects/new';
  static const String chat = '/projects/:id/chat';
  static const String accounts = '/accounts';
  static const String accountDetail = '/accounts/:id';
  static const String kyc = '/kyc';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String admin = '/admin';
  static const String adminProjectDetail = '/admin/projects/:id';
}
