import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/api_service.dart';
import '../../../data/models/business_sector.dart';
import '../../../core/services/ai_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── AI Agent Model ──
enum AgentType { router, rse, compliance, commercial, accounting }

extension AgentTypeExt on AgentType {
  String get label {
    switch (this) {
      case AgentType.router: return 'Routeur';
      case AgentType.rse: return 'RSE';
      case AgentType.compliance: return 'Conformité';
      case AgentType.commercial: return 'Commercial';
      case AgentType.accounting: return 'Comptabilité';
    }
  }

  String get description {
    switch (this) {
      case AgentType.router: return 'Synthèse & orientation';
      case AgentType.rse: return 'Impact social & environnemental';
      case AgentType.compliance: return 'Conformité réglementaire';
      case AgentType.commercial: return 'Viabilité commerciale';
      case AgentType.accounting: return 'Analyse financière';
    }
  }

  Color get color {
    switch (this) {
      case AgentType.router: return AppColors.aiRouter;
      case AgentType.rse: return AppColors.aiRSE;
      case AgentType.compliance: return AppColors.aiCompliance;
      case AgentType.commercial: return AppColors.aiCommercial;
      case AgentType.accounting: return AppColors.aiAccounting;
    }
  }

  IconData get icon {
    switch (this) {
      case AgentType.router: return Icons.hub;
      case AgentType.rse: return Icons.eco;
      case AgentType.compliance: return Icons.gavel;
      case AgentType.commercial: return Icons.trending_up;
      case AgentType.accounting: return Icons.calculate;
    }
  }
}

// ── Chat Message Model ──
class ChatMessage {
  final String content;
  final bool isAi;
  final DateTime time;
  final AgentType? agent;
  final List<QuickReply>? quickReplies;

  ChatMessage({
    required this.content,
    required this.isAi,
    required this.time,
    this.agent,
    this.quickReplies,
  });
}

// ── Quick Reply Model ──
class QuickReply {
  final String label;
  final String value;
  QuickReply(this.label, this.value);
}

class ChatScreen extends StatefulWidget {
  final String projectId;
  final bool showBackButton;
  const ChatScreen({super.key, required this.projectId, this.showBackButton = true});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  BusinessSector? _cachedSector;
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _inputFocusNode = FocusNode();
  bool _isAiTyping = false;
  AgentType? _typingAgent;
  AgentType? _activeAgent;
  bool _showAgentPanel = false;

  bool get _isGeneralAssistant => widget.projectId == 'assistant';
  final String _projectTitle = 'Épicerie Bio Kinshasa';

  late List<ChatMessage> _messages;

  @override
  void initState() {
    _loadSectorData();
    super.initState();
    _messages = _isGeneralAssistant ? _buildAssistantIntro() : _buildProjectIntro();
    if (!_isGeneralAssistant) _loadHistory();

    _inputFocusNode.addListener(() {
      if (_inputFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadSectorData() async {
    _cachedSector = await _loadSector();
    if (mounted) setState(() {});
  }

  Future<BusinessSector?> _loadSector() async {
    final prefs = await SharedPreferences.getInstance();
    final sectorId = prefs.getString('business_sector');
    if (sectorId != null && sectorId != 'autre') {
      return BusinessSectors.findById(sectorId);
    }
    final sectorName = prefs.getString('business_sector_name');
    if (sectorName != null) {
      try {
        return BusinessSectors.sectors.firstWhere((s) => s.name == sectorName);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> _getComplianceResponse() {
    final sector = _cachedSector;
    if (sector != null) {
      final docsCount = sector.requiredDocuments.length;
      final commonCount = BusinessSectors.commonDocuments.length;
      final sectorDocsCount = docsCount - commonCount;
      return {
        'content': "Je suis l'agent Conformité. Je vérifie votre dossier selon les exigences de *${sector.regulator}*.\n\nSecteur détecté: *${sector.name}*\n\nVérifications en cours:\n✅ Registre de commerce — à valider\n✅ Identification du promoteur\n⚠️ $sectorDocsCount document(s) spécifiques au secteur — à fournir\n\nRégulateur: ${sector.regulator}\nNiveau de conformité actuel: *45%*",
        'quickReplies': [
          QuickReply('Que dois-je fournir ?', 'conformite_docs'),
          QuickReply('Voir régulateur', 'conformite_regulateur'),
        ],
      };
    }
    return {
      'content': "Je suis l'agent Conformité. Je vérifie que votre dossier respecte les exigences réglementaires de la BCC et de RawBank.\n\nVérifications en cours:\n✅ Registre de commerce valide\n✅ Identification du promoteur\n⚠️ Statuts de l'entreprise — à fournir\n⚠️ Attestation fiscale — à fournir\n\nNiveau de conformité actuel: *65%*",
      'quickReplies': [
        QuickReply('Que dois-je fournir ?', 'conformite_docs'),
        QuickReply('Délai réglementaire', 'conformite_delai'),
      ],
    };
  }

  Map<String, dynamic> _getComplianceDocsResponse() {
    final sector = _cachedSector;
    if (sector != null) {
      final docsList = sector.requiredDocuments.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n');
      final optionalList = sector.optionalDocuments.isNotEmpty
        ? "\n\nDocuments recommandés (optionnels):\n${sector.optionalDocuments.map((d) => '• $d').join('\n')}"
        : '';
      final notesList = sector.regulatoryNotes.isNotEmpty
        ? "\n\nNotes réglementaires:\n${sector.regulatoryNotes.map((n) => '⚠️ $n').join('\n')}"
        : '';
      return {
        'content': "Documents requis pour le secteur *${sector.name}*:\n\nRégulateur: ${sector.regulator}\n\n$docsList$optionalList$notesList\n\nCes documents sont à déposer dans la section *KYC* de l'application.",
        'quickReplies': [
          QuickReply('Aller au KYC', 'goto_kyc'),
          QuickReply('Parler au Routeur', 'agent_router'),
        ],
      };
    }
    return {
      'content': "Documents réglementaires à fournir:\n\n1. Statuts de l'entreprise (notariés)\n2. Extrait RCCM\n3. Carte d'identité du gérant\n4. Attestation fiscale (DGI)\n5. Attestation de localisation\n6. Bilan financier (si > 3 ans d'activité)\n\nCes documents sont à déposer dans la section *KYC* de l'application.",
      'quickReplies': [
        QuickReply('Aller au KYC', 'goto_kyc'),
        QuickReply('Délai réglementaire', 'conformite_delai'),
      ],
    };
  }

  Future<void> _loadHistory() async {
    try {
      final raw = await ApiService.instance.getMessages(widget.projectId);
      if (raw.isNotEmpty) {
        final restored = raw.map<ChatMessage>((m) => ChatMessage(
          content: m['content'] as String,
          isAi: m['sender_type'] != 'human',
          time: DateTime.tryParse(m['created_at']?.toString() ?? '') ?? DateTime.now(),
        )).toList();
        if (mounted) setState(() => _messages = restored);
      } else {
        for (final m in _messages) {
          _persistMessage(m.content, m.isAi ? 'ai' : 'human', (m.agent ?? AgentType.router).name);
        }
      }
    } catch (_) {}
  }

  void _persistMessage(String content, String senderType, String agentType) {
    if (_isGeneralAssistant) return;
    ApiService.instance.logChatMessage(widget.projectId, content, senderType, agentType).catchError((_) {});
  }

  List<ChatMessage> _buildAssistantIntro() {
    return [
      ChatMessage(
        content: "Bonjour 👋 Je suis l'Assistant IA RawBank, propulsé par Llama 3.3. Je peux analyser votre projet, évaluer sa viabilité, vérifier la conformité et vous guider dans votre demande de financement.\n\nPosez-moi votre question !",
        isAi: true,
        time: DateTime.now(),
        agent: AgentType.router,
        quickReplies: [
          QuickReply('Voir mes comptes', 'goto_comptes'),
          QuickReply('Suivre un projet', 'agent_router'),
          QuickReply('Documents KYC requis', 'conformite_docs'),
        ],
      ),
    ];
  }

  List<ChatMessage> _buildProjectIntro() {
    return [
      ChatMessage(
        content: "Bonjour ! Je suis le Routeur IA de RawBank. J'ai pris en charge votre dossier *$_projectTitle*. Je vais l'analyser et l'orienter vers les agents spécialisés.",
        isAi: true,
        time: DateTime.now().subtract(const Duration(minutes: 8)),
        agent: AgentType.router,
        quickReplies: [
          QuickReply('Quels documents me manquent ?', 'docs_manquants'),
          QuickReply('Quel est le statut ?', 'statut'),
          QuickReply('Parler à un agent spécifique', 'changer_agent'),
        ],
      ),
      ChatMessage(
        content: "Quels documents me manquent pour mon dossier ?",
        isAi: false,
        time: DateTime.now().subtract(const Duration(minutes: 6)),
      ),
      ChatMessage(
        content: "J'ai vérifié votre dossier. Voici le statut des documents :\n\n✅ Carte d'identité — Reçu\n✅ Registre de commerce — Reçu\n✅ Relevés bancaires (6 mois) — Reçu\n⚠️ Business Plan complet — Manquant\n⚠️ Plan de trésorerie 3 ans — Manquant\n⚠️ Facture pro forma — Manquant\n\nVous pouvez les télécharger directement depuis la section *KYC* de l'application.",
        isAi: true,
        time: DateTime.now().subtract(const Duration(minutes: 5)),
        agent: AgentType.router,
        quickReplies: [
          QuickReply('Aller au KYC', 'goto_kyc'),
          QuickReply('Parler à RSE', 'agent_rse'),
        ],
      ),
    ];
  }

  void _selectAgent(AgentType? agent) {
    setState(() {
      _activeAgent = agent;
      _showAgentPanel = false;
    });
    _addAgentWelcome(agent);
  }

  void _addAgentWelcome(AgentType? agent) {
    if (agent == null) return;
    Map<String, dynamic> response;
    switch (agent) {
      case AgentType.rse:
        response = {
          'content': "Je suis l'agent RSE (Responsabilité Sociétale). J'évalue l'impact social et environnemental de votre projet.\n\nPour *$_projectTitle*:\n✅ Création d'emplois: 12 postes directs\n✅ Approvisionnement local: 70%\n⚠️ Gestion des déchets: à améliorer\n⚠️ Empreinte carbone: non mesurée\n\nScore RSE actuel: *72/100*",
          'quickReplies': [
            QuickReply('Comment améliorer ?', 'ameliorer_rse'),
            QuickReply('Impact social', 'impact_social'),
          ],
        };
        break;
      case AgentType.compliance:
        response = _getComplianceResponse();
        break;
      case AgentType.commercial:
        response = {
          'content': "Je suis l'agent Commercial. J'analyse la viabilité de votre business model.\n\nPour *$_projectTitle*:\n📊 Marché ciblé: 45 000 ménages\n📊 Concurrents: 8 identifiés\n📊 CA estimé année 1: \$48 000\n📊 Marge brute: 32%\n\nViabilité commerciale: *Modérée*",
          'quickReplies': [
            QuickReply('Voir concurrents', 'concurrents'),
            QuickReply('Projections', 'projections'),
          ],
        };
        break;
      case AgentType.accounting:
        response = {
          'content': "Je suis l'agent Comptabilité. J'analyse la structure financière de votre dossier.\n\nPour *$_projectTitle*:\n💰 Montant demandé: \$25 000\n💰 Taux estimé: 14.5%\n💰 Durée: 36 mois\n💰 Mensualité: ~\$865\n💰 DSCR: 1.35 (satisfaisant)\n\nCapacité de remboursement: *Validée*",
          'quickReplies': [
            QuickReply('Tableau amortissement', 'amortissement'),
            QuickReply('Améliorer le score', 'ameliorer_fin'),
          ],
        };
        break;
      case AgentType.router:
        return;
    }
    setState(() {
      _messages.add(ChatMessage(
        content: response['content'],
        isAi: true,
        time: DateTime.now(),
        agent: agent,
        quickReplies: (response['quickReplies'] as List).cast<QuickReply>(),
      ));
    });
    _scrollToBottom();
  }

  void _sendMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    _messageController.clear();
    setState(() {
      _messages.add(ChatMessage(content: trimmed, isAi: false, time: DateTime.now()));
      _isAiTyping = true;
      _typingAgent = _activeAgent;
    });
    _persistMessage(trimmed, 'human', (_activeAgent ?? AgentType.router).name);
    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      final response = _processQuickReply(trimmed);
      setState(() {
        _isAiTyping = false;
        _messages.add(ChatMessage(
          content: response['content'],
          isAi: true,
          time: DateTime.now(),
          agent: _activeAgent ?? AgentType.router,
          quickReplies: response['quickReplies'] != null
              ? (response['quickReplies'] as List).cast<QuickReply>()
              : null,
        ));
      });
      _persistMessage(response['content'], 'ai', (_activeAgent ?? AgentType.router).name);
      _scrollToBottom();
    });
  }

  Map<String, dynamic> _processQuickReply(String text) {
    if (text.toLowerCase().contains('comptes') || text == 'goto_comptes') {
      return {
        'content': 'Pour accéder à vos comptes, appuyez sur "Comptes" dans le menu en bas de l\'écran. Vous y verrez votre solde IllicoCash, vos comptes bancaires et l\'historique des transactions.',
        'quickReplies': null,
      };
    }
    if (text.toLowerCase().contains('kyc') || text == 'goto_kyc') {
      return {
        'content': 'Pour télécharger vos documents KYC, rendez-vous dans la section "KYC" accessible depuis votre profil. Vous pourrez y soumettre votre pièce d\'identité, justificatif de domicile et selfie biométrique.',
        'quickReplies': null,
      };
    }
    if (text == 'agent_rse' || text.toLowerCase().contains('parler à rse') || text.toLowerCase().contains('parler a rse')) {
      _activeAgent = AgentType.rse;
      return {
        'content': "Je suis l'agent RSE (Responsabilité Sociétale). J'évalue l'impact social et environnemental de votre projet.\n\nPour *$_projectTitle*:\n✅ Création d'emplois: 12 postes directs\n✅ Approvisionnement local: 70%\n⚠️ Gestion des déchets: à améliorer\n⚠️ Empreinte carbone: non mesurée\n\nScore RSE actuel: *72/100*",
        'quickReplies': [
          QuickReply('Comment améliorer ?', 'ameliorer_rse'),
          QuickReply('Impact social', 'impact_social'),
        ],
      };
    }
    if (text == 'agent_commercial' || text.toLowerCase().contains('parler à commercial') || text.toLowerCase().contains('parler a commercial')) {
      _activeAgent = AgentType.commercial;
      return {
        'content': "Je suis l'agent Commercial. J'analyse la viabilité de votre business model.\n\nPour *$_projectTitle*:\n📊 Marché ciblé: 45 000 ménages\n📊 Concurrents: 8 identifiés\n📊 CA estimé année 1: \$48 000\n📊 Marge brute: 32%\n\nViabilité commerciale: *Modérée*",
        'quickReplies': [
          QuickReply('Voir concurrents', 'concurrents'),
          QuickReply('Projections', 'projections'),
        ],
      };
    }

    switch (text) {
      case 'docs_manquants':
      case 'Quels documents me manquent ?':
      case 'Quels documents me manquent':
        return {
          'content': "J'ai vérifié votre dossier. Voici le statut des documents :\n\n✅ Carte d'identité — Reçu\n✅ Registre de commerce — Reçu\n✅ Relevés bancaires (6 mois) — Reçu\n⚠️ Business Plan complet — Manquant\n⚠️ Plan de trésorerie 3 ans — Manquant\n⚠️ Facture pro forma — Manquant\n\nVous pouvez les télécharger directement depuis la section *KYC* de l'application.",
          'quickReplies': [
            QuickReply('Aller au KYC', 'goto_kyc'),
            QuickReply('Parler à RSE', 'agent_rse'),
          ],
        };
      case 'statut':
      case 'Quel est le statut ?':
      case 'Quel est le statut de mon dossier ?':
        return {
          'content': "Statut de votre dossier *$_projectTitle*:\n\n📋 Étape actuelle: Analyse IA\n📊 Score global: 68/100\n⏱️ Délai estimé: 5-7 jours ouvrables\n\nRépartition du score:\n• RSE: 72/100 ✅\n• Conformité: 45/100 ⚠️\n• Commercial: 65/100 ✅\n• Financier: 80/100 ✅\n\nProchaine étape: Revue par un analyste RawBank.",
          'quickReplies': [
            QuickReply('Améliorer conformité', 'conformite_docs'),
            QuickReply('Parler au Routeur', 'agent_router'),
          ],
        };
      case 'ameliorer_rse':
      case 'Comment améliorer mon score RSE ?':
        return {
          'content': "Pour améliorer votre score RSE (actuellement 72/100):\n\n1. *Gestion des déchets* (+10 pts): Mettez en place un système de tri et recyclage\n2. *Empreinte carbone* (+8 pts): Mesurez et publiez votre bilan CO2\n3. *Inclusion numérique* (+5 pts): Formez vos employés au numérique\n4. *Approvisionnement équitable* (+5 pts): Certifiez vos fournisseurs locaux\n\nScore potentiel: *95/100*",
          'quickReplies': [
            QuickReply('Impact social détaillé', 'impact_social'),
            QuickReply('Parler au Routeur', 'agent_router'),
          ],
        };
      case 'impact_social':
      case 'Quel est mon impact social ?':
        return {
          'content': "Impact social de *$_projectTitle*:\n\n👥 Emplois créés: 12 directs + 5 indirects\n👥 Salaires: 15% au-dessus du SMIC local\n👥 Formation: 80% des employés formés\n👥 Diversité: 40% de femmes employées\n\nContribution à l'économie locale: *\$180 000/an*",
          'quickReplies': [
            QuickReply('Comment améliorer ?', 'ameliorer_rse'),
            QuickReply('Parler au Routeur', 'agent_router'),
          ],
        };
      case 'concurrents':
      case 'Analyse de la concurrence':
        return {
          'content': "Analyse concurrentielle pour *$_projectTitle*:\n\n1. *GreenMarket* — Premium, 25% de part de marché\n2. *Bio Congo* — Moyen gamme, 20%\n3. *Fresh & Go* — Économique, 15%\n4. Autres (5 concurrents) — 40%\n\nVotre positionnement: *Bio + local + accessible*\nDifférenciateur: Seul acteur 100% bio à Kinshasa\nAvantage: Marge 32% vs 28% moyenne du marché",
          'quickReplies': [
            QuickReply('Projections de vente', 'projections'),
            QuickReply('Parler au Routeur', 'agent_router'),
          ],
        };
      case 'projections':
      case 'projections_fin':
      case 'Voir les projections de vente':
      case 'Voir les projections financières':
        return {
          'content': "Projections financières (3 ans):\n\n*Année 1:* CA \$48 000 | Résultat \$5 200 | Marge 11%\n*Année 2:* CA \$72 000 | Résultat \$11 500 | Marge 16%\n*Année 3:* CA \$108 000 | Résultat \$21 600 | Marge 20%\n\nBreak-even: Mois 14\nROI sur 3 ans: *145%*",
          'quickReplies': [
            QuickReply('Tableau amortissement', 'amortissement'),
            QuickReply('Parler à Comptabilité', 'agent_commercial'),
          ],
        };
      case 'taux':
      case "Quel est mon taux d'intérêt estimé ?":
        return {
          'content': "Estimation du taux d'intérêt:\n\nBase RawBank PME: 16.5%\nAjustements:\n- Score dossier: -1.5% (bon profil)\n- Apport personnel 25%: -0.5%\n- Garantie hypothécaire: -0.0%\n\n*Taux estimé: 14.5%*\n\nMensualité sur 36 mois pour \$25 000: ~\$865/mois",
          'quickReplies': [
            QuickReply('Tableau amortissement', 'amortissement'),
            QuickReply('Améliorer le taux', 'ameliorer_fin'),
          ],
        };
      case 'viabilite':
      case 'Quelle est ma viabilité commerciale ?':
        return {
          'content': "Analyse de viabilité commerciale:\n\n✅ Marché existant et en croissance\n✅ Modèle économique éprouvé\n✅ Équipe expérimentée\n⚠️ Concurrence croissante\n⚠️ Dépendance aux importations\n\n*Verdict: Viabilité modérée (65/100)*\nRecommandation: Renforcer le marketing local et la diversification fournisseurs.",
          'quickReplies': [
            QuickReply('Voir concurrents', 'concurrents'),
            QuickReply('Projections', 'projections'),
          ],
        };
      case 'conformite_docs':
      case 'Que dois-je fournir pour la conformité ?':
        return _getComplianceDocsResponse();
      case 'conformite_delai':
      case 'Quel est le délai réglementaire ?':
        return {
          'content': "Délais réglementaires:\n\n1. *Validation dossier*: 5-7 jours ouvrables\n2. *Vérification BCC*: 3-5 jours\n3. *Comité de crédit*: 2-3 jours\n4. *Décaissement*: 2-4 jours après accord\n\n*Délai total estimé: 12-19 jours ouvrables*",
          'quickReplies': [
            QuickReply('Que dois-je fournir ?', 'conformite_docs'),
            QuickReply('Parler au Routeur', 'agent_router'),
          ],
        };
      case 'conformite_regulateur':
        final sector = _cachedSector;
        if (sector != null) {
          return {
            'content': "Régulateur de votre secteur:\n\n*${sector.regulator}*\n\n${sector.regulatoryNotes.isNotEmpty ? 'Notes: ${sector.regulatoryNotes.join('\n')}' : 'Aucune note spécifique.'}",
            'quickReplies': [
              QuickReply('Que dois-je fournir ?', 'conformite_docs'),
              QuickReply('Parler au Routeur', 'agent_router'),
            ],
          };
        }
        return {
          'content': "Le régulateur principal est la *Banque Centrale du Congo (BCC)*.\n\nSelon votre secteur d'activité, d'autres régulateurs peuvent s'appliquer (DGI, OCC, etc.).",
          'quickReplies': [
            QuickReply('Que dois-je fournir ?', 'conformite_docs'),
            QuickReply('Parler au Routeur', 'agent_router'),
          ],
        };
      case 'amortissement':
      case "Voir le tableau d'amortissement":
        return {
          'content': "Tableau d'amortissement (extrait):\n\n*Capital: \$25 000 | Taux: 14.5% | 36 mois*\n\nM1: Capital \$565 | Intérêt \$302 | Total \$867\nM6: Capital \$598 | Intérêt \$269 | Total \$867\nM12: Capital \$635 | Intérêt \$232 | Total \$867\nM24: Capital \$713 | Intérêt \$154 | Total \$867\nM36: Capital \$838 | Intérêt \$29 | Total \$867\n\nTotal intérêts payés: *\$6 212*\nCoût total du crédit: *\$31 212*",
          'quickReplies': [
            QuickReply('Améliorer le score', 'ameliorer_fin'),
            QuickReply('Parler au Routeur', 'agent_router'),
          ],
        };
      case 'ameliorer_fin':
      case 'Comment améliorer mon score financier ?':
        return {
          'content': "Pour améliorer votre score financier (actuellement 80/100):\n\n1. *Augmenter l'apport personnel* (+5 pts): Passez de 25% à 30%\n2. *Réduire le montant demandé* (+3 pts): \$22 000 au lieu de \$25 000\n3. *Améliorer le DSCR* (+4 pts): Diversifiez vos revenus\n4. *Garanties supplémentaires* (+3 pts): Ajoutez une caution\n\nScore potentiel: *95/100*\nTaux pourrait descendre à *12.5%*",
          'quickReplies': [
            QuickReply('Voir le taux estimé', 'taux'),
            QuickReply('Projections', 'projections'),
          ],
        };
      case 'upload':
      case 'Je veux télécharger mes documents':
        return {
          'content': 'Pour télécharger vos documents, allez dans la section *KYC* de l\'application. Vous pourrez y soumettre:\n\n1. Pièce d\'identité\n2. Justificatif de domicile\n3. Selfie biométrique\n\nLes documents sont chiffrés et stockés de manière sécurisée.',
          'quickReplies': [
            QuickReply('Aller au KYC', 'goto_kyc'),
            QuickReply('Parler au Routeur', 'agent_router'),
          ],
        };
      case 'changer_agent':
      case 'Je veux parler à un agent spécifique':
        setState(() => _showAgentPanel = true);
        return {
          'content': 'Choisissez l\'agent avec lequel vous souhaitez parler. Touchez l\'icône de changement en haut de l\'écran pour basculer entre les agents.',
          'quickReplies': [
            QuickReply('Parler à RSE', 'agent_rse'),
            QuickReply('Parler à Commercial', 'agent_commercial'),
          ],
        };
      default:
        return _tryAiResponse(text);
    }
  }

  Map<String, dynamic> _tryAiResponse(String userText) {
    final lower = userText.toLowerCase();
    if (lower.contains('rse') || lower.contains('social') || lower.contains('environnement') || lower.contains('vert')) {
      _activeAgent = AgentType.rse;
      return {
        'content': "Votre question concerne la RSE. Je suis l'agent RSE.\n\nPour *$_projectTitle*, votre score RSE est de *72/100*.\n\nPoints forts: création d'emplois, approvisionnement local.\nPoints à améliorer: gestion des déchets, empreinte carbone.\n\nQue souhaitez-vous savoir exactement ?",
        'quickReplies': [
          QuickReply('Comment améliorer ?', 'ameliorer_rse'),
          QuickReply('Impact social', 'impact_social'),
        ],
      };
    }
    if (lower.contains('conform') || lower.contains('document') || lower.contains('réglement') || lower.contains('reglement') || lower.contains('bcc')) {
      _activeAgent = AgentType.compliance;
      return _getComplianceResponse();
    }
    if (lower.contains('concurrence') || lower.contains('marché') || lower.contains('marche') || lower.contains('vente') || lower.contains('client')) {
      _activeAgent = AgentType.commercial;
      return {
        'content': "Votre question est d'ordre commercial. Je suis l'agent Commercial.\n\nPour *$_projectTitle*:\n📊 Marché ciblé: 45 000 ménages\n📊 CA estimé année 1: \$48 000\n📊 Marge brute: 32%\n\nQue voulez-vous analyser ?",
        'quickReplies': [
          QuickReply('Voir concurrents', 'concurrents'),
          QuickReply('Projections', 'projections'),
        ],
      };
    }
    if (lower.contains('taux') || lower.contains('rembours') || lower.contains('financ') || lower.contains('argent') || lower.contains('amort')) {
      _activeAgent = AgentType.accounting;
      return {
        'content': "Votre question est d'ordre financier. Je suis l'agent Comptabilité.\n\nPour *$_projectTitle*:\n💰 Montant demandé: \$25 000\n💰 Taux estimé: 14.5%\n💰 Mensualité: ~\$865/mois\n💰 DSCR: 1.35\n\nQue souhaitez-vous calculer ?",
        'quickReplies': [
          QuickReply('Tableau amortissement', 'amortissement'),
          QuickReply('Améliorer le score', 'ameliorer_fin'),
        ],
      };
    }
    _activeAgent = null;
    return {
      'content': "J'ai bien reçu votre message. En tant que Routeur IA, je vais orienter votre demande vers le bon agent.\n\nD'après votre question, je recommande de consulter:\n1. *RSE* pour l'impact social\n2. *Conformité* pour les documents\n3. *Commercial* pour la viabilité\n4. *Comptabilité* pour les finances\n\nQuel aspect vous intéresse le plus ?",
      'quickReplies': [
        QuickReply('Voir le statut', 'statut'),
        QuickReply('Documents requis', 'conformite_docs'),
        QuickReply('Parler à un agent', 'changer_agent'),
      ],
    };
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _activeAgent?.label ?? 'Assistant IA',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            Text(
              _activeAgent?.description ?? 'Propulsé par Llama 3.3',
              style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.7)),
            ),
          ],
        ),
        automaticallyImplyLeading: widget.showBackButton,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        actions: [
          GestureDetector(
            onTap: () => setState(() => _showAgentPanel = !_showAgentPanel),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.swap_horiz, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: _showAgentPanel ? 140 : 0,
            color: Colors.white,
            child: _showAgentPanel
                ? ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    children: [
                      _AgentOption(icon: Icons.hub, label: 'Routeur', desc: 'Synthèse & coordination', color: AppColors.aiRouter, selected: _activeAgent == null, onTap: () => _selectAgent(null)),
                      _AgentOption(icon: Icons.eco, label: 'RSE', desc: 'Impact social & environnemental', color: AppColors.aiRSE, selected: _activeAgent == AgentType.rse, onTap: () => _selectAgent(AgentType.rse)),
                      _AgentOption(icon: Icons.gavel, label: 'Conformité', desc: 'Conformité réglementaire', color: AppColors.aiCompliance, selected: _activeAgent == AgentType.compliance, onTap: () => _selectAgent(AgentType.compliance)),
                      _AgentOption(icon: Icons.trending_up, label: 'Commercial', desc: 'Viabilité commerciale', color: AppColors.aiCommercial, selected: _activeAgent == AgentType.commercial, onTap: () => _selectAgent(AgentType.commercial)),
                      _AgentOption(icon: Icons.calculate, label: 'Comptabilité', desc: 'Analyse financière', color: AppColors.aiAccounting, selected: _activeAgent == AgentType.accounting, onTap: () => _selectAgent(AgentType.accounting)),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: AgentType.values.map((a) {
                  final active = _activeAgent == a || (_activeAgent == null && a == AgentType.router);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _AgentChip(label: a.label, color: a.color, isActive: active, onTap: () => _selectAgent(a == AgentType.router ? null : a)),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isAiTyping ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == _messages.length && _isAiTyping) {
                  return _TypingIndicator(agent: _typingAgent);
                }
                final msg = _messages[i];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MessageBubble(message: msg),
                    if (msg.quickReplies != null && msg.isAi) ...[
                      const SizedBox(height: 8),
                      _QuickReplies(
                        replies: msg.quickReplies!,
                        onTap: (reply) => _sendMessage(reply.value == 'changer_agent'
                            ? 'Je veux parler à un agent spécifique'
                            : reply.value == 'agent_rse'
                                ? 'Parler à RSE'
                                : reply.value == 'agent_commercial'
                                    ? 'Parler à Commercial'
                                    : _quickReplyToText(reply.value)),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ],
                );
              },
            ),
          ),
          // Input with keyboard handling
          AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              color: Colors.white,
              child: SafeArea(
                top: false,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.attach_file, color: AppColors.grey500),
                      onPressed: () {},
                    ),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        focusNode: _inputFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Posez votre question...',
                          hintStyle: const TextStyle(color: AppColors.grey500, fontSize: 14),
                          filled: true,
                          fillColor: AppColors.grey100,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        maxLines: 4,
                        minLines: 1,
                        textCapitalization: TextCapitalization.sentences,
                        onSubmitted: _sendMessage,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _sendMessage(_messageController.text),
                      child: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: _activeAgent?.color ?? AppColors.primary, shape: BoxShape.circle),
                        child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _quickReplyToText(String value) {
    switch (value) {
      case 'docs_manquants': return 'Quels documents me manquent ?';
      case 'statut': return 'Quel est le statut de mon dossier ?';
      case 'upload': return 'Je veux télécharger mes documents';
      case 'impact_social': return 'Quel est mon impact social ?';
      case 'ameliorer_rse': return 'Comment améliorer mon score RSE ?';
      case 'concurrents': return 'Analyse de la concurrence';
      case 'projections': return 'Voir les projections de vente';
      case 'taux': return "Quel est mon taux d'intérêt estimé ?";
      case 'projections_fin': return 'Voir les projections financières';
      case 'viabilite': return 'Quelle est ma viabilité commerciale ?';
      case 'conformite_docs': return 'Que dois-je fournir pour la conformité ?';
      case 'conformite_delai': return 'Quel est le délai réglementaire ?';
      case 'amortissement': return "Voir le tableau d'amortissement";
      case 'ameliorer_fin': return 'Comment améliorer mon score financier ?';
      case 'goto_comptes': return 'Je veux voir mes comptes';
      default: return value;
    }
  }
}

// ── Message Bubble ──
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isAi = message.isAi;
    final agentColor = message.agent?.color ?? AppColors.primary;
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.82),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isAi ? Colors.white : agentColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isAi ? const Radius.circular(4) : const Radius.circular(16),
            bottomRight: isAi ? const Radius.circular(16) : const Radius.circular(4),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isAi && message.agent != null) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(message.agent!.icon, size: 14, color: agentColor),
                  const SizedBox(width: 4),
                  Text(message.agent!.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: agentColor)),
                ],
              ),
              const SizedBox(height: 8),
            ],
            _formatContent(message.content, isAi, agentColor),
          ],
        ),
      ),
    );
  }

  Widget _formatContent(String content, bool isAi, Color agentColor) {
    final parts = <TextSpan>[];
    final regex = RegExp(r'\*(.+?)\*');
    int lastEnd = 0;
    for (final match in regex.allMatches(content)) {
      if (match.start > lastEnd) {
        parts.add(TextSpan(text: content.substring(lastEnd, match.start), style: TextStyle(fontSize: 14, height: 1.5, color: isAi ? AppColors.textPrimary : Colors.white)));
      }
      parts.add(TextSpan(text: match.group(1), style: TextStyle(fontSize: 14, height: 1.5, fontWeight: FontWeight.w700, color: isAi ? agentColor : Colors.white)));
      lastEnd = match.end;
    }
    if (lastEnd < content.length) {
      parts.add(TextSpan(text: content.substring(lastEnd), style: TextStyle(fontSize: 14, height: 1.5, color: isAi ? AppColors.textPrimary : Colors.white)));
    }
    return RichText(text: TextSpan(children: parts));
  }
}

// ── Typing Indicator ──
class _TypingIndicator extends StatelessWidget {
  final AgentType? agent;
  const _TypingIndicator({this.agent});

  @override
  Widget build(BuildContext context) {
    final color = agent?.color ?? AppColors.primary;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (agent != null) ...[Icon(agent!.icon, size: 14, color: color), const SizedBox(width: 8)],
            _Dot(color: color), const SizedBox(width: 4),
            _Dot(color: color), const SizedBox(width: 4),
            _Dot(color: color),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot({required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
  }
}

// ── Quick Replies ──
class _QuickReplies extends StatelessWidget {
  final List<QuickReply> replies;
  final ValueChanged<QuickReply> onTap;
  const _QuickReplies({required this.replies, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: replies.map((reply) {
        return GestureDetector(
          onTap: () => onTap(reply),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
            ),
            child: Text(reply.label, style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        );
      }).toList(),
    );
  }
}

// ── Agent Option ──
class _AgentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _AgentOption({required this.icon, required this.label, required this.desc, required this.color, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: selected ? Border.all(color: color.withValues(alpha: 0.3)) : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: selected ? color : AppColors.textPrimary)),
                Text(desc, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
            const Spacer(),
            if (selected) Icon(Icons.check_circle, size: 18, color: color),
          ],
        ),
      ),
    );
  }
}

// ── Agent Chip ──
class _AgentChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;
  const _AgentChip({required this.label, required this.color, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(color: isActive ? color : AppColors.grey100, borderRadius: BorderRadius.circular(20)),
        child: Text(label, style: TextStyle(color: isActive ? Colors.white : AppColors.grey700, fontSize: 12, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500)),
      ),
    );
  }
}
