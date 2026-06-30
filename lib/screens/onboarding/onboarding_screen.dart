import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _ctrl = PageController();
  int _page = 0;

  final _pages = const [
    {'icon': Icons.account_balance_rounded, 'title': 'La première banque\nde la RDC', 'sub': 'Gérez vos finances avec la puissance et le prestige de RawBank.'},
    {'icon': Icons.psychology_rounded, 'title': 'IA au service\nde vos projets', 'sub': 'Notre assistant analyse vos dossiers en temps réel — RSE, conformité, viabilité.'},
    {'icon': Icons.rocket_launch_rounded, 'title': 'Vos ambitions\nméritent mieux', 'sub': 'PME, agriculture, immobilier — déposez votre dossier en quelques minutes.'},
  ];

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _next() {
    if (_page < 2) {
      _ctrl.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : AppColors.lightBg;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(children: [
        PageView.builder(
          controller: _ctrl,
          onPageChanged: (i) => setState(() => _page = i),
          itemCount: 3,
          itemBuilder: (_, i) {
            final p = _pages[i];
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(children: [
                  const SizedBox(height: 60),
                  Container(
                    width: size.width * 0.44,
                    height: size.width * 0.44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gold.withOpacity(0.12),
                      border: Border.all(color: AppColors.gold.withOpacity(0.25), width: 1),
                    ),
                    child: Icon(p['icon'] as IconData,
                      size: size.width * 0.18, color: AppColors.gold),
                  ),
                  const Spacer(),
                  Text(p['title'] as String, textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w800,
                      color: textPrimary, height: 1.2)),
                  const SizedBox(height: 16),
                  Text(p['sub'] as String, textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 15, color: textSecondary, height: 1.6)),
                  const SizedBox(height: 100),
                ]),
              ),
            );
          },
        ),
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 16, 28, 24),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                SmoothPageIndicator(
                  controller: _ctrl, count: 3,
                  effect: ExpandingDotsEffect(
                    activeDotColor: AppColors.gold,
                    dotColor: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                    dotHeight: 8, dotWidth: 8, expansionFactor: 3),
                ),
                GestureDetector(
                  onTap: _next,
                  child: Container(
                    width: 56, height: 56,
                    decoration: const BoxDecoration(color: AppColors.gold, shape: BoxShape.circle),
                    child: Icon(_page == 2 ? Icons.check_rounded : Icons.arrow_forward_rounded,
                      color: Colors.white, size: 24),
                  ),
                ),
              ]),
            ),
          ),
        ),
        Positioned(
          top: 0, right: 0,
          child: SafeArea(
            child: TextButton(
              onPressed: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen())),
              child: Text('Passer', style: GoogleFonts.poppins(
                color: textSecondary, fontSize: 14)),
            ),
          ),
        ),
      ]),
    );
  }
}
