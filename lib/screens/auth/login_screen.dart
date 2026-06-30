import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../main_navigation.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  void _login() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigation()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              // Logo
              Center(
                child: Container(
                  width: 72, height: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primaryLight],
                    ),
                  ),
                  child: Center(
                    child: Text('R', style: GoogleFonts.poppins(
                      fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.black)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Bienvenue', textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.textWhite)),
              Text('Connectez-vous à MyRawApp', textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textGrey)),
              const SizedBox(height: 48),

              // Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: AppColors.textWhite),
                decoration: const InputDecoration(
                  labelText: 'Email ou N° client',
                  prefixIcon: Icon(Icons.person_outline, color: AppColors.textGrey),
                ),
              ),
              const SizedBox(height: 16),

              // Password
              TextField(
                controller: _passwordController,
                obscureText: _obscure,
                style: const TextStyle(color: AppColors.textWhite),
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textGrey),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textGrey),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text('Mot de passe oublié ?',
                    style: GoogleFonts.poppins(color: AppColors.primary, fontSize: 13)),
                ),
              ),
              const SizedBox(height: 24),

              // Bouton connexion
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                    ? const SizedBox(width: 24, height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.black))
                    : Text('Se connecter', style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.black)),
                ),
              ),
              const SizedBox(height: 20),

              // Biométrie
              OutlinedButton.icon(
                icon: const Icon(Icons.fingerprint, color: AppColors.primary, size: 22),
                label: Text('Connexion biométrique',
                  style: GoogleFonts.poppins(color: AppColors.primary, fontWeight: FontWeight.w600)),
                onPressed: _login,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Pas encore de compte ? ', style: GoogleFonts.poppins(
                    color: AppColors.textGrey, fontSize: 14)),
                  GestureDetector(
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen())),
                    child: Text('S\'inscrire', style: GoogleFonts.poppins(
                      color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14)),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Center(
                child: Text('Inspire By YuuStore',
                  style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textLight, letterSpacing: 1.5)),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
