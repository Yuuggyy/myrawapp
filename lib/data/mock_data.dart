class MockUser {
  static const String name = "Jean-Philippe Mukendi";
  static const String email = "jpmukendi@rawbank.cd";
  static const String phone = "+243 81 234 5678";
  static const String kycLevel = "Standard";
  static const String clientType = "Particulier";
  static const String accountNumber = "RAW-2024-00842";
}

class MockAccounts {
  static const List<Map<String, dynamic>> accounts = [
    {
      "id": "1",
      "type": "IllicoCash",
      "balance": 2450.75,
      "currency": "USD",
      "status": "Actif",
      "number": "IC-843920",
    },
    {
      "id": "2",
      "type": "Compte Particulier",
      "balance": 8750.00,
      "currency": "USD",
      "status": "Actif",
      "number": "RAW-00842-P",
    },
  ];
}

class MockTransactions {
  static const List<Map<String, dynamic>> transactions = [
    {
      "id": "1",
      "type": "credit",
      "amount": 500.00,
      "currency": "USD",
      "description": "Virement reçu - Mama Shop",
      "date": "2026-06-30",
      "status": "Complété",
      "reference": "TXN-20260630-001",
    },
    {
      "id": "2",
      "type": "debit",
      "amount": 120.50,
      "currency": "USD",
      "description": "Paiement facture SNEL",
      "date": "2026-06-29",
      "status": "Complété",
      "reference": "TXN-20260629-045",
    },
    {
      "id": "3",
      "type": "debit",
      "amount": 75.00,
      "currency": "USD",
      "description": "Frais analyse dossier PME",
      "date": "2026-06-28",
      "status": "Complété",
      "reference": "TXN-20260628-012",
    },
    {
      "id": "4",
      "type": "credit",
      "amount": 1200.00,
      "currency": "USD",
      "description": "Salaire Juin 2026",
      "date": "2026-06-25",
      "status": "Complété",
      "reference": "TXN-20260625-001",
    },
    {
      "id": "5",
      "type": "debit",
      "amount": 200.00,
      "currency": "USD",
      "description": "Recharge IllicoCash",
      "date": "2026-06-22",
      "status": "Complété",
      "reference": "TXN-20260622-089",
    },
  ];
}

class MockProjects {
  static const List<Map<String, dynamic>> projects = [
    {
      "id": "1",
      "title": "Épicerie Bio Gombe",
      "type": "PME",
      "sector": "Commerce / Alimentation",
      "amount": 25000.00,
      "currency": "USD",
      "status": "En validation humaine",
      "statusCode": 3,
      "createdDate": "2026-06-15",
      "aiScore": 78,
      "rseScore": 82,
      "complianceScore": 91,
      "commercialScore": 74,
      "accountingScore": 65,
      "aiRecommendation": "Favorable",
      "step": "Analyse IA terminée — En attente validation chargé de compte",
    },
    {
      "id": "2",
      "title": "Salon de Beauté Lady's First",
      "type": "Lady's First",
      "sector": "Services / Beauté",
      "amount": 8000.00,
      "currency": "USD",
      "status": "Analyse IA en cours",
      "statusCode": 2,
      "createdDate": "2026-06-28",
      "aiScore": 0,
      "rseScore": 0,
      "complianceScore": 0,
      "commercialScore": 0,
      "accountingScore": 0,
      "aiRecommendation": "En cours",
      "step": "Documents reçus — Routage IA en cours",
    },
    {
      "id": "3",
      "title": "Ferme Avicole Kasaï",
      "type": "Agriculture",
      "sector": "Agriculture / Élevage",
      "amount": 45000.00,
      "currency": "USD",
      "status": "Décision rendue",
      "statusCode": 4,
      "createdDate": "2026-05-10",
      "aiScore": 85,
      "rseScore": 90,
      "complianceScore": 88,
      "commercialScore": 80,
      "accountingScore": 82,
      "aiRecommendation": "Favorable",
      "step": "Approuvé — Contrat en préparation",
    },
  ];
}

class MockChatMessages {
  static const List<Map<String, dynamic>> messages = [
    {
      "id": "1",
      "sender": "ai",
      "content": "Bonjour Jean-Philippe ! Je suis votre assistant IA RawBank. Comment puis-je vous aider avec votre dossier de financement aujourd'hui ?",
      "time": "09:00",
      "date": "2026-06-30",
    },
    {
      "id": "2",
      "sender": "user",
      "content": "Bonjour ! J'ai des questions sur mon dossier Épicerie Bio Gombe.",
      "time": "09:05",
      "date": "2026-06-30",
    },
    {
      "id": "3",
      "sender": "ai",
      "content": "Bien sûr ! Votre dossier 'Épicerie Bio Gombe' est actuellement en validation humaine après une analyse IA favorable (score global : 78/100). Votre chargé de compte Mme Kabila l'examinera dans les 48h. Avez-vous des documents supplémentaires à fournir ?",
      "time": "09:06",
      "date": "2026-06-30",
    },
    {
      "id": "4",
      "sender": "user",
      "content": "Est-ce que je dois fournir un plan de financement supplémentaire ?",
      "time": "09:10",
      "date": "2026-06-30",
    },
    {
      "id": "5",
      "sender": "ai",
      "content": "D'après l'analyse de votre dossier, votre plan de financement actuel est suffisant. Cependant, l'IA Comptabilité suggère d'ajouter des projections de cash-flow sur 24 mois pour renforcer votre dossier. Souhaitez-vous un modèle de tableau ?",
      "time": "09:11",
      "date": "2026-06-30",
    },
  ];
}

class MockNotifications {
  static const List<Map<String, dynamic>> notifications = [
    {
      "id": "1",
      "title": "Analyse IA terminée",
      "body": "Votre dossier 'Épicerie Bio Gombe' a été analysé. Score global : 78/100",
      "type": "project",
      "isRead": false,
      "time": "Il y a 2h",
    },
    {
      "id": "2",
      "title": "Document requis",
      "body": "Veuillez compléter votre KYC — pièce d'identité en attente de vérification",
      "type": "kyc",
      "isRead": false,
      "time": "Il y a 5h",
    },
    {
      "id": "3",
      "title": "Transaction reçue",
      "body": "Vous avez reçu 500 USD de Mama Shop",
      "type": "transaction",
      "isRead": true,
      "time": "Hier",
    },
  ];
}
