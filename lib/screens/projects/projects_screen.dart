import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../data/mock_data.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});
  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  @override
  void initState() { super.initState(); _tabs = TabController(length: 2, vsync: this); }
  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  void _showNewProjectDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String selectedType = 'PME';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20,
            MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Center(child: Container(width: 36, height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text('Nouveau projet', style: GoogleFonts.poppins(
              fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary)),
            const SizedBox(height: 16),
            TextField(controller: titleCtrl,
              style: TextStyle(color: textPrimary),
              decoration: const InputDecoration(labelText: 'Titre du projet')),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedType,
              dropdownColor: card,
              style: TextStyle(color: textPrimary),
              decoration: const InputDecoration(labelText: 'Type de financement'),
              items: ['PME', 'Agriculture', 'Immobilier', 'Lady\'s First', 'RSE']
                .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setS(() => selectedType = v ?? selectedType),
            ),
            const SizedBox(height: 12),
            TextField(controller: amountCtrl, keyboardType: TextInputType.number,
              style: TextStyle(color: textPrimary),
              decoration: const InputDecoration(
                labelText: 'Montant demandé (USD)',
                prefixIcon: Icon(Icons.attach_money_rounded, size: 20))),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () { Navigator.pop(context); },
              child: const Text('Soumettre le dossier')),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : AppColors.lightBg;
    final card = isDark ? AppColors.darkCard : AppColors.lightCard;
    final divider = isDark ? AppColors.darkDivider : AppColors.lightDivider;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        automaticallyImplyLeading: false,
        title: Text('Mes projets', style: GoogleFonts.poppins(
          color: textPrimary, fontWeight: FontWeight.w700)),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.add_rounded, color: AppColors.gold, size: 20),
            label: Text('Nouveau', style: GoogleFonts.poppins(
              color: AppColors.gold, fontWeight: FontWeight.w600, fontSize: 13)),
            onPressed: () => _showNewProjectDialog(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.gold,
          unselectedLabelColor: textSecondary,
          indicatorColor: AppColors.gold,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: divider,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13),
          tabs: const [Tab(text: 'Mes dossiers'), Tab(text: 'Programmes')],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _MyProjects(isDark: isDark, card: card, divider: divider,
            textPrimary: textPrimary, textSecondary: textSecondary),
          _Programs(isDark: isDark, card: card, divider: divider,
            textPrimary: textPrimary, textSecondary: textSecondary),
        ],
      ),
    );
  }
}

class _MyProjects extends StatelessWidget {
  final bool isDark;
  final Color card, divider, textPrimary, textSecondary;
  const _MyProjects({required this.isDark, required this.card,
    required this.divider, required this.textPrimary, required this.textSecondary});

  Color _statusColor(int code) {
    switch (code) {
      case 1: return const Color(0xFF4285F4);
      case 2: return AppColors.warning;
      case 3: return const Color(0xFF9C27B0);
      case 4: return AppColors.success;
      default: return AppColors.darkTextSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: MockProjects.projects.length,
      itemBuilder: (_, i) {
        final p = MockProjects.projects[i];
        final color = _statusColor(p['statusCode'] as int);
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: divider, width: 0.5),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text(p['title'] as String, style: GoogleFonts.poppins(
                fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20)),
                child: Text(p['status'] as String, style: GoogleFonts.poppins(
                  fontSize: 10, color: color, fontWeight: FontWeight.w600))),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Text(p['type'] as String, style: GoogleFonts.poppins(
                fontSize: 12, color: textSecondary)),
              const SizedBox(width: 8),
              Text('·', style: TextStyle(color: textSecondary)),
              const SizedBox(width: 8),
              Text('\$${NumberFormat('#,###').format(p['amount'])} USD',
                style: GoogleFonts.poppins(fontSize: 12,
                  color: AppColors.gold, fontWeight: FontWeight.w600)),
            ]),
            if ((p['aiScore'] as int) > 0) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (p['aiScore'] as int) / 100,
                  backgroundColor: AppColors.gold.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                  minHeight: 4)),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.psychology_rounded, size: 13, color: AppColors.gold),
                const SizedBox(width: 4),
                Text('Score IA : ${p['aiScore']}/100 — ${p['aiRecommendation']}',
                  style: GoogleFonts.poppins(fontSize: 11, color: textSecondary)),
              ]),
            ],
          ]),
        );
      },
    );
  }
}

class _Programs extends StatelessWidget {
  final bool isDark;
  final Color card, divider, textPrimary, textSecondary;
  const _Programs({required this.isDark, required this.card,
    required this.divider, required this.textPrimary, required this.textSecondary});

  @override
  Widget build(BuildContext context) {
    final programs = [
      {'title': 'PME RawBank', 'desc': 'Financement jusqu\'à 500 000 USD pour les petites et moyennes entreprises congolaises.', 'icon': Icons.business_rounded, 'range': '10K – 500K USD'},
      {'title': 'Lady\'s First', 'desc': 'Programme exclusif pour les femmes entrepreneures de la RDC.', 'icon': Icons.people_rounded, 'range': '5K – 100K USD'},
      {'title': 'Agri-Finance', 'desc': 'Soutien à l\'agriculture et à l\'agro-industrie congolaise.', 'icon': Icons.eco_rounded, 'range': '10K – 250K USD'},
      {'title': 'Immo RawBank', 'desc': 'Crédits immobiliers et construction pour particuliers et promoteurs.', 'icon': Icons.home_rounded, 'range': '50K – 1M USD'},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: programs.length,
      itemBuilder: (_, i) {
        final p = programs[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: divider, width: 0.5),
          ),
          child: Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14)),
              child: Icon(p['icon'] as IconData, color: AppColors.gold, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p['title'] as String, style: GoogleFonts.poppins(
                fontSize: 14, fontWeight: FontWeight.w700, color: textPrimary)),
              const SizedBox(height: 2),
              Text(p['desc'] as String, style: GoogleFonts.poppins(
                fontSize: 12, color: textSecondary, height: 1.4)),
              const SizedBox(height: 6),
              Text(p['range'] as String, style: GoogleFonts.poppins(
                fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w600)),
            ])),
            const Icon(Icons.chevron_right_rounded, color: AppColors.gold, size: 20),
          ]),
        );
      },
    );
  }
}
