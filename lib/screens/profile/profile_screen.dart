import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Mon Profil',
          style: GoogleFonts.poppins(color: AppColors.textGold, fontWeight: FontWeight.w600)),
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.black,
      ),
      body: ListView(
        children: [
          // Header
          Container(
            color: AppColors.black,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            child: Column(
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primaryLight],
                    ),
                  ),
                  child: Center(
                    child: Text(MockUser.name.substring(0, 2).toUpperCase(),
                      style: GoogleFonts.poppins(
                        fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.black)),
                  ),
                ),
                const SizedBox(height: 12),
                Text(MockUser.name, style: GoogleFonts.poppins(
                  fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textWhite)),
                Text(MockUser.email, style: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.textGrey)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Badge(label: 'KYC ${MockUser.kycLevel}', color: AppColors.success),
                    const SizedBox(width: 8),
                    _Badge(label: MockUser.clientType, color: AppColors.primary),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // KYC Progress
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.divider, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Niveau KYC', style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textWhite)),
                      TextButton(onPressed: () {},
                        child: Text('Améliorer', style: GoogleFonts.poppins(
                          color: AppColors.primary, fontSize: 12))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _KycStep(label: 'Basic', isDone: true),
                      Expanded(child: Container(height: 1,
                        color: AppColors.primary.withOpacity(0.5))),
                      _KycStep(label: 'Standard', isDone: true),
                      Expanded(child: Container(height: 1, color: AppColors.divider)),
                      _KycStep(label: 'Avancé', isDone: false),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text('Passez au niveau Avancé pour les financements > 50 000 USD',
                    style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textGrey)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          _SectionTitle('Informations personnelles'),
          _InfoTile(icon: Icons.person_outline, label: 'Nom complet', value: MockUser.name),
          _InfoTile(icon: Icons.email_outlined, label: 'Email', value: MockUser.email),
          _InfoTile(icon: Icons.phone_outlined, label: 'Téléphone', value: MockUser.phone),
          _InfoTile(icon: Icons.credit_card_outlined, label: 'N° Client', value: MockUser.accountNumber),
          const SizedBox(height: 8),

          _SectionTitle('Sécurité'),
          _ActionTile(icon: Icons.lock_outline, label: 'Changer le mot de passe', onTap: () {}),
          _ActionTile(icon: Icons.fingerprint, label: 'Biométrie', onTap: () {}),
          _ActionTile(icon: Icons.security_outlined, label: 'Authentification 2FA', onTap: () {}),
          const SizedBox(height: 8),

          _SectionTitle('Aide & Support'),
          _ActionTile(icon: Icons.help_outline, label: 'FAQ', onTap: () {}),
          _ActionTile(icon: Icons.chat_outlined, label: 'Contacter RawBank', onTap: () {}),
          _ActionTile(icon: Icons.description_outlined, label: 'Conditions générales', onTap: () {}),
          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.all(16),
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout, color: AppColors.error),
              label: Text('Se déconnecter',
                style: GoogleFonts.poppins(color: AppColors.error, fontWeight: FontWeight.w600)),
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(child: Text('Inspire By YuuStore',
            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textLight, letterSpacing: 2))),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label, style: GoogleFonts.poppins(
        fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

class _KycStep extends StatelessWidget {
  final String label;
  final bool isDone;
  const _KycStep({required this.label, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 28, height: 28,
          decoration: BoxDecoration(
            color: isDone ? AppColors.primary : AppColors.blackSurface,
            shape: BoxShape.circle,
            border: Border.all(color: isDone ? AppColors.primary : AppColors.divider),
          ),
          child: Icon(isDone ? Icons.check : Icons.circle_outlined,
            color: isDone ? AppColors.black : AppColors.textLight, size: 14),
        ),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.poppins(
          fontSize: 9, color: isDone ? AppColors.primary : AppColors.textLight)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Text(title, style: GoogleFonts.poppins(
        fontSize: 12, fontWeight: FontWeight.w700,
        color: AppColors.textGold, letterSpacing: 0.5)),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 18),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textGrey)),
              Text(value, style: GoogleFonts.poppins(
                fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textWhite)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textGrey, size: 18),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: GoogleFonts.poppins(
              fontSize: 13, color: AppColors.textWhite))),
            const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textLight),
          ],
        ),
      ),
    );
  }
}
