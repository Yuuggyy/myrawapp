import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/illicocash_api.dart';
import '../../../data/models/account_model.dart';

class AccountsScreen extends StatefulWidget {
  const AccountsScreen({super.key});

  @override
  State<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends State<AccountsScreen> {
  final IllicoCashApi _api = IllicoCashApi()..init();
  bool _loading = true;

  double _balanceUsd = 2450.75;
  double _balanceCdf = 7450250;
  double _exchangeRate = 2950;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final balance = await _api.getBalance('+243810000001');
    final rate = await _api.getExchangeRate();
    if (mounted) {
      setState(() {
        if (balance['success'] == true) {
          _balanceUsd = (balance['data'] as Map)['balance_usd'].toDouble();
          _balanceCdf = (balance['data'] as Map)['balance_cdf'].toDouble();
        }
        if (rate['success'] == true) {
          _exchangeRate = ((rate['data'] as Map)['usd_to_cdf'] as num).toDouble();
        }
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.primary,
            toolbarHeight: 64,
            title: const Text('Mes Comptes', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: Colors.white),
                onPressed: () => _showCreateAccount(context),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total balance
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Solde total estimé', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(_balanceUsd),
                              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(width: 6),
                            const Text('USD', style: TextStyle(color: Colors.white54, fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '≈ ${NumberFormat.currency(symbol: 'FC ', decimalDigits: 0).format(_balanceCdf)} CDF',
                          style: const TextStyle(color: Colors.white54, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Taux: 1 USD = ${_exchangeRate.toStringAsFixed(0)} CDF',
                          style: const TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // IllicoCash account card
                  const Text('Mes comptes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),

                  // IllicoCash card
                  _AccountCard(
                    accountName: 'IllicoCash',
                    accountNumber: '001',
                    balance: _balanceUsd,
                    currency: 'USD',
                    icon: Icons.account_balance_wallet,
                    color: AppColors.primary,
                    actions: [
                      _ActionItem(icon: Icons.send, label: 'Envoyer', onTap: () => Navigator.pushNamed(context, '/transfer')),
                      _ActionItem(icon: Icons.add, label: 'Recharger', onTap: () => _showRecharge(context)),
                      _ActionItem(icon: Icons.qr_code, label: 'QR Pay', onTap: () => _showQrPay(context)),
                      _ActionItem(icon: Icons.receipt_long, label: 'Relevé', onTap: () => _showStatement(context)),
                    ],
                  ),

                  // Savings card
                  _AccountCard(
                    accountName: 'Compte Épargne',
                    accountNumber: '002',
                    balance: 6000.00,
                    currency: 'USD',
                    icon: Icons.savings_outlined,
                    color: AppColors.secondary,
                    actions: [
                      _ActionItem(icon: Icons.swap_horiz, label: 'Transfert', onTap: () => Navigator.pushNamed(context, '/transfer')),
                      _ActionItem(icon: Icons.history, label: 'Historique', onTap: () => _showStatement(context)),
                      _ActionItem(icon: Icons.download, label: 'Relevé', onTap: () => _showStatement(context)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Transactions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Historique des transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      TextButton(
                        onPressed: () => _showStatement(context),
                        child: const Text('Filtrer', style: TextStyle(color: AppColors.primary, fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._mockTransactions.map((t) => _TxTile(tx: t)),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Dialogs & Sheets ──

  void _showCreateAccount(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _CreateAccountSheet(api: _api, onCreated: _loadData),
    );
  }

  void _showRecharge(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => _RechargeSheet(api: _api, onDone: _loadData),
    );
  }

  void _showQrPay(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => const _QrPaySheet(),
    );
  }

  void _showStatement(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => const _StatementSheet(),
    );
  }
}

// ── Account Card ──
class _AccountCard extends StatelessWidget {
  final String accountName;
  final String accountNumber;
  final double balance;
  final String currency;
  final IconData icon;
  final Color color;
  final List<_ActionItem> actions;

  const _AccountCard({
    required this.accountName,
    required this.accountNumber,
    required this.balance,
    required this.currency,
    required this.icon,
    required this.color,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(accountName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    Text('•••• $accountNumber', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                child: const Text('Actif', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            NumberFormat.currency(symbol: '$currency ', decimalDigits: 2).format(balance),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Row(
            children: actions.map((a) {
              final i = actions.indexOf(a);
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < actions.length - 1 ? 8 : 0),
                  child: GestureDetector(
                    onTap: a.onTap,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(color: AppColors.grey100, borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        children: [
                          Icon(a.icon, size: 18, color: AppColors.primary),
                          const SizedBox(height: 4),
                          Text(a.label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionItem({required this.icon, required this.label, required this.onTap});
}

// ── Transaction Tile ──
class _TxTile extends StatelessWidget {
  final TransactionModel tx;
  const _TxTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isCredit = tx.type == TransactionType.credit;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: (isCredit ? AppColors.success : AppColors.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(isCredit ? Icons.south_west : Icons.north_east,
                color: isCredit ? AppColors.success : AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.description, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                const SizedBox(height: 2),
                Text(DateFormat('dd MMM yyyy, HH:mm').format(tx.createdAt),
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(tx.amount)}',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14,
                color: isCredit ? AppColors.success : AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

// ── Create Account Sheet ──
class _CreateAccountSheet extends StatefulWidget {
  final IllicoCashApi api;
  final VoidCallback onCreated;
  const _CreateAccountSheet({required this.api, required this.onCreated});

  @override
  State<_CreateAccountSheet> createState() => _CreateAccountSheetState();
}

class _CreateAccountSheetState extends State<_CreateAccountSheet> {
  final _phoneCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  String _accountType = 'illico';
  bool _loading = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _nameCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_phoneCtrl.text.isEmpty || _nameCtrl.text.isEmpty || _pinCtrl.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Remplissez tous les champs. PIN minimum 4 chiffres.')),
      );
      return;
    }

    setState(() => _loading = true);
    final result = await widget.api.createAccount(
      phone: _phoneCtrl.text,
      name: _nameCtrl.text,
      pin: _pinCtrl.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result['success'] == true) {
      widget.onCreated();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compte créé avec succès !'), backgroundColor: AppColors.success),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['error'] ?? 'Erreur'), backgroundColor: AppColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: AppColors.grey300, borderRadius: BorderRadius.circular(2))),
            ),
            const Text('Créer un compte', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('Ouvrez un nouveau compte IllicoCash ou Épargne',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 20),

            // Account type
            Row(
              children: [
                Expanded(
                  child: _TypeOption(
                    icon: Icons.account_balance_wallet, label: 'IllicoCash',
                    selected: _accountType == 'illico',
                    onTap: () => setState(() => _accountType = 'illico'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _TypeOption(
                    icon: Icons.savings_outlined, label: 'Épargne',
                    selected: _accountType == 'savings',
                    onTap: () => setState(() => _accountType = 'savings'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nom complet *', prefixIcon: Icon(Icons.person_outline)),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Numéro de téléphone *', prefixIcon: Icon(Icons.phone), hintText: '+243 ...'),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _pinCtrl,
              keyboardType: TextInputType.number,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'PIN (4 chiffres) *', prefixIcon: Icon(Icons.lock_outline)),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Créer le compte'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── Recharge Sheet ──
class _RechargeSheet extends StatefulWidget {
  final IllicoCashApi api;
  final VoidCallback onDone;
  const _RechargeSheet({required this.api, required this.onDone});

  @override
  State<_RechargeSheet> createState() => _RechargeSheetState();
}

class _RechargeSheetState extends State<_RechargeSheet> {
  final _amountCtrl = TextEditingController();
  String _method = 'bank';
  bool _loading = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_amountCtrl.text.isEmpty || double.tryParse(_amountCtrl.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Montant invalide')));
      return;
    }

    setState(() => _loading = true);
    final result = await widget.api.deposit(
      phone: '+243810000001',
      amount: double.parse(_amountCtrl.text),
      currency: 'USD',
      method: _method,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (result['success'] == true) {
      widget.onDone();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rechargé: \$${_amountCtrl.text} USD'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: AppColors.grey300, borderRadius: BorderRadius.circular(2))),
            ),
            const Text('Recharger IllicoCash', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),

            TextFormField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Montant (USD) *', prefixIcon: Icon(Icons.attach_money), hintText: '0.00'),
            ),
            const SizedBox(height: 16),

            const Text('Méthode', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _MethodChip(icon: Icons.account_balance, label: 'Banque', selected: _method == 'bank', onTap: () => setState(() => _method = 'bank'))),
                const SizedBox(width: 8),
                Expanded(child: _MethodChip(icon: Icons.money, label: 'Cash', selected: _method == 'cash', onTap: () => setState(() => _method = 'cash'))),
                const SizedBox(width: 8),
                Expanded(child: _MethodChip(icon: Icons.phone_android, label: 'Mobile Money', selected: _method == 'mobile_money', onTap: () => setState(() => _method = 'mobile_money'))),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Recharger'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ── QR Pay Sheet ──
class _QrPaySheet extends StatelessWidget {
  const _QrPaySheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(color: AppColors.grey300, borderRadius: BorderRadius.circular(2))),
          const Text('Paiement QR', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 24),
          Container(
            width: 200, height: 200,
            decoration: BoxDecoration(
              color: AppColors.grey100, borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.grey300),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_scanner, size: 64, color: AppColors.grey500),
                SizedBox(height: 12),
                Text('Scanner un QR code', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Placez le QR code du marchand dans le cadre',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Ouvrir la caméra'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Statement Sheet ──
class _StatementSheet extends StatelessWidget {
  const _StatementSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: AppColors.grey300, borderRadius: BorderRadius.circular(2))),
            ),
            const Text('Relevé de compte', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('Compte IllicoCash •••• 001',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            const SizedBox(height: 16),

            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Tout', 'Crédits', 'Débits', 'Transferts', 'Aujourd\'hui', '7 jours', '30 jours']
                    .map((f) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(label: Text(f), onSelected: (_) {}),
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: 16),

            ..._mockTransactions.map((t) => _StatementTxTile(tx: t)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _StatementTxTile extends StatelessWidget {
  final TransactionModel tx;
  const _StatementTxTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isCredit = tx.type == TransactionType.credit;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: (isCredit ? AppColors.success : AppColors.primary).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(isCredit ? Icons.add : Icons.remove, color: isCredit ? AppColors.success : AppColors.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.description, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text('${DateFormat('dd/MM').format(tx.createdAt)} • ${tx.reference}',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13,
                color: isCredit ? AppColors.success : AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

// ── Shared Widgets ──
class _TypeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TypeOption({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.06) : AppColors.grey100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primary : Colors.transparent, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? AppColors.primary : AppColors.grey700, size: 28),
            const SizedBox(height: 6),
            Text(label, style: TextStyle(fontWeight: selected ? FontWeight.w600 : FontWeight.w500, fontSize: 13,
                color: selected ? AppColors.primary : AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

class _MethodChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _MethodChip({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.06) : AppColors.grey100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primary : Colors.transparent, width: 2),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? AppColors.primary : AppColors.grey700, size: 22),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 11, fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? AppColors.primary : AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}

// ── Mock data ──
final _mockTransactions = [
  TransactionModel(
    id: 't1', accountId: 'acc1', type: TransactionType.credit, amount: 500.0, currency: 'USD',
    description: 'Virement reçu - ONG Partenaire', reference: 'REF001',
    status: 'completed', createdAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  TransactionModel(
    id: 't2', accountId: 'acc1', type: TransactionType.debit, amount: 49.50, currency: 'USD',
    description: 'Frais dossier PME', reference: 'REF002',
    status: 'completed', createdAt: DateTime.now().subtract(const Duration(hours: 8)),
  ),
  TransactionModel(
    id: 't3', accountId: 'acc1', type: TransactionType.transfer, amount: 200.0, currency: 'USD',
    description: 'Transfert IllicoCash → Sarah Kasa', reference: 'REF003',
    status: 'completed', createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  TransactionModel(
    id: 't4', accountId: 'acc1', type: TransactionType.debit, amount: 35.00, currency: 'USD',
    description: 'Achat carburant - Station Total', reference: 'REF004',
    status: 'completed', createdAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
  TransactionModel(
    id: 't5', accountId: 'acc1', type: TransactionType.credit, amount: 1200.0, currency: 'USD',
    description: 'Dépôt agence RawBank Gombe', reference: 'REF005',
    status: 'completed', createdAt: DateTime.now().subtract(const Duration(days: 4)),
  ),
  TransactionModel(
    id: 't6', accountId: 'acc1', type: TransactionType.transfer, amount: 150.0, currency: 'USD',
    description: 'Transfert IllicoCash → J. Tshisekedi', reference: 'REF006',
    status: 'completed', createdAt: DateTime.now().subtract(const Duration(days: 5)),
  ),
];
