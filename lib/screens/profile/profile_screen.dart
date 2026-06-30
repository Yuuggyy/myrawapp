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
      appBar: AppBar(title: const Text('Mon Profil'), automaticallyImplyLeading: false),
      body: ListView(
        children: [
          // Header profil
          Container(
            color: AppColors.primary,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(MockUser.name.substring(0, 2).toUpperCase(),
                    style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
                ),
                const SizedBox(height: 12),
                Text(MockUser.name, style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
                Text(MockUser.email, style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _Badge(label: 'KYC ${MockUser.kycLevel}', color: Colors.green),
                    const SizedBox(width: 8),
                    _Badge(label: MockUser.clientType, color: Colors.white24),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // KYC Progress
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Niveau KYC', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 15)),
                      TextButton(onPressed: () {}, child: Text('Améliorer',
                        style: GoogleFonts.poppins(color: AppColors.primary, fontSize: 12))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _KycStep(label: 'Basic', isDone: true),
                      Expanded(child: Container(height: 2, color: AppColors.primary)),
                      _KycStep(label: 'Standard', isDone: true),
                      Expanded(child: Container(height: 2, color: AppColors.divider)),
                      _KycStep(label: 'Avancé', isDone: false),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Passez au niveau Avancé pour accéder aux financements > 50 000 USD',
                    style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textGrey)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Infos
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
              label: Text('Se déconnecter', style: GoogleFonts.poppins(color: AppColors.error, fontWeight: FontWeight.w600)),
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(child: Text('MyRawApp v1.0.0 · Inspire × YuuStore',
            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textLight))),
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
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
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
            color: isDone ? AppColors.primary : AppColors.divider,
            shape: BoxShape.circle,
          ),
          child: Icon(isDone ? Icons.check : Icons.circle_outlined,
            color: isDone ? Colors.white : AppColors.textLight, size: 16),
        ),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.poppins(fontSize: 10, color: isDone ? AppColors.primary : AppColors.textLight)),
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(title, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textGrey)),
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
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textGrey)),
              Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textGrey, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: GoogleFonts.poppins(fontSize: 14))),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }
}
