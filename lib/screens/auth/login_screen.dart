import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../main.dart';
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
    final app = MyRawApp.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Theme toggle
              Align(
                alignment: Alignment.centerRight,
                child: _ThemeToggle(
                  current: app?.themeMode ?? ThemeMode.system,
                  onChanged: (m) => app?.setThemeMode(m),
                ),
              ),
              const SizedBox(height: 24),
              // Logo
              Center(
                child: Container(
                  width: 72, height: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.gold,
                  ),
                  child: Center(
                    child: Text('R', style: GoogleFonts.poppins(
                      fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Bienvenue', textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 26)),
              const SizedBox(height: 4),
              Text('Connectez-vous à votre espace', textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 40),

              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email ou N° client',
                  prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _pwCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20),
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
                    style: GoogleFonts.poppins(color: AppColors.gold, fontSize: 13)),
                ),
              ),
              const SizedBox(height: 20),

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                    ? const SizedBox(width: 22, height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Se connecter'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.fingerprint_rounded, size: 22),
                  label: const Text('Connexion biométrique'),
                  onPressed: _login,
                ),
              ),
              const SizedBox(height: 32),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text("Pas encore de compte ? ",
                  style: Theme.of(context).textTheme.bodySmall),
                GestureDetector(
                  onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  child: Text("S'inscrire", style: GoogleFonts.poppins(
                    color: AppColors.gold, fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ]),
              const SizedBox(height: 40),
              Text('© 2026 RawBank. Tous droits réservés.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 10,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
              const SizedBox(height: 4),
              Text('Conçu et développé par YuuStore',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 10,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  final ThemeMode current;
  final Function(ThemeMode) onChanged;
  const _ThemeToggle({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleBtn(icon: Icons.brightness_auto_rounded, isActive: current == ThemeMode.system,
            onTap: () => onChanged(ThemeMode.system)),
          _ToggleBtn(icon: Icons.light_mode_rounded, isActive: current == ThemeMode.light,
            onTap: () => onChanged(ThemeMode.light)),
          _ToggleBtn(icon: Icons.dark_mode_rounded, isActive: current == ThemeMode.dark,
            onTap: () => onChanged(ThemeMode.dark)),
        ],
      ),
    );
  }
}

class _ToggleBtn extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  const _ToggleBtn({required this.icon, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.gold : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(icon, size: 18,
          color: isActive ? Colors.white
            : (Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
      ),
    );
  }
}
