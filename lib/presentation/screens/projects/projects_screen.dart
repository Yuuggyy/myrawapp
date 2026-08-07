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

class _ProjectsScreenState extends State<ProjectsScreen> {
  String _selectedFilter = 'Tous';
  bool _loading = true;
  bool _isSearching = false;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _filters = ['Tous', 'En cours', 'Approuvés', 'Rejetés'];
  List<ProjectModel> _projects = [];
  List<ProjectModel> _filteredProjects = [];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      final raw = await ApiService.instance.getProjects();
      final projects = raw.map((p) => ProjectModel.fromJson(p)).toList();
      if (mounted) {
        setState(() {
          _projects = projects;
          _filteredProjects = projects;
          _loading = false;
        });
        _applyFilters();
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _applyFilters() {
    List<ProjectModel> result = _projects;

    // Apply status filter
    if (_selectedFilter != 'Tous') {
      result = result.where((p) {
        if (_selectedFilter == 'En cours') return p.status == ProjectStatus.aiReview || p.status == ProjectStatus.analyzing || p.status == ProjectStatus.humanReview || p.status == ProjectStatus.pendingInfo;
        if (_selectedFilter == 'Approuvés') return p.status == ProjectStatus.approved;
        if (_selectedFilter == 'Rejetés') return p.status == ProjectStatus.rejected;
        return true;
      }).toList();
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      result = result.where((p) =>
        p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.sector.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    setState(() => _filteredProjects = result);
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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Rechercher un projet...',
                  hintStyle: TextStyle(color: Colors.white70, fontSize: 16),
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                onChanged: (val) {
                  _searchQuery = val;
                  _applyFilters();
                },
              )
            : const Text('Mes Projets'),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _searchQuery = '';
                  _applyFilters();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
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
                      onSelected: (_) {
                        setState(() => _selectedFilter = f);
                        _applyFilters();
                      },
                      selectedColor: AppColors.primary.withOpacity(0.15),
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
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _filteredProjects.isEmpty
                    ? RefreshIndicator(
                        onRefresh: _loadProjects,
                        child: ListView(
                          children: [const SizedBox(height: 120), _EmptyState(onCreate: () => Navigator.pushNamed(context, AppRoutes.newProject))],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadProjects,
                        child: ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                          itemCount: _filteredProjects.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final project = _filteredProjects[i];
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16, right: 8),
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.newProject),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.secondary,
          icon: const Icon(Icons.add),
          label: const Text('Nouveau projet', style: TextStyle(fontWeight: FontWeight.w700)),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _ProjectTile extends StatelessWidget {
  final ProjectModel project;
  final Color statusColor;
  final VoidCallback onTap;
  const _ProjectTile({required this.project, required this.statusColor, required this.onTap});

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
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
                  child: Text(project.type, style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w600)),
                ),
                const Spacer(),
                Container(width: 8, height: 8, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                const SizedBox(width: 5),
                Text(project.statusLabel, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 10),
            Text(project.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(project.sector, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${project.amountRequested.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} USD',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
                if (project.globalAiScore != null)
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, size: 13, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text('Score IA: ${project.globalAiScore!.toStringAsFixed(0)}/100', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.warning)),
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
  final VoidCallback onCreate;
  const _EmptyState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.folder_open_outlined, size: 64, color: AppColors.grey300),
          const SizedBox(height: 16),
          const Text('Aucun projet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.grey500)),
          const SizedBox(height: 8),
          const Text('Déposez votre premier dossier de financement', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onCreate,
            icon: const Icon(Icons.add),
            label: const Text('Créer un projet'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.secondary),
          ),
        ],
      ),
    );
  }
}
