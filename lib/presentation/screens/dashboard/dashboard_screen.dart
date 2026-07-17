import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/account_model.dart';
import '../accounts/accounts_screen.dart';
import '../profile/profile_screen.dart';

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
        children: [
          const _HomeTab(),
          const _ProjectsTab(),
          const AccountsScreen(),
          const ProfileScreen(),
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
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home, color: AppColors.primary),
              label: 'Accueil',
            ),
            NavigationDestination(
              icon: Icon(Icons.folder_outlined),
              selectedIcon: Icon(Icons.folder, color: AppColors.primary),
              label: 'Projets',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet, color: AppColors.primary),
              label: 'Comptes',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outlined),
              selectedIcon: Icon(Icons.person, color: AppColors.primary),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}

// ── HOME TAB ──
class _HomeTab extends StatelessWidget {
  const _HomeTab();

  final AccountModel _illicoCash = const AccountModel(
    id: 'acc-illico-001', userId: '1',
    type: AccountType.illicoCash,
    balance: 2450.75, currency: 'USD',
    status: AccountStatus.active,
    createdAt: null,
  );

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
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
                    const Text('Jean Mutombo',
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
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
                  child: const Center(
                    child: Text('JM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
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
                _IllicoCashCard(balance: _illicoCash.balance),
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
                _ProjectCard(
                  title: 'Épicerie Bio Kinshasa',
                  type: 'PME',
                  status: 'Analyse IA en cours',
                  step: 2,
                  amount: '\$15,000',
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Dernières transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Tout voir', style: TextStyle(color: AppColors.primary, fontSize: 13)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _TxItem(label: 'Virement reçu', amount: '+\$500.00', date: 'Il y a 2h', isCredit: true),
                _TxItem(label: 'Paiement dossier PME', amount: '-\$49.50', date: 'Il y a 8h', isCredit: false),
                _TxItem(label: 'Transfert IllicoCash', amount: '-\$200.00', date: 'Hier', isCredit: false),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _IllicoCashCard extends StatelessWidget {
  final double balance;
  const _IllicoCashCard({required this.balance});

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
              const Text('USD', style: TextStyle(color: Colors.white54, fontSize: 13)),
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
            child: Icon(Icons.shield_outlined, color: AppColors.warning, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('KYC Standard', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text('Améliorez pour débloquer plus de services',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.grey500),
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
              Icon(Icons.auto_awesome, size: 16, color: AppColors.warning),
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
class _ProjectsTab extends StatelessWidget {
  const _ProjectsTab();

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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _FullProjectCard(
            title: 'Épicerie Bio Kinshasa',
            type: 'PME',
            sector: 'Commerce & Distribution',
            status: 'Analyse IA en cours',
            statusColor: AppColors.warning,
            amount: 15000,
            step: 2,
            date: 'Soumis il y a 3 jours',
          ),
          const SizedBox(height: 12),
          _FullProjectCard(
            title: 'Ferme avicole Mbankana',
            type: 'Agriculture',
            sector: 'Agriculture & Agro-alimentaire',
            status: 'Approuvé',
            statusColor: AppColors.success,
            amount: 25000,
            step: 5,
            date: 'Approuvé le 12/07/2026',
          ),
          const SizedBox(height: 12),
          _FullProjectCard(
            title: 'Logiciel gestion stock',
            type: 'PME',
            sector: 'Technologies & Numérique',
            status: 'En attente d\'infos',
            statusColor: AppColors.info,
            amount: 8000,
            step: 1,
            date: 'Soumis il y a 7 jours',
          ),
          const SizedBox(height: 100),
        ],
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
