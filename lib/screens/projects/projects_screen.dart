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

class _ProjectsScreenState extends State<ProjectsScreen> {
  String _filter = 'Tous';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes Projets'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => _showNewProjectSheet(context)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Filtres
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Tous', 'En cours', 'Terminés', 'Lady\'s First'].map((f) =>
                GestureDetector(
                  onTap: () => setState(() => _filter = f),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _filter == f ? AppColors.primary : AppColors.cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _filter == f ? AppColors.primary : AppColors.divider),
                    ),
                    child: Text(f, style: GoogleFonts.poppins(
                      fontSize: 13, color: _filter == f ? Colors.white : AppColors.textGrey,
                      fontWeight: _filter == f ? FontWeight.w600 : FontWeight.w400)),
                  ),
                ),
              ).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Nouveau dossier CTA
          GestureDetector(
            onTap: () => _showNewProjectSheet(context),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.add, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Déposer un nouveau dossier', style: GoogleFonts.poppins(
                        color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                      Text('PME, Agriculture, Lady\'s First...', style: GoogleFonts.poppins(
                        color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text('Dossiers actifs (${MockProjects.projects.length})',
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),

          ...MockProjects.projects.map((p) => _ProjectDetailCard(project: p)),
        ],
      ),
    );
  }

  void _showNewProjectSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _NewProjectSheet(),
    );
  }
}

class _ProjectDetailCard extends StatelessWidget {
  final Map<String, dynamic> project;
  const _ProjectDetailCard({required this.project});

  Color get _statusColor {
    switch (project['statusCode']) {
      case 1: return Colors.blue;
      case 2: return Colors.orange;
      case 3: return Colors.purple;
      case 4: return Colors.green;
      default: return AppColors.textGrey;
    }
  }

  IconData get _statusIcon {
    switch (project['statusCode']) {
      case 1: return Icons.upload_file_rounded;
      case 2: return Icons.psychology_rounded;
      case 3: return Icons.how_to_reg_rounded;
      case 4: return Icons.check_circle_rounded;
      default: return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_statusIcon, color: _statusColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(project['title'], style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700, fontSize: 15)),
                          Text('${project['type']} · ${project['sector']}',
                            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(project['status'], style: GoogleFonts.poppins(
                        fontSize: 10, color: _statusColor, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _InfoChip(label: 'Montant', value: '\$${NumberFormat('#,###').format(project['amount'])}'),
                    _InfoChip(label: 'Date', value: project['createdDate']),
                    if (project['aiScore'] > 0)
                      _InfoChip(label: 'Score IA', value: '${project['aiScore']}/100', isScore: true),
                  ],
                ),
                if (project['aiScore'] > 0) ...[
                  const SizedBox(height: 16),
                  Text('Analyse IA', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textGrey)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _ScoreBar(label: 'RSE', score: project['rseScore']),
                      const SizedBox(width: 8),
                      _ScoreBar(label: 'Conf.', score: project['complianceScore']),
                      const SizedBox(width: 8),
                      _ScoreBar(label: 'Com.', score: project['commercialScore']),
                      const SizedBox(width: 8),
                      _ScoreBar(label: 'Compta', score: project['accountingScore']),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(project['step'], style: GoogleFonts.poppins(
                    fontSize: 12, color: AppColors.textGrey, fontStyle: FontStyle.italic)),
                ),
              ],
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.divider)),
            ),
            child: Row(
              children: [
                Expanded(child: TextButton.icon(
                  icon: const Icon(Icons.chat_bubble_outline, size: 16),
                  label: Text('Chat IA', style: GoogleFonts.poppins(fontSize: 13)),
                  onPressed: () {},
                  style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                )),
                Container(width: 1, height: 40, color: AppColors.divider),
                Expanded(child: TextButton.icon(
                  icon: const Icon(Icons.upload_file_outlined, size: 16),
                  label: Text('Documents', style: GoogleFonts.poppins(fontSize: 13)),
                  onPressed: () {},
                  style: TextButton.styleFrom(foregroundColor: AppColors.textGrey),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final bool isScore;
  const _InfoChip({required this.label, required this.value, this.isScore = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textLight)),
        Text(value, style: GoogleFonts.poppins(
          fontSize: 13, fontWeight: FontWeight.w600,
          color: isScore ? AppColors.primary : AppColors.textDark)),
      ],
    );
  }
}

class _ScoreBar extends StatelessWidget {
  final String label;
  final int score;
  const _ScoreBar({required this.label, required this.score});

  Color get _color {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(label, style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textGrey)),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: score / 100,
            backgroundColor: AppColors.divider,
            color: _color,
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 2),
          Text('$score', style: GoogleFonts.poppins(fontSize: 10, color: _color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _NewProjectSheet extends StatefulWidget {
  const _NewProjectSheet();

  @override
  State<_NewProjectSheet> createState() => _NewProjectSheetState();
}

class _NewProjectSheetState extends State<_NewProjectSheet> {
  String _selectedType = 'PME';
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text('Nouveau dossier', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          TextField(controller: _titleController,
            decoration: const InputDecoration(labelText: 'Titre du projet', prefixIcon: Icon(Icons.business_outlined))),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedType,
            decoration: InputDecoration(
              labelText: 'Type de projet',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              prefixIcon: const Icon(Icons.category_outlined),
            ),
            items: ['PME', 'Agriculture', 'Immobilier', "Lady's First", 'Exportation']
              .map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => setState(() => _selectedType = v!),
          ),
          const SizedBox(height: 16),
          TextField(controller: _amountController, keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Montant recherché (USD)', prefixIcon: Icon(Icons.attach_money))),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Déposer le dossier'),
          ),
        ],
      ),
    );
  }
}
