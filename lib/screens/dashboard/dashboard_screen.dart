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
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.black, Color(0xFF1A1200)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Bonjour 👋', style: GoogleFonts.poppins(
                            color: AppColors.textGrey, fontSize: 13)),
                          Text('Jean-Philippe', style: GoogleFonts.poppins(
                            color: AppColors.textWhite, fontSize: 20, fontWeight: FontWeight.w700)),
                        ],
                      ),
                      Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                width: 42, height: 42,
                                decoration: BoxDecoration(
                                  color: AppColors.blackSurface, shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.divider)),
                                child: const Icon(Icons.notifications_outlined,
                                  color: AppColors.textGrey, size: 20),
                              ),
                              if (unreadCount > 0)
                                Positioned(
                                  top: 4, right: 4,
                                  child: Container(
                                    width: 16, height: 16,
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary, shape: BoxShape.circle),
                                    child: Center(child: Text('$unreadCount',
                                      style: GoogleFonts.poppins(fontSize: 9,
                                        color: AppColors.black, fontWeight: FontWeight.w700))),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.blackSurface, shape: BoxShape.circle,
                              border: Border.all(color: AppColors.divider)),
                            child: const Icon(Icons.qr_code_scanner,
                              color: AppColors.textGrey, size: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  // Solde
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withOpacity(0.12),
                          AppColors.primaryDark.withOpacity(0.06),
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.account_balance_wallet_outlined,
                              color: AppColors.primary, size: 16),
                            const SizedBox(width: 6),
                            Text('Solde IllicoCash',
                              style: GoogleFonts.poppins(color: AppColors.textGrey, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('\$${formatter.format(2450.75)}',
                              style: GoogleFonts.poppins(
                                color: AppColors.textGold, fontSize: 34, fontWeight: FontWeight.w800)),
                            const SizedBox(width: 10),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                                ),
                                child: Text('+2.4%', style: GoogleFonts.poppins(
                                  color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('Mis à jour il y a 2 min',
                          style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textLight)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Actions rapides
                  Row(
                    children: [
                      _QuickAction(icon: Icons.send_rounded, label: 'Envoyer', color: AppColors.primary),
                      const SizedBox(width: 10),
                      _QuickAction(icon: Icons.add_rounded, label: 'Recharger', color: const Color(0xFF1E88E5)),
                      const SizedBox(width: 10),
                      _QuickAction(icon: Icons.receipt_long_rounded, label: 'Payer', color: const Color(0xFF43A047)),
                      const SizedBox(width: 10),
                      _QuickAction(icon: Icons.more_horiz_rounded, label: 'Plus', color: AppColors.textGrey),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // KYC Alert
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.warning.withOpacity(0.25)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.15), shape: BoxShape.circle),
                          child: const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('KYC Standard requis',
                                style: GoogleFonts.poppins(fontSize: 12,
                                  fontWeight: FontWeight.w600, color: AppColors.warning)),
                              Text('Complétez la vérification pour accéder à tous les services',
                                style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textGrey)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textGrey),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Projets
                  _SectionHeader(title: 'Mes projets', onSeeAll: () {}),
                  const SizedBox(height: 10),
                  ...MockProjects.projects.take(2).map((p) => _ProjectCard(project: p)),
                  const SizedBox(height: 24),

                  // Transactions
                  _SectionHeader(title: 'Transactions récentes', onSeeAll: () {}),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.divider, width: 0.5),
                    ),
                    child: Column(
                      children: MockTransactions.transactions.take(4).toList().asMap().entries.map((e) {
                        final i = e.key; final t = e.value;
                        return _TransactionTile(transaction: t, showDivider: i < 3);
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

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  const _SectionHeader({required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: GoogleFonts.poppins(
          fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textWhite)),
        TextButton(onPressed: onSeeAll,
          child: Text('Voir tout', style: GoogleFonts.poppins(color: AppColors.primary, fontSize: 12))),
      ],
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
            height: 54,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label, style: GoogleFonts.poppins(
            fontSize: 11, color: AppColors.textGrey, fontWeight: FontWeight.w500)),
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
      case 1: return const Color(0xFF42A5F5);
      case 2: return AppColors.warning;
      case 3: return const Color(0xFFAB47BC);
      case 4: return AppColors.success;
      default: return AppColors.textGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(project['title'],
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600,
                  fontSize: 14, color: AppColors.textWhite))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _statusColor.withOpacity(0.3)),
                ),
                child: Text(project['status'], style: GoogleFonts.poppins(
                  fontSize: 10, color: _statusColor, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(project['type'], style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey)),
              const SizedBox(width: 8),
              Container(width: 3, height: 3, decoration: const BoxDecoration(
                color: AppColors.textLight, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Text('\$${NumberFormat('#,###').format(project['amount'])} USD',
                style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGold)),
            ],
          ),
          if (project['aiScore'] > 0) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.psychology_rounded, size: 14, color: AppColors.primary),
                const SizedBox(width: 4),
                Text('Score IA : ', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey)),
                Text('${project['aiScore']}/100', style: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(project['aiRecommendation'], style: GoogleFonts.poppins(
                    fontSize: 10, color: AppColors.success, fontWeight: FontWeight.w600)),
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
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: (isCredit ? AppColors.success : AppColors.primary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                  color: isCredit ? AppColors.success : AppColors.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transaction['description'], style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textWhite),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(transaction['date'], style: GoogleFonts.poppins(
                      fontSize: 11, color: AppColors.textLight)),
                  ],
                ),
              ),
              Text(
                '${isCredit ? '+' : '-'}\$${NumberFormat('#,##0.00').format(transaction['amount'])}',
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700,
                  color: isCredit ? AppColors.success : AppColors.textWhite)),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, indent: 70, color: AppColors.divider),
      ],
    );
  }
}
