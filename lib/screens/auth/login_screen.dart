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
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  void _login() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigation()));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const SizedBox(height: 48),
            Center(child: Container(
              width: 76, height: 76,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.gold),
              child: Center(child: Text('R', style: GoogleFonts.poppins(
                fontSize: 38, fontWeight: FontWeight.w900, color: Colors.white))),
            )),
            const SizedBox(height: 20),
            Text('Bienvenue', textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
            const SizedBox(height: 4),
            Text('Connectez-vous à votre espace', textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 14, color: textSecondary)),
            const SizedBox(height: 44),

            TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email ou N° client',
                prefixIcon: Icon(Icons.person_outline_rounded, size: 20))),
            const SizedBox(height: 14),
            TextField(controller: _pwCtrl, obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
                  onPressed: () => setState(() => _obscure = !_obscure)))),
            const SizedBox(height: 6),
            Align(alignment: Alignment.centerRight,
              child: TextButton(onPressed: () {},
                child: Text('Mot de passe oublié ?',
                  style: GoogleFonts.poppins(color: AppColors.gold, fontSize: 13)))),
            const SizedBox(height: 22),

            SizedBox(height: 54,
              child: ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading
                  ? const SizedBox(width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Se connecter'))),
            const SizedBox(height: 12),
            SizedBox(height: 54,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.fingerprint_rounded, size: 24),
                label: const Text('Connexion biométrique'),
                onPressed: _login)),
            const SizedBox(height: 36),

            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text("Pas encore de compte ? ", style: GoogleFonts.poppins(
                color: textSecondary, fontSize: 14)),
              GestureDetector(
                onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen())),
                child: Text("S'inscrire", style: GoogleFonts.poppins(
                  color: AppColors.gold, fontWeight: FontWeight.w700, fontSize: 14))),
            ]),
            const SizedBox(height: 40),
            Text('© 2026 RawBank. Tous droits réservés.', textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 10, color: textSecondary)),
            const SizedBox(height: 2),
            Text('Conçu et développé par YuuStore', textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 10, color: textSecondary)),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }
}
