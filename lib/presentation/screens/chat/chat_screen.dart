import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/api_service.dart';
import '../../../data/models/business_sector.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── AI Agent Model (internal routing, not user-facing) ──
enum AgentType { router, rse, compliance, commercial, accounting }

class AgentInfo {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final List<String> keywords;
  
  const AgentInfo(this.id, this.name, this.icon, this.color, this.keywords);
}

class AgentRouter {
  static const List<AgentInfo> agents = [
    AgentInfo('rse', 'Agent RSE', Icons.eco, AppColors.aiRSE,
      ['rse', 'social', 'environnement', 'vert', 'ecologie', 'impact', 'dechet', 'carbone', 'emploi', 'esg', 'durabl', 'green', 'ecolo', 'inclusion', 'communaut']),
    AgentInfo('conformite', 'Agent Conformité', Icons.gavel, AppColors.aiCompliance,
      ['conform', 'document', 'reglement', 'bcc', 'legal', 'loi', 'statut', 'rccm', 'fiscal', 'impot', 'registre', 'kyc', 'verification', 'delai', 'valide', 'autorisation']),
    AgentInfo('commercial', 'Agent Commercial', Icons.trending_up, AppColors.aiCommercial,
      ['concurren', 'marche', 'vente', 'client', 'commercial', 'business', 'produit', 'prix', 'marge', 'marketing', 'chiffre', 'strategie', 'positionnement']),
    AgentInfo('comptabilite', 'Agent Comptabilité', Icons.calculate, AppColors.aiAccounting,
      ['taux', 'rembours', 'financ', 'argent', 'amort', 'interet', 'mensual', 'dscr', 'credit', 'emprunt', 'capital', 'tresorerie', 'roi', 'rentab', 'cout', 'cash']),
  ];
  
  static const AgentInfo router = AgentInfo('routeur', 'Routeur IA', Icons.hub, AppColors.aiRouter, []);
  
  static AgentInfo route(String message) {
    final lower = message.toLowerCase();
    int bestScore = 0;
    AgentInfo? best;
    
    for (final agent in agents) {
      int score = 0;
      for (final kw in agent.keywords) {
        if (lower.contains(kw)) score++;
      }
      if (score > bestScore) {
        bestScore = score;
        best = agent;
      }
    }
    
    return best ?? router;
  }
}

// ── Chat Message Model ──
class ChatMessage {
  final String content;
  final bool isAi;
  final DateTime time;
  final AgentInfo? agent;

  ChatMessage({required this.content, required this.isAi, required this.time, this.agent});
}

class ChatScreen extends StatefulWidget {
  final String projectId;
  final bool showBackButton;
  final VoidCallback? onBack;
  const ChatScreen({super.key, required this.projectId, this.showBackButton = true, this.onBack});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _inputFocusNode = FocusNode();
  bool _isAiTyping = false;
  AgentInfo? _typingAgent;
  BusinessSector? _cachedSector;

  bool get _isGeneralAssistant => widget.projectId == 'assistant';
  final String _projectTitle = 'Épicerie Bio Kinshasa';

  late List<ChatMessage> _messages;

  @override
  void initState() {
    super.initState();
    _loadSectorData();
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
    final prefs = await SharedPreferences.getInstance();
    final sectorId = prefs.getString('business_sector');
    if (sectorId != null && sectorId != 'autre') {
      _cachedSector = BusinessSectors.findById(sectorId);
    } else {
      final sectorName = prefs.getString('business_sector_name');
      if (sectorName != null) {
        try {
          _cachedSector = BusinessSectors.sectors.firstWhere((s) => s.name == sectorName);
        } catch (_) {}
      }
    }
    if (mounted) setState(() {});
  }

  Future<void> _loadHistory() async {
    try {
      final raw = await ApiService.instance.getMessages(widget.projectId);
      if (raw.isNotEmpty && mounted) {
        setState(() {
          _messages = raw.map<ChatMessage>((m) => ChatMessage(
            content: m['content'] as String,
            isAi: m['sender_type'] != 'human',
            time: DateTime.tryParse(m['created_at']?.toString() ?? '') ?? DateTime.now(),
          )).toList();
        });
      }
    } catch (_) {}
  }

  List<ChatMessage> _buildAssistantIntro() {
    return [
      ChatMessage(
        content: "Bonjour 👋 Je suis l'Agent IA RawBank. J'analyse votre demande et je l'oriente automatiquement vers le bon agent spécialisé.\n\nJe peux vous aider sur :\n1. L'impact social et environnemental (RSE)\n2. La conformité réglementaire\n3. La viabilité commerciale\n4. L'analyse financière\n\nPosez-moi votre question !",
        isAi: true,
        time: DateTime.now(),
        agent: AgentRouter.router,
      ),
    ];
  }

  List<ChatMessage> _buildProjectIntro() {
    return [
      ChatMessage(
        content: "Bonjour ! Je suis le Routeur IA de RawBank. J'ai pris en charge votre dossier *$_projectTitle*.\n\nPosez votre question et je l'oriente automatiquement vers l'agent le plus approprié.",
        isAi: true,
        time: DateTime.now(),
        agent: AgentRouter.router,
      ),
    ];
  }

  void _sendMessage(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    _messageController.clear();
    setState(() {
      _messages.add(ChatMessage(content: trimmed, isAi: false, time: DateTime.now()));
      _isAiTyping = true;
    });
    _scrollToBottom();

    // Auto-route the message
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      
      final agent = AgentRouter.route(trimmed);
      final response = _generateResponse(trimmed, agent);
      
      setState(() {
        _isAiTyping = false;
        _messages.add(ChatMessage(
          content: response,
          isAi: true,
          time: DateTime.now(),
          agent: agent,
        ));
      });
      _scrollToBottom();
    });
  }

  String _generateResponse(String message, AgentInfo agent) {
    final lower = message.toLowerCase();
    
    if (agent.id == 'routeur') {
      if (lower.contains('bonjour') || lower.contains('salut') || lower.contains('hello')) {
        return "Bonjour ! Je suis le Routeur IA de RawBank. J'analyse votre demande en temps réel pour l'orienter vers le bon agent spécialisé.\n\nJe peux vous aider sur :\n1. L'impact social et environnemental (RSE)\n2. La conformité réglementaire\n3. La viabilité commerciale\n4. L'analyse financière\n\nDécrivez-moi votre projet ou posez votre question, je vous oriente automatiquement.";
      }
      if (lower.contains('statut') || lower.contains('état') || lower.contains('etat')) {
        return "Statut de votre dossier :\n\n📋 Étape actuelle : Analyse IA en cours\n📊 Score global : 68/100\n⏱️ Délai estimé : 5-7 jours ouvrables\n\nRépartition du score :\n• RSE : 72/100\n• Conformité : 45/100\n• Commercial : 65/100\n• Financier : 80/100\n\nProchaine étape : Revue par un analyste RawBank. Je vous recommande d'améliorer votre score de conformité qui est le plus faible.";
      }
      return "J'ai analysé votre message. D'après le contenu, votre question concerne ${_detectTopic(lower)}. Je vous oriente vers l'agent le plus approprié.\n\nVous pouvez aussi me demander :\n• Le statut de votre dossier\n• Les documents requis\n• Une analyse de viabilité\n• Une simulation financière\n\nQue souhaitez-vous approfondir ?";
    }
    
    if (agent.id == 'rse') {
      if (lower.contains('améliorer') || lower.contains('ameliorer') || lower.contains('comment')) {
        return "Pour améliorer votre score RSE (actuellement 72/100) :\n\n1. Gestion des déchets (+10 pts) : Mettez en place un système de tri et recyclage\n2. Empreinte carbone (+8 pts) : Mesurez et publiez votre bilan CO2\n3. Inclusion numérique (+5 pts) : Formez vos employés au numérique\n4. Approvisionnement équitable (+5 pts) : Certifiez vos fournisseurs locaux\n\nScore potentiel : 95/100\n\nVoulez-vous que je détaille un point spécifique ?";
      }
      if (lower.contains('impact') || lower.contains('social')) {
        return "Impact social de votre projet :\n\n👥 Emplois créés : 12 directs + 5 indirects\n👥 Salaires : 15% au-dessus du SMIC local\n👥 Formation : 80% des employés formés\n👥 Diversité : 40% de femmes employées\n\nContribution à l'économie locale : 180 000 USD/an\n\nCe score est calculé à partir des données de votre dossier. Pour l'améliorer, concentrez-vous sur la diversité et la formation.";
      }
      return "Je suis l'Agent RSE de RawBank. J'analyse l'impact social et environnemental de votre projet.\n\nVotre score RSE actuel : 72/100\n\nPoints forts : Création d'emplois, approvisionnement local\nPoints à améliorer : Gestion des déchets, empreinte carbone\n\nQue souhaitez-vous savoir ? Je peux détailler votre impact social, votre empreinte environnementale, ou vous suggérer des améliorations.";
    }
    
    if (agent.id == 'conformite') {
      if (lower.contains('document') || lower.contains('fournir') || lower.contains('requis')) {
        final sector = _cachedSector;
        if (sector != null) {
          final docs = sector.requiredDocuments.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n');
          return "Documents requis pour le secteur *${sector.name}* :\n\nRégulateur : ${sector.regulator}\n\n$docs\n\nVotre statut :\n✅ Carte d'identité — Reçu\n✅ Registre de commerce — Reçu\n✅ Relevés bancaires — Reçu\n⚠️ Business Plan — Manquant\n⚠️ Plan de trésorerie — Manquant\n\nDéposez ces documents dans la section KYC.";
        }
        return "Documents réglementaires requis :\n\n1. Statuts de l'entreprise (notariés)\n2. Extrait RCCM\n3. Carte d'identité du gérant\n4. Attestation fiscale (DGI)\n5. Attestation de localisation\n6. Bilan financier (si > 3 ans)\n\nVotre statut :\n✅ Carte d'identité — Reçu\n✅ Registre de commerce — Reçu\n✅ Relevés bancaires — Reçu\n⚠️ Business Plan — Manquant\n⚠️ Plan de trésorerie — Manquant\n\nDéposez ces documents dans la section KYC.";
      }
      if (lower.contains('délai') || lower.contains('delai') || lower.contains('temps')) {
        return "Délais réglementaires estimés :\n\n1. Validation dossier : 5-7 jours ouvrables\n2. Vérification BCC : 3-5 jours\n3. Comité de crédit : 2-3 jours\n4. Décaissement : 2-4 jours après accord\n\nDélai total estimé : 12-19 jours ouvrables\n\nAccélération possible avec un dossier complet dès le dépôt. Actuellement, 3 documents manquent.";
      }
      return "Je suis l'Agent Conformité de RawBank. Je vérifie que votre dossier respecte les exigences réglementaires de la BCC et de RawBank.\n\nNiveau de conformité actuel : 65%\nDocuments reçus : 3 sur 6\nManquants : Business Plan, Plan de trésorerie, Facture pro forma\n\nDemandez-moi la liste des documents requis, les délais, ou votre régulateur spécifique.";
    }
    
    if (agent.id == 'commercial') {
      if (lower.contains('concurren')) {
        return "Analyse concurrentielle pour votre projet :\n\n1. GreenMarket — Premium, 25% de part de marché\n2. Bio Congo — Moyen gamme, 20%\n3. Fresh & Go — Économique, 15%\n4. Autres (5 concurrents) — 40%\n\nVotre positionnement : Bio + local + accessible\nDifférenciateur : Seul acteur 100% bio à Kinshasa\nAvantage : Marge 32% vs 28% moyenne du marché";
      }
      if (lower.contains('projection') || lower.contains('vente') || lower.contains('chiffre')) {
        return "Projections financières (3 ans) :\n\nAnnée 1 : CA 48 000 USD | Résultat 5 200 | Marge 11%\nAnnée 2 : CA 72 000 USD | Résultat 11 500 | Marge 16%\nAnnée 3 : CA 108 000 USD | Résultat 21 600 | Marge 20%\n\nBreak-even : Mois 14\nROI sur 3 ans : 145%";
      }
      return "Je suis l'Agent Commercial de RawBank. J'analyse la viabilité commerciale de votre projet.\n\nMarché ciblé : 45 000 ménages\nConcurrents : 8 identifiés\nCA estimé année 1 : 48 000 USD\nMarge brute : 32%\n\nViabilité : Modérée\n\nDemandez-moi l'analyse concurrentielle ou les projections de vente.";
    }
    
    if (agent.id == 'comptabilite') {
      if (lower.contains('taux') || lower.contains('intérêt') || lower.contains('interet')) {
        return "Estimation du taux d'intérêt :\n\nBase RawBank PME : 16.5%\nAjustements :\n- Score dossier : -1.5% (bon profil)\n- Apport personnel 25% : -0.5%\n\nTaux estimé : 14.5%\nMensualité sur 36 mois pour 25 000 USD : ~865 USD/mois\n\nPour réduire le taux : augmentez votre apport à 30% et ajoutez une caution. Le taux pourrait descendre à 12.5%.";
      }
      if (lower.contains('amort') || lower.contains('rembours') || lower.contains('tableau')) {
        return "Tableau d'amortissement (extrait) :\n\nCapital : 25 000 USD | Taux : 14.5% | 36 mois\n\nM1 : Capital 565 | Intérêt 302 | Total 867\nM12 : Capital 635 | Intérêt 232 | Total 867\nM36 : Capital 838 | Intérêt 29 | Total 867\n\nTotal intérêts : 6 212 USD\nCoût total : 31 212 USD\nDSCR : 1.35 (satisfaisant)";
      }
      if (lower.contains('améliorer') || lower.contains('ameliorer') || lower.contains('score')) {
        return "Pour améliorer votre score financier (actuellement 80/100) :\n\n1. Augmenter l'apport personnel (+5 pts) : 25% → 30%\n2. Réduire le montant demandé (+3 pts) : 22 000 au lieu de 25 000\n3. Améliorer le DSCR (+4 pts) : Diversifier les revenus\n4. Garanties supplémentaires (+3 pts) : Ajouter une caution\n\nScore potentiel : 95/100\nTaux possible : 12.5%";
      }
      return "Je suis l'Agent Comptabilité de RawBank. J'analyse la structure financière de votre dossier.\n\nMontant demandé : 25 000 USD\nTaux estimé : 14.5%\nMensualité : ~865 USD/mois\nDSCR : 1.35 (satisfaisant)\n\nCapacité de remboursement : Validée\n\nDemandez-moi le taux, le tableau d'amortissement, ou comment améliorer votre score.";
    }
    
    return "J'ai bien reçu votre message. Posez votre question et je vous oriente vers le bon agent.";
  }

  String _detectTopic(String lower) {
    if (lower.contains('rse') || lower.contains('social') || lower.contains('environnement')) return "la responsabilité sociétale (RSE)";
    if (lower.contains('conform') || lower.contains('document') || lower.contains('réglement')) return "la conformité réglementaire";
    if (lower.contains('marché') || lower.contains('vente') || lower.contains('client')) return "la viabilité commerciale";
    if (lower.contains('taux') || lower.contains('financ') || lower.contains('rembours')) return "l'analyse financière";
    return "votre projet de financement";
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
    final isEmbedded = !widget.showBackButton;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: isEmbedded ? false : true,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Agent IA', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isAiTyping ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == _messages.length && _isAiTyping) {
                  return _TypingIndicator();
                }
                return _MessageBubble(message: _messages[i]);
              },
            ),
          ),
          // Input with keyboard handling
          AnimatedPadding(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.only(bottom: isEmbedded ? bottomInset : 0),
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
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.grey100,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: TextField(
                          controller: _messageController,
                          focusNode: _inputFocusNode,
                          decoration: const InputDecoration(
                            hintText: 'Posez votre question...',
                            hintStyle: TextStyle(color: AppColors.grey500, fontSize: 14),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          maxLines: 4,
                          minLines: 1,
                          textCapitalization: TextCapitalization.sentences,
                          onSubmitted: _sendMessage,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _sendMessage(_messageController.text),
                      child: Container(
                        width: 44, height: 44,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
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
}

// ── Message Bubble ──
class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isAi = message.isAi;
    final agentColor = message.agent?.color ?? AppColors.primary;
    final screenWidth = MediaQuery.sizeOf(context).width;
    
    return Align(
      alignment: isAi ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: screenWidth * 0.82),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isAi ? Colors.white : AppColors.secondary,
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
                  Text(message.agent!.name, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: agentColor)),
                ],
              ),
              const SizedBox(height: 6),
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
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(), const SizedBox(width: 4), _Dot(), const SizedBox(width: 4), _Dot(),
          ],
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 900), vsync: this)..repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 0.3 + 0.7 * _controller.value,
          child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle)),
        );
      },
    );
  }
}
