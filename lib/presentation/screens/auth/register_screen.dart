import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/api_service.dart';
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
      setState(() => _errorMessage = 'Veuillez accepter les conditions d\'utilisation.');
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      await ApiService.instance.register({
        'full_name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'password': _passwordController.text,
        'client_type': _clientType,
      });
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.login);
    } catch (e) {
      setState(() => _errorMessage = 'Erreur lors de l\'inscription. Veuillez réessayer.');
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
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
                const Text(
                  'Créer un compte',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Rejoignez MyRawApp en quelques étapes.',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),

                const SizedBox(height: 32),

                // Type de compte
                const Text('Type de compte',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _TypeCard(
                      icon: Icons.person_outline,
                      label: 'Particulier',
                      isSelected: _clientType == 'individual',
                      onTap: () => setState(() => _clientType = 'individual'),
                    ),
                    const SizedBox(width: 12),
                    _TypeCard(
                      icon: Icons.business_outlined,
                      label: 'Entreprise',
                      isSelected: _clientType == 'enterprise',
                      onTap: () => setState(() => _clientType = 'enterprise'),
                    ),
                  ],
                ),

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

                // Terms
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
                            const TextSpan(text: "J'accepte les "),
                            TextSpan(
                              text: 'Conditions Générales d\'Utilisation',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                RawButton(
                  label: 'Créer mon compte',
                  isLoading: _isLoading,
                  onPressed: _register,
                ),

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
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeCard({
    required this.icon,
    required this.label,
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
          padding: const EdgeInsets.symmetric(vertical: 16),
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
              Icon(icon, color: isSelected ? AppColors.primary : AppColors.grey500),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
