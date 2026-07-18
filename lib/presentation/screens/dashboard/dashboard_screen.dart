import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/account_model.dart';
import '../accounts/accounts_screen.dart';
import '../profile/profile_screen.dart';
import '../chat/chat_screen.dart';
import '../../../core/services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _HomeTab(),
          _ProjectsTab(),
          AccountsScreen(),
          ChatScreen(projectId: 'assistant', showBackButton: false),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Color(0x0F000000), blurRadius: 20, offset: Offset(0, -4)),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (i) => setState(() => _selectedIndex = i),
          backgroundColor: Colors.white,
          indicatorColor: AppColors.primary.withValues(alpha: 0.1),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home, color: AppColors.primary),
              label: 'Accueil',
            ),
            NavigationDestination(
              icon: const Icon(Icons.folder_outlined),
              selectedIcon: const Icon(Icons.folder, color: AppColors.primary),
              label: 'Projets',
            ),
            NavigationDestination(
              icon: const Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: const Icon(Icons.account_balance_wallet, color: AppColors.primary),
              label: 'Comptes',
            ),
            NavigationDestination(
              icon: const Icon(Icons.smart_toy_outlined),
              selectedIcon: const Icon(Icons.smart_toy, color: AppColors.primary),
              label: 'Chat IA',
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outlined),
              selectedIcon: const Icon(Icons.person, color: AppColors.primary),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

// ── HOME TAB ──
class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  bool _isLoading = true;
  bool _hasError = false;
  String _userName = '';
  double _balance = 0;
  String _currency = 'USD';
  List<dynamic> _projects = [];
  List<dynamic> _transactions = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _hasError = false; });
    try {
      final results = await Future.wait([
        ApiService.instance.me(),
        ApiService.instance.getAccounts(),
        ApiService.instance.getProjects(),
      ]);
      final user = results[0] as Map<String, dynamic>;
      final accounts = results[1] as List<dynamic>;
      final projects = results[2] as List<dynamic>;

      double balance = 0;
      String currency = 'USD';
      List<dynamic> txs = [];
      if (accounts.isNotEmpty) {
        final illico = accounts.firstWhere(
          (a) => (a as Map)['type'] == 'illicoCash',
          orElse: () => accounts.first,
        ) as Map<String, dynamic>;
        balance = (illico['balance'] as num?)?.toDouble() ?? 0;
        currency = illico['currency'] as String? ?? 'USD';
        txs = await ApiService.instance.getTransactions(illico['id'] as String);
      }

      if (!mounted) return;
      setState(() {
        _userName = (user['full_name'] as String?) ?? '';
        _balance = balance;
        _currency = currency;
        _projects = projects;
        _transactions = txs.take(3).toList();
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() { _hasError = true; _isLoading = false; });
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts.isNotEmpty) return parts[0][0].toUpperCase();
    return '?';
  }

  String _relativeDate(String? iso) {
    if (iso == null) return '';
    final date = DateTime.tryParse(iso);
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.primary,
            expandedHeight: 0,
            toolbarHeight: 70,
            flexibleSpace: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Bonjour 👋',
                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                      Text(_userName.isNotEmpty ? _userName : 'Bienvenue',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const Spacer(),
                  Stack(
                    children: [
                      Container(
                        width: 42, height: 42,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                        child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                      ),
                      const Positioned(
                        top: 6, right: 6,
                        child: SizedBox(
                          width: 8, height: 8,
                          child: DecoratedBox(
                            decoration: BoxDecoration(color: Color(0xFFFFD700), shape: BoxShape.circle),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)),
                    child: Center(
                      child: Text(_initials(_userName), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_hasError)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                          const SizedBox(width: 8),
                          const Expanded(child: Text('Certaines données n\'ont pas pu être chargées.', style: TextStyle(color: AppColors.error, fontSize: 13))),
                          TextButton(onPressed: _load, child: const Text('Réessayer')),
                        ],
                      ),
                    ),
                  _IllicoCashCard(balance: _balance, currency: _currency),
                  const SizedBox(height: 24),
                  _QuickActions(),
                  const SizedBox(height: 24),
                  _KycBanner(),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Projets en cours', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.newProject),
                        child: const Text('Voir tout', style: TextStyle(color: AppColors.primary, fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_projects.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.grey200),
                      ),
                      child: const Text('Aucun projet pour l\'instant. Lancez votre première demande de financement.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    )
                  else
                    Builder(builder: (context) {
                      final p = _projects.first as Map<String, dynamic>;
                      final info = projectStatusInfo(p['status'] as String? ?? 'submitted');
                      return _ProjectCard(
                        title: p['title'] as String? ?? '',
                        type: p['type'] as String? ?? '',
                        status: info.label,
                        step: info.step,
                        amount: '\$${(p['amount_requested'] as num? ?? 0).toStringAsFixed(0)}',
                      );
                    }),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Dernières transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      TextButton(
                        onPressed: () => Navigator.pushNamed(context, AppRoutes.accounts),
                        child: const Text('Tout voir', style: TextStyle(color: AppColors.primary, fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_transactions.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.grey200),
                      ),
                      child: const Text('Aucune transaction pour le moment.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    )
                  else
                    for (final t in _transactions)
                      Builder(builder: (context) {
                        final tx = t as Map<String, dynamic>;
                        final isCredit = tx['type'] == 'credit' || tx['type'] == 'refund';
                        final amount = (tx['amount'] as num? ?? 0).toDouble();
                        return _TxItem(
                          label: (tx['description'] as String?)?.isNotEmpty == true ? tx['description'] as String : 'Transaction',
                          amount: '${isCredit ? '+' : '-'}\$${amount.toStringAsFixed(2)}',
                          date: _relativeDate(tx['created_at'] as String?),
                          isCredit: isCredit,
                        );
                      }),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProjectStatusInfo {
  final String label;
  final Color color;
  final int step;
  const ProjectStatusInfo(this.label, this.color, this.step);
}

ProjectStatusInfo projectStatusInfo(String status) {
  switch (status) {
    case 'draft':
      return const ProjectStatusInfo('Brouillon', AppColors.grey500, 0);
    case 'submitted':
      return const ProjectStatusInfo('Soumis', AppColors.info, 1);
    case 'analyzing':
      return const ProjectStatusInfo('Analyse IA en cours', AppColors.warning, 2);
    case 'ai_review':
      return const ProjectStatusInfo('Revue IA', AppColors.warning, 3);
    case 'human_review':
      return const ProjectStatusInfo('Revue humaine', AppColors.warning, 3);
    case 'approved':
      return const ProjectStatusInfo('Approuvé', AppColors.success, 5);
    case 'rejected':
      return const ProjectStatusInfo('Rejeté', AppColors.error, 5);
    case 'pending_info':
      return const ProjectStatusInfo('En attente d\'infos', AppColors.info, 1);
    default:
      return const ProjectStatusInfo('Soumis', AppColors.info, 1);
  }
}
class _IllicoCashCard extends StatelessWidget {
  final double balance;
  final String currency;
  const _IllicoCashCard({required this.balance, this.currency = 'USD'});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('IllicoCash', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(currency, style: const TextStyle(color: Colors.white54, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(balance),
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _QuickBtn(icon: Icons.send, label: 'Virement', onTap: () => Navigator.pushNamed(context, '/transfer')),
              const SizedBox(width: 10),
              _QuickBtn(icon: Icons.add, label: 'Dépôt', onTap: () {}),
              const SizedBox(width: 10),
              _QuickBtn(icon: Icons.qr_code, label: 'QR Pay', onTap: () {}),
              const SizedBox(width: 10),
              _QuickBtn(icon: Icons.history, label: 'Historique', onTap: () {}),
            ],
          ),
        ],
      ),
    );
  }
}
class _QuickBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      {'icon': Icons.add_business, 'label': 'Nouveau\nprojet', 'route': AppRoutes.newProject},
      {'icon': Icons.send, 'label': 'Virement', 'route': '/transfer'},
      {'icon': Icons.qr_code_scanner, 'label': 'Scanner\nQR', 'route': ''},
      {'icon': Icons.receipt_long, 'label': 'Relevé', 'route': ''},
    ];
    return Row(
      children: actions.map((a) {
        return Expanded(
          child: GestureDetector(
            onTap: () {
              final route = a['route'] as String;
              if (route.isNotEmpty) Navigator.pushNamed(context, route);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.grey200),
              ),
              child: Column(
                children: [
                  Icon(a['icon'] as IconData, color: AppColors.primary, size: 26),
                  const SizedBox(height: 6),
                  Text(
                    (a['label'] as String).replaceAll('\n', ' '),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _KycBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shield_outlined, color: AppColors.warning, size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('KYC Standard', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text('Améliorez pour débloquer plus de services',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.grey500),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final String title, type, status, amount;
  final int step;
  const _ProjectCard({required this.title, required this.type, required this.status, required this.step, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(type, style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              Text(amount, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 16, color: AppColors.warning),
              const SizedBox(width: 6),
              Text(status, style: TextStyle(color: AppColors.warning, fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 10),
          // Progress steps
          Row(
            children: List.generate(5, (i) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
                  height: 4,
                  decoration: BoxDecoration(
                    color: i <= step ? AppColors.primary : AppColors.grey200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _TxItem extends StatelessWidget {
  final String label, amount, date;
  final bool isCredit;
  const _TxItem({required this.label, required this.amount, required this.date, required this.isCredit});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: (isCredit ? AppColors.success : AppColors.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCredit ? Icons.south_west : Icons.north_east,
              color: isCredit ? AppColors.success : AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(date, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: isCredit ? AppColors.success : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── PROJECTS TAB ──
class _ProjectsTab extends StatefulWidget {
  const _ProjectsTab();

  @override
  State<_ProjectsTab> createState() => _ProjectsTabState();
}

class _ProjectsTabState extends State<_ProjectsTab> {
  bool _isLoading = true;
  bool _hasError = false;
  List<dynamic> _projects = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _hasError = false; });
    try {
      final projects = await ApiService.instance.getProjects();
      if (!mounted) return;
      setState(() { _projects = projects; _isLoading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _hasError = true; _isLoading = false; });
    }
  }

  String _formatDate(String? iso) {
    if (iso == null) return '';
    final date = DateTime.tryParse(iso);
    if (date == null) return '';
    return 'Soumis le ${DateFormat('dd/MM/yyyy').format(date)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes Projets'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.newProject),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Nouveau projet'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              onRefresh: _load,
              child: _projects.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        if (_hasError)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text('Impossible de charger vos projets. Tirez pour réessayer.',
                                style: const TextStyle(color: AppColors.error, fontSize: 13)),
                          ),
                        const SizedBox(height: 60),
                        const Center(
                          child: Text('Aucun projet pour l\'instant.\nCréez votre première demande de financement.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                        ),
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.all(20),
                      children: [
                        for (final item in _projects) ...[
                          Builder(builder: (context) {
                            final p = item as Map<String, dynamic>;
                            final info = projectStatusInfo(p['status'] as String? ?? 'submitted');
                            return _FullProjectCard(
                              title: p['title'] as String? ?? '',
                              type: p['type'] as String? ?? '',
                              sector: p['sector'] as String? ?? '',
                              status: info.label,
                              statusColor: info.color,
                              amount: (p['amount_requested'] as num? ?? 0).toDouble(),
                              step: info.step,
                              date: _formatDate(p['created_at'] as String?),
                            );
                          }),
                          const SizedBox(height: 12),
                        ],
                        const SizedBox(height: 88),
                      ],
                    ),
            ),
    );
  }
}
class _FullProjectCard extends StatelessWidget {
  final String title, type, sector, status, date;
  final Color statusColor;
  final double amount;
  final int step;
  const _FullProjectCard({
    required this.title, required this.type, required this.sector,
    required this.status, required this.statusColor,
    required this.amount, required this.step, required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(type, style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              Text(
                NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(amount),
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
          const SizedBox(height: 4),
          Text(sector, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
              const Spacer(),
              Text(date, style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (i) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
                  height: 5,
                  decoration: BoxDecoration(
                    color: i < step ? statusColor : AppColors.grey200,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
