import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';
import '../chat/chat_screen.dart';

// Financing types
enum FinancingType {
  pret('Prêt'),
  pretInteret('Prêt avec intérêt'),
  partenariat('Financement de partenariat'),
  rse('RSE — Responsabilité Sociétale & Environnementale');

  final String label;
  const FinancingType(this.label);
}

class NewProjectScreen extends StatefulWidget {
  const NewProjectScreen({super.key});

  @override
  State<NewProjectScreen> createState() => _NewProjectScreenState();
}

class _NewProjectScreenState extends State<NewProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  final int _totalSteps = 4;
  bool _isSubmitting = false;

  // Step 1: General info
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  String? _sector;
  final _promoterCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final _marketCtrl = TextEditingController();
  final _competitionCtrl = TextEditingController();

  // Step 2: Financing
  FinancingType? _financingType;
  final _amountCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  String _currency = 'USD';

  // Partnership fields
  final _projectedRevenueCtrl = TextEditingController();
  final _bankShareCtrl = TextEditingController();
  final _percentageCtrl = TextEditingController();
  final _partnershipTermsCtrl = TextEditingController();

  // Loan with interest fields
  final _interestRateCtrl = TextEditingController();
  final _collateralCtrl = TextEditingController();

  // RSE fields
  final _socialImpactCtrl = TextEditingController();
  final _envImpactCtrl = TextEditingController();
  final _beneficiariesCtrl = TextEditingController();
  final _jobsCreatedCtrl = TextEditingController();

  // Step 3: Business plan
  final _businessPlanCtrl = TextEditingController();
  final List<String> _uploadedDocs = [];

  final _docTypes = [
    'Business Plan complet (PDF)',
    'Registre de commerce',
    'Carte d\'identité / passeport',
    'Relevé bancaire (6 derniers mois)',
    'Facture pro forma / Devis',
    'Statuts de l\'entreprise',
    'Plan de trésorerie',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _promoterCtrl.dispose();
    _experienceCtrl.dispose();
    _marketCtrl.dispose();
    _competitionCtrl.dispose();
    _amountCtrl.dispose();
    _durationCtrl.dispose();
    _projectedRevenueCtrl.dispose();
    _bankShareCtrl.dispose();
    _percentageCtrl.dispose();
    _partnershipTermsCtrl.dispose();
    _interestRateCtrl.dispose();
    _collateralCtrl.dispose();
    _socialImpactCtrl.dispose();
    _envImpactCtrl.dispose();
    _beneficiariesCtrl.dispose();
    _jobsCreatedCtrl.dispose();
    _businessPlanCtrl.dispose();
    super.dispose();
  }

  bool get _isLastStep => _currentStep == _totalSteps - 1;

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      _submit();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_sector == null || _financingType == null || _amountCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Merci de compléter le secteur, le type de financement et le montant.')),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final amount = double.tryParse(_amountCtrl.text.replaceAll(',', '.')) ?? 0;
      
      // Map financing type to Supabase format
      String fundingType;
      String? rseEsgCategory;
      String? rseEsgDescription;
      double? interestRate;
      double? projectedRevenue;
      double? bankProfitShare;
      double? roiPercentage;
      
      switch (_financingType ?? FinancingType.pret) {
        case FinancingType.pret:
          fundingType = 'loan';
          break;
        case FinancingType.pretInteret:
          fundingType = 'interest_loan';
          interestRate = double.tryParse(_interestRateCtrl.text.replaceAll(',', '.')) ?? 0;
          break;
        case FinancingType.partenariat:
          fundingType = 'partnership';
          projectedRevenue = double.tryParse(_projectedRevenueCtrl.text.replaceAll(',', '.')) ?? 0;
          bankProfitShare = double.tryParse(_bankShareCtrl.text.replaceAll(',', '.')) ?? 0;
          roiPercentage = double.tryParse(_percentageCtrl.text.replaceAll(',', '.')) ?? 0;
          break;
        case FinancingType.rse:
          fundingType = 'loan';
          rseEsgCategory = 'mixte';
          rseEsgDescription = 'Impact social: ${_socialImpactCtrl.text.trim()}\nImpact environnemental: ${_envImpactCtrl.text.trim()}\nBeneficiaires: ${_beneficiariesCtrl.text.trim()}\nEmplois crees: ${_jobsCreatedCtrl.text.trim()}';
          break;
      }
      
      await ApiService.instance.createProject({
        'title': _titleCtrl.text.trim(),
        'project_name': _titleCtrl.text.trim(),
        'type': fundingType,
        'funding_type': fundingType,
        'sector': _sector,
        'amount_requested': amount,
        'requested_amount': amount,
        'currency': _currency,
        'description': _descCtrl.text.trim(),
        'project_description': _descCtrl.text.trim(),
        'interest_rate': interestRate,
        'projected_revenue': projectedRevenue,
        'bank_profit_share': bankProfitShare,
        'roi_percentage': roiPercentage,
        'rse_esg_category': rseEsgCategory,
        'rse_esg_description': rseEsgDescription,
        'business_plan_url': _businessPlanCtrl.text.trim().isNotEmpty ? _businessPlanCtrl.text.trim() : null,
      });
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => _SuccessDialog(onClose: () {
          // Build project context for AI analysis
          final projectContext = <String, dynamic>{
            'project_name': _titleCtrl.text.trim(),
            'sector': _sector,
            'funding_type': fundingType,
            'amount': amount,
            'description': _descCtrl.text.trim(),
            'interest_rate': interestRate,
          };
          if (_socialImpactCtrl.text.trim().isNotEmpty) projectContext['social_impact'] = _socialImpactCtrl.text.trim();
          if (_envImpactCtrl.text.trim().isNotEmpty) projectContext['environmental_impact'] = _envImpactCtrl.text.trim();
          if (_jobsCreatedCtrl.text.trim().isNotEmpty) projectContext['jobs_created'] = int.tryParse(_jobsCreatedCtrl.text.trim()) ?? 0;
          
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => ChatScreen(
              projectId: 'new_project',
              showBackButton: true,
              onBack: () => Navigator.pushReplacementNamed(context, AppRoutes.projects),
              projectContext: projectContext,
            )),
          );
        }),
      );
    } on ApiException catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (_) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Soumission impossible. Vérifiez votre connexion internet.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Nouveau projet'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          _StepIndicator(currentStep: _currentStep, total: _totalSteps),
          Expanded(
            child: Form(
              key: _formKey,
              child: IndexedStack(
                index: _currentStep,
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(),
                  _buildStep4(),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Informations générales', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Renseignez les informations essentielles du projet',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 24),

          _Field(controller: _titleCtrl, label: 'Titre du projet *', hint: 'Ex: Épicerie Bio Kinshasa', validator: _required),
          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: _sector,
            decoration: const InputDecoration(labelText: 'Secteur d\'activité *'),
            items: AppConstants.projectSectors.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (v) => setState(() => _sector = v),
            validator: (v) => v == null ? 'Secteur requis' : null,
          ),
          const SizedBox(height: 16),

          _Field(controller: _locationCtrl, label: 'Localisation *', hint: 'Ex: Gombe, Kinshasa', icon: Icons.location_on_outlined, validator: _required),
          const SizedBox(height: 16),

          _Field(controller: _promoterCtrl, label: 'Nom du promoteur *', hint: 'Ex: Jean Mutombo', icon: Icons.person_outline, validator: _required),
          const SizedBox(height: 16),

          _Field(
            controller: _experienceCtrl,
            label: 'Expérience dans le domaine *',
            hint: 'Ex: 5 ans dans le commerce de détail',
            maxLines: 2,
            validator: _required,
          ),
          const SizedBox(height: 16),

          _Field(
            controller: _marketCtrl,
            label: 'Marché cible *',
            hint: 'Décrivez votre marché cible, clients potentiels...',
            maxLines: 3,
            validator: _required,
          ),
          const SizedBox(height: 16),

          _Field(
            controller: _competitionCtrl,
            label: 'Concurrence / Avantage différenciant *',
            hint: 'Quels sont vos concurrents et votre avantage ?',
            maxLines: 3,
            validator: _required,
          ),
          const SizedBox(height: 16),

          _Field(
            controller: _descCtrl,
            label: 'Description détaillée du projet *',
            hint: 'Décrivez votre projet en détail...',
            maxLines: 5,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Description requise';
              if (v.length < 50) return 'Minimum 50 caractères';
              return null;
            },
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Type de financement', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Choisissez le type de financement souhaité',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 24),

          // Financing type cards
          ...FinancingType.values.map((ft) {
            final selected = _financingType == ft;
            return GestureDetector(
              onTap: () => setState(() => _financingType = ft),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary.withOpacity(0.06) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.grey200,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 22, height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: selected ? AppColors.primary : AppColors.grey300, width: 2),
                      ),
                      child: selected
                          ? const Center(child: const Icon(Icons.check, size: 14, color: AppColors.primary))
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(ft.label, style: TextStyle(
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 15,
                        color: selected ? AppColors.primary : AppColors.textPrimary,
                      )),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // Amount + duration (always shown)
          if (_financingType != null) ...[
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Montant demandé *',
                      hintText: 'Ex: 15000',
                      prefixIcon: const Icon(Icons.attach_money),
                      suffix: _CurrencyToggle(value: _currency, onChanged: (v) => setState(() => _currency = v)),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Requis';
                      if (double.tryParse(v) == null) return 'Invalide';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _durationCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Durée de remboursement (mois) *',
                hintText: 'Ex: 24',
                prefixIcon: const Icon(Icons.schedule),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Durée requise';
                final n = int.tryParse(v);
                if (n == null || n < 1 || n > 120) return 'Entre 1 et 120 mois';
                return null;
              },
            ),
            const SizedBox(height: 24),
          ],

          // Conditional fields
          if (_financingType == FinancingType.partenariat) ..._partnershipFields(),
          if (_financingType == FinancingType.pretInteret) ..._loanInterestFields(),
          if (_financingType == FinancingType.rse) ..._rseFields(),
          if (_financingType == FinancingType.pret) ...[
            // Just a note for plain loan
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.info.withOpacity(0.2)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: AppColors.info, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Le prêt sera analysé par nos agents IA. Le taux d\'intérêt sera communiqué après évaluation de votre dossier.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  List<Widget> _partnershipFields() {
    return [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.aiCommercial.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.aiCommercial.withOpacity(0.2)),
        ),
        child: const Row(
          children: [
            const Icon(Icons.handshake_outlined, color: AppColors.aiCommercial, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Partenariat — précisez les conditions financières',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _Field(
        controller: _projectedRevenueCtrl,
        label: 'Revenus projetés (total) *',
        hint: 'Ex: 50000',
        icon: Icons.trending_up,
        keyboardType: TextInputType.number,
        validator: _required,
      ),
      const SizedBox(height: 16),
      _Field(
        controller: _bankShareCtrl,
        label: 'Part de la banque (\$ ou montant) *',
        hint: 'Ex: 10000',
        icon: Icons.account_balance,
        keyboardType: TextInputType.number,
        validator: _required,
      ),
      const SizedBox(height: 16),
      _Field(
        controller: _percentageCtrl,
        label: 'Pourcentage de la banque (%) *',
        hint: 'Ex: 20',
        icon: Icons.percent,
        keyboardType: TextInputType.number,
        validator: (v) {
          if (v == null || v.isEmpty) return 'Requis';
          final n = double.tryParse(v);
          if (n == null || n < 0 || n > 100) return 'Entre 0 et 100%';
          return null;
        },
      ),
      const SizedBox(height: 16),
      _Field(
        controller: _partnershipTermsCtrl,
        label: 'Conditions du partenariat *',
        hint: 'Décrivez les termes: durée, répartition, obligations...',
        maxLines: 4,
        validator: _required,
      ),
    ];
  }

  List<Widget> _loanInterestFields() {
    return [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.aiAccounting.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.aiAccounting.withOpacity(0.2)),
        ),
        child: const Row(
          children: [
            const Icon(Icons.percent, color: AppColors.aiAccounting, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Prêt avec intérêt — précisez les conditions',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _Field(
        controller: _interestRateCtrl,
        label: 'Taux d\'intérêt souhaité (%) *',
        hint: 'Ex: 8.5',
        icon: Icons.percent,
        keyboardType: TextInputType.number,
        validator: (v) {
          if (v == null || v.isEmpty) return 'Requis';
          final n = double.tryParse(v);
          if (n == null || n < 0 || n > 50) return 'Entre 0 et 50%';
          return null;
        },
      ),
      const SizedBox(height: 16),
      _Field(
        controller: _collateralCtrl,
        label: 'Garantie / Collateral *',
        hint: 'Ex: Terrain à Lemba, véhicule, équipement...',
        maxLines: 3,
        validator: _required,
      ),
    ];
  }

  List<Widget> _rseFields() {
    return [
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.aiRSE.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.aiRSE.withOpacity(0.2)),
        ),
        child: const Row(
          children: [
            const Icon(Icons.eco_outlined, color: AppColors.aiRSE, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text('RSE — Impact sociétal et environnemental',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      _Field(
        controller: _socialImpactCtrl,
        label: 'Impact social *',
        hint: 'Comment le projet benefiting la communauté ?',
        maxLines: 3,
        validator: _required,
      ),
      const SizedBox(height: 16),
      _Field(
        controller: _envImpactCtrl,
        label: 'Impact environnemental *',
        hint: 'Mesures environnementales, empreinte carbone, etc.',
        maxLines: 3,
        validator: _required,
      ),
      const SizedBox(height: 16),
      _Field(
        controller: _beneficiariesCtrl,
        label: 'Nombre de bénéficiaires estimé *',
        hint: 'Ex: 500 personnes',
        icon: Icons.groups,
        validator: _required,
      ),
      const SizedBox(height: 16),
      _Field(
        controller: _jobsCreatedCtrl,
        label: 'Emplois créés estimés *',
        hint: 'Ex: 15 emplois directs',
        icon: Icons.work_outline,
        keyboardType: TextInputType.number,
        validator: _required,
      ),
    ];
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Plan d\'affaires', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Décrivez votre plan d\'affaires complet. Le back-office recevra ces informations structurées.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 24),

          // Business plan text area
          TextFormField(
            controller: _businessPlanCtrl,
            maxLines: 12,
            decoration: const InputDecoration(
              labelText: 'Plan d\'affaires complet *',
              hintText: 'Incluez: modèle économique, stratégie, prévisions financières, équipe, risques...',
              alignLabelWithHint: true,
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Plan d\'affaires requis';
              if (v.length < 200) return 'Minimum 200 caractères pour un plan complet';
              return null;
            },
          ),
          const SizedBox(height: 24),

          // Document uploads
          const Text('Documents à joindre', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          ..._docTypes.map((doc) {
            final isUploaded = _uploadedDocs.contains(doc);
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isUploaded ? AppColors.success.withOpacity(0.3) : AppColors.grey200,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: isUploaded ? AppColors.success.withOpacity(0.1) : AppColors.grey100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isUploaded ? Icons.check_circle : Icons.upload_file,
                      color: isUploaded ? AppColors.success : AppColors.grey500,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(doc, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                        Text(
                          isUploaded ? 'Téléchargé' : 'PDF, JPG, PNG (max 10MB)',
                          style: TextStyle(
                            color: isUploaded ? AppColors.success : AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  isUploaded
                      ? IconButton(
                          icon: const Icon(Icons.close, color: AppColors.error, size: 20),
                          onPressed: () => setState(() => _uploadedDocs.remove(doc)),
                        )
                      : IconButton(
                          icon: const Icon(Icons.add_circle, color: AppColors.primary),
                          onPressed: () => setState(() => _uploadedDocs.add(doc)),
                        ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.cloud_upload_outlined),
            label: const Text('Télécharger tous les documents'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Récapitulatif', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Vérifiez les informations avant de soumettre',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 24),

          _SummaryItem(label: 'Titre', value: _titleCtrl.text.isEmpty ? '—' : _titleCtrl.text),
          _SummaryItem(label: 'Secteur', value: _sector ?? '—'),
          _SummaryItem(label: 'Localisation', value: _locationCtrl.text.isEmpty ? '—' : _locationCtrl.text),
          _SummaryItem(label: 'Promoteur', value: _promoterCtrl.text.isEmpty ? '—' : _promoterCtrl.text),
          _SummaryItem(
            label: 'Type de financement',
            value: _financingType?.label ?? '—',
            highlight: true,
          ),
          _SummaryItem(
            label: 'Montant',
            value: _amountCtrl.text.isEmpty ? '—' : '${_amountCtrl.text} $_currency',
          ),
          _SummaryItem(
            label: 'Durée',
            value: _durationCtrl.text.isEmpty ? '—' : '${_durationCtrl.text} mois',
          ),
          if (_financingType == FinancingType.partenariat) ...[
            _SummaryItem(label: 'Revenus projetés', value: _projectedRevenueCtrl.text.isEmpty ? '—' : _projectedRevenueCtrl.text),
            _SummaryItem(label: 'Part banque', value: _bankShareCtrl.text.isEmpty ? '—' : _bankShareCtrl.text),
            _SummaryItem(label: 'Pourcentage banque', value: _percentageCtrl.text.isEmpty ? '—' : '${_percentageCtrl.text}%'),
          ],
          if (_financingType == FinancingType.pretInteret) ...[
            _SummaryItem(label: 'Taux souhaité', value: _interestRateCtrl.text.isEmpty ? '—' : '${_interestRateCtrl.text}%'),
            _SummaryItem(label: 'Garantie', value: _collateralCtrl.text.isEmpty ? '—' : _collateralCtrl.text),
          ],
          if (_financingType == FinancingType.rse) ...[
            _SummaryItem(label: 'Bénéficiaires', value: _beneficiariesCtrl.text.isEmpty ? '—' : _beneficiariesCtrl.text),
            _SummaryItem(label: 'Emplois créés', value: _jobsCreatedCtrl.text.isEmpty ? '—' : _jobsCreatedCtrl.text),
          ],
          _SummaryItem(
            label: 'Plan d\'affaires',
            value: _businessPlanCtrl.text.isEmpty ? '—' : '${_businessPlanCtrl.text.length} caractères',
          ),
          _SummaryItem(
            label: 'Documents',
            value: '${_uploadedDocs.length} / ${_docTypes.length} téléchargés',
          ),

          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.info.withOpacity(0.2)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.info, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Analyse IA automatique', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(
                        'Votre projet sera analysé par 5 agents IA: RSE, Compliance, Commercial, Comptable, et Router. Chaque information sera transmise séparément au back-office.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  side: const BorderSide(color: AppColors.grey300),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Précédent'),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _nextStep,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_isLastStep ? 'Soumettre le projet' : 'Continuer'),
            ),
          ),
        ],
      ),
    );
  }

  String? _required(String? v) {
    if (v == null || v.trim().isEmpty) return 'Champ requis';
    return null;
  }
}

// ── Widgets ──
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int total;
  const _StepIndicator({required this.currentStep, required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: Colors.white,
      child: Row(
        children: List.generate(total, (i) {
          final isActive = i <= currentStep;
          final isCurrent = i == currentStep;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.grey200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: isCurrent
                        ? const Text('●', style: TextStyle(color: Colors.white, fontSize: 8))
                        : Text('${i + 1}',
                            style: TextStyle(
                              color: isActive ? Colors.white : AppColors.grey500,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            )),
                  ),
                ),
                const SizedBox(width: 6),
                if (i < total - 1)
                  Expanded(child: Container(height: 2, color: i < currentStep ? AppColors.primary : AppColors.grey200)),
                if (i < total - 1) const SizedBox(width: 6),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData? icon;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.icon,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon != null ? Icon(icon) : null,

        alignLabelWithHint: maxLines > 1,
      ),
      validator: validator,
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const _SummaryItem({required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.grey200)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                color: highlight ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencyToggle extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _CurrencyToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      isSelected: ['USD', 'CDF'].map((c) => c == value).toList(),
      onPressed: (i) => onChanged(['USD', 'CDF'][i]),
      borderRadius: BorderRadius.circular(8),
      constraints: const BoxConstraints(minWidth: 44, minHeight: 32),
      selectedColor: Colors.white,
      fillColor: AppColors.primary,
      borderColor: AppColors.grey300,
      selectedBorderColor: AppColors.primary,
      children: const [
        Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('USD', style: TextStyle(fontSize: 12))),
        Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('CDF', style: TextStyle(fontSize: 12))),
      ],
    );
  }
}

class _SuccessDialog extends StatelessWidget {
  final VoidCallback onClose;
  const _SuccessDialog({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.check, color: AppColors.success, size: 40),
            ),
            const SizedBox(height: 20),
            const Text('Projet soumis !', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'Votre projet est transmis au back-office. Chaque section (informations, financement, plan d\'affaires) est envoyée séparément. Les 5 agents IA vont analyser votre dossier.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: onClose, child: const Text('Analyser avec l IA')),
            ),
          ],
        ),
      ),
    );
  }
}
