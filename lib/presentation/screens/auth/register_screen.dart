import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../widgets/common/raw_button.dart';
import '../../widgets/common/raw_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _acceptTerms = false;
  String _clientType = 'individual';
  String? _errorMessage;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptTerms) {
      setState(() => _errorMessage = 'Veuillez accepter les conditions d\'ouverture de compte.');
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });

    // Mock — simulate account opening at RawBank
    await Future.delayed(const Duration(milliseconds: 800));

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', true);
    await prefs.setString('user_email', _emailController.text.trim());
    await prefs.setString('user_name', _nameController.text.trim());
    await prefs.setString('account_type', _clientType);

    if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
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
          onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
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
                // RawBank branding
                Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('RB',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text('RawBank',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  ],
                ),

                const SizedBox(height: 24),

                Text(
                  'Ouvrir un compte',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ouvrez votre compte bancaire RawBank en quelques minutes. '
                  'Vous serez immédiatement client de la banque.',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),

                const SizedBox(height: 32),

                // Type de compte
                const Text('Type de compte bancaire',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _TypeCard(
                      icon: Icons.person_outline,
                      label: 'Particulier',
                      subtitle: 'Compte personnel',
                      isSelected: _clientType == 'individual',
                      onTap: () => setState(() => _clientType = 'individual'),
                    ),
                    const SizedBox(width: 12),
                    _TypeCard(
                      icon: Icons.business_outlined,
                      label: 'Entreprise',
                      subtitle: 'Compte professionnel',
                      isSelected: _clientType == 'enterprise',
                      onTap: () {
                        Navigator.pushNamed(context, '/business-register');
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                if (_clientType == 'individual') ...[
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

                  // Info banner
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, size: 18, color: AppColors.info),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'En ouvrant un compte particulier, vous devenez client RawBank. '
                            'Un compte IllicoCash et un compte courant seront automatiquement créés.',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  RawTextField(
                    controller: _nameController,
                    label: 'Nom complet',
                    hint: 'Jean Kabila',
                    prefixIcon: Icons.badge_outlined,
                    validator: (v) => (v?.isEmpty ?? true) ? 'Nom requis' : null,
                  ),
                  const SizedBox(height: 16),

                  RawTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'votre@email.com',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'Email requis';
                      if (!v!.contains('@')) return 'Email invalide';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  RawTextField(
                    controller: _phoneController,
                    label: 'Téléphone',
                    hint: '+243 81X XXX XXXX',
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined,
                    validator: (v) => (v?.isEmpty ?? true) ? 'Téléphone requis' : null,
                  ),
                  const SizedBox(height: 16),

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
                    validator: (v) {
                      if (v?.isEmpty ?? true) return 'Mot de passe requis';
                      if (v!.length < 8) return 'Minimum 8 caractères';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  RawTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirmer le mot de passe',
                    hint: '••••••••',
                    obscureText: true,
                    prefixIcon: Icons.lock_outlined,
                    validator: (v) {
                      if (v != _passwordController.text) return 'Les mots de passe ne correspondent pas';
                      return null;
                    },
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
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                            children: const [
                              TextSpan(text: "J'accepte les "),
                              TextSpan(
                                text: 'Conditions Générales de Banque',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(text: ' de RawBank.'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  RawButton(
                    label: 'Ouvrir mon compte',
                    isLoading: _isLoading,
                    onPressed: _register,
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.business, size: 48, color: AppColors.primary),
                        SizedBox(height: 12),
                        Text(
                          'Compte Entreprise RawBank',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Vous allez être redirigé vers le formulaire d\'ouverture de compte entreprise '
                          'avec sélection de secteur d\'activité et documents réglementaires.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
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

class _TypeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : AppColors.grey100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.grey300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppColors.primary : AppColors.grey500, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.7) : AppColors.grey500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
