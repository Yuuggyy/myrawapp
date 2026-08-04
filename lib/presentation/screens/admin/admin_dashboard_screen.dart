import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/services/ai_service.dart';
import '../../../data/models/admin_models.dart';
import '../../../data/models/project_model.dart';
import '../../../data/models/user_model.dart';
import '../../../core/theme/app_theme.dart';

/// Full Admin Back-Office — complete access to everything:
/// Projects, Users, AI Hub, Requests, Stats
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _currentTab = 0;
  List<NewsItem> _newsItems = [];
  List<RawbankUpdate> _rawbankUpdates = [];
  bool _isLoadingNews = false;

  // ── Mock data for the back-office (will be replaced by real API) ──
  final AdminStats _stats = const AdminStats(
    totalUsers: 1284,
    totalProjects: 347,
    pendingProjects: 89,
    approvedProjects: 182,
    rejectedProjects: 76,
    totalRequests: 156,
    totalFundingRequested: 4850000,
    activeAiAgents: 5,
  );

  final List<AdminRequest> _requests = [
    const AdminRequest(
      id: 'r1',
      type: RequestType.projectSubmission,
      userName: 'Jean Mukendi',
      userEmail: 'jean.mukendi@email.com',
      title: 'Projet agro-industriel - Kasaï',
      description: 'Demande de financement pour une ferme agro-industrielle',
      status: 'pending',
      createdAt: null,
      amount: 75000,
    ).copyWithDate(DateTime.now().subtract(const Duration(hours: 3))),
    const AdminRequest(
      id: 'r2',
      type: RequestType.kycVerification,
      userName: 'Sarah Kabongo',
      userEmail: 'sarah.k@email.com',
      title: 'Vérification KYC Standard',
      description: 'Documents soumis pour vérification niveau standard',
      status: 'processing',
      createdAt: null,
    ).copyWithDate(DateTime.now().subtract(const Duration(days: 1))),
    const AdminRequest(
      id: 'r3',
      type: RequestType.loanRequest,
      userName: 'Pierre Mwamba',
      userEmail: 'p.mwamba@email.com',
      title: 'Prêt commercial - PME',
      description: 'Demande de prêt pour extension commerce',
      status: 'pending',
      createdAt: null,
      amount: 120000,
    ).copyWithDate(DateTime.now().subtract(const Duration(hours: 8))),
    const AdminRequest(
      id: 'r4',
      type: RequestType.partnershipRequest,
      userName: 'Mine de Kolwezi',
      userEmail: 'contact@kolwezi-mining.cd',
      title: 'Partenariat RSE - Programme environnemental',
      description: 'Proposition de partenariat pour programme RSE',
      status: 'resolved',
      createdAt: null,
      amount: 500000,
    ).copyWithDate(DateTime.now().subtract(const Duration(days: 5))),
  ];

  final List<AiAgentStatus> _aiAgents = const [
    AiAgentStatus(
      agentId: 'router',
      name: 'Routeur IA',
      description: 'Synthèse & orientation des demandes',
      isActive: true,
      queriesToday: 47,
      totalQueries: 3284,
      avgScore: 0.82,
      color: Color(0xFFF0B000),
      icon: Icons.hub,
    ),
    AiAgentStatus(
      agentId: 'rse',
      name: 'Agent RSE',
      description: 'Impact social & environnemental',
      isActive: true,
      queriesToday: 23,
      totalQueries: 1820,
      avgScore: 0.76,
      color: Color(0xFF2E7D32),
      icon: Icons.eco,
    ),
    AiAgentStatus(
      agentId: 'compliance',
      name: 'Agent Conformité',
      description: 'Conformité réglementaire & juridique',
      isActive: true,
      queriesToday: 31,
      totalQueries: 2104,
      avgScore: 0.88,
      color: Color(0xFF1565C0),
      icon: Icons.gavel,
    ),
    AiAgentStatus(
      agentId: 'commercial',
      name: 'Agent Commercial',
      description: 'Viabilité commerciale & marché',
      isActive: true,
      queriesToday: 19,
      totalQueries: 1567,
      avgScore: 0.79,
      color: Color(0xFFE65100),
      icon: Icons.trending_up,
    ),
    AiAgentStatus(
      agentId: 'accounting',
      name: 'Agent Comptabilité',
      description: 'Analyse financière & comptable',
      isActive: true,
      queriesToday: 28,
      totalQueries: 1943,
      avgScore: 0.84,
      color: Color(0xFF6A1B9A),
      icon: Icons.calculate,
    ),
  ];

  final List<AdminUser> _users = const [
    AdminUser(
      id: 'u1',
      fullName: 'Mustafa Rawji',
      email: 'admin@rawbank.com',
      phone: '+243 81 000 0001',
      role: UserRole.superAdmin,
      kycLevel: KycLevel.advanced,
      isActive: true,
      projectCount: 0,
    ),
    AdminUser(
      id: 'u2',
      fullName: 'Jean Mukendi',
      email: 'jean.mukendi@email.com',
      phone: '+243 82 123 4567',
      role: UserRole.client,
      kycLevel: KycLevel.standard,
      isActive: true,
      projectCount: 3,
    ),
    AdminUser(
      id: 'u3',
      fullName: 'Sarah Kabongo',
      email: 'sarah.k@email.com',
      phone: '+243 81 234 5678',
      role: UserRole.client,
      kycLevel: KycLevel.basic,
      isActive: true,
      projectCount: 1,
    ),
    AdminUser(
      id: 'u4',
      fullName: 'Pierre Mwamba',
      email: 'p.mwamba@email.com',
      phone: '+243 89 345 6789',
      role: UserRole.agent,
      kycLevel: KycLevel.advanced,
      isActive: true,
      projectCount: 12,
    ),
    AdminUser(
      id: 'u5',
      fullName: 'Grace Tshibangu',
      email: 'grace.t@email.com',
      phone: '+243 82 456 7890',
      role: UserRole.manager,
      kycLevel: KycLevel.advanced,
      isActive: false,
      projectCount: 8,
    ),
  ];

  final List<ProjectModel> _projects = [];


  @override
  void initState() {
    super.initState();
    _loadNewsFeed();
  }

  Future<void> _loadNewsFeed() async {
    setState(() => _isLoadingNews = true);
    final result = await AiService.instance.getNewsFeed(query: 'RawBank RDC banque 2025', limit: 10);
    if (mounted) {
      setState(() {
        _newsItems = result?.news ?? [];
        _rawbankUpdates = result?.rawbankUpdates ?? [];
        _isLoadingNews = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: IndexedStack(
        index: _currentTab,
        children: [
          _buildOverviewTab(),
          _buildProjectsTab(),
          _buildRequestsTab(),
          _buildAiHubTab(),
          _buildUsersTab(),
          _buildNewsTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF15151E),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 68,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _adminNavItem(Icons.dashboard, Icons.dashboard_outlined, 'Overview', 0),
                _adminNavItem(Icons.folder, Icons.folder_outlined, 'Projets', 1),
                _adminNavItem(Icons.inbox, Icons.inbox_outlined, 'Demandes', 2),
                _adminNavItem(Icons.psychology, Icons.psychology_outlined, 'IA Hub', 3),
                _adminNavItem(Icons.people, Icons.people_outlined, 'Users', 4),
                _adminNavItem(Icons.newspaper, Icons.newspaper_outlined, 'Actus', 5),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _adminNavItem(IconData filled, IconData outlined, String label, int index) {
    final isSelected = _currentTab == index;
    final color = isSelected ? AppColors.primary : const Color(0xFF8888A0);
    return InkWell(
      onTap: () => setState(() => _currentTab = index),
      child: SizedBox(
        width: 55,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? filled : outlined, color: color, size: 22),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: color)),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // TAB 0: OVERVIEW / DASHBOARD
  // ═══════════════════════════════════════════════════
  Widget _buildOverviewTab() {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shield, color: Colors.black, size: 28),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Back-Office', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                      Text('RawBank Admin — Accès complet', style: TextStyle(fontSize: 13, color: Color(0xFF8888A0))),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: const Text('SUPER ADMIN', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary, letterSpacing: 1)),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Stats grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _statCard(Icons.people, 'Utilisateurs', '${_stats.totalUsers}', const Color(0xFF1565C0)),
                _statCard(Icons.folder_open, 'Projets', '${_stats.totalProjects}', AppColors.primary),
                _statCard(Icons.hourglass_top, 'En attente', '${_stats.pendingProjects}', const Color(0xFFF57F17)),
                _statCard(Icons.check_circle, 'Approuvés', '${_stats.approvedProjects}', const Color(0xFF2E7D32)),
                _statCard(Icons.cancel, 'Rejetés', '${_stats.rejectedProjects}', const Color(0xFFC62828)),
                _statCard(Icons.inbox, 'Demandes', '${_stats.totalRequests}', const Color(0xFF6A1B9A)),
              ],
            ),
            const SizedBox(height: 20),

            // Funding requested card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary.withOpacity(0.15), const Color(0xFF15151E)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.account_balance_wallet, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Financement total demandé', style: TextStyle(fontSize: 13, color: Color(0xFF8888A0))),
                        const SizedBox(height: 4),
                        Text(currencyFormat.format(_stats.totalFundingRequested), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // AI Agents summary
            const Text('Agents IA actifs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 12),
            ...(_aiAgents.map((agent) => _buildAgentMiniCard(agent))),
            const SizedBox(height: 20),

            // Quick actions
            const Text('Actions rapides', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _quickAction(Icons.folder_open, 'Nouveaux\nprojets', '${_stats.pendingProjects}', const Color(0xFFF57F17), () => setState(() => _currentTab = 1))),
                const SizedBox(width: 12),
                Expanded(child: _quickAction(Icons.inbox, 'Demandes\nen attente', '12', const Color(0xFF6A1B9A), () => setState(() => _currentTab = 2))),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _quickAction(Icons.psychology, 'Configurer\nIA', '5 agents', AppColors.primary, () => setState(() => _currentTab = 3))),
                const SizedBox(width: 12),
                Expanded(child: _quickAction(Icons.people, 'Gérer\nutilisateurs', '${_stats.totalUsers}', const Color(0xFF1565C0), () => setState(() => _currentTab = 4))),
              ],
            ),
            const SizedBox(height: 20),

            // Recent activity
            const Text('Activité récente', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 12),
            ...(_requests.take(3).map((req) => _buildRequestMiniCard(req))),
          ],
        ),
      ),
    );
  }

  Widget _statCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF15151E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
              if (label == 'En attente' || label == 'Demandes')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: Text('!', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color)),
                ),
            ],
          ),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF8888A0))),
        ],
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, String badge, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF15151E),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white, height: 1.2)),
            const SizedBox(height: 4),
            Text(badge, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _buildAgentMiniCard(AiAgentStatus agent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF15151E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: agent.color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(agent.icon, color: agent.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(agent.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                Text('${agent.queriesToday} requêtes aujourd\'hui', style: const TextStyle(fontSize: 11, color: const Color(0xFF8888A0))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: agent.avgScore >= 0.8 ? const Color(0xFF2E7D32).withOpacity(0.15) : const Color(0xFFF57F17).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('${(agent.avgScore * 100).toStringAsFixed(0)}%', style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700,
              color: agent.avgScore >= 0.8 ? const Color(0xFF2E7D32) : const Color(0xFFF57F17),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestMiniCard(AdminRequest req) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF15151E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: req.type.color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(req.type.icon, color: req.type.color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(req.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(req.userName, style: const TextStyle(fontSize: 11, color: Color(0xFF8888A0))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: req.statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: Text(req.statusLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: req.statusColor)),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // TAB 1: PROJECTS MANAGEMENT
  // ═══════════════════════════════════════════════════
  Widget _buildProjectsTab() {
    // Use mock projects if none from API
    final mockProjects = [
      _MockAdminProject('p1', 'Agro-industrie Kasaï', 'Agriculture', 75000, ProjectStatus.submitted, 'Jean Mukendi', DateTime.now().subtract(const Duration(hours: 3))),
      _MockAdminProject('p2', 'Solar Energy Goma', 'Énergie & Environnement', 250000, ProjectStatus.aiReview, 'Marie Kalala', DateTime.now().subtract(const Duration(days: 2))),
      _MockAdminProject('p3', 'Tech Hub Kinshasa', 'Technologie & Télécoms', 500000, ProjectStatus.humanReview, 'Patrick Ilunga', DateTime.now().subtract(const Duration(days: 5))),
      _MockAdminProject('p4', 'Lady\'s First - Couture', 'Commerce & Distribution', 25000, ProjectStatus.approved, 'Sarah Kabongo', DateTime.now().subtract(const Duration(days: 7))),
      _MockAdminProject('p5', 'Export Café Robusta', 'Exportation', 120000, ProjectStatus.rejected, 'Joseph Tshisekedi', DateTime.now().subtract(const Duration(days: 10))),
      _MockAdminProject('p6', 'Clinique Santé Plus', 'Santé & Bien-être', 300000, ProjectStatus.pendingInfo, 'Dr. Grace Lwamba', DateTime.now().subtract(const Duration(days: 1))),
    ];

    return SafeArea(
      child: Column(
        children: [
          _buildAdminHeader('Tous les projets', '${mockProjects.length} au total'),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: mockProjects.length,
              itemBuilder: (context, index) => _buildProjectAdminCard(mockProjects[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectAdminCard(_MockAdminProject project) {
    Color statusColor;
    switch (project.status) {
      case ProjectStatus.approved: statusColor = const Color(0xFF2E7D32);
      case ProjectStatus.rejected: statusColor = const Color(0xFFC62828);
      case ProjectStatus.aiReview: statusColor = AppColors.primary;
      case ProjectStatus.humanReview: statusColor = const Color(0xFF0277BD);
      case ProjectStatus.pendingInfo: statusColor = const Color(0xFFF57F17);
      case ProjectStatus.submitted: statusColor = const Color(0xFF1565C0);
      default: statusColor = const Color(0xFF9E9E9E);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF15151E),
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: statusColor, width: 3)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(project.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Text(project.sector, style: const TextStyle(fontSize: 12, color: Color(0xFF8888A0))),
              const SizedBox(width: 8),
              Container(width: 3, height: 3, decoration: const BoxDecoration(color: Color(0xFF8888A0), shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text(project.userName, style: const TextStyle(fontSize: 12, color: Color(0xFF8888A0))),
            ],
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
          child: Text(project.statusLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: statusColor)),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _infoChip('Montant', '\$${project.amount.toStringAsFixed(0)}', AppColors.primary),
                    const SizedBox(width: 12),
                    _infoChip('Soumis', _formatDate(project.createdAt), const Color(0xFF8888A0)),
                  ],
                ),
                const SizedBox(height: 16),
                // Admin actions
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Approuver', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC62828),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        icon: const Icon(Icons.close, size: 18),
                        label: const Text('Rejeter', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {},
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primary.withOpacity(0.15),
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.psychology, size: 20),
                      tooltip: 'Analyser avec IA',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: color.withOpacity(0.7))),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // TAB 2: REQUESTS / DEMANDES
  // ═══════════════════════════════════════════════════
  Widget _buildRequestsTab() {
    return SafeArea(
      child: Column(
        children: [
          _buildAdminHeader('Toutes les demandes', '${_requests.length} au total'),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _requests.length,
              itemBuilder: (context, index) => _buildRequestCard(_requests[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(AdminRequest req) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF15151E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: req.type.color.withOpacity(0.15)),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: req.type.color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
          child: Icon(req.type.icon, color: req.type.color, size: 22),
        ),
        title: Text(req.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: req.type.color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                child: Text(req.type.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: req.type.color)),
              ),
              const SizedBox(width: 8),
              Text(req.userName, style: const TextStyle(fontSize: 12, color: Color(0xFF8888A0))),
            ],
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: req.statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
          child: Text(req.statusLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: req.statusColor)),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(req.description, style: const TextStyle(fontSize: 13, color: Color(0xFFAAAAAA), height: 1.4)),
                if (req.amount != null) ...[
                  const SizedBox(height: 8),
                  Text('Montant: \$${req.amount!.toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
                ],
                const SizedBox(height: 8),
                Text('Email: ${req.userEmail}', style: const TextStyle(fontSize: 12, color: Color(0xFF8888A0))),
                const SizedBox(height: 16),
                if (req.status == 'pending' || req.status == 'processing')
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Traiter', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFC62828),
                            side: const BorderSide(color: Color(0xFFC62828)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Rejeter', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // TAB 3: AI HUB — Full access to all AI agents
  // ═══════════════════════════════════════════════════
  Widget _buildAiHubTab() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAdminHeader2('Hub IA', '5 agents actifs'),
            const SizedBox(height: 8),

            // AI Agents full control
            ...(_aiAgents.map((agent) => _buildAiAgentFullCard(agent))),

            const SizedBox(height: 20),

            // AI Settings
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF15151E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Configuration globale IA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                  const SizedBox(height: 16),
                  _settingToggle('Auto-analyse nouveaux projets', true),
                  _settingToggle('Notifications score < 60%', true),
                  _settingToggle('Rapport quotidien automatique', false),
                  _settingToggle('Mode démo (réponses simulées)', true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiAgentFullCard(AiAgentStatus agent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF15151E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: agent.color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: agent.color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                child: Icon(agent.icon, color: agent.color, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(agent.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                    Text(agent.description, style: const TextStyle(fontSize: 12, color: Color(0xFF8888A0))),
                  ],
                ),
              ),
              Switch(
                value: agent.isActive,
                onChanged: (val) {},
                activeColor: AppColors.primary,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _metricChip('Aujourd\'hui', '${agent.queriesToday}', agent.color),
              const SizedBox(width: 12),
              _metricChip('Total', '${agent.totalQueries}', agent.color),
              const SizedBox(width: 12),
              _metricChip('Score moyen', '${(agent.avgScore * 100).toStringAsFixed(0)}%', agent.color),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    foregroundColor: agent.color,
                    side: BorderSide(color: agent.color.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.chat, size: 18),
                  label: const Text('Tester l\'agent', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {},
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.05),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.settings, size: 20),
                tooltip: 'Configurer',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF8888A0))),
          ],
        ),
      ),
    );
  }

  Widget _settingToggle(String label, bool initialValue) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool val = initialValue;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Expanded(child: Text(label, style: const TextStyle(fontSize: 14, color: Colors.white))),
              Switch(
                value: val,
                onChanged: (v) => setState(() => val = v),
                activeColor: AppColors.primary,
              ),
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════
  // TAB 4: USERS MANAGEMENT
  // ═══════════════════════════════════════════════════
  Widget _buildUsersTab() {
    return SafeArea(
      child: Column(
        children: [
          _buildAdminHeader('Utilisateurs', '${_users.length} inscrits'),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _users.length,
              itemBuilder: (context, index) => _buildUserCard(_users[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(AdminUser user) {
    Color roleColor = const Color(0xFF8888A0);
    switch (user.role) {
      case UserRole.superAdmin: roleColor = AppColors.primary;
      case UserRole.admin: roleColor = const Color(0xFF6A1B9A);
      case UserRole.manager: roleColor = const Color(0xFF0277BD);
      case UserRole.agent: roleColor = const Color(0xFF2E7D32);
      case UserRole.client: roleColor = const Color(0xFF8888A0);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF15151E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: roleColor.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: roleColor.withOpacity(0.2),
            child: Text(user.fullName.split(' ').map((n) => n.isNotEmpty ? n[0] : '').take(2).join(), style: TextStyle(fontWeight: FontWeight.w800, color: roleColor)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(user.fullName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                    if (!user.isActive) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFC62828).withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                        child: const Text('Inactif', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Color(0xFFC62828))),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(user.email, style: const TextStyle(fontSize: 12, color: Color(0xFF8888A0))),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: roleColor.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                      child: Text(user.roleLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: roleColor)),
                    ),
                    const SizedBox(width: 8),
                    Text('KYC: ${user.kycLevel.name}', style: const TextStyle(fontSize: 10, color: Color(0xFF8888A0))),
                    const SizedBox(width: 8),
                    Text('${user.projectCount} projets', style: const TextStyle(fontSize: 10, color: Color(0xFF8888A0))),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {},
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Modifier')),
              const PopupMenuItem(value: 'role', child: Text('Changer rôle')),
              const PopupMenuItem(value: 'activate', child: Text('Activer/Désactiver')),
              const PopupMenuItem(value: 'delete', child: Text('Supprimer', style: TextStyle(color: Color(0xFFC62828)))),
            ],
            color: const Color(0xFF22222F),
            child: const Icon(Icons.more_vert, color: Color(0xFF8888A0)),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════
  // SHARED HEADERS
  // ═══════════════════════════════════════════════════
  Widget _buildAdminHeader(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: const BoxDecoration(
        color: Color(0xFF15151E),
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
              Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF8888A0))),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.filter_list, color: Color(0xFF8888A0)),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Color(0xFF8888A0)),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminHeader2(String title, String subtitle) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
            Text(subtitle, style: const TextStyle(fontSize: 13, color: Color(0xFF8888A0))),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Widget _buildNewsTab() {
    return RefreshIndicator(
      onRefresh: _loadNewsFeed,
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAdminHeader2('Actualités', 'RawBank et secteur bancaire RDC'),

          // RawBank KPIs from annual report
          if (_rawbankUpdates.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildSectionTitle('Indicateurs Clés 2025'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _rawbankUpdates.map((u) {
                Color impactColor;
                if (u.impact == 'Positif') {
                  impactColor = const Color(0xFF4CAF50);
                } else if (u.impact == 'Vigilance') {
                  impactColor = const Color(0xFFFFA726);
                } else {
                  impactColor = const Color(0xFFEF5350);
                }
                return Container(
                  width: MediaQuery.of(context).size.width * 0.45,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF15151E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border(left: BorderSide(color: impactColor, width: 3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(u.category, style: TextStyle(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text(u.title, style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(u.detail, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: impactColor.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                        child: Text(u.impact, style: TextStyle(fontSize: 10, color: impactColor, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],

          // News articles
          const SizedBox(height: 24),
          _buildSectionTitle('Dernières Actualités'),
          const SizedBox(height: 12),

          if (_isLoadingNews)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: AppColors.primary)))
          else if (_newsItems.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('Aucune actualité disponible', style: TextStyle(color: Colors.grey))))
          else
            ..._newsItems.map((n) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF15151E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
                        child: Text(n.source, style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w600)),
                      ),
                      const Spacer(),
                      if (n.date.isNotEmpty)
                        Text(n.date, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(n.title, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600)),
                  if (n.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(n.description, style: TextStyle(fontSize: 12, color: Colors.grey[400]), maxLines: 3, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            )).toList(),

          const SizedBox(height: 20),
          // AI Info box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Icon(Icons.psychology, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  const Text('Auto-Formation IA', style: TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w700)),
                ]),
                const SizedBox(height: 8),
                Text(
                  "L\'IA RawBank s\'auto-forme automatiquement à partir des actualités bancaires. "
                  "Connexion à X (Twitter) prévue pour un flux temps réel des nouveautés. "
                  "Modèle: Llama 3.3 70B via Groq (gratuit).",
                  style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w700));
  }
}

// Extension to add date to AdminRequest
extension on AdminRequest {
  AdminRequest copyWithDate(DateTime date) {
    return AdminRequest(
      id: id,
      type: type,
      userName: userName,
      userEmail: userEmail,
      title: title,
      description: description,
      status: status,
      createdAt: date,
      amount: amount,
    );
  }
}

// Simple mock project for admin view

class _MockAdminProject {
  final String id;
  final String title;
  final String sector;
  final double amount;
  final ProjectStatus status;
  final String userName;
  final DateTime createdAt;

  _MockAdminProject(this.id, this.title, this.sector, this.amount, this.status, this.userName, this.createdAt);

  String get statusLabel {
    switch (status) {
      case ProjectStatus.draft: return 'Brouillon';
      case ProjectStatus.submitted: return 'Soumis';
      case ProjectStatus.analyzing: return 'En analyse';
      case ProjectStatus.aiReview: return 'Analyse IA';
      case ProjectStatus.humanReview: return 'Validation humaine';
      case ProjectStatus.approved: return 'Approuvé';
      case ProjectStatus.rejected: return 'Rejeté';
      case ProjectStatus.pendingInfo: return 'Complément requis';
    }
  }

  Color get statusColor {
    switch (status) {
      case ProjectStatus.draft: return const Color(0xFF9E9E9E);
      case ProjectStatus.submitted: return const Color(0xFF2196F3);
      case ProjectStatus.analyzing: return const Color(0xFFFFA726);
      case ProjectStatus.aiReview: return const Color(0xFF9C27B0);
      case ProjectStatus.humanReview: return const Color(0xFFFFA726);
      case ProjectStatus.approved: return const Color(0xFF4CAF50);
      case ProjectStatus.rejected: return const Color(0xFFEF5350);
      case ProjectStatus.pendingInfo: return const Color(0xFFFFC107);
    }
  }
}
