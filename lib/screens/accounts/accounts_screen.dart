import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../data/mock_data.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkBg : AppColors.lightBg;
    final card = isDark ? AppColors.darkCard : AppColors.lightCard;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final divider = isDark ? AppColors.darkDivider : AppColors.lightDivider;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final fmt = NumberFormat('#,##0.00', 'fr_FR');

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: Text('Mes comptes', style: GoogleFonts.poppins(
          color: textPrimary, fontWeight: FontWeight.w700, fontSize: 18)),
        automaticallyImplyLeading: false,
        backgroundColor: bg,
        actions: [
          IconButton(
            icon: Icon(Icons.add_rounded, color: AppColors.gold),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Compte principal
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Compte Courant', style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.85), fontSize: 13)),
                  const Icon(Icons.account_balance_rounded, color: Colors.white, size: 22),
                ]),
                const SizedBox(height: 16),
                Text('\$${fmt.format(2450.75)}', style: GoogleFonts.poppins(
                  color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(MockUser.accountNumber, style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.7), fontSize: 13, letterSpacing: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Compte épargne
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: divider, width: 0.5),
            ),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.savings_rounded, color: AppColors.gold, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Compte Épargne', style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary)),
                Text('\$${fmt.format(8200.00)}', style: GoogleFonts.poppins(
                  fontSize: 13, color: textSecondary)),
              ])),
              const Icon(Icons.chevron_right_rounded, color: AppColors.gold),
            ]),
          ),
          const SizedBox(height: 8),

          // Compte Mobile
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: divider, width: 0.5),
            ),
            child: Row(children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.phone_android_rounded, color: AppColors.gold, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('IllicoCash', style: GoogleFonts.poppins(
                  fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary)),
                Text('+243 81 XXX XXXX', style: GoogleFonts.poppins(
                  fontSize: 13, color: textSecondary)),
              ])),
              const Icon(Icons.chevron_right_rounded, color: AppColors.gold),
            ]),
          ),
          const SizedBox(height: 24),

          Text('Dernières opérations', style: GoogleFonts.poppins(
            fontSize: 15, fontWeight: FontWeight.w700, color: textPrimary)),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: divider, width: 0.5),
            ),
            child: Column(
              children: MockTransactions.transactions.asMap().entries.map((e) {
                final tx = e.value;
                final isCredit = tx['type'] == 'credit';
                return Column(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    child: Row(children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: (isCredit ? AppColors.success : AppColors.error).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isCredit ? Icons.south_west_rounded : Icons.north_east_rounded,
                          color: isCredit ? AppColors.success : AppColors.error, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(tx['description'], style: GoogleFonts.poppins(
                          fontSize: 13, fontWeight: FontWeight.w500, color: textPrimary),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(tx['date'], style: GoogleFonts.poppins(
                          fontSize: 11, color: textSecondary)),
                      ])),
                      Text(
                        '${isCredit ? '+' : '-'}\$${NumberFormat('#,##0.00').format(tx['amount'])}',
                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w700,
                          color: isCredit ? AppColors.success : textPrimary)),
                    ]),
                  ),
                  if (e.key < MockTransactions.transactions.length - 1)
                    Divider(height: 1, indent: 68, color: divider),
                ]);
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
