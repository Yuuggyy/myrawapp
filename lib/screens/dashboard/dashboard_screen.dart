import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../data/mock_data.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##0.00', 'fr_FR');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : AppColors.lightBg;
    final card = isDark ? AppColors.darkCard : AppColors.lightCard;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final divider = isDark ? AppColors.darkDivider : AppColors.lightDivider;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final unread = MockNotifications.notifications.where((n) => n['isRead'] == false).length;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: bg,
            elevation: 0,
            automaticallyImplyLeading: false,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: bg,
                padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 56, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Bonjour 👋', style: GoogleFonts.poppins(
                            color: textSecondary, fontSize: 13)),
                          Text('Jean-Philippe', style: GoogleFonts.poppins(
                            color: textPrimary, fontSize: 20, fontWeight: FontWeight.w700)),
                        ]),
                        Row(children: [
                          _IconBtn(icon: Icons.notifications_outlined, badge: unread, isDark: isDark),
                          const SizedBox(width: 8),
                          _IconBtn(icon: Icons.qr_code_scanner_outlined, isDark: isDark),
                        ]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            title: Text('Accueil', style: GoogleFonts.poppins(
              color: textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Balance card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Solde IllicoCash', style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.85), fontSize: 13)),
                        const SizedBox(height: 8),
                        Text('\$${fmt.format(2450.75)}', style: GoogleFonts.poppins(
                          color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 6),
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('+2.4% ce mois', style: GoogleFonts.poppins(
                              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                          ),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quick actions
                  Row(children: [
                    _QuickAction(icon: Icons.send_rounded, label: 'Envoyer', isDark: isDark),
                    const SizedBox(width: 10),
                    _QuickAction(icon: Icons.add_rounded, label: 'Recharger', isDark: isDark),
                    const SizedBox(width: 10),
                    _QuickAction(icon: Icons.receipt_long_rounded, label: 'Payer', isDark: isDark),
                    const SizedBox(width: 10),
                    _QuickAction(icon: Icons.more_horiz_rounded, label: 'Plus', isDark: isDark),
                  ]),
                  const SizedBox(height: 24),

                  // Projets
                  _SectionHeader(title: 'Mes projets', textPrimary: textPrimary),
                  const SizedBox(height: 10),
                  ...MockProjects.projects.take(2).map((p) => _ProjectCard(
                    project: p, card: card, divider: divider,
                    textPrimary: textPrimary, textSecondary: textSecondary)),
                  const SizedBox(height: 24),

                  // Transactions
                  _SectionHeader(title: 'Transactions récentes', textPrimary: textPrimary),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: divider, width: 0.5),
                    ),
                    child: Column(
                      children: MockTransactions.transactions.take(4).toList().asMap().entries.map((e) {
                        return _TxTile(tx: e.value, showDivider: e.key < 3,
                          card: card, divider: divider,
                          textPrimary: textPrimary, textSecondary: textSecondary);
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final int badge;
  final bool isDark;
  const _IconBtn({required this.icon, this.badge = 0, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
      ),
      if (badge > 0) Positioned(top: 2, right: 2,
        child: Container(
          width: 14, height: 14,
          decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
          child: Center(child: Text('$badge', style: GoogleFonts.poppins(
            fontSize: 8, color: Colors.white, fontWeight: FontWeight.w700))),
        )),
    ]);
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  const _QuickAction({required this.icon, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Column(children: [
      Container(
        height: 52,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(icon, color: AppColors.gold, size: 22),
      ),
      const SizedBox(height: 6),
      Text(label, style: GoogleFonts.poppins(fontSize: 11,
        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
    ]));
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color textPrimary;
  const _SectionHeader({required this.title, required this.textPrimary});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title, style: GoogleFonts.poppins(
        fontSize: 15, fontWeight: FontWeight.w700, color: textPrimary)),
      TextButton(onPressed: () {},
        child: Text('Voir tout', style: GoogleFonts.poppins(
          color: AppColors.gold, fontSize: 12))),
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
      case 1: return const Color(0xFF4285F4);
      case 2: return AppColors.warning;
      case 3: return const Color(0xFF9C27B0);
      case 4: return AppColors.success;
      default: return AppColors.darkTextSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: divider, width: 0.5),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(project['title'], style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600, fontSize: 14, color: textPrimary))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(project['status'], style: GoogleFonts.poppins(
              fontSize: 10, color: _statusColor, fontWeight: FontWeight.w600)),
          ),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          Text(project['type'], style: GoogleFonts.poppins(fontSize: 12, color: textSecondary)),
          const SizedBox(width: 8),
          Text('·', style: TextStyle(color: textSecondary)),
          const SizedBox(width: 8),
          Text('\$${NumberFormat('#,###').format(project['amount'])} USD',
            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w600)),
        ]),
      ]),
    );
  }
}

class _TxTile extends StatelessWidget {
  final Map<String, dynamic> tx;
  final bool showDivider;
  final Color card, divider, textPrimary, textSecondary;
  const _TxTile({required this.tx, required this.showDivider, required this.card,
    required this.divider, required this.textPrimary, required this.textSecondary});

  @override
  Widget build(BuildContext context) {
    final isCredit = tx['type'] == 'credit';
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: (isCredit ? AppColors.success : AppColors.error).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCredit ? Icons.south_west_rounded : Icons.north_east_rounded,
              color: isCredit ? AppColors.success : AppColors.error, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(tx['description'], style: GoogleFonts.poppins(
              fontSize: 13, fontWeight: FontWeight.w500, color: textPrimary),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(tx['date'], style: GoogleFonts.poppins(fontSize: 11, color: textSecondary)),
          ])),
          Text(
            '${isCredit ? '+' : '-'}\$${NumberFormat('#,##0.00').format(tx['amount'])}',
            style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700,
              color: isCredit ? AppColors.success : textPrimary)),
        ]),
      ),
      if (showDivider) Divider(height: 1, indent: 68, endIndent: 0, color: divider),
    ]);
  }
}
