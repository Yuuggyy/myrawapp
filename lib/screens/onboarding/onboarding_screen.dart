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
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'icon': Icons.account_balance_rounded,
      'title': 'Première banque\nde la RDC',
      'subtitle': 'Gérez vos finances avec la puissance et le prestige de RawBank, pionnière du secteur bancaire congolais.',
      'gradient': [const Color(0xFF0A0A0A), const Color(0xFF1A1200)],
    },
    {
      'icon': Icons.psychology_rounded,
      'title': 'IA au service\nde vos projets',
      'subtitle': 'Notre intelligence artificielle analyse vos dossiers de financement en temps réel — RSE, conformité, viabilité commerciale.',
      'gradient': [const Color(0xFF0A0A0A), const Color(0xFF001220)],
    },
    {
      'icon': Icons.rocket_launch_rounded,
      'title': 'Vos ambitions\nméritent mieux',
      'subtitle': 'PME, agriculture, immobilier, Lady\'s First — déposez votre dossier en quelques minutes depuis votre téléphone.',
      'gradient': [const Color(0xFF0A0A0A), const Color(0xFF120010)],
    },
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < 2) {
      _controller.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _pages.length,
            itemBuilder: (_, i) {
              final page = _pages[i];
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: page['gradient'] as List<Color>,
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const SizedBox(height: 60),
                        // Icône
                        Container(
                          width: size.width * 0.45,
                          height: size.width * 0.45,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
                            color: AppColors.primary.withOpacity(0.08),
                          ),
                          child: Icon(page['icon'] as IconData,
                            size: size.width * 0.18, color: AppColors.primary),
                        ),
                        const Spacer(),
                        Text(page['title'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 30, fontWeight: FontWeight.w800,
                            color: AppColors.textWhite, height: 1.2)),
                        const SizedBox(height: 20),
                        Text(page['subtitle'] as String,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 15, color: AppColors.textGrey, height: 1.6)),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Bottom bar
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, AppColors.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SmoothPageIndicator(
                    controller: _controller,
                    count: 3,
                    effect: ExpandingDotsEffect(
                      activeDotColor: AppColors.primary,
                      dotColor: AppColors.divider,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                    ),
                  ),
                  GestureDetector(
                    onTap: _next,
                    child: Container(
                      width: 60, height: 60,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.primaryDark, AppColors.primaryLight],
                        ),
                      ),
                      child: Icon(
                        _currentPage == 2 ? Icons.check_rounded : Icons.arrow_forward_rounded,
                        color: AppColors.black, size: 26),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Skip
          Positioned(
            top: 0, right: 0,
            child: SafeArea(
              child: TextButton(
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen())),
                child: Text('Passer', style: GoogleFonts.poppins(
                  color: AppColors.textGrey, fontSize: 14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
