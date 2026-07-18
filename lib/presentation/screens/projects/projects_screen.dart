import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';
import '../../../data/models/project_model.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'Tous';
  bool _loading = true;

  final List<String> _filters = ['Tous', 'En cours', 'Approuvés', 'Rejetés'];

  List<ProjectModel> _projects = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      final raw = await ApiService.instance.getProjects();
      final projects = raw.map((p) => ProjectModel.fromJson(p)).toList();
      if (mounted) setState(() { _projects = projects; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _statusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.approved: return AppColors.success;
      case ProjectStatus.rejected: return AppColors.error;
      case ProjectStatus.aiReview:
      case ProjectStatus.analyzing: return AppColors.aiRouter;
      case ProjectStatus.humanReview: return AppColors.info;
      case ProjectStatus.pendingInfo: return AppColors.warning;
      default: return AppColors.grey500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes Projets'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((f) {
                  final isSelected = _selectedFilter == f;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(f),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedFilter = f),
                      selectedColor: AppColors.primary.withValues(alpha: 0.15),
                      checkmarkColor: AppColors.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Projects List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _projects.isEmpty
                    ? RefreshIndicator(
                        onRefresh: _loadProjects,
                        child: ListView(
                          children: [const SizedBox(height: 120), const _EmptyState()],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadProjects,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _projects.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final project = _projects[i];
                            return _ProjectTile(
                              project: project,
                              statusColor: _statusColor(project.status),
                              onTap: () => Navigator.pushNamed(context, '/projects/${project.id}'),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.newProject),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nouveau projet',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class _ProjectTile extends StatelessWidget {
  final ProjectModel project;
  final Color statusColor;
  final VoidCallback onTap;

  const _ProjectTile({
    required this.project,
    required this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(project.type,
                    style: const TextStyle(
                      color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w600)),
                ),
                const Spacer(),
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: statusColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
                Text(project.statusLabel,
                  style: TextStyle(
                    color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 10),
            Text(project.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(project.sector,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${project.amountRequested.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} USD',
                  style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary)),
                if (project.globalAiScore != null)
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, size: 13, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text('Score IA: ${project.globalAiScore!.toStringAsFixed(0)}/100',
                        style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.warning)),
                    ],
                  ),
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.grey500),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_open_outlined, size: 64, color: AppColors.grey300),
          const SizedBox(height: 16),
          const Text('Aucun projet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.grey500)),
          const SizedBox(height: 8),
          const Text('Déposez votre premier dossier de financement',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.newProject),
            icon: const Icon(Icons.add),
            label: const Text('Créer un projet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
