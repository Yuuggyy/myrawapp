import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../data/mock_data.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.00', 'fr_FR');
    final unreadCount = MockNotifications.notifications.where((n) => n['isRead'] == false).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Bonjour,', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
                                Text('Jean-Philippe 👋', style: GoogleFonts.poppins(
                                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                              ],
                            ),
                            Stack(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 28),
                                  onPressed: () {},
                                ),
                                if (unreadCount > 0)
                                  Positioned(
                                    top: 8, right: 8,
                                    child: Container(
                                      width: 18, height: 18,
                                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                      child: Center(child: Text('$unreadCount', style: GoogleFonts.poppins(
                                        fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w700))),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text('Solde IllicoCash', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12)),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('\$${formatter.format(2450.75)}',
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700)),
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text('+2.4%', style: GoogleFonts.poppins(
                                  color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Actions
                  Row(
                    children: [
                      _QuickAction(icon: Icons.send_rounded, label: 'Envoyer', color: AppColors.primary),
                      const SizedBox(width: 12),
                      _QuickAction(icon: Icons.add_rounded, label: 'Recharger', color: Color(0xFF1565C0)),
                      const SizedBox(width: 12),
                      _QuickAction(icon: Icons.receipt_long_rounded, label: 'Payer', color: Color(0xFF2E7D32)),
                      const SizedBox(width: 12),
                      _QuickAction(icon: Icons.more_horiz_rounded, label: 'Plus', color: AppColors.textGrey),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // KYC Alert
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), shape: BoxShape.circle),
                          child: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('KYC Standard requis', style: GoogleFonts.poppins(
                                fontSize: 13, fontWeight: FontWeight.w600, color: Colors.orange.shade800)),
                              Text('Complétez votre vérification pour accéder à tous les services',
                                style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textGrey)),
                            ],
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios, size: 14, color: Colors.orange.shade600),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Projets en cours
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Mes projets', style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700)),
                      TextButton(onPressed: () {}, child: Text('Voir tout', style: GoogleFonts.poppins(
                        color: AppColors.primary, fontSize: 13))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...MockProjects.projects.take(2).map((p) => _ProjectCard(project: p)),
                  const SizedBox(height: 24),

                  // Dernières transactions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Transactions récentes', style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w700)),
                      TextButton(onPressed: () {}, child: Text('Voir tout', style: GoogleFonts.poppins(
                        color: AppColors.primary, fontSize: 13))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBg, borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                    ),
                    child: Column(
                      children: MockTransactions.transactions.take(3).toList().asMap().entries.map((e) {
                        final i = e.key; final t = e.value;
                        return _TransactionTile(transaction: t, showDivider: i < 2);
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _QuickAction({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textDark, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Map<String, dynamic> project;
  const _ProjectCard({required this.project});

  Color get _statusColor {
    switch (project['statusCode']) {
      case 1: return Colors.blue;
      case 2: return Colors.orange;
      case 3: return Colors.purple;
      case 4: return Colors.green;
      default: return AppColors.textGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(project['title'], style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, fontSize: 14))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(project['status'], style: GoogleFonts.poppins(
                  fontSize: 10, color: _statusColor, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.category_outlined, size: 14, color: AppColors.textGrey),
              const SizedBox(width: 4),
              Text(project['type'], style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey)),
              const SizedBox(width: 16),
              Icon(Icons.attach_money, size: 14, color: AppColors.textGrey),
              Text('\$${NumberFormat('#,###').format(project['amount'])} USD',
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey)),
            ],
          ),
          if (project['statusCode'] >= 3) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Score IA global : ', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey)),
                Text('${project['aiScore']}/100', style: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(project['aiRecommendation'], style: GoogleFonts.poppins(
                    fontSize: 10, color: Colors.green, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final bool showDivider;
  const _TransactionTile({required this.transaction, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction['type'] == 'credit';
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: (isCredit ? Colors.green : AppColors.primary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                  color: isCredit ? Colors.green : AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transaction['description'], style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(transaction['date'], style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textGrey)),
                  ],
                ),
              ),
              Text(
                '${isCredit ? '+' : '-'}\$${NumberFormat('#,##0.00').format(transaction['amount'])}',
                style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w700,
                  color: isCredit ? Colors.green : AppColors.textDark),
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, indent: 72),
      ],
    );
  }
}
