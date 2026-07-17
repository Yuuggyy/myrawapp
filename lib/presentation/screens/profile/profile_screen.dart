import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/user_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  final UserModel _user = const UserModel(
    id: '1',
    email: 'jean.mutombo@rawbank.cd',
    phone: '+243810000001',
    fullName: 'Jean Mutombo',
    kycLevel: KycLevel.standard,
    createdAt: null,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
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
                          child: const Center(
                            child: Text('JM',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(_user.fullName,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(_user.email,
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
                                'KYC: ${_kycLabel(_user.kycLevel)}',
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
                  if (_user.kycLevel != KycLevel.advanced) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.lock_outline, color: AppColors.primary, size: 28),
                          SizedBox(width: 14),
                          Expanded(
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
                          Icon(Icons.chevron_right, color: AppColors.grey500),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Menu items
                  _MenuSection(title: 'Compte', items: const [
                    _MenuItem(icon: Icons.person_outline, label: 'Informations personnelles'),
                    _MenuItem(icon: Icons.badge_outlined, label: 'Pièces d\'identité'),
                    _MenuItem(icon: Icons.lock_outline, label: 'Sécurité & PIN'),
                    _MenuItem(icon: Icons.language, label: 'Langue', trailing: 'Français'),
                  ]),
                  const SizedBox(height: 16),

                  _MenuSection(title: 'Banque', items: const [
                    _MenuItem(icon: Icons.account_balance_outlined, label: 'Mes comptes'),
                    _MenuItem(icon: Icons.receipt_long_outlined, label: 'Relevés bancaires'),
                    _MenuItem(icon: Icons.swap_horiz, label: 'Bénéficiaires'),
                    _MenuItem(icon: Icons.support_agent, label: 'Support client'),
                  ]),
                  const SizedBox(height: 16),

                  _MenuSection(title: 'Préférences', items: const [
                    _MenuItem(icon: Icons.notifications_outlined, label: 'Notifications'),
                    _MenuItem(icon: Icons.dark_mode_outlined, label: 'Thème', trailing: 'Clair'),
                    _MenuItem(icon: Icons.info_outline, label: 'À propos', trailing: 'v${AppConstants.version}'),
                  ]),
                  const SizedBox(height: 24),

                  // Logout
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('is_logged_in', false);
                        if (context.mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
                      },
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
                    'MyRawApp v${AppConstants.version}\n© 2026 RawBank RDC',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.grey500, fontSize: 12),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _kycLabel(KycLevel level) {
    switch (level) {
      case KycLevel.none:
        return 'Non vérifié';
      case KycLevel.basic:
        return 'Basique';
      case KycLevel.standard:
        return 'Standard';
      case KycLevel.advanced:
        return 'Avancé';
    }
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
  const _MenuItem({required this.icon, required this.label, this.trailing});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
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
              Text(trailing!, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 20, color: AppColors.grey500),
          ],
        ),
      ),
    );
  }
}
