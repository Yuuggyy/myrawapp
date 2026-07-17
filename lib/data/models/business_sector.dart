// Business sectors for DRC with regulatory requirements
// Each sector has: name, regulator, required documents, optional documents

class BusinessSector {
  final String id;
  final String name;
  final String icon;
  final String regulator;
  final String description;
  final List<String> requiredDocuments;
  final List<String> optionalDocuments;
  final List<String> regulatoryNotes;

  const BusinessSector({
    required this.id,
    required this.name,
    required this.icon,
    required this.regulator,
    required this.description,
    required this.requiredDocuments,
    this.optionalDocuments = const [],
    this.regulatoryNotes = const [],
  });
}

class BusinessSectors {
  // Documents communs à tous les secteurs
  static const List<String> commonDocuments = [
    'RCCM (Registre du Commerce et du Crédit Mobilier)',
    'Statuts de l\'entreprise',
    'Numéro d'Identification Nationale (ID Nat / NIF)',
    'Pièce d'identité du représentant légal',
    'Patente (licence d'exploitation)',
    'Attestation de dépôt de déclaration à la DGI',
  ];

  static const List<BusinessSector> sectors = [
    BusinessSector(
      id: 'agriculture',
      name: 'Agriculture & Agro-industrie',
      icon: 'agriculture',
      regulator: 'Ministère de l\'Agriculture & SENASEM',
      description: 'Production végétale, élevage, transformation agro-alimentaire',
      requiredDocuments: [
        ...commonDocuments,
        'Autorisation d'exploitation de terres (titre foncier ou bail)',
        'Certificat phytosanitaire (pour exportation)',
        'Agrément SENASEM (semences et plants)',
      ],
      optionalDocuments: [
        'Certificat de conformité OAPI (propriété intellectuelle végétale)',
        'Attestation d\'adhésion à une coopérative agricole',
      ],
      regulatoryNotes: [
        'Les terres agricoles nécessitent un titre foncier ou un bail emphytéotique',
        'L'importation d'intrants agricoles nécessite une autorisation du Ministère',
        'L'exportation de produits agricoles requiert un certificat phytosanitaire',
      ],
    ),
    BusinessSector(
      id: 'mining',
      name: 'Mines & Carrières',
      icon: 'mining',
      regulator: 'CTCPM (Cadastre Minier) & Ministère des Mines',
      description: 'Exploration, exploitation, transformation minière',
      requiredDocuments: [
        ...commonDocuments,
        'Permis de recherche ou d'exploitation (Cadastre Minier)',
        'Certificat de conformité environnementale',
        'Carte de carrière (pour carrières)',
        'Attestation de paiement des droits miniers',
        'Plan de gestion environnemental (PGE)',
      ],
      optionalDocuments: [
        'Certificat EITI (Initiative pour la Transparence)',
        'Attestation de responsabilité sociétale minière',
      ],
      regulatoryNotes: [
        'Le Code Minier (Loi n°007/2002) régit l'ensemble du secteur',
        'Le CTCPM délivre tous les titres miniers',
        'Obligation de RSE pour toutes les entreprises minières',
        'Traçabilité obligatoire pour l'or, le coltan et l'étain (3TG)',
      ],
    ),
    BusinessSector(
      id: 'telecom',
      name: 'Télécommunications & ICT',
      icon: 'telecom',
      regulator: 'ARPTC (Autorité de Régulation des Télécommunications)',
      description: 'Téléphonie, internet, services numériques, data centers',
      requiredDocuments: [
        ...commonDocuments,
        'Licence ARPTC d'exploitation de services telecom',
        'Autorisation de fréquences radioélectriques',
        'Certificat de conformité des équipements',
      ],
      optionalDocuments: [
        'Agrément pour services de paiement mobile',
        'Certificat ISO 27001 (sécurité de l'information)',
      ],
      regulatoryNotes: [
        'L'ARPTC régule tous les services de télécommunications',
        'Les fréquences radioélectriques nécessitent une autorisation spécifique',
        'Loi n°024/2002 sur les télécommunications en RDC',
      ],
    ),
    BusinessSector(
      id: 'finance',
      name: 'Finance, Banque & Microfinance',
      icon: 'finance',
      regulator: 'BCC (Banque Centrale du Congo)',
      description: 'Banques, microfinance, transfert d'argent, fintech',
      requiredDocuments: [
        ...commonDocuments,
        'Agrément BCC (Banque Centrale du Congo)',
        'Capital minimum conformément à la réglementation BCC',
        'Plan d'affaires approuvé par la BCC',
        'Attestation de conformité anti-blanchiment (LCB-FT)',
        'Rapport d'audit prudential annuel',
      ],
      optionalDocuments: [
        'Certificat de la cellule nationale de renseignements financiers (CENAREF)',
      ],
      regulatoryNotes: [
        'La BCC est l'autorité de régulation unique',
        'Loi n°005/2002 sur la Banque Centrale',
        'Conformité stricte LCB-FT (Loi n°022/2002)',
        'Capital minimum variable selon le type d'institution',
      ],
    ),
    BusinessSector(
      id: 'construction',
      name: 'BTP & Construction',
      icon: 'construction',
      regulator: 'Ministère des Infrastructures & BTP',
      description: 'Bâtiment, travaux publics, génie civil',
      requiredDocuments: [
        ...commonDocuments,
        'Agrément BTP (classification des entreprises)',
        'Permis de construire (pour les projets)',
        'Attestation ONEM (Office National de l'Emploi)',
        'Certificat de conformité technique',
      ],
      optionalDocuments: [
        'Certification ISO 9001 (qualité)',
        'Attestation CNPP (Commission Nationale de Prévention des Pollutions)',
      ],
      regulatoryNotes: [
        'L'agrément BTP classe les entreprises en catégories (I à V)',
        'Les marchés publics nécessitent un agrément valide',
      ],
    ),
    BusinessSector(
      id: 'commerce',
      name: 'Commerce & Distribution',
      icon: 'commerce',
      regulator: 'Ministère du Commerce & DGCC',
      description: 'Commerce de gros, détail, grande distribution',
      requiredDocuments: [
        ...commonDocuments,
        'Registre du Commerce (RCCM) avec mention du secteur commerce',
        'Attestation de respect des normes de concurrence (DGCC)',
      ],
      optionalDocuments: [
        'Licence d'importation (pour produits réglementés)',
        'Attestation de conformité aux normes métrologiques',
      ],
      regulatoryNotes: [
        'La DGCC veille à la loyauté de la concurrence',
        'Les prix de certains produits sont réglementés',
      ],
    ),
    BusinessSector(
      id: 'import_export',
      name: 'Import-Export & Douane',
      icon: 'import_export',
      regulator: 'DGDA (Direction Générale des Douanes & Accises)',
      description: 'Importation, exportation, transit, commissionnement',
      requiredDocuments: [
        ...commonDocuments,
        'Code douanier (numéro d'identification douanier)',
        'Registre des opérations douanières',
        'Attestation de franchise ou régime douanier',
      ],
      optionalDocuments: [
        'Certificat d'origine (pour préférences tarifaires)',
        'Engagement de transit international',
      ],
      regulatoryNotes: [
        'La DGDA régule toutes les opérations douanières',
        'Le SAD (Single Administrative Document) est obligatoire',
        'Les marchandises réglementées nécessitent des licences spécifiques',
      ],
    ),
    BusinessSector(
      id: 'transport',
      name: 'Transport & Logistique',
      icon: 'transport',
      regulator: 'Ministère des Transports & OFRAC',
      description: 'Transport routier, ferroviaire, fluvial, aérien',
      requiredDocuments: [
        ...commonDocuments,
        'Licence de transport (selon mode: routier, aérien, fluvial)',
        'Cartes grises et assurances des véhicules',
        'Attestation de conformité technique (OFRAC)',
      ],
      optionalDocuments: [
        'Autorisation de transport transfrontalier',
        'Certificat IMO (pour transport maritime)',
      ],
      regulatoryNotes: [
        'OFRAC régule le transport routier de marchandises et voyageurs',
        'Les transports aérien et maritime relèvent de l'OACI/OMI',
        'Assurance responsabilité civile obligatoire',
      ],
    ),
    BusinessSector(
      id: 'health',
      name: 'Santé & Pharmacie',
      icon: 'health',
      regulator: 'Ministère de la Santé & Ordre des Pharmaciens',
      description: 'Établissements de santé, pharmacies, équipements médicaux',
      requiredDocuments: [
        ...commonDocuments,
        'Agrément du Ministère de la Santé',
        'Inscription à l'Ordre des Pharmaciens (pour pharmacies)',
        'Autorisation de mise sur le marché (AMM) pour médicaments',
        'Certificat de bonnes pratiques de stockage',
      ],
      optionalDocuments: [
        'Certification ISO 13485 (dispositifs médicaux)',
        'Attestation de respect des chaînes de froid',
      ],
      regulatoryNotes: [
        'La Direction de la Pharmacie régule les médicaments',
        'L'importation de médicaments nécessite une AMM',
        'Obligation d'avoir un pharmacien responsable',
      ],
    ),
    BusinessSector(
      id: 'energy',
      name: 'Énergie & Électricité',
      icon: 'energy',
      regulator: 'Ministère de l'Énergie & ARE (Autorité de Régulation)',
      description: 'Production, distribution, transport d'énergie',
      requiredDocuments: [
        ...commonDocuments,
        'Licence de production/distribution d'énergie (ARE)',
        'Étude d'impact environnemental (EIE)',
        'Convention de concession (pour production)',
      ],
      optionalDocuments: [
        'Certificat de réduction d'émissions (MDP/MOC)',
        'Attestation d'efficacité énergétique',
      ],
      regulatoryNotes: [
        'L'ARE régule le secteur électrique',
        'La SNEL détient le monopole de transport',
        'L'auto-production nécessite une autorisation',
      ],
    ),
    BusinessSector(
      id: 'education',
      name: 'Éducation & Formation',
      icon: 'education',
      regulator: 'Ministère de l'Enseignement (EPSP & ESU)',
      description: 'Écoles, universités, centres de formation',
      requiredDocuments: [
        ...commonDocuments,
        'Agrément du Ministère de l'EPSP ou ESU',
        'Programmes pédagogiques approuvés',
        'Attestation d'infrastructures conformes',
      ],
      optionalDocuments: [
        'Accréditation internationale',
        'Attestation de qualification du personnel enseignant',
      ],
      regulatoryNotes: [
        'L'EPSP régule le primaire et secondaire',
        'L'ESU régule l'enseignement supérieur',
        'Les diplômes doivent être reconnus par l'État',
      ],
    ),
    BusinessSector(
      id: 'media',
      name: 'Médias & Audiovisuel',
      icon: 'media',
      regulator: 'CSAC & ARPTC',
      description: 'Presse, radio, télévision, production audiovisuelle',
      requiredDocuments: [
        ...commonDocuments,
        'Autorisation du CSAC (Conseil Supérieur de l'Audiovisuel)',
        'Licence de fréquence (ARPTC) pour radio/TV',
        'Carte de journaliste (pour les journalistes)',
      ],
      optionalDocuments: [
        'Convention avec l'ORTP (Office de Radio-Télévision)',
      ],
      regulatoryNotes: [
        'Le CSAC régule la liberté de la presse',
        'La Loi n°024/2002 sur la liberté des médias',
        'Obligation de déontologie journalistique',
      ],
    ),
    BusinessSector(
      id: 'manufacturing',
      name: 'Industrie & Manufacturing',
      icon: 'manufacturing',
      regulator: 'Ministère de l'Industrie',
      description: 'Transformation, usines, production industrielle',
      requiredDocuments: [
        ...commonDocuments,
        'Agrément industriel du Ministère de l'Industrie',
        'Étude d'impact environnemental (EIE)',
        'Certificat de conformité aux normes OQTC',
      ],
      optionalDocuments: [
        'Certification ISO (9001, 14001, 45001)',
        'Attestation de zone économique spéciale (ZES)',
      ],
      regulatoryNotes: [
        'L'OQTC (Office Québécois de la Technologie et de la Conformité) vérifie les normes',
        'Les ZES offrent des avantages fiscaux',
        'Obligation EIE pour installations industrielles',
      ],
    ),
    BusinessSector(
      id: 'tourism',
      name: 'Tourisme & Hôtellerie',
      icon: 'tourism',
      regulator: 'Ministère du Tourisme & ONT',
      description: 'Hôtels, restaurants, agences de voyage, tourisme',
      requiredDocuments: [
        ...commonDocuments,
        'Licence d'exploitation touristique (ONT)',
        'Classement hôtelier (étoiles)',
        'Certificat d'hygiène et sécurité',
      ],
      optionalDocuments: [
        'Attestation de formation en hôtellerie',
        'Certification HACCP (pour restaurants)',
      ],
      regulatoryNotes: [
        'L'ONT (Office National du Tourisme) délivre les licences',
        'Le classement hôtelier est obligatoire',
        'Normes d'hygiène strictes pour la restauration',
      ],
    ),
    BusinessSector(
      id: 'realestate',
      name: 'Immobilier & Promotion',
      icon: 'realestate',
      regulator: 'Ministère des Affaires Foncières',
      description: 'Promotion immobilière, gestion locative, foncier',
      requiredDocuments: [
        ...commonDocuments,
        'Titre foncier ou bail emphytéotique',
        'Permis de construire',
        'Certificat de conformité du bâtiment',
      ],
      optionalDocuments: [
        'Attestation d'assurance décennale',
        'Rapport d'expertise immobilière',
      ],
      regulatoryNotes: [
        'La Loi foncière n°073/021 de 1973 régit le foncier',
        'Le cadastre enregistre tous les titres',
        'Les bails emphytéotiques sont de 25 ans renouvelables',
      ],
    ),
    BusinessSector(
      id: 'fishing',
      name: 'Pêche & Aquaculture',
      icon: 'fishing',
      regulator: 'Ministère de l'Agriculture (Pêche)',
      description: 'Pêche continentale, aquaculture, transformation poisson',
      requiredDocuments: [
        ...commonDocuments,
        'Licence de pêche (Ministère de l'Agriculture)',
        'Autorisation de pêcherie (pour installations)',
        'Certificat sanitaire des produits de la pêche',
      ],
      optionalDocuments: [
        'Attestation de respect des quotas de pêche',
      ],
      regulatoryNotes: [
        'La pêche est régulée par le Code Rural',
        'Les zones de pêche sont délimitées par arrêté',
      ],
    ),
    BusinessSector(
      id: 'forestry',
      name: 'Forêt & Exploitation Forestière',
      icon: 'forestry',
      regulator: 'MECNT (Ministère de l'Environnement)',
      description: 'Exploitation forestière, bois, transformation',
      requiredDocuments: [
        ...commonDocuments,
        'Concession forestière (titre forestier)',
        'Plan d'aménagement forestier (PAF)',
        'Certificat de légalité du bois (FLEGT)',
        'Étude d'impact environnemental',
      ],
      optionalDocuments: [
        'Certification FSC (Forest Stewardship Council)',
      ],
      regulatoryNotes: [
        'Le Code Forestier (Loi n°011/2002) régit le secteur',
        'Le MECNT délivre les concessions',
        'Traçabilité obligatoire via Sigifl (Système de Gestion de l'Information Forestière)',
      ],
    ),
    BusinessSector(
      id: 'textile',
      name: 'Textile & Habillement',
      icon: 'textile',
      regulator: 'Ministère de l'Industrie',
      description: 'Production textile, confection, mode',
      requiredDocuments: [
        ...commonDocuments,
        'Agrément industriel (Ministère de l'Industrie)',
        'Certificat de conformité textile',
      ],
      optionalDocuments: [
        'Certification OEKO-TEX (normes internationales)',
        'Attestation de respect du Code du Travail',
      ],
      regulatoryNotes: [
        'Le secteur textile bénéficie de la Zone Franc (préférences commerciales)',
        'Normes OQTC pour la conformité',
      ],
    ),
    BusinessSector(
      id: 'automotive',
      name: 'Automobile & Concession',
      icon: 'automotive',
      regulator: 'Ministère des Transports',
      description: 'Vente, réparation, entretien automobile',
      requiredDocuments: [
        ...commonDocuments,
        'Agrément concessionnaire (pour marques officielles)',
        'Attestation technique des ateliers',
      ],
      optionalDocuments: [
        'Certification du constructeur',
      ],
      regulatoryNotes: [
        'Les véhicules doivent être immatriculés au cadastre',
        'Contrôle technique obligatoire (OFRAC)',
      ],
    ),
    BusinessSector(
      id: 'aviation',
      name: 'Aviation & Aéronautique',
      icon: 'aviation',
      regulator: 'CAA (Civil Aviation Authority) / RVA',
      description: 'Compagnies aériennes, maintenance, services aéroportuaires',
      requiredDocuments: [
        ...commonDocuments,
        'Certificat d'exploitant aérien (AOC)',
        'Licence de maintenance (CAA)',
        'Certificat de navigabilité',
      ],
      optionalDocuments: [
        'Certification EASA (normes européennes)',
        'Attestation de conformité OACI',
      ],
      regulatoryNotes: [
        'La CAA régule l'aviation civile',
        'Obligation de respect des standards OACI',
        'La RVA gère les aéroports',
      ],
    ),
    BusinessSector(
      id: 'maritime',
      name: 'Maritime & Portuaire',
      icon: 'maritime',
      regulator: 'Ministère des Transports & SCTP',
      description: 'Transport maritime, services portuaires, transit',
      requiredDocuments: [
        ...commonDocuments,
        'Licence d'armateur (Ministère des Transports)',
        'Convention portuaire (SCTP)',
        'Certificat de sécurité maritime',
      ],
      optionalDocuments: [
        'Certification IMO (Organisation Maritime Internationale)',
      ],
      regulatoryNotes: [
        'La SCTP gère les ports de Matadi, Boma et Banana',
        'Le pavillon congolais nécessite un enregistrement spécifique',
      ],
    ),
    BusinessSector(
      id: 'food',
      name: 'Agro-alimentaire & Boissons',
      icon: 'food',
      regulator: 'Ministère de l'Agriculture & DRC FDA equivalent',
      description: 'Production alimentaire, boissons, restauration industrielle',
      requiredDocuments: [
        ...commonDocuments,
        'Agrément sanitaire (Ministère de la Santé)',
        'Certificat HACCP',
        'Attestation de conformité aux normes alimentaires',
      ],
      optionalDocuments: [
        'Certification ISO 22000 (sécurité alimentaire)',
        'Label bio (si applicable)',
      ],
      regulatoryNotes: [
        'Le contrôle sanitaire est assuré par le Ministère de la Santé',
        'Normes OQTC pour les produits alimentaires',
      ],
    ),
    BusinessSector(
      id: 'pharma',
      name: 'Pharmaceutique',
      icon: 'pharma',
      regulator: 'Ministère de la Santé & Direction de la Pharmacie',
      description: 'Fabrication, importation, distribution de médicaments',
      requiredDocuments: [
        ...commonDocuments,
        'Agrément de fabrication pharmaceutique',
        'AMM (Autorisation de Mise sur le Marché) par produit',
        'Certificat BPF (Bonnes Pratiques de Fabrication)',
        'Licence d'importation de médicaments',
      ],
      optionalDocuments: [
        'Certification WHO-GMP (OMS)',
        'Certificat de pharmacovigilance',
      ],
      regulatoryNotes: [
        'La Direction de la Pharmacie régule le secteur',
        'BPF obligatoires pour la fabrication locale',
        'L'importation nécessite une licence spécifique par produit',
      ],
    ),
    BusinessSector(
      id: 'insurance',
      name: 'Assurance & Réassurance',
      icon: 'insurance',
      regulator: 'ARCA (Autorité de Régulation et de Contrôle des Assurances)',
      description: 'Assurance vie, non-vie, réassurance, courtage',
      requiredDocuments: [
        ...commonDocuments,
        'Agrément ARCA',
        'Capital minimum réglementaire',
        'Programme de réassurance approuvé',
        'Rapport d'audit prudential annuel',
      ],
      optionalDocuments: [
        'Certificat de solvabilité',
      ],
      regulatoryNotes: [
        'L'ARCA est le régulateur unique du secteur assurances',
        'Loi n°007/2015 sur l'assurance en RDC',
        'Capital minimum: variable selon la branche',
      ],
    ),
    BusinessSector(
      id: 'ngo',
      name: 'ONG & Organisation Non-Profit',
      icon: 'ngo',
      regulator: 'Ministère du Plan & Intérieur',
      description: 'ONGD, associations, fondations, coopératives',
      requiredDocuments: [
        ...commonDocuments,
        'Acte d'enregistrement (Ministère de l'Intérieur)',
        'Statuts de l'association/ONG',
        'Agrément du Ministère du Plan (pour ONGD étrangères)',
        'Accord-cadre avec le gouvernement',
      ],
      optionalDocuments: [
        'Attestation de transparence financière',
        'Rapport d'activités annuel',
      ],
      regulatoryNotes: [
        'Les ONGD locales sont régies par le Ministère de l'Intérieur',
        'Les ONGD internationales nécessitent un accord-cadre',
        'Obligation de produire un rapport d'activités annuel',
      ],
    ),
    BusinessSector(
      id: 'security',
      name: 'Sécurité & Gardiennage',
      icon: 'security',
      regulator: 'Ministère de l'Intérieur',
      description: 'Sociétés de sécurité privée, gardiennage, protection',
      requiredDocuments: [
        ...commonDocuments,
        'Agrément du Ministère de l'Intérieur',
        'Autorisation de port d'armes (si applicable)',
        'Casier judiciaire du personnel',
      ],
      optionalDocuments: [
        'Certification ISO 18788 (management sécurité)',
      ],
      regulatoryNotes: [
        'Le secteur de la sécurité privée est strictement réglementé',
        'L'agrément du Ministère de l'Intérieur est obligatoire',
      ],
    ),
    BusinessSector(
      id: 'consulting',
      name: 'Conseil & Services',
      icon: 'consulting',
      regulator: 'Ministère des PME',
      description: 'Conseil, services professionnels, comptabilité, juridique',
      requiredDocuments: [
        ...commonDocuments,
        'Attestation de qualification professionnelle',
        'Inscription à l'Ordre (pour avocats, comptables, experts)',
      ],
      optionalDocuments: [
        'Certification professionnelle internationale',
      ],
      regulatoryNotes: [
        'Les professions libérales nécessitent une inscription à l'Ordre',
        'Le barème des honoraires est réglementé pour certaines professions',
      ],
    ),
    BusinessSector(
      id: 'oil_gas',
      name: 'Pétrole & Gaz',
      icon: 'oil_gas',
      regulator: 'Ministère des Hydrocarbures & PPDA',
      description: 'Exploration, production, raffinage, distribution pétrolière',
      requiredDocuments: [
        ...commonDocuments,
        'Permis d'exploration/exploitation (Ministère des Hydrocarbures)',
        'Étude d'impact environnemental (EIE)',
        'Certificat de conformité HSE',
        'Convention de partage de production (CPP)',
      ],
      optionalDocuments: [
        'Certification API (American Petroleum Institute)',
      ],
      regulatoryNotes: [
        'La Loi n°007/2014 sur les hydrocarbures',
        'Le PPDA (Permis de Pétrole et Développement Associé)',
        'Obligation de contenu local (Local Content)',
      ],
    ),
    BusinessSector(
      id: 'technology',
      name: 'Technologie & Innovation',
      icon: 'technology',
      regulator: 'Ministère des PTNTIC',
      description: 'Startup, software, IA, blockchain, services tech',
      requiredDocuments: [
        ...commonDocuments,
        'Enregistrement au registre du commerce (PTNTIC)',
      ],
      optionalDocuments: [
        'Certification ISO 27001 (sécurité)',
        'Brevet OAPI (propriété intellectuelle)',
        'Attestation de conformité données personnelles (Loi n°024/2002)',
      ],
      regulatoryNotes: [
        'Le Ministère des PTNTIC promeut le secteur numérique',
        'La protection des données personnelles est obligatoire',
        'Les brevets sont gérés par l'OAPI',
      ],
    ),
    BusinessSector(
      id: 'water',
      name: 'Eau & Assainissement',
      icon: 'water',
      regulator: 'Ministère de l'Eau & REGIDESO',
      description: 'Distribution d'eau, assainissement, forage',
      requiredDocuments: [
        ...commonDocuments,
        'Autorisation de prélèvement d'eau',
        'Convention avec REGIDESO (si applicable)',
        'Certificat de potabilité de l'eau',
      ],
      optionalDocuments: [
        'Certification ISO 24516 (services d'eau)',
      ],
      regulatoryNotes: [
        'La REGIDESO gère le service public de l'eau',
        'Les forages nécessitent une autorisation',
        'Qualité de l'eau conforme aux normes OMS',
      ],
    ),
    BusinessSector(
      id: 'artisanat',
      name: 'Artisanat & Métiers d'Art',
      icon: 'artisanat',
      regulator: 'Ministère des PME & INPP',
      description: 'Artisanat, métiers d'art, production artisanale',
      requiredDocuments: [
        ...commonDocuments,
        'Carte d'artisan (Ministère des PME)',
      ],
      optionalDocuments: [
        'Attestation de formation INPP',
        'Label d'authenticité',
      ],
      regulatoryNotes: [
        'L'INPP forme et certifie les artisans',
        'Les produits artisanaux peuvent bénéficier de l'IGP (indication géographique protégée)',
      ],
    ),
    BusinessSector(
      id: 'logistics',
      name: 'Logistique & Supply Chain',
      icon: 'logistics',
      regulator: 'Ministère des Transports & DGDA',
      description: 'Entreposage, chaîne d'approvisionnement, freight forwarding',
      requiredDocuments: [
        ...commonDocuments,
        'Licence de transitaire (DGDA)',
        'Attestation d'entrepôt douanier (si applicable)',
      ],
      optionalDocuments: [
        'Certification FIATA (Fédération Internationale des Transitaires)',
      ],
      regulatoryNotes: [
        'Les transitaires doivent être enregistrés à la DGDA',
        'Les entrepôts douaniers nécessitent un agrément spécifique',
      ],
    ),
    BusinessSector(
      id: 'entertainment',
      name: 'Divertissement & Événementiel',
      icon: 'entertainment',
      regulator: 'Ministère de la Culture & CSAC',
      description: 'Production musicale, événementiel, spectacle, artistes',
      requiredDocuments: [
        ...commonDocuments,
        'Autorisation du Ministère de la Culture',
        'Licence d'exploitation du droit d'auteur (SOPEXA/SONECA)',
      ],
      optionalDocuments: [
        'Carte d'artiste (Ministère de la Culture)',
        'Attestation de droits voisins',
      ],
      regulatoryNotes: [
        'La SONECA gère les droits d'auteur',
        'Les événements publics nécessitent une autorisation municipale',
        'Loi n°086/1986 sur la protection des œuvres intellectuelles',
      ],
    ),
    BusinessSector(
      id: 'mining_services',
      name: 'Services Miniers',
      icon: 'mining_services',
      regulator: 'CTCPM & Ministère des Mines',
      description: 'Services aux mines, laboratoires, expertise minière',
      requiredDocuments: [
        ...commonDocuments,
        'Agrément de prestataire minier',
        'Certificat d'accréditation du laboratoire (si applicable)',
      ],
      optionalDocuments: [
        'Certification ISO 17025 (laboratoires)',
      ],
      regulatoryNotes: [
        'Les prestataires miniers doivent être agréés par le CTCPM',
        'Les laboratoires d'analyse minière nécessitent une accréditation',
      ],
    ),
    BusinessSector(
      id: 'environment',
      name: 'Environnement & Éco-services',
      icon: 'environment',
      regulator: 'MECNT (Ministère de l'Environnement)',
      description: 'Gestion des déchets, recyclage, éco-industries, consultance EIE',
      requiredDocuments: [
        ...commonDocuments,
        'Agrément MECNT pour études environnementales',
        'Certificat de gestion des déchets dangereux',
      ],
      optionalDocuments: [
        'Certification ISO 14001 (management environnemental)',
      ],
      regulatoryNotes: [
        'Le MECNT régule le secteur environnemental',
        'Les EIE ne peuvent être réalisées que par des structures agréées',
      ],
    ),
    BusinessSector(
      id: 'agribusiness',
      name: 'Agro-business & Plantations',
      icon: 'agribusiness',
      regulator: 'Ministère de l'Agriculture & APIA',
      description: 'Grandes plantations, transformation, exportation agricole',
      requiredDocuments: [
        ...commonDocuments,
        'Bail emphytéotique ou titre foncier',
        'Agrément APIA (Agence pour la Promotion des Investissements Agricoles)',
        'Certificat phytosanitaire (export)',
      ],
      optionalDocuments: [
        'Certification Rainforest Alliance / Fair Trade',
      ],
      regulatoryNotes: [
        'L'APIA promeut les investissements agricoles',
        'Les grandes plantations nécessitent un bail emphytéotique',
      ],
    ),
  ];

  // Recherche d'un secteur par ID
  static BusinessSector? findById(String id) {
    try {
      return sectors.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // Secteurs pour affichage dans le dropdown
  static List<String> get sectorNames => sectors.map((s) => s.name).toList();
}
