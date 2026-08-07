import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';
import '../../../data/models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final data = await ApiService.instance.me();
      if (!mounted) return;
      setState(() {
        _user = UserModel.fromJson(data);
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() { _error = e.message; _isLoading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _error = 'Impossible de charger votre profil.'; _isLoading = false; });
    }
  }

  Future<void> _logout() async {
    await ApiService.instance.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', false);
    if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_error != null || _user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 40),
                const SizedBox(height: 12),
                Text(_error ?? 'Erreur', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                OutlinedButton(onPressed: _loadUser, child: const Text('Réessayer')),
              ],
            ),
          ),
        ),
      );
    }

    final user = _user!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _loadUser,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              backgroundColor: AppColors.primary,
              toolbarHeight: 64,
              title: const Text('Profil',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Avatar + name
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.grey200),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 80, height: 80,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryDark],
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Center(
                              child: Text(user.initials,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(user.fullName,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(user.email,
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                          const SizedBox(height: 12),
                          // KYC badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.shield, size: 16, color: AppColors.warning),
                                const SizedBox(width: 6),
                                Text(
                                  'KYC: ${user.kycLevelLabel}',
                                  style: const TextStyle(
                                    color: AppColors.warning,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Upgrade KYC banner
                    if (user.kycLevel != KycLevel.advanced) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lock_outline, color: AppColors.primary, size: 28),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Améliorez votre KYC',
                                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                  SizedBox(height: 2),
                                  Text(
                                    'Débloquez des limites plus élevées',
                                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () => Navigator.pushNamed(context, AppRoutes.kyc),
                              child: const Icon(Icons.chevron_right, color: AppColors.grey500),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Menu items
                    _MenuSection(title: 'Compte', items: [
                      _MenuItem(icon: Icons.person_outline, label: 'Informations personnelles', onTap: () => Navigator.pushNamed(context, AppRoutes.profile)),
                      _MenuItem(icon: Icons.badge_outlined, label: 'KYC & Documents', onTap: () => Navigator.pushNamed(context, AppRoutes.kyc)),
                      _MenuItem(icon: Icons.lock_outline, label: 'Sécurité & PIN', onTap: () {}),
                      _MenuItem(icon: Icons.language, label: 'Langue', trailing: 'Français', onTap: () {}),
                    ]),
                    const SizedBox(height: 16),

                    _MenuSection(title: 'Banque', items: [
                      _MenuItem(icon: Icons.account_balance_outlined, label: 'Mes comptes', onTap: () => Navigator.pushNamed(context, AppRoutes.accounts)),
                      _MenuItem(icon: Icons.receipt_long_outlined, label: 'Transferts', onTap: () => Navigator.pushNamed(context, AppRoutes.transfer)),
                      _MenuItem(icon: Icons.swap_horiz, label: 'Bénéficiaires', onTap: () => Navigator.pushNamed(context, AppRoutes.transfer)),
                      _MenuItem(icon: Icons.support_agent, label: 'Support client (Chat IA)', onTap: () => Navigator.pushNamed(context, AppRoutes.chat)),
                    ]),
                    const SizedBox(height: 16),

                    _MenuSection(title: 'Préférences', items: [
                      _MenuItem(icon: Icons.notifications_outlined, label: 'Notifications', onTap: () {}),
                      _MenuItem(icon: Icons.dark_mode_outlined, label: 'Thème', trailing: 'Clair', onTap: () {}),
                      _MenuItem(icon: Icons.info_outline, label: 'À propos', trailing: 'v${AppConstants.version}', onTap: () {}),
                    ]),
                    const SizedBox(height: 24),

                    // Admin Back-Office access
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, '/admin'),
                        icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
                        label: const Text('Accéder au Back-Office',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1a1a2e),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Logout
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout, color: AppColors.error),
                        label: const Text('Se déconnecter',
                            style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.error),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'RawBank — MyRawApp v${AppConstants.version}\n© 2026 RawBank RDC',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.grey500, fontSize: 12),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;
  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title,
              style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.grey200),
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                items[i],
                if (i < items.length - 1)
                  const Divider(height: 1, indent: 56),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback? onTap;
  const _MenuItem({required this.icon, required this.label, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.grey700),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            ),
            if (trailing != null)
              Text(trailing!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 20, color: AppColors.grey500),
          ],
        ),
      ),
    );
  }
}
