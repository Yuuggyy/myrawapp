import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../data/mock_data.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  int _selectedAccount = 0;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##0.00', 'fr_FR');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mes Comptes'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () {}),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Cards comptes
          SizedBox(
            height: 180,
            child: PageView.builder(
              itemCount: MockAccounts.accounts.length,
              onPageChanged: (i) => setState(() => _selectedAccount = i),
              itemBuilder: (_, i) {
                final account = MockAccounts.accounts[i];
                final isIllico = account['type'] == 'IllicoCash';
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isIllico
                          ? [const Color(0xFF1A237E), const Color(0xFF3949AB)]
                          : [AppColors.primaryDark, AppColors.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [BoxShadow(color: (isIllico ? Colors.indigo : AppColors.primary).withOpacity(0.3),
                        blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(account['type'], style: GoogleFonts.poppins(
                              color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                              child: Text(account['status'], style: GoogleFonts.poppins(
                                color: Colors.white, fontSize: 11)),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text('\$${formatter.format(account['balance'])}',
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text(account['number'], style: GoogleFonts.poppins(color: Colors.white60, fontSize: 12)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(MockAccounts.accounts.length, (i) =>
              Container(
                width: _selectedAccount == i ? 20 : 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: _selectedAccount == i ? AppColors.primary : AppColors.divider,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Actions rapides IllicoCash
          Text('Actions IllicoCash', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Row(
            children: [
              _AccountAction(icon: Icons.send_rounded, label: 'Envoyer', color: AppColors.primary),
              const SizedBox(width: 12),
              _AccountAction(icon: Icons.add_circle_outline_rounded, label: 'Recharger', color: const Color(0xFF1565C0)),
              const SizedBox(width: 12),
              _AccountAction(icon: Icons.payment_rounded, label: 'Payer', color: const Color(0xFF2E7D32)),
              const SizedBox(width: 12),
              _AccountAction(icon: Icons.history_rounded, label: 'Historique', color: AppColors.textGrey),
            ],
          ),
          const SizedBox(height: 24),

          // Demandes de compte
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                  child: const Icon(Icons.add_business_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ouvrir un compte Entreprise', style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, fontSize: 14)),
                    Text('KYB requis · Traitement 2-5 jours', style: GoogleFonts.poppins(
                      fontSize: 12, color: AppColors.textGrey)),
                  ],
                ),
                const Spacer(),
                const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textGrey),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Transactions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Historique', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700)),
              TextButton(onPressed: () {}, child: Text('Tout voir',
                style: GoogleFonts.poppins(color: AppColors.primary, fontSize: 13))),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
            ),
            child: Column(
              children: MockTransactions.transactions.asMap().entries.map((e) {
                final i = e.key; final t = e.value;
                return _TxTile(transaction: t, showDivider: i < MockTransactions.transactions.length - 1);
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _AccountAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _AccountAction({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 56,
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 6),
          Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textDark, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _TxTile extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final bool showDivider;
  const _TxTile({required this.transaction, required this.showDivider});

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction['type'] == 'credit';
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: (isCredit ? Colors.green : AppColors.primary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                  color: isCredit ? Colors.green : AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(transaction['description'], style: GoogleFonts.poppins(
                      fontSize: 13, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(transaction['reference'], style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textLight)),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${isCredit ? '+' : '-'}\$${NumberFormat('#,##0.00').format(transaction['amount'])}',
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w700,
                      color: isCredit ? Colors.green : AppColors.textDark)),
                  Text(transaction['date'], style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textGrey)),
                ],
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, indent: 72),
      ],
    );
  }
}
