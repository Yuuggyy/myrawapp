import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/api_service.dart';
import '../../../data/models/user_model.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  bool _loading = true;
  bool _uploading = false;
  KycLevel _kycLevel = KycLevel.none;
  List<Map<String, dynamic>> _documents = [];

  static const _docTypeChoices = [
    'Pièce d\'identité',
    'Justificatif de domicile',
    'Selfie biométrique',
  ];

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    setState(() => _loading = true);
    try {
      final data = await ApiService.instance.getKycStatus();
      if (mounted) {
        setState(() {
          _kycLevel = _parseLevel(data['kyc_level'] as String?);
          _documents = List<Map<String, dynamic>>.from(data['documents'] ?? []);
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  KycLevel _parseLevel(String? level) {
    switch (level) {
      case 'basic': return KycLevel.basic;
      case 'standard': return KycLevel.standard;
      case 'advanced': return KycLevel.advanced;
      default: return KycLevel.none;
    }
  }

  String _levelLabel(KycLevel level) {
    switch (level) {
      case KycLevel.none: return 'Non vérifié';
      case KycLevel.basic: return 'KYC Basique';
      case KycLevel.standard: return 'KYC Standard';
      case KycLevel.advanced: return 'KYC Avancé';
    }
  }

  List<_KycStep> get _steps {
    final levelIndex = _kycLevel.index; // none=0, basic=1, standard=2, advanced=3
    return [
      _KycStep(
        level: KycLevel.basic,
        title: 'KYC Basique',
        description: 'Email + téléphone vérifiés',
        icon: Icons.email_outlined,
        features: const ['Accès IllicoCash', 'Transferts jusqu\'à \$500/mois', 'Chat IA'],
        isCompleted: levelIndex >= KycLevel.basic.index,
        isCurrent: _kycLevel == KycLevel.basic,
      ),
      _KycStep(
        level: KycLevel.standard,
        title: 'KYC Standard',
        description: 'Pièce d\'identité vérifiée',
        icon: Icons.badge_outlined,
        features: const ['Projets jusqu\'à \$20,000', 'Transferts jusqu\'à \$5,000/mois', 'Ouverture compte perso'],
        isCompleted: levelIndex >= KycLevel.standard.index,
        isCurrent: _kycLevel == KycLevel.standard,
      ),
      _KycStep(
        level: KycLevel.advanced,
        title: 'KYC Avancé',
        description: 'Biométrie + documents avancés',
        icon: Icons.fingerprint,
        features: const ['Projets illimités', 'Compte entreprise', 'Toutes les fonctionnalités'],
        isCompleted: levelIndex >= KycLevel.advanced.index,
        isCurrent: _kycLevel == KycLevel.advanced,
      ),
    ];
  }

  bool get _isFullyVerified => _kycLevel == KycLevel.advanced;

  Future<void> _startVerification() async {
    final docType = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Quel document souhaitez-vous soumettre ?',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
            ..._docTypeChoices.map((t) => ListTile(
                  leading: const Icon(Icons.description_outlined, color: AppColors.primary),
                  title: Text(t),
                  onTap: () => Navigator.pop(sheetContext, t),
                )),
          ],
        ),
      ),
    );
    if (docType == null) return;
    if (!mounted) return;

    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined, color: AppColors.primary),
              title: const Text('Prendre une photo'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary),
              title: const Text('Choisir depuis la galerie'),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    try {
      final picked = await ImagePicker().pickImage(source: source, maxWidth: 1200, imageQuality: 80);
      if (picked == null) return;
      setState(() => _uploading = true);
      final bytes = await File(picked.path).readAsBytes();
      final base64Str = base64Encode(bytes);
      final ext = picked.path.split('.').last.toLowerCase();
      final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
      final dataUrl = 'data:$mime;base64,$base64Str';

      await ApiService.instance.uploadKycDocument(docType, dataUrl);
      await _loadStatus();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Document envoyé. Votre dossier est en cours de vérification.'),
          backgroundColor: AppColors.success,
        ),
      );
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Envoi impossible. Vérifiez votre connexion internet.')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Vérification KYC'),
        backgroundColor: AppColors.primary,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStatus,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Banner
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryDark],
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
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.verified_user, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_levelLabel(_kycLevel),
                                  style: const TextStyle(
                                    color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(
                                  _kycLevel == KycLevel.none
                                      ? 'Soumettez un document pour démarrer'
                                      : 'Votre identité est vérifiée',
                                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: _kycLevel == KycLevel.none ? AppColors.warning : AppColors.success,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(_kycLevel == KycLevel.none ? 'À faire' : 'Actif',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    const Text('Niveaux de vérification',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 16),

                    ..._steps.map((step) => _KycLevelCard(step: step)),

                    if (_documents.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text('Documents soumis',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 10),
                      ..._documents.map((d) => _DocumentTile(
                            docType: d['doc_type'] as String? ?? '—',
                            status: d['status'] as String? ?? 'pending',
                          )),
                    ],

                    const SizedBox(height: 28),

                    // Upgrade CTA
                    if (!_isFullyVerified)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.upgrade, color: AppColors.primary),
                                SizedBox(width: 8),
                                Text('Continuer ma vérification',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Pour déposer des projets supérieurs à \$20,000 et ouvrir un compte entreprise, complétez votre vérification avancée.',
                              style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _uploading ? null : _startVerification,
                              icon: _uploading
                                  ? const SizedBox(
                                      width: 16, height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.fingerprint),
                              label: Text(_uploading ? 'Envoi en cours…' : 'Soumettre un document'),
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
              color: color.withValues(alpha: 0.1),
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
                          color: AppColors.primary.withValues(alpha: 0.1),
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

class _DocumentTile extends StatelessWidget {
  final String docType;
  final String status;
  const _DocumentTile({required this.docType, required this.status});

  Color get _statusColor {
    switch (status) {
      case 'approved': return AppColors.success;
      case 'rejected': return AppColors.error;
      default: return AppColors.warning;
    }
  }

  String get _statusLabel {
    switch (status) {
      case 'approved': return 'Validé';
      case 'rejected': return 'Rejeté';
      default: return 'En attente';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          const Icon(Icons.insert_drive_file_outlined, size: 18, color: AppColors.grey500),
          const SizedBox(width: 10),
          Expanded(child: Text(docType, style: const TextStyle(fontSize: 13))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(_statusLabel,
              style: TextStyle(color: _statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
