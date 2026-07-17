import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/business_sector.dart';
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

  Future<void> _loadSectorData() async {
    _cachedSector = await _loadSector();
    if (mounted) setState(() {});
  }


  // ── Sector-aware compliance methods ──

  Future<BusinessSector?> _loadSector() async {
    final prefs = await SharedPreferences.getInstance();
    final sectorId = prefs.getString('business_sector');
    if (sectorId != null && sectorId != 'autre') {
      return BusinessSectors.findById(sectorId);
    }
    final sectorName = prefs.getString('business_sector_name');
    if (sectorName != null) {
      // Try to find by name for "autre" sectors
      try {
        return BusinessSectors.sectors.firstWhere((s) => s.name == sectorName);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Map<String, dynamic> _getComplianceResponse() {
    // Try to load sector - for now use synchronous approach with cached value
    // Since we can't use async in _getWelcome, we'll use a fallback
    final sector = _cachedSector;
    if (sector != null) {
      final docsCount = sector.requiredDocuments.length;
      final commonCount = BusinessSectors.commonDocuments.length;
      final sectorDocsCount = docsCount - commonCount;
      return {
        'content': "Je suis l'agent Conformité. Je vérifie votre dossier selon les exigences de *${sector.regulator}*.\n\nSecteur détecté: *${sector.name}*\n\nVérifications en cours:\n✅ Registre de commerce — à valider\n✅ Identification du promoteur\n⚠️ ${sectorDocsCount} document(s) spécifiques au secteur — à fournir\n\nRégulateur: ${sector.regulator}\nNiveau de conformité actuel: *45%*",
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
        ? '\n\nDocuments recommandés (optionnels):\n${sector.optionalDocuments.map((d) => '• $d').join('\n')}'
        : '';
      final notesList = sector.regulatoryNotes.isNotEmpty
        ? '\n\nNotes réglementaires:\n${sector.regulatoryNotes.map((n) => '⚠️ $n').join('\n')}'
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

  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isAiTyping = false;
  AgentType? _typingAgent;
  AgentType? _activeAgent; // null = router
  bool _showAgentPanel = false;

  bool get _isGeneralAssistant => widget.projectId == 'assistant';
  final String _projectTitle = 'Épicerie Bio Kinshasa';

  late List<ChatMessage> _messages;

  @override
  void initState() {
    _loadSectorData();
    super.initState();
    _messages = _isGeneralAssistant ? _buildAssistantIntro() : _buildProjectIntro();
  }

  List<ChatMessage> _buildAssistantIntro() {
    return [
      ChatMessage(
        content: "Bonjour 👋 Je suis l'Assistant RawBank. Je peux répondre à vos questions sur vos comptes, vos virements, vos projets de financement ou votre dossier KYC. Que puis-je faire pour vous ?",
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
        content: "J'ai vérifié votre dossier. Voici le statut des documents :\n\n✅ Carte d'identité — Reçu\n✅ Registre de commerce — Reçu\n✅ Relevés bancaires (6 mois) — Reçu\n⚠️ Business Plan complet — Manquant\n⚠️ Plan de trésorerie 3 ans — Manquant\n⚠️ Facture pro forma — Manquant\n\nVous pouvez les télécharger directement depuis l'onglet *Projets*.",
        isAi: true,
        time: DateTime.now().subtract(const Duration(minutes: 5)),
        agent: AgentType.router,
        quickReplies: [
          QuickReply('Quel est le statut ?', 'statut'),
          QuickReply('Parler à RSE', 'agent_rse'),
          QuickReply('Parler à Commercial', 'agent_commercial'),
        ],
      ),
    ];
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) async {
    text = text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(content: text, isAi: false, time: DateTime.now()));
      _isAiTyping = true;
      _typingAgent = _activeAgent ?? AgentType.router;
    });
    _messageController.clear();
    _scrollToBottom();

    // Determine which agent responds
    final respondingAgent = _activeAgent ?? _determineAgent(text);

    // Simulate thinking delay
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final response = _generateResponse(text, respondingAgent);

    setState(() {
      _isAiTyping = false;
      _typingAgent = null;
      _messages.add(ChatMessage(
        content: response['content']!,
        isAi: true,
        time: DateTime.now(),
        agent: respondingAgent,
        quickReplies: response['quickReplies'],
      ));
    });
    _scrollToBottom();
  }

  AgentType _determineAgent(String message) {
    final msg = message.toLowerCase();
    if (msg.contains('document') || msg.contains('statut') || msg.contains('dossier')) {
      return AgentType.router;
    }
    if (msg.contains('rse') || msg.contains('social') || msg.contains('environnement') || msg.contains('impact')) {
      return AgentType.rse;
    }
    if (msg.contains('conform') || msg.contains('réglement') || msg.contains('legal') || msg.contains('loi')) {
      return AgentType.compliance;
    }
    if (msg.contains('marché') || msg.contains('commercial') || msg.contains('vente') || msg.contains('client')) {
      return AgentType.commercial;
    }
    if (msg.contains('financ') || msg.contains('comptab') || msg.contains('taux') || msg.contains('remboursement') || msg.contains('cash')) {
      return AgentType.accounting;
    }
    return AgentType.router;
  }

  Map<String, dynamic> _generateResponse(String userMessage, AgentType agent) {
    final msg = userMessage.toLowerCase();

    switch (agent) {
      case AgentType.router:
        if (msg.contains('docs_manquants') || msg.contains('document') || msg.contains('manquent')) {
          return {
            'content': "Pour votre dossier *$_projectTitle*, il manque encore:\n\n1. Business Plan complet (3 ans)\n2. Plan de trésorerie prévisionnel\n3. Facture pro forma des équipements\n\nUne fois ces documents reçus, je pourrai lancer l'analyse complète par les 4 agents spécialisés.",
            'quickReplies': [
              QuickReply('Télécharger maintenant', 'upload'),
              QuickReply('Parler à Commercial', 'agent_commercial'),
            ],
          };
        }
        if (msg.contains('statut')) {
          return {
            'content': "Statut du dossier:\n\n📊 Étape 2/5 — Analyse IA en cours\n\n• Routeur: ✅ Terminé\n• RSE: 🔄 En cours\n• Conformité: ⏳ En attente\n• Commercial: ⏳ En attente\n• Comptabilité: ⏳ En attente\n\nScore partiel: *72/100*\nEstimation: 2-3 jours ouvrables restants.",
            'quickReplies': [
              QuickReply('Voir détail RSE', 'agent_rse'),
              QuickReply('Voir détail Commercial', 'agent_commercial'),
            ],
          };
        }
        if (_isGeneralAssistant && (msg.contains('compte') || msg.contains('solde'))) {
          return {
            'content': "Vous pouvez consulter tous vos comptes RawBank (IllicoCash, Courant, Épargne...) depuis l'onglet *Comptes* en bas de l'écran. Vous pouvez aussi y ouvrir un nouveau compte en un clic.",
            'quickReplies': [
              QuickReply('Documents KYC requis', 'conformite_docs'),
              QuickReply('Suivre un projet', 'agent_router'),
            ],
          };
        }
        return {
          'content': _isGeneralAssistant
              ? "J'ai bien reçu votre message. Je peux vous aider sur vos comptes, vos transferts, vos projets de financement ou vos documents KYC. Que souhaitez-vous savoir ?"
              : "J'ai bien reçu votre message. En tant que Routeur, j'analyse votre demande et l'oriente vers l'agent le plus pertinent.\n\nVous pouvez aussi parler directement à un agent spécialisé en le sélectionnant en haut de l'écran.",
          'quickReplies': [
            QuickReply('Statut du dossier', 'statut'),
            QuickReply('Documents manquants', 'docs_manquants'),
          ],
        };

      case AgentType.rse:
        if (msg.contains('impact') || msg.contains('social')) {
          return {
            'content': "Analyse RSE de votre projet:\n\n🌱 Impact social: Positif\n- Création de 8 emplois locaux estimés\n- Accessibilité produits bio à prix abordables\n\n🌍 Impact environnemental: Modéré\n- Réduction emballages plastiques recommandée\n- Sourcing local favorable\n\n📈 Score RSE: *78/100*\n\nRecommandation: Ajouter un plan de gestion des déchets pour améliorer le score.",
            'quickReplies': [
              QuickReply('Comment améliorer le score ?', 'ameliorer_rse'),
              QuickReply('Voir rapport complet', 'rapport_rse'),
            ],
          };
        }
        return {
          'content': "Je suis l'agent RSE. J'évalue l'impact social et environnemental de votre projet.\n\nPour *$_projectTitle*, mon analyse est en cours. Vous pouvez me demander:\n— Quel est mon impact social ?\n— Quelles recommandations environnementales ?\n— Comment améliorer mon score RSE ?",
          'quickReplies': [
            QuickReply('Mon impact social', 'impact_social'),
            QuickReply('Améliorer mon score', 'ameliorer_rse'),
          ],
        };

      case AgentType.compliance:
        return _getComplianceResponse();

      case AgentType.commercial:
        if (msg.contains('marché') || msg.contains('viabilit')) {
          return {
            'content': "Analyse commerciale:\n\n🏪 Marché cible: Gombe, Kinshasa — Zone à fort potentiel\n👥 Clients estimés: 150-200/mois (justifié)\n💰 Panier moyen: \$15-25 (cohérent)\n⚠️ Concurrence: 4 épiceries similaires dans 500m\n\nAvantage différenciant: Produits bio, sourcing local\n\nScore commercial: *81/100*\n\nRecommandation: Mettre en avant l'aspect *bio/local* dans votre communication.",
            'quickReplies': [
              QuickReply('Analyse concurrents', 'concurrents'),
              QuickReply('Voir projections', 'projections'),
            ],
          };
        }
        return {
          'content': "Je suis l'agent Commercial. J'évalue la viabilité commerciale de votre projet.\n\nPour *$_projectTitle*:\n— Analyse du marché: ✅ Terminée\n— Étude concurrentielle: 🔄 En cours\n— Projections de vente: ⏳ En attente\n\nDemandez-moi: *Quelle est ma viabilité commerciale ?*",
          'quickReplies': [
            QuickReply('Viabilité commerciale', 'viabilite'),
            QuickReply('Analyse concurrents', 'concurrents'),
          ],
        };

      case AgentType.accounting:
        if (msg.contains('taux') || msg.contains('remboursement') || msg.contains('cash')) {
          return {
            'content': "Analyse financière:\n\n💵 Montant demandé: \$15,000\n📊 Taux d'intérêt estimé: *8.5%* (basé sur le profil)\n📅 Durée: 24 mois\n💸 Mensualité estimée: ~\$682\n\nRatios clés:\n— DSCR: 1.8 (acceptable, minimum 1.2)\n— ROI projeté: 23% sur 2 ans\n— Point mort: 14 mois\n\nScore financier: *74/100*\n⚠️ Recommandation: Renforcer le fonds de roulement.",
            'quickReplies': [
              QuickReply('Voir le tableau d\'amortissement', 'amortissement'),
              QuickReply('Comment améliorer le score ?', 'ameliorer_fin'),
            ],
          };
        }
        return {
          'content': "Je suis l'agent Comptabilité. J'analyse la viabilité financière de votre projet.\n\nPour *$_projectTitle*:\n— Analyse des ratios: ✅ Terminée\n— Projections de trésorerie: 🔄 En cours\n— Plan de remboursement: ⏳ En attente\n\nDemandez-moi: *Quel est mon taux d'intérêt ?*",
          'quickReplies': [
            QuickReply('Taux d\'intérêt estimé', 'taux'),
            QuickReply('Projections financières', 'projections_fin'),
          ],
        };
    }
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

  void _selectAgent(AgentType? agent) {
    setState(() {
      _activeAgent = agent;
      _showAgentPanel = false;
      if (agent != null) {
        final agentName = agent.label;
        _messages.add(ChatMessage(
          content: "Vous êtes maintenant connecté à l'agent *$agentName*. Posez votre question et il répondra avec son expertise.",
          isAi: true,
          time: DateTime.now(),
          agent: agent,
        ));
        _scrollToBottom();
      } else {
        _messages.add(ChatMessage(
          content: "Retour au Routeur. Je coordonne l'analyse globale de votre dossier.",
          isAi: true,
          time: DateTime.now(),
          agent: AgentType.router,
        ));
        _scrollToBottom();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: _activeAgent?.color ?? AppColors.primary,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _activeAgent != null
                  ? 'Agent ${_activeAgent!.label}'
                  : (_isGeneralAssistant ? 'Assistant RawBank' : 'Routeur IA'),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            Text(
              _activeAgent?.description ?? (_isGeneralAssistant ? 'Toujours disponible' : 'Synthèse & coordination'),
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        automaticallyImplyLeading: widget.showBackButton,
        leading: widget.showBackButton
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
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
          // Agent selector panel (expandable)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: _showAgentPanel ? 120 : 0,
            color: Colors.white,
            child: _showAgentPanel
                ? ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    children: [
                      _AgentOption(
                        icon: Icons.hub, label: 'Routeur', desc: 'Synthèse & coordination',
                        color: AppColors.aiRouter, selected: _activeAgent == null,
                        onTap: () => _selectAgent(null),
                      ),
                      _AgentOption(
                        icon: Icons.eco, label: 'RSE', desc: 'Impact social & environnemental',
                        color: AppColors.aiRSE, selected: _activeAgent == AgentType.rse,
                        onTap: () => _selectAgent(AgentType.rse),
                      ),
                      _AgentOption(
                        icon: Icons.gavel, label: 'Conformité', desc: 'Conformité réglementaire',
                        color: AppColors.aiCompliance, selected: _activeAgent == AgentType.compliance,
                        onTap: () => _selectAgent(AgentType.compliance),
                      ),
                      _AgentOption(
                        icon: Icons.trending_up, label: 'Commercial', desc: 'Viabilité commerciale',
                        color: AppColors.aiCommercial, selected: _activeAgent == AgentType.commercial,
                        onTap: () => _selectAgent(AgentType.commercial),
                      ),
                      _AgentOption(
                        icon: Icons.calculate, label: 'Comptabilité', desc: 'Analyse financière',
                        color: AppColors.aiAccounting, selected: _activeAgent == AgentType.accounting,
                        onTap: () => _selectAgent(AgentType.accounting),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),

          // Active agent bar
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
                    child: _AgentChip(
                      label: a.label, color: a.color, isActive: active,
                      onTap: () => _selectAgent(a == AgentType.router ? null : a),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1),

          // Messages
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

          // Input
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
            color: Colors.white,
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: AppColors.grey500),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Posez votre question...',
                        hintStyle: const TextStyle(color: AppColors.grey500, fontSize: 14),
                        filled: true,
                        fillColor: AppColors.grey100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
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
                      decoration: BoxDecoration(
                        color: _activeAgent?.color ?? AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
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
      case 'taux': return 'Quel est mon taux d\'intérêt estimé ?';
      case 'projections_fin': return 'Voir les projections financières';
      case 'viabilite': return 'Quelle est ma viabilité commerciale ?';
      case 'conformite_docs': return 'Que dois-je fournir pour la conformité ?';
      case 'conformite_delai': return 'Quel est le délai réglementaire ?';
      case 'amortissement': return 'Voir le tableau d\'amortissement';
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
    final agentColor = message.agent?.color ?? AppColors.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: message.isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (message.isAi) ...[
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: agentColor, shape: BoxShape.circle),
              child: Icon(
                message.agent?.icon ?? Icons.smart_toy,
                color: Colors.white, size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                color: message.isAi ? Colors.white : agentColor,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(message.isAi ? 4 : 16),
                  bottomRight: Radius.circular(message.isAi ? 16 : 4),
                ),
                border: message.isAi ? Border.all(color: AppColors.grey200) : null,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6, offset: const Offset(0, 2)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.isAi && message.agent != null) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: agentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        message.agent!.label,
                        style: TextStyle(color: agentColor, fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                  _buildContent(message.content, message.isAi),
                  const SizedBox(height: 4),
                  Text(
                    '${message.time.hour.toString().padLeft(2, '0')}:${message.time.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 10,
                      color: message.isAi ? AppColors.grey500 : Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Simple markdown-like parser for *bold* and newlines
  Widget _buildContent(String text, bool isAi) {
    final lines = text.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        // Handle *bold* segments
        final parts = line.split(RegExp(r'\*(.+?)\*'));
        if (parts.length == 1) {
          return Text(
            line,
            style: TextStyle(
              color: isAi ? AppColors.textPrimary : Colors.white,
              fontSize: 14,
              height: 1.4,
            ),
          );
        }
        return RichText(
          text: TextSpan(
            children: List.generate(parts.length, (i) {
              final isBold = i % 2 == 1;
              return TextSpan(
                text: parts[i],
                style: TextStyle(
                  color: isAi ? AppColors.textPrimary : Colors.white,
                  fontSize: 14,
                  fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
                  height: 1.4,
                ),
              );
            }),
          ),
        );
      }).toList(),
    );
  }
}

// ── Typing Indicator ──
class _TypingIndicator extends StatefulWidget {
  final AgentType? agent;
  const _TypingIndicator({this.agent});

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _a = Tween<double>(begin: 0.3, end: 1).animate(_c);
    _c.repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.agent?.color ?? AppColors.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(widget.agent?.icon ?? Icons.smart_toy, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.grey200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FadeTransition(
                  opacity: _a,
                  child: Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                ),
                const SizedBox(width: 4),
                FadeTransition(
                  opacity: _a,
                  child: Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                ),
                const SizedBox(width: 4),
                FadeTransition(
                  opacity: _a,
                  child: Container(width: 7, height: 7, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Replies ──
class _QuickReplies extends StatelessWidget {
  final List<QuickReply> replies;
  final Function(QuickReply) onTap;
  const _QuickReplies({required this.replies, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: replies.map((r) {
        return ActionChip(
          label: Text(r.label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          onPressed: () => onTap(r),
          backgroundColor: Colors.white,
          side: const BorderSide(color: AppColors.grey300),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          labelStyle: const TextStyle(color: AppColors.primary),
        );
      }).toList(),
    );
  }
}

// ── Agent Chip ──
class _AgentChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isActive;
  final VoidCallback onTap;
  const _AgentChip({required this.label, required this.color, this.isActive = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isActive ? 0.15 : 0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: isActive ? 0.5 : 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive)
              Container(
                width: 6, height: 6,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ── Agent Option (for panel) ──
class _AgentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  const _AgentOption({
    required this.icon, required this.label, required this.desc,
    required this.color, required this.selected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: selected ? color : Colors.transparent, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: selected ? color : AppColors.textPrimary)),
                  Text(desc, style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
            if (selected) Icon(Icons.check_circle, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}
