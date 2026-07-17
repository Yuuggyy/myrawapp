import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/user_model.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  KycLevel _currentLevel = KycLevel.standard;

  final List<_KycStep> _steps = [
    _KycStep(
      level: KycLevel.basic,
      title: 'KYC Basique',
      description: 'Email + téléphone vérifiés',
      icon: Icons.email_outlined,
      features: ['Accès IllicoCash', 'Transferts jusqu\'à \$500/mois', 'Chat IA'],
      isCompleted: true,
    ),
    _KycStep(
      level: KycLevel.standard,
      title: 'KYC Standard',
      description: 'Pièce d\'identité vérifiée',
      icon: Icons.badge_outlined,
      features: ['Projets jusqu\'à \$20,000', 'Transferts jusqu\'à \$5,000/mois', 'Ouverture compte perso'],
      isCompleted: true,
      isCurrent: true,
    ),
    _KycStep(
      level: KycLevel.advanced,
      title: 'KYC Avancé',
      description: 'Biométrie + documents avancés',
      icon: Icons.fingerprint,
      features: ['Projets illimités', 'Compte entreprise', 'Toutes les fonctionnalités'],
      isCompleted: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Vérification KYC'),
        backgroundColor: AppColors.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFCC0000), Color(0xFF880000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.verified_user, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('KYC Standard',
                          style: TextStyle(
                            color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                        SizedBox(height: 4),
                        Text('Votre identité est vérifiée',
                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Actif',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            const Text('Niveaux de vérification',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),

            ..._steps.map((step) => _KycLevelCard(step: step)),

            const SizedBox(height: 28),

            // Upgrade CTA
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.upgrade, color: AppColors.primary),
                      const SizedBox(width: 8),
                      const Text('Passer au KYC Avancé',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Pour déposer des projets supérieurs à \$20,000 et ouvrir un compte entreprise, vous devez compléter votre vérification avancée.',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  _UpgradeStep(step: 1, label: 'Scan biométrique (liveness check)', isDone: false),
                  _UpgradeStep(step: 2, label: 'Vérification email OTP', isDone: true),
                  _UpgradeStep(step: 3, label: 'Documents entreprise (si applicable)', isDone: false),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Démarrer la vérification'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _KycStep {
  final KycLevel level;
  final String title;
  final String description;
  final IconData icon;
  final List<String> features;
  final bool isCompleted;
  final bool isCurrent;

  _KycStep({
    required this.level,
    required this.title,
    required this.description,
    required this.icon,
    required this.features,
    required this.isCompleted,
    this.isCurrent = false,
  });
}

class _KycLevelCard extends StatelessWidget {
  final _KycStep step;
  const _KycLevelCard({required this.step});

  @override
  Widget build(BuildContext context) {
    final color = step.isCompleted ? AppColors.success
        : step.isCurrent ? AppColors.primary
        : AppColors.grey400;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: step.isCurrent ? AppColors.primary : AppColors.grey200,
          width: step.isCurrent ? 2 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              step.isCompleted ? Icons.check_circle : step.icon,
              color: color, size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(step.title,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    const Spacer(),
                    if (step.isCurrent)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('Actuel',
                          style: TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(step.description,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 8),
                ...step.features.map((f) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    children: [
                      Icon(Icons.check, size: 13, color: color),
                      const SizedBox(width: 6),
                      Text(f, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UpgradeStep extends StatelessWidget {
  final int step;
  final String label;
  final bool isDone;

  const _UpgradeStep({required this.step, required this.label, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 24, height: 24,
            decoration: BoxDecoration(
              color: isDone ? AppColors.success : AppColors.grey200,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isDone
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : Text('$step', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(
            fontSize: 13,
            color: isDone ? AppColors.success : AppColors.textPrimary,
            decoration: isDone ? TextDecoration.lineThrough : null,
          )),
        ],
      ),
    );
  }
}
