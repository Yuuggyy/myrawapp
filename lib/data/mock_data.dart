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
    {
      "id": "3",
      "type": "Lady's First",
      "balance": 3200.00,
      "currency": "USD",
      "status": "Actif",
      "number": "LF-00842-W",
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
      "reference": "TXN-20260622-003",
    },
    {
      "id": "6",
      "type": "debit",
      "amount": 45.00,
      "currency": "USD",
      "description": "Visa Direct - Envoi diaspora",
      "date": "2026-06-20",
      "status": "Complété",
      "reference": "TXN-20260620-008",
    },
  ];
}

class MockServices {
  static const List<Map<String, dynamic>> services = [
    {
      "name": "RawbankOnline",
      "description": "Gérez vos comptes en ligne, 24h/24",
      "icon": "phone_android",
      "color": "#F0B000",
    },
    {
      "name": "IllicoCash",
      "description": "Envoyez de l'argent partout en RDC",
      "icon": "send",
      "color": "#F0B000",
    },
    {
      "name": "Visa Direct",
      "description": "Recevez et envoyez avec votre carte",
      "icon": "credit_card",
      "color": "#F0B000",
    },
    {
      "name": "Kimia Diaspora",
      "description": "Assurance pour la diaspora congolaise",
      "icon": "shield",
      "color": "#F0B000",
    },
    {
      "name": "Lady's First",
      "description": "Programme pour femmes entrepreneurs",
      "icon": "female",
      "color": "#F0B000",
    },
    {
      "name": "We Act",
      "description": "RSE et accompagnement des jeunes",
      "icon": "groups",
      "color": "#F0B000",
    },
  ];
}

class RawbankStats {
  static const String branches = "100+";
  static const String atms = "274";
  static const String foundedYear = "2002";
  static const String marketShare = "35%";
  static const String totalAssets = "2.5 Mrd $";
  static const String employees = "1,200+";
}
