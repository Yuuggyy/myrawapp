import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../data/mock_data.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : AppColors.lightBg;
    final card = isDark ? AppColors.darkCard : AppColors.lightCard;
    final cardAlt = isDark ? AppColors.darkCardAlt : AppColors.lightCardAlt;
    final divider = isDark ? AppColors.darkDivider : AppColors.lightDivider;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final fmt = NumberFormat('#,##0.00', 'fr_FR');
    final unread = MockNotifications.notifications.where((n) => n['isRead'] == false).length;
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          // Header fixe
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.fromLTRB(20, top + 20, 20, 0),
              color: bg,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Bonjour 👋', style: GoogleFonts.poppins(
                      color: textSecondary, fontSize: 13, fontWeight: FontWeight.w400)),
                    Text('Jean-Philippe', style: GoogleFonts.poppins(
                      color: textPrimary, fontSize: 22, fontWeight: FontWeight.w800)),
                  ]),
                  Row(children: [
                    _TopBtn(icon: Icons.notifications_outlined,
                      badge: unread, isDark: isDark),
                    const SizedBox(width: 10),
                    _TopBtn(icon: Icons.qr_code_scanner_rounded, isDark: isDark),
                  ]),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Balance card dorée
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('IllicoCash', style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.85), fontSize: 13, fontWeight: FontWeight.w500)),
                    Icon(Icons.account_balance_wallet_rounded,
                      color: Colors.white.withOpacity(0.7), size: 20),
                  ]),
                  const SizedBox(height: 14),
                  Text('\$${fmt.format(2450.75)}', style: GoogleFonts.poppins(
                    color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800,
                    letterSpacing: -0.5)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20)),
                      child: Row(children: [
                        const Icon(Icons.trending_up_rounded, color: Colors.white, size: 13),
                        const SizedBox(width: 4),
                        Text('+2.4%', style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                    const SizedBox(width: 10),
                    Text('ce mois', style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.7), fontSize: 12)),
                  ]),
                ]),
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 28)),

          // Quick Actions — plus grandes, plus d'air
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Actions rapides', style: GoogleFonts.poppins(
                  color: textSecondary, fontSize: 12, fontWeight: FontWeight.w600,
                  letterSpacing: 0.5)),
                const SizedBox(height: 14),
                Row(children: [
                  _QuickAction(icon: Icons.send_rounded, label: 'Envoyer',
                    color: const Color(0xFF007AFF), isDark: isDark),
                  const SizedBox(width: 12),
                  _QuickAction(icon: Icons.add_rounded, label: 'Recharger',
                    color: const Color(0xFF34C759), isDark: isDark),
                  const SizedBox(width: 12),
                  _QuickAction(icon: Icons.receipt_long_rounded, label: 'Payer',
                    color: AppColors.gold, isDark: isDark),
                  const SizedBox(width: 12),
                  _QuickAction(icon: Icons.apps_rounded, label: 'Plus',
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    isDark: isDark),
                ]),
              ]),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 28)),

          // Alerte KYC
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(isDark ? 0.12 : 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.warning.withOpacity(0.25)),
                ),
                child: Row(children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.15),
                      shape: BoxShape.circle),
                    child: const Icon(Icons.warning_amber_rounded,
                      color: AppColors.warning, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('KYC Standard requis', style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.warning)),
                    Text('Complétez pour accéder à tous les services',
                      style: GoogleFonts.poppins(fontSize: 12, color: textSecondary)),
                  ])),
                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: textSecondary),
                ]),
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 28)),

          // Projets
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SectionHeader('Mes projets', textPrimary),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: _ProjectCard(project: MockProjects.projects[i],
                  card: card, divider: divider,
                  textPrimary: textPrimary, textSecondary: textSecondary)),
              childCount: MockProjects.projects.length < 2 ? MockProjects.projects.length : 2,
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 28)),

          // Transactions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _SectionHeader('Transactions récentes', textPrimary),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: divider, width: 0.5),
                ),
                child: Column(
                  children: MockTransactions.transactions.take(4).toList().asMap().entries.map((e) =>
                    _TxTile(tx: e.value, showDivider: e.key < 3,
                      divider: divider, textPrimary: textPrimary, textSecondary: textSecondary)
                  ).toList(),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}

class _TopBtn extends StatelessWidget {
  final IconData icon;
  final int badge;
  final bool isDark;
  const _TopBtn({required this.icon, this.badge = 0, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            width: 0.5),
        ),
        child: Icon(icon, size: 21,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
      ),
      if (badge > 0) Positioned(top: 4, right: 4,
        child: Container(
          width: 15, height: 15,
          decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
          child: Center(child: Text('$badge',
            style: GoogleFonts.poppins(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w800))))),
    ]);
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  const _QuickAction({required this.icon, required this.label,
    required this.color, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Column(children: [
      Container(
        height: 64,
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.15 : 0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.2), width: 0.5),
        ),
        child: Center(child: Icon(icon, color: color, size: 26)),
      ),
      const SizedBox(height: 8),
      Text(label, style: GoogleFonts.poppins(
        fontSize: 12, fontWeight: FontWeight.w500,
        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
    ]));
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color textPrimary;
  const _SectionHeader(this.title, this.textPrimary);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: GoogleFonts.poppins(
        fontSize: 16, fontWeight: FontWeight.w700, color: textPrimary)),
      TextButton(onPressed: () {},
        style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero),
        child: Text('Voir tout', style: GoogleFonts.poppins(
          color: AppColors.gold, fontSize: 13, fontWeight: FontWeight.w600))),
    ]);
  }
}

class _ProjectCard extends StatelessWidget {
  final Map<String, dynamic> project;
  final Color card, divider, textPrimary, textSecondary;
  const _ProjectCard({required this.project, required this.card,
    required this.divider, required this.textPrimary, required this.textSecondary});

  Color get _statusColor {
    switch (project['statusCode']) {
      case 1: return const Color(0xFF007AFF);
      case 2: return AppColors.warning;
      case 3: return const Color(0xFFAF52DE);
      case 4: return AppColors.success;
      default: return AppColors.darkTextSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: divider, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(project['title'] as String, style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700, fontSize: 14, color: textPrimary))),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20)),
            child: Text(project['status'] as String, style: GoogleFonts.poppins(
              fontSize: 11, color: _statusColor, fontWeight: FontWeight.w700))),
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Icon(Icons.category_outlined, size: 13, color: textSecondary),
          const SizedBox(width: 4),
          Text(project['type'] as String, style: GoogleFonts.poppins(
            fontSize: 12, color: textSecondary)),
          const SizedBox(width: 12),
          Icon(Icons.attach_money_rounded, size: 13, color: AppColors.gold),
          Text('${NumberFormat('#,###').format(project['amount'])} USD',
            style: GoogleFonts.poppins(fontSize: 12,
              color: AppColors.gold, fontWeight: FontWeight.w600)),
        ]),
        if ((project['aiScore'] as int) > 0) ...[
          const SizedBox(height: 12),
          ClipRRect(borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (project['aiScore'] as int) / 100,
              backgroundColor: AppColors.gold.withOpacity(0.12),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
              minHeight: 5)),
          const SizedBox(height: 6),
          Row(children: [
            const Icon(Icons.psychology_rounded, size: 13, color: AppColors.gold),
            const SizedBox(width: 4),
            Text('Score IA ${project['aiScore']}/100 · ${project['aiRecommendation']}',
              style: GoogleFonts.poppins(fontSize: 11, color: textSecondary)),
          ]),
        ],
      ]),
    );
  }
}

class _TxTile extends StatelessWidget {
  final Map<String, dynamic> tx;
  final bool showDivider;
  final Color divider, textPrimary, textSecondary;
  const _TxTile({required this.tx, required this.showDivider,
    required this.divider, required this.textPrimary, required this.textSecondary});

  @override
  Widget build(BuildContext context) {
    final isCredit = tx['type'] == 'credit';
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: (isCredit ? AppColors.success : AppColors.error).withOpacity(0.1),
              borderRadius: BorderRadius.circular(13)),
            child: Icon(
              isCredit ? Icons.south_west_rounded : Icons.north_east_rounded,
              color: isCredit ? AppColors.success : AppColors.error, size: 19),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tx['description'] as String, style: GoogleFonts.poppins(
              fontSize: 14, fontWeight: FontWeight.w500, color: textPrimary),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(tx['date'] as String, style: GoogleFonts.poppins(
              fontSize: 12, color: textSecondary)),
          ])),
          Text(
            '${isCredit ? '+' : '-'}\$${NumberFormat('#,##0.00').format(tx['amount'])}',
            style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700,
              color: isCredit ? AppColors.success : textPrimary)),
        ]),
      ),
      if (showDivider) Divider(height: 1, indent: 74, endIndent: 0, color: divider),
    ]);
  }
}
