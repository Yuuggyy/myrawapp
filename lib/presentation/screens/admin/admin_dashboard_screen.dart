import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/services/admin_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

/// Admin Back-Office — connected to real Supabase data
/// 6 tabs: Overview, Projects, Requests, AI Hub (RAG upload), Users, News
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _adminService = AdminService.instance;
  int _currentTab = 0;
  bool _isLoading = true;
  AdminStats _stats = AdminStats.empty();
  List<Map<String, dynamic>> _projects = [];
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _kbDocs = [];
  List<Map<String, dynamic>> _recentProjects = [];

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() => _isLoading = true);
    try {
      final stats = await _adminService.getStats();
      final projects = await _adminService.getProjects();
      final users = await _adminService.getUsers();
      final kbDocs = await _adminService.getKnowledgeBase();

      if (mounted) {
        setState(() {
          _stats = stats;
          _projects = projects;
          _users = users;
          _kbDocs = kbDocs;
          _recentProjects = projects.take(5).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _approveProject(String projectId) async {
    final success = await _adminService.updateProjectStatus(
      projectId: projectId,
      status: 'approved',
      reviewNotes: 'Approuvé par admin',
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Projet approuvé'), backgroundColor: Colors.green),
      );
      _loadAllData();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de l\'approbation'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _rejectProject(String projectId) async {
    final success = await _adminService.updateProjectStatus(
      projectId: projectId,
      status: 'rejected',
      reviewNotes: 'Rejeté par admin',
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Projet rejeté'), backgroundColor: Colors.orange),
      );
      _loadAllData();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors du rejet'), backgroundColor: Colors.red),
      );
    }
  }

  void _showUploadDocumentDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    String selectedCategory = 'general';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.cloud_upload, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Uploader un document RAG'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Titre du document',
                      border: OutlineInputBorder(),
                      hintText: 'ex: Guide RSE RawBank',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Description (optionnel)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Catégorie',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'general', child: Text('Général')),
                      DropdownMenuItem(value: 'rse', child: Text('RSE')),
                      DropdownMenuItem(value: 'conformite', child: Text('Conformité')),
                      DropdownMenuItem(value: 'commercial', child: Text('Commercial')),
                      DropdownMenuItem(value: 'comptabilite', child: Text('Comptabilité')),
                    ],
                    onChanged: (v) => setDialogState(() => selectedCategory = v!),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contentCtrl,
                    maxLines: 8,
                    decoration: const InputDecoration(
                      labelText: 'Contenu du document',
                      border: OutlineInputBorder(),
                      hintText: 'Collez ici le texte du document...',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.isEmpty || contentCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Titre et contenu requis')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Upload en cours...')),
                );
                final result = await _adminService.uploadDocument(
                  title: titleCtrl.text,
                  content: contentCtrl.text,
                  category: selectedCategory,
                  description: descCtrl.text.isEmpty ? null : descCtrl.text,
                );
                if (result != null && result['success'] == true && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Document "${titleCtrl.text}" ajouté à la base de connaissances'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadAllData();
                } else if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Erreur lors de l\'upload'), backgroundColor: Colors.red),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text('Uploader', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Back-Office RawBank'), backgroundColor: AppColors.primary),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Back-Office RawBank', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadAllData,
            tooltip: 'Actualiser',
          ),
        ],
      ),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (i) => setState(() => _currentTab = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Vue d\'ensemble'),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: 'Projets'),
          BottomNavigationBarItem(icon: Icon(Icons.inbox), label: 'Demandes'),
          BottomNavigationBarItem(icon: Icon(Icons.psychology), label: 'Hub IA'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.article), label: 'Actu'),
        ],
      ),
      floatingActionButton: _currentTab == 3
          ? FloatingActionButton(
              onPressed: _showUploadDocumentDialog,
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.cloud_upload, color: Colors.white),
              tooltip: 'Uploader un document RAG',
            )
          : null,
    );
  }

  // ── Overview Tab ──
  Widget _buildOverviewTab() {
    final fmt = NumberFormat('#,##0');
    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Stats grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.2,
            children: [
              _statCard('Utilisateurs', '${_stats.totalUsers}', Icons.people, Colors.blue),
              _statCard('Projets', '${_stats.totalProjects}', Icons.folder, AppColors.primary),
              _statCard('En attente', '${_stats.pendingProjects}', Icons.pending, Colors.orange),
              _statCard('Approuvés', '${_stats.approvedProjects}', Icons.check_circle, Colors.green),
              _statCard('Rejetés', '${_stats.rejectedProjects}', Icons.cancel, Colors.red),
              _statCard('Financement', '\$${fmt.format(_stats.totalFundingRequested)}', Icons.attach_money, Colors.purple),
              _statCard('Transactions', '${_stats.totalTransactions}', Icons.swap_horiz, Colors.teal),
              _statCard('Docs RAG', '${_stats.knowledgeBaseDocs}', Icons.library_books, Colors.indigo),
            ],
          ),
          const SizedBox(height: 20),
          // AI Agents summary
          const Text('Agents IA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...AppConstants.agentKeys.map((key) => _agentMiniRow(key)),
          const SizedBox(height: 16),
          // Recent projects
          const Text('Projets récents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_recentProjects.isEmpty)
            const Card(child: ListTile(title: Text('Aucun projet pour l\'instant')))
          else
            ..._recentProjects.map((p) => _recentProjectCard(p)),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _agentMiniRow(String agentKey) {
    final name = AppConstants.agentNames[agentKey] ?? agentKey;
    final desc = AppConstants.agentDescriptions[agentKey] ?? '';
    final colors = {
      'routeur': Colors.amber, 'rse': Colors.green, 'conformite': Colors.blue,
      'commercial': Colors.orange, 'comptabilite': Colors.purple,
    };
    return Card(
      child: ListTile(
        leading: CircleAvatar(backgroundColor: colors[agentKey]?.withOpacity(0.2), child: Icon(Icons.psychology, color: colors[agentKey])),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(desc),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
          child: const Text('Actif', style: TextStyle(color: Colors.green, fontSize: 12)),
        ),
      ),
    );
  }

  Widget _recentProjectCard(Map<String, dynamic> p) {
    final status = p['status'] ?? 'submitted';
    final statusColors = {
      'submitted': Colors.orange, 'approved': Colors.green,
      'rejected': Colors.red, 'pending': Colors.orange, 'under_review': Colors.blue,
    };
    return Card(
      child: ListTile(
        title: Text(p['project_name'] ?? 'Sans titre', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${p['sector'] ?? 'N/A'} • \$${p['requested_amount'] ?? 0}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: (statusColors[status] ?? Colors.grey).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
          child: Text(status, style: TextStyle(color: statusColors[status] ?? Colors.grey, fontSize: 12)),
        ),
      ),
    );
  }

  // ── Projects Tab ──
  Widget _buildProjectsTab() {
    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: _projects.isEmpty
          ? ListView(children: [const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('Aucun projet soumis')))])
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _projects.length,
              itemBuilder: (ctx, i) => _projectAdminCard(_projects[i]),
            ),
    );
  }

  Widget _projectAdminCard(Map<String, dynamic> p) {
    final status = p['status'] ?? 'submitted';
    final statusColors = {
      'submitted': Colors.orange, 'approved': Colors.green,
      'rejected': Colors.red, 'pending': Colors.orange, 'under_review': Colors.blue,
    };
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    p['project_name'] ?? 'Sans titre',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: (statusColors[status] ?? Colors.grey).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                  child: Text(status, style: TextStyle(color: statusColors[status] ?? Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Secteur: ${p['sector'] ?? 'N/A'}'),
            Text('Type: ${p['funding_type'] ?? 'N/A'}'),
            Text('Montant: \$${p['requested_amount'] ?? 0}'),
            if (p['project_description'] != null) ...[
              const SizedBox(height: 8),
              Text(p['project_description'], maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
            ],
            if (p['interest_rate'] != null)
              Text('Taux: ${p['interest_rate']}%'),
            if (p['projected_revenue'] != null)
              Text('Revenus projetés: \$${p['projected_revenue']}'),
            if (p['bank_profit_share'] != null)
              Text('Part banque: ${p['bank_profit_share']}%'),
            const SizedBox(height: 12),
            if (status == 'submitted' || status == 'pending' || status == 'under_review')
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _rejectProject(p['id']),
                    style: TextButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Rejeter'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _approveProject(p['id']),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text('Approuver', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ── Requests Tab (pending projects) ──
  Widget _buildRequestsTab() {
    final pending = _projects.where((p) => 
      p['status'] == 'submitted' || p['status'] == 'pending' || p['status'] == 'under_review'
    ).toList();
    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: pending.isEmpty
          ? ListView(children: [const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('Aucune demande en attente')))])
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pending.length,
              itemBuilder: (ctx, i) => _projectAdminCard(pending[i]),
            ),
    );
  }

  // ── AI Hub Tab (RAG documents) ──
  Widget _buildAiHubTab() {
    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Card(
            color: AppColors.primary.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.psychology, color: AppColors.primary, size: 32),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hub IA — Base de connaissances', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('Uploadez des documents pour nourrir les agents IA (RAG)', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Agents list
          const Text('Agents IA actifs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...AppConstants.agentKeys.map((key) => _agentFullCard(key)),
          const SizedBox(height: 20),
          // Knowledge base documents
          Row(
            children: [
              const Text('Documents RAG', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Spacer(),
              Text('${_kbDocs.length} document(s)', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 8),
          if (_kbDocs.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.library_books, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    const Text('Aucun document dans la base'),
                    const SizedBox(height: 4),
                    const Text('Cliquez sur le bouton + pour uploader', style: TextStyle(fontSize: 13, color: Colors.grey)),
                  ],
                ),
              ),
            )
          else
            ..._kbDocs.map((doc) => _kbDocCard(doc)),
          const SizedBox(height: 16),
          // Info banner
          Card(
            color: Colors.blue.withOpacity(0.1),
            child: const Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Les documents uploadés alimentent le RAG. L\'IA les utilise comme contexte pour répondre aux questions des clients.',
                      style: TextStyle(fontSize: 13),
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

  Widget _agentFullCard(String agentKey) {
    final name = AppConstants.agentNames[agentKey] ?? agentKey;
    final desc = AppConstants.agentDescriptions[agentKey] ?? '';
    final colors = {
      'routeur': Colors.amber, 'rse': Colors.green, 'conformite': Colors.blue,
      'commercial': Colors.orange, 'comptabilite': Colors.purple,
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: (colors[agentKey] ?? Colors.grey).withOpacity(0.2),
              child: Icon(Icons.psychology, color: colors[agentKey]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
              child: const Text('Actif', style: TextStyle(color: Colors.green, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kbDocCard(Map<String, dynamic> doc) {
    return Card(
      child: ListTile(
        leading: Icon(
          doc['document_type'] == 'pdf' ? Icons.picture_as_pdf : Icons.description,
          color: doc['category'] == 'rse' ? Colors.green : doc['category'] == 'conformite' ? Colors.blue : Colors.indigo,
        ),
        title: Text(doc['title'] ?? 'Sans titre', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${doc['category'] ?? 'general'} • ${doc['embedding_status'] ?? 'pending'}'),
        trailing: doc['is_active'] == true
            ? const Icon(Icons.check_circle, color: Colors.green, size: 20)
            : const Icon(Icons.pause_circle, color: Colors.grey, size: 20),
      ),
    );
  }

  // ── Users Tab ──
  Widget _buildUsersTab() {
    return RefreshIndicator(
      onRefresh: _loadAllData,
      child: _users.isEmpty
          ? ListView(children: [const Center(child: Padding(padding: EdgeInsets.all(40), child: Text('Aucun utilisateur')))])
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _users.length,
              itemBuilder: (ctx, i) => _userCard(_users[i]),
            ),
    );
  }

  Widget _userCard(Map<String, dynamic> u) {
    final kycColors = {'verified': Colors.green, 'pending': Colors.orange, 'rejected': Colors.red};
    final kyc = u['kyc_status'] ?? 'pending';
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.2),
          child: Text(
            (u['full_name'] ?? 'U')[0].toUpperCase(),
            style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(u['full_name'] ?? 'Inconnu', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(u['email'] ?? ''),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: (kycColors[kyc] ?? Colors.grey).withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
          child: Text('KYC: $kyc', style: TextStyle(color: kycColors[kyc] ?? Colors.grey, fontSize: 12)),
        ),
      ),
    );
  }

  // ── News Tab (placeholder with RawBank info) ──
  Widget _buildNewsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Actualités RawBank', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.trending_up, color: Colors.green, size: 32),
            title: const Text('RawBank: 1ère banque de RDC'),
            subtitle: const Text('Plus de 100 agences, 274 ATM, au service du développement'),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.eco, color: Colors.green, size: 32),
            title: const Text('RawBank RSE — Inclusion financière'),
            subtitle: const Text('Programmes Lady\'s First, We Act, financement vert'),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.phone_android, color: AppColors.primary, size: 32),
            title: const Text('IllicoCash — Mobile Banking'),
            subtitle: const Text('Transferts, paiements marchands, recharge mobile'),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Système', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Statut du système', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                _systemRow('Backend IA (Groq)', true),
                _systemRow('Supabase (kblhgqvpoteyctszmkgd)', true),
                _systemRow('RAG Knowledge Base', _kbDocs.isNotEmpty),
                _systemRow('Chat IA (5 agents)', true),
                _systemRow('Admin Dashboard', true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _systemRow(String label, bool active) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(active ? Icons.check_circle : Icons.pending, color: active ? Colors.green : Colors.orange, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13))),
          Text(active ? 'OK' : 'En attente', style: TextStyle(fontSize: 12, color: active ? Colors.green : Colors.orange)),
        ],
      ),
    );
  }
}
