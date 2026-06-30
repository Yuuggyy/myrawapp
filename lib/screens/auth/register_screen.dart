import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../main_navigation.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  int _step = 1;

  void _nextStep() async {
    if (_step == 1) {
      setState(() => _step = 2);
    } else {
      setState(() => _isLoading = true);
      await Future.delayed(const Duration(milliseconds: 1200));
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigation()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Créer un compte'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () {
            if (_step == 2) setState(() => _step = 1);
            else Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  _StepIndicator(number: 1, label: 'Identité', isActive: _step >= 1, isDone: _step > 1),
                  Expanded(child: Container(height: 2, color: _step > 1 ? AppColors.primary : AppColors.divider)),
                  _StepIndicator(number: 2, label: 'Sécurité', isActive: _step >= 2, isDone: false),
                ],
              ),
              const SizedBox(height: 32),
              if (_step == 1) ...[
                Text('Vos informations', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('Renseignez vos coordonnées personnelles', style: GoogleFonts.poppins(color: AppColors.textGrey)),
                const SizedBox(height: 24),
                TextField(controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nom complet', prefixIcon: Icon(Icons.person_outline))),
                const SizedBox(height: 16),
                TextField(controller: _emailController, keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined))),
                const SizedBox(height: 16),
                TextField(controller: _phoneController, keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Téléphone (+243...)', prefixIcon: Icon(Icons.phone_outlined))),
              ] else ...[
                Text('Sécurisez votre compte', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text('Choisissez un mot de passe fort', style: GoogleFonts.poppins(color: AppColors.textGrey)),
                const SizedBox(height: 24),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(child: Text(
                        'Un SMS de vérification sera envoyé à votre numéro',
                        style: GoogleFonts.poppins(fontSize: 12, color: AppColors.primary),
                      )),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _nextStep,
                  child: _isLoading
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(_step == 1 ? 'Continuer' : 'Créer mon compte'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int number;
  final String label;
  final bool isActive;
  final bool isDone;

  const _StepIndicator({required this.number, required this.label, required this.isActive, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.divider,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: isDone
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : Text('$number', style: GoogleFonts.poppins(
                  color: isActive ? Colors.white : AppColors.textLight,
                  fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.poppins(
          fontSize: 11, color: isActive ? AppColors.primary : AppColors.textLight)),
      ],
    );
  }
}
