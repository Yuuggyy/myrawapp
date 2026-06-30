import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../data/mock_data.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : AppColors.lightBg;
    final card = isDark ? AppColors.darkCard : AppColors.lightCard;
    final divider = isDark ? AppColors.darkDivider : AppColors.lightDivider;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        automaticallyImplyLeading: false,
        title: Text('Profil', style: GoogleFonts.poppins(
          color: textPrimary, fontWeight: FontWeight.w700)),
      ),
      body: ListView(children: [
        // Header
        Container(
          color: bg,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          child: Column(children: [
            Container(
              width: 76, height: 76,
              decoration: const BoxDecoration(
                shape: BoxShape.circle, color: AppColors.gold),
              child: Center(child: Text(
                MockUser.name.substring(0, 2).toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white))),
            ),
            const SizedBox(height: 12),
            Text(MockUser.name, style: GoogleFonts.poppins(
              fontSize: 18, fontWeight: FontWeight.w700, color: textPrimary)),
            Text(MockUser.email, style: GoogleFonts.poppins(
              fontSize: 12, color: textSecondary)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              _Badge('KYC ${MockUser.kycLevel}', AppColors.success),
              const SizedBox(width: 8),
              _Badge(MockUser.clientType, AppColors.gold),
            ]),
          ]),
        ),

        Divider(height: 1, color: divider),
        const SizedBox(height: 12),

        _SectionTitle('Informations', textSecondary),
        _InfoTile(Icons.person_outline_rounded, 'Nom complet', MockUser.name, card, divider, textPrimary, textSecondary),
        _InfoTile(Icons.email_outlined, 'Email', MockUser.email, card, divider, textPrimary, textSecondary),
        _InfoTile(Icons.phone_outlined, 'Téléphone', MockUser.phone, card, divider, textPrimary, textSecondary),
        _InfoTile(Icons.credit_card_outlined, 'N° Client', MockUser.accountNumber, card, divider, textPrimary, textSecondary),
        const SizedBox(height: 8),

        _SectionTitle('Sécurité', textSecondary),
        _ActionTile(Icons.lock_outline_rounded, 'Changer le mot de passe', card, divider, textPrimary, () {}),
        _ActionTile(Icons.fingerprint_rounded, 'Biométrie', card, divider, textPrimary, () {}),
        _ActionTile(Icons.security_outlined, '2FA', card, divider, textPrimary, () {}),
        const SizedBox(height: 8),

        _SectionTitle('Support', textSecondary),
        _ActionTile(Icons.help_outline_rounded, 'FAQ', card, divider, textPrimary, () {}),
        _ActionTile(Icons.chat_outlined, 'Contacter RawBank', card, divider, textPrimary, () {}),
        const SizedBox(height: 8),

        Padding(
          padding: const EdgeInsets.all(16),
          child: OutlinedButton.icon(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
            label: Text('Se déconnecter', style: GoogleFonts.poppins(
              color: AppColors.error, fontWeight: FontWeight.w600)),
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text('© 2026 RawBank. Tous droits réservés.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 10, color: textSecondary)),
        const SizedBox(height: 2),
        Text('Conçu et développé par YuuStore',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 10, color: textSecondary)),
        const SizedBox(height: 24),
      ]),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label; final Color color;
  const _Badge(this.label, this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3))),
      child: Text(label, style: GoogleFonts.poppins(
        fontSize: 11, color: color, fontWeight: FontWeight.w600)));
  }
}

class _SectionTitle extends StatelessWidget {
  final String title; final Color color;
  const _SectionTitle(this.title, this.color);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
    child: Text(title, style: GoogleFonts.poppins(
      fontSize: 11, fontWeight: FontWeight.w700,
      color: AppColors.gold, letterSpacing: 0.5)));
}

class _InfoTile extends StatelessWidget {
  final IconData icon; final String label, value;
  final Color card, divider, textPrimary, textSecondary;
  const _InfoTile(this.icon, this.label, this.value,
    this.card, this.divider, this.textPrimary, this.textSecondary);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
    decoration: BoxDecoration(
      color: card, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: divider, width: 0.5)),
    child: Row(children: [
      Icon(icon, color: AppColors.gold, size: 18),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.poppins(fontSize: 11, color: textSecondary)),
        Text(value, style: GoogleFonts.poppins(fontSize: 13,
          fontWeight: FontWeight.w500, color: textPrimary)),
      ]),
    ]));
}

class _ActionTile extends StatelessWidget {
  final IconData icon; final String label;
  final Color card, divider, textPrimary;
  final VoidCallback onTap;
  const _ActionTile(this.icon, this.label, this.card, this.divider, this.textPrimary, this.onTap);
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: card, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: divider, width: 0.5)),
      child: Row(children: [
        Icon(icon, color: AppColors.gold, size: 18),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: GoogleFonts.poppins(
          fontSize: 13, color: textPrimary))),
        Icon(Icons.chevron_right_rounded, size: 18,
          color: AppColors.gold.withOpacity(0.5)),
      ])));
}
