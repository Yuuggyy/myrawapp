import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/business_sector.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/common/raw_button.dart';
import '../../widgets/common/raw_text_field.dart';

class BusinessRegisterScreen extends StatefulWidget {
  const BusinessRegisterScreen({super.key});

  @override
  State<BusinessRegisterScreen> createState() => _BusinessRegisterScreenState();
}

class _BusinessRegisterScreenState extends State<BusinessRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _companyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _rccmController = TextEditingController();
  final _idNatController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _otherSectorController = TextEditingController();

  String? _selectedSectorId;
  BusinessSector? _selectedSector;
  bool _isOtherSector = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _acceptTerms = false;
  String? _errorMessage;

  int _currentStep = 0;
  final int _totalSteps = 3;

  void _onSectorChanged(String? sectorName) {
    if (sectorName == null) return;
    if (sectorName == 'Autre') {
      setState(() {
        _isOtherSector = true;
        _selectedSector = null;
        _selectedSectorId = null;
      });
      return;
    }
    final sector = BusinessSectors.sectors.firstWhere((s) => s.name == sectorName);
    setState(() {
      _selectedSector = sector;
      _selectedSectorId = sector.id;
      _isOtherSector = false;
    });
  }

  bool _validateStep() {
    switch (_currentStep) {
      case 0:
        if (_companyNameController.text.isEmpty) {
          setState(() => _errorMessage = 'Nom de l\'entreprise requis');
          return false;
        }
        if (_selectedSectorId == null && !_isOtherSector) {
          setState(() => _errorMessage = 'Veuillez sélectionner un secteur');
          return false;
        }
        if (_isOtherSector && _otherSectorController.text.isEmpty) {
          setState(() => _errorMessage = 'Veuillez préciser votre secteur');
          return false;
        }
        return true;
      case 1:
        if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
          setState(() => _errorMessage = 'Email valide requis');
          return false;
        }
        if (_phoneController.text.isEmpty) {
          setState(() => _errorMessage = 'Téléphone requis');
          return false;
        }
        if (_rccmController.text.isEmpty) {
          setState(() => _errorMessage = 'Numéro RCCM requis');
          return false;
        }
        return true;
      case 2:
        if (_passwordController.text.length < 8) {
          setState(() => _errorMessage = 'Mot de passe: minimum 8 caractères');
          return false;
        }
        if (_passwordController.text != _confirmPasswordController.text) {
          setState(() => _errorMessage = 'Les mots de passe ne correspondent pas');
          return false;
        }
        if (!_acceptTerms) {
          setState(() => _errorMessage = 'Veuillez accepter les conditions');
          return false;
        }
        return true;
    }
    return true;
  }

  void _nextStep() {
    if (!_validateStep()) return;
    setState(() {
      _errorMessage = null;
      if (_currentStep < _totalSteps - 1) {
        _currentStep++;
      } else {
        _register();
      }
    });
  }

  void _previousStep() {
    setState(() {
      _errorMessage = null;
      if (_currentStep > 0) _currentStep--;
    });
  }

  Future<void> _register() async {
    setState(() { _isLoading = true; _errorMessage = null; });

    await Future.delayed(const Duration(milliseconds: 800));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('user_email', _emailController.text.trim());
    await prefs.setString('user_name', _companyNameController.text.trim());
    await prefs.setString('account_type', 'enterprise');
    await prefs.setString('business_sector', _selectedSectorId ?? 'autre');
    await prefs.setString('business_sector_name', _isOtherSector ? _otherSectorController.text : (_selectedSector?.name ?? 'Autre'));
    await prefs.setString('rccm', _rccmController.text.trim());

    if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
  }

  IconData _getSectorIcon(String icon) {
    const icons = {
      'agriculture': Icons.agriculture,
      'mining': Icons.terrain,
      'telecom': Icons.wifi,
      'finance': Icons.account_balance,
      'construction': Icons.construction,
      'commerce': Icons.store,
      'import_export': Icons.local_shipping,
      'transport': Icons.directions_bus,
      'health': Icons.local_hospital,
      'energy': Icons.bolt,
      'education': Icons.school,
      'media': Icons.tv,
      'manufacturing': Icons.factory,
      'tourism': Icons.hotel,
      'realestate': Icons.home_work,
      'fishing': Icons.set_meal,
      'forestry': Icons.forest,
      'textile': Icons.dry_cleaning,
      'automotive': Icons.directions_car,
      'aviation': Icons.flight,
      'maritime': Icons.directions_boat,
      'food': Icons.restaurant,
      'pharma': Icons.medication,
      'insurance': Icons.shield,
      'ngo': Icons.volunteer_activism,
      'security': Icons.security,
      'consulting': Icons.lightbulb,
      'oil_gas': Icons.oil_barrel,
      'technology': Icons.computer,
      'water': Icons.water_drop,
      'artisanat': Icons.handyman,
      'logistics': Icons.inventory,
      'entertainment': Icons.theater_comedy,
      'mining_services': Icons.science,
      'environment': Icons.eco,
      'agribusiness': Icons.grass,
    };
    return icons[icon] ?? Icons.business;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: _currentStep > 0 ? _previousStep : () => Navigator.pushReplacementNamed(context, AppRoutes.register),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Compte Entreprise RawBank',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                const Text('Ouvrez le compte bancaire de votre entreprise auprès de RawBank.',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),

                const SizedBox(height: 16),

                // Progress indicator
                Row(
                  children: List.generate(_totalSteps, (i) {
                    return Expanded(
                      child: Container(
                        height: 4,
                        margin: EdgeInsets.only(right: i < _totalSteps - 1 ? 8 : 0),
                        decoration: BoxDecoration(
                          color: i <= _currentStep ? AppColors.primary : AppColors.grey300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                Text('Étape ${_currentStep + 1} sur $_totalSteps',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),

                const SizedBox(height: 24),

                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(_errorMessage!,
                      style: const TextStyle(color: AppColors.error, fontSize: 13)),
                  ),
                  const SizedBox(height: 16),
                ],

                // STEP 0: Entreprise + Secteur
                if (_currentStep == 0) ...[
                  RawTextField(
                    controller: _companyNameController,
                    label: 'Nom de l\'entreprise',
                    hint: 'Ex: RawTech SARL',
                    prefixIcon: Icons.business,
                    validator: (v) => (v?.isEmpty ?? true) ? 'Nom requis' : null,
                  ),
                  const SizedBox(height: 20),

                  // Secteur dropdown
                  const Text('Secteur d\'activité',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.grey300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedSector?.name,
                        hint: const Padding(
                          padding: EdgeInsets.only(left: 16),
                          child: Text('Sélectionnez votre secteur',
                            style: TextStyle(color: AppColors.grey500)),
                        ),
                        isExpanded: true,
                        icon: const Padding(
                          padding: EdgeInsets.only(right: 16),
                          child: Icon(Icons.arrow_drop_down, color: AppColors.grey500),
                        ),
                        items: [
                          ...BusinessSectors.sectors.map((s) => DropdownMenuItem(
                            value: s.name,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Row(
                                children: [
                                  Icon(_getSectorIcon(s.icon), size: 20, color: AppColors.primary),
                                  const SizedBox(width: 12),
                                  Expanded(child: Text(s.name, style: const TextStyle(fontSize: 14))),
                                ],
                              ),
                            ),
                          )),
                          const DropdownMenuItem(
                            value: 'Autre',
                            child: Padding(
                              padding: EdgeInsets.only(left: 12),
                              child: Row(
                                children: [
                                  Icon(Icons.more_horiz, size: 20, color: AppColors.grey500),
                                  SizedBox(width: 12),
                                  Text('Autre (préciser)', style: TextStyle(fontSize: 14)),
                                ],
                              ),
                            ),
                          ),
                        ],
                        onChanged: _onSectorChanged,
                      ),
                    ),
                  ),

                  if (_isOtherSector) ...[
                    const SizedBox(height: 12),
                    RawTextField(
                      controller: _otherSectorController,
                      label: 'Précisez votre secteur',
                      hint: 'Ex: Énergie solaire, biotechnologie...',
                      prefixIcon: Icons.category,
                    ),
                  ],

                  // Sector info
                  if (_selectedSector != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.info_outline, size: 18, color: AppColors.primary),
                              const SizedBox(width: 8),
                              Text('Régulateur: ${_selectedSector!.regulator}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(_selectedSector!.description,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ],
                ],

                // STEP 1: Documents & Contact
                if (_currentStep == 1) ...[
                  RawTextField(
                    controller: _emailController,
                    label: 'Email professionnel',
                    hint: 'contact@entreprise.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 16),
                  RawTextField(
                    controller: _phoneController,
                    label: 'Téléphone',
                    hint: '+243 81X XXX XXXX',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                  ),
                  const SizedBox(height: 16),
                  RawTextField(
                    controller: _rccmController,
                    label: 'Numéro RCCM',
                    hint: 'Ex: CD/KIN/2024/12345',
                    prefixIcon: Icons.receipt_long,
                  ),
                  const SizedBox(height: 16),
                  RawTextField(
                    controller: _idNatController,
                    label: 'ID National / NIF (optionnel)',
                    hint: 'Ex: 01-2-34567-8',
                    prefixIcon: Icons.badge_outlined,
                  ),

                  // Show required documents preview
                  if (_selectedSector != null) ...[
                    const SizedBox(height: 20),
                    const Text('Documents requis pour ce secteur:',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _selectedSector!.requiredDocuments.map((doc) =>
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle_outline, size: 16, color: AppColors.primary),
                                const SizedBox(width: 8),
                                Expanded(child: Text(doc, style: const TextStyle(fontSize: 12))),
                              ],
                            ),
                          )
                        ).toList(),
                      ),
                    ),
                  ],

                  if (_isOtherSector) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.lightbulb_outline, size: 18, color: AppColors.warning),
                          const SizedBox(width: 8),
                          Expanded(
                            child: const Text(
                              'Votre secteur sera analysé par notre IA. Les documents requis vous seront communiqués après vérification.',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],

                // STEP 2: Sécurité
                if (_currentStep == 2) ...[
                  RawTextField(
                    controller: _passwordController,
                    label: 'Mot de passe',
                    hint: 'Min. 8 caractères',
                    obscureText: _obscurePassword,
                    prefixIcon: Icons.lock_outlined,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.grey500,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 16),
                  RawTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirmer le mot de passe',
                    hint: '••••••••',
                    obscureText: true,
                    prefixIcon: Icons.lock_outlined,
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Checkbox(
                        value: _acceptTerms,
                        activeColor: AppColors.primary,
                        onChanged: (v) => setState(() => _acceptTerms = v ?? false),
                      ),
                      Expanded(
                        child: const Text(
                          "J'accepte les conditions d'utilisation et confirme être autorisé à représenter cette entreprise.",
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),

                  // Summary
                  if (_selectedSector != null || _isOtherSector) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.grey100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Récapitulatif — Ouverture de compte',
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 8),
                          Text('Entreprise: ${_companyNameController.text}', style: const TextStyle(fontSize: 13)),
                          Text('Banque: RawBank', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          Text('Secteur: ${_isOtherSector ? _otherSectorController.text : _selectedSector?.name}', style: const TextStyle(fontSize: 13)),
                          Text('Email: ${_emailController.text}', style: const TextStyle(fontSize: 13)),
                          Text('RCCM: ${_rccmController.text}', style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ],

                const SizedBox(height: 24),

                RawButton(
                  label: _currentStep < _totalSteps - 1 ? 'Continuer' : 'Créer le compte entreprise',
                  isLoading: _isLoading,
                  onPressed: _nextStep,
                ),

                if (_currentStep > 0) ...[
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _previousStep,
                    child: const Text('Retour', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ],

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
